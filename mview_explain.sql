prompt lista detalhes da mview e motivo de não fazer refresh fast
prompt REQUISITO:
prompt 		@$ORACLE_HOME/rdbms/admin/utlxmv.sql (SYSTEM)
prompt
define owner=&owner
define mview=&mview

EXECUTE DBMS_MVIEW.EXPLAIN_MVIEW (upper('&owner') || '.' || upper('&mview'));

col CAPABILITY_NAME format a20
col POSSIBLE format a10
col RELATED_TEXT format a30 wrapped
col RELATED_NUM format 999999
col MSGNO format 999999
col MSGTXT format a60 wrapped

select CAPABILITY_NAME,  POSSIBLE, RELATED_TEXT, RELATED_NUM, MSGNO, MSGTXT
FROM MV_CAPABILITIES_TABLE
WHERE MVOWNER = upper('&owner')
AND MVNAME = upper('&mview')
ORDER BY SEQ;

undefine owner
undefine mview