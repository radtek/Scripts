col sqltext for a50 wrapped
col signature for 99999999999999999999999
select  sql_handle, plan_name, enabled, accepted, fixed, autopurge, reproduced, LAST_EXECUTED, LAST_VERIFIED, origin, signature, parsing_schema_name, substr(sql_text, 1, 50) as sqltext
from dba_sql_plan_baselines 
order by created desc;	

