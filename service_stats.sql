col service_name for a30
col stat_name for a60
col value for 999999999999999999999 justify right
prompt
show parameter service
prompt
prompt
select SERVICE_NAME, STAT_NAME, VALUE
FROM v$service_stats 
where upper(service_name) like upper('&servicename')
and upper(stat_name) like upper('&stat_name')
order by 1, 2;