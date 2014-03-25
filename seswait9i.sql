col sid for 9999
col username for a15
col osuser for a15
col machine for a28
col event for a50 wrapped
col p1text for a9
col p2text for a9
col p3text for a9
--col p1 for 9999999999
--col p2 for 9999999999
--col p3 for 9999999999
col seconds_in_wait for 99999999 heading (s)
col client_identifier format a15
col logon_time format a20
col program format a20

select /*+ rule */ 
       s.sid,s.username,s.osuser, s.machine, s.sql_hash_value,w.seconds_in_wait as "SEC WAIT",w.event,substr(w.p1text,1,9) p1text,w.p1,
       w.p2text,w.p2,w.p3text,w.p3,s.logon_time,s.program,to_char(s.logon_time, 'dd/mm/rrrr hh24:mi') logon_time, 
	s.client_identifier,last_call_et/60 "Idle - min", 
	sysdate - (w.seconds_in_wait / 60 / 24) waiting_since
from v$session s, v$session_wait w
where s.sid = w.sid and
      w.event <> 'SQL*Net message from client' and
      w.event <> 'Null event' and
      w.event <> 'null event' and
      w.event <> 'rdbms ipc message' and
      w.event <> 'pmon timer' and
      w.event <> 'smon timer' and
--      w.event <> 'SQL*Net message to client' and
      w.event <> 'pipe get' and 
      w.event <> 'jobq slave wait' 
and w.event <> 'ARCH random i/o'
and w.event <> 'ARCH sequential i/o'
and w.event <> 'KXFX: execution message dequeue - Slaves'
and w.event <> 'LGWR random i/o'
and w.event <> 'LGWR sequential i/o'
and w.event <> 'LGWR wait for redo copy'
and w.event <> 'Null event'
and w.event <> 'PL/SQL lock timer'
and w.event <> 'PX Deq Credit: need buffer'
and w.event <> 'PX Deq: Execute Reply'
and w.event <> 'PX Deq: Execution Msg'
and w.event <> 'PX Deq: Index Merge Close'
and w.event <> 'PX Deq: Index Merge Execute'
and w.event <> 'PX Deq: Index Merge Reply'
and w.event <> 'PX Deq: Join ACK'
and w.event <> 'PX Deq: Msg Fragment'
and w.event <> 'PX Deq: Par Recov Change Vector'
and w.event <> 'PX Deq: Par Recov Execute'
and w.event <> 'PX Deq: Par Recov Reply'
and w.event <> 'PX Deq: Parse Reply'
and w.event <> 'PX Deq: Table Q Normal'
and w.event <> 'PX Deq: Table Q Sample'
and w.event <> 'PX Deq: Txn Recovery Reply'
and w.event <> 'PX Deq: Txn Recovery Start'
and w.event <> 'PX Deque wait'
and w.event <> 'PX Idle Wait'
and w.event <> 'Queue Monitor Shutdown Wait'
and w.event <> 'Queue Monitor Slave Wait'
and w.event <> 'Queue Monitor Wait'
and w.event <> 'RFS random i/o'
and w.event <> 'RFS sequential i/o'
and w.event <> 'RFS write'
and w.event <> 'SQL*Net message from client'
and w.event <> 'SQL*Net message from dblink'
and w.event <> 'STREAMS apply coord waiting for slave message'
and w.event <> 'STREAMS apply coord waiting for some work to finish'
and w.event <> 'STREAMS apply slave idle wait'
and w.event <> 'STREAMS capture process filter callback wait for ruleset'
and w.event <> 'STREAMS fetch slave waiting for txns'
and w.event <> 'WMON goes to sleep'
and w.event <> 'async disk IO'
and w.event <> 'client message'
and w.event <> 'control file parallel write'
and w.event <> 'control file sequential read'
and w.event <> 'control file single write'
and w.event <> 'db file single write'
and w.event <> 'db file parallel write'
and w.event <> 'dispatcher timer'
and w.event <> 'gcs log flush sync'
and w.event <> 'gcs remote message'
and w.event <> 'ges reconfiguration to start'
and w.event <> 'ges remote message'
and w.event <> 'io done'
and w.event <> 'jobq slave wait'
and w.event <> 'lock manager wait for remote message'
and w.event <> 'log file parallel write'
and w.event <> 'log file sequential read'
and w.event <> 'log file single write'
and w.event <> 'parallel dequeue wait'
and w.event <> 'parallel recovery coordinator waits for cleanup of slaves'
and w.event <> 'parallel query dequeue'
and w.event <> 'parallel query idle wait - Slaves'
and w.event <> 'pipe get'
and w.event <> 'pmon timer'
and w.event <> 'queue messages'
and w.event <> 'rdbms ipc message'
and w.event <> 'recovery read'
and w.event <> 'single-task message'
and w.event <> 'slave wait'
and w.event <> 'smon timer'
and w.event <> 'statement suspended, wait error to be cleared'
and w.event <> 'unread message'
and w.event <> 'virtual circuit'
and w.event <> 'virtual circuit status'
and w.event <> 'wait for activate message'
and w.event <> 'wait for transaction'
and w.event <> 'wait for unread message on broadcast channel'
and w.event <> 'wait for unread message on multiple broadcast channels'
and w.event <> 'wakeup event for builder'
and w.event <> 'wakeup event for preparer'
and w.event <> 'wakeup event for reader'
and w.event <> 'wakeup time manager' and
      1=1
order by s.sql_hash_value;