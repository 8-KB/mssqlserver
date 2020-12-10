DECLARE @SQLCMD VARCHAR(100);
DECLARE @DBName VARCHAR(100);
DECLARE @Message VARCHAR(100);

DECLARE DM_Suspended CURSOR
FOR
SELECT DB_NAME(database_id), 'ALTER DATABASE [' + DB_NAME(database_id) + '] SET HADR RESUME;'
FROM sys.dm_hadr_database_replica_states drs
JOIN sys.availability_replicas ar ON ar.replica_id = drs.replica_id
WHERE ar.replica_server_name = @@SERVERNAME
AND drs.is_suspended = 1;

OPEN DM_Suspended;

FETCH NEXT
FROM DM_Suspended
INTO @DBName , @SQLCMD;

WHILE @@FETCH_STATUS = 0
BEGIN
	
	
	BEGIN TRY

	EXECUTE (@SQLCMD);

	END TRY 
	BEGIN CATCH
	
	SET @Message ='|- Resume Data Movement Failed for DB '+@DBName
	RAISERROR ( @Message,16, 1) WITH LOG
	
	END CATCH 

	SET @Message ='|- Resume Data Movement Successful for DB '+@DBName
	RAISERROR ( @Message,10, 1) WITH LOG

	FETCH NEXT
	FROM DM_Suspended
	INTO @DBName , @SQLCMD;
END;

CLOSE DM_Suspended;

DEALLOCATE DM_Suspended;
