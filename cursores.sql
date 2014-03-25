select c.hash_value, c.sql_id, c.SQL_TEXT
from v$open_cursor c
      inner join v$session s
	on c.Saddr = C.Saddr
	and c.Sid = s.sid
where s.sid=&sid;