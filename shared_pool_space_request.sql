prompt ver arquivo ageout.txt
prompt listar aloca��es desde ultima consulta que fizeram mais solicita��es de espa�o na sharedpool que fizerem outros cairem
spool ageout.txt
SELECT *
FROM x$ksmlru 
WHERE ksmlrnum>0;
spool off
