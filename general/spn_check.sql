DECLARE @accntsqlservice NVARCHAR(128)

SELECT service_account
FROM sys.dm_server_services
WHERE servicename LIKE 'SQL Server%'
	AND servicename NOT LIKE 'SQL Server Agent%'

DECLARE @CMD NVARCHAR(4000)
	,@line INT
	,@linemax INT
	,@SPN VARCHAR(8000)
	,@SPNMachine VARCHAR(8000)

IF EXISTS (
		SELECT [object_id]
		FROM tempdb.sys.objects(NOLOCK)
		WHERE [object_id] = OBJECT_ID('tempdb.dbo.#xp_cmdshell_AcctSPNoutput')
		)
	DROP TABLE #xp_cmdshell_AcctSPNoutput;

IF NOT EXISTS (
		SELECT [object_id]
		FROM tempdb.sys.objects(NOLOCK)
		WHERE [object_id] = OBJECT_ID('tempdb.dbo.#xp_cmdshell_AcctSPNoutput')
		)
	CREATE TABLE #xp_cmdshell_AcctSPNoutput (
		line INT IDENTITY(1, 1) PRIMARY KEY
		,[Output] VARCHAR(8000)
		);

IF EXISTS (
		SELECT [object_id]
		FROM tempdb.sys.objects(NOLOCK)
		WHERE [object_id] = OBJECT_ID('tempdb.dbo.#xp_cmdshell_DupSPNoutput')
		)
	DROP TABLE #xp_cmdshell_DupSPNoutput;

IF NOT EXISTS (
		SELECT [object_id]
		FROM tempdb.sys.objects(NOLOCK)
		WHERE [object_id] = OBJECT_ID('tempdb.dbo.#xp_cmdshell_DupSPNoutput')
		)
	CREATE TABLE #xp_cmdshell_DupSPNoutput (
		line INT IDENTITY(1, 1) PRIMARY KEY
		,[Output] VARCHAR(8000)
		);

IF EXISTS (
		SELECT [object_id]
		FROM tempdb.sys.objects(NOLOCK)
		WHERE [object_id] = OBJECT_ID('tempdb.dbo.#FinalDupSPN')
		)
	DROP TABLE #FinalDupSPN;

IF NOT EXISTS (
		SELECT [object_id]
		FROM tempdb.sys.objects(NOLOCK)
		WHERE [object_id] = OBJECT_ID('tempdb.dbo.#FinalDupSPN')
		)
	CREATE TABLE #FinalDupSPN (
		[SPN] VARCHAR(8000)
		,[Accounts] VARCHAR(8000)
		);

IF EXISTS (
		SELECT [object_id]
		FROM tempdb.sys.objects(NOLOCK)
		WHERE [object_id] = OBJECT_ID('tempdb.dbo.#ScopedDupSPN')
		)
	DROP TABLE #ScopedDupSPN;

IF NOT EXISTS (
		SELECT [object_id]
		FROM tempdb.sys.objects(NOLOCK)
		WHERE [object_id] = OBJECT_ID('tempdb.dbo.#ScopedDupSPN')
		)
	CREATE TABLE #ScopedDupSPN (
		[SPN] VARCHAR(8000)
		,[Accounts] VARCHAR(8000)
		);

SELECT @CMD = N'SETSPN -P -L ' + @accntsqlservice

INSERT INTO #xp_cmdshell_AcctSPNoutput ([Output])
EXEC master.dbo.xp_cmdshell @CMD;

SET @CMD = N'SETSPN -P -X'

INSERT INTO #xp_cmdshell_DupSPNoutput ([Output])
EXEC master.dbo.xp_cmdshell @CMD;

SELECT @SPNMachine = '%MSSQLSvc/' + CONVERT(NVARCHAR(100), SERVERPROPERTY('MachineName')) + '%';

IF EXISTS (
		SELECT TOP 1 b.line
		FROM #xp_cmdshell_AcctSPNoutput a
		INNER JOIN #xp_cmdshell_DupSPNoutput b ON REPLACE(UPPER(a.[Output]), CHAR(9), '') = LEFT(REPLACE(UPPER(b.[Output]), CHAR(9), ''), LEN(REPLACE(UPPER(a.[Output]), ' ', '')))
		)
BEGIN
	DECLARE curSPN CURSOR FAST_FORWARD
	FOR
	SELECT b.line
		,REPLACE(a.[Output], CHAR(9), '')
	FROM #xp_cmdshell_AcctSPNoutput a
	INNER JOIN #xp_cmdshell_DupSPNoutput b ON REPLACE(UPPER(a.[Output]), CHAR(9), '') = LEFT(REPLACE(UPPER(b.[Output]), CHAR(9), ''), LEN(REPLACE(UPPER(a.[Output]), ' ', '')))
	WHERE a.[Output] LIKE '%MSSQLSvc%'

	OPEN curSPN

	FETCH NEXT
	FROM curSPN
	INTO @line
		,@SPN

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT TOP 1 @linemax = line
		FROM #xp_cmdshell_DupSPNoutput
		WHERE line > @line
			AND [Output] IS NULL;

		INSERT INTO #FinalDupSPN
		SELECT QUOTENAME(@SPN)
			,QUOTENAME(REPLACE([Output], CHAR(9), ''))
		FROM #xp_cmdshell_DupSPNoutput
		WHERE line > @line
			AND line < @linemax;

		IF EXISTS (
				SELECT [Output]
				FROM #xp_cmdshell_DupSPNoutput
				WHERE line = @line
					AND [Output] LIKE @SPNMachine
				)
		BEGIN
			INSERT INTO #ScopedDupSPN
			SELECT QUOTENAME(@SPN)
				,QUOTENAME(REPLACE([Output], CHAR(9), ''))
			FROM #xp_cmdshell_DupSPNoutput
			WHERE line > @line
				AND line < @linemax;
		END

		FETCH NEXT
		FROM curSPN
		INTO @line
			,@SPN
	END

	CLOSE curSPN

	DEALLOCATE curSPN
END

IF EXISTS (
		SELECT TOP 1 [Output]
		FROM #xp_cmdshell_AcctSPNoutput
		WHERE [Output] LIKE '%MSSQLSvc%'
		)
BEGIN
	IF EXISTS (
			SELECT [Output]
			FROM #xp_cmdshell_AcctSPNoutput
			WHERE [Output] LIKE '%MSSQLSvc%'
				AND [Output] LIKE @SPNMachine
			)
	BEGIN
		SELECT 'Service_Account_checks' AS [Category]
			,'MSSQLSvc_SPNs_SvcAcct_CurrServer' AS [Check]
			,'[OK]' AS [Deviation]
			,QUOTENAME(REPLACE([Output], CHAR(9), '')) AS SPN
		FROM #xp_cmdshell_AcctSPNoutput
		WHERE [Output] LIKE @SPNMachine
	END
	ELSE
	BEGIN
		SELECT 'Service_Account_checks' AS [Category]
			,'MSSQLSvc_SPNs_SvcAcct_CurrServer' AS [Check]
			,'[WARNING: There is no registered MSSQLSvc SPN for the current service account in the scoped server name, preventing the use of Kerberos authentication]' AS [Deviation];
	END

	IF EXISTS (
			SELECT [Output]
			FROM #xp_cmdshell_AcctSPNoutput
			WHERE [Output] LIKE '%MSSQLSvc%'
				AND [Output] NOT LIKE @SPNMachine
			)
	BEGIN
		SELECT 'Service_Account_checks' AS [Category]
			,'MSSQLSvc_SPNs_SvcAcct' AS [Check]
			,'[INFORMATION: There are other MSSQLSvc SPNs registered for the current service account]' AS [Deviation]
			,QUOTENAME(REPLACE([Output], CHAR(9), '')) AS SPN
		FROM #xp_cmdshell_AcctSPNoutput
		WHERE [Output] LIKE '%MSSQLSvc%'
			AND [Output] NOT LIKE @SPNMachine
	END
END
ELSE
BEGIN
	SELECT 'Service_Account_checks' AS [Category]
		,'MSSQLSvc_SPNs_SvcAcct' AS [Check]
		,'[WARNING: There is no registered MSSQLSvc SPN for the current service account, preventing the use of Kerberos authentication]' AS [Deviation];
END

IF (
		SELECT COUNT(*)
		FROM #ScopedDupSPN
		) > 0
BEGIN
	SELECT 'Service_Account_checks' AS [Category]
		,'Dup_MSSQLSvc_SPNs_Acct_CurrServer' AS [Check]
		,'[WARNING: There are duplicate registered MSSQLSvc SPNs in the domain, for the SPN in the scoped server name]' AS [Deviation]
		,REPLACE([SPN], CHAR(9), '')
		,[Accounts] AS [Information]
	FROM #ScopedDupSPN
END
ELSE
BEGIN
	SELECT 'Service_Account_checks' AS [Category]
		,'Dup_MSSQLSvc_SPNs_Acct_CurrServer' AS [Check]
		,'[OK]' AS [Deviation];
END

IF (
		SELECT COUNT(*)
		FROM #FinalDupSPN
		) > 0
BEGIN
	SELECT 'Service_Account_checks' AS [Category]
		,'Dup_MSSQLSvc_SPNs_Acct' AS [Check]
		,'[WARNING: There are duplicate registered MSSQLSvc SPNs in the domain]' AS [Deviation]
		,[SPN]
		,[Accounts]
	FROM #FinalDupSPN
END
ELSE
BEGIN
	SELECT 'Service_Account_checks' AS [Category]
		,'Dup_MSSQLSvc_SPNs_Acct' AS [Check]
		,'[OK]' AS [Deviation];
END
