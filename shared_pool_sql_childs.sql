prompt 
prompt demostrar porque as consulta não estão sendo reutilizadas
prompt 
SELECT SA.SQL_TEXT,SA.VERSION_COUNT,SS.*
FROM V$SQLAREA SA,
	V$SQL_SHARED_CURSOR SS
WHERE SA.ADDRESS=SS.ADDRESS
AND SA.VERSION_COUNT > 5
and sa.sql_id = '&sql_id'
ORDER BY SA.VERSION_COUNT;