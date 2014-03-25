select operation_type as type, 
	policy, 
	sid, 
	round(active_time/1000000,2) as active_sec,
	round(work_area_size/1024/1024,2) as wa_size_MB, 
	round(expected_size/1024/1024,2) as expectedSize_MB,
	round(actual_mem_used/1024/1024,2) as actual_mem_MB,
	round(max_mem_used/1024/1024,2) as max_mem_MB, 
	number_passes as passes, 
	round(tempseg_size/1024/1024,2) as temp_MB
from v$sql_workarea_active
order by desc;
/
