#Config Variables
$SiteURL = "https://ChangeToTARGETSharePointSite.com"
$TemplateFile = "C:\Temp\PnP\Buro-ListSchemas.xml"
 
#Connect to PNP Online
Connect-PnPOnline -Url $SiteURL -UseWebLogin
 
Write-Host "Creating List(s) from Template File..."
Apply-PnPProvisioningTemplate -Path $TemplateFile

Write-Host "Removing the 'Title' as a required field"
$xml = [xml](Get-Content -Path $TemplateFile)
$namespaceMgr = New-Object System.Xml.XmlNamespaceManager $xml.NameTable
$namespaceMgr.AddNameSpace("pnp", "http://schemas.dev.office.com/PnP/2020/02/ProvisioningSchema")

[string]$xpath='/pnp:Lists/pnp:ListInstance/Title'

$nodes = $xml.SelectSingleNode($xpath, $namespaceMgr)
Write-Host $nodes

Write-Host $xml.DocumentElement.Lists.ListInstance

foreach($item in $xml.Provisioning.Templates.ProvisioningTemplate.Lists.ListInstance) {
 Set-PnPField -List $item.SelectSingleNode('@Title', $namespaceMgr).'#text' -Identity "Title" -Values @{Required=$false} 
}
