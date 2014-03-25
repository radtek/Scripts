select sql_handle, plan_name, enabled, accepted,fixed,origin 
from dba_sql_plan_baselines 
where signature=&signature;