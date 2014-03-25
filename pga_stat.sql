prompt 
prompt - aggregate PGA target parameter  = valor da PGA_AGGREGATE_TARGET
prompt - aggregate PGA auto target = total de memória disponivel para workareas(sort e hash)
prompt - total PGA inuse = total de area alocada para workareas
prompt - total PGA allocated  = quantidade de PGA alocada para todos os propositos
prompt - total freeable PGA memory = total de memória que poderia ser liberada da PGA se fosse necessário para outra area 
prompt - over allocation count = acontece quando o oracle nao tem escolha e precisa expandir a workarea alem do que é indicada pela pga_aggregate_target, 
prompt 	ou seja, indica que a pga_aggregate_target pode estar com valor muito baixo
prompt - bytes processed = total de bytes processados em hash e sorte nas workareas
prompt - extra bytes read/written = quantidade de bytes em single pass ou multi pass, bytes que foram lidos e escritos dos segmentos temporarios, 
prompt 	pois não coube em memória
prompt - cache hit percentage = determina a efetividade da PGA, ou seja, 100% indica todas operações foram em memória
prompt 	
prompt 

select name, 
	case when UNIT = 'bytes' then to_char(round(value / 1024 / 1024)) || 'M' else to_char(value) end as calc_value 
from v$pgastat;