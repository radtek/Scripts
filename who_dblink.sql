-- who is querying via dblink?
-- Courtesy of Tom Kyte, via Mark Bobak
-- this script can be used at both ends of the database link
-- to match up which session on the remote database started
-- the local transaction
-- the GTXID will match for those sessions
-- just run the script on both databases
--
-- Exemplo Origem:
--  	ORIGIN                GTXID                               LSESSION   USERNAME   S WAITING
--  	--------------------- ----------------------------------- ---------- ---------- - ----------
--  	oraserver.-21901      DB1.d6d6d69e.3.16.7190              500.15059  SYSTEM     I SQL*Net me
--
-- Exemplo Destino:
--	    ORIGIN                GTXID                               LSESSION   USERNAME   S WAITING
--  	--------------------- ----------------------------------- ---------- ---------- - ----------
--   	ordevdb01.-21903      DB1.d6d6d69e.3.16.7190             138.28152  SCOTT      I SQL*Net me:
-- 
--->>>>>> Notice that the output from DB1 shows the PID in the ORIGIN column.  In this case it is 21901.


Select /*+ ORDERED */
substr(s.ksusemnm,1,10)||'-'|| substr(s.ksusepid,1,10)      "ORIGIN",
substr(g.K2GTITID_ORA,1,35) "GTXID",
substr(s.indx,1,4)||'.'|| substr(s.ksuseser,1,5) "LSESSION" ,
s2.username,
substr(
   decode(bitand(ksuseidl,11),
      1,'ACTIVE',
      0, decode( bitand(ksuseflg,4096) , 0,'INACTIVE','CACHED'),
      2,'SNIPED',
      3,'SNIPED',
      'KILLED'
   ),1,1
) "S",
substr(w.event,1,10) "WAITING"
from  x$k2gte g, x$ktcxb t, x$ksuse s, v$session_wait w, v$session s2
where  g.K2GTDXCB =t.ktcxbxba
and   g.K2GTDSES=t.ktcxbses
and  s.addr=g.K2GTDSES
and  w.sid=s.indx
and s2.sid = w.sid;