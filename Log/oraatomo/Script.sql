select owner||'.'||object_name "OBJECT",object_type TYPE,LAST_DDL_TIME
from dba_objects
where status = 'INVALID'
and owner IN ('VCMLIVE','VCMMGMT','VCMSYS')
order by 1;

alter session set current_schema=VCMMGMT;
@C:\Script\Log\oraatomo\vcmmgmt\PKG_VCM_MGMT_CHANNEL_CONTENT.sql

alter session set current_schema=VCMLIVE;
@C:\Script\Log\oraatomo\vcmlive\PKG_VCM_MGMT_CHANNEL_CONTENT.sql

select owner||'.'||object_name "OBJECT",object_type TYPE,LAST_DDL_TIME
from dba_objects
where status = 'INVALID'
and owner IN ('VCMLIVE','VCMMGMT','VCMSYS')
order by 1;

select 'alter '||decode(object_type,'PACKAGE BODY','PACKAGE',object_type)
||' '||owner||'."'||object_name||'" compile '||
decode(object_type,'PACKAGE BODY','BODY;',';')
from dba_objects
where status = 'INVALID' 
  and owner IN ('VCMLIVE','VCMMGMT','VCMSYS')
order by object_type desc;
