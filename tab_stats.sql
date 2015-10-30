set lines 2000
col table_name format a30
col tablespace_name for a30
select table_name, num_rows, blocks, empty_blocks, chain_cnt, last_analyzed, avg_row_len, partition_name, last_analyzed, stattype_locked, stale_stats, 
(select t.tablespace_name from dba_tables t  where t.table_name = ts.table_name and t.owner=ts.owner) as tablespace_name
from dba_tab_statistics ts
where owner = upper('&owner')
and table_name like upper('&table_name')
order by partition_name
/
