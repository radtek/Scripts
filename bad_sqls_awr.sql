define instance_id= &instance_id

prompt
prompt default por CPU

SELECT *
FROM (SELECT *
	 FROM ( select  ss.PLAN_HASH_VALUE, hs.snap_id, to_char(hs.end_interval_time, 'DD/MM/YYYY HH24:MI') AS end_interval_time,	
					SUM(ROUND(ss.DISK_READS_DELTA / ss.EXECUTIONS_DELTA)) as DISK_READS_AVG,
					SUM(ROUND(ss.BUFFER_GETS_DELTA / ss.EXECUTIONS_DELTA)) AS BUFFER_GETS_AVG,
					SUM(ROUND(ss.ROWS_PROCESSED_DELTA / ss.EXECUTIONS_DELTA)) AS ROWS_PROCESSED_AVG,
					SUM(ROUND(ss.CPU_TIME_DELTA  / ss.EXECUTIONS_DELTA / 1000)) AS CPU_TIME_MS_AVG,
					SUM(ROUND((ss.ELAPSED_TIME_DELTA  / ss.EXECUTIONS_DELTA) / 1000)) AS ELAPSED_TIME_MS_AVG,
					SUM(ROUND(ss.FETCHES_DELTA  / ss.EXECUTIONS_DELTA)) AS FETCHES_AVG,
					SUM(ROUND(ss.SORTS_DELTA  / ss.EXECUTIONS_DELTA)) AS SORTS_AVG,
					SUM(ROUND(ss.PARSE_CALLS_DELTA  / ss.EXECUTIONS_DELTA)) AS PARSE_CALLS_AVG,
					SUM(ROUND(ss.PX_SERVERS_EXECS_DELTA  / ss.EXECUTIONS_DELTA)) AS PX_SERVERS_EXECS_AVG, 
					PARSING_SCHEMA_NAME, 
					SUM(ss.EXECUTIONS_DELTA) EXECUTIONS
			from dba_hist_snapshot hs
				inner join dba_hist_sqlstat ss
					on hs.snap_id = ss.snap_id
					and hs.instance_number = ss.instance_number	
			where hs.end_interval_time between TO_DATE('&dt1', 'dd/mm/yyyy hh24:mi:ss') and TO_DATE('&dt2', 'dd/mm/yyyy hh24:mi:ss')			
			and (hs.instance_id = &instance_id or &instance_id = 0)
				and EXECUTIONS_DELTA > 0
				and PLAN_HASH_VALUE > 0
			group by ss.PLAN_HASH_VALUE, hs.snap_id, to_char(hs.end_interval_time, 'DD/MM/YYYY HH24:MI'), PARSING_SCHEMA_NAME) tbl
	 WHERE BUFFER_GETS_AVG > 1000
		and EXECUTIONS > 2
	ORDER BY CPU_TIME_MS_AVG desc, BUFFER_GETS_AVG desc, ROWS_PROCESSED_AVG asc) tbl
WHERE ROWNUM <= 10
/

undef instance_id