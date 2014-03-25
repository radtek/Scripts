set verify off
set echo off
set long 999999
col SERVICE format a10
col MODULE format a10
col FIRST_LOAD_TIME format a20
col LAST_LOAD_TIME format a20
define hash=&hash

prompt "TOTAIS"
SELECT child_number, (SHARABLE_MEM + PERSISTENT_MEM + RUNTIME_MEM) AS SUM_MEM, EXECUTIONS, BUFFER_GETS, CPU_TIME, ELAPSED_TIME, DISK_READS, ROWS_PROCESSED, FETCHES, USERS_EXECUTING, parsing_user_id
	FROM V$SQL
WHERE hash_value=&hash;

prompt "VALOR POR EXECUCAO:"
	SELECT child_number, round((SHARABLE_MEM + PERSISTENT_MEM + RUNTIME_MEM) / DECODE(EXECUTIONS, 0, 1, EXECUTIONS)) AS SUM_MEM, 
		   ROUND(BUFFER_GETS / DECODE(EXECUTIONS, 0, 1, EXECUTIONS)) AS AVG_BUFFER_GETS, 
		ROUND((CPU_TIME  / DECODE(EXECUTIONS, 0, 1, EXECUTIONS))/ 1000)  AS AVG_CPU_MS,
		ROUND((ELAPSED_TIME / DECODE(EXECUTIONS, 0, 1, EXECUTIONS)) / 1000)   AS AVG_ELAPSED_MS,
		ROUND(DISK_READS  / DECODE(EXECUTIONS, 0, 1, EXECUTIONS)) AS AVG_DISK_READS,
		ROUND(ROWS_PROCESSED / DECODE(EXECUTIONS, 0, 1, EXECUTIONS)) AS AVG_ROWS,
		ROUND(FETCHES / DECODE(EXECUTIONS, 0, 1, EXECUTIONS)) AS AVG_FETCHES
	FROM V$SQL
	WHERE hash_value=&hash;
prompt 
prompt "GERAL DO SQL:"                         
	SELECT child_number, HASH_VALUE, MODULE, FIRST_LOAD_TIME, LAST_LOAD_TIME, USERS_EXECUTING, OPTIMIZER_MODE
	FROM V$SQL
	WHERE hash_value=&hash;
prompt 
prompt 
col sql_text format a999
SELECT
         T.SQL_TEXT
FROM     V$SQLTEXT T
WHERE t.hash_value=&hash
ORDER BY T.PIECE;
prompt
prompt
select     lpad(' ',2*(level-1))|| decode(id,0,operation||' '||options||' '||object_name||' Cost:'||cost,operation||' '||options||' '||object_name) operation
   , optimizer
   , cardinality num_rows
        , PARTITION_START
        , PARTITION_STOP
--   ,object_node
--   ,other
 from (
      select *
      from v$sql_plan a
      where a.hash_value = &hash
        and a.child_number = 0
      order by address, child_number)
start with id = 0
connect by prior id = parent_id
/
UNDEFINE hash
set verify on
