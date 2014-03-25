prompt
prompt grande numero de invaldation indica problema de parse 
prompt reloads indica alguma pressão de memoria a memoria está sendo desalocada para outro ocupar seguidamente
prompt 
prompt shared pool é alocada em blocks evitando a falta de espaço por fragmentação, objetos podem ser desalocados não continuos
prompt reserved size é um espaço separado para alocações maiores e mais raras de objetos, 04031 pode ser devido a falta de espaço neste pool
prompt 
prompt
SELECT NAMESPACE, PINS, PINHITS, RELOADS, INVALIDATIONS
FROM V$LIBRARYCACHE
ORDER BY NAMESPACE;

SELECT SUM(PINHITS)/SUM(PINS) FROM V$LIBRARYCACHE;
