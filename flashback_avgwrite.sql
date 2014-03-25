prompt ideal colocar separado dos redo e stripping
prompt fined grained é recomendado
prompt 
SELECT (small_write_megabytes + large_write_megabytes)
	total_write_mb,
	(small_write_reqs + large_write_reqs) total_write_reqs,
	ROUND( (small_write_megabytes + large_write_megabytes) * 1024 / (small_write_reqs + large_write_reqs), 2)
	avg_write_kb
FROM v$iostat_file f
WHERE filetype_name = 'Flashback Log';