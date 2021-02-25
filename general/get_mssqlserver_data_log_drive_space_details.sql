SELECT DISTINCT DB_NAME(dovs.database_id) DBName
	,type_desc
	,mf.physical_name PhysicalFileLocation
	,dovs.logical_volume_name AS LogicalName
	,dovs.volume_mount_point AS Drive
	,CONVERT(INT, dovs.total_bytes / 1048576.0) / 1024 AS AvilableSpaceInGB
	,CONVERT(INT, dovs.available_bytes / 1048576.0) / 1024 AS FreeSpaceInGB
	,CAST((CONVERT(FLOAT, dovs.available_bytes / 1048576.0) / 1024) / (CONVERT(FLOAT, dovs.total_bytes / 1048576.0) / 1024) * 100 AS DECIMAL(10, 2)) AS [%_Free]
FROM sys.master_files mf
CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.FILE_ID) dovs
--WHERE type_desc = 'LOG'
ORDER BY FreeSpaceInGB DESC
GO


