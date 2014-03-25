col O_OBJECT_NAME format a30
col D_OBJECT_NAME format a30
col O_OBJECT_TYPE format a20
col D_OBJECT_TYPE format a20
prompt *** gerar lista de problemas para criar sinonimos para todos os objetos do schema de origem no schema de destino **
prompt casos onde o schema de origem tem objeto com o mesmo nome do schema de destino
SELECT O.OBJECT_NAME AS O_OBJECT_NAME,
	O.OBJECT_TYPE AS O_OBJECT_TYPE,
	D.OBJECT_NAME AS D_OBJECT_NAME,
	D.OBJECT_TYPE AS D_OBJECT_TYPE
FROM DBA_OBJECTS O
	INNER JOIN DBA_OBJECTS D
		ON O."OBJECT_NAME" = D."OBJECT_NAME"
WHERE D.OWNER = UPPER('&destino')
	AND O.OWNER = UPPER('&origem')
	AND D.OBJECT_TYPE IN ('SEQUENCE','PROCEDURE','PACKAGE','TABLE','FUNCTION')
	AND O.OBJECT_TYPE IN ('SEQUENCE','PROCEDURE','PACKAGE','TABLE','FUNCTION')
ORDER BY O."OBJECT_NAME",
	O.OBJECT_TYPE;