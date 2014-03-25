undefine sqlid
undefine child_number
define sqlid=&sqlid

col SQL_TEXT format a100
col BIND_NAME format a10
col BIND_STRING format a30
col child_number format 999

select  child_number, b.name BIND_NAME,  b.value_string BIND_STRING, DATATYPE_STRING
from  v$sql_bind_capture b	
where  b.value_string is not null
and b.sql_id='&sqlid'
order by position, child_number, b.name;



undefine sqlid
undefine child_number
