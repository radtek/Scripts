SELECT sql_handle, plan_name, enabled, accepted, FIXED, LAST_EXECUTED
FROM   dba_sql_plan_baselines
WHERE  upper(sql_text) LIKE '&texto'
AND    sql_text NOT LIKE '%dba_sql_plan_baselines%';