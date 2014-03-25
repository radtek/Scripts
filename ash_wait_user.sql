select sesion.sid,
	sesion.username,
	sum(active_session_history.wait_time +
        active_session_history.time_waited) ttl_wait_time
from v$active_session_history active_session_history,
	v$session sesion
where active_session_history.sample_time between sysdate - 60/2880 and sysdate
and active_session_history.session_id = sesion.sid
group by sesion.sid, sesion.username
order by 3;

