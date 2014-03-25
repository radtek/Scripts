set long 9999
select table_owner, table_name, sum(num_rows) as num_rows, round(sum(blocks / 1024)) as sizeMB
from dba_tab_partitions
where table_owner not in ('SYSTEM', 'SYS')
and table_name like '&tablename'
and table_owner like '&tableowner'
group by table_owner, table_name
order by 1,2;