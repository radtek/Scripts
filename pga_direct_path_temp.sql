prompt devemos comprar "direct path read/write temp" com outras atividades como CPU
prompt ideal coletar em um periodo e comparar
prompt podemos verificar se devemos aumentar o tamanho da PGA
prompt 
WITH system_event AS
(
SELECT CASE WHEN event LIKE 'direct path%temp'
	 THEN event ELSE wait_class
	 END wait_type, e.*
FROM v$system_event e)
SELECT wait_type,
	SUM(total_waits) total_waits,
	 round(SUM(time_waited_micro)/1000000,2) time_waited_seconds,
	 ROUND( SUM(time_waited_micro) * 100 / SUM(SUM(time_waited_micro)) OVER (), 2) pct
FROM (	 SELECT wait_type, event, total_waits, time_waited_micro
	 FROM system_event e
	 UNION
	 SELECT 'CPU', stat_name, NULL, VALUE
	 FROM v$sys_time_model
	 WHERE stat_name IN ('background cpu time', 'DB CPU')) l
WHERE wait_type <> 'Idle'
GROUP BY wait_type
ORDER BY 4 DESC;