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
	s.sample_time, u.username, count(1) ctd
from v$active_session_history s
	inner join dba_users u
		on u.user_id = s.user_id
	inner join V$ACTIVE_SERVICES sv
		on sv.NAME_HASH = s.service_hash
where s.sample_time between to_date('&dt1') and to_date('&dt2')
group by s.sample_time, u.username
order by 3 desc
/

select 
	s.sample_time, s.sql_id, count(1) ctd
from v$active_session_history s
	inner join dba_users u
		on u.user_id = s.user_id
	inner join V$ACTIVE_SERVICES sv
		on sv.NAME_HASH = s.service_hash
where s.sample_time between to_date('&dt1') and to_date('&dt2')
group by s.sample_time, s.sql_id
order by 3 desc
/


select 
	s.sample_time, s.SQL_PLAN_HASH_VALUE, count(1) ctd
from v$active_session_history s
	inner join dba_users u
		on u.user_id = s.user_id
	inner join V$ACTIVE_SERVICES sv
		on sv.NAME_HASH = s.service_hash
where s.sample_time between to_date('&dt1') and to_date('&dt2')
group by s.sample_time, s.SQL_PLAN_HASH_VALUE
order by 3 desc
/


select 
	s.sample_time, s.blocking_session, count(1) ctd
from v$active_session_history s
	inner join dba_users u
		on u.user_id = s.user_id
	inner join V$ACTIVE_SERVICES sv
		on sv.NAME_HASH = s.service_hash
where s.sample_time between to_date('&dt1') and to_date('&dt2')
group by s.sample_time, s.blocking_session
order by 3 desc
/


select 
	s.sample_time, s.event, s.wait_class, count(1) ctd
from v$active_session_history s
	inner join dba_users u
		on u.user_id = s.user_id
	inner join V$ACTIVE_SERVICES sv
		on sv.NAME_HASH = s.service_hash
where s.sample_time between to_date('&dt1') and to_date('&dt2')
group by s.sample_time, s.wait_class, s.event
order by 4 desc
/

select 
	s.sample_time, s.program, s.module, s.action, s.client_id, count(1) ctd
from v$active_session_history s
	inner join dba_users u
		on u.user_id = s.user_id
	inner join V$ACTIVE_SERVICES sv
		on sv.NAME_HASH = s.service_hash
where s.sample_time between to_date('&dt1') and to_date('&dt2')
group by s.program, s.module, s.action, s.client_id
order by 6 desc
/


undef dt1
undef dt2 

