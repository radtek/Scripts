COL "Timestamp" FORMAT a17;
COL "Logoff" FORMAT a17;
COL "UNIX ID" FORMAT a7;
COL "DB User" FORMAT a7;
COL "Client ID" FORMAT a15;
COL "Action" FORMAT a17;
COL "Priv/Error" FORMAT a17;
COL "User" FORMAT a13;
COL "Privilege" FORMAT a20;

SELECT user_name "User", privilege "Privilege", success,
failure FROM dba_priv_audit_opts
where rownum <= 100
	
SELECT user_name "User", audit_option "Privilege", success,
failure FROM dba_stmt_audit_opts
where rownum <= 100;

SELECT TO_CHAR(timestamp, 'MM/DD/YYYY HH24:MI') "Timestamp",
TO_CHAR(logoff_time, 'MM/DD/YYYY HH24:MI') "Logoff",
os_username "UNIX ID", username "DB User",
client_id "Client ID",
CASE WHEN action_name = 'SELECT'
THEN action_name || ' (' || obj_name || ')'
ELSE action_name END "Action",
CASE WHEN returncode=0 THEN priv_used ELSE '*ORA-' ||
returncode || '*' END "Priv/Error", 
terminal
FROM sys.dba_audit_trail 
where rownum <= 100
ORDER BY timestamp;
