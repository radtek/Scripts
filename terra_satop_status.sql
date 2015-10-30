col nome for a30
col procedimento for a80

select nome, procedimento, data_ini, data_fim, timeout,data_executado, round((data_fim - data_ini) * 1440, 2) as hrs
from prd_satop.trr_processos 
where trunc(data_ini) > trunc(sysdate - 5) 
order by  data_ini
/
