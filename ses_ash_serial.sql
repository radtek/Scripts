select
   	s.session_serial#, 
	min(s.sample_time) inicio, 
	max(s.sample_time) final
from DBA_HIST_ACTIVE_SESS_HISTORY s
where s.sample_time between to_date('&dt1', 'dd/mm/yyyy HH24:mi:ss') and to_date('&dt2', 'dd/mm/yyyy HH24:mi:ss')
and s.session_id = &session_id
group by s.session_serial#
order by inicio;