prompt informe o identificador que vai gerar statisticas
prompt disponivel em V$CLIENT_STATS
prompt 
exec DBMS_MONITOR.CLIENT_ID_STAT_ENABLE('&ident');