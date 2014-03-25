select 	user_process username,
	"Recursive Calls",
	"Execute Count",
	"Opened Cursors",
	"Current Cursors", 
	"session pga memory" / 1024 / 1024 as "session pga memory MB",
	"session uga memory" / 1024 / 1024 as "session uga memory MB"
from  (
	select 	nvl(ss.USERNAME,'ORACLE PROC')||'('||se.sid||') ' user_process, 
			sum(decode(NAME,'execute count',value)) "Execute Count",
			sum(decode(NAME,'recursive calls',value)) "Recursive Calls",
			sum(decode(NAME,'opened cursors cumulative',value)) "Opened Cursors",
			sum(decode(NAME,'opened cursors current',value)) "Current Cursors",
			sum(decode(NAME,'session pga memory',value)) "session pga memory",
			sum(decode(NAME,'session uga memory',value)) "session uga memory"
	from 	v$session ss, 
		v$sesstat se, 
		v$statname sn
	where 	se.STATISTIC# = sn.STATISTIC#
	and 	se.SID = ss.SID
	and 	ss.USERNAME is not null
	group 	by nvl(ss.USERNAME,'ORACLE PROC')||'('||se.SID||') '
	order by "Current Cursors" desc)
orasnap_user_cursors
where rownum < 10
order 	by "Current Cursors" desc, USER_PROCESS
/