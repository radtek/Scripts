col "Initial (40) text" format a45
select rownum rnum, a.*, round((sysdate - min_first_load_time ) *24*60 / "Num Execs") execs_by_min 
from (
Select substr(sql_text,1,40) 	As "Initial (40) text",
	   sum(USER_IO_WAIT_TIME) as "User IO Wait Time",
       sum(Elapsed_Time)        As "Elapsed Time",
       sum(cpu_time)            As "Cpu Time",
       Count(*) 		as "Num SQLs",
       Sum(Executions) 		As "Num Execs",
       Sum(Buffer_Gets) 	As "Read Blocks",
       Sum(Rows_Processed) 	As "Num Rows",
       Round(Sum(Buffer_Gets)/decode(Sum(Executions),0,1,Sum(Executions))) 	As "Bloc/Exec",
       Round(Sum(Rows_Processed)/decode(Sum(Executions),0,1,Sum(Executions))) 	As "Rows/Exec",
	   min(to_date(first_load_time, 'yyyy-mm-dd/hh24:mi:ss')) min_first_load_time	   
  From v$sqlarea
 where upper(substr(sql_text,1,40)) Not like 'BEGIN%'
   AND upper(substr(sql_text,1,40)) Not like 'DECLARE%'
 Group by substr(sql_text,1,40)
 having Round(Sum(Buffer_Gets)/decode(Sum(Executions),0,1,Sum(Executions))) > 100
 Order by sum(USER_IO_WAIT_TIME) desc) A
Where rownum <= 30	
/