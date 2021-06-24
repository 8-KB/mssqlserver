DECLARE @log_reduce_percent INT = 50;

CREATE TABLE #logsize (
	Dbname SYSNAME
	,Log_File_Size_MB DECIMAL(38, 2) DEFAULT(0)
	,log_Space_Used_MB DECIMAL(30, 2) DEFAULT(0)
	,log_Free_Space_MB DECIMAL(30, 2) DEFAULT(0)
	);

INSERT INTO #logsize (
	Dbname
	,Log_File_Size_MB
	,log_Space_Used_MB
	,log_Free_Space_MB
	)
EXEC sp_MSforeachdb 'use [?]; 
  select DB_NAME() AS DbName, 
sum(size)/128.0 AS Log_File_Size_MB, 
sum(CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT))/128.0 as log_Space_Used_MB, 
SUM( size)/128.0 - sum(CAST(FILEPROPERTY(name,''SpaceUsed'') AS INT))/128.0 AS log_Free_Space_MB  
from sys.database_files  where type=1 group by type';

SELECT @@SERVERNAME [Server]
	,l.*
	,Cast((log_Free_Space_MB / Log_File_Size_MB) * 100 AS DECIMAL(10, 2)) [%Free]
	,log_reuse_wait_desc
	,CASE 
		WHEN log_reuse_wait_desc = 'NOTHING'
			THEN 'USE [' + d.name + N']' + CHAR(13) + CHAR(10) + 'DBCC SHRINKFILE (N''' + mf.name + N''' , ' + CAST(CAST(log_Free_Space_MB * @log_reduce_percent / 100 AS INT) AS NVARCHAR(128)) + ');' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
		END [tsql]
FROM #logsize l
LEFT JOIN sys.databases d ON l.Dbname = d.name
LEFT JOIN sys.master_files mf ON mf.database_id = d.database_id
WHERE  mf.type_desc = 'LOG' --and d.database_id > 4
DROP TABLE #logsize
