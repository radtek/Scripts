connect / as sysdba
set serveroutput on
set timing on
set lines 200
set pages 0
spool output.out
declare
  ctd number;
  csql VARCHAR2(4000);
  thread number:=1;

  CURSOR c1 IS
  select /*+ parallel(tkt 4)*/ sql_undo, ROW_ID
  from system.logmnr_tk5442
  where XIDUSN || '.' || XIDSLT || '.' || XIDSQN = '6.3.10659965'
  and scn between 6857763776991 and 6857764599684;

begin
  ctd:=0;

  for rec in c1 loop

    select replace(replace(rec.sql_undo, '"BIPUB"."TERRA_GATEWAY_LOG_SMS_MO"', '"BIPUB"."DBA_TERRA_GATEWAY_LOG_SMS_MO"'), ';', '')
    into csql
    from dual;

    execute immediate csql;

    ctd:= ctd + 1;
    if mod(ctd,10000) = 0 then
       insert into system.logmnr_tk5442_carga2(id, data, row_count)
       values(thread,sysdate,ctd);

       commit;
    end if;
  end loop;

  insert into system.logmnr_tk5442_carga2(id, data, row_count)
  values(thread,sysdate,ctd);

  commit;
end;
/
