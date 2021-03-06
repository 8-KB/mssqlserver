DECLARE @name VARCHAR(max)

DECLARE db_cursor CURSOR
FOR
SELECT msdb.dbo.backupmediafamily.physical_device_name
FROM msdb.dbo.backupmediafamily
INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id
WHERE (CONVERT(DATETIME, msdb.dbo.backupset.backup_start_date, 102) >= GETDATE() - 1)
	AND msdb..backupset.type = 'L'
	
OPEN db_cursor

FETCH NEXT
FROM db_cursor
INTO @name

WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT [Transaction SID], *
	FROM fn_dump_dblog(NULL, NULL, N'DISK', 1, @name, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
	--WHERE Operation LIKE 'LOP_DELETE%'

	FETCH NEXT
	FROM db_cursor
	INTO @name
END

CLOSE db_cursor

DEALLOCATE db_cursor
