select sn.name, ss.value
from v$sesstat ss
	inner join v$statname sn
		on ss.STATISTIC# = sn.STATISTIC#
where sid=&sid
and sn.name like '&name'
order by value;