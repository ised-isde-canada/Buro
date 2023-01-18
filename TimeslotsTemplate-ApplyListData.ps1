#Config Variables
$SiteURL = "https://ChangeToTARGETSharePointSite.com"
$ListName = "Timeslots"
$CSVFile = "C:\Temp\PnP\TimeslotsTemplate.csv"

###!!! CSV Fields need to be hard coded in script below. 
###To Do: investigate using for loop to iterate through columns 
 
#Get the CSV file contents
$CSVData = Import-Csv -Path $CSVFile -header "ID","time_range_en","time_range_fr","start_time","start_time_in_min","end_time","end_time_in_min" -delimiter ","
 
#Connect to site
Connect-PnPOnline $SiteUrl -UseWebLogin
 
#Iterate through each Row in the CSV and import data to SharePoint Online List
foreach ($Row in $CSVData)
{
    if ($Row.ID -ne "ID")	
    {

	Add-PnPListItem -List $ListName -Values @{
                              "time_range_en" = $($Row.time_range_en)
                              "time_range_fr" = $($Row.time_range_fr)
                              "start_time" = $($Row.start_time)
                              "start_time_in_min" = $($Row.start_time_in_min)
                              "end_time" = $($Row.end_time)
                              "end_time_in_min" = $($Row.end_time_in_min)}
    }
}

