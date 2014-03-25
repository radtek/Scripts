col sid for 9999999
col username for a14
col event for a50
col machine for a50
col p1text for a15
col p2text for a20
col p3text for a15
col p1 for 99999999
col p2 for 99999999
col p3 for 999999999
col seconds_in_wait for 99999999 heading "seg|wait"
col client_identifier format a15
col logon_time format a15
col program format a20

select /*+ rule */ 
       s.INST_ID, s.sid, s.username, w.seconds_in_wait as "SEC WAIT", w.event, s.sql_hash_value,s.sql_id, s.prev_sql_id, 
	s.program, s.machine, to_char(s.logon_time, 'dd/mm/rrrr hh24:mi') as logon_time, 
	s.client_identifier, s.sql_child_number, 
	sysdate - (w.seconds_in_wait / 60 / 24) waiting_since, STATUS, server, 
	s.BLOCKING_SESSION_STATUS,
	s.BLOCKING_INSTANCE,
	s.BLOCKING_SESSION,
	service_name, 
	substr(w.p1text,1,9) p1text, w.p1,
	w.p2text,w.p2,w.p3text,w.p3, s.RESOURCE_CONSUMER_GROUP
from gv$session s, gv$session_wait w, (select /*+ no_merge */ BLOCKING_SESSION,BLOCKING_INSTANCE from gv$session where BLOCKING_SESSION is not null) tbl
where s.sid = w.sid and
      s.inst_id = w.inst_id and 
      s.sid = tbl.blocking_session (+) and 
      s.inst_id = tbl.blocking_instance (+) and 
      (s.WAIT_CLASS <> 'Idle' or tbl.blocking_session is not null)
order by s.sql_hash_value,s.sid;