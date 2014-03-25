col sid for 99999999
prompt top 10 agrupados por inst, sid, user
select * 
from 
(SELECT inst_id, user_name, sid, count(*) ctd_cursores 
FROM gv$open_cursor 
GROUP BY inst_id, user_name, sid
order by 4 desc)
where rownum <= 10
order by 1, 4 desc;

prompt top 10 agrupados por inst, user
select * 
from 
(SELECT inst_id, user_name, count(*) ctd_cursores 
FROM gv$open_cursor 
GROUP BY inst_id, user_name
order by 3 desc)
where rownum <= 10
order by 1, 3 desc;