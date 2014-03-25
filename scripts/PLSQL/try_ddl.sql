begin
  for i in 1..1000
  loop
          dbms_lock.sleep(1);
          declare
                  erro_ddl EXCEPTION;
                  PRAGMA EXCEPTION_INIT(erro_ddl, -54);
          begin
                  execute immediate 'DROP MATERIALIZED VIEW LOG ON "LMS_PD"."NOTA_FISCAL_CONHECIMENTO"';
          EXCEPTION
                  WHEN erro_ddl THEN
                          null;
          end;
  end loop;
end;
/