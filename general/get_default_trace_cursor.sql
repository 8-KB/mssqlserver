DECLARE @name VARCHAR(500)

CREATE TABLE #DirTree (
	id INT IDENTITY(1, 1)
	,subdirectory NVARCHAR(512)
	,depth INT
	,isfile BIT
	);

CREATE TABLE #trace (
	[DatabaseName] [nvarchar](256) NULL
	,[TextData] [ntext] NULL
	,[Duration] [bigint] NULL
	,[StartTime] [datetime] NULL
	,[EndTime] [datetime] NULL
	,[SPID] [int] NULL
	,[ApplicationName] [nvarchar](256) NULL
	,[LoginName] [nvarchar](256) NULL
	);

DECLARE @path NVARCHAR(260)

SELECT @path = LEFT(path, Len(path) - Charindex('\', Reverse(path)))
FROM sys.traces
WHERE is_default = 1

INSERT #DirTree (
	subdirectory
	,depth
	,isfile
	)
EXEC master.sys.xp_dirtree @path
	,1
	,1;

DECLARE db_cursor CURSOR
FOR
SELECT @path + '\' + subdirectory
FROM #DirTree
WHERE [isfile] = 1
	AND subdirectory LIKE '%.trc'

OPEN db_cursor

FETCH NEXT
FROM db_cursor
INTO @name

WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO #trace
	SELECT DatabaseName
		,TextData
		,Duration
		,StartTime
		,EndTime
		,SPID
		,ApplicationName
		,LoginName
	FROM sys.fn_trace_gettable(@name, DEFAULT)
	WHERE EventClass IN (115) and EventSubClass=1
	ORDER BY StartTime DESC

	FETCH NEXT
	FROM db_cursor
	INTO @name
END

CLOSE db_cursor

DEALLOCATE db_cursor

SELECT *
FROM #trace

DROP TABLE #DirTree

DROP TABLE #trace
