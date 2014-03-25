define owner = &owner
define tablename = &tablename

break on report
compute sum of data_mb on report
compute sum of indx_mb on report
compute sum of lob_mb on report
compute sum of total_mb on report

select owner, 
	  table_name,
	  decode(partitioned,'/','NO',partitioned) partitioned,
	  num_rows,
	  data_mb,
	  indx_mb,
	  lob_mb,
	  total_mb
from (  select data.owner, 
			   data.table_name,
			   partitioning_type
			   || decode (subpartitioning_type,
						  'none', null,
						  '/' || subpartitioning_type)
					  partitioned,
			   num_rows,
			   nvl(data_mb,0) data_mb,
			   nvl(indx_mb,0) indx_mb,
			   nvl(lob_mb,0) lob_mb,
			   nvl(data_mb,0) + nvl(indx_mb,0) + nvl(lob_mb,0) total_mb
 	    from (select owner, 
					table_name,
					nvl(min(num_rows),0) num_rows,
					round(sum(data_mb),2) data_mb
			 from (select owner,
						 table_name, 
						 num_rows, 
						 data_mb
				  from (select  a.owner,
								a.table_name,
								a.num_rows,
								b.bytes/1024/1024 as data_mb
						from dba_tables a, dba_segments b
						where a.table_name = b.segment_name
						  and a.owner = b.owner
						  and a.owner like upper('&owner')
						  and a.table_name like upper('&tablename')))
			 group by owner,
					  table_name) data,
			(select a.owner,
					a.table_name,
					round(sum(b.bytes/1024/1024),2) as indx_mb
			 from dba_indexes a, dba_segments b
			 where a.index_name = b.segment_name
			   and a.owner = b.owner
			   and a.owner like upper('&owner')
			   and a.table_name like upper('&tablename')
			 group by a.owner, 
					  a.table_name) indx,
			(select a.owner, 
					a.table_name,
					round(sum(b.bytes/1024/1024),2) as lob_mb
			 from dba_lobs a, dba_segments b
			 where a.segment_name = b.segment_name
			   and a.owner = b.owner
			   and a.owner like upper('&owner')
			   and a.table_name like upper('&tablename')
			  group by a.owner, 
					   a.table_name) lob,				   
			dba_part_tables part
 	    where     data.table_name = indx.table_name(+)
		 	  and data.owner = indx.owner(+)
			  and data.table_name = lob.table_name(+)
			  and data.owner = lob.owner(+)
			  and data.table_name = part.table_name(+)
			  and data.owner = part.owner(+)
	)
order by owner, 
		 table_name;

		 
undefine owner 		 
undefine tablename