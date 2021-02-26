$servers = Get-Content "C:\SQLDBA\server.txt"

$ps_Scriptblock = ForEach-Object {

	Invoke-Command -ComputerName $servers -ScriptBlock { Get-WmiObject win32_operatingsystem | Select-Object csname,@{ LABEL = ’LastBootUpTime’; EXPRESSION = { $_.ConverttoDateTime($_.lastbootuptime) } } } -Verbose
}

$ps_Scriptblock | Out-GridView
