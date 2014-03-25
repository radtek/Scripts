select distinct client_name, window_name, job_status, job_info
from dba_autotask_job_history
where job_status <> 'SUCCEEDED'
order by 1,2;