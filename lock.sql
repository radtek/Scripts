col sid format 999999
prompt informe 0 para todos
prompt 
define sid=&sid

select a.sid,b.osuser,b.username,a.type,d.name||'.'||c.name name,a.id1,a.id2,
	decode(lmode,1,'null',2,'RS',3,'RX',4,'S',5,'SRX',6,'X',0,'NONE',lmode) lmode,
	decode(request,1,'null',2,'RS',3,'RX',4,'S',5,'SRX',6,'X',0,'NONE',request) request
from v$lock a
	 INNER JOIN v$session b
		ON a.sid = b.sid
	 LEFT JOIN sys.obj$ c
		ON a.id1 = c.OBJ#
	 LEFT JOIN sys.user$ d
		ON c.owner# = d.user#
where b.username is not null
and ((a.sid = &sid) or (&sid = 0))
order by 2,1;

undef sid