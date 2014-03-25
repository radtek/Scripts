define OWNER='&OWNER'
define TABLE_NAME='&TABLE_NAME'

select u.name AS OWNER
	, io.name AS INDEX_NAME
	, t.name AS TABLE_NAME
	, decode(bitand(i.flags, 65536), 0, 'NO', 'YES') MONITORING
	, decode(bitand(ou.flags, 1), 0, 'NO', 'YES') USED
	, ou.start_monitoring START_MONITORING
	, ou.end_monitoring END_MONITORING
from
	sys.user$ u
	, sys.obj$ io
	, sys.obj$ t
	, sys.ind$ i
	, sys.object_usage ou
where
	i.obj# = ou.obj#
	and io.obj# = ou.obj#
	and t.obj# = i.bo#
	and u.user# = io.owner#
	and u.name LIKE UPPER('&OWNER')
	and t.name LIKE UPPER('&TABLE_NAME');

undefine OWNER
undefine TABLE_NAME