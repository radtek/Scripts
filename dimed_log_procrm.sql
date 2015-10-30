prompt no detalhe
break on data_do_processamento skip 1
compute sum of elapsed_sec on data_do_processamento
select data_do_processamento, 
       step,
	hora_da_execucao,
	LAG(hora_da_execucao, 1, hora_da_execucao) OVER (PARTITION BY data_do_processamento  ORDER BY data_do_processamento, hora_da_execucao, step) hora_da_execucao_ant,
       (hora_da_execucao - LAG(hora_da_execucao, 1, hora_da_execucao) OVER (PARTITION BY data_do_processamento  ORDER BY data_do_processamento, hora_da_execucao, step)) * 24 * 60 * 60 as elapsed_sec       
from
	(select data_do_processamento, 
			to_number(substr(descricao_do_log,instr('PRC_CRM_PROC_CUBO_FID_CRM', descricao_do_log) + 29, 3)) as step,
			max(hora_da_execucao) as hora_da_execucao
	from crm_logs_de_processamento 
	where identificador_do_sistema = 'CUBOFID' 
	  and descricao_do_log like '%PRC_CRM_PROC_CUBO_FID_CRM%'
	  and data_do_processamento = to_date('08/07/2015', 'dd/mm/yyyy')
	group by data_do_processamento, 
			 to_number(substr(descricao_do_log,instr('PRC_CRM_PROC_CUBO_FID_CRM', descricao_do_log) + 29, 3)) 
	) 
order by data_do_processamento, hora_da_execucao, step
/



prompt sumario
select to_char(data_do_processamento, 'dd/mm/yyyy') data_processamento,
	   to_char(sum(elapsed_sec), '999,999,999,999') as sum_elapsed_sec
from (	   
select data_do_processamento, 
       step,
	   hora_da_execucao,
	   LAG(hora_da_execucao, 1, hora_da_execucao) OVER (PARTITION BY data_do_processamento  ORDER BY data_do_processamento, hora_da_execucao, step) hora_da_execucao_ant,
       (hora_da_execucao - LAG(hora_da_execucao, 1, hora_da_execucao) OVER (PARTITION BY data_do_processamento  ORDER BY data_do_processamento, hora_da_execucao, step)) * 24 * 60 * 60 as elapsed_sec       
from
	(select data_do_processamento, 
			to_number(substr(descricao_do_log,instr('PRC_CRM_PROC_CUBO_FID_CRM', descricao_do_log) + 29, 3)) as step,
			max(hora_da_execucao) as hora_da_execucao
	from crm_logs_de_processamento
	where identificador_do_sistema = 'CUBOFID' 
	  and descricao_do_log like '%PRC_CRM_PROC_CUBO_FID_CRM%'
	  and data_do_processamento > sysdate - 1000 
	group by data_do_processamento, 
			 to_number(substr(descricao_do_log,instr('PRC_CRM_PROC_CUBO_FID_CRM', descricao_do_log) + 29, 3)) 
	)			  
order by data_do_processamento, hora_da_execucao, step)
group by data_do_processamento
order by data_do_processamento
/
