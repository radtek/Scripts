prompt **** dicas ****
prompt desconsiderar sempre o primeiro valor, porque o delta dele é incorreto
prompt informe instance_number 0 para todas
prompt ***************
Accept instance_number  prompt 'Instance number:'
Accept dt1  prompt 'Begin (dd/mm/yyyy hh24:mi:ss):'
Accept dt2  prompt 'End   (dd/mm/yyyy hh24:mi:ss):'

break on report

SELECT 
	TB_RWT.INTERVAL, 	
	round(TB_RWT.delta_ms / TB_RWS.delta_write) as DELTA_AVG_redo_write_time_ms,
	round(TB_RWT.accum_ms / TB_RWS.accum_write) as ACCUM_AVG_redo_write_time_ms,	
	TB_RWT.snap_id, 
	TB_RWT.startup_time
FROM (select STAT_NAME, 
		   to_char(end_interval_time, 'DD/MM/YYYY HH24:MI') AS Interval,
		   round(value_ms - LAG(value_ms, 1, 0) OVER (PARTITION BY startup_time, STAT_NAME  ORDER BY snap_id, startup_time)) as delta_ms,
		   round(value_ms) accum_ms,
		   snap_id, 
		   startup_time
	from (  select ss.startup_time, ss.snap_id, ss.END_INTERVAL_TIME, hst.STAT_NAME, sum(hst.value / 10) value_ms
			from dba_hist_sysstat hst
				inner join dba_hist_snapshot ss 
					on hst.instance_number = ss.instance_number 
					and hst.snap_id = ss.snap_id 
			where ss.END_INTERVAL_TIME between TO_DATE('&dt1', 'dd/mm/yyyy hh24:mi:ss') and TO_DATE('&dt2', 'dd/mm/yyyy hh24:mi:ss')
				and (ss.INSTANCE_NUMBER = &instance_number or &instance_number = 0)
				and hst.STAT_NAME = 'redo write time'
			group by ss.startup_time, ss.snap_id, ss.END_INTERVAL_TIME, hst.STAT_NAME
			order by ss.snap_id desc ) tbl ) TB_RWT
	INNER JOIN (select STAT_NAME, 
					   to_char(end_interval_time, 'DD/MM/YYYY HH24:MI') AS Interval,
					   round(value_write - LAG(value_write, 1, 0) OVER (PARTITION BY startup_time, STAT_NAME  ORDER BY snap_id, startup_time)) as delta_write,
					   round(value_write) accum_write,
					   snap_id, 
					   startup_time
				from (  select ss.startup_time, ss.snap_id, ss.END_INTERVAL_TIME, hst.STAT_NAME, sum(hst.value) value_write
						from dba_hist_sysstat hst
							inner join dba_hist_snapshot ss 
								on hst.instance_number = ss.instance_number 
								and hst.snap_id = ss.snap_id 
						where ss.END_INTERVAL_TIME between TO_DATE('&dt1', 'dd/mm/yyyy hh24:mi:ss') and TO_DATE('&dt2', 'dd/mm/yyyy hh24:mi:ss')
							and (ss.INSTANCE_NUMBER = &instance_number or &instance_number = 0)
							and hst.STAT_NAME = 'redo writes'
						group by ss.startup_time, ss.snap_id, ss.END_INTERVAL_TIME, hst.STAT_NAME
						order by ss.snap_id desc ) tbl ) TB_RWS
		ON TB_RWT.INTERVAL = TB_RWS.INTERVAL
		AND TB_RWT.snap_id = TB_RWS.snap_id				
order by TB_RWT.snap_id
/

undef dt1
undef dt2
undef instance_number