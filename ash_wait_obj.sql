select dba_objects.object_name,
dba_objects.object_type,
active_session_history.event,
sum(active_session_history.wait_time +
active_session_history.time_waited) ttl_wait_time
from v$active_session_history active_session_history,
dba_objects
where active_session_history.sample_time between sysdate - 60/2880 and sysdate
and active_session_history.current_obj# = dba_objects.object_id
group by dba_objects.object_name, dba_objects.object_type, active_session_history.event
order by 4;
