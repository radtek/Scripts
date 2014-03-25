break on report
COLUMN sid                     FORMAT 99999            HEADING 'SID'
COLUMN oracle_username         FORMAT a12            HEADING 'Oracle User'     JUSTIFY right
COLUMN os_username             FORMAT a9             HEADING 'O/S User'        JUSTIFY right
COLUMN session_program         FORMAT a18            HEADING 'Session Program' TRUNC
COLUMN session_machine         FORMAT a8             HEADING 'Machine'         JUSTIFY right TRUNC
COLUMN session_pga_memory_KB      FORMAT 9,999,999,999  HEADING 'PGA Memory_KB'
COLUMN session_pga_memory_max_KB  FORMAT 9,999,999,999  HEADING 'PGA Memory Max_KB'
COLUMN session_uga_memory_KB      FORMAT 9,999,999,999  HEADING 'UGA Memory_KB'
COLUMN session_uga_memory_max_KB  FORMAT 9,999,999,999  HEADING 'UGA Memory MAX_KB'
compute sum of session_uga_memory_KB on report
compute sum of session_uga_memory_max_KB on report
compute sum of session_pga_memory_KB on report
compute sum of session_pga_memory_max_KB on report
SELECT
    s.sid                sid
  , lpad(s.username,12)  oracle_username
  , lpad(s.osuser,9)     os_username
  , s.program            session_program
  , lpad(s.machine,8)    session_machine
  , (select ss.value from v$sesstat ss, v$statname sn
     where ss.sid = s.sid and 
           sn.statistic# = ss.statistic# and
           sn.name = 'session pga memory') / 1024      session_pga_memory_KB
  , (select ss.value from v$sesstat ss, v$statname sn
     where ss.sid = s.sid and 
           sn.statistic# = ss.statistic# and
           sn.name = 'session pga memory max') / 1024   session_pga_memory_max_KB
  , (select ss.value from v$sesstat ss, v$statname sn
     where ss.sid = s.sid and 
           sn.statistic# = ss.statistic# and
           sn.name = 'session uga memory') / 1024       session_uga_memory_KB
  , (select ss.value from v$sesstat ss, v$statname sn
     where ss.sid = s.sid and 
           sn.statistic# = ss.statistic# and
           sn.name = 'session uga memory max') / 1024   session_uga_memory_max_KB, 
  s.logon_time, 
  s.sql_id, 
  s.status
FROM 
    v$session  s
ORDER BY session_uga_memory_max_KB DESC;


clear breaks
clear computes