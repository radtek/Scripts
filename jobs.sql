col program_name col a30

 select owner, job_name,enabled, 
   to_char(next_run_date,'dd-mm-yy hh24:mi:ss'),run_count, 
   program_name, stop_on_window_close, job_priority   
 from dba_scheduler_jobs
where job_name='&job_name'; 

-- verificar status do job
SELECT JOB_NAME, STATE 
FROM DBA_SCHEDULER_JOBS
where job_name='&job_name';

prompt failed verificar dba_scheduler_details
prompt broken estourou max_failures, verificar dba_SCHEDULER_JOB_LOG
prompt disabled job, class, scheduler, program foi desabilitado ou removido
prompt completed end_date ou max_runs foi atingido
prompt scheduled executou e está agendado novamente

select * 
from user_scheduler_job_run_details 
where job_name='&job_name';


select job_name,log_date,status from dba_scheduler_job_log
where job_name='&job_name';


--> nao atualizar informações de duration, e retorna o output, se use_current_session=false colocar em background e atualiza informações
exec dbms_scheduler.run_job(job_name=>'job_name', use_current_session=true);


-> criar um job em outro schema:
	BEGIN
	DBMS_SCHEDULER.CREATE_JOB (
	   job_name           =>  'sales.update_sales',
	   job_type           =>  'STORED_PROCEDURE',
	   job_action         =>  'OPS.SALES_PKG.UPDATE_SALES_SUMMARY',
	   start_date         =>  '28-APR-08 07.00.00 PM Australia/Sydney',
	   repeat_interval    =>  'FREQ=DAILY;INTERVAL=2', /* every other day */
	   end_date           =>  '20-NOV-08 07.00.00 PM Australia/Sydney',
	   job_class          =>  'batch_update_jobs',
	   comments           =>  'My new job');
	END;
	/
	-> job creator é quem cria o job e não precisa ser o job owner que é qual o contexto o job vai executar