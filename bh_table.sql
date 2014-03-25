define owner = &owner
define table_name = &table_name
define inst_id = &inst_id

col owner for a20
col object_name for a30
col inst_id for 999

SELECT /*+ leading(objs) */ bh.inst_id, obj.owner, obj.object_name, count(bh.block#) blocks 
from (select /*+ no_merge */ tbl.owner, tbl.table_name
from dba_tables tbl
where table_name like upper('&table_name')
and owner like upper('&owner')
union all
select tbl.owner, tbl.index_name
from dba_indexes tbl
where table_name like upper('&table_name')
and owner like upper('&owner')) objs
inner join dba_objects obj
	on obj.owner = objs.owner 
	and obj.object_name = objs.table_name
inner join gv$bh bh 
	on obj.data_object_id = bh.objd 		
	and (bh.inst_id = &inst_id or &inst_id = 0)
group by bh.inst_id, obj.owner, obj.object_name
order by inst_id, blocks desc
/

undefine table_name 
undefine owner 
undefine inst_id