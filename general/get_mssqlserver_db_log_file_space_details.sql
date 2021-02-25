CREATE TABLE #logsize (
	Dbname SYSNAME
	,Log_File_Size_MB DECIMAL(38, 2) DEFAULT(0)
	,log_Space_Used_MB DECIMAL(30, 2) DEFAULT(0)
	,log_Free_Space_MB DECIMAL(30, 2) DEFAULT(0)
	)
GO

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
from sys.database_files  where type=1 group by type'

SELECT @@SERVERNAME [Server],*
	,Cast((log_Free_Space_MB / Log_File_Size_MB) * 100 AS DECIMAL(10, 2)) [%Free]
FROM #logsize

DROP TABLE #logsize
