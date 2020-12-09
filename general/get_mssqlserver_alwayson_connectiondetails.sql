WITH AG
AS (
	SELECT es.login_name
		,es.program_name
		,db_name(es.database_id) [db_name]
		,ec.client_net_address
		,ec.client_tcp_port
		,agl.dns_name
		,aglip.ip_address
		,agl.port
		,ec.encrypt_option
	FROM sys.availability_group_listeners agl
	INNER JOIN sys.availability_group_listener_ip_addresses aglip ON agl.listener_id = aglip.listener_id
	INNER JOIN sys.dm_exec_connections ec ON ec.local_net_address = aglip.ip_address
	INNER JOIN sys.dm_exec_sessions es ON ec.session_id = es.session_id
	
	UNION ALL
	
	SELECT es.login_name
		,es.program_name
		,db_name(es.database_id) [db_name]
		,ec.client_net_address
		,ec.client_tcp_port
		,@@SERVERNAME AS [dns_name]
		,sr.value_data AS [ip_Address]
		,ec.local_tcp_port AS [port]
		,ec.encrypt_option
	FROM sys.dm_server_registry sr
	INNER JOIN sys.dm_exec_connections ec ON sr.value_name = 'IpAddress'
		AND ec.local_net_address = sr.value_data
	INNER JOIN sys.dm_exec_sessions es ON ec.session_id = es.session_id
	)
SELECT *
FROM AG

-----------------------------------------------------------------------------------------------------------

DECLARE @StaticportNo NVARCHAR(10);

EXEC xp_instance_regread @rootkey = 'HKEY_LOCAL_MACHINE'
	,@key = 'Software\Microsoft\Microsoft SQL Server\MSSQLServer\SuperSocketNetLib\Tcp\IpAll'
	,@value_name = 'TcpPort'
	,@value = @StaticportNo OUTPUT

SELECT es.login_name
	,es.program_name
	,db_name(es.database_id) [db_name]
	,ec.net_transport
	,ec.client_net_address
	,ec.local_net_address
	,ec.client_tcp_port
	,ISNULL(agl.dns_name, @@Servername) dns_name
	,CASE 
		WHEN net_transport ! = 'Shared Memory'
			THEN ISNULL(aglip.ip_address, ec.local_net_address)
		END ip_address
	,ISNULL(agl.port, @StaticportNo) port
	,ec.encrypt_option
	,ec.auth_scheme
FROM sys.dm_exec_connections ec
LEFT JOIN sys.dm_exec_sessions es ON ec.session_id = es.session_id
LEFT JOIN sys.availability_group_listener_ip_addresses aglip ON ec.local_net_address = aglip.ip_address
LEFT JOIN sys.availability_group_listeners agl ON agl.listener_id = aglip.listener_id
