prompt
prompt grande numero de invaldation indica problema de parse 
prompt reloads indica alguma press�o de memoria a memoria est� sendo desalocada para outro ocupar seguidamente
prompt 
prompt shared pool � alocada em blocks evitando a falta de espa�o por fragmenta��o, objetos podem ser desalocados n�o continuos
prompt reserved size � um espa�o separado para aloca��es maiores e mais raras de objetos, 04031 pode ser devido a falta de espa�o neste pool
prompt 
prompt
SELECT NAMESPACE, PINS, PINHITS, RELOADS, INVALIDATIONS
FROM V$LIBRARYCACHE
ORDER BY NAMESPACE;

SELECT SUM(PINHITS)/SUM(PINS) FROM V$LIBRARYCACHE;
