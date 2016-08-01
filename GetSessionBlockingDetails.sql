SELECT Sess.Session_id
       ,Req.blocking_session_id
       ,CASE WHEN (Req2.session_id IS NOT NULL AND (sess.session_id IS NULL 
	           OR Req.blocking_session_id=0 or req.blocking_session_id is null)) THEN 1 
		  ELSE 0 
		  END [IsHeadBlocker]
       ,tasks.scheduler_id [CPU_ID]
       ,Sess.login_time
       ,Sess.login_name
       ,Sess.host_name
       ,Sess.program_name
       ,Req.request_id
       ,Req.status [Request_Session]
       ,DB_Name(Req.database_id) [DBName]
       ,Req.command
       ,Req.wait_type [Req_wait_type]
       ,Req.Wait_time [Req_Wait_time]
       ,Req.wait_resource [Req_wait_Resource]
       ,Req.total_elapsed_time/(1000*60) [Request_time_Total(Mins)]
       ,CASE Req.transaction_isolation_level	
             WHEN 0 THEN 'Unspecified'
             WHEN 1 THEN 'ReadUncomitted'
             WHEN 2 THEN 'ReadCommitted'
             WHEN 3 THEN 'Repeatable'
             WHEN 4 THEN 'Serializable'
             WHEN 5 THEN 'Snapshot'
             ELSE 'UNKNOWN' 
		  END [transaction_isolation_level]
       ,DB_NAME(Txt.dbid)+'..'+OBJECT_NAME(Txt.objectid,Txt.dbid) [Running_ObjectName]
       ,REPLACE(REPLACE(REPLACE(REPLACE(LEFT(Txt.Text,500),char(13)+char(10),'  '),char(10),' '),CHAR(13),' '),CHAR(9),' ') [Full_Text]
       ,REPLACE(REPLACE(REPLACE(REPLACE(LEFT(SUBSTRING(Txt.text,
       								(Req.statement_start_offset/2)+1 , 
       								(((CASE WHEN Req.statement_end_offset = -1 THEN (LEN(CONVERT(nvarchar(max),Txt.text)) * 2) 
       								ELSE Req.statement_end_offset END)  - Req.statement_start_offset)/2)+1)
       					,500),char(13)+char(10),'  '),char(10),' '),CHAR(13),' '),CHAR(9),' ') [Running_Text]
  FROM sys.dm_exec_requests Req
       JOIN sys.dm_exec_sessions Sess on (Req.session_id=Sess.session_id)
       JOIN sys.dm_os_tasks tasks on (req.session_id=tasks.session_id)
       JOIN sys.dm_exec_connections Conn on (Sess.session_id=Conn.session_id)
       LEFT JOIN sys.dm_exec_requests Req2 on (Sess.session_id=Req2.blocking_session_id)
       OUTER APPLY sys.dm_exec_sql_text(Conn.most_recent_sql_handle) Txt
 WHERE Sess.session_id > 50;