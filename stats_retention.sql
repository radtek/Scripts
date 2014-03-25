prompt  Configurar a retenção
							select dbms_stats.GET_STATS_HISTORY_RETENTION() from dual;
select dbms_stats.GET_STATS_HISTORY_AVAILABILITY() from dual;
							prompt  antiga nunca é salva "exec DBMS_STATS.ALTER_STATS_HISTORY_RETENTION(0);"
							prompt  nunca ocorre o purge "exec DBMS_STATS.ALTER_STATS_HISTORY_RETENTION(1);"
							prompt  default value 31 dias "exec DBMS_STATS.ALTER_STATS_HISTORY_RETENTION(NULL);"