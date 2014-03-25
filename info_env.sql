col host_name format a20
col services format a40
col caracterset  format a20

select instance_name, host_name, version, (select gi.value from gv$parameter gi where gi.name = 'service_names' and gi.inst_id = g.inst_id) as services, 
(select value from nls_database_parameters where parameter = 'NLS_CHARACTERSET'	) as caracterset, 
(SELECT ROUND(SUM(decode(ts.CONTENTS, 'UNDO', coalesce(tf.bytes, df.bytes), 0)) / 1024 / 1024 / 1024) + 
       ROUND(SUM(decode(ts.CONTENTS, 'TEMPORARY', coalesce(tf.bytes, df.bytes), 0)) / 1024 / 1024 / 1024) +
       ROUND(SUM(decode(ts.CONTENTS, 'PERMANENT', coalesce(tf.bytes, df.bytes), 0)) / 1024 / 1024 / 1024) 
from dba_tablespaces ts
     left join dba_data_files df
	on ts.tablespace_name = df.tablespace_name
     left join dba_temp_files tf
	on ts.tablespace_name = tf.tablespace_name) as dbsize_GB, 
	(SELECT MAX(GB) AS GB
	FROM (select  
	   round(sum(BLOCKS*BLOCK_SIZE) / 1024 / 1024 / 1024) GB
	FROM v$archived_log
	WHERE COMPLETION_TIME > (sysdate - 30)
	group by to_char(trunc(COMPLETION_TIME,'DD'), 'MONTH DD'))) max_arch_day_GB
from gv$instance g
order by instance_name;
