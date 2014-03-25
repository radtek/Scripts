prompt informe gera statisticas para nivel servico/modulo/action
prompt disponivel em V$SERV_MOD_ACT_STAT
prompt 
exec DBMS_MONITOR.SERV_MOD_ACT_STAT_ENABLE(&servicename, &module, &action);