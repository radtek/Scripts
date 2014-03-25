define table_owner = &table_owner
prompt
prompt
prompt ****** Ultima particao de tabelas particionadas ************
SELECT dba_tab_partitions.table_owner ||'.' ||dba_tab_partitions.table_name ||'.' || dba_tab_partitions.partition_name
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
prompt
prompt
prompt ****** tabelas não particionadas ************
select t.table_name
from dba_tables t
    left join dba_tab_partitions p
	on t.table_name = p.table_name
	and t.owner = p.table_owner
where p.table_name is null
and t.owner = '&table_owner';

undef table_owner