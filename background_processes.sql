select sid, program, EVENT, BLOCKING_SESSION, sql_id from v$session where type = 'BACKGROUND'
order by sid
/
