prompt - Sugestão para PGA em V$PGA_TARGET_ADVICE
prompt 			- quando é relizado um sort que precisa ir para disco o oracle consegue medir qual tamanho seria necessário para realizar como "optimal"
prompt 			- colunas:
prompt 				-> PGA_TARGET_FOR_ESTIMATE PGA - target para estimar
prompt 				-> PGA_TARGET_FACTOR - PGA target para estimar relativo a current PGA target (100 é o atual)
prompt 				-> BYTES_PROCESSED - bytes processados nas workareas como sorts e hash joins
prompt 				-> ESTD_TIME - tempo estimado para processar BYTES_PROCESSED
prompt 				-> ESTD_EXTRA_BYTES_RW - bytes processados em single e multipass operations, bytes que não couberam em memória e foram para segmentos temporários
prompt 				-> ESTD_PGA_CACHE_HIT_PERCENTAGE ->  hit de bytes
prompt 				-> ESTD_OVERALLOC_COUNT -> estimativa de overallocations para a PGA value, altos valores indicam que valor da PGA seria não apropriado para demanda
prompt 
prompt 
		 
col pga_target_mb format 99,999 heading "Pga |MB"
col pga_target_factor_pct format 9,999 heading "Pga Size|Pct"
col estd_time format 999,999,999 heading "Estimated|Time (s)"
col estd_extra_mb_rw format 99,999,999 heading "Estd extra|MB"
col estd_pga_cache_hit_percentage format 999.99 heading "Estd PGA|Hit Pct"
col estd_overalloc_count format 999,999 heading "Estd|Overalloc"
set pagesize 1000
set lines 100
set echo on 

SELECT ROUND(pga_target_for_estimate / 1048576) pga_target_mb,
       pga_target_factor * 100 pga_target_factor_pct, estd_time,
       ROUND(estd_extra_bytes_rw / 1048576) estd_extra_mb_rw,
       estd_pga_cache_hit_percentage, estd_overalloc_count
FROM v$pga_target_advice
ORDER BY pga_target_factor;
