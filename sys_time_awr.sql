prompt **** dicas ****
prompt desconsiderar sempre o primeiro valor, porque o delta dele é incorreto
prompt informe instance_number 0 para todas
prompt 
prompt DB time -> Indicador total de esforço do banco de dados para atender as demandas de usuários, bom indicador para ver alterações no comportamento
prompt obs: O tempo total de uma requisição é composta pelo tempo de CPU (trabalhando, alterar consulta) + tempo de wait (eventos de espera, problema de configuração)
prompt
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
from (  select ss.startup_time, stm.snap_id, ss.END_INTERVAL_TIME, stm.STAT_NAME, sum(stm.value / 1000 / 1000) value_sec
	from DBA_HIST_SYS_TIME_MODEL stm 
		inner join dba_hist_snapshot ss 
			on ss.instance_number = stm.instance_number 
			and ss.snap_id = stm.snap_id 
	where ss.END_INTERVAL_TIME between TO_DATE('&dt1', 'dd/mm/yyyy hh24:mi:ss') and TO_DATE('&dt2', 'dd/mm/yyyy hh24:mi:ss')
		and (ss.INSTANCE_NUMBER = &instance_number or &instance_number = 0)
		and upper(stm.STAT_NAME) like upper('%&STAT_NAME')
	group by ss.startup_time, stm.snap_id, ss.END_INTERVAL_TIME, stm.STAT_NAME
	order by stm.snap_id desc) tbl 
order by STAT_NAME, snap_id
/

undef dt1
undef dt2
undef instance_number
undef STAT_NAME