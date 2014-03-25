prompt ver arquivo ageout.txt
prompt listar alocações desde ultima consulta que fizeram mais solicitações de espaço na sharedpool que fizerem outros cairem
spool ageout.txt
SELECT *
FROM x$ksmlru 
WHERE ksmlrnum>0;
spool off
