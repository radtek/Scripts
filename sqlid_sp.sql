

prompt lista os planos de um sqlid no statspack conforme periodo
prompt ignorar o primeiro registro da listagem devido ao calculo errado do delta

Accept dt1  prompt 'Begin (dd/mm/yyyy hh24:mi:ss)......:'
Accept dt2  prompt 'End   (dd/mm/yyyy hh24:mi:ss)......:'
Accept inst prompt 'Instance Number....................:'
Accept sql_id_list prompt 'Informe a lista de SQL_ID...:'

set verify off
col MODULE for a20
col OUTLINE_CATEGORY for a10
break on sql_id skip 1

prompt
prompt 
prompt ############ RESOURCES PER EXEC ###############			 
SELECT 			
	SQL_ID,
	to_char(SNAP_TIME, 'dd/mm hh:mi') as data, 	
	EXECUTIONS,
	round(ROWS_PROCESSED / EXECUTIONS) as ROWS_,
	round((CPU_TIME / 1000) / EXECUTIONS) As CPU,
	round((ELAPSED_TIME / 1000) / EXECUTIONS) as ELAPSED,
	round(DISK_READS / EXECUTIONS) as DISK_READS,
	round(DIRECT_WRITES / EXECUTIONS) as DIRECT_WRITES,
	round(BUFFER_GETS / EXECUTIONS) as BUFER_GETS,
	round(FETCHES	 / EXECUTIONS) as FETCHES,
	SNAP_ID, 
	STARTUP_TIME  
FROM (SELECT 
		   SNAP_ID,
		   SNAP_TIME,
		   STARTUP_TIME,	
		   SQL_ID,
		   round(EXECUTIONS - LAG(EXECUTIONS, 1, 0) OVER (PARTITION BY sql_id, startup_time  ORDER BY sql_id, snap_id, STARTUP_TIME)) as EXECUTIONS,
		   round(ROWS_PROCESSED - LAG(ROWS_PROCESSED, 1, 0) OVER (PARTITION BY sql_id, startup_time  ORDER BY sql_id, snap_id, STARTUP_TIME)) as ROWS_PROCESSED,
		   round(CPU_TIME - LAG(CPU_TIME, 1, 0) OVER (PARTITION BY sql_id, startup_time  ORDER BY sql_id, snap_id, STARTUP_TIME)) as CPU_TIME,
		   round(ELAPSED_TIME - LAG(ELAPSED_TIME, 1, 0) OVER (PARTITION BY sql_id, startup_time  ORDER BY sql_id, snap_id, STARTUP_TIME)) as ELAPSED_TIME,
		   round(DISK_READS - LAG(DISK_READS, 1, 0) OVER (PARTITION BY sql_id, startup_time  ORDER BY sql_id, snap_id, STARTUP_TIME)) as DISK_READS,
		   round(DIRECT_WRITES - LAG(DIRECT_WRITES, 1, 0) OVER (PARTITION BY sql_id, startup_time  ORDER BY sql_id, snap_id, STARTUP_TIME)) as DIRECT_WRITES,
		   round(BUFFER_GETS - LAG(BUFFER_GETS, 1, 0) OVER (PARTITION BY sql_id, startup_time  ORDER BY sql_id, snap_id, STARTUP_TIME)) as BUFFER_GETS,
		   round(FETCHES - LAG(FETCHES, 1, 0) OVER (PARTITION BY sql_id, startup_time  ORDER BY sql_id, snap_id, STARTUP_TIME)) as FETCHES
	  FROM (SELECT 
				   S.DBID, 
				   S.SNAP_ID,
				   S.SNAP_TIME,
				   S.STARTUP_TIME,	
				   SS.SQL_ID,
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
			 and SQL_ID in (&sql_id_list)
			group by S.DBID, 
				   S.SNAP_ID,
				   S.SNAP_TIME,
				   S.STARTUP_TIME,	
				   SS.SQL_ID) TBL) TBL
order by SQL_ID, snap_id;

prompt
prompt	 
prompt ############ WAIT TIME PER EXEC ###############		


SELECT 			
	SQL_ID,
	to_char(SNAP_TIME, 'dd/mm hh:mi') as data, 	
	round((APPLICATION_WAIT_TIME / 1000) / EXECUTIONS) as APPLICATION_WAIT_MS,
	round((CONCURRENCY_WAIT_TIME / 1000) / EXECUTIONS) as CONCURRENCY_WAIT_MS,
	round((CLUSTER_WAIT_TIME / 1000) / EXECUTIONS) as CLUSTER_WAIT_MS,
	round((USER_IO_WAIT_TIME / 1000) / EXECUTIONS) AS USER_IO_WAIT_MS,
	round((PLSQL_EXEC_TIME / 1000) / EXECUTIONS) as PLSQL_EXEC_MS,
	round((JAVA_EXEC_TIME / 1000) / EXECUTIONS) as JAVA_EXEC_MS,
	SNAP_ID, 
	STARTUP_TIME  
FROM (SELECT 
		   SNAP_ID,
		   SNAP_TIME,
		   STARTUP_TIME,	
		   SQL_ID,
		   round(EXECUTIONS - LAG(EXECUTIONS, 1, 0) OVER (PARTITION BY sql_id, startup_time  ORDER BY sql_id, snap_id, STARTUP_TIME)) as EXECUTIONS,
		   round(APPLICATION_WAIT_TIME - LAG(APPLICATION_WAIT_TIME, 1, 0) OVER (PARTITION BY sql_id, startup_time  ORDER BY sql_id, snap_id, STARTUP_TIME)) as APPLICATION_WAIT_TIME,
		   round(CONCURRENCY_WAIT_TIME - LAG(CONCURRENCY_WAIT_TIME, 1, 0) OVER (PARTITION BY sql_id, startup_time  ORDER BY sql_id, snap_id, STARTUP_TIME)) as CONCURRENCY_WAIT_TIME,
		   round(CLUSTER_WAIT_TIME - LAG(CLUSTER_WAIT_TIME, 1, 0) OVER (PARTITION BY sql_id, startup_time  ORDER BY sql_id, snap_id, STARTUP_TIME)) as CLUSTER_WAIT_TIME,
		   round(USER_IO_WAIT_TIME - LAG(USER_IO_WAIT_TIME, 1, 0) OVER (PARTITION BY sql_id, startup_time  ORDER BY sql_id, snap_id, STARTUP_TIME)) as USER_IO_WAIT_TIME,
		   round(PLSQL_EXEC_TIME - LAG(PLSQL_EXEC_TIME, 1, 0) OVER (PARTITION BY sql_id, startup_time  ORDER BY sql_id, snap_id, STARTUP_TIME)) as PLSQL_EXEC_TIME,
		   round(JAVA_EXEC_TIME - LAG(JAVA_EXEC_TIME, 1, 0) OVER (PARTITION BY sql_id, startup_time  ORDER BY sql_id, snap_id, STARTUP_TIME)) as JAVA_EXEC_TIME
	  FROM (SELECT 
				   S.DBID, 
				   S.SNAP_ID,
				   S.SNAP_TIME,
				   S.STARTUP_TIME,	
				   SS.SQL_ID,
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
			 and SQL_ID in (&sql_id_list)
			group by S.DBID, 
				   S.SNAP_ID,
				   S.SNAP_TIME,
				   S.STARTUP_TIME,	
				   SS.SQL_ID) TBL) TBL
order by SQL_ID, snap_id;	 	
prompt
prompt
prompt ############ INFORMACOES GERAIS ###############			 
SELECT 			
	ss.SQL_ID,
	to_char(SNAP_TIME, 'dd/mm hh:mi') as data, 
	ss.VERSION_COUNT,
	ss.LOADS,
	ss.INVALIDATIONS,
	ss.PARSE_CALLS,	
	ss.SORTS,
	ss.MODULE,
	ss.PX_SERVERS_EXECUTIONS,
	ss.OUTLINE_CATEGORY,
	ss.HASH_VALUE,
	ss.FORCE_MATCHING_SIGNATURE,
	ss.AVG_HARD_PARSE_TIME,
	s.SNAP_ID
from stats$snapshot S
	inner join stats$sql_summary ss
		on S.snap_id         = SS.snap_id
		and S.instance_number = SS.instance_number
		and S.dbid            = SS.dbid	 	
where s.SNAP_TIME between to_date('&dt1', 'dd/mm/yyyy hh24:mi:ss') and to_date('&dt2', 'dd/mm/yyyy hh24:mi:ss')
 and (s.INSTANCE_NUMBER = &inst or &inst = 0)
 and SQL_ID in (&sql_id_list)
order by SQL_ID, s.snap_id;

prompt 
prompt
prompt ############ INFORMACOES SOBRE TROCA DE PLANO ###############

SELECT 
	SQL_ID, 		
	PLAN_HASH_VALUE,	
	count(1) ctd
from stats$snapshot S
	inner join STATS$SQL_PLAN_USAGE ss
		on S.snap_id          = SS.snap_id
		and S.instance_number = SS.instance_number
		and S.dbid            = SS.dbid	 	
where     s.SNAP_TIME between to_date('&dt1', 'dd/mm/yyyy hh24:mi:ss') and to_date('&dt2', 'dd/mm/yyyy hh24:mi:ss')
	 and (s.INSTANCE_NUMBER = &inst or &inst = 0)
	 and SQL_ID in (&sql_id_list)
group by sql_id, PLAN_HASH_VALUE
order by ctd;

prompt 
prompt
break on sql_id skip 1 on PLAN_HASH_VALUE skip 1

SELECT 
	SQL_ID, 				
	to_char(SNAP_TIME, 'dd/mm hh:mi') as data, 
	PLAN_HASH_VALUE, 
	COST, 
	OPTIMIZER, 
	LAST_ACTIVE_TIME, 
	S.SNAP_ID
from stats$snapshot S
	inner join STATS$SQL_PLAN_USAGE ss
		on S.snap_id          = SS.snap_id
		and S.instance_number = SS.instance_number
		and S.dbid            = SS.dbid	 	
where     s.SNAP_TIME between to_date('&dt1', 'dd/mm/yyyy hh24:mi:ss') and to_date('&dt2', 'dd/mm/yyyy hh24:mi:ss')
	 and (s.INSTANCE_NUMBER = &inst or &inst = 0)
	 and SQL_ID in (&sql_id_list)
order by sql_id, s.SNAP_ID, PLAN_HASH_VALUE;

prompt 
prompt

set verify off
set feedback off
set long 100000
set longchunksize 100000
var saida clob
begin
dbms_lob.createtemporary(:saida, TRUE); for linha in (select sql_text from V$SQLTEXT_WITH_NEWLINES
where sql_id in (&sql_id_list)
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
undef sql_id_list
set verify on