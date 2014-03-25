col PLAN FOR a150

SELECT
     RPAD('(' || p.plan_line_ID || ' ' || NVL(p.plan_parent_id,'0') || ')',8) || '|' ||
     RPAD(LPAD (' ', 2*p.plan_DEPTH) || p.plan_operation || ' ' || p.plan_options,60,'.') ||
     NVL2(p.plan_object_owner||p.plan_object_name, '(' || p.plan_object_owner|| '.' || p.plan_object_name || ') ', '') ||
     NVL2(p.plan_COST,'Cost:' || p.plan_COST,'') || ' ' ||
     NVL2(p.plan_bytes||p.plan_CARDINALITY,'(' || p.plan_bytes || ' bytes, ' || p.plan_CARDINALITY || ' rows)','') || ' ' ||
     NVL2(p.plan_partition_start || p.plan_partition_stop,' PStart:' ||  p.plan_partition_start || ' PStop:' || p.plan_partition_stop,'') ||
     NVL2(p.plan_time, p.plan_time || '(s)','') AS PLAN
FROM v$sql_plan_monitor p
WHERE sql_id = '&sqlid'
     AND sql_exec_id = &sql_exec_id
     AND sql_exec_start=TO_DATE('&sql_exec_start','dd-mm-yyyy hh24:mi:ss')
ORDER BY p.plan_line_id, p.plan_parent_id;
