SELECT 'EXECUTE SYS.dbms_system.set_ev (' || TO_CHAR (sid) ||
          ', ' || TO_CHAR (serial#) || ', 10046, 8, '''');' || chr(13) || chr(10) ||
	'EXECUTE SYS.dbms_system.set_ev (' || TO_CHAR (sid) ||
          ', ' || TO_CHAR (serial#) || ', 10046, 0, '''');'
FROM   v$session
WHERE  username = UPPER('&USERNAME')
and status <> 'KILLED'
order by logon_time;

