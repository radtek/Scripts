break on sample_time skip 1
compute sum of ctd on sample_time

col program for a50
col module for a50
col action for a50
col client_id for a50
col wait_class for a100
col event for a100
col username for a50
col servicename for a50

Accept dt1  prompt 'Begin (dd/mm/yyyy hh24:mi:ss):'
Accept dt2  prompt 'End   (dd/mm/yyyy hh24:mi:ss):'


select 
	s.sample_time, s.event, s.wait_class, count(1) ctd
from v$active_session_history s
	inner join dba_users u
		on u.user_id = s.user_id
	inner join V$ACTIVE_SERVICES sv
		on sv.NAME_HASH = s.service_hash
where s.sample_time between to_date('&dt1') and to_date('&dt2')
and s.event is not null
group by s.sample_time, s.wait_class, s.event
order by 1, 4 desc
/



undef dt1
undef dt2 
clear breaks
clear computes