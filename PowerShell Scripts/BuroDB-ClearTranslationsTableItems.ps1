$SiteToDeleteFrom = "" #example: "https://033gc.sharepoint.com/sites/StagingBuroDB"
$SchemaName = 'Translations'

#Connect to site we want to clear
Connect-PnPOnline -Url $SiteToDeleteFrom -UseWebLogin 

$Items = Get-PnPListItem -List "Translations"
$FirstItem = ($Items | Select-Object -first 1).Id
$LastItem =  ($Items | Select-Object -last 1).Id

$FirstItem..$LastItem | ForEach-Object{Remove-PnPListItem -List $SchemaName -Identity $_ -Force}

Write-Host "Successfully cleared items from the " $SchemaName " table"

#Disconnect from the SharePoint sessions
Disconnect-PnPOnline