CREATE VIEW [sqldba].vw_sql_maintenance_parameters
AS 
WITH data_con as (
SELECT ISNULL(CAST([Server_Name] AS NVARCHAR(max)),'NULL') [Server_Name]
      ,ISNULL(CAST([Databases] AS NVARCHAR(max)),'NULL') [Databases]
      ,CASE WHEN ISNULL(CAST([FragmentationLow] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@FragmentationLow = NULL,' ELSE '@FragmentationLow = '''+FragmentationLow+''',' END [FragmentationLow]
      ,CASE WHEN ISNULL(CAST([FragmentationMedium] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@FragmentationMedium = NULL,' ELSE '@FragmentationMedium = '''+FragmentationMedium+''',' END [FragmentationMedium]
      ,CASE WHEN ISNULL(CAST([FragmentationHigh] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@FragmentationHigh = NULL,' ELSE '@FragmentationHigh = '''+FragmentationHigh+''',' END [FragmentationHigh]
      ,CASE WHEN ISNULL(CAST([FragmentationLevel1] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@FragmentationLevel1 = NULL,' ELSE '@FragmentationLevel1 = '''+CAST(FragmentationLevel1 AS NVARCHAR(max))+''',' END [FragmentationLevel1]
      ,CASE WHEN ISNULL(CAST([FragmentationLevel2] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@FragmentationLevel2 = NULL,' ELSE '@FragmentationLevel2 = '''+CAST(FragmentationLevel2 AS NVARCHAR(max))+''',' END [FragmentationLevel2]
      ,CASE WHEN ISNULL(CAST([MinNumberOfPages] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@MinNumberOfPages = NULL,' ELSE '@MinNumberOfPages = '''+CAST(MinNumberOfPages AS NVARCHAR(max))+''',' END [MinNumberOfPages]
      ,CASE WHEN ISNULL(CAST([MaxNumberOfPages] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@MaxNumberOfPages = NULL,' ELSE '@MaxNumberOfPages = '''+CAST(MaxNumberOfPages AS NVARCHAR(max))+''',' END [MaxNumberOfPages]
      ,CASE WHEN ISNULL(CAST([SortInTempdb] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@SortInTempdb = NULL,' ELSE '@SortInTempdb = '''+SortInTempdb+''',' END [SortInTempdb]
      ,CASE WHEN ISNULL(CAST([Max_DOP] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@Max_DOP = NULL,' ELSE '@Max_DOP = '''+CAST(Max_DOP AS NVARCHAR(max))+''',' END [Max_DOP]
      ,CASE WHEN ISNULL(CAST([Fill_Factor] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@Fill_Factor = NULL,' ELSE '@Fill_Factor = '''+CAST(Fill_Factor AS NVARCHAR(max))+''',' END [Fill_Factor]
      ,CASE WHEN ISNULL(CAST([PadIndex] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@PadIndex = NULL,' ELSE '@PadIndex = '''+PadIndex+''',' END [PadIndex]
      ,CASE WHEN ISNULL(CAST([LOBCompaction] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@LOBCompaction = NULL,' ELSE '@LOBCompaction = '''+LOBCompaction+''',' END [LOBCompaction]
      ,CASE WHEN ISNULL(CAST([UpdateStatistics] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@UpdateStatistics = NULL,' ELSE '@UpdateStatistics = '''+UpdateStatistics+''',' END [UpdateStatistics]
      ,CASE WHEN ISNULL(CAST([OnlyModifiedStatistics] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@OnlyModifiedStatistics = NULL,' ELSE '@OnlyModifiedStatistics = '''+OnlyModifiedStatistics+''',' END [OnlyModifiedStatistics]
      ,CASE WHEN ISNULL(CAST([StatisticsModificationLevel] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@StatisticsModificationLevel = NULL,' ELSE '@StatisticsModificationLevel = '''+CAST(StatisticsModificationLevel AS NVARCHAR(max))+''',' END [StatisticsModificationLevel]
      ,CASE WHEN ISNULL(CAST([StatisticsSample] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@StatisticsSample = NULL,' ELSE '@StatisticsSample = '''+CAST(StatisticsSample AS NVARCHAR(max))+''',' END [StatisticsSample]
      ,CASE WHEN ISNULL(CAST([StatisticsResample] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@StatisticsResample = NULL,' ELSE '@StatisticsResample = '''+StatisticsResample+''',' END [StatisticsResample]
      ,CASE WHEN ISNULL(CAST([PartitionLevel] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@PartitionLevel = NULL,' ELSE '@PartitionLevel = '''+PartitionLevel+''',' END [PartitionLevel]
      ,CASE WHEN ISNULL(CAST([MSShippedObjects] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@MSShippedObjects = NULL,' ELSE '@MSShippedObjects = '''+MSShippedObjects+''',' END [MSShippedObjects]
      ,CASE WHEN ISNULL(CAST([Indexes] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@Indexes = NULL,' ELSE '@Indexes = '''+Indexes+''',' END [Indexes]
      ,CASE WHEN ISNULL(CAST([TimeLimit] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@TimeLimit = NULL,' ELSE '@TimeLimit = '''+CAST(TimeLimit AS NVARCHAR(max))+''',' END [TimeLimit]
      ,CASE WHEN ISNULL(CAST([DELAY] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@DELAY = NULL,' ELSE '@DELAY = '''+CAST(DELAY AS NVARCHAR(max))+''',' END [DELAY]
      ,CASE WHEN ISNULL(CAST([WaitAtLowPriorityMaxDuration] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@WaitAtLowPriorityMaxDuration = NULL,' ELSE '@WaitAtLowPriorityMaxDuration = '''+CAST(WaitAtLowPriorityMaxDuration AS NVARCHAR(max))+''',' END [WaitAtLowPriorityMaxDuration]
      ,CASE WHEN ISNULL(CAST([WaitAtLowPriorityAbortAfterWait] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@WaitAtLowPriorityAbortAfterWait = NULL,' ELSE '@WaitAtLowPriorityAbortAfterWait = '''+WaitAtLowPriorityAbortAfterWait+''',' END [WaitAtLowPriorityAbortAfterWait]
      ,CASE WHEN ISNULL(CAST([Resumable] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@Resumable = NULL,' ELSE '@Resumable = '''+Resumable+''',' END [Resumable]
      ,CASE WHEN ISNULL(CAST([AvailabilityGroups] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@AvailabilityGroups = NULL,' ELSE '@AvailabilityGroups = '''+AvailabilityGroups+''',' END [AvailabilityGroups]
      ,CASE WHEN ISNULL(CAST([LockTimeout] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@LockTimeout = NULL,' ELSE '@LockTimeout = '''+CAST(LockTimeout AS NVARCHAR(max))+''',' END [LockTimeout]
      ,CASE WHEN ISNULL(CAST([LockMessageSeverity] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@LockMessageSeverity = NULL,' ELSE '@LockMessageSeverity = '''+CAST(LockMessageSeverity AS NVARCHAR(max))+''',' END [LockMessageSeverity]
      ,CASE WHEN ISNULL(CAST([StringDelimiter] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@StringDelimiter = NULL,' ELSE '@StringDelimiter = '''+StringDelimiter+''',' END [StringDelimiter]
      ,CASE WHEN ISNULL(CAST([DatabaseOrder] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@DatabaseOrder = NULL,' ELSE '@DatabaseOrder = '''+DatabaseOrder+''',' END [DatabaseOrder]
      ,CASE WHEN ISNULL(CAST([DatabasesInParallel] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@DatabasesInParallel = NULL,' ELSE '@DatabasesInParallel = '''+DatabasesInParallel+''',' END [DatabasesInParallel]
      ,CASE WHEN ISNULL(CAST([LogToTable] AS NVARCHAR(max)),'NULL') ='NULL' THEN '@LogToTable = NULL,' ELSE '@LogToTable = '''+LogToTable+'''' END [LogToTable]
  FROM sqldba.sql_maintenance_parameters
  )
SELECT	 Server_Name
		,Databases
		,'DECLARE @sql_db VARCHAR(max); SET @sql_db = ( SELECT DB_NAME(db_id())); EXECUTE [sqldba].[IndexOptimize]	@Databases = @sql_db,' + FragmentationLow + FragmentationMedium + FragmentationHigh + FragmentationLevel1 + FragmentationLevel2 + MinNumberOfPages + MaxNumberOfPages + SortInTempdb + Max_DOP + Fill_Factor + PadIndex + LOBCompaction + UpdateStatistics + OnlyModifiedStatistics + StatisticsModificationLevel + StatisticsSample + StatisticsResample + PartitionLevel + MSShippedObjects + Indexes + TimeLimit + DELAY + WaitAtLowPriorityMaxDuration + WaitAtLowPriorityAbortAfterWait + Resumable + AvailabilityGroups + LockTimeout + LockMessageSeverity + StringDelimiter + DatabaseOrder + DatabasesInParallel + LogToTable AS Script
FROM data_con
