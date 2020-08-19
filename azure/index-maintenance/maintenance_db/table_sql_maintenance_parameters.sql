IF NOT EXISTS (SELECT  schema_name FROM    information_schema.schemata WHERE   schema_name = 'sqldba' ) 
BEGIN
	EXEC dbo.sp_executesql @command= N'CREATE SCHEMA [sqldba]'
END

CREATE TABLE [sqldba].[sql_maintenance_parameters] (
	[ID] [int] IDENTITY(1,1) NOT NULL
	,customer NVARCHAR(max) NOT NULL
	,Server_Name NVARCHAR(max) NOT NULL
	,Databases NVARCHAR(max) NOT NULL
	,FragmentationLow NVARCHAR(max) DEFAULT NULL
	,FragmentationMedium NVARCHAR(max) DEFAULT 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'
	,FragmentationHigh NVARCHAR(max) DEFAULT 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'
	,FragmentationLevel1 INT DEFAULT 5
	,FragmentationLevel2 INT DEFAULT 30
	,MinNumberOfPages INT DEFAULT 1000
	,MaxNumberOfPages INT DEFAULT NULL
	,SortInTempdb NVARCHAR(max) DEFAULT 'N'
	,Max_DOP INT DEFAULT NULL
	,Fill_Factor INT DEFAULT NULL
	,PadIndex NVARCHAR(max) DEFAULT NULL
	,LOBCompaction NVARCHAR(max) DEFAULT 'Y'
	,UpdateStatistics NVARCHAR(max) DEFAULT 'ALL'
	,OnlyModifiedStatistics NVARCHAR(max) DEFAULT 'N'
	,StatisticsModificationLevel INT DEFAULT NULL
	,StatisticsSample INT DEFAULT 100
	,StatisticsResample NVARCHAR(max) DEFAULT 'N'
	,PartitionLevel NVARCHAR(max) DEFAULT 'Y'
	,MSShippedObjects NVARCHAR(max) DEFAULT 'N'
	,Indexes NVARCHAR(max) DEFAULT NULL
	,TimeLimit INT DEFAULT NULL
	,DELAY INT DEFAULT NULL
	,WaitAtLowPriorityMaxDuration INT DEFAULT NULL
	,WaitAtLowPriorityAbortAfterWait NVARCHAR(max) DEFAULT NULL
	,Resumable NVARCHAR(max) DEFAULT 'N'
	,AvailabilityGroups NVARCHAR(max) DEFAULT NULL
	,LockTimeout INT DEFAULT NULL
	,LockMessageSeverity INT DEFAULT 16
	,StringDelimiter NVARCHAR(max) DEFAULT ','
	,DatabaseOrder NVARCHAR(max) DEFAULT NULL
	,DatabasesInParallel NVARCHAR(max) DEFAULT 'N'
	,CommandLogCleanup INT DEFAULT 14
	,LogToTable NVARCHAR(max) DEFAULT 'Y'
	,Created datetime DEFAULT getdate()
	,Comments NVARCHAR(max) NULL
	)
/*

INSERT INTO [sqldba].[sql_maintenance_parameters] (
	[Server_Name]
	,[Databases]
	)
VALUES (
	'sqldba.database.windows.net'
	,'dbatools'
	)
GO

*/
