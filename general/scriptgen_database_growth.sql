DECLARE @DBNAME VARCHAR(256);
DECLARE @FileName VARCHAR(256);
DECLARE @size_kb int;

DECLARE db_cursor CURSOR FOR 
select  DB_NAME(database_id)  DBNAME, name [file_name] , (cast(size as float)*8) size_kb from sys.master_files
where type_desc='ROWS'

OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @DBNAME, @FileName, @size_kb

WHILE @@FETCH_STATUS = 0  
BEGIN  

DECLARE @cnt INT = 1;
DECLARE @cnt_total INT = 15;
DECLARE @inc_vale INT = (SELECT 2 * 1024 * 1024)

WHILE (@cnt <= @cnt_total)
BEGIN

	SET @size_kb = @size_kb +  @inc_vale
	PRINT 'ALTER DATABASE ['+@DBNAME+'] MODIFY FILE ( NAME = N'''+@FileName+''', SIZE = '+cast(@size_kb as varchar(256))+'KB )'
	SET @cnt = @cnt + 1

END

FETCH NEXT FROM db_cursor INTO @DBNAME, @FileName, @size_kb
END

CLOSE db_cursor
DEALLOCATE db_cursor
