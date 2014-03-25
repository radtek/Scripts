SELECT 'kill -9 ' || spid                  
FROM v$process                  
WHERE NOT EXISTS ( SELECT 1                                     
	FROM v$session                                     
	WHERE paddr = addr); 