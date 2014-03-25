set timing on 
alter session set statistics_level = all;
alter session set sql_trace = true;
alter session set tracefile_identifier='TRACE_101';
alter session set max_dump_file_size=unlimited;
alter session set timed_statistics = true;
alter session set events '10046 trace name context forever, level 12';
--alter session set events '10053 trace name context forever, level 1'; 

rem evitar bug "ORA-07445 [MSQSUB()+32] When Select From V$SQL_PLAN [ID 791225.1]"
alter session set "_cursor_plan_unparse_enabled"=false; 




/*
begin 
	execute immediate 'alter session set tracefile_identifier=''TRACE_RELATACADO''';
	execute immediate 'alter session set sql_trace = true';
	execute immediate 'alter session set max_dump_file_size=unlimited';
	execute immediate 'alter session set timed_statistics = true';
	execute immediate 'alter session set events ''10046 trace name context forever, level 12''';
	execute immediate 'alter session set "_cursor_plan_unparse_enabled"=false'; 
end;

SPM:
	alter session set events 'trace[RDBMS.SQL_Plan_Management.*]';
	alter session set events 'trace[RDBMS.SQL_Plan_Management.*] off';
*/



	
		