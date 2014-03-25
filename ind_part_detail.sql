set long 99999
column high_value format a15 
column distinct_keys format 99999999
column table_owner format a15
column table_name format a15
column tablespace_name format a30
column partition_name format a30
column COLUMN_NAME format a30

select tp.index_owner, tp.index_name, tp.num_rows, tp.distinct_keys, round(tp.LEAF_BLOCKS * (select block_size from dba_tablespaces where tablespace_name = tp.tablespace_name) / 1024 / 1024 ) as LFBLK_sizeMB, tp.tablespace_name, tp.partition_position, tp.high_value, tp.partition_name, 
--	DECODE((select 1
--			from dba_ind_partitions tb_TMP
--				 inner join dba_indexes ind2
--					on ind2.owner = tb_TMP.index_owner
--					and ind2.index_name = tb_TMP.index_name		
--				 inner join dba_data_files df_TMP
--					on df_TMP.tablespace_name = tb_TMP.tablespace_name
--			where df_TMP.online_status =  'OFFLINE'
--			  and ind2.TABLE_NAME = ind.TABLE_NAME
--			  and ind2.TABLE_owner = ind.TABLE_OWNER
--			  and ind2.owner = ind.owner
--			  and ind2.index_name = ind.index_name
--			  and tb_TMP.partition_position = tp.partition_position
--			  and tb_TMP.partition_name = tp.partition_name
--			  and tb_TMP.TABLESPACE_NAME = tp.TABLESPACE_NAME
--			  and rownum = 1), 1, 'YES', 'NO') AS OFF_LINE, 
		(select xmlagg(xmlelement("teste", column_name || ',')).extract('//text()') from DBA_PART_KEY_COLUMNS where owner = ind.OWNER and NAME = ind.INDEX_NAME and OBJECT_TYPE = 'INDEX') AS COLUMN_NAME
from dba_ind_partitions tp
	inner join dba_indexes ind
		on ind.owner = tp.index_owner
		and ind.index_name = tp.index_name		
where upper(ind.index_name) =  upper('&index_name')
order by 1,2, partition_position ;