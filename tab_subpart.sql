select partition_name, subpartition_name, high_value, subpartition_position, tablespace_name, num_rows, blocks,LAST_ANALYZED, 
	(select xmlagg(xmlelement("teste", column_name || ',')).extract('//text()') from DBA_SUBPART_KEY_COLUMNS where owner = sp.TABLE_OWNER and NAME = sp.table_name AND OBJECT_TYPE = 'TABLE') AS COLUMN_NAME
from dba_tab_subpartitions sp where partition_name like upper('&PARTITION_NAME') and table_name = upper('&TABLE_NAME') and table_owner = upper('&OWNER');