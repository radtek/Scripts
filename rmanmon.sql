select operation as "operation",
	object_type as "type",
        status,
        output_device_type as "output_device_type",
        to_char(end_time,'DD-MM-RRRR HH24:MI:SS') as "endtime",
        round(MBYTES_PROCESSED/1024) as "size(MB)"
from
         v$rman_status
where
         operation <> 'CATALOG'
         and trunc(end_time)>=trunc(sysdate-1)
  order by end_time;
