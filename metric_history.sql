col METRIC_NAME for a60

select END_TIME, METRIC_NAME, VALUE, METRIC_UNIT 
from  v$sysmetric_history 
where upper(metric_name) like upper('&metric_name')
order by METRIC_NAME, end_time;

