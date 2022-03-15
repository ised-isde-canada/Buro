$SiteToDeleteFrom = "" #example: "https://033gc.sharepoint.com/sites/StagingBuroDB"
$SchemaNames = @('ExternalErrors', 'Users', 'Regions', 'Buildings', 'Neighbourhoods', 'Floors', 'Desks', 'Reservations', 'Translations', 'Timeslots', 'SeatingTypes', 'SeatingArrangements')

#Connect to site we want to clear
Connect-PnPOnline -Url $SiteToDeleteFrom -UseWebLogin 

#Iterate over each list
foreach($name in $SchemaNames){
    #Delete the list
    Remove-PnPList -Identity $name -Force
}

#Get the folders in the site's Shared Documents folder
$DocumentsFolder = Get-PnPFolderItem -Identity "$SiteToDeleteFrom/Shared Documents"
if($DocumentsFolder.count -gt 0) {
    #Iterate over each folder
    foreach($folder in $DocumentsFolder){
        if($folder.Name -ne "Forms") { 
            #Delete the folder
            Remove-PnPFolder -Name $folder.Name -Folder "Shared Documents" -Force 
        }
    }
}

Write-Host "Successfully delete all site contents from " $SiteToDeleteFrom

#Disconnect from the SharePoint sessions
Disconnect-PnPOnline
