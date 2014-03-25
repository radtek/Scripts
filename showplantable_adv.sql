prompt somente no 10g para demostra conjunto de hints
prompt 
SET LINESIZE 2000
SET PAGESIZE 0

prompt executar script para criar plantable: @$ORACLE_HOME/rdbms/admin/utlxplan.sql
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, NULL, 'ADVANCED'));


SET PAGESIZE 100