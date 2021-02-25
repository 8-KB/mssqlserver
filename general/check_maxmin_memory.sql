DECLARE @maxservermem bigint, @minservermem bigint, @systemmem bigint, @systemfreemem bigint, @numa_nodes_afinned tinyint, @LowMemoryThreshold int
DECLARE @mwthreads_count int, @xtp int , @numa int
DECLARE @SystemManufacturer VARCHAR(128) , @ostype VARCHAR(128)
DECLARE @clustered bit
DECLARE @machineinfo TABLE ([Value] NVARCHAR(256), [Data] NVARCHAR(256))

BEGIN
	INSERT INTO @machineinfo
	EXEC xp_instance_regread 'HKEY_LOCAL_MACHINE','HARDWARE\DESCRIPTION\System\BIOS','SystemManufacturer';
	INSERT INTO @machineinfo
	EXEC xp_instance_regread 'HKEY_LOCAL_MACHINE','HARDWARE\DESCRIPTION\System\BIOS','SystemProductName';
	INSERT INTO @machineinfo
	EXEC xp_instance_regread 'HKEY_LOCAL_MACHINE','HARDWARE\DESCRIPTION\System\BIOS','SystemFamily';
	INSERT INTO @machineinfo
	EXEC xp_instance_regread 'HKEY_LOCAL_MACHINE','HARDWARE\DESCRIPTION\System\BIOS','BIOSVendor';
	INSERT INTO @machineinfo
	EXEC xp_instance_regread 'HKEY_LOCAL_MACHINE','HARDWARE\DESCRIPTION\System\BIOS','BIOSVersion';
	INSERT INTO @machineinfo
	EXEC xp_instance_regread 'HKEY_LOCAL_MACHINE','HARDWARE\DESCRIPTION\System\BIOS','BIOSReleaseDate';
	INSERT INTO @machineinfo
	EXEC xp_instance_regread 'HKEY_LOCAL_MACHINE','HARDWARE\DESCRIPTION\System\CentralProcessor\0','ProcessorNameString';
END;

SELECT @clustered = CONVERT(bit,ISNULL(SERVERPROPERTY('IsClustered'),0));
SELECT @minservermem = CONVERT(int, [value]) FROM sys.configurations (NOLOCK) WHERE [Name] = 'min server memory (MB)';
SELECT @maxservermem = CONVERT(int, [value]) FROM sys.configurations (NOLOCK) WHERE [Name] = 'max server memory (MB)';
SELECT @mwthreads_count = max_workers_count FROM sys.dm_os_sys_info;
SELECT @numa_nodes_afinned = COUNT (DISTINCT parent_node_id) FROM sys.dm_os_schedulers WHERE scheduler_id < 255 AND parent_node_id < 64 AND is_online = 1
SELECT @SystemManufacturer = [Data] FROM @machineinfo WHERE [Value] = 'SystemManufacturer';
SELECT @numa = COUNT(DISTINCT parent_node_id) FROM sys.dm_os_schedulers WHERE scheduler_id < 255 AND parent_node_id < 64;
SELECT 'Memory_checks' AS [Category], 'Memory_issues_MaxServerMem' AS [Check],
	CASE WHEN @maxservermem = 2147483647 THEN '[WARNING: MaxMem setting is default. Please revise memory settings]'
		WHEN @maxservermem > @systemmem THEN '[WARNING: MaxMem setting exceeds available system memory]'
		WHEN SERVERPROPERTY('EditionID') IN (284895786, 1293598313) AND @maxservermem > 67108864 THEN '[WARNING: MaxMem setting exceeds Web and Business Intelligence Edition limits]'
		WHEN SERVERPROPERTY('EditionID') = -1534726760 AND @maxservermem > 134217728 THEN '[WARNING: MaxMem setting exceeds Standard Edition limits]'
		WHEN SERVERPROPERTY('EngineEdition') = 4 AND @maxservermem > 1443840 THEN '[WARNING: MaxMem setting exceeds Express Edition limits]'
		WHEN @numa > 1 AND (@maxservermem/@numa) * @numa_nodes_afinned > (@systemmem/@numa) * @numa_nodes_afinned THEN '[WARNING: Current MaxMem setting will leverage node foreign memory. 
Maximum value for MaxMem setting on this configuration is ' + CONVERT(NVARCHAR,(@systemmem/@numa) * @numa_nodes_afinned) + ' for a single instance]'
		ELSE '[OK]'
	END AS [Deviation], @maxservermem AS [sql_max_mem_MB];

	SELECT 'Memory_checks' AS [Category], 'Memory_issues_MinServerMem' AS [Check],
	CASE WHEN @minservermem = 0 AND (LOWER(@SystemManufacturer) = 'microsoft' OR LOWER(@SystemManufacturer) = 'vmware') THEN '[WARNING: Min Server Mem setting is not set in a VM, allowing memory pressure on the Host to attempt to deallocate memory on a guest SQL Server]'
		WHEN @minservermem = 0 AND @clustered = 1 THEN '[INFORMATION: Min Server Mem setting is default in a clustered instance. Leverage Min Server Mem for the purpose of limiting memory concurrency between instances]'
		WHEN @minservermem = @maxservermem THEN '[WARNING: Min Server Mem setting is equal to Max Server Mem. This will not allow dynamic memory. Please revise memory settings]'
		WHEN @numa > 1 AND (@minservermem/@numa) * @numa_nodes_afinned > (@systemmem/@numa) * @numa_nodes_afinned THEN '[WARNING: Current MinMem setting will leverage node foreign memory]'
		ELSE '[OK]'
	END AS [Deviation], @minservermem AS [sql_min_mem_MB];