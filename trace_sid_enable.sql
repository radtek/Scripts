prompt se NULL para sid e serial então é minha propria sessao
alter session set tracefile_identifier='TRACE_100';
EXECUTE DBMS_MONITOR.SESSION_TRACE_ENABLE(&sid,&serial, TRUE, true);
@@trace_show