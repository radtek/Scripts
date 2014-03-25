col name format a15

select group_number, name, type, total_mb, free_mb, round(free_mb / total_mb * 100) AS "free(%)", state
from v$asm_diskgroup;
