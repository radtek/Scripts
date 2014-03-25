prompt **** dicas ****
prompt desconsiderar sempre o primeiro valor, porque o delta dele é incorreto
prompt informe instance_number 0 para todas
prompt ***************
Accept instance_number  prompt 'Instance number:'
Accept dt1  prompt 'Begin (dd/mm/yyyy hh24:mi:ss):'
Accept dt2  prompt 'End   (dd/mm/yyyy hh24:mi:ss):'

break on report
col mount for a10
col Interval for a20

SELECT mount, 
		Interval, 
		round(sum(PHYRDS_K)) AS PHYRDS_K,
		round(sum(PHYWRTS_K)) AS PHYWRTS_K,
		round(sum(SINGLEBLKRDS_K)) AS SINGLEBLKRDS_K,
		round(AVG(READTIM_MS)) AS READTIM_AVG_MS,
		round(AVG(WRITETIM_MS)) AS WRITETIM_AVG_MS,
		round(AVG(SINGLEBLKRDTIM_MS)) AS SINGLEBLKRDTIM_AVG_MS,
		round(sum(PHYBLKRD_K)) AS PHYBLKRD_K,
		round(sum(PHYBLKWRT_K)) AS PHYBLKWRT_K,
		round(sum(WAIT_COUNT_K)) AS WAIT_COUNT_K,
		round(AVG(TIME_MS)) AS TIME_AVG_MS, 
		snap_id,
		startup_time
FROM(		
	select substr(FILENAME, 1, instr(FILENAME, '/', 2) - 1) mount,
		  Interval,
		  PHYRDS_K - LAG(PHYRDS_K, 1, 0) OVER (PARTITION BY startup_time, FILENAME  ORDER BY FILENAME,snap_id, startup_time) as PHYRDS_K,
		  PHYWRTS_K - LAG(PHYWRTS_K, 1, 0) OVER (PARTITION BY startup_time, FILENAME  ORDER BY FILENAME,snap_id, startup_time) as PHYWRTS_K,
		  SINGLEBLKRDS_K - LAG(SINGLEBLKRDS_K, 1, 0) OVER (PARTITION BY startup_time, FILENAME  ORDER BY FILENAME,snap_id, startup_time) as SINGLEBLKRDS_K,
		  READTIM_MS - LAG(READTIM_MS, 1, 0) OVER (PARTITION BY startup_time, FILENAME  ORDER BY FILENAME,snap_id, startup_time) as READTIM_MS,
		  WRITETIM_MS - LAG(WRITETIM_MS, 1, 0) OVER (PARTITION BY startup_time, FILENAME  ORDER BY FILENAME,snap_id, startup_time) as WRITETIM_MS,
		  SINGLEBLKRDTIM_MS - LAG(SINGLEBLKRDTIM_MS, 1, 0) OVER (PARTITION BY startup_time, FILENAME  ORDER BY FILENAME,snap_id, startup_time) as SINGLEBLKRDTIM_MS,
		  PHYBLKRD_K - LAG(PHYBLKRD_K, 1, 0) OVER (PARTITION BY startup_time, FILENAME  ORDER BY FILENAME,snap_id, startup_time) as PHYBLKRD_K,
		  PHYBLKWRT_K - LAG(PHYBLKWRT_K, 1, 0) OVER (PARTITION BY startup_time, FILENAME  ORDER BY FILENAME,snap_id, startup_time) as PHYBLKWRT_K,
		  WAIT_COUNT_K - LAG(WAIT_COUNT_K, 1, 0) OVER (PARTITION BY startup_time, FILENAME  ORDER BY FILENAME,snap_id, startup_time) as WAIT_COUNT_K,
		  TIME_MS - LAG(TIME_MS, 1, 0) OVER (PARTITION BY startup_time, FILENAME  ORDER BY FILENAME,snap_id, startup_time) as TIME_MS,
		  snap_id,
		  startup_time
	FROM (    SELECT
					  SS.SNAP_ID,
					  SS.startup_time,
					  to_char(ss.end_interval_time, 'DD/MM/YYYY HH24:MI') AS Interval,
					  FILENAME,
					  SUM(tp.PHYRDS / 1000) AS PHYRDS_K,
					  SUM(tp.PHYWRTS       / 1000) AS PHYWRTS_K,
					  SUM(tp.SINGLEBLKRDS / 1000) AS SINGLEBLKRDS_K,
					  SUM(tp.READTIM      / 10) AS READTIM_MS,
					  SUM(tp.WRITETIM / 10) AS WRITETIM_MS,
					  SUM(tp.SINGLEBLKRDTIM       / 10) AS SINGLEBLKRDTIM_MS,
					  SUM(tp.PHYBLKRD / 1000) AS PHYBLKRD_K,
					  SUM(tp.PHYBLKWRT / 1000) AS PHYBLKWRT_K,
					  SUM(tp.WAIT_COUNT / 1000) AS WAIT_COUNT_K,
					  SUM(tp.TIME / 10) AS TIME_MS
			  FROM DBA_HIST_TEMPSTATXS tp
					   inner join dba_hist_snapshot ss
							  on tp.instance_number = ss.instance_number
							  and tp.snap_id = ss.snap_id
			  where ss.END_INTERVAL_TIME between TO_DATE('&dt1', 'dd/mm/yyyy hh24:mi:ss') and TO_DATE('&dt2', 'dd/mm/yyyy hh24:mi:ss')
					  and (ss.INSTANCE_NUMBER = &instance_number or &instance_number = 0)
			  group by SS.SNAP_ID,
					  SS.startup_time,
					  to_char(ss.end_interval_time, 'DD/MM/YYYY HH24:MI'),
					  FILENAME
			  order by snap_id, FILENAME desc)) 
group by mount, Interval, snap_id, startup_time
order by mount, snap_id desc;

undef instance_number 
undef dt1
undef dt2
