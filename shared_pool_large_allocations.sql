prompt Erro ORA-04031  � sinalizado somente ap�s o processo de clean rodar liberar espa�o e mesmo assim n�o tem espa�o suficiente para aloca��o
prompt normalmente ocorre devido a uma grande fragamenta��o e � necess�rio aloca��o continua
prompt 
prompt este script demostra a quantidade de memoria continua que foi alocada assim podemos ver quais os tende a ter mais problemas de aloca��o
prompt e podem gerar erros. > 5 problema > 10 grande problema > 20 pinar certo
prompt 
prompt ver arquivo ageout.txt depois que consulta oracle faz o purge
prompt 
spool ageout.txt
select * from x$ksmlru where ksmlrsiz > 5000;
spool off
