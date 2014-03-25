select b.address,b.hash_value as sqlid,b.child_number,b.plan_hash_value,b.sql_text
from v$session a, v$sql b
where a.sql_address = b.address
and a.sql_hash_value = b. hash_value
and a.sid=&sid
/
