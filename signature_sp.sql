

prompt lista os planos de um assintura ou FORCE_MATCHING_SIGNATURE no statspack conforme periodo
prompt ignorar o primeiro registro da listagem devido ao calculo errado do delta
prompt como é uma agregação por FORCE_MATCHING_SIGNATURE, pode ser que sql_id coletados em um snap não foram coletados em outros, entao pode ter valores negativos

Accept dt1  prompt 'Begin (dd/mm/yyyy hh24:mi:ss)......:'
Accept dt2  prompt 'End   (dd/mm/yyyy hh24:mi:ss)......:'
Accept inst default '0' prompt 'Instance Number....................:'
Accept FORCE_MATCHING_SIGNATURE_list prompt 'Informe o FORCE_MATCHING_SIGNATURE...:'

set verify off
col MODULE for a20
col OUTLINE_CATEGORY for a10
break on FORCE_MATCHING_SIGNATURE skip 1

prompt
prompt 
prompt ############ RESOURCES PER EXEC ###############			 
SELECT 			
	FORCE_MATCHING_SIGNATURE,
	to_char(SNAP_TIME, 'dd/mm hh24:mi') as data, 	
	EXECUTIONS,
	round(ROWS_PROCESSED / NVL(NULLIF(EXECUTIONS,0), 1)) as ROWS_,
	round((CPU_TIME / 1000) / NVL(NULLIF(EXECUTIONS,0), 1)) As CPU,
	round((ELAPSED_TIME / 1000) / NVL(NULLIF(EXECUTIONS,0), 1)) as ELAPSED,
	round(DISK_READS / NVL(NULLIF(EXECUTIONS,0), 1)) as DISK_READS,
	round(DIRECT_WRITES / NVL(NULLIF(EXECUTIONS,0), 1)) as DIRECT_WRITES,
	round(BUFFER_GETS / NVL(NULLIF(EXECUTIONS,0), 1)) as BUFER_GETS,
	round(FETCHES	 / NVL(NULLIF(EXECUTIONS,0), 1)) as FETCHES,
	SNAP_ID, 
	INSTANCE_NUMBER,
	STARTUP_TIME  
FROM (SELECT 
		   SNAP_ID,
		   INSTANCE_NUMBER,
		   SNAP_TIME,
		   STARTUP_TIME,	
		   FORCE_MATCHING_SIGNATURE,
		   round(EXECUTIONS - LAG(EXECUTIONS, 1, 0) OVER (PARTITION BY FORCE_MATCHING_SIGNATURE, startup_time  ORDER BY FORCE_MATCHING_SIGNATURE, snap_id, STARTUP_TIME)) as EXECUTIONS,
		   round(ROWS_PROCESSED - LAG(ROWS_PROCESSED, 1, 0) OVER (PARTITION BY FORCE_MATCHING_SIGNATURE, startup_time  ORDER BY FORCE_MATCHING_SIGNATURE, snap_id, STARTUP_TIME)) as ROWS_PROCESSED,
		   round(CPU_TIME - LAG(CPU_TIME, 1, 0) OVER (PARTITION BY FORCE_MATCHING_SIGNATURE, startup_time  ORDER BY FORCE_MATCHING_SIGNATURE, snap_id, STARTUP_TIME)) as CPU_TIME,
		   round(ELAPSED_TIME - LAG(ELAPSED_TIME, 1, 0) OVER (PARTITION BY FORCE_MATCHING_SIGNATURE, startup_time  ORDER BY FORCE_MATCHING_SIGNATURE, snap_id, STARTUP_TIME)) as ELAPSED_TIME,
		   round(DISK_READS - LAG(DISK_READS, 1, 0) OVER (PARTITION BY FORCE_MATCHING_SIGNATURE, startup_time  ORDER BY FORCE_MATCHING_SIGNATURE, snap_id, STARTUP_TIME)) as DISK_READS,
		   round(DIRECT_WRITES - LAG(DIRECT_WRITES, 1, 0) OVER (PARTITION BY FORCE_MATCHING_SIGNATURE, startup_time  ORDER BY FORCE_MATCHING_SIGNATURE, snap_id, STARTUP_TIME)) as DIRECT_WRITES,
		   round(BUFFER_GETS - LAG(BUFFER_GETS, 1, 0) OVER (PARTITION BY FORCE_MATCHING_SIGNATURE, startup_time  ORDER BY FORCE_MATCHING_SIGNATURE, snap_id, STARTUP_TIME)) as BUFFER_GETS,
		   round(FETCHES - LAG(FETCHES, 1, 0) OVER (PARTITION BY FORCE_MATCHING_SIGNATURE, startup_time  ORDER BY FORCE_MATCHING_SIGNATURE, snap_id, STARTUP_TIME)) as FETCHES
	  FROM (SELECT 
				   S.DBID, 
				   S.SNAP_ID,
				   s.INSTANCE_NUMBER,				   
				   S.SNAP_TIME,
				   S.STARTUP_TIME,	
				   SS.FORCE_MATCHING_SIGNATURE,
				   SUM(EXECUTIONS) AS EXECUTIONS,
				   SUM(ROWS_PROCESSED) AS ROWS_PROCESSED,
				   SUM(CPU_TIME) as CPU_TIME,
				   SUM(ELAPSED_TIME) as ELAPSED_TIME,
				   SUM(DISK_READS) as DISK_READS,
				   SUM(DIRECT_WRITES) as DIRECT_WRITES,
				   SUM(BUFFER_GETS) as BUFFER_GETS,
				   SUM(FETCHES) as FETCHES	
			from stats$snapshot S
				inner join stats$sql_summary ss
					on S.snap_id         = SS.snap_id
					and S.instance_number = SS.instance_number
					and S.dbid            = SS.dbid	 	
			where s.SNAP_TIME between to_date('&dt1', 'dd/mm/yyyy hh24:mi:ss') and to_date('&dt2', 'dd/mm/yyyy hh24:mi:ss')
			 and (s.INSTANCE_NUMBER = &inst or &inst = 0)
			 and FORCE_MATCHING_SIGNATURE = &FORCE_MATCHING_SIGNATURE_list
			group by S.DBID, 
				   S.SNAP_ID,
				   s.INSTANCE_NUMBER,
				   S.SNAP_TIME,
				   S.STARTUP_TIME,	
				   SS.FORCE_MATCHING_SIGNATURE) TBL) TBL
order by FORCE_MATCHING_SIGNATURE, snap_id, INSTANCE_NUMBER;

prompt
prompt	 
prompt ############ WAIT TIME PER EXEC ###############		


SELECT 			
	FORCE_MATCHING_SIGNATURE,
	to_char(SNAP_TIME, 'dd/mm hh24:mi') as data, 	
	round((APPLICATION_WAIT_TIME / 1000) / NVL(NULLIF(EXECUTIONS,0), 1)) as APPLICATION_WAIT_MS,
	round((CONCURRENCY_WAIT_TIME / 1000) / NVL(NULLIF(EXECUTIONS,0), 1)) as CONCURRENCY_WAIT_MS,
	round((CLUSTER_WAIT_TIME / 1000) / NVL(NULLIF(EXECUTIONS,0), 1)) as CLUSTER_WAIT_MS,
	round((USER_IO_WAIT_TIME / 1000) / NVL(NULLIF(EXECUTIONS,0), 1)) AS USER_IO_WAIT_MS,
	round((PLSQL_EXEC_TIME / 1000) / NVL(NULLIF(EXECUTIONS,0), 1)) as PLSQL_EXEC_MS,
	round((JAVA_EXEC_TIME / 1000) / NVL(NULLIF(EXECUTIONS,0), 1)) as JAVA_EXEC_MS,
	SNAP_ID, 
	INSTANCE_NUMBER,
	STARTUP_TIME  
FROM (SELECT 
		   SNAP_ID,
		   SNAP_TIME,
		   STARTUP_TIME,	
		   FORCE_MATCHING_SIGNATURE,
		   INSTANCE_NUMBER,
		   round(EXECUTIONS - LAG(EXECUTIONS, 1, 0) OVER (PARTITION BY FORCE_MATCHING_SIGNATURE, startup_time  ORDER BY FORCE_MATCHING_SIGNATURE, snap_id, STARTUP_TIME)) as EXECUTIONS,
		   round(APPLICATION_WAIT_TIME - LAG(APPLICATION_WAIT_TIME, 1, 0) OVER (PARTITION BY FORCE_MATCHING_SIGNATURE, startup_time  ORDER BY FORCE_MATCHING_SIGNATURE, snap_id, STARTUP_TIME)) as APPLICATION_WAIT_TIME,
		   round(CONCURRENCY_WAIT_TIME - LAG(CONCURRENCY_WAIT_TIME, 1, 0) OVER (PARTITION BY FORCE_MATCHING_SIGNATURE, startup_time  ORDER BY FORCE_MATCHING_SIGNATURE, snap_id, STARTUP_TIME)) as CONCURRENCY_WAIT_TIME,
		   round(CLUSTER_WAIT_TIME - LAG(CLUSTER_WAIT_TIME, 1, 0) OVER (PARTITION BY FORCE_MATCHING_SIGNATURE, startup_time  ORDER BY FORCE_MATCHING_SIGNATURE, snap_id, STARTUP_TIME)) as CLUSTER_WAIT_TIME,
		   round(USER_IO_WAIT_TIME - LAG(USER_IO_WAIT_TIME, 1, 0) OVER (PARTITION BY FORCE_MATCHING_SIGNATURE, startup_time  ORDER BY FORCE_MATCHING_SIGNATURE, snap_id, STARTUP_TIME)) as USER_IO_WAIT_TIME,
		   round(PLSQL_EXEC_TIME - LAG(PLSQL_EXEC_TIME, 1, 0) OVER (PARTITION BY FORCE_MATCHING_SIGNATURE, startup_time  ORDER BY FORCE_MATCHING_SIGNATURE, snap_id, STARTUP_TIME)) as PLSQL_EXEC_TIME,
		   round(JAVA_EXEC_TIME - LAG(JAVA_EXEC_TIME, 1, 0) OVER (PARTITION BY FORCE_MATCHING_SIGNATURE, startup_time  ORDER BY FORCE_MATCHING_SIGNATURE, snap_id, STARTUP_TIME)) as JAVA_EXEC_TIME
	  FROM (SELECT 
				   S.DBID, 
				   S.SNAP_ID,
				   S.SNAP_TIME,
				   S.STARTUP_TIME,	
				   SS.FORCE_MATCHING_SIGNATURE,
				   s.INSTANCE_NUMBER,
				   SUM(EXECUTIONS) AS EXECUTIONS,				   
				   SUM(APPLICATION_WAIT_TIME) AS APPLICATION_WAIT_TIME,
				   SUM(CONCURRENCY_WAIT_TIME) AS CONCURRENCY_WAIT_TIME,
				   SUM(CLUSTER_WAIT_TIME) AS CLUSTER_WAIT_TIME,
				   SUM(USER_IO_WAIT_TIME) AS USER_IO_WAIT_TIME,
				   SUM(PLSQL_EXEC_TIME) AS PLSQL_EXEC_TIME,
				   SUM(JAVA_EXEC_TIME) AS JAVA_EXEC_TIME				   
			from stats$snapshot S
				inner join stats$sql_summary ss
					on S.snap_id         = SS.snap_id
					and S.instance_number = SS.instance_number
					and S.dbid            = SS.dbid	 	
			where s.SNAP_TIME between to_date('&dt1', 'dd/mm/yyyy hh24:mi:ss') and to_date('&dt2', 'dd/mm/yyyy hh24:mi:ss')
			 and (s.INSTANCE_NUMBER = &inst or &inst = 0)
			 and FORCE_MATCHING_SIGNATURE = &FORCE_MATCHING_SIGNATURE_list
			group by S.DBID, 
				   S.SNAP_ID,
				   s.INSTANCE_NUMBER,
				   S.SNAP_TIME,
				   S.STARTUP_TIME,	
				   SS.FORCE_MATCHING_SIGNATURE) TBL) TBL
order by FORCE_MATCHING_SIGNATURE, snap_id, INSTANCE_NUMBER;	 	
prompt
prompt
prompt ############ INFORMACOES GERAIS ###############			 
SELECT 			
	ss.FORCE_MATCHING_SIGNATURE,
	MAX(to_char(SNAP_TIME, 'dd/mm hh24:mi')) as data, 
	SUM(ss.VERSION_COUNT) as VERSION_COUNT,
	SUM(ss.LOADS) as LOADS,
	SUM(ss.INVALIDATIONS) as INVALIDATIONS,
	SUM(ss.PARSE_CALLS) as PARSE_CALLS,	
	SUM(ss.SORTS) as SORTS,
	MAX(ss.MODULE) as MODULE,
	SUM(ss.PX_SERVERS_EXECUTIONS) as PX_SERVERS_EXECUTIONS,
	MAX(ss.OUTLINE_CATEGORY) as OUTLINE_CATEGORY,
	AVG(ss.AVG_HARD_PARSE_TIME) as AVG_HARD_PARSE_TIME,
	s.SNAP_ID,
	s.INSTANCE_NUMBER
from stats$snapshot S
	inner join stats$sql_summary ss
		on S.snap_id         = SS.snap_id
		and S.instance_number = SS.instance_number
		and S.dbid            = SS.dbid	 	
where s.SNAP_TIME between to_date('&dt1', 'dd/mm/yyyy hh24:mi:ss') and to_date('&dt2', 'dd/mm/yyyy hh24:mi:ss')
 and (s.INSTANCE_NUMBER = &inst or &inst = 0)
 and FORCE_MATCHING_SIGNATURE = &FORCE_MATCHING_SIGNATURE_list
GROUP BY ss.FORCE_MATCHING_SIGNATURE,
	s.SNAP_ID,
	s.INSTANCE_NUMBER
order by FORCE_MATCHING_SIGNATURE, s.snap_id;

prompt 
prompt
prompt ############ INFORMACOES SOBRE TROCA DE PLANO ###############

SELECT 
	ss.FORCE_MATCHING_SIGNATURE, 		
	spu.PLAN_HASH_VALUE,	
	count(1) ctd
from stats$snapshot S
	inner join STATS$SQL_PLAN_USAGE spu
		on S.snap_id          = spu.snap_id
		and S.instance_number = spu.instance_number
		and S.dbid            = spu.dbid	 	
	inner join stats$sql_summary ss
		on S.snap_id         = SS.snap_id
		and S.instance_number = SS.instance_number
		and S.dbid            = SS.dbid	 	
		and spu.HASH_VALUE	  = SS.HASH_VALUE
where     s.SNAP_TIME between to_date('&dt1', 'dd/mm/yyyy hh24:mi:ss') and to_date('&dt2', 'dd/mm/yyyy hh24:mi:ss')
	 and (s.INSTANCE_NUMBER = &inst or &inst = 0)
	 and ss.FORCE_MATCHING_SIGNATURE = &FORCE_MATCHING_SIGNATURE_list
group by ss.FORCE_MATCHING_SIGNATURE, spu.PLAN_HASH_VALUE
order by ctd;

prompt 
prompt

set verify off
set feedback off
set long 100000
set longchunksize 100000
var saida clob
begin
dbms_lob.createtemporary(:saida, TRUE); for linha in (select sql_text from V$SQLTEXT_WITH_NEWLINES where SQL_ID = 
	(select max(sql_id) from v$sql where FORCE_MATCHING_SIGNATURE = &FORCE_MATCHING_SIGNATURE_list)
	order by sql_id, piece)
loop
:saida := :saida ||linha.sql_text;
end loop;
end;
/
select :saida SQL from dual;
set verify on
set feedback on

prompt
prompt

undef inst
undef dt1
undef dt2
undef FORCE_MATCHING_SIGNATURE_list
set verify on