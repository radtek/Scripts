select 	OWNER,
	TABLE_NAME
from 
(
select 	OWNER, 
	TABLE_NAME 
from 	dba_tables
minus
select 	TABLE_OWNER, 
	TABLE_NAME 
from 	dba_indexes
)
orasnap_noindex
where	OWNER not in ('SYS','SYSTEM')
order 	by OWNER,TABLE_NAME;