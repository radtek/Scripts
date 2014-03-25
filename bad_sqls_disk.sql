select rownum rnum, a.* from (
Select substr(sql_text,1,40) 	As "Initial (40) text",
       Count(*) 		as "Num SQLs",
       Sum(Executions) 		As "Num Execs",
       Sum(Disk_reads) 	        As "Disk Read Blocks",
       Sum(Rows_Processed) 	As "Num Rows",
       Round(Sum(Disk_reads)/decode(Sum(Executions),0,1,Sum(Executions))) 	As "DIsk/Exec",
       Round(Sum(Rows_Processed)/decode(Sum(Executions),0,1,Sum(Executions))) 	As "Rows/Exec"
  From v$sqlarea
 where upper(substr(sql_text,1,40)) Not like 'BEGIN%'
   AND upper(substr(sql_text,1,40)) Not like 'DECLARE%'
 Group by substr(sql_text,1,40)
 having Round(Sum(Disk_reads)/decode(Sum(Executions),0,1,Sum(Executions))) > 100
 Order by Sum(Disk_reads) desc) A
Where rownum <= 30
/
