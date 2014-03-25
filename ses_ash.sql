prompt obs: solicitar um range pequeno devido ao detalhamento
prompt 
prompt
col program for a50
col module for a50
col action for a50
col client_id for a50
col wait_class for a100
col event for a100
col username for a50
Accept dt1  prompt 'Begin (dd/mm/yyyy hh24:mi:ss):'
Accept dt2  prompt 'End   (dd/mm/yyyy hh24:mi:ss):'


select 
	s.sample_time, s.session_id, u.username, s.sql_id ,s.SQL_PLAN_HASH_VALUE, 
	s.session_state, sv.name, s.session_type, s.blocking_session, 
	s.blocking_session_status, s.event, s.event#, s.p1text, s.p2text, s.p3text, 
	s.wait_class, s.wait_time, s.time_waited, s.program, s.module, s.action, s.client_id
from v$active_session_history s
	left  join dba_users u
		on u.user_id = s.user_id
	left  join V$ACTIVE_SERVICES sv
		on sv.NAME_HASH = s.service_hash
where s.sample_time between to_date('01/10/2012 00:00:00', 'dd/mm/yyyy hh24:mi:ss') and to_date('01/10/2012 10:00:00', 'dd/mm/yyyy hh24:mi:ss')
order by s.sample_time
/



clear breaks