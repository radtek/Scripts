break on sample_time skip 1
compute sum of ctd on sample_time

col WAIT_CLASS for a20
col event for a50
col username for a20
col program for a30
col sql_id for a20
col ctd for 9999999
col inicio for a28
col final for a28
col diff for a28

Accept dt1  prompt 'Begin (dd/mm/yyyy hh24:mi:ss):'
Accept dt2  prompt 'End   (dd/mm/yyyy hh24:mi:ss):'
define session_id=&session_id
define serial=&serial

select 
	sql_id, WAIT_CLASS, event, u.username, s.program, count(1) ctd
from DBA_HIST_ACTIVE_SESS_HISTORY s
	left join dba_users u
		on u.user_id = s.user_id
	left join V$ACTIVE_SERVICES sv
		on sv.NAME_HASH = s.service_hash
where s.sample_time between to_date('&dt1') and to_date('&dt2')
and s.session_id = &session_id
and s.SESSION_SERIAL# = &serial
and s.user_id is not null
group by sql_id, WAIT_CLASS, event, u.username, s.program
order by u.username, ctd desc, sql_id;

select
   sql_id, min(sample_time) inicio, max(sample_time) final, max(sample_time) - min(sample_time) as diff, count(1) ctd
from DBA_HIST_ACTIVE_SESS_HISTORY s
   left join dba_users u
           on u.user_id = s.user_id
where s.sample_time between to_date('&dt1') and to_date('&dt2')
and s.session_id = &session_id
and s.SESSION_SERIAL# = &serial
group by sql_id
order by 2 desc;


select
   xid, sql_id, min(sample_time) inicio, max(sample_time) final, max(sample_time) - min(sample_time) as diff, count(1) ctd
from DBA_HIST_ACTIVE_SESS_HISTORY s
   left join dba_users u
           on u.user_id = s.user_id
where s.sample_time between to_date('&dt1') and to_date('&dt2')
and s.session_id = &session_id
and s.SESSION_SERIAL# = &serial
group by xid, sql_id
order by xid, inicio desc;


select 
	sql_id, count(1) ctd
from DBA_HIST_ACTIVE_SESS_HISTORY s
	left join dba_users u
		on u.user_id = s.user_id
	left join V$ACTIVE_SERVICES sv
		on sv.NAME_HASH = s.service_hash
where s.sample_time between to_date('&dt1') and to_date('&dt2')
and s.session_id = &session_id
and s.SESSION_SERIAL# = &serial
and s.user_id is not null
group by sql_id
order by ctd desc;

select 
	SQL_PLAN_HASH_VALUE, count(1) ctd
from DBA_HIST_ACTIVE_SESS_HISTORY s
	left join dba_users u
		on u.user_id = s.user_id
	left join V$ACTIVE_SERVICES sv
		on sv.NAME_HASH = s.service_hash
where s.sample_time between to_date('&dt1') and to_date('&dt2')
and s.session_id = &session_id
and s.SESSION_SERIAL# = &serial
and s.user_id is not null
group by SQL_PLAN_HASH_VALUE
order by ctd desc;


undef dt1
undef dt2 
undefine session_id
undefine serial
clear breaks
clear computes