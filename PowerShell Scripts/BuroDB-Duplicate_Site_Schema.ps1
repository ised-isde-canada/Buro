#Config Variables
$SiteToCopyFrom = "" #example: "https://033gc.sharepoint.com/sites/DEVBuroDB"
$SiteToCopyTo = "" #example: "https://033gc.sharepoint.com/sites/StagingBuroDB"
$SchemaNames = @('ExternalErrors', 'Users', 'Regions', 'Buildings', 'Neighbourhoods', 'Floors', 'Desks', 'Reservations', 'Translations', 'Timeslots', 'SeatingTypes', 'SeatingArrangements')

Write-Host "Connecting to the site to copy from ..."
#Connect to site with the schema we want to copy
Connect-PnPOnline -Url $SiteToCopyFrom -UseWebLogin 

Write-Host "Copying the list schema from the site ..."

#Get the provisioning template from the site to copy from
$ProvisioningTemplate = Get-PnPProvisioningTemplate -OutputInstance -Handlers Lists -ListsToExtract $SchemaNames

Write-Host "Connecting to the site to copy to ..."
#Connect to site we want to copy the schema to
Connect-PnPOnline -Url $SiteToCopyTo -UseWebLogin

Write-Host "Copying over the List Schemas ..."
#Apply the list schemas to the new site
Apply-PnPProvisioningTemplate -InputInstance $ProvisioningTemplate

Write-Host "Remove the Title's Column Required property ..."
#Remove the Title's Required property
foreach($item in $SchemaNames) { Set-PnPField -List $item -Identity "Title" -Values @{Required=$false} }

#Disconnect from the SharePoint sessions
Disconnect-PnPOnline

Write-Host "Successfully cloned the lists of " $SiteToCopyFrom " to " $SiteToCopyTo


