DECLARE @user sysname = (SELECT SUSER_SNAME()) ;
DECLARE @sql nvarchar(max) = 'xp_logininfo '''+@user+''',''all''';
EXEC sp_executesql @sql

exec xp_cmdshell 'powershell -command "([adsi]''WinNT://Domain/#USERNAME#,user'').ChangePassword(''oldpassword'',''newpassword'')"';

--Clears the clean buffers. This will flush cached indexes and data pages. 
--You may want to run a CHECKPOINT command first, in order to flush everything to disk.

CHECKPOINT;
GO
DBCC DROPCLEANBUFFERS;
GO

--Clears the procedure cache, which may free up some space in tempdb, although at the expense of your cached execution plans, which will need to be rebuilt the next time.
--This means that ad-hoc queries and stored procedures will have to recompile the next time you run them. Although this happens automatically, you may notice a significant performance decrease the first few times you run your procedures.

DBCC FREEPROCCACHE;
GO

--This operation is similar to FREEPROCCACHE, except it affects other types of caches.

DBCC FREESYSTEMCACHE ('ALL');
GO

--Flushes the distributed query connection cache. This has to do with distributed queries (queries between servers), but I’m really not sure how much space they actually take up in tempdb.

DBCC FREESESSIONCACHE;
GO

EXECUTE AS login='sa';

/* Enable Trace Flags 1204 and 1222 at global level  */

DBCC TRACEON (1204,-1);
GO
DBCC TRACEON (1222,-1);
GO

/* Second Option Enabling Trace Flags 1204 and 1222 using DBCC TRACEON Statement at global level */

DBCC TRACEON (1204, 1222, -1);

/* Disable Trace Flags 1204 and 1222 at global level */

DBCC TRACEOFF (1204,-1);
DBCC TRACEOFF (1222,-1);

/* Second Option Disable Trace Flags 1204 and 1222 using single DBCC TRACEON Statement at global level */

DBCC TRACEOFF (1204, 1222, -1);

select max(last_batch),min(last_batch),DATEADD(HOUR, -5, GETDATE()),DATEADD(HOUR, 5, GETDATE())
 from sys.sysprocesses
where loginame='DOMAIN\XXXX'
and status ='sleeping' and last_batch < DATEADD(HOUR, -24, GETDATE());

SELECT 'KILL ' + cast(spid AS VARCHAR(max)) + ';'
	,*
FROM sys.sysprocesses
WHERE dbid IN (
		SELECT database_id
		FROM sys.databases
		WHERE name = 'DB_Name' --change
		);

-- Multi Value SP --
SELECT T.C.value('.', 'NVARCHAR(20)') AS [ID]
INTO #TempNHI
FROM (
	SELECT CAST('<ID>' + REPLACE(@Local_ID, ',', '</ID><ID>') + '</ID>' AS XML) AS [IDs]
	) AS A
CROSS APPLY IDs.nodes('/ID') AS T(C);

---- Stuck in Single User Mode ---- 


SET DEADLOCK_PRIORITY high;

ALTER DATABASE [DBATools]
SET OFFLINE;

ALTER DATABASE [DBATools]
SET MULTI_USER;

ALTER DATABASE [DBATools]
SET ONLINE;

------------------------------------------------------------------------

SELECT SERVERPROPERTY('MachineName') MachineName
	,SERVERPROPERTY('productversion') productversion
	,SUBSTRING(cast(@@VERSION AS VARCHAR(max)), 1, CHARINDEX(CAST(SERVERPROPERTY('productversion') AS VARCHAR(max)), cast(@@VERSION AS VARCHAR(max)), 1) + len(CAST(SERVERPROPERTY('productversion') AS VARCHAR(max)))) Version
WHERE SERVERPROPERTY('MachineName') ='';
------------------------------------------------------------------------
