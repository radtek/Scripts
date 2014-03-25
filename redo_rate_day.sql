
break on REPORT

compute AVG LABEL "AVG" OF Archives_Generated ON REPORT 

compute AVG LABEL "AVG " -
		MAX LABEL "MAX " -
		MIN LABEL "MIN " -
		OF "MB" on REPORT

select to_char(trunc(COMPLETION_TIME,'DD'), 'MONTH DD') "Day", 
	   round(sum(BLOCKS*BLOCK_SIZE) / 1024 / 1024) MB,
	   count(*) Archives_Generated 
FROM v$archived_log
WHERE COMPLETION_TIME > (sysdate - 30)
group by trunc(COMPLETION_TIME,'DD')
order by trunc(COMPLETION_TIME,'DD');

clear breaks;
clear columns;
clear computes;