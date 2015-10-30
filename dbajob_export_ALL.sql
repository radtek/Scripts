set serveroutput on 

DECLARE
 callstr VARCHAR2(4000);
BEGIN
  for c1 in (select job from dba_jobs where log_user not in ('SYS', 'SYSTEM')) 
   loop
  	sys.dbms_ijob.FULL_EXPORT(c1.job, callstr);
	dbms_output.put_line(callstr);
  end loop;
END;
/
