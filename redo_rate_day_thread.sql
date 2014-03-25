
compute AVG LABEL "AVG thread#" OF Archives_Generated ON thread# 

compute AVG LABEL "AVG thread#" -
		MAX LABEL "MAX thread#" -
		MIN LABEL "MIN thread#" -
		OF "MB" on thread#

break on thread# skip 1 

select thread#,
	   to_char(trunc(COMPLETION_TIME,'DD'), 'MONTH DD') "Day", 	    
	   round(sum(BLOCKS*BLOCK_SIZE) / 1024 / 1024) MB,
	   count(*) Archives_Generated 
FROM v$archived_log
WHERE COMPLETION_TIME > (sysdate - 30)
group by trunc(COMPLETION_TIME,'DD'), thread# 
order by thread#, trunc(COMPLETION_TIME,'DD'); 

clear breaks;
clear columns;
clear computes;