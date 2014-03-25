col message for a150

SELECT state,undoblocksdone,undoblockstotal,cputime, pid
FROM v$fast_start_transactions;

select l.start_time,trunc(l.time_remaining/60,2) remaining_minutos,trunc(l.elapsed_seconds/60,2) Elapsed_minutos,      round((sofar/totalwork)*100,2) "%done",l.message
from gv$session_longops l
where 
(sofar/totalwork) < 1 and  totalwork > 0
/