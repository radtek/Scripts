select * 
from 
(SELECT user_name, sid, count(*) ctd_cursores FROM v$open_cursor 
GROUP BY user_name, sid
order by 3 desc)
where rownum <= 10;


select * 
from 
(SELECT user_name, count(*) ctd_cursores FROM v$open_cursor 
GROUP BY user_name
order by 2 desc)
where rownum <= 10;