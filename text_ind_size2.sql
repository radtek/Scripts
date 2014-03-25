COL table_name format A30;
COL ind_nm format A30;
COL KB 9999999999;

select table_name, x.index_name, sum(KB) KB from 
(select substr(table_name, 4, instr(table_name, '$', -1)-4) index_name,
sum(bytes)/1024 KB
from dba_tables t, dba_segments s
where t.table_name = s.segment_name 
  and t.table_name like 'DR$%$%'
  and s.owner = t.owner
  and t.owner like '%&owner%'
group by substr(table_name, 4, instr(table_name, '$', -1)-4) 
union
select substr(table_name, 4, instr(table_name, '$', -1)-4) index_name,
sum(bytes)/1024 KB 
from dba_indexes i, dba_segments s
where i.index_name = s.segment_name and i.table_name like 'DR$%$%'
and i.owner = s.owner
and i.owner like '%&owner%'
group by substr(table_name, 4, instr(table_name, '$', -1)-4)
) x, user_indexes ind
where x.index_name = ind.index_name
group by table_Name, x.index_name
order by table_name, x.index_name;
