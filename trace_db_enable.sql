prompt ativo para binds e waits
prompt NULL em instance_name para todas a instances
exec DBMS_MONITOR.DATABASE_TRACE_ENABLE(true, true, &instance_name, 'ALL_EXECUTIONS');