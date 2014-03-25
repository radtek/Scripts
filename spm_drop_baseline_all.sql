DECLARE
   cursor c_s IS SELECT sql_handle FROM dba_sql_plan_baselines 
  WHERE parsing_schema_name='&schema';

  nRet NUMBER;
BEGIN
  FOR rec IN c_s loop
    BEGIN
      nRet := dbms_spm.drop_sql_plan_baseline(rec.sql_handle);
    exception
      -- I know, this is BAD, so, do not use it in your production code
      WHEN others THEN NULL;
    END;
   END loop;

  commit;
END;
 /
