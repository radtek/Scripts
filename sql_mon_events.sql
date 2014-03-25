SELECT NVL(wait_class,'CPU') AS wait_class, NVL(event,'CPU') AS event, sql_plan_line_id, COUNT(*)
     FROM v$active_session_history a
     WHERE sql_id = '&sqlid'
     AND sql_exec_id = &sql_exec_id
     AND sql_exec_start=TO_DATE('&sql_exec_start','dd-mm-yyyy hh24:mi:ss')
     GROUP BY wait_class,event,sql_plan_line_id;
