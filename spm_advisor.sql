prompt 
prompt **** Exemplo:
prompt  DBMS_SPM.SET_EVOLVE_TASK_PARAMETER(
prompt    task_name => 'SYS_AUTO_SPM_EVOLVE_TASK'
prompt ,   parameter => 'ACCEPT_PLANS'
prompt ,   value     => 'false'
prompt );
prompt END;
prompt **** 
prompt

COL PARAMETER_NAME FORMAT a25
COL VALUE FORMAT a10
SELECT PARAMETER_NAME, PARAMETER_VALUE AS "VALUE"
FROM   DBA_ADVISOR_PARAMETERS
WHERE  ( (TASK_NAME = 'SYS_AUTO_SPM_EVOLVE_TASK') AND
         ( (PARAMETER_NAME = 'ACCEPT_PLANS') OR
           (PARAMETER_NAME = 'TIME_LIMIT') ) );