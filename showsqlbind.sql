

col username format a5
col sqlid format a14
col sql_child_number format 9
col name format a4
col value_string format a8
col last_captured format a9

select s.sid,
s.username,
sq.sql_text,
s.sql_hash_value,
s.sql_id,
s.sql_child_number,
spc.name,
spc.value_string,
last_captured
from v$sql_bind_capture spc, v$session s,v$sql sq
where s.sql_hash_value = spc.hash_value
and s.sql_address = spc.address
and sq.sql_id=s.sql_id
and spc.was_captured='YES'
and s.type<>'BACKGROUND'
and s.status='ACTIVE'
and s.sid = &sid;
