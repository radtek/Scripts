SELECT *
FROM (SELECT NVL(a.username, '(oracle)') AS username,
			   a.osuser,
			   a.sid,
			   a.serial#,
			   c.value as "db_block_changes",
			   a.lockwait,
			   a.status,
			   a.program,
			   TO_CHAR(a.logon_Time,'DD-MON-YYYY HH24:MI:SS') AS logon_time
		FROM   v$session a,
			   v$sesstat c,
			   v$statname d
		WHERE  a.sid        = c.sid
		AND    c.statistic# = d.statistic#
		AND    d.name       = 'db block changes'
		ORDER BY c.value DESC) tbl
WHERE rownum < 10;