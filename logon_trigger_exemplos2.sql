WHENEVER SQLERROR EXIT FAILURE;
-- força a falha
select aaaa from dual;


CREATE OR REPLACE TRIGGER "SYSTEM"."TRG_TRACE"
AFTER LOGON ON JEAN.SCHEMA
DECLARE
    v_sid         NUMBER;
    v_serial      NUMBER;
     CURSOR c1 IS
      SELECT sid,
             serial#
       FROM v$session
       WHERE sid in (select SYS_CONTEXT('USERENV', 'SID') from dual);
BEGIN
    OPEN c1;
    FETCH c1 INTO v_sid, v_serial;
    CLOSE c1;
     DBMS_MONITOR.SESSION_TRACE_ENABLE(v_sid,v_serial, TRUE, true);
     execute immediate 'alter session set tracefile_identifier= JEAN';
     execute immediate 'alter session set max_dump_file_size=unlimited';
END;
ALTER TRIGGER "SYSTEM"."TRG_TRACE" DISABLE