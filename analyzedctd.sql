select	OWNER,
	sum(decode(nvl(NUM_ROWS,9999), 9999,0,1)) analyzed,
	sum(decode(nvl(NUM_ROWS,9999), 9999,1,0)) not_analyzed,
	count(TABLE_NAME) total
from 	dba_tables
where 	OWNER not in ('SYS', 'SYSTEM')
group 	by OWNER

