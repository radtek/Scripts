accept spid prompt "informe o SPID:"

select 
   rows_processed 
from 
   v$sql 
where 
   hash_value=
  (select 
      sql_hash_value 
   from 
      v$session 
   where paddr=
   (select addr from v$process where spid='&spid')
  );      

undef spid