declare 
	tune_task_name  varchar2(30); 
	bad_sql_stmt    clob; 
begin 
	bad_sql_stmt := 'select distinct object_id from object_analysis'; 
	tune_task_name := dbms_sqltune.create_tuning_task 
		(sql_text     => bad_sql_stmt, 
    	   	user_name   => 'RJB', 
		scope       => 'COMPREHENSIVE', 
		time_limit  => 60, 
		task_name   => 'rjb_sql_tuning_task', 
		description => 'See what is wrong with the SELECT' 
		); 
end; 



--- altera
begin 
	dbms_sqltune.set_tuning_task_parameter 
	   (task_name  => 'rjb_sql_tuning_task', 
	    parameter  => 'TIME_LIMIT', value => 30 
	   ); 
end; 


-- executar
begin 
	dbms_sqltune.execute_tuning_task 
	   (task_name => 'rjb_sql_tuning_task'); 
end; 


--monitorar
select task_name, status, sofar, totalwork 
from dba_advisor_tasks 
	join v$advisor_progress using(task_id) 
where task_name = 'rjb_sql_tuning_task'; 



-- retorna recomendações
select 
      dbms_sqltune.report_tuning_task('rjb_sql_tuning_task') 
from dual;