prompt resizes ocorridos na SGA quando SGA_TARGET(ASMM) est� ativada 
set pages 1000
set lines 100
col initial_mb format 9999 heading "Initial|MB"
col final_mb format 9999 heading "Final|MB"
column component format a24
set echo on

SELECT TO_CHAR(end_time, 'HH24:MI') end_time, component, 
       oper_type, oper_mode,
       ROUND(initial_size / 1048576) initial_mb,
       ROUND(final_size / 1048576) final_mb, status
FROM v$sga_resize_ops o
WHERE end_time > SYSDATE - NUMTODSINTERVAL(24, 'HOUR')
ORDER BY end_time DESC;
 

 
 