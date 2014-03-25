break on inst_id
compute sum of session_uga_memory_max_MB on inst_id
compute sum of session_uga_memory_MB on inst_id
compute sum of session_pga_memory_max_MB on inst_id
compute sum of session_pga_memory_MB on inst_id

SELECT
    s.inst_id
  , lpad(s.username,12)  oracle_username
  , sum(round((select ss.value from v$sesstat ss, v$statname sn
     where ss.sid = s.sid and
           sn.statistic# = ss.statistic# and
           sn.name = 'session pga memory') / 1024 / 1024))      session_pga_memory_MB
  , sum(round((select ss.value from v$sesstat ss, v$statname sn
     where ss.sid = s.sid and
           sn.statistic# = ss.statistic# and
           sn.name = 'session pga memory max') / 1024/ 1024))   session_pga_memory_max_MB
  , sum(round((select ss.value from v$sesstat ss, v$statname sn
     where ss.sid = s.sid and
           sn.statistic# = ss.statistic# and
           sn.name = 'session uga memory') / 1024/ 1024))       session_uga_memory_MB
  , sum(round((select ss.value from v$sesstat ss, v$statname sn
     where ss.sid = s.sid and
           sn.statistic# = ss.statistic# and
           sn.name = 'session uga memory max') / 1024/ 1024))   session_uga_memory_max_MB
FROM
    gv$session  s
group by     s.inst_id
  , lpad(s.username,12)
ORDER BY s.inst_id, session_uga_memory_MB DESC;