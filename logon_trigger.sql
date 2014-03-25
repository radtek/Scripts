WHENEVER SQLERROR EXIT FAILURE;
-- força a falha
select aaaa from dual;

-- criar como SYSTEM
CREATE OR REPLACE TRIGGER SYS.trace_login_trigger
AFTER LOGON ON DATABASE
BEGIN	
	if (ora_login_user =  'OPENCMS') then
		EXECUTE IMMEDIATE 'alter session set statistics_level=ALL';
		EXECUTE IMMEDIATE 'alter session set max_dump_file_size=UNLIMITED';
		EXECUTE IMMEDIATE 'alter session set timed_statistics = true';
		EXECUTE IMMEDIATE 'alter session set events ''10046 trace name context forever, level 12''';
	
		EXECUTE IMMEDIATE 'alter session set sql_trace = true';
		EXECUTE IMMEDIATE 'alter session set tracefile_identifier=''OPENCMS''';
	end if ;
END set_trace;
/

grant alter session to &username;

CREATE OR REPLACE TRIGGER SYSTEM.trace_login_trigger
AFTER LOGON
ON DATABASE
BEGIN
IF SYS_CONTEXT ('USERENV', 'MODULE')  LIKE '%TOAD%'
   THEN
   
	DBMS_SESSION.session_trace_enable (waits => TRUE,
							binds => FALSE,
							plan_stat => 'all_executions' ---> 11g
							);
      EXECUTE IMMEDIATE 'alter session set tracefile_identifier=TOAD';

   END IF;
END;




------------------



CREATE OR REPLACE TRIGGER SYSTEM.trace_login_trigger
AFTER LOGON ON DATABASE
WHEN (USER = 'AFV')
BEGIN
	EXECUTE IMMEDIATE 'alter session set statistics_level=ALL';
	EXECUTE IMMEDIATE 'alter session set max_dump_file_size=UNLIMITED';
	EXECUTE IMMEDIATE 'alter session set timed_statistics = true';
	EXECUTE IMMEDIATE 'alter session set events ''10046 trace name context forever, level 12''';
	EXECUTE IMMEDIATE 'alter session set sql_trace = true';
	EXECUTE IMMEDIATE 'alter session set tracefile_identifier=''CARGA_AFV''';
END set_trace;
/

grant alter session to &USERNAME;