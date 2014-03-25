set lines 2000
col SQL_TEXT format a102

select rownum rnum,       
	  a.*
from (
		Select    sum(cpu_time)            As "Cpu Time",
			   sum(Elapsed_Time)        As "Elapsed Time",
			   Count(*) 		as "Num SQLs",
			   Sum(Executions) 		As "Num Execs",
			   Sum(Buffer_Gets) 	As "Read Blocks",
			   Round(Sum(Buffer_Gets)/Sum(Executions)) As "Blocks/Exec", 
			   substr(SQL_TEXT,1,50) as SQL_TEXT,
			   Sum(Rows_Processed) 	As "Num Rows",
			   Round(Sum(Buffer_Gets)/decode(Sum(Executions),0,1,Sum(Executions))) 	As "Bloc/Exec",
			   Round(Sum(Rows_Processed)/decode(Sum(Executions),0,1,Sum(Executions))) 	As "Rows/Exec"
		  From v$sqlarea
		 where upper(substr(sql_text,1,40)) Not like 'BEGIN%'
		   AND upper(substr(sql_text,1,40)) Not like 'DECLARE%'
		   AND Executions > 0
		 Group by substr(SQL_TEXT,1,50)
having Round(Sum(Buffer_Gets)/decode(Sum(Executions),0,1,Sum(Executions))) > 100
Order by sum(cpu_time) desc) A
Where rownum <= 30
/

