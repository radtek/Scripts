
prompt ***** valores em MB
prompt
col tablespace_name for a40

select 
	tablespace_name, 
	to_char(end_interval_time, 'DD/MM/YYYY') AS Interval,
	TABLESPACE_SIZE, 
	TABLESPACE_MAXSIZE, 
	TABLESPACE_USEDSIZE,
	END_INTERVAL_TIME
from (select /*+ LEADING(ts ts2 ss tsu) */ ts.name as tablespace_name, 
		   trunc(end_interval_time)  as end_interval_time,
		   round(MAX(TABLESPACE_SIZE) ) TABLESPACE_SIZE,
		   round(MAX(TABLESPACE_MAXSIZE)    ) TABLESPACE_MAXSIZE,
		   round(MAX(TABLESPACE_USEDSIZE)  ) TABLESPACE_USEDSIZE
	from (select /*+ no_merge */ distinct ss.snap_id, ss.END_INTERVAL_TIME
		  from dba_hist_snapshot ss 
		  where ss.END_INTERVAL_TIME between TO_DATE('&dt1', 'dd/mm/yyyy hh24:mi:ss') and TO_DATE('&dt2', 'dd/mm/yyyy hh24:mi:ss')) ss
		inner join dba_hist_tbspc_space_usage tsu	
				on ss.snap_id = tsu.snap_id
		inner join v$tablespace ts
				on ts.ts# = tsu.tablespace_id
		inner join dba_tablespaces ts2
			on ts2.tablespace_name = ts.name
	where ts.name = '&tablespace_name'	  
	group by ts.name, 
			 trunc(end_interval_time), 
			 ts2.block_size)
order by tablespace_name, end_interval_time;