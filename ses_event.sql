select sid, event, time_waited, time_waited_micro
from v$session_event where sid=&sid order by 3;