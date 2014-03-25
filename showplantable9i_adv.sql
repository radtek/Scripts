prompt necessário hint /*+ gather_plan_statistics */ ou "alter session set statistics_level = all"
prompt 	- A-Rows - corresponde ao numero de rows produzidas  pelo row source
prompt 	- buffers - consistent read blocks
prompt 	- starts - quantas vezes a operação foi processada

SET LINESIZE 2000
SET PAGESIZE 0
prompt executar script para criar plantable: @$ORACLE_HOME/rdbms/admin/utlxplan.sql

SELECT PLAN_TABLE_OUTPUT 
FROM TABLE(DBMS_XPLAN.DISPLAY(null, null, 'advanced'));



SET PAGESIZE 100