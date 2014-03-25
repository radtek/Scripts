prompt Média de tamanho de scrita para LGWR
prompt 	podemos usar valor para determinar o tamanho ideal para stripping do storage, 
prompt 	isso visando maximizar a performance de batch commits ou flush normais, pois um 
prompt  flush poderia ser paralelizado entre discos e stripping é pequeno ou menos que o flush do LGWR

SELECT (small_write_megabytes + large_write_megabytes) total_mb,
	(small_write_reqs + large_write_reqs) total_requests,
	ROUND((small_write_megabytes + large_write_megabytes) * 1024 / (small_write_reqs + large_write_reqs),2) avg_write_kb
FROM v$iostat_function
WHERE function_name = 'LGWR';
