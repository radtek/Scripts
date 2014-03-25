col MACHINE for a30
col OSUSER for a20
col PROGRAM for a50
col USERNAME for a20
col STATUS for a10
col sid format 999999999
col event for a40
prompt ########################## usuarios diferentes do ecommerce ########################## 
select a.sid,a.serial#,b.spid,a.username,last_call_et/60 "Idle - min",w.event, a.sql_hash_value,  osuser,a.machine,a.program,a.status,logon_time,server
from v$session a
   left join v$process b
           on a.paddr = b.addr
   left join v$session_wait w
           on a.sid = w.sid
where a.username not like upper('DIMEDWEB')
  and a.status = 'ACTIVE'
order by "Idle - min" desc, a.username, a.status;


prompt 

prompt ########################## agg by hash ########################## 
select count(1) ctd, sql_hash_value, username
from v$session
where status = 'ACTIVE'
and username is not null
group by username, sql_hash_value
order by username, ctd desc, sql_hash_value;


prompt 
prompt ########################## summario de eventos ########################## 
select w.event, count(1) ctd
from v$session a
   left join v$session_wait w
           on a.sid = w.sid
where a.status = 'ACTIVE'
and a.username is not null
group by w.event
order by ctd desc, w.event;
prompt 
prompt ########################## usuario dimedweb ########################## 
select a.sid,a.serial#,b.spid,a.username,last_call_et/60 "Idle - min",w.event, a.sql_hash_value,  osuser,a.machine,a.program,a.status,logon_time,server
from v$session a
   left join v$process b
           on a.paddr = b.addr
   left join v$session_wait w
           on a.sid = w.sid
where a.username like upper('DIMEDWEB')
  and a.status = 'ACTIVE'
order by "Idle - min" desc, a.username, a.status;


prompt 
prompt ########################## summario sessoes ########################## 
select sum(case when status = 'ACTIVE' and username = 'DIMEDWEB' then 1 else 0 end) active_dimedweb, 
       sum(case when status <> 'ACTIVE' and username = 'DIMEDWEB' then 1 else 0 end) idle_dimedweb,
       sum(case when status = 'ACTIVE' and username <> 'DIMEDWEB' then 1 else 0 end) active_outros,
       sum(case when status <> 'ACTIVE' and username <> 'DIMEDWEB' then 1 else 0 end) idle_outros
from v$session;

prompt ########################## summario blocks ########################## 
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

prompt

