prompt
show parameter service_names 
prompt
prompt
col total_waits for 9999999999999999 justify right
col time_waited for 9999999999999999 justify right
col service_name for a30
col wait_class for a60

select service_name, wait_class, total_waits, time_waited
from v$service_wait_class
where upper(service_name) like upper('&service_name')
and upper(wait_class) like upper('&wait_class')
order by service_name, time_waited;