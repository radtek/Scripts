ACCEPT 1 PROMPT "Informe tipo[READS,EXECS, CPU]"
COLUMN username FORMAT A15
COLUMN machine FORMAT A25
COLUMN logon_time FORMAT A20

SELECT *
FROM (SELECT NVL(a.username, '(oracle)') AS username,
			   a.osuser,
			   a.sid,
			   a.serial#,
			   c.value AS &1,
			   a.lockwait,
			   a.status,
			   a.module,
			   a.machine,
			   a.program,
			   TO_CHAR(a.logon_Time,'DD-MON-YYYY HH24:MI:SS') AS logon_time
		FROM   v$session a,
			   v$sesstat c,
			   v$statname d
		WHERE  a.sid        = c.sid
		AND    c.statistic# = d.statistic#
		AND    d.name       = DECODE(UPPER('&1'), 'READS', 'session logical reads',
												  'EXECS', 'execute count',
												  'CPU',   'CPU used by this session',
														   'CPU used by this session')
		ORDER BY c.value DESC)
WHERE rownum < 100;

undef 1