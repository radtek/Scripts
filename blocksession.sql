break on REPORT

compute COUNT OF blocking_session ON REPORT
col BLOCKING_SESSION_STATUS format a10
col username format a20

select INST_ID, sid, username, blocking_session, BLOCKING_SESSION_STATUS, BLOCKING_INSTANCE
from gv$session 
where blocking_session is not null
UNION ALL
select  A.INST_ID, A.sid, A.username, A.blocking_session, B.STATUS, B.INST_ID
from gv$session A, gv$session B
where A.sid = B.blocking_session
order by blocking_session;

clear breaks