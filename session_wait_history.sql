prompt
prompt sid é um IN
prompt
col EVENT format a60
select
   SID, SEQ#, EVENT, WAIT_TIME, WAIT_COUNT
from v$session_wait_history
where sid in (&sid)
order by sid, seq#;