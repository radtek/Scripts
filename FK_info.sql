prompt "%" para todos
prompt 

col OWNER format a20
col TABLE_NAME format a30
col CONSTRAINT_NAME format a30
col COLUMN_NAME format a20
col TABLE_NAME format a30
col COLUMN_NAME format a20
col POSITION format 99999

select 	c.OWNER,
	c.TABLE_NAME,
	c.CONSTRAINT_NAME,
	cc.COLUMN_NAME,
	r.TABLE_NAME,
	rc.COLUMN_NAME,
	cc.POSITION
from 	dba_constraints c, 
	dba_constraints r, 
	dba_cons_columns cc, 
	dba_cons_columns rc
where 	c.CONSTRAINT_TYPE = 'R'
and 	c.OWNER not in ('SYS','SYSTEM')
and 	c.R_OWNER = r.OWNER
and 	c.R_CONSTRAINT_NAME = r.CONSTRAINT_NAME
and 	c.CONSTRAINT_NAME = cc.CONSTRAINT_NAME
and 	c.OWNER = cc.OWNER
and 	r.CONSTRAINT_NAME = rc.CONSTRAINT_NAME
and 	r.OWNER = rc.OWNER
and 	cc.POSITION = rc.POSITION
and 	c.owner like upper('&OWNER')
and 	c.TABLE_NAME like upper('&TABLENAME')
order 	by c.OWNER, c.TABLE_NAME, c.CONSTRAINT_NAME, cc.POSITION;