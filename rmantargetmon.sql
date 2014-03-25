select sid,
       serial#,
       context,
       sofar,
       totalwork,
       round(sofar/totalwork*100,2) "%_complete"
from
       v$session_longops
where
        opname like 'RMAN%'
        and opname not like '%aggregate%'
        and totalwork != 0
        and sofar <> totalwork;
