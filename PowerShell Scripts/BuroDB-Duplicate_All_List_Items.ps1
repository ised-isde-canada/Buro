##FUNCTION BASED DB LIST DUPLICATION

#Config Variables
$env:PNPLEGACYMESSAGE='false'
$SiteToCopyFrom = "" #example: "https://033gc.sharepoint.com/sites/DEVBuroDB"
$SiteToCopyTo = "" #example: "https://033gc.sharepoint.com/sites/StagingBuroDB"
$SiteToCopyFromName = "" #example: "DEVBuroDB"
$SiteToCopyToName = "" #example: "StagingBuroDB"

$NoDependencyLists = @('Regions', 'Timeslots', 'Translations', 'SeatingTypes', 'SeatingArrangements')
$DependencyLists = @('Buildings', 'Neighbourhoods', 'Floors', 'Desks', 'Reservations')
$ColumnsWithLinks = @('seating_type_image', 'icon_link', 'desk_floor_plan_url', 'desk_image')

#DEBUG TOOL
#  $HashTable.GetEnumerator() | ForEach-Object{ Write-Host $_.key "=" $_.value }

<#
# Gets a record from a list by the ID column value
# @params 
#   RecordID - the record ID to find
#   List     - the list to find the record in
#>
function Get-RecordByID($RecordID, $List){
    foreach($record in $List) { 
        if($record.FieldValues.ID -eq $RecordID){ 
            return $record
            break
        }
    }
}


<#
# Gets a record from a list by matching a column value
# @params 
#   ColumnName    - the column name to match values for
#   RecordToMatch - a reference record to match a column value to
#   List          - the list to find the record in
#>
function Get-MatchingRecordByName($ColumnName, $RecordToMatch, $List) {
    foreach($record in $List){
        if($record.FieldValues.$ColumnName -eq $RecordToMatch.FieldValues.$ColumnName){
            return $record
            break
        }
    }

}

<#
# Gets all matching records from a list by matching a column value
# @params 
#   ColumnName    - the column name to match values for
#   RecordToMatch - a reference record to match a column value to
#   List          - the list to find the record in
#>
function Get-AllMatchingRecordsByName($ColumnName, $RecordToMatch, $List) {
    $MatchingRecords = @()
    foreach($record in $List){
        if($record.FieldValues.$ColumnName -eq $RecordToMatch.FieldValues.$ColumnName){
            $MatchingRecords += $record
        }
    }
    return $MatchingRecords
}

<#
# Gets a matching record from a list by matching each column value provided
# @params 
#   ColumnNames    - the column name(s) to match values for
#   RecordToMatch - a reference record to match the specified column values to
#   List          - the list to find the record in
#>
function Get-MatchingRecordByValues($ColumnNames, $RecordToMatch, $List){
    foreach($record in $List){
        $PassedCheck = $true
        foreach($item in $ColumnNames){
            if($record.FieldValues.$item -ne $RecordToMatch.FieldValues.$item){
                $PassedCheck = $false
            }
        }

        if($PassedCheck -eq $true){
            return $record
            break
        }
    }

}

<#
# Gets all matching records from a list by matching each column value provided
# @params 
#   ColumnNames    - the column name(s) to match values for
#   RecordToMatch - a reference record to match the specified column values to
#   List          - the list to find the record in
#>
function Get-AllMatchingRecordsByValues($ColumnNames, $RecordToMatch, $List){
    $MatchingRecords = @()
    foreach($record in $List){
        $PassedCheck = $true
        foreach($item in $ColumnNames){
            if($record.FieldValues.$item -ne $RecordToMatch.FieldValues.$item){
                $PassedCheck = $false
            }
        }

        if($PassedCheck -eq $true){
            $MatchingRecords += $record
        }
    }

    return $MatchingRecords

}

#Get user input on whether to copy over reservation items
$copyOverReservations = Read-Host -Prompt "Copy over Reservations: Yes [Y] or No [N]"

Write-Host "Connecting to the site to copy from ..."
#Connect to site with the list items we want to copy
Connect-PnPOnline -Url $SiteToCopyFrom -UseWebLogin 

#Iterate over the lists without dependencies
foreach($list in $NoDependencyLists){

    Write-Host "Copying over " $list
    
    #Get the records of the list
    $records = Get-PnPListItem -List $list

    #Get the view of the list (what list columns are seen on SharePoint)
    $view = Get-PnPView -List $list -Identity "All Items"
    
    #Save the column names of the view
    $columns = $view.ViewFields

    #Connect to site that we want to copy list items to
    Connect-PnPOnline -Url $SiteToCopyTo -UseWebLogin 
    
    #Iterate over each record
    foreach($record in $records){
        $HashTable=@{} 
        
        #Iterate over each column
        foreach($column in $columns){

            #If the column is one that has links
            if ($ColumnsWithLinks -contains $column.toString()) {
                #The column data has links to the old site update them to the new site
                $ColValue = $record.FieldValues[$column].Url -replace "$SiteToCopyFromName", "$SiteToCopyToName"
                $HashTable.Add($column, $ColValue)
            
            #Otherwise if the column 
            } elseif ($column.toString() -ne "ID") {
                #Add the column's name and value to the hash table
                $HashTable.Add($column, $record.FieldValues[$column])
            }
        }
        #Add the record to the new site
        Add-PnPListItem -List $list -Values $HashTable
    }

    #Connect to site with the list items we want to copy
    Connect-PnPOnline -Url $SiteToCopyFrom -UseWebLogin 
}


#Connect to the original site that we're copying from
Write-Host "Connecting to the site to copy from ..."
Connect-PnPOnline -Url $SiteToCopyFrom -UseWebLogin

Write-Host "Fetching Records"

#Get the following lists from the original site: Regions, Buildings
$OldRegionRecords = Get-PnPListItem -List "Regions"
$OldBuildingRecords = Get-PnPListItem -List "Buildings"

#Connect to the new site that we're copying to
Write-Host "Connecting to the site to copy to ..."
Connect-PnPOnline -Url $SiteToCopyTo -UseWebLogin

#Get the following lists from the new site: Regions 
$NewRegionsRecords = Get-PnPListItem -List "Regions"

#Get the view of the list (what list columns are seen on SharePoint)
$BuildingView = Get-PnPView -List "Buildings" -Identity "All Items"
#Save the column names of the view
$BuildingColumns = $BuildingView.ViewFields

#Copy over Building List 
Write-Host "Copying over Buildings"

#Iterate over each building record
foreach($OldBuildingRecord in $OldBuildingRecords){
    
    #Get the old region record from the old building record
    $OldRegionRecord = Get-RecordByID $OldBuildingRecord.ID $OldRegionRecords
    #Get the new region record that matches the old region's name
    $NewRegionID = Get-MatchingRecordByName "region_name_en" $OldRegionRecord $NewRegionsRecords

    $HashTable=@{} 
    #Iterate over each column
    foreach($BuildingColumn in $BuildingColumns){
        #Filter out the ID field from being added
        if($BuildingColumn.toString() -ne "ID") {
            #Filter the LookUp Field to Regions
            if($BuildingColumn.toString().Contains("region_id")){
                #Filter out the helper LookUp Fields
                if($BuildingColumn.toString() -eq "region_id"){
                    $HashTable.Add($BuildingColumn, $NewRegionID.ID)
                }
            } else {
                #If not an ID field, add the column normally
                $HashTable.Add($BuildingColumn, $OldBuildingRecord.FieldValues[$BuildingColumn])
            }
        }
    }

    #If our hash table is not empty, then we can add the record to the new site list
    if($HashTable.Count -ge 1){     
        Add-PnPListItem -List "Buildings" -Values $HashTable
    }      
}

Write-Host "Successfully added all " $OldBuildingRecords.Count " Buildings"

#----------------------------------------------------------------------------

#Connect to the original site that we're copying from
Connect-PnPOnline -Url $SiteToCopyFrom -UseWebLogin

#Get the following lists from the original site: Regions, Buildings, Floors
$OldRegionRecords = Get-PnPListItem -List "Regions"
$OldBuildingRecords = Get-PnPListItem -List "Buildings"
$OldFloorRecords = Get-PnPListItem -List "Floors"

#Connect to the new site that we're copying to
Connect-PnPOnline -Url $SiteToCopyTo -UseWebLogin 
#Get the following lists from the original site: Regions, Buildings
$NewRegionRecords = Get-PnPListItem -List "Regions"
$NewBuildingRecords = Get-PnPListItem -List "Buildings"

#Get the view of the list (what list columns are seen on SharePoint)
$FloorView = Get-PnPView -List "Floors" -Identity "All Items"
#Save the column names of the view
$FloorColumns = $FloorView.ViewFields

#Copy over Floors List 
Write-Host "Copying over Floors"
#Iterate over each record
foreach($OldFloorRecord in $OldFloorRecords){

    #Get the old building record from the old floor record
    $OldBuildingRecord = Get-RecordByID $OldFloorRecord.FieldValues.building_id.LookupId $OldBuildingRecords
    #Get the old region record from the old building record
    $OldRegionRecord = Get-RecordByID $OldBuildingRecord.FieldValues.region_id.LookupId $OldRegionRecords
    
    #Get the new building records that match the old building's name
    foreach($BuildingRecord in Get-AllMatchingRecordsByName "building_name_en" $OldBuildingRecord $NewBuildingRecords){
        #Get the new region records that match the old region's name
        foreach($RegionRecord in Get-AllMatchingRecordsByName "region_name_en" $OldRegionRecord $NewRegionRecords){
            #Does the new building's region_id and the new region's ID match
            if( $BuildingRecord.FieldValues.region_id.LookUpId -eq $RegionRecord.ID){
                #Save the matching records from the new site
                $NewFloor = $OldFloorRecord
                $NewBuilding = $BuildingRecord
                break
            }
        }
    }

    $HashTable=@{} 
    #Iterate over each column
    foreach($FloorColumn in $FloorColumns){
        #Filter out the ID field from being added
        if($FloorColumn.toString() -ne "ID") {
            #Filter the LookUp Field to Floors
            if($FloorColumn.toString().Contains("building_id")){
                #Filter out the helper LookUp Fields
                if($FloorColumn.toString() -eq "building_id"){
                    $HashTable.Add($FloorColumn, $NewBuilding.ID)
                }
            } else {
                #If not an ID field, add the column normally
                $HashTable.Add($FloorColumn, $NewFloor.FieldValues[$FloorColumn])
            }
        }
    }

    #If our hash table is not empty, then we can add the record to the table
    if($HashTable.Count -ge 1){
        Add-PnPListItem -List "Floors" -Values $HashTable    
    } 

}

Write-Host "Successfully added all " $OldFloorRecords.Count " Floors"

#----------------------------------------------------------------------------

#Connect to the original site that we're copying from
Connect-PnPOnline -Url $SiteToCopyFrom -UseWebLogin

#Get the following lists from the original site: Regions, Buildings, Floors, Neighbourhoods
$OldRegionRecords = Get-PnPListItem -List "Regions"
$OldBuildingRecords = Get-PnPListItem -List "Buildings"
$OldFloorRecords = Get-PnPListItem -List "Floors"
$OldNeighbourhoodRecords = Get-PnPListItem -List "Neighbourhoods"


#Connect to the new site that we're copying to
Connect-PnPOnline -Url $SiteToCopyTo -UseWebLogin 
#Get the following lists from the original site: Regions, Buildings, Floors
$NewRegionRecords = Get-PnPListItem -List "Regions"
$NewBuildingRecords = Get-PnPListItem -List "Buildings"
$NewFloorRecords = Get-PnPListItem -List "Floors"

#Get the view of the list (what list columns are seen on SharePoint)
$NeighbourhoodView = Get-PnPView -List "Neighbourhoods" -Identity "All Items"
#Save the column names of the view
$NeighbourhoodColumns = $NeighbourhoodView.ViewFields

#Copy over Neighbourhoods List 
Write-Host "Copying over Neighbourhoods"
#Iterate over each record
foreach($OldNeighbourhoodRecord in $OldNeighbourhoodRecords){

    #Get the old floor record from the old neighbourhood record
    $MatchingOldFloor = Get-RecordByID $OldNeighbourhoodRecord.FieldValues.floor_id.LookupId $OldFloorRecords
    #Get the old building record from the old floor record
    $MatchingOldBuilding = Get-RecordByID $MatchingOldFloor.FieldValues.building_id.LookupId $OldBuildingRecords
    #Get the old region record from the old building record
    $MatchingOldRegion = Get-RecordByID $MatchingOldBuilding.FieldValues.region_id.LookupId $OldRegionRecords
    
    #Get the new floor records that match the old floor's name
    foreach($FloorRecord in Get-AllMatchingRecordsByName "floor_name_en" $MatchingOldFloor $NewFloorRecords){
        #Get the new building records that match the old building's name
        foreach($BuildingRecord in Get-AllMatchingRecordsByName "building_name_en" $MatchingOldBuilding $NewBuildingRecords){
            #Get the new region records that match the old region's name
            foreach($RegionRecord in Get-AllMatchingRecordsByName "region_name_en" $MatchingOldRegion $NewRegionRecords){
                #Does the new floor's building_id and the new building's ID match &&
                #Does the new building's region_id and the new region's ID match
                If($FloorRecord.FieldValues.building_id.LookupId -eq $BuildingRecord.ID -and
                   $BuildingRecord.FieldValues.region_id.LookupId -eq $RegionRecord.ID ){
                    #Save the matching record from the new site
                    $MatchingNewFloor = $FloorRecord
                    break
                }
            }
        }
    }

    $HashTable=@{} 
    #Iterate over each column
    foreach($NeighbourhoodColumn in $NeighbourhoodColumns){
        #Filter out the ID field from being added
        if($NeighbourhoodColumn.toString() -ne "ID") {
            #Filter the LookUp Field to Neighbourhoods
            if($NeighbourhoodColumn.toString().Contains("floor_id")){
                #Filter out the helper LookUp Fields
                if($NeighbourhoodColumn.toString() -eq "floor_id"){
                    $HashTable.Add($NeighbourhoodColumn, $MatchingNewFloor.ID)
                }
            } else {
                #If not an ID field, add the column normally
                $HashTable.Add($NeighbourhoodColumn, $OldNeighbourhoodRecord.FieldValues[$NeighbourhoodColumn])
            }
        }
    }

    #If our hash table is not empty, then we can add the record to the table
    if($HashTable.Count -ge 1){
        Add-PnPListItem -List "Neighbourhoods" -Values $HashTable       
    } 


}

Write-Host "Successfully added all " $OldNeighbourhoodRecords.Count " Neighbourhoods"

#----------------------------------------------------------------------------

#Connect to the original site that we're copying from
Connect-PnPOnline -Url $SiteToCopyFrom -UseWebLogin
#Get the following lists from the original site: Regions, Buildings, Floors, Neighbourhoods, Desks, SeatingTypes, SeatingArrangements
$OldRegionRecords = Get-PnPListItem -List "Regions"
$OldBuildingRecords = Get-PnPListItem -List "Buildings"
$OldFloorRecords = Get-PnPListItem -List "Floors"
$OldNeighbourhoodRecords = Get-PnPListItem -List "Neighbourhoods"
$OldDeskRecords = Get-PnPListItem -List "Desks"
$OldSeatingTypeRecords = Get-PnPListItem -List "SeatingTypes"
$OldSeatingArrangementRecords = Get-PnPListItem -List "SeatingArrangements"

#Connect to the new site that we're copying to
Connect-PnPOnline -Url $SiteToCopyTo -UseWebLogin 
#Get the following lists from the original site: Regions, Buildings, Floors, Neighbourhoods, SeatingTypes, SeatingArrangements
$NewBuildingRecords = Get-PnPListItem -List "Buildings"
$NewRegionRecords = Get-PnPListItem -List "Regions"
$NewNeighbourhoodRecords = Get-PnPListItem -List "Neighbourhoods"
$NewFloorRecords = Get-PnPListItem -List "Floors"
$NewSeatingTypeRecords = Get-PnPListItem -List "SeatingTypes"
$NewSeatingArrangementRecords = Get-PnPListItem -List "SeatingArrangements"

#Get the view of the list (what list columns are seen on SharePoint)
$DeskView = Get-PnPView -List "Desks" -Identity "All Items"
#Save the column names of the view
$DeskColumns = $DeskView.ViewFields

#Copy over Desks List 
Write-Host "Copying over Desks"
#Iterate over each record
foreach($OldDeskRecord in $OldDeskRecords){

    #Get Seating Type Information
        #Get the old seating type record from the old desk record
        $MatchingOldSeatingType = Get-RecordByID $OldDeskRecord.FieldValues.seating_type_id.LookupId $OldSeatingTypeRecords
        #Get the new seating type record that matches the old seating type's name
        $MatchingNewSeatingType = Get-MatchingRecordByName "seating_type_name_en" $MatchingOldSeatingType $NewSeatingTypeRecords

    #Get Seating Arrangement Information
        #Get the old seating arrangement record from the old desk record
        $MatchingOldSeatingArrangement = Get-RecordByID $OldDeskRecord.FieldValues.seating_arrangement_id.LookupId $OldSeatingArrangementRecords
        #Get the new seating arrangement record that matches the old seating arrangement's name
        $MatchingNewSeatingArrangement = Get-MatchingRecordByName "seating_arrangement_name_en" $MatchingOldSeatingArrangement $NewSeatingArrangementRecords

    # Get Building Information
        #Get the old building record from the old desk record
        $MatchingOldBuilding = Get-RecordByID $OldDeskRecord.FieldValues.building_id.LookupId $OldBuildingRecords
        #Get the new building record that matches the old building's name
        $MatchingNewBuilding = Get-MatchingRecordByName "building_name_en" $MatchingOldBuilding $NewBuildingRecords

    # Get Neighbourhood Information
        #Get the old neighbourhood record from the old desk record
        $MatchingOldNeighbourhood = Get-RecordByID $OldDeskRecord.FieldValues.neighbourhood_id.LookupId $OldNeighbourhoodRecords
        #Get the old floor record from the old neighbourhood record
        $MatchingOldFloor = Get-RecordByID $MatchingOldNeighbourhood.FieldValues.floor_id.LookupId $OldFloorRecords
        #Get the old region record from the old building record
        $MatchingOldRegion = Get-RecordByID $MatchingOldBuilding.FieldValues.region_id.LookupId $OldRegionRecords
        
        #Verify the MatchingOldNeighbourhood's building record matches the MatchingOldBuilding record and they match the same region
        If($MatchingOldFloor.FieldValues.building_id.LookUpId -ne $MatchingOldBuilding.ID -or
           $MatchingOldBuilding.FieldValues.region_id.LookupID -ne $MatchingOldRegion.ID ){
            continue
        }

        #Get the new neighbourhood records that match the old neighbourhood's name
        foreach($NeighbourhoodRecord in Get-AllMatchingRecordsByName "neighbourhood_name_en" $MatchingOldNeighbourhood $NewNeighbourhoodRecords){
            #Get the new floor records that match the old floor's name
            foreach($FloorRecord in Get-AllMatchingRecordsByName "floor_name_en" $MatchingOldFloor $NewFloorRecords){
                #Does the new neighbourhood's floor_id and the new floor's ID match
                If($NeighbourhoodRecord.FieldValues.floor_id.LookUpId -eq $FloorRecord.ID){
                    #Get the new building records that match the old building's name
                    foreach($BuildingRecord in Get-AllMatchingRecordsByName "building_name_en" $MatchingOldBuilding $NewBuildingRecords){
                        #Does the new floor's building_id and the new building's ID match
                        If($FloorRecord.FieldValues.building_id.LookupId -eq $BuildingRecord.ID){
                            #Get the new region records that match the old region's name
                            foreach($RegionRecord in Get-AllMatchingRecordsByName "region_name_en" $MatchingOldRegion $NewRegionRecords){
                                #Does the new building's region_id and the new region's ID match
                                If($BuildingRecord.FieldValues.region_id.LookupId -eq $RegionRecord.ID){
                                    #Save the matching records from the new site
                                    $MatchingNewNeighbourhood = $NeighbourhoodRecord
                                    $MatchingNewBuilding = $BuildingRecord
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
    
    $HashTable=@{} 
    #Iterate over each column
    foreach($DeskColumn in $DeskColumns){
        #Filter out the ID field from being added
        if($DeskColumn.toString() -ne "ID") {
            #Filter the LookUp Fields
            if($DeskColumn.toString().Contains("_id")){

                #Filter out the helper LookUp Fields
                if($DeskColumn.toString() -eq "neighbourhood_id"){
                    $HashTable.Add($DeskColumn, $MatchingNewNeighbourhood.ID)
                } elseif ($DeskColumn.toString() -eq "building_id"){
                    $HashTable.Add($DeskColumn, $MatchingNewBuilding.ID)
                } elseif ($DeskColumn.toString() -eq "seating_type_id"){
                    $HashTable.Add($DeskColumn, $MatchingNewSeatingType.ID)
                } elseif ($DeskColumn.toString() -eq "seating_arrangement_id"){
                    $HashTable.Add($DeskColumn, $MatchingNewSeatingArrangement.ID)
                }
            } else {
                #Filter the image link Fields
                if( $ColumnsWithLinks -contains $DeskColumn.toString()){
                    $ColVal = $OldDeskRecord.FieldValues[$DeskColumn].Url -replace "$SiteToCopyFromName", "$SiteToCopyToName"
                    $HashTable.Add($DeskColumn, $ColVal)
                } else {
                    #If not a LookUp field or a image link field add the column normally
                    $HashTable.Add($DeskColumn, $OldDeskRecord.FieldValues[$DeskColumn])
                }
            }
        }
    }   

    #If our hash table is not empty, then we can add the record to the table
    if($HashTable.Count -ge 1){
        Add-PnPListItem -List "Desks" -Values $HashTable     
    }

}

Write-Host "Successfully added all " $OldDeskRecords.Count " Desks"

#----------------------------------------------------------------------------
#Do we copy over the reservations
If($copyOverReservations -eq "Y") {

    #Connect to the original site that we're copying from
    Connect-PnPOnline -Url $SiteToCopyFrom -UseWebLogin
    #Get the following lists from the original site: Regions, Buildings, Floors, Neighbourhoods, Desks, SeatingTypes, SeatingArrangements, Timeslots, Reservations
    $OldRegionRecords = Get-PnPListItem -List "Regions"
    $OldBuildingRecords = Get-PnPListItem -List "Buildings"
    $OldFloorRecords = Get-PnPListItem -List "Floors"
    $OldNeighbourhoodRecords = Get-PnPListItem -List "Neighbourhoods"
    $OldDeskRecords = Get-PnPListItem -List "Desks"
    $OldSeatingTypeRecords = Get-PnPListItem -List "SeatingTypes"
    $OldSeatingArrangementRecords = Get-PnPListItem -List "SeatingArrangements"
    $OldTimeslotRecords = Get-PnPListItem -List "Timeslots"
    $OldReservationRecords = Get-PnPListItem -List "Reservations"

    #Connect to the new site that we're copying to
    Connect-PnPOnline -Url $SiteToCopyTo -UseWebLogin 
    #Get the following lists from the original site: Regions, Buildings, Floors, Neighbourhoods, Desks, SeatingTypes, SeatingArrangements, Timeslots, Reservations
    $NewRegionRecords = Get-PnPListItem -List "Regions"
    $NewBuildingRecords = Get-PnPListItem -List "Buildings"
    $NewFloorRecords = Get-PnPListItem -List "Floors"
    $NewNeighbourhoodRecords = Get-PnPListItem -List "Neighbourhoods"
    $NewDeskRecords = Get-PnPListItem -List "Desks"
    $NewSeatingTypeRecords = Get-PnPListItem -List "SeatingTypes"
    $NewSeatingArrangementRecords = Get-PnPListItem -List "SeatingArrangements"
    $NewTimeslotRecords = Get-PnPListItem -List "Timeslots"

    #Get the view of the list (what list columns are seen on SharePoint)
    $ReservationView = Get-PnPView -List "Reservations" -Identity "All Items"
    #Save the column names of the view
    $ReservationColumns = $ReservationView.ViewFields

    #Copy over Desks List 
    Write-Host "Copying over Reservations"

    #Iterate over each record
    foreach($OldReservationRecord in $OldReservationRecords){
        
        #Get the Timeslot information
            #Get the old timeslot record from the old reservation record
            $MatchingOldTimeslot = Get-RecordByID $OldReservationRecord.FieldValues.timeslot_id.LookupId $OldTimeslotRecords
            #Get the new timeslot record that matches the old timeslot's name, starttime, and endtime
            $MatchingNewTimeslot = Get-MatchingRecordByValues @("time_range_en", "start_time_in_min", "end_time_in_min") $MatchingOldTimeslot $NewTimeslotRecords  
            

        #Get Old Desk Information
            #Get the old desk record from the old reservation record
            $MatchingOldDesk = Get-RecordByID $OldReservationRecord.FieldValues.desk_id.LookupId $OldDeskRecords
            #Get the old seating type record from the old desk record
            $MatchingOldSeatingType = Get-RecordByID $MatchingOldDesk.FieldValues.seating_type_id.LookupId $OldSeatingTypeRecords
            #Get the old seating arrangement record from the old desk record
            $MatchingOldSeatingArrangement = Get-RecordByID $MatchingOldDesk.FieldValues.seating_arrangement_id.LookupId $OldSeatingArrangementRecords
            #Get the old neighbourhood record from the old floor record
            $MatchingOldDesksNeighbourhood = Get-RecordByID $MatchingOldDesk.FieldValues.neighbourhood_id.LookupId $OldNeighbourhoodRecords
            #Get the old floor record from the old neighbourhood record
            $MatchingOldDesksFloor = Get-RecordByID $MatchingOldDesksNeighbourhood.FieldValues.floor_id.LookupId $OldFloorRecords
            #Get the old building record from the old desk record
            $MatchingOldDesksBuilding = Get-RecordByID $MatchingOldDesk.FieldValues.building_id.LookupId $OldBuildingRecords
            #Get the old region record from the old building record
            $MatchingOldDesksRegion = Get-RecordByID $MatchingOldDesksBuilding.FieldValues.region_id.LookupId $OldRegionRecords
        

            #Sanity check
            #Does the old desk's buulding_id match the old desks's floor's building_id
            if($MatchingOldDesksBuilding.ID -ne $MatchingOldDesksFloor.FieldValues.building_id.LookupId){
                #Skip adding it to the new site. Go to next iteration of loop
                continue
            }

    
    #Pair the Old Desk to the New Desk

       #Return new desks if the new desk and the old desk have the same name and workstation specifics
       :loop foreach($NewDeskRecord in Get-AllMatchingRecordsByValues @("desk_name_en", "workstation_specifics") $MatchingOldDesk $NewDeskRecords) { 
            #Get the new seating type records that match the old seating type's name
            foreach($NewSeatingTypeRecord in Get-AllMatchingRecordsByValues @("seating_type_name_en", "seating_type_description_en") $MatchingOldSeatingType $NewSeatingTypeRecords){
                #Get the new seating arrangement records that match the old seating arrangement's name
                foreach($NewSeatingArrangementRecord in Get-AllMatchingRecordsByName "seating_arrangement_en" $MatchingOldSeatingArrangement $NewSeatingArrangementRecords){
                    #Get the new neighbourhood records that match the old neighbourhood's name
                    foreach($NewNeighbourhoodRecord in Get-AllMatchingRecordsByName "neighbourhood_name_en" $MatchingOldDesksNeighbourhood $NewNeighbourhoodRecords){
                        #Does the new desk's neighbourhood_id and the new neighbourhood's ID match
                        if($NewDeskRecord.FieldValues.neighbourhood_id.LookupId -eq $NewNeighbourhoodRecord.ID){
                            #Get the new floor records that match the old floor's name
                            foreach($NewFloorRecord in Get-AllMatchingRecordsByName "floor_name_en" $MatchingOldDesksFloor $NewFloorRecords){
                                #Does the new floor's ID and the new neighbourhood's floor_id ID match
                                if($NewFloorRecord.ID -eq $NewNeighbourhoodRecord.FieldValues.floor_id.LookupId){
                                    #Get the new building records that match the old building's name
                                    foreach($NewBuildingRecord in Get-AllMatchingRecordsByName "building_name_en" $MatchingOldDesksBuilding $NewBuildingRecords){
                                        #Does the new building's ID and the new floor's building_id match &&
                                        #Does the new desk's building_id and the new building's ID match
                                        if( ($NewBuildingRecord.ID -eq $NewFloorRecord.FieldValues.building_id.LookupId) -and
                                            ($NewDeskRecord.FieldValues.building_id.LookupId -eq $NewBuildingRecord.ID)) {
                                                #Get the new region records that match the old region's name
                                                foreach($NewRegionRecord in Get-AllMatchingRecordsByName "region_name_en" $MatchingOldDesksRegion $NewRegionRecords){
                                                    #Does the new region's ID and the new building's region_id match
                                                    if($NewRegionRecord.ID -eq $NewBuildingRecord.FieldValues.region_id.LookupId){
                                                        #Save the matching record from the new site
                                                        $MatchingNewDesk = $NewDeskRecord
                                                        break loop
                                                    }
                                                }
                                            }
                                        }
                                    } 
                                }
                            }
                        }
                    }
                }
            }
            
        $HashTable=@{} 
        #Iterate over each column
        foreach($ReservationColumn in $ReservationColumns){
            #Filter out the ID field from being added
            if($ReservationColumn.toString() -ne "ID") {
                #Filter the LookUp Fields
                if($ReservationColumn.toString().Contains("_id")){

                    #Filter out the helper LookUp Fields
                    if($ReservationColumn.toString() -eq "desk_id"){
                        $HashTable.Add($ReservationColumn, $MatchingNewDesk.ID)
                    } elseif ($ReservationColumn.toString() -eq "timeslot_id"){
                        $HashTable.Add($ReservationColumn, $MatchingNewTimeslot.ID)
                    }
                } else {
                    #If not a LookUp field, add the column normally
                    $HashTable.Add($ReservationColumn, $OldReservationRecord.FieldValues[$ReservationColumn])
                }
            }
        }

        #If our hash table is not empty, then we can add the record to the table
        if($HashTable.Count -ge 1){
            Add-PnPListItem -List "Reservations" -Values $HashTable  
        }
    }
}

Write-Host "Successfully added all " $OldReservationRecords.Count " Reservations"

#----------------------------------------------------------------------------

Write-Host "Successfully copied over list items"


#Disconnect from the SharePoint sessions
Disconnect-PnPOnline