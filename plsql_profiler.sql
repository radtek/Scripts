prompt Listar 5 comandos tops em tempo de processamento total
prompt executar PLSQL utilizando DBMS_PROFILER antes 
prompt exemplos:
prompt		ReturnCode := DBMS_PROFILER.start_profiler('Profiler Demo 2');
prompt		ReturnCode := DBMS_PROFILER.stop_profiler;
WITH plsql_qry AS (
	SELECT u.unit_name, line#,
		  ROUND (d.total_time / 1e9) time_ms,
		  round(d.total_time * 100 / sum(d.total_time) over(),2) pct_time,
		  d.total_occur as execs,
		  substr(ltrim(s.text),1,40) as text,
		  dense_rank() over(order by d.total_time desc) ranking 
	FROM plsql_profiler_runs r 
		JOIN plsql_profiler_units u USING (runid)
		JOIN plsql_profiler_data d  USING (runid, unit_number)
		LEFT OUTER JOIN all_source s ON ( s.owner = u.unit_owner AND s.TYPE = u.unit_type AND s.NAME = u.unit_name	AND s.line = d.line# )
	WHERE r.run_comment = '&profile_name')
select unit_name,line#,time_ms,pct_time,execs,text
from plsql_qry
where ranking <=5
ORDER BY ranking;
