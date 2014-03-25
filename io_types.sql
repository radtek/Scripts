prompt 
prompt - tipos de IO:
prompt 			-> Buffered datafile IO= "db file sequential read" and "db file scattered read" quando uma sessão lê dados  do datafile para buffer cache
prompt 			-> Temporary segment IO waits=  "direct path read temp" and "direct path write temp" quando um sort executa sem suficiente PGA
prompt 			-> Direct path reads= Oracle bypass buffer cache, não afeta memory configurarion
prompt 			-> System IO=write nos redo ou datafile conduzidos por background process não afeta configuração de memória
prompt 
			
WITH system_event AS
(
SELECT CASE WHEN event LIKE 'direct path%temp' THEN 'direct path read/write temp'
			 WHEN event LIKE 'direct path%' THEN 'direct path read/write non-temp'
			 WHEN wait_class = 'User I/O' THEN event
			 ELSE wait_class
		END AS wait_type, 
		e.*
FROM v$system_event e
)
SELECT wait_type, 
		SUM(total_waits) total_waits,
		ROUND(SUM(time_waited_micro) / 1000000, 2) time_waited_seconds,
		ROUND( SUM(time_waited_micro) * 100 / SUM(SUM(time_waited_micro)) OVER (), 2) pct
FROM (SELECT wait_type, 
			event, 
			total_waits, 
			time_waited_micro
FROM system_event e
UNION
SELECT 'CPU', stat_name, NULL, VALUE
FROM v$sys_time_model
WHERE stat_name IN ('background cpu time', 'DB CPU')) l
WHERE wait_type <> 'Idle'
GROUP BY wait_type
ORDER BY 4 DESC
/