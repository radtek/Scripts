SELECT ROUND(SUM(decode(ts.CONTENTS, 'UNDO', coalesce(tf.bytes, df.bytes), 0)) / 1024 / 1024 / 1024) GB_UNDO, 
       ROUND(SUM(decode(ts.CONTENTS, 'TEMPORARY', coalesce(tf.bytes, df.bytes), 0)) / 1024 / 1024 / 1024) GB_TEMP,
       ROUND(SUM(decode(ts.CONTENTS, 'PERMANENT', coalesce(tf.bytes, df.bytes), 0)) / 1024 / 1024 / 1024) GB_DATA, 
       ROUND(SUM(decode(ts.CONTENTS, 'PERMANENT', decode(ts.status, 'ONLINE', coalesce(tf.bytes, df.bytes), 0), 0)) / 1024 / 1024 / 1024) GB_DATA_ONLINE,
       ROUND(SUM(decode(ts.CONTENTS, 'PERMANENT', decode(ts.status, 'READ ONLY', coalesce(tf.bytes, df.bytes), 0), 0)) / 1024 / 1024 / 1024) GB_DATA_READ_ONLY,
       ROUND(SUM(decode(ts.CONTENTS, 'PERMANENT', decode(df.online_status, 'OFFLINE', coalesce(tf.bytes, df.bytes), 0), 0)) / 1024 / 1024 / 1024) GB_DATA_OFFLINE, 
       ROUND(MAX((select sum(BYTES) / 1024/ 1024 / 1024 GB_REDO from v$log)),2) REDO_GB
from dba_tablespaces ts
     left join dba_data_files df
	on ts.tablespace_name = df.tablespace_name
     left join dba_temp_files tf
	on ts.tablespace_name = tf.tablespace_name;