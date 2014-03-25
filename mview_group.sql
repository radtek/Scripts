define mview_name=&mview_namecol NAME format a20
col "TYPE" format a20
col ROWNER format a20
col "REFRESH_GROUP" format a20 
col JOB format 9999999
col "INTERVAL" format a20
col BROKEN format a6
col PARALLELISM format 99999
SELECT NAME, ROWNER, RNAME AS "REFRESH_GROUP", JOB, NEXT_DATE, "INTERVAL", BROKEN, PARALLELISM, "TYPE"
FROM DBA_REFRESH_CHILDREN 
WHERE NAME LIKE UPPER('%&mview_name%')
AND RNAME LIKE UPPER('%&Group_Name%');
undefine mview_name
prompt
prompt Para incluir em um grupo use:
prompt		exec DBMS_REFRESH.ADD('SUAT_REFRESH_GROUP','TRR_TIPO_COBRANCA');
prompt Para excluir em um grupo use (drop remove automatico):
prompt		exec DBMS_REFRESH.SUBTRACT('SUAT_REFRESH_GROUP','TRR_TIPO_COBRANCA');promp