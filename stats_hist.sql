select operation, target, start_time, end_time, end_time - start_time total_time 
						from DBA_OPTSTAT_OPERATIONS
						order by start_time;