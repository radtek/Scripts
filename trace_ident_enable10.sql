prompt usar dbms_session set_identifier antes @trace_set_ident
prompt 
EXECUTE DBMS_MONITOR.CLIENT_ID_TRACE_ENABLE('&ident', TRUE,true);