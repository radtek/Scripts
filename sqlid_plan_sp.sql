
prompt lista os planos de um sqlid no statspack conforme periodo

Accept dt1  prompt 'Begin (dd/mm/yyyy hh24:mi:ss)......:'
Accept dt2  prompt 'End   (dd/mm/yyyy hh24:mi:ss)......:'
Accept inst prompt 'Instance Number....................:'
Accept sql_id_list prompt 'Informe a lista de SQL_ID...:'

SELECT 
	SQL_ID, 				
	count(1) ctd
from stats$snapshot S
	inner join STATS$SQL_PLAN_USAGE ss
		on S.snap_id          = SS.snap_id
		and S.instance_number = SS.instance_number
		and S.dbid            = SS.dbid	 	
where     s.SNAP_TIME between to_date('&dt1', 'dd/mm/yyyy hh24:mi:ss') and to_date('&dt2', 'dd/mm/yyyy hh24:mi:ss')
	 and (s.INSTANCE_NUMBER = &inst or &inst = 0)
	 and SQL_ID in (&sql_id_list)
group by sql_id
order by ctd;


break on sql_id skip 1

SELECT 
	SQL_ID, 				
	to_char(SNAP_TIME, 'dd/mm hh:mi') as data, 
	PLAN_HASH_VALUE, 
	COST, 
	OPTIMIZER, 
	LAST_ACTIVE_TIME, 
	S.SNAP_ID
from stats$snapshot S
	inner join STATS$SQL_PLAN_USAGE ss
		on S.snap_id          = SS.snap_id
		and S.instance_number = SS.instance_number
		and S.dbid            = SS.dbid	 	
where     s.SNAP_TIME between to_date('&dt1', 'dd/mm/yyyy hh24:mi:ss') and to_date('&dt2', 'dd/mm/yyyy hh24:mi:ss')
	 and (s.INSTANCE_NUMBER = &inst or &inst = 0)
	 and SQL_ID in (&sql_id_list)
order by sql_id, s.SNAP_ID, PLAN_HASH_VALUE;

undef inst
undef dt1
undef dt2
undef sql_id_list
prompt usar @sqlid_plan_sp.sql para validar troca de planos