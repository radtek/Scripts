prompt ativa o trace para nivel servico/mod/action depois o trace pode ser unico com trcsess
prompt para module NULL ou '' é configurado para todos que não configuraram module ou DBMS_MONITOR.ALL_MODULES para todos idenpendente se foi ou não configurado
prompt para action NULL ou '' é configurado para todos que não configuraram action ou DBMS_MONITOR.ALL_ACTIONS para todos idenpendente se foi ou não configurado
EXECUTE DBMS_MONITOR.SERV_MOD_ACT_TRACE_ENABLE('&service',&MODULES, &ACTIONS,TRUE,TRUE,'ALL_EXECUTIONS');