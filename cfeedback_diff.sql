select  query1.sql_id,
		query1.plan_hash_value phv1,
		query2.plan_hash_value phv2, 
		query1.executions exec1,
		query2.executions exec2,
		trunc((query1.avg_elapsed_time)/1000000,2) AVG_ELA_SEC1,
		trunc(( query2.avg_elapsed_time)/1000000,2) AVG_ELA_SEC2,
		trunc(( query1.avg_elapsed_time - query2.avg_elapsed_time)/1000000,2) AVG_ELA_DIFF,		
		abs(trunc(((query1.avg_elapsed_time - query2.avg_elapsed_time) * query2.executions)/1000000,2)) ABS_ELA_TOT_DIFF,
		    trunc(((query1.avg_elapsed_time - query2.avg_elapsed_time) * query2.executions)/1000000,2)      ELA_TOT_DIFF,
		    trunc(((query1.avg_elapsed_time - query2.avg_elapsed_time) / query1.avg_elapsed_time) * 100,1) ELA_CARD_PERC_DIFF,
		trunc(query1.avg_buffer_gets) AVG_BGETS1,
		trunc(query2.avg_buffer_gets) AVG_BGETS2,		
		abs(trunc(((query1.avg_buffer_gets - query2.avg_buffer_gets) * query2.executions),2)) ABS_BGETS_TOT_DIFF,
		    trunc(((query1.avg_buffer_gets - query2.avg_buffer_gets) * query2.executions),2)      BGETS_TOT_DIFF,
		    trunc(((query1.avg_buffer_gets - query2.avg_buffer_gets) / query1.avg_buffer_gets) * 100,1) BGETS_CARD_PERC_DIFF,	
		substr(query1.sql_text, 1, 100) as sql_text
from 
		(select 
			sql_id,plan_hash_value,last_active_time,executions,(rows_processed/executions) avg_rows_processed,
			(elapsed_time/executions) avg_elapsed_time,(cpu_time/executions) avg_cpu_time,(buffer_gets/executions) avg_buffer_gets,
			sql_text 
		 from V$SQLSTATS_PLAN_HASH a
		 where exists (select plan_hash_value  from V$SQLSTATS_PLAN_HASH b  where a.sql_id=b.sql_id and a.plan_hash_value <> b.plan_hash_value and executions > 0) -- tem mais de 1 plano
		   and executions > 0
		 order by sql_id,last_active_time) query1,
		(select 
			sql_id,plan_hash_value,last_active_time,executions,(rows_processed/executions) avg_rows_processed,
			(elapsed_time/executions) avg_elapsed_time,(cpu_time/executions) avg_cpu_time,(buffer_gets/executions) avg_buffer_gets,
			sql_text 
		 from V$SQLSTATS_PLAN_HASH a
		 where exists (select plan_hash_value  from V$SQLSTATS_PLAN_HASH b  where a.sql_id=b.sql_id and a.plan_hash_value <> b.plan_hash_value and executions > 0) -- tem mais de 1 plano
		   and executions > 0
		 order by sql_id,last_active_time) query2 -- 
where query1.sql_id=query2.sql_id
  and query1.last_active_time < query2.last_active_time -- query1 gerou feedbackstats para a execução do segundo plano, senão não faz sentido
  and exists (select 1 from V$SQL_SHARED_CURSOR c where query1.sql_id=c.sql_id and c.use_feedback_stats='Y') -- query1, plano que gerou feedback stats para o proximo plano
--and query1.avg_elapsed_time < query2.avg_elapsed_time
order by ABS_ELA_TOT_DIFF desc;