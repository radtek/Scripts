select active_session_history.event,
	sum(active_session_history.wait_time +
        active_session_history.time_waited) ttl_wait_time
from v$active_session_history active_session_history
where active_session_history.sample_time between sysdate - 60/2880 and sysdate
group by active_session_history.event
order by 2;

