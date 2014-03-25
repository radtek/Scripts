select sql_handle, plan_name, enabled, accepted,fixed,origin 
from dba_sql_plan_baselines 
where sql_id = (select sql_id from v$sql where exact_matching_signature = '&signature');