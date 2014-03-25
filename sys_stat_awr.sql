prompt **** dicas ****
prompt desconsiderar sempre o primeiro valor, porque o delta dele é incorreto
prompt informe instance_number 0 para todas
prompt ***************
Accept instance_number  prompt 'Instance number:'
Accept dt1  prompt 'Begin (dd/mm/yyyy hh24:mi:ss):'
Accept dt2  prompt 'End   (dd/mm/yyyy hh24:mi:ss):'
Accept STAT_NAME  prompt 'Upper(STAT_NAME) like(valor):'

break on report
break on STAT_NAME skip 1 
col STAT_NAME for a55

select STAT_NAME, 
       to_char(end_interval_time, 'DD/MM/YYYY HH24:MI') AS Interval,
       round(value_sec - LAG(value_sec, 1, 0) OVER (PARTITION BY startup_time, STAT_NAME  ORDER BY snap_id, startup_time)) as delta_sec,
	   round(value_sec) accum_sec,
       snap_id, 
	   startup_time
from (  select ss.startup_time, ss.snap_id, ss.END_INTERVAL_TIME, hst.STAT_NAME, sum(hst.value / 100) value_sec
		from dba_hist_sysstat hst
			inner join dba_hist_snapshot ss 
				on hst.instance_number = ss.instance_number 
				and hst.snap_id = ss.snap_id 
		where ss.END_INTERVAL_TIME between TO_DATE('&dt1', 'dd/mm/yyyy hh24:mi:ss') and TO_DATE('&dt2', 'dd/mm/yyyy hh24:mi:ss')
			and (ss.INSTANCE_NUMBER = &instance_number or &instance_number = 0)
			and upper(hst.STAT_NAME) like upper('%&STAT_NAME')
		group by ss.startup_time, ss.snap_id, ss.END_INTERVAL_TIME, hst.STAT_NAME
		order by ss.snap_id desc ) tbl 
order by STAT_NAME, snap_id
/

undef dt1
undef dt2
undef instance_number
undef STAT_NAME
