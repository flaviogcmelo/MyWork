select count(*) as sessions, s.host_name, s.host_process_id, s.program_name, db_name(s.database_id)as database_name 
  from sys.dm_exec_sessions s where is_user_process=1
 group by host_name,host_process_id,program_name,database_id 
 order by count(*)desc;


declare @host_process_id int=1508;
declare @host_name sysname=N'SERV4102';
declare @database_name sysname=N'My_Database';

select datediff(minute,s.last_request_end_time,getdate())as minutes_asleep,s.session_id,db_name(s.database_id)as database_name,s.host_name,s.host_process_id,t.text as last_sql,s.program_name 
from sys.dm_exec_connections c 
JOIN sys.dm_exec_sessions s on c.session_id=s.session_id 
CROSS APPLY sys.dm_exec_sql_text(c.most_recent_sql_handle)t 
where s.is_user_process=1 
  and s.status='sleeping' 
  and db_name(s.database_id)=@database_name
  and s.host_process_id=@host_process_id 
  and s.host_name=@host_name 
  and datediff(second,s.last_request_end_time,getdate())>60order by s.last_request_end_time;
