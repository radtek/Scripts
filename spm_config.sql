prompt 
prompt -> para alterar:
prompt 	BEGIN
prompt 		  DBMS_SPM.configure('space_budget_percent', 11); -- entre 1 e 50 percentual da sysuax que pode ser usado
prompt 		  DBMS_SPM.configure('plan_retention_weeks', 54); -- entre 5 e 523 weeks que os planos podem ser mantidos
prompt 	END;
prompt
prompt
SELECT parameter_name, parameter_value
FROM   dba_sql_management_config;