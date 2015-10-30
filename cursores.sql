select distinct sql_id, sql_text
from v$sql 
where users_executing > 0
and sql_id in (
select c.sql_id
from v$open_cursor c
      inner join v$session s
	on c.Saddr = C.Saddr
	and c.Sid = s.sid
where s.sid=&sid);