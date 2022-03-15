#Config Variables
$env:PNPLEGACYMESSAGE='false'
$SiteToCopyFrom = "" #example: "https://033gc.sharepoint.com/sites/DEVBuroDB"
$SiteToCopyTo = "" #example: "https://033gc.sharepoint.com/sites/StagingBuroDB"
$ListName = "Shared Documents"
$CurrentPath = Get-Location


Write-Host "Connecting to the site to copy from ..."

#Connect to site with the assets we want to copy
Connect-PnPOnline -Url $SiteToCopyFrom -UseWebLogin

#Save the contents of the Shared Documents folder
$DocumentsFolder = Get-PnPFolder -List $ListName
$FileCount = 0

#Iterate over the contents of the Shared Documents folder
foreach($folder in $DocumentsFolder) {

    #For each folder get its relative path
    $FolderPath = $folder.ServerRelativeUrl.Substring($folder.ServerRelativeUrl.IndexOf($ListName))
    
    #Save the contents of the files in that folder
    $FolderItems = Get-PnPFolderItem -Identity $FolderPath
    
    #Iterate over each file in the folder
    foreach($file in $FolderItems) {
        
        #Save the file url
        $FileUrl = $file.ServerRelativeUrl.Substring($file.ServerRelativeUrl.IndexOf($ListName))
        
        #Download the file to the local machine
        Get-PnPFile -Url $FileUrl -Filename $file.Name -Path $CurrentPath.Path -AsFile -Force
        $FileCount++
    }
    
    #Connect to site that we want to copy site assets to
    Connect-PnPOnline -Url $SiteToCopyTo -UseWebLogin
    
    #Create the same folder from the previous site on the new one
    Add-PnPFolder -Name $folder.Name -Folder $ListName

    #Iterate over each file in the folder again
    foreach($file in $FolderItems) {
        if (Test-Path ("{0}\{1}" -f $CurrentPath.Path, $file.Name)) 
        {
            #Add the file to the new folder on the new site
            Add-PnPFile -Folder ("{0}/{1}" -f $ListName, $folder.Name) -Path ("{0}\{1}" -f $CurrentPath.Path, $file.Name)
            
            #Remove the file locally
            Remove-Item ("{0}\{1}" -f $CurrentPath.Path, $file.Name)
        }
    }
    

    #Connect to site with the assets we want to copy from
    Connect-PnPOnline -Url $SiteToCopyFrom -UseWebLogin
    
}

#Disconnect from the SharePoint sessions
Disconnect-PnPOnline

Write-Host "Successfully added " $DocumentsFolder.count " folder(s) and " $FileCount " file(s)"