SELECT dba_tab_partitions.table_owner, dba_tab_partitions.table_name, dba_tab_partitions.high_value, dba_tab_partitions.partition_name, 
dba_tab_partitions.num_rows
from dba_tab_partitions
     inner join (
select table_owner, table_name, MAX(partition_position) as partition_position
from dba_tab_partitions
where table_owner not in ('SYSTEM', 'SYS')
and table_owner like '&table_owner' 
and num_rows > 0
group by table_owner, table_name) tbl 
on tbl.table_owner = dba_tab_partitions.table_owner
and tbl.table_name = dba_tab_partitions.table_name
and tbl.partition_position = dba_tab_partitions.partition_position;