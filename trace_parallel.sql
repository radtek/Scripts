prompt *****************trace para query com parallel*****************
prompt para consolidar os traces:
prompt 		trcsess clientid='TRACE_PARALLEL' output=trace_parallel.trc *
prompt para analisar o trace:
prompt 		tkprof trace_parallel.trc trace.trc sort='(prsela,fchela,exeela)'
prompt 

BEGIN
	DBMS_SESSION.set_identifier ('TRACE_PARALLLEL');				
	DBMS_MONITOR.client_id_trace_enable(client_id => 'TRACE_PARALLLEL',waits => TRUE);
END;
/
