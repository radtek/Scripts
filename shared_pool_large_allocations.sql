prompt Erro ORA-04031  é sinalizado somente após o processo de clean rodar liberar espaço e mesmo assim não tem espaço suficiente para alocação
prompt normalmente ocorre devido a uma grande fragamentação e é necessário alocação continua
prompt 
prompt este script demostra a quantidade de memoria continua que foi alocada assim podemos ver quais os tende a ter mais problemas de alocação
prompt e podem gerar erros. > 5 problema > 10 grande problema > 20 pinar certo
prompt 
prompt ver arquivo ageout.txt depois que consulta oracle faz o purge
prompt 
spool ageout.txt
select * from x$ksmlru where ksmlrsiz > 5000;
spool off
