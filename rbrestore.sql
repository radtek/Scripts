accept owner prompt "Informe owner:" 
accept table_name prompt "Informe table_name:"
accept novo_table_name prompt "Informe novo_table_name:"

select 'FLASHBACK TABLE "' || object_name || '" TO BEFORE DROP RENAME TO ' || ' &novo_table_name;'
from dba_recyclebin
where owner = upper('&owner') 
 and original_name = upper('&table_name')
order by owner, original_name;
