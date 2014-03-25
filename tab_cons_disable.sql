set lines 100 pages 999
col discon format a100 
select 'alter table '||a.owner||'.'||a.table_name||' disable constraint
'||a.constraint_name||';' discon
from	dba_constraints a
,	dba_constraints b
where	a.constraint_type = 'R'
and 	a.r_constraint_name = b.constraint_name
and	a.r_owner  = b.owner
and 	b.owner = upper('&table_owner')
and	b.table_name = upper('&table_name');