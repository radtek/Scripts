select sesion.sid,
sesion.username,
name,
isdefault,
value
from v$sql_optimizer_env sql_optimizer_env, v$session sesion
where sesion.sql_hash_value = sql_optimizer_env.hash_value
and sesion.sql_address = sql_optimizer_env.address
and sesion.username is not null
and sesion.sid = &sid;