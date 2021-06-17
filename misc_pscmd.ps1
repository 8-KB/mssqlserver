Get-ChildItem env: # $env:computername #ComputerName 
Get-Variable $PSVersionTable.PSVersion #Powershell Version 

#Reboot time & username
Get-EventLog -LogName System  -Newest 10000 | Where-Object {$_.eventid -eq '1074'} | Select-Object MachineName , UserName , TimeGenerated |Sort-Object TimeGenerated -Descending

#Test Connection - Record Timeout

$server = @('s1','s2')
while ($true)
{
	$server | ForEach-Object {
		if (-not (Test-Connection $PSItem -Count 1 -Quiet)) {
			Write-Output "$($PSItem) : $(get-date) - Request Timed Out" |
			Out-File c:\_tools\S_log.txt -Append
		}
	}
}

#PSPing DateTime Log

.\psping.exe -t SQL01:1433 | ForEach-Object { "{0} - {1}" -f (Get-Date),$_ } | Tee-Object -FilePath "C:\Log\SQL01_log.txt"

#EventLog PS Query

$Begin = Get-Date -Date '12/10/2020 04:30:00'
$End = Get-Date -Date '12/10/2020 05:30:00'
Get-EventLog -LogName System -After $Begin -Before $End
Get-EventLog -LogName Application -After $Begin -Before $End
Get-EventLog -LogName Setup -After $Begin -Before $End
Get-EventLog -LogName Security -After $Begin -Before $End | Where-Object { $_.EntryType -eq 'FailureAudit' } | Out-GridView

#PS List files & details
Get-ChildItem "C:\Program Files\Microsoft SQL Server" -Filter *.exe -Recurse | ForEach-Object { $_.FullName }
Get-ChildItem "K:\" -Filter "*.*" -Recurse -File | Where-Object CreationTime -LT (Get-Date).AddDays(-180) | Select-Object fullname,creationtime | Out-GridView
Get-ChildItem "J:\" -Filter "*.bak" -Recurse -File | Where-Object CreationTime -LT (Get-Date).AddDays(-20) | Select-Object fullname,creationtime,@{ N = 'SizeIngb'; E = { [double]('{0:N2}' -f ($_.Length / 1gb)) } } | Out-GridView

#Search Text In Files

Get-ChildItem `
 	-Path "C:\Program Files\Microsoft SQL Server\" -Filter "*.*" -Recurse | `
 	Select-String -Pattern "Exception" | `
 	Select-Object -Property Path,LineNumber,Line | `
 	Export-Csv "C:\temp\Result.csv"


#Find Files greater than mentioned size

$path = "\\d$"
$size = 1MB
$limit = 500 ##Limit the number of rows
$Extension = "*.bak"
$largeSizefiles = Get-ChildItem -Path $path -Recurse -ErrorAction "SilentlyContinue" -Include $Extension | Where-Object { $_.GetType().Name -eq "FileInfo" } | Where-Object { $_.Length -gt $size } | Where-Object CreationTime -LT (Get-Date).AddDays(-7) | Sort-Object -Property length -Descending | Select-Object fullname,creationtime,@{ Name = "SizeInGB"; Expression = { $_.Length / 1GB } },@{ Name = "Path"; Expression = { $_.Directory } } -First $limit
$largeSizefiles | Out-GridView

#Cluster subnet Info
get-cluster | Format-List *subnet*
(get-cluster).SameSubnetDelay = 2000
(get-cluster).SameSubnetThreshold = 10

#Cluster Resouce Details 

Get-ClusterResource "SQL Network Name (XXXXXXXXX)" | ForEach-Object { $_.Name = “YYYYYYYYYYY” }

#Cluster AG Multisubnet 

Get-ClusterResource
Get-ClusterResource ag01 | Get-ClusterParameter
Get-ClusterResource ag01 | Set-ClusterParameter RegisterAllProvidersIP 0
Get-ClusterResource ag01 | Set-ClusterParameter HostRecordTTL 30

#List All Parameters    
$cn = Get-ClusterResource | Select-Object Name
$cn | ForEach-Object {

	Get-ClusterResource $cn.Name | Get-ClusterParameter

}

#Save PS Module

$wc = New-Object System.Net.WebClient
$wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials

Find-Module -Name "azurerm.storage" -Repository "PSGallery" | Save-Module -Path "C:\temp\PSModules\" -Verbose
