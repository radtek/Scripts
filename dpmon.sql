SELECT
        SUBSTR(sql_text, INSTR(sql_text,'INTO "'),30) table_name
      , rows_processed
      , ROUND( (sysdate-TO_DATE(first_load_time,'yyyy-mm-dd hh24:mi:ss'))*24*60,1) minutes
      , TRUNC(rows_processed/((sysdate-to_date(first_load_time,'yyyy-mm-dd hh24:mi:ss'))*24*60)) rows_per_minute
    FROM
        sys.v_$sqlarea
    WHERE
          sql_text like 'INSERT %INTO "%'
      AND command_type = 2
      AND open_versions > 0;
	  