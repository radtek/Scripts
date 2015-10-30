select a.sql_id, a.executions, a.CPU_TIME, a.DISK_READS, a.BUFFER_GETS 
from V$SQLAREA a
where a.sql_id in (select o.sql_id from V$OPEN_CURSOR o where o.sid=&sid)
order by a.BUFFER_GETS;