col SID format 99999

SELECT SID, cast(r.JOB as varchar2(30)) JOB, LOG_USER, r.THIS_DATE start_date, r.THIS_SEC as ELAPSED_TIME, r.instance
  FROM DBA_JOBS_RUNNING r
	left join DBA_JOBS j
		on r.JOB = j.JOB
union all
select SESSION_ID, JOB_NAME, OWNER, sysdate, to_char(ELAPSED_TIME), RUNNING_INSTANCE
from dba_SCHEDULER_RUNNING_JOBS;


  SELECT SID, TYPE, ID1, ID2
   FROM V$LOCK
   WHERE TYPE = 'JQ';

