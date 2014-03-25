col sid format 99999

SELECT L.BLOCKER, L.WAITER, l.INST_ID, l.SID, l.TYPE, l.ID1,       l.ID2, l.LMODE, l.REQUEST, l.CTIME, l.BLOCK, w.EVENT, W.WAIT_TIME, W.STATE, 
s.username, s.program,to_char(s.logon_time, 'dd/mm/rrrr hh24:mi'), s.client_identifier, s.sql_hash_value
FROM (
   select  DECODE( l.block, 0, '       ','YES    ') BLOCKER,
           DECODE( l.block, 0, 'YES    ','       ') WAITER,
           l.INST_ID, l.SID, l.TYPE, l.ID1, l.ID2, l.LMODE,        l.REQUEST, l.CTIME, l.BLOCK
   from gv$lock l
   where (ID1,ID2,TYPE) in
         (select ID1,ID2,TYPE from gv$lock where request>0)) L
   left join v$session_wait w
           on w.sid = l.sid
   left join gv$session s
	   on s.sid = w.sid
order by L.BLOCKER;
