SELECT CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS SERVER
	,msdb.dbo.backupset.database_name
	,msdb.dbo.backupset.backup_start_date
	,msdb.dbo.backupset.backup_finish_date
	,msdb.dbo.backupset.expiration_date
	,CASE msdb..backupset.type
		WHEN 'D'
			THEN 'Database'
		WHEN 'L'
			THEN 'Log'
		WHEN 'I'
			THEN 'Differential'
		END AS backup_type
	,CAST(msdb.dbo.backupset.backup_size / 1024 / 1024 / 1024 AS DECIMAL(10, 4)) backup_size_GB
	,msdb.dbo.backupset.backup_size
	,msdb.dbo.backupset.compressed_backup_size
	,msdb.dbo.backupmediafamily.logical_device_name
	,msdb.dbo.backupmediafamily.physical_device_name
	,[user_name]
	,msdb.dbo.backupset.is_copy_only
	,msdb.dbo.backupset.is_snapshot
	,msdb.dbo.backupset.checkpoint_lsn
	,msdb.dbo.backupset.database_backup_lsn
	,msdb.dbo.backupset.differential_base_lsn
	,msdb.dbo.backupset.first_lsn
	,msdb.dbo.backupset.fork_point_lsn
	,msdb.dbo.backupset.last_lsn
FROM msdb.dbo.backupmediafamily
INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id
WHERE (CONVERT(DATETIME, msdb.dbo.backupset.backup_start_date, 102) >= GETDATE() - 1)
--AND msdb..backupset.type = 'L'
--AND msdb.dbo.backupset.database_name = 'master'
ORDER BY msdb.dbo.backupset.database_name
	,msdb.dbo.backupset.backup_finish_date DESC
	
	
---------------------------
-- Missing backup by date
---------------------------
if  object_id('tempdb..#dbtmp','u') is not null drop table #dbtmp
create table #dbtmp (
	databasename sysname
)
IF charindex('Microsoft SQL Server  2000',@@version) =0 
BEGIN 
	insert into #dbtmp (databasename)
	select name
	from sys.databases 
	where state=0 and database_id <> 2 and is_in_standby<>1  
	if object_id('sys.fn_hadr_backup_is_preferred_replica') is not null
	begin
		delete #dbtmp
		where sys.fn_hadr_backup_is_preferred_replica(databasename)=0
	end
END
ELSE
BEGIN 
	insert into #dbtmp (databasename)
	select name
	from master.dbo.sysdatabases 
	where dbid <> 2 and DATABASEPROPERTYEX(name, 'Status') = 'ONLINE' and DATABASEPROPERTYEX(name, 'IsInStandBy') = 0
END

DECLARE @day int=7

SELECT CAST(DATEADD(DAY, number + 1, GETDATE() - (@day+1)) AS DATE) [backup_date]
	,sd.databasename databasename
INTO #date_list
FROM master..spt_values
CROSS APPLY #dbtmp sd
WHERE type = 'P'
	AND DATEADD(DAY, number + 1, GETDATE() - (@day+1)) < GETDATE()

SELECT cast(backup_start_date AS DATE) backup_date
	,database_name
INTO #backup_list
FROM msdb.dbo.backupset
WHERE is_copy_only != 1
	AND is_snapshot ! = 1
	AND type != 'L'
	AND backup_start_date > GETDATE() - (@day + 7)

SELECT DATENAME(WEEKDAY,dl.backup_date) [week_day],*
FROM #date_list dl
LEFT JOIN #backup_list bl ON dl.backup_date = bl.backup_date
	AND dl.databasename = bl.database_name
WHERE bl.backup_date is null

DROP TABLE #backup_list
DROP TABLE #date_list
