select a.owner,
       a.table_name, 
       a.segment_name, 
	a.tablespace_name, 
	a.index_name, 
	a.chunk, 
	a.cache, 
	a.logging, 
	a.in_row, 
	a.compression
from dba_lobs a
where a.owner like upper('&owner')
  and a.table_name like upper('&tablename')
/
