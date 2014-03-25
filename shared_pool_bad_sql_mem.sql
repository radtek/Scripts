prompt identificar consultas que usam mais memória da shared pool 
SELECT substr(sql_text,1,20) "Stmt", count(*),
  sum(sharable_mem)/1024/1024 "Mem",
  sum(users_opening) "Open",
  sum(executions) "Exec"
  FROM v$sql
GROUP BY substr(sql_text,1,20)
HAVING sum(sharable_mem) > (select current_size*0.1 from v$sga_dynamic_components where component='shared pool');
