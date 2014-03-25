prompt coluna: "O/1/M"
prompt 		O = optimal, ou seja memória suficiente
prompt 		1 = one pass, falta memoria, mas acessou somente uma X o segmento temporario
prompt 		M = multi pass, falta memoria, e acessou N X o segmento temporario
prompt

col "O/1/M" format a10
col name format a20

SELECT operation, options, object_name name,
       trunc(bytes/1024/1024) "input(MB)",
       trunc(last_memory_used/1024) last_mem,
       trunc(estimated_optimal_size/1024) optimal_mem, 
       trunc(estimated_onepass_size/1024) onepass_mem, 
       decode(optimal_executions, null, null, 
              optimal_executions||'/'||onepass_executions||'/'||
              multipasses_executions) "O/1/M"
  FROM V$SQL_PLAN p, V$SQL_WORKAREA w 
 WHERE p.address=w.address(+) 
   AND p.hash_value=w.hash_value(+) 
   AND p.id=w.operation_id(+) 
   AND p.sql_id='&sqlid';