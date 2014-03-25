prompt versao para 11g
prompt pode indetificar dispararidade de IOs entres os discos dentro do mesmo DG
prompt o ASM faz o balanceamento dos blocos de acordo com o tamanho dos discos, ou seja, 
prompt discos grande tem IO maior que discos pequenos dentro do mesmo DG
prompt ideal todos discos do mesmo tamanho
prompt 
prompt opções:
prompt 		group_number = 0 para todos
prompt 		group_name = % para todos
prompt 
col disk_path format a30

define group_name = &group_name
define group_number = &group_number


SELECT d.PATH disk_path, 
		d.total_mb,
		ROUND(ds.read_secs * 100 / ds.reads, 2) avg_read_ms,
		ROUND(ds.write_secs * 100/ ds.writes, 2) avg_writes_ms,
		ds.reads/1000 + ds.writes/1000 io_1k,
		ds.read_secs +ds.write_secs io_secs,
		ROUND((d.reads + d.writes) * 100 / SUM(d.reads + d.writes) OVER (),2) pct_io,
		ROUND((ds.read_secs +ds.write_secs)*100/ SUM(ds.read_secs +ds.write_secs) OVER (),2) pct_time
FROM v$asm_diskgroup_stat dg
	 JOIN v$asm_disk_stat d 
		ON (d.group_number = dg.group_number)
	JOIN (SELECT group_number, 
				disk_number disk_number, 
				SUM(reads) reads,
				SUM(writes) writes, 
				ROUND(SUM(read_time), 2) read_secs,
				ROUND(SUM(write_time), 2) write_secs
		  FROM gv$asm_disk_stat
		  WHERE mount_status = 'OPENED'
		  GROUP BY group_number, disk_number) ds
		ON  ds.group_number = d.group_number
		AND ds.disk_number = d.disk_number
WHERE ((dg.group_number = &group_number or &group_number = 0)
	and (dg.name like '&group_name'))
AND d.mount_status = 'OPENED'
ORDER BY d.PATH;

undefine group_name 
undefine group_number
