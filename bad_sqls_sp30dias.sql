define INSTANCE_NUMBER= &INSTANCE_NUMBER

prompt
prompt default por CPU

SELECT *
FROM (SELECT *
	 FROM ( select  ss.SNAP_ID
ss.TEXT_SUBSET
ss.OLD_HASH_VALUE
ss.SQL_TEXT
ss.SQL_ID
ss.MODULE
ss.FETCHES
ss.EXECUTIONS
ss.PARSE_CALLS
ss.DISK_READS
ss.DIRECT_WRITES
ss.BUFFER_GETS
ss.APPLICATION_WAIT_TIME
ss.CONCURRENCY_WAIT_TIME
ss.CLUSTER_WAIT_TIME
ss.USER_IO_WAIT_TIME
ss.PLSQL_EXEC_TIME
ss.JAVA_EXEC_TIME
ss.ROWS_PROCESSED
ss.CPU_TIME
ss.ELAPSED_TIME
ss.	AVG_HARD_PARSE_TIME

			select s.startup_time, 
					s.SNAP_TIME,
					s.*,
					ss.EXECUTIONS,
					ss.PARSE_CALLS,
					ss.DISK_READS,
					ss.DIRECT_WRITES,
					ss.BUFFER_GETS,
					ss.APPLICATION_WAIT_TIME,
					ss.CONCURRENCY_WAIT_TIME,
					ss.CLUSTER_WAIT_TIME
			from stats$snapshot S
				 inner join stats$sql_summary ss
					on S.snap_id         = SS.snap_id
					and S.instance_number = SS.instance_number
					and S.dbid            = SS.dbid	 							
			where ss.sql_id = '9z4qbcwu143pw'
			and rownum < 10 
			order by S.snap_id
			
					SUM(ROUND(ss.DISK_READS_DELTA / ss.EXECUTIONS_DELTA)) as DISK_READS_AVG,
					SUM(ROUND(ss.BUFFER_GETS_DELTA / ss.EXECUTIONS_DELTA)) AS BUFFER_GETS_AVG,
					SUM(ROUND(ss.ROWS_PROCESSED_DELTA / ss.EXECUTIONS_DELTA)) AS ROWS_PROCESSED_AVG,
					SUM(ROUND(ss.CPU_TIME_DELTA  / ss.EXECUTIONS_DELTA / 1000)) AS CPU_TIME_MS_AVG,
					SUM(ROUND((ss.ELAPSED_TIME_DELTA  / ss.EXECUTIONS_DELTA) / 1000)) AS ELAPSED_TIME_MS_AVG,
					SUM(ROUND(ss.FETCHES_DELTA  / ss.EXECUTIONS_DELTA)) AS FETCHES_AVG,
					SUM(ROUND(ss.SORTS_DELTA  / ss.EXECUTIONS_DELTA)) AS SORTS_AVG,
					SUM(ROUND(ss.PARSE_CALLS_DELTA  / ss.EXECUTIONS_DELTA)) AS PARSE_CALLS_AVG,
					SUM(ROUND(ss.PX_SERVERS_EXECS_DELTA  / ss.EXECUTIONS_DELTA)) AS PX_SERVERS_EXECS_AVG, 		
					SUM(ss.EXECUTIONS_DELTA) EXECUTIONS
			from dba_hist_snapshot hs
				inner join dba_hist_sqlstat ss
					on hs.snap_id = ss.snap_id
					and hs.instance_number = ss.instance_number	
			where hs.end_interval_time between sysdate - 30 and sysdate
			and (hs.INSTANCE_NUMBER = &INSTANCE_NUMBER or &INSTANCE_NUMBER = 0)
				and EXECUTIONS_DELTA > 0
				and PLAN_HASH_VALUE > 0
			group by ss.PLAN_HASH_VALUE) tbl
	 WHERE BUFFER_GETS_AVG > 1
		and EXECUTIONS > 1
	ORDER BY CPU_TIME_MS_AVG desc, BUFFER_GETS_AVG desc, ROWS_PROCESSED_AVG asc) tbl
WHERE ROWNUM <= 10
/

undef INSTANCE_NUMBER