SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

EXEC master.dbo.sp_WhoIsActive @get_outer_command = 1
       --,@get_plans = 1
       --,@get_full_inner_text = 1
       --,@get_transaction_info = 1
       --,@get_locks = 1
       --,@get_task_info = 2
       --,@get_additional_info = 1
       ,@show_sleeping_spids = 1
       ,@find_block_leaders = 1
       --,@get_avg_time = 1
       --,@delta_interval = 2
      -- ,@filter_type='host'
      -- ,@filter='XX'
       ,@output_column_list = 
       '[session_id][start_time][dd hh:mm:ss.mss][cpu][status][open_tran_count][blocking_session_id][blocked_session_count][%delta][wait_info]
      [database_name][host_name][login_name][program_name][sql_text][sql_command][query_plan][locks][tempdb%]
       [reads][writes][physical_reads][used_memory][percent_complete][request_id][login_time][tran_start_time][collection_time]'
       --,@sort_order = '[start_time] ASC'
       ,@sort_order = '[cpu] DESC'
       --,@sort_order = '[blocked_session_count] DESC'
GO
