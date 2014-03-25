prompt ver todos os planos gerado por um hash value 
prompt usando o statspack
prompt 
prompt 

col OPERATION for a80
define hash_value=&hash_value

prompt ver planos gerados pelo hash
Select plan_hash_value, count(*) ctd_plano from STATS$SQL_PLAN_usage where hash_value=&hash_value group by plan_hash_value order by 2;
prompt

Accept plan_Hash_value prompt 'Plan_Hash_value:'

select     lpad(' ',2*(level-1))|| decode(id,0,operation||' '||options||' '||object_name||' Cost:'||cost,operation||' '||options||' '||object_name) operation
   , optimizer
   , cardinality num_rows
        , PARTITION_START
        , PARTITION_STOP
 from (
      select *
      from STATS$SQL_PLAN a
      where a.PLAN_HASH_VALUE = &Plan_Hash_value
        --and a.child_number = 0
      )
start with id = 0
connect by prior id = parent_id
/

undef plan_Hash_value
undef hash_value