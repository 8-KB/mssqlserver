DECLARE @NewDataFileGrowth varchar(100) = '1024MB'
DECLARE @NewLogGrowth varchar(100) = '512MB'

select 
  CASE WHEN physical_name like '%.ldf'
    THEN 'ALTER DATABASE [' + DB_NAME(mf.database_id) + '] MODIFY FILE (NAME = [' + mf.name + '], FILEGROWTH = ' + @NewLogGrowth + ');'
    ELSE 'ALTER DATABASE [' + DB_NAME(mf.database_id) + '] MODIFY FILE (NAME = [' + mf.name + '], FILEGROWTH = ' + @NewDataFileGrowth + ');'
  END as ChangeAutoGrowSettings, 
  DB_NAME(mf.database_id) database_name, 
  mf.name logical_name, 
  CONVERT (
    DECIMAL (20, 2), 
    (
      CONVERT(DECIMAL, size)/ 128
    )
  ) [file_size_MB], 
  CASE mf.is_percent_growth WHEN 1 THEN 'Yes' ELSE 'No' END AS [is_percent_growth], 
  CASE mf.is_percent_growth WHEN 1
	THEN CONVERT(VARCHAR, mf.growth) + '%'
	WHEN 0 THEN CONVERT(VARCHAR, mf.growth / 128) + ' MB'
	END AS [growth_in_increment_of], 
  CASE mf.is_percent_growth WHEN 1
  THEN CONVERT(DECIMAL(20, 2), 
    ( ( ( CONVERT(DECIMAL, size)* growth )/ 100 )* 8 )/ 1024 )
	WHEN 0
		THEN CONVERT( DECIMAL(20, 2), ( CONVERT(DECIMAL, growth)/ 128 ) )
	END AS [next_auto_growth_size_MB], 
  CASE mf.max_size
	WHEN 0 THEN 'No growth is allowed'
	WHEN 1 THEN 'File will grow until the disk is full'
	ELSE CONVERT(VARCHAR, mf.max_size) END AS [max_size], 
  physical_name 
from 
  sys.master_files mf 
where 
  CASE mf.is_percent_growth
  WHEN 1 THEN CONVERT(VARCHAR, mf.growth) + '%'
  WHEN 0 THEN CONVERT(VARCHAR, mf.growth / 128) + ' MB'
  END IN ('10%', '1 MB')
