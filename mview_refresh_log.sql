col owner for a11
 col error for a200
 col "Tempo(min)" for a10
 col error for a150

 select owner,mview_name,refresh_type,atomic,to_char(start_time,'dd/mm/yyyy hh24:mi:ss'),to_char(end_time,'dd/mm/yyyy hh24:mi:ss'),
 to_char( (end_time-start_time)*24*60,'999.9') "Tempo(min)",substr(last_error,1,150) error
 from refresh_mview_log
 where mview_name like upper('&&Mview_name') and
 owner like upper('&Owner') and
 refresh_type like upper('&Refresh_type') and
 (start_time >= sysdate - &Dias_atras)
 order by start_time
 /
 undef mview_name