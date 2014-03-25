set lines 2000
col SQL_TEXT format a102

select rownum rnum,       
	  a.*,
	  (SELECT substr(SQL_TEXT,1,100) FROM v$sqlarea WHERE FORCE_MATCHING_SIGNATURE = A.FORCE_MATCHING_SIGNATURE and rownum = 1) SQL_TEXT, 
	  (SELECT parsing_schema_name FROM v$sqlarea WHERE FORCE_MATCHING_SIGNATURE = A.FORCE_MATCHING_SIGNATURE and rownum = 1) parsing_schema_name
from (
		Select Count(*) 		as "Num SQLs",
			   Sum(Executions) 		As "Num Execs",
			   Sum(Buffer_Gets) 	As "Read Blocks",
			   Sum(Rows_Processed) 	As "Num Rows",
			   Round(Sum(Buffer_Gets)/decode(Sum(Executions),0,1,Sum(Executions))) 	As "Bloc/Exec",
			   Round(Sum(Rows_Processed)/decode(Sum(Executions),0,1,Sum(Executions))) 	As "Rows/Exec", 
			   FORCE_MATCHING_SIGNATURE
		From v$sqlarea
		where upper(substr(sql_text,1,40)) Not like 'BEGIN%'
		   AND upper(substr(sql_text,1,40)) Not like 'DECLARE%'
		Group by FORCE_MATCHING_SIGNATURE
		having Round(Sum(Buffer_Gets)/decode(Sum(Executions),0,1,Sum(Executions))) > 100
		Order by Sum(Buffer_Gets) desc) A
Where rownum <= 30;







