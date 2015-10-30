col WINDOW_NAME for a50
col RESOURCE_PLAN for a50
col name for a50
col value for a50

prompt *** JANELAS ATIVAS
SELECT WINDOW_NAME, RESOURCE_PLAN FROM DBA_SCHEDULER_WINDOWS
WHERE ACTIVE='TRUE';	

prompt 
prompt *** ATIVO
SELECT * FROM V$RSRC_PLAN;

prompt 
prompt *** PARAMETROS 
select name, value from v$parameter where name like '%resource%';