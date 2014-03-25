prompt result cache statistics
prompt para habilitar:
prompt - RESULT_CACHE_MODE: modo de operação do result cach
prompt 				- OFF: Desabilitado
prompt 				- MANUAL: somente consulta com RESULT_CACHE hint ou query que acessa tabelas com RESULT_CACHE(MODE=FORCE) (somente 11g r2)
prompt 				- FORCE: Todas querys (problemas com latch)
prompt - RESULT_CACHE_MAX_SIZE: tamanho do result cache, por default é 1% da shared pool 
prompt - RESULT_CACHE_MAX_RESULT: maximo de percentual do cache que por ser consumindo por 1 single result set, mair que isso não vai para cache
prompt 
prompt - Eficiencia:
prompt 					- Create Count Success—The number of result set caches created.
prompt 					- Find Count—The number of queries that found a result set in the cache.
prompt 					- Invalidation Count—The number of result set caches that were invalidated when DML changed the contents of a dependent object.
prompt 					- Delete Count Valid—The number of valid result sets removed to make way for new result sets. (Result sets are aged out using a prompt LRU)
prompt 

SELECT name,value FROM v$result_cache_statistics;