col OWNER for a20
col job_action for a100 wrapped
col REPEAT_INTERVAL for a30
col START_DATE for a20
col END_DATE for a20
col NEXT_RUN_DATE for a20
col LAST_START_DATE for a20
col LAST_RUN_DURATION for a30
col MAX_RUN_DURATION for a30
define job_name = &job_name;

select
    d.OWNER,
    d.job_name,
    d.start_date,  	
    d.repeat_interval, 
    d.NEXT_RUN_DATE,
    d.enabled, 
    d.state, 
    d.run_count, 
    d.failure_count, 
    d.retry_count, 
    d.last_start_date, 
    d.last_run_duration, 
    d.max_run_duration, 
    d.job_action
from
    dba_scheduler_jobs d 
where
	 upper(d.job_name) like upper('&job_name') ;

undefine job_name	