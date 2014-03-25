prompt desativar o identificador que está gerarando statisticas
prompt disponivel em V$SERV_MOD_ACT_STAT
prompt
exec DBMS_MONITOR.SERV_MOD_ACT_STAT_DISABLE(&servicename, &module, &action);