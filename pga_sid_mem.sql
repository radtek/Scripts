

SELECT pid, category, allocated, used, max_allocated
FROM   v$process_memory
WHERE  pid = (SELECT pid
              FROM   v$process
              WHERE  addr= (select paddr
                            FROM   v$session
                            WHERE  sid = &sid));


prompt 
prompt
prompt ######## PARA DETALHES USE ############
prompt oradebug setospid 9444
prompt ORADEBUG DUMP PGA_DETAIL_GET 22;
prompt 
prompt SELECT category, name, heap_name, bytes, allocation_count,
prompt        heap_descriptor, parent_heap_descriptor
prompt FROM   v$process_memory_detail;
