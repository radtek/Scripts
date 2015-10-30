define indexname=&indexname
prompt execute antes um validate struture para atualizar as informações:
prompt 		analyze index &indexname validate structure online;
prompt gera lock se for OFFLINE, mas pode ser ONLINE
SELECT 
	NAME,
	PARTITION_NAME, 
	LF_ROWS, 
	LF_ROWS_LEN, 
	DEL_LF_ROWS, 
	DISTINCT_KEYS  , 
	BLKS_GETS_PER_ACCESS, 
	ROWS_PER_KEY, 
	USED_SPACE, 
	DEL_LF_ROWS*100/decode(LF_ROWS, 0, 1, LF_ROWS) PCT_DELETED, 
	(LF_ROWS-DISTINCT_KEYS)*100/ decode(LF_ROWS,0,1,LF_ROWS) DISTINCTIVENESS
FROM index_stats
WHERE NAME like UPPER('&indexname');

undef indexname