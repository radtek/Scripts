define sql_id=&sql_id
col VALUE_STRING for a40
col name for a20
col position for 9999
SELECT NAME, POSITION, DATATYPE_STRING, VALUE_STRING, LAST_CAPTURED 
FROM (
	SELECT NAME, POSITION, DATATYPE_STRING, VALUE_STRING, LAST_CAPTURED
	FROM DBA_HIST_SQLBIND A
	WHERE A.SQL_ID = '&sql_id'
	 AND SNAP_ID = (SELECT MAX(SNAP_ID) FROM DBA_HIST_SQLBIND WHERE SQL_ID = '&sql_id')
	 ORDER BY SNAP_ID DESC, NAME )
WHERE ROWNUM < 500
order by position
/

SELECT 'var ' || replace(NAME, ':', '') || ' '  || DATATYPE_STRING || ';' || chr(13) || chr(10) ||
       'exec ' || name || ':=' || VALUE_STRING || ';'
FROM (
	SELECT NAME, POSITION, DATATYPE_STRING, VALUE_STRING, LAST_CAPTURED
	FROM DBA_HIST_SQLBIND A
	WHERE A.SQL_ID = '&sql_id'
	 AND SNAP_ID = (SELECT MAX(SNAP_ID) FROM DBA_HIST_SQLBIND WHERE SQL_ID = '&sql_id')
	 ORDER BY SNAP_ID DESC, NAME )
WHERE ROWNUM < 500
order by position
/


undef sql_id



