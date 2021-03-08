IF OBJECT_ID('tempdb..#dbachecksLastRunTime') IS NOT NULL
	DROP TABLE #dbachecksLastRunTime

DECLARE @MAXDAYS int =5;

SELECT *
INTO #dbachecksLastRunTime
FROM (
	SELECT j.job_id
		,j.name AS JobName
		,DATEDIFF(SECOND, 0, STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(6), jh.run_duration), 6), 5, 0, ':'), 3, 0, ':')) AS Duration
	FROM msdb.dbo.sysjobs j
	INNER JOIN (
		SELECT job_id
			,instance_id = MAX(instance_id)
		FROM msdb.dbo.sysjobhistory
		GROUP BY job_id
		) AS h ON j.job_id = h.job_id
	INNER JOIN msdb.dbo.sysjobhistory AS jh ON jh.job_id = h.job_id
		AND jh.instance_id = h.instance_id
	WHERE msdb.dbo.agent_datetime(jh.run_date, jh.run_time) > DATEADD(DAY, - @MAXDAYS, GETDATE())
		AND jh.step_id = 0
	) AS lrt

IF OBJECT_ID('tempdb..#dbachecksAverageRunTime') IS NOT NULL
	DROP TABLE #dbachecksAverageRunTime

SELECT *
INTO #dbachecksAverageRunTime
FROM (
	SELECT job_id
		,AVG(DATEDIFF(SECOND, 0, STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(6), run_duration), 6), 5, 0, ':'), 3, 0, ':'))) AS AvgSec
	FROM msdb.dbo.sysjobhistory hist
	WHERE msdb.dbo.agent_datetime(run_date, run_time) > DATEADD(DAY, - @MAXDAYS, GETDATE())
		AND Step_id = 0
	GROUP BY job_id
	) AS art

SELECT JobName
	,Duration
	,AvgSec
	,Duration - AvgSec AS Diff
FROM #dbachecksLastRunTime lastrun
JOIN #dbachecksAverageRunTime avgrun ON lastrun.job_id = avgrun.job_id

DROP TABLE #dbachecksLastRunTime

DROP TABLE #dbachecksAverageRunTime
