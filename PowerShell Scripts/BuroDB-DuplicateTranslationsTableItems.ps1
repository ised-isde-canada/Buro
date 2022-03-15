##FUNCTION BASED DB LIST DUPLICATION

#Config Variables
$env:PNPLEGACYMESSAGE='false'
$SiteToCopyFrom = "" #example: "https://033gc.sharepoint.com/sites/DEVBuroDB"
$SiteToCopyTo = "" #example: "https://033gc.sharepoint.com/sites/StagingBuroDB"

$ListToCopyOver = "Translations"

#DEBUG TOOL
#  $HashTable.GetEnumerator() | ForEach-Object{ Write-Host $_.key "=" $_.value }


Write-Host "Connecting to the site to copy from ..."
#Connect to site with the list items we want to copy
Connect-PnPOnline -Url $SiteToCopyFrom -UseWebLogin 


Write-Host "Copying over " $ListToCopyOver
    
#Get the records of the list
$records = Get-PnPListItem -List $ListToCopyOver

#Get the view of the list (what list columns are seen on SharePoint)
$view = Get-PnPView -List $ListToCopyOver -Identity "All Items"
    
#Save the column names of the view
$columns = $view.ViewFields

#Connect to site that we want to copy list items to
Connect-PnPOnline -Url $SiteToCopyTo -UseWebLogin 
    
#Iterate over each record
foreach($record in $records){
    $HashTable=@{} 
        
    #Iterate over each column
    foreach($column in $columns){
        if ($column.toString() -ne "ID") {
            #Add the column's name and value to the hash table
            $HashTable.Add($column, $record.FieldValues[$column])
        }
    }
    #Add the record to the new site
    Add-PnPListItem -List $ListToCopyOver -Values $HashTable
}

#Connect to site with the list items we want to copy
Connect-PnPOnline -Url $SiteToCopyFrom -UseWebLogin 


#----------------------------------------------------------------------------

Write-Host "Successfully copied over list items"


#Disconnect from the SharePoint sessions
Disconnect-PnPOnline