col sid format 99999

prompt sessão que mais gera redo
select * 
from (SELECT s.sid, s.serial#, s.username, s.program,
i.block_changes
FROM v$session s, v$sess_io i
WHERE s.sid = i.sid
ORDER BY 5 desc) tbl
where rownum < 10;