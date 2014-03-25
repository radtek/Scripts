select rownum rnum, a.* from (
Select substr(sql_text,1,40) 	As "Initial_text",
       Count(*) 		as "Num SQLs",
       Sum(Executions) 		As "Num Execs",
       Sum(Buffer_Gets) 	As "Read Blocks",
       Sum(Rows_Processed) 	As "Num Rows",
       Round(Sum(Buffer_Gets)/decode(Sum(Executions),0,1,Sum(Executions))) 	As "Bloc/Exec",
       Round(Sum(Rows_Processed)/decode(Sum(Executions),0,1,Sum(Executions))) 	As "Rows/Exec"
  From v$sqlarea
 where upper(substr(sql_text,1,40)) Not like 'BEGIN%'
   AND upper(substr(sql_text,1,40)) Not like 'DECLARE%'
   and parsing_schema_name not in  ('SYS', 'SYSTEM')
 Group by substr(sql_text,1,40)
 having Round(Sum(Buffer_Gets)/decode(Sum(Executions),0,1,Sum(Executions))) > 1000
   and Sum(Executions) > 100
 Order by Round(Sum(Buffer_Gets)/decode(Sum(Executions),0,1,Sum(Executions))) desc) A
Where rownum <= 30
order by "Bloc/Exec" desc;