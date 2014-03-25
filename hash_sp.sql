set verify off
Accept dt1  prompt 'Begin (dd/mm/yyyy hh24:mi:ss):'
Accept dt2  prompt 'End   (dd/mm/yyyy hh24:mi:ss):'
Accept instance prompt 'Instance:'
define hash = &hash

col OUTLINE_CATEGORY format a20
col EXECUTIONS for 999999999999 justify right
col DISK_READS  for 999999999999 justify right
col BUFFER_GETS for 999999999999 justify right
col ROWS_PROCESSED for 999999999999 justify right
col CPU_TIME_MS for 999999999999 justify right
col ELAPSED_TIME_MS for 999999999999 justify right
col FETCHES for 999999999999 justify right
col SORTS for 999999999999 justify right
col PARSE_CALLS for 999999999999 justify right
col AVG_DISK_READS for 999999999999 justify right
col AVG_BUFFER_GETS for 999999999999 justify right
col AVG_ROWS_PROCESSED for 999999999999 justify right
col AVG_CPU_TIME_MS for 999999999999 justify right
col AVG_ELAPSED_TIME_MS for 999999999999 justify right
col AVG_FETCHES for 999999999999 justify right
col AVG_SORTS for 999999999999 justify right
col AVG_PARSE_CALLS for 999999999999 justify right

var Snap_ini number;
var Snap_fim number;
var Plan_hash number;

begin 
	select min(snap_id), max(snap_id)
	INTO :Snap_ini, :Snap_fim
	from stats$snapshot
	where instance_number = &instance
	and snap_time between to_date('&dt1', 'DD/MM/YYYY HH24:MI:SS') and to_date('&dt2', 'DD/MM/YYYY HH24:MI:SS');
end;
/

select snap_id, snap_time, instance_number, snap_level
from stats$snapshot
where snap_id in (:Snap_ini, :Snap_fim);
prompt
prompt 
Select Count(*) Nro_ocorrencias, Plan_hash_value
from STATS$SQL_PLAN_usage 
where hash_value=&hash 
and snap_id between :Snap_ini and :Snap_fim
group by plan_hash_value 
order by 1;

begin 
	select plan_hash_value
	into :Plan_hash
	from (Select Count(*) Nro_ocorrencias, Plan_hash_value
			from STATS$SQL_PLAN_usage 
			where hash_value=&hash 
			and snap_id between :Snap_ini and :Snap_fim
			group by plan_hash_value 
			order by 1 desc)
	where rownum =1;
end;
/

prompt 
prompt "GERAL"
select  SS.snap_id, 
	to_char(S.snap_time, 'DD/MM/YYYY HH24:MI') AS snap_time,
	SS.MODULE, 
	SS.LOADED_VERSIONS, 
	SS.INVALIDATIONS, 
	SS.PARSE_CALLS,
	SS.LOADS, 
	SS.COMMAND_TYPE, 
	SS.ADDRESS, 
	SS.VERSION_COUNT, 
	SS.OUTLINE_SID, 
	SS.OUTLINE_CATEGORY, 
	SS.CHILD_LATCH,	
	SPU.Plan_hash_value, 
	SPU.cost, 
	SPU.Optimizer
from stats$snapshot S
	 INNER JOIN stats$sql_summary SS
		ON S.snap_id         = SS.snap_id
		and S.instance_number = SS.instance_number
		and S.dbid            = SS.dbid
	 LEFT JOIN STATS$SQL_PLAN_USAGE SPU
		ON SS.snap_id         = SPU.snap_id
		and SS.instance_number = SPU.instance_number
		and SS.dbid            = SPU.dbid
		and SS.hash_value      = SPU.hash_value
where SS.HASH_VALUE=&hash
and  SS.snap_id between :Snap_ini and :Snap_fim
group by SS.snap_id, to_char(S.snap_time, 'DD/MM/YYYY HH24:MI'), SS.MODULE,  SS.LOADED_VERSIONS, 
	SS.INVALIDATIONS, SS.PARSE_CALLS, SS.LOADS, SS.COMMAND_TYPE, SS.ADDRESS, SS.VERSION_COUNT, SS.OUTLINE_SID, SS.OUTLINE_CATEGORY, SS.CHILD_LATCH,	
	SPU.Plan_hash_value, SPU.cost, SPU.Optimizer
order by SS.SNAP_ID, SPU.Plan_hash_value;
prompt 
prompt
prompt "TOTAIS"
select  SS.snap_id, 
	to_char(S.snap_time, 'DD/MM/YYYY HH24:MI') AS snap_time,
	SUM(SS.EXECUTIONS) AS EXECUTIONS,   
	SUM(SS.DISK_READS) AS DISK_READS, 
	SUM(SS.BUFFER_GETS) AS BUFFER_GETS,
	SUM(SS.ROWS_PROCESSED) AS  ROWS_PROCESSED,
	SUM(round(SS.CPU_TIME / 1000.0)) AS CPU_TIME_MS,
	SUM(round(SS.ELAPSED_TIME / 1000.0)) AS ELAPSED_TIME_MS,	
	SUM(SS.SHARABLE_MEM) As SHARABLE_MEM, 	
	SUM(SS.FETCHES) AS FETCHES, 
	SUM(SS.SORTS) AS SORTS, 
	SPU.Plan_hash_value, 
	SPU.cost, 
	SPU.Optimizer
from stats$snapshot S
	 INNER JOIN stats$sql_summary SS
		ON S.snap_id         = SS.snap_id
		and S.instance_number = SS.instance_number
		and S.dbid            = SS.dbid	 
	 LEFT JOIN STATS$SQL_PLAN_USAGE SPU
		ON SS.snap_id         = SPU.snap_id
		and SS.instance_number = SPU.instance_number
		and SS.dbid            = SPU.dbid
		and SS.hash_value      = SPU.hash_value
where SS.HASH_VALUE=&hash
and  SS.snap_id between :Snap_ini and :Snap_fim
group by SS.SNAP_ID, SPU.Plan_hash_value, SPU.cost, SPU.Optimizer, to_char(S.snap_time, 'DD/MM/YYYY HH24:MI')
order by SS.SNAP_ID, SPU.Plan_hash_value;
prompt
prompt
prompt "VALORES POR EXECUCAO"
select  SS.snap_id, 
	to_char(S.snap_time, 'DD/MM/YYYY HH24:MI') AS snap_time,
	SUM(SS.EXECUTIONS) AS EXECUTIONS,   
	ROUND(SUM(SS.DISK_READS) / SUM(DECODE(EXECUTIONS, 0, 1, EXECUTIONS)) ) AS AVG_DISK_READS, 
	ROUND(SUM(SS.BUFFER_GETS) / SUM(DECODE(EXECUTIONS, 0, 1, EXECUTIONS)) ) AS AVG_BUFFER_GETS,
	ROUND(SUM(SS.ROWS_PROCESSED) / SUM(DECODE(EXECUTIONS, 0, 1, EXECUTIONS)) ) AS  AVG_ROWS_PROCESSED,
	ROUND(SUM(round((SS.CPU_TIME / 1000.) / DECODE(EXECUTIONS, 0, 1, EXECUTIONS)))) AS AVG_CPU_TIME_MS,
	ROUND(SUM(round((SS.ELAPSED_TIME / 1000.0) / DECODE(EXECUTIONS, 0, 1, EXECUTIONS)))) AS AVG_ELAPSED_TIME_MS,	
	ROUND(SUM(SS.SHARABLE_MEM) / SUM(DECODE(EXECUTIONS, 0, 1, EXECUTIONS)) ) As AVG_SHARABLE_MEM, 	
	ROUND(SUM(SS.FETCHES) / SUM(DECODE(EXECUTIONS, 0, 1, EXECUTIONS)) ) AS AVG_FETCHES, 
	ROUND(SUM(SS.SORTS) / SUM(DECODE(EXECUTIONS, 0, 1, EXECUTIONS)) ) AS AVG_SORTS, 
	SPU.Plan_hash_value, 
	SPU.cost, 
	SPU.Optimizer
from stats$snapshot S
	 INNER JOIN stats$sql_summary SS
		ON S.snap_id         = SS.snap_id
		and S.instance_number = SS.instance_number
		and S.dbid            = SS.dbid
	 LEFT JOIN STATS$SQL_PLAN_USAGE SPU
		ON SS.snap_id         = SPU.snap_id
		and SS.instance_number = SPU.instance_number
		and SS.dbid            = SPU.dbid
		and SS.hash_value      = SPU.hash_value
where SS.HASH_VALUE=&hash
and  SS.snap_id between :Snap_ini and :Snap_fim
group by SS.SNAP_ID, SPU.Plan_hash_value, SPU.cost, SPU.Optimizer, to_char(S.snap_time, 'DD/MM/YYYY HH24:MI')
order by SS.SNAP_ID, SPU.Plan_hash_value;
prompt 
prompt 
prompt 
prompt "PLANO QUE TEM MAIS OCORRENCIA"
select     lpad(' ',2*(level-1))|| decode(id,0,operation||' '||options||' '||object_name||' Cost:'||cost,operation||' '||options||' '||object_name) operation
   , optimizer
   , cardinality num_rows
        , PARTITION_START
        , PARTITION_STOP
 from (
      select *
      from perfstat.STATS$SQL_PLAN a
      where a.plan_hash_value = :Plan_hash
      )
start with id = 0
connect by prior id = parent_id	  
/
prompt 
prompt
undef dt1
undef dt2
undef instance
undef hash
set verify on