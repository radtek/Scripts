
prompt **** dicas ****
prompt desconsiderar sempre o primeiro valor, porque o delta dele é incorreto
prompt informe instance_number 0 para todas
prompt ***************
Accept instance_number  prompt 'Instance number:'
Accept dt1  prompt 'Begin (dd/mm/yyyy hh24:mi:ss):'
Accept dt2  prompt 'End   (dd/mm/yyyy hh24:mi:ss):'
Accept event_name  prompt 'Upper(event_name) like(valor):'

break on report
break on event_name skip 1 
col event_name for a55
select 
	event_name,
	Interval,
	delta_waits_k,
	delta_time_waited_seg,
	round(delta_time_waited_seg / nullif(delta_waits_k, 0),2) as media_k_seg,
	accum_waits_k,
	accum_time_waited_seg,
	snap_id, 	   
	startup_time
from (	
		select event_name, 
			   to_char(end_interval_time, 'DD/MM/YYYY HH24:MI') AS Interval,
			   round(waits_k - LAG(waits_k, 1, 0) OVER (PARTITION BY startup_time, event_name  ORDER BY snap_id, startup_time)) as delta_waits_k,	   
			   round(time_waited_seg - LAG(time_waited_seg, 1, 0) OVER (PARTITION BY startup_time, event_name  ORDER BY snap_id, startup_time)) as delta_time_waited_seg,	   	   
			   round(waits_k) accum_waits_k,
			   round(time_waited_seg) accum_time_waited_seg,	   
			   snap_id, 	   
			   startup_time
		from (  select ss.startup_time, ss.snap_id, ss.END_INTERVAL_TIME, hst.event_name, 
					   sum(hst.TOTAL_WAITS) / 1000 waits_k, 
					   sum(hst.TIME_WAITED_MICRO) / 1000 / 1000 time_waited_seg	
				from DBA_HIST_SYSTEM_EVENT hst
					inner join dba_hist_snapshot ss 
						on hst.instance_number = ss.instance_number 
						and hst.snap_id = ss.snap_id 
				where ss.END_INTERVAL_TIME between TO_DATE('&dt1', 'dd/mm/yyyy hh24:mi:ss') and TO_DATE('&dt2', 'dd/mm/yyyy hh24:mi:ss')
					and (ss.INSTANCE_NUMBER = &instance_number or &instance_number = 0)
					and upper(hst.event_name) like upper('%&event_name')
				group by ss.startup_time, ss.snap_id, ss.END_INTERVAL_TIME, hst.event_name
				order by ss.snap_id desc ) tbl ) tbl
order by event_name, snap_id						
/


undef dt1
undef dt2
undef instance_number
undef event_name