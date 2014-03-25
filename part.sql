col HIGH_VALUE for a90
select table_owner, table_name, partition_name, high_value, tablespace_name, last_analyzed, num_rows
from DBA_TAB_PARTITIONS
where table_name = upper('&TABLE_NAME')
and table_owner like upper('%&Owner%')
order by 3
/
