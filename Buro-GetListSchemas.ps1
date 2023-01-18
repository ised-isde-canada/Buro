#Config Variables
$SiteURL = "https://ChangeToSOURCESharePointSite.com"
$ListNames = @("Buildings", "Desks", "ExternalErrors", "Floors", "Neighbourhoods", "Regions", "Reservations", "SeatingArrangements", "SeatingTypes", "Timeslots", "Translations", "Users")
$ListsOutputFile = "C:\Temp\PnP\BuroListSchemas.xml"
 
#Connect to PNP Online
Connect-PnPOnline -Url $SiteURL -UseWebLogin
 
#Get the List schemas from the Site Templates and export to XML file
$Templates = Get-PnPProvisioningTemplate -OutputInstance -Handlers Lists -ListsToExtract $ListNames 
Save-PnPProvisioningTemplate -InputInstance $Templates -Out ($ListsOutputFile)	

