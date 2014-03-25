prompt Listar comandos em modo hierarquico, somente 11g
prompt 		-> executar antes @dbmshptab.sql para criar tabelas internas
prompt 		-> executar PLSQL utilizando dbms_hprof antes para gerar arquivo
prompt 		-> pode gerar html report C:\traceFiles>plshprof -output hprof_report hprof_trace.trc 
prompt exemplos:
prompt       hprof_demo_pkg.init(1000);
prompt       dbms_hprof.start_profiling('HPROF_DIR','hprof_trace.trc',max_depth=>10);
prompt       dbms_hprof.stop_profiling ();
prompt       runid :=dbms_hprof.ANALYZE (LOCATION => 'HPROF_DIR', filename => 'hprof_trace.trc', run_comment => 'Hprof demo 1');
prompt descricao "The FUNCTION_ELASPED_TIME column shows the amount of time elapsed in the function alone excluding all time sent in subroutines. "
prompt descricao "the SUBTREE_ELAPSED_TIME column shows the time spend in the function and all its subroutines"
WITH dbmshp AS
( SELECT module||'.'||function as function,
	NVL(pci.calls,f.calls) calls,
	NVL(pci.function_elapsed_time,f.function_elapsed_Time) AS function_elapsed_Time,
	NVL(pci.subtree_elapsed_time,f.subtree_elapsed_time) AS subtree_elapsed_time,
	f.symbolid , 
	pci.parentsymid
FROM dbmshp_runs r
	JOIN dbmshp_function_info f ON (r.runid = f.runid)
	FULL OUTER JOIN dbmshp_parent_child_info pci
		ON (pci.runid = r.runid AND pci.childsymid = f.symbolid)
WHERE r.run_comment='&profiler_name')
SELECT rpad(' ',level)||function as function,calls,
	function_elapsed_time,
	subtree_elapsed_time,
	subtree_elapsed_time-function_elapsed_Time AS subtree_only_time
FROM dbmshp
CONNECT BY PRIOR symbolid = parentsymid
START WITH parentsymid IS NULL;

