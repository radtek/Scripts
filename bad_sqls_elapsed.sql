
col "Initial (40) text" format a45
col "Elapsed TimeMS" for 99999999999999999
col "Cpu TimeMS" for  99999999999999999
col "AVG_Elapsed TimeMS" for 99999999999999

select rownum rnum, a.*, round((sysdate - min_first_load_time ) *24*60 / "Num Execs") execs_by_min 
from (
Select substr(sql_text,1,40) 	As "Initial (40) text",
       sum(Elapsed_Time)        As "Elapsed TimeMS",
       Round(sum(Elapsed_Time) / 1000 / Sum(Executions)) as "AVG_Elapsed TimeMS",
       round(sum(cpu_time) / 1000)           As "Cpu TimeMS",
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
 Order by sum(Elapsed_Time) desc) A
Where rownum <= 30	
order by "Elapsed TimeMS" desc
/
