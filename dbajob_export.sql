set serveroutput on

DECLARE
 callstr VARCHAR2(4000);
BEGIN
  sys.dbms_ijob.FULL_EXPORT(&jobno, callstr);
  dbms_output.put_line(callstr);
END;
/