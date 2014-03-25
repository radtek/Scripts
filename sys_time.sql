select stat_name, seconds, round((seconds / total_sec) * 100, 2) as "pct%"
from (  select stat_name, sum(trunc(value/1000000)) over (partition by stat_name)  seconds, sum(value/1000000) over() total_sec
	from v$sys_time_model 
	order by seconds desc)
order by seconds desc;
