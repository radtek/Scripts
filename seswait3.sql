
accept sid number prompt "informe o sid ou 0 para todos:" default 0
accept inst_id number prompt "informe o inst_id ou 0 para todos:" default 0


col sid for 9999
col username for a14
col event for a60
col p1text for a9
col p2text for a9
col p3text for a9
col p1 for 999999
col p2 for 999999
col p3 for 999999
col OSPID for a9
col seconds_in_wait for 99999999 heading (s)
col sql_text format a100
col client_identifier format a15
col logon_time format a15
col program format a20

select /*+ rule */ 
       proc.spid OSPID, s.INST_ID, s.sid,s.username,s.logon_time,w.seconds_in_wait as "SEC WAIT",w.event,substr(w.p1text,1,9) p1text,w.p1,
       w.p2text,w.p2,w.p3text,w.p3,s.sql_hash_value,s.program,to_char(s.logon_time, 'dd/mm/rrrr hh24:mi') as logon_time, 
       sql.sql_text, 
		s.client_identifier, s.sql_id, s.sql_child_number, 
		sysdate as "SYSDATE",
		sysdate - (w.seconds_in_wait / 60 / 24) waiting_since,         
	s.BLOCKING_SESSION,
	s.BLOCKING_INSTANCE	
from gv$session s
     INNER JOIN gv$session_wait w  
		ON s.sid = w.sid
		and s.inst_id = w.inst_id
     LEFT JOIN V$sql sql
		on sql.hash_value = s.sql_hash_value		
	 LEFT JOIN gV$process proc
		ON proc.addr = s.paddr
		AND proc.inst_id = s.INST_ID
where w.event <> 'SQL*Net message from client' and
      w.event <> 'Null event' and
      w.event <> 'null event' and
      w.event <> 'rdbms ipc message' and
      w.event <> 'pmon timer' and
      w.event <> 'smon timer' and
--      w.event <> 'SQL*Net message to client' and
      w.event <> 'pipe get' and 
      w.event <> 'jobq slave wait' and
      (s.sid = &&sid or &&sid = 0) and 
	  (s.INST_ID = &&inst_id or &&inst_id = 0)	  
order by s.sql_hash_value,s.sid;

undef sid
undef inst_id