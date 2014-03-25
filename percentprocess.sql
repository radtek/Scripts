col sid format 99999
col message for a150

select s.inst_id, s.sid,s.serial#, s.username,l.start_time,trunc(l.time_remaining/60,2) remaining_minutos,trunc(l.elapsed_seconds/60,2) Elapsed_minutos,      round((sofar/totalwork)*100,2) "%done",l.message
from gv$session s, gv$session_longops l
where s.sid = l.sid and
s.status = 'ACTIVE' and      
-- (sofar/totalwork) < 1 and 
trunc(l.time_remaining/60,2) > 0 and 
totalwork > 0
order by s.username
/