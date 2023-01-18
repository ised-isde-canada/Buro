#Config Variables
$SiteURL = "https://ChangeToTARGETSharePointSite.com"
$ListName = "Translations"
$CSVFile = "C:\Temp\PnP\TranslationsTemplate.csv"

###!!! CSV Fields need to be hard coded in script below. 
###To Do: investigate using for loop to iterate through columns 
 
#Get the CSV file contents
$CSVData = Import-Csv -Path $CSVFile -header "ID","key","text","language" -delimiter ","
 
#Connect to site
Connect-PnPOnline $SiteUrl -UseWebLogin
 
#Iterate through each Row in the CSV and import data to SharePoint Online List
foreach ($Row in $CSVData)
{
    if ($Row.key -ne "key")	
    {

	Add-PnPListItem -List $ListName -Values @{
                              "key" = $($Row.key)
                              "text" = $($Row.text)
                              "language" = $($Row.language)}
    }
}

