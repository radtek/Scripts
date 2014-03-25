define owner =&owner
define object=&object


select a.sid,b.osuser,b.username,b.machine, b.program, b.status, a.type,d.name||'.'||c.name name,a.id1,a.id2,
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
and d.name like upper('&owner')
and c.name like upper('&object')
order by 2,1;



select o.owner, o.object_name, lo.SESSION_ID, lo.ORACLE_USERNAME, lo.OS_USER_NAME, lo.PROCESS, 
decode(lo.LOCKED_MODE, 0, 'none',
1, 'null (NULL)',
2, 'row-S (SS)',
3, 'row-X (SX)',
4, 'share (S)',
5, 'S/Row-X (SSX)',
6, 'exclusive (X)', null)
from V$LOCKED_OBJECT lo
	inner join dba_objects o
		on o.object_id = lo.object_id
where o.owner like upper('&owner')
  and o.object_name like upper('&object')
order by 1, 2;


undefine owner 
undefine object