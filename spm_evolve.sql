prompt 
prompt informe o sql_handle que ser� analisado, se NULL todos s�o avaliados
prompt informe o plan_name que ser� analisado, se NULL todos s�o avaliados
prompt informe commit = 'YES' se quer marcar como aceit�vel o melhor plano ou commit='NO' se quer apenas um report
prompt informe verify = 'YES' se quer validar a performance dos planos e verify = 'NO' se n�o � necess�rio
prompt informe o timelimit DBMS_SPM.AUTO_LIMIT ou DBMS_SPM.NO_LIMIT ou inteiro e minutos
prompt 

SET SERVEROUTPUT ON
SET LONG 10000
 DECLARE
	 report clob;
 BEGIN
	 report := DBMS_SPM.EVOLVE_SQL_PLAN_BASELINE(
		 sql_handle => &sql_handle, plan_name => &plan_name, time_limit => &time, verify=> '&verify', commit=> '&commit');
	
	 DBMS_OUTPUT.PUT_LINE(report);
 END;
 /