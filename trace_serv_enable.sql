prompt ativa o trace para nivel servico/mod/action depois o trace pode ser unico com trcsess
prompt para module NULL ou '' � configurado para todos que n�o configuraram module ou DBMS_MONITOR.ALL_MODULES para todos idenpendente se foi ou n�o configurado
prompt para action NULL ou '' � configurado para todos que n�o configuraram action ou DBMS_MONITOR.ALL_ACTIONS para todos idenpendente se foi ou n�o configurado
EXECUTE DBMS_MONITOR.SERV_MOD_ACT_TRACE_ENABLE('&service',&MODULES, &ACTIONS,TRUE,TRUE,'ALL_EXECUTIONS');