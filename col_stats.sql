col low_value format a30
col high_value format a30
col column_name format a30

select column_name, num_distinct, low_value, high_value, density, num_nulls, last_analyzed, avg_col_len, histogram
from dba_tab_col_statistics
where owner = UPPER('&OWNER')
and table_name like UPPER('&TABLE_NAME')
and column_name like UPPER('&COLUMN_NAME')
order by column_name;