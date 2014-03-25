select 'ORACLE' as tecnologia, (SELECT NAME FROM V$DATABASE) as DBNAME, u.username as owner, round(coalesce(sum(s.bytes)/1024/1024, 0)) MB, tbl.dblinks
from dba_users u
    left join dba_segments s
           on u.username = s.owner
    left join (select owner, 
       "1" ||
       DECODE("2", '-', '', ',' || "2") || 
       DECODE("3", '-', '', ',' || "3") ||
       DECODE("4", '-', '', ',' || "4") ||
       DECODE("5", '-', '', ',' || "5") ||
       DECODE("6", '-', '', ',' || "6") ||
       DECODE("7", '-', '', ',' || "7") ||
       DECODE("8", '-', '', ',' || "8") ||
       DECODE("9", '-', '', ',' || "9") ||
       DECODE("10", '-', '', ',' || "10") as dblinks
from(
select owner, 
	max(case rn  when 1 then username || '@' || host  else '-' end) "1",
	max(case rn when 2 then username || '@' || host else '-' end) "2",
	max(case rn when 3 then username || '@' || host else '-' end) "3",
	max(case rn when 4 then username || '@' || host else '-' end) "4",
	max(case rn when 5 then username || '@' || host else '-' end) "5",
	max(case rn when 6 then username || '@' || host else '-' end) "6",
	max(case rn when 7 then username || '@' || host else '-' end) "7",
	max(case rn when 8 then username || '@' || host else '-' end) "8",
	max(case rn when 9 then username || '@' || host else '-' end) "9",
	max(case rn when 10 then username || '@' || host else '-' end) "10"
from (
select owner, username, host, rownum rn
from dba_db_links
where owner = 'SISCON') tbl
group by owner)) tbl 
	on tbl.owner = u.username
group by u.username, tbl.dblinks
order by MB, u.username
