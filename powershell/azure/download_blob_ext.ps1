$LogTime = Get-Date -Format "yyyy-MM-dd"
$LogFile = 'C:\Log\' + "Download_Trn_Blob_" + $LogTime + ".log"

Start-Transcript $LogFile -Append
$Hour = 1
$BackupTime = (Get-Date).AddHours(- $Hour)
$storage_account = ''
$storage_account_key = ''
$storage_context = New-AzureStorageContext -StorageAccountName $storage_account -StorageAccountKey $storage_account_key -ErrorAction Stop -Verbose
$contaninerlist = Get-AzureStorageContainer -Context $storage_context -Verbose | Where-Object name -In "tlog-backups" | Select-Object name
$contaninerlist | ForEach-Object {
	$containername = $_.Name
	$filelist = Get-AzureStorageBlob -Context $storage_context -Container $containername -Blob "*.trn" | Where-Object LastModified -GT $BackupTime | Select-Object *,@{ N = 'LengthIngb'; E = { [double]('{0:N2}' -f ($_.Length / 1gb)) } },@{ N = 'DateString'; E = { [regex]::Matches($_.Name,'\d{14}').Value,"yyyyMMddHHmmss" } },@{ N = 'StartDate'; E = { [datetime]::ParseExact([regex]::Matches($_.Name,'\d{14}').Value,"yyyyMMddHHmmss",[System.Globalization.CultureInfo]::CurrentCulture) } }

	foreach ($file in $filelist | Where-Object { ($_.StartDate -gt $BackupTime) -and ($_.StartDate -ne $null) })
	{
		if ($file.Name -ne $null)
		{

			"Backups Since : " + $Hour + " hours - " + $BackupTime + " | " + $storage_account + "\" + $containername + "\" + $file.Name + " | Last Modified : " + $file.LastModified + " | Backup Start : " + $file.StartDate
			Get-AzureStorageBlobContent -Context $storage_context -Container $containername -Blob $file.Name -Destination "\\SQLDBANET\BLOB\" #-WhatIf
			$flag = 1
		}
	}
	if ($flag -eq 0 -or $flag -eq $null) { Write-Host "No Recent backups:",$BackupTime }


}

Stop-Transcript
