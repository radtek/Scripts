SELECT
	SUM(case WHEN query1.avg_elapsed_time < query2.avg_elapsed_time THEN 1 ELSE 0 END) AS CTD_1ST_BETTER,
	SUM(case WHEN query2.avg_elapsed_time < query1.avg_elapsed_time THEN 1 ELSE 0 END) AS CTD_2ND_BETTER,
	trunc(SUM(( query1.avg_elapsed_time - query2.avg_elapsed_time)/1000000),2) SUM_AVG_ELA_DIFF,
	trunc(SUM(((query1.avg_elapsed_time - query2.avg_elapsed_time) * query2.executions)/1000000),2)     SUM_ELA_TOT_DIFF,
	trunc(SUM((query1.avg_buffer_gets - query2.avg_buffer_gets) * query2.executions),2)      SUM_BGETS_TOT_DIFF
from
		(SELECT
			sql_id,plan_hash_value,last_active_time,executions,(rows_processed/executions) avg_rows_processed,
			(elapsed_time/executions) avg_elapsed_time,(cpu_time/executions) avg_cpu_time,(buffer_gets/executions) avg_buffer_gets,
			sql_text 
		 from V$SQLSTATS_PLAN_HASH a
		 where exists (SELECT plan_hash_value  from V$SQLSTATS_PLAN_HASH b  where a.sql_id=b.sql_id and a.plan_hash_value <> b.plan_hash_value and executions > 0)
		   and executions > 0
		 order by sql_id,last_active_time) query1,
		(SELECT 
			sql_id,plan_hash_value,last_active_time,executions,(rows_processed/executions) avg_rows_processed,
			(elapsed_time/executions) avg_elapsed_time,(cpu_time/executions) avg_cpu_time,(buffer_gets/executions) avg_buffer_gets,
			sql_text 
		 from V$SQLSTATS_PLAN_HASH a
		 where exists (SELECT plan_hash_value  from V$SQLSTATS_PLAN_HASH b  where a.sql_id=b.sql_id and a.plan_hash_value <> b.plan_hash_value and executions > 0)
		   and executions > 0
		 order by sql_id,last_active_time) query2 -- 
where query1.sql_id=query2.sql_id
  and query1.last_active_time < query2.last_active_time 
  and exists (SELECT 1 from V$SQL_SHARED_CURSOR c where query1.sql_id=c.sql_id and c.use_feedback_stats='Y');