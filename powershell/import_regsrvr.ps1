#ensure the script is run under SQL Server PowerShell window
if ((Get-Process -Id $pid).MainWindowTitle -ne 'SQL Server PowerShell')
{
	Write-Error "`r`n`r`nScript should be run in SQL Server PowerShell Window. `r`n`r`nPlease start SQLPS from SSMS to ensure the correct SQLPS version loaded";
	return;

}

[string]$choice = 'Database Engine Server Group' # 'Central Management Server Group\CentralServerName';
$srv = @();

#part 1: Interpret the tct file
$pf = '.';
switch -Regex -File C:\_dbccheck\reg\server_list.txt # change to your own txt file path
{
	"^\s*\[(\w+[^\\])]$" #folder, the format is [folder]
	{
		$srv += New-Object -TypeName psobject -Property @{ ParentFolder = '.'; Type = 'Directory'; Value = $Matches[1]; };
		$Pf = $matches[1];
	}

	"^\s*\[(\w+\\.+)]$" #sub-folder, the format is [folder\subfolder]
	{
		$pf = Split-Path -Path $matches[1];
		[string]$leaf = Split-Path $matches[1] -Leaf;
		$srv += New-Object -TypeName psobject -Property @{ ParentFolder = $pf; Type = 'Directory'; Value = $leaf; };
		$pf = $matches[1];

	}

	'^\s*(?![;#\[])(.+)' # if you want to comment out one server, just put ; or # in front of the server name    
	{
		$srv += New-Object -TypeName PSObject -Property @{ ParentFolder = $pf; Type = 'Registration'; Value = $matches[1]; }
	}

}

#part 2: create the folder/registered server based on the info in $srv

Set-Location "SQLServer:\SqlRegistration\$($choice)";
Get-ChildItem -Recurse | Remove-Item -Force; #clean up everything
foreach ($g in $srv)
{
	if ($g.Type -eq 'Directory')
	{
		if ($g.ParentFolder -eq '.')
		{
			Set-Location -LiteralPath "SQLServer:\SqlRegistration\$($choice)"
		}
		else
		{
			Set-Location -LiteralPath "SQLServer:\SqlRegistration\$($choice)\$($g.ParentFolder)";
		}
		New-Item -Path $g.Value -ItemType $g.Type;
	}
	else # it is a registered server
	{
		$regsrv = $g.Value.Replace("%5C","\")
		New-Item -Name $(Encode-SqlName $g.Value) -Path "sqlserver:\SQLRegistration\$($choice)\$($g.parentfolder)" -ItemType $g.Type -Value ("Server=$regsrv ; integrated security=true");
	}

}

Set-Location "SQLServer:\SqlRegistration\$($choice)";

#Source : https://www.mssqltips.com/sqlservertip/3252/automate-registering-and-maintaining-servers-in-sql-server-management-studio-ssms/
