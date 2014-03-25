define INSTANCE_NUMBER= &INSTANCE_NUMBER

prompt
prompt default por CPU

SELECT *
FROM (SELECT *
	 FROM ( select  ss.PLAN_HASH_VALUE,
					SUM(ROUND(ss.DISK_READS_DELTA )) as DISK_READS,
					SUM(ROUND(ss.BUFFER_GETS_DELTA )) AS BUFFER_GETS,
					SUM(ROUND(ss.ROWS_PROCESSED_DELTA )) AS ROWS_PROCESSED,
					SUM(ROUND((ss.CPU_TIME_DELTA) / 1000)) AS CPU_TIME_MS,
					SUM(ROUND((ss.ELAPSED_TIME_DELTA  ) / 1000)) AS ELAPSED_TIME_MS,
					SUM(ROUND(ss.FETCHES_DELTA  / ss.EXECUTIONS_DELTA)) AS FETCHES,
					SUM(ROUND(ss.SORTS_DELTA  / ss.EXECUTIONS_DELTA)) AS SORTS,
					SUM(ROUND(ss.PARSE_CALLS_DELTA  / ss.EXECUTIONS_DELTA)) AS PARSE_CALLS,
					SUM(ROUND(ss.PX_SERVERS_EXECS_DELTA  / ss.EXECUTIONS_DELTA)) AS PX_SERVERS_EXECS, 		
					SUM(ss.EXECUTIONS_DELTA) EXECUTIONS
			from dba_hist_snapshot hs
				inner join dba_hist_sqlstat ss
					on hs.snap_id = ss.snap_id
					and hs.instance_number = ss.instance_number	
			where hs.end_interval_time between sysdate - 2 and sysdate
			and (hs.INSTANCE_NUMBER = &INSTANCE_NUMBER or &INSTANCE_NUMBER = 0)
				and EXECUTIONS_DELTA > 0
				and PLAN_HASH_VALUE > 0
			group by ss.PLAN_HASH_VALUE) tbl
	 WHERE BUFFER_GETS > 1
		and EXECUTIONS > 1
	ORDER BY CPU_TIME_MS desc, BUFFER_GETS desc, ROWS_PROCESSED asc) tbl
WHERE ROWNUM <= 10
/

undef INSTANCE_NUMBER