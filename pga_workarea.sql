PROMPT ## WORKAREA TEMPORARIA EM UTILIZACAO AGORA
PROMPT 
SELECT TO_NUMBER(DECODE(sid, 65535, null, sid)) sid,
       operation_type operation,
       TRUNC(expected_size/1024) esize_kb,
       TRUNC(actual_mem_used/1024) mem_kb,
       TRUNC(max_mem_used/1024) "max_mem_kb",
       number_passes pass,
       TRUNC(TEMPSEG_SIZE/1024) tsize__kb
  FROM V$SQL_WORKAREA_ACTIVE
 ORDER BY 1,2;