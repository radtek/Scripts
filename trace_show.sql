SELECT s.sql_trace, s.sql_trace_waits, s.sql_trace_binds,
          traceid, tracefile
     FROM v$session s JOIN v$process p ON (p.addr = s.paddr)
    WHERE audsid = USERENV ('SESSIONID');