col parsed format a6
col sql_text format a40
set lines 200
set pages 300

define sqlid=&sqlid

select     
 sql_text,
 parsing_schema_name as parsed,
 elapsed_time_delta/1000/1000 as elapsed_sec,
 stat.snap_id,
 to_char(snap.end_interval_time,'dd.mm hh24:mi:ss') as snaptime,
 txt.sql_id
from     
 dba_hist_sqlstat stat,
 dba_hist_sqltext txt,
 dba_hist_snapshot snap
where     
 stat.sql_id=txt.sql_id and
 stat.snap_id=snap.snap_id and
 snap.begin_interval_time>=sysdate-1 and
 stat.sql_id = '&&sqlid' and 
 parsing_schema_name not in ('SYS','SYSMAN','MDSYS','WKSYS')
order by snaptime asc;

undef sqlid