set lines 2000
prompt
prompt "buffers HW" é high water mark para o buffer em blocos (parallel_execution_message_size), para determinar se o tamanho atual esta pequeno você pode:
prompt comparar valor em bytes da "px msg pool" com "buffers HW" para determinar o pico atingido é alto ou não
prompt

SELECT * FROM V$PX_PROCESS_SYSSTAT WHERE STATISTIC LIKE 'Buffers%';

prompt
prompt advisor
select  * from v$PX_BUFFER_ADVICE;
