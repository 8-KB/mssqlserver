##########################################################
## Load SQL Server SMO objects (Dot Net name space)
##########################################################
[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null

# Disable Log Backup and LS Jobs

$Logs = "C:\log\DiableJob_$(get-date -f 'yyyy-MM-dd_HHMM').txt"
"Script starting at $(get-date) by $($env:USERDOMAIN)\$($env:USERNAME)" | Out-File $Logs

$PPInstance = "SQL1"
$PPDRInstance = "SQL1"
$jobPPSQLServer = New-Object microsoft.sqlserver.management.smo.server ($PPInstance)
$jobPPDRSQLServer = New-Object microsoft.sqlserver.management.smo.server ($PPDRInstance)
$ppjobs = $jobPPSQLServer.JobServer.Jobs | Where-Object { $_.Name -in ('J1','J2','J3') }
foreach ($ppjob in $ppjobs)
{
	$ppjob.IsEnabled = $TRUE
	$ppjob.Alter()
	$ppjob.OriginatingServer + ' : ' + $ppjob.Name + ' Is Enabled : ' + $ppjob.IsEnabled | Tee-Object $Logs -Append
}

$ppdrjobs = $jobPPDRSQLServer.JobServer.Jobs | Where-Object { $_.Name -in ('J1','J2','J3') }
foreach ($ppdrjob in $ppdrjobs)
{
	$ppdrjob.IsEnabled = $TRUE
	$ppdrjob.Alter()
	$ppdrjob.OriginatingServer + ' : ' + $ppdrjob.Name + ' Is Enabled : ' + $ppdrjob.IsEnabled | Tee-Object $Logs -Append
}
