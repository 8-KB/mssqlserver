DECLARE @outval VARCHAR(36);

IF @outval IS NULL /* If power plan was not set by group policy */
	EXEC master.sys.xp_regread @rootkey = 'HKEY_LOCAL_MACHINE'
		,@key = 'SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes'
		,@value_name = 'ActivePowerScheme'
		,@value = @outval OUTPUT;

DECLARE @cpu_speed_mhz INT
	,@cpu_speed_ghz DECIMAL(18, 2);

EXEC master.sys.xp_regread @rootkey = 'HKEY_LOCAL_MACHINE'
	,@key = 'HARDWARE\DESCRIPTION\System\CentralProcessor\0'
	,@value_name = '~MHz'
	,@value = @cpu_speed_mhz OUTPUT;

SELECT @cpu_speed_ghz = CAST(CAST(@cpu_speed_mhz AS DECIMAL) / 1000 AS DECIMAL(18, 2));

SELECT 'Server Info' AS FindingsGroup
	,'Power Plan' AS Finding
	,CAST(@cpu_speed_ghz AS VARCHAR(4)) + 'GHz CPUs' cup_speed
	,CASE @outval
		WHEN 'a1841308-3541-4fab-bc81-f71556f20b4a'
			THEN 'power saving mode'
		WHEN '381b4222-f694-41f0-9685-ff5bb260df2e'
			THEN 'balanced power mode'
		WHEN '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
			THEN 'high performance power mode'
		WHEN 'e9a42b02-d5df-448d-aa00-03f14749eb61'
			THEN 'ultimate performance power mode'
		ELSE 'an unknown power mode'
		END AS PowerPlan
    
/*
run from an elevated (run as admin) CMD or Powershell window.

powercfg /L
powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg /L

/L lists the existing and active power profiles.  That guid should be the one for High Performance

*/
