CREATE EVENT SESSION [what_queries_are_failing] ON SERVER ADD EVENT sqlserver.error_reported (
	ACTION(sqlserver.client_app_name, sqlserver.client_hostname, sqlserver.database_id, sqlserver.nt_username, sqlserver.session_nt_username, sqlserver.sql_text, sqlserver.tsql_stack, sqlserver.username) WHERE (
		[package0].[greater_than_int64]([severity], (10))
		AND [error_number] <> (17830)
		)
	) ADD TARGET package0.event_file (
	SET filename = N'what_queries_are_failing.xel'
	,max_file_size = (5)
	,max_rollover_files = (5)
	,metadatafile = N'what_queries_are_failing.xem'
	)
	WITH (
			MAX_MEMORY = 4096 KB
			,EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS
			,MAX_DISPATCH_LATENCY = 5 SECONDS
			,MAX_EVENT_SIZE = 0 KB
			,MEMORY_PARTITION_MODE = NONE
			,TRACK_CAUSALITY = OFF
			,STARTUP_STATE = OFF
			)
GO
