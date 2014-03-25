col type format a10
col cons_name format a30
select	decode(constraint_type,
		'C', 'Check',
		'O', 'R/O View',
		'P', 'Primary',
		'R', 'Foreign',
		'U', 'Unique',
		'V', 'Check view') type
,	constraint_name cons_name
,	status
,	last_change
,SEARCH_CONDITION
from	dba_constraints
where	owner like upper('&owner')
and	table_name like upper('&table_name')
order by 1;
