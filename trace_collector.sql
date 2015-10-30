PROMPT
PROMPT
PROMPT *******************************************************
PROMPT Welcome to the most inteligent SQL trace Collector Tool
PROMPT *******************************************************
PROMPT 
PROMPT
set timi off
set feed off
set verify off
col "Info" for a120
select 'You are running a client over an '||version||' instance' "Info" from v$instance 
union all 
select 'You are session sid: '||TO_NUMBER(SUBSTR(dbms_session.unique_session_id,1,4),'XXXX')||' and serial '||serial# "Info" from v$session where sid=TO_NUMBER(SUBSTR(dbms_session.unique_session_id,1,4),'XXXX')
union all 
select 'Your Potential Trace File is: '||value ||'/'||(select instance_name from v$instance) ||'_ora_'||(select spid||case when traceid is not null then '_'||traceid else null end from v$process where addr = (select paddr from v$session where sid = (select sid from v$mystat where rownum = 1))) || '.trc' "Info" from v$parameter where name = 'user_dump_dest';

PROMPT
PROMPT
PROMPT Current Active Sessions
PROMPT

col machine format a27
col program format a45
col username format a20
col osuser for a25
col sid format 99999
col spid for a10
col status for a10
col server for a15
select a.sid,a.serial#,to_char(b.spid) spid, a.username,last_call_et,a.sql_hash_value,
osuser,a.machine,a.program,a.status,logon_time,server
from v$session a, v$process b
where a.username is not null
and a.paddr = b.addr
and status = 'ACTIVE'
order by 5;

PROMPT
PROMPT
undef sess
ACCEPT sess number PROMPT 'Which Would be the traced SID? Type 0 in case of own session: '
select sid,serial#,username,osuser from v$session where sid = decode(&sess,0,TO_NUMBER(SUBSTR(dbms_session.unique_session_id,1,4),'XXXX'),&sess);
PROMPT
undef ident
ACCEPT ident char PROMPT 'Would you like to change Trace File Identifier? Type N in case of NO: '
declare
	id varchar2 (200) := '&ident';
	sess number(10) := &sess;
	newpath varchar2(200);
begin
	if id <> 'N' then
		if sess = 0 then
			execute immediate 'alter session set TRACEFILE_IDENTIFIER='||id;
			select 'Your Trace File has been changed to: '||value ||'/'||(select instance_name from v$instance) ||'_ora_'||
 				(select spid||case when traceid is not null then '_'||id else null end
				from v$process where addr = (select paddr from v$session
							where sid = (select sid from v$mystat where rownum = 1))) || '.trc' tracefile into newpath
				from v$parameter where name = 'user_dump_dest';
		else 
			select 'Your Trace File has been changed to: '||value ||'/'||(select instance_name from v$instance) ||'_ora_'||
 				(select spid||case when traceid is not null then '_'||id else null end
				from v$process where addr = (select paddr from v$session
							where sid = sess)) || '.trc' tracefile into newpath
				from v$parameter where name = 'user_dump_dest';
		
		end if;
		dbms_output.put_line(newpath);
	else
		if sess = 0 then
			select 'Your Trace File has been changed to: '||value ||'/'||(select instance_name from v$instance) ||'_ora_'||
 				(select spid||case when traceid is not null then '_'||traceid else null end
				from v$process where addr = (select paddr from v$session
							where sid = (select sid from v$mystat where rownum = 1))) || '.trc' tracefile into newpath
				from v$parameter where name = 'user_dump_dest';
		else 
			select 'Your Trace File has been changed to: '||value ||'/'||(select instance_name from v$instance) ||'_ora_'||
 				(select spid||case when traceid is not null then '_'||traceid else null end
				from v$process where addr = (select paddr from v$session
							where sid = sess)) || '.trc' tracefile into newpath
				from v$parameter where name = 'user_dump_dest';
		
		end if;
		dbms_output.put_line(newpath);
	end if;
end;
/
PROMPT
PROMPT

PROMPT 'Starting level 12 SQL Trace on picked session' 
declare
	version number(4);
	sid number;
	ser number;
	sess number := &sess;
	parname varchar2(200);
	parval varchar2(200);
	cursor cur is
		select name,lower(value) value from v$parameter where lower(name) in ('sql_trace','max_dump_file_size','timed_statistics');
begin
	select sid,serial# into sid,ser from v$session where sid = decode(&sess,0,TO_NUMBER(SUBSTR(dbms_session.unique_session_id,1,4),'XXXX'),&sess);
	for reg in cur loop
		parname := reg.name;
		parval := to_char(reg.value);
		if parname = 'sql_trace' then
			if parval <> 'true' then
				dbms_output.put_line('Checking Parameter SQL_TRACE - NOK - Changing session value');
				execute immediate 'ALTER SESSION SET SQL_TRACE = TRUE';				
			else
				dbms_output.put_line('Checking Parameter SQL_TRACE - OK');	
			end if;
		elsif parname = 'max_dump_file_size' then
			if parval <> 'unlimited' then
				dbms_output.put_line('Checking Parameter MAX_DUMP_FILE_SIZE - NOK - Changing session value');
				execute immediate 'ALTER SESSION SET MAX_DUMP_FILE_SIZE = UNLIMITED';				
			else
				dbms_output.put_line('Checking Parameter MAX_DUMP_FILE_SIZE - OK');	
			end if;

		elsif parname = 'timed_statistics' then
			if parval <> 'true' then
				dbms_output.put_line('Checking Parameter TIMED_STATISTIC - NOK - Changing session value');
				execute immediate 'ALTER SESSION SET TIMED_STATISTIC = TRUE';				
			else
				dbms_output.put_line('Checking Parameter TIMED_STATISTIC - OK');	
			end if;
		end if;
	end loop;
	select to_number(substr(version,1,instr(version,'.',1)-1)) into version from v$instance;
	if version > 9 then
		dbms_output.put_line('Seting up SQL Trace event Leve 12 for Databases 10g and later');
		dbms_monitor.session_trace_enable(sid,ser, TRUE, TRUE);
	else
		dbms_output.put_line('Seting up SQL Trace event Leve 12 for Databases 9i and before');
		if sess = 0 then
			execute immediate 'alter session set events ''10046 trace name context forever, level 12''';
   			execute immediate 'alter session set "_cursor_plan_unparse_enabled"=false';
		else
			execute immediate 'sys.dbms_system.set_sql_trace_in_session('||sid||','||ser||',TRUE)';
			execute immediate 'alter session set "_cursor_plan_unparse_enabled"=false';
		end if;
	end if;
end;
/
PROMPT
PROMPT
PROMPT 'You are ready to go, put you SQL to run and enjoy your trace file! :)'
set timi on
set feed on
set verify on
