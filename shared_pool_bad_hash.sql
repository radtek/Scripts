prompt validar consultas com o mesmo hash_value mas com literais diferentes
SELECT hash_value, count(*)
FROM v$sqlarea
GROUP BY hash_value
HAVING count(*) > 5;
