
break on session_recid
col intervalo format a15
col status format a10
COL SESSION_RECID HEADING 'SESSION' 
COL OUTPUT_DEVICE_TYPE HEADING 'DEVICE' 

select session_recid, object_type, status, start_time, replace(replace(cast(cast(end_time as timestamp) - cast(start_time as timestamp) as varchar2(100)), 'INTERVAL''+00000000', ''), '.000000''DAY(9)TO SECOND', '') intervalo, OUTPUT_DEVICE_TYPE, 
	   round(MBYTES_PROCESSED/1024,2) as sizeGB
from V$RMAN_STATUS
where  start_time > sysdate - 10
and operation IN ('BACKUP', 'RESTORE')
order by session_recid, start_time;

undef object_type