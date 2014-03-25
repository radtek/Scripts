prompt
prompt shared pool free espace
prompt
SELECT inst_id, pool, name, round(bytes / 1024 / 1024) MB FROM 
GV$SGASTAT
WHERE NAME = 'free memory'
AND POOL = 'shared pool';
