col inst_id for 99999
col name for a50
col value for a100

accept p_name prompt "informe o nome do parametro": 

select inst_id, name, value 
from gv$parameter 
where upper(name) like upper('&p_name')
/


undef p_name