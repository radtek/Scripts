set long 99999
column high_value format a15 
column table_owner format a15
column table_name format a15
column tablespace_name format a30
column partition_name format a30
column COLUMN_NAME format a30

select table_owner, table_name, num_rows, blocks, round(blocks * (select block_size from dba_tablespaces where tablespace_name = tp.tablespace_name) / 1024 / 1024 ) as sizeMB, tablespace_name, partition_position, high_value, partition_name, 
	DECODE((select 1
			from dba_tab_partitions tb_TMP
				 inner join dba_data_files df_TMP
					on df_TMP.tablespace_name = tb_TMP.tablespace_name
			where df_TMP.online_status =  'OFFLINE'
			  and tb_TMP.TABLE_NAME = tp.TABLE_NAME
			  and tb_TMP.TABLE_owner = tp.TABLE_OWNER
			  and tb_TMP.partition_position = tp.partition_position
			  and tb_TMP.partition_name = tp.partition_name
			  and tb_TMP.TABLESPACE_NAME = tp.TABLESPACE_NAME
			  and rownum = 1), 1, 'YES', 'NO') AS OFF_LINE, 
		(select xmlagg(xmlelement("teste", column_name || ',')).extract('//text()') from DBA_PART_KEY_COLUMNS where owner = tp.TABLE_OWNER and NAME = tp.TABLE_NAME AND OBJECT_TYPE = 'TABLE') AS COLUMN_NAME, 
	tp.subpartition_count
from dba_tab_partitions tp
where table_owner not in ('SYSTEM', 'SYS')
and upper(table_name) like upper('&tablename')
and upper(table_owner) like upper('&tableowner')
order by 1,2, partition_position ;




