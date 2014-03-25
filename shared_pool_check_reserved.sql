prompt 
prompt verificar a reserved pool que são objetos large alocados e desalocados toda hora
prompt 
prompt se REQUEST_FAILURES > 0 (and increasing) pode indicar problema de sizing deve aumentar shared pool que aloca automaticamente para reserved pool
prompt existe um “_shared_pool_reserved_pct” que controla o percentual da shared pool que vai para reserved pool, default é 5%
prompt 
prompt se REQUEST_MISS = 0 e FREE_MEMORY  > 50% pode indicar uma overalocação
prompt 


col free_space for 999,999,999,999 head "TOTAL FREE"
col avg_free_size for 999,999,999,999 head "AVERAGE|CHUNK SIZE"
col free_count for 999,999,999,999 head "COUNT"
col request_misses for 999,999,999,999 head "REQUEST|MISSES"
col request_failures for 999,999,999,999 head "REQUEST|FAILURES"
col max_free_size for 999,999,999,999 head "LARGEST CHUNK"

select free_space, avg_free_size, free_count, max_free_size, request_misses, request_failures
from v$shared_pool_reserved;
