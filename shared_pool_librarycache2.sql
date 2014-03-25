prompt 
prompt Se percentual de reloads tiver muito alto devemos rever tamanho total da shared pool
prompt Se invalidation representar mais de 20% dos reloads então, temos que investigar a origem
prompt 
select namespace, 
	pins, 
	pins-pinhits as loads, 
	reloads, 
	invalidations, 
	round(100*(reloads-invalidations) / (pins-pinhits), 2) "%reloads"
from v$librarycache 
where pins>0
order by namespace;