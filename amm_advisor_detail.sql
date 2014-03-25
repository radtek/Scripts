prompt 
prompt Quando alocamos mais memória não saber qual area que será alocado a memória
prompt Podemos ter mais detalhes se consultar x$kmgsbsmemadv
prompt OBS: precisa ser executada como SYS
prompt 
SELECT memsz memory_size, 
	ROUND(memsz * 100 / base_memsz) memory_size_pct,
	sga_sz sga_size, pga_sz pga_size, dbtime estd_db_time,
	ROUND(dbtime * 100 / base_estd_dbtime) db_time_pct,
	sgatime estd_sga_time, pgatime estd_pga_time
FROM x$kmgsbsmemadv
ORDER BY memsz;
