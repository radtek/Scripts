define owner=&owner

select COUNT(DISTINCT(acc.CONSTRAINT_NAME)) total_casos_fk_no_index
from   	dba_cons_columns acc, 
	dba_constraints ac
where  	ac.CONSTRAINT_NAME = acc.CONSTRAINT_NAME
and   	ac.CONSTRAINT_TYPE = 'R'
and     acc.OWNER = upper('&owner')
and     acc.OWNER not in ('SYS','SYSTEM')
and     not exists (
        select  'TRUE' 
        from    dba_ind_columns b
        where   b.TABLE_OWNER = acc.OWNER
        and     b.TABLE_NAME = acc.TABLE_NAME
        and     b.COLUMN_NAME = acc.COLUMN_NAME
	and     b.table_OWNER = upper('&owner')
        and     b.COLUMN_POSITION = acc.POSITION);

select 	acc.OWNER,
	acc.CONSTRAINT_NAME,
	acc.COLUMN_NAME,
	acc.POSITION,
	'No Index' Problem
from   	dba_cons_columns acc, 
	dba_constraints ac
where  	ac.CONSTRAINT_NAME = acc.CONSTRAINT_NAME
and   	ac.CONSTRAINT_TYPE = 'R'
and     acc.OWNER = upper('&owner')
and     acc.OWNER not in ('SYS','SYSTEM')
and     not exists (
        select  'TRUE' 
        from    dba_ind_columns b
        where   b.TABLE_OWNER = acc.OWNER
        and     b.TABLE_NAME = acc.TABLE_NAME
        and     b.COLUMN_NAME = acc.COLUMN_NAME
	and     b.table_OWNER = upper('&owner')
        and     b.COLUMN_POSITION = acc.POSITION)
order   by acc.OWNER, acc.CONSTRAINT_NAME, acc.COLUMN_NAME, acc.POSITION;

undef owner