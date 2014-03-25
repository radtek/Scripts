prompt CUIDADO:
prompt 		sql_handle e/ou plan_handle para ser deletado, ideal especificar ambos e deletar 1 por X
prompt 		   - plan_name NULL para todos os planos associados ao sql_handle
prompt 		   - sql_handle NULL para todos os sql_handle associados ao plan_name
prompt 

SET SERVEROUTPUT ON

DECLARE
	l_plans_dropped  PLS_INTEGER;
BEGIN
	l_plans_dropped := dbms_spm.drop_sql_plan_baseline(sql_handle => &sql_handle, plan_name  => &plan_name);
    
		commit;
	  DBMS_OUTPUT.put_line(' ');
	  DBMS_OUTPUT.put_line('Planos removidos: ' || to_char(l_plans_dropped));
END;
/