SELECT TYPE,name,
lmode lock_mode , id1, id2, lmode,
DECODE(TYPE, 'TM',(SELECT object_name
FROM dba_objects
WHERE object_id = id1))
table_name
FROM v$lock JOIN v$lock_type USING (type)
WHERE sid = (SELECT sid
FROM v$session
WHERE audsid = USERENV('sessionid'))
and type <> 'AE';