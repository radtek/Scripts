prompt ignora o direct path que faz o bypass no buffer cache
prompt 
SELECT name, block_size / 1024 block_size_kb, current_ size, target_size,prev_size
FROM v$buffer_pool;

SELECT name, 
    block_size / 1024 block_size_kb,
	ROUND(db_block_change / 1000) db_change,
	 ROUND(db_block_gets / 1000) db_gets,
	 ROUND(consistent_gets / 1000) con_gets,
	 ROUND(physical_reads / 1000) phys_rds,
	1 - (physical_reads / (db_block_gets + consistent_gets)) AS "Hit Ratio"
FROM v$buffer_pool_statistics;
