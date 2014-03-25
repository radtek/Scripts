prompt	Novos objetos, configurar tablespaces com unlimited:
prompt 		alter tablespace ts_32k storage (maxextents unlimited)

select 
   'alter '||
   object_type||
   ' '||
   object_name||
   ' storage (maxextents unlimited);'
from 
   dba_objects
where 
   object_type in ('TABLE','INDEX')
and owner = '&owner';



