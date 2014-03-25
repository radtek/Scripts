col machine format a25
col program format a20

prompt Blockers
SELECT  c.spid, 
	b.sid, 
	decode(b.username, null, 'ora_' ||substr(b.program, instr(b.program, '('), 4),b.username) as username, 
	b.machine, 
	b.program, 
        b.sql_id, 
        b.prev_sql_id, 
        b.blocking_session
FROM v$session b
     INNER JOIN v$process c
	ON c.addr = b.paddr
WHERE EXISTS (SELECT 1 FROM v$session d WHERE b.sid = d.blocking_session)
order by b.sql_hash_value, b.sid;
