prompt ver plano de hash value usando stats pack
prompt 
select     lpad(' ',2*(level-1))|| decode(id,0,operation||' '||options||' '||object_name||' Cost:'||cost,operation||' '||options||' '||object_name) operation
   , optimizer
   , cardinality num_rows
        , PARTITION_START
        , PARTITION_STOP
 from (
      select *
      from perfstat.STATS$SQL_PLAN a
      where a.plan_hash_value = &Hash_value
      )
start with id = 0
connect by prior id = parent_id	  
/
