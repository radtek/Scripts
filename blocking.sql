Prompt
Prompt *** Script para verificar lock de usuario ***
Prompt *** Indica qual usuario esta bloqueando os demais ***
Prompt

col machine for a20
SELECT distinct
        DECODE( l.block, 0, '  ', 'YES' ) BLOCKER,
         DECODE( l.request, 0, '  ', 'YES' ) WAITER, 
       s.sid, s.username, s.osuser, s.machine, s.program
    FROM v$lock l
		 INNER JOIN v$session s
			ON l.sid = s.sid
   WHERE (l.request > 0 OR l.block > 0)    
   ORDER BY 1, 2 DESC
/