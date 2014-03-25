prompt 
prompt informe sql_id % para pegar os top 50 operações
prompt usar @plan_hash para identificar o sql_id
prompt 
prompt 
select * 
from (
select s.plan_hash_value, sw.operation_type, 
	round((sum(sw.active_time) / 100)) as active_time_seg, 
	 sum(sw.total_executions) total_exec, 
	 sum(sw.optimal_executions) total_optimal, 
	 round(sum(sw.optimal_executions) / sum(sw.total_executions) * 100) as "%perc"
from v$sql s
	inner join v$sql_workarea sw
		on s.sql_id = sw.sql_id
where s.sql_id like '&sql_id'
and sw.total_executions > 0
group by s.plan_hash_value, sw.operation_type
order by active_time_seg desc, s.plan_hash_value, sw.operation_type)
where rownum < 50;