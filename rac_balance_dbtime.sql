prompt verificar o balanceamento no cluster validando o dbtime
prompt pode ocorrer sintomas diferentes entre os hosts no cluster desbalanceado
prompt valores abaixo são desde restart e instancias podem restartar em momentos diferentes
prompt 

WITH sys_time AS 
(
 SELECT inst_id, 
	SUM(CASE stat_name WHEN 'DB time' THEN VALUE END) db_time,
	SUM(CASE WHEN stat_name IN ('DB CPU','background cpu time') THEN  VALUE  END) cpu_time
 FROM gv$sys_time_model
 GROUP BY inst_id                 
)
SELECT instance_name,
        ROUND(db_time/1000000,2) db_time_secs,
        ROUND(db_time*100/SUM(db_time) over(),2) db_time_pct,
        ROUND(cpu_time/1000000,2) cpu_time_secs,
        ROUND(cpu_time*100/SUM(cpu_time) over(),2)  cpu_time_pct
FROM     sys_time
	JOIN gv$instance 
		USING (inst_id);