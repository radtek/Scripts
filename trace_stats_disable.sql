prompt desativar o identificador que est� gerarando statisticas
prompt disponivel em V$CLIENT_STATS
prompt
exec DBMS_MONITOR.CLIENT_ID_STAT_DISABLE('&ident');