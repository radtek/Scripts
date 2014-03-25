def instance_number=&instance_number

prompt
prompt rldpct = reload percent = round(100*((invalidations+reloads)-invalidations)/(pins-pinhits),0)
prompt
prompt informe o parametro dias relativo ao dia atual, ex: 1 para dia de ontem e 2 para antes de ontem
prompt 

col "1" for 99999 justify right
col "2" for 99999 justify right
col "3" for 99999 justify right
col "4" for 99999 justify right
col "5" for 99999 justify right
col "6" for 99999 justify right
col "7" for 99999 justify right
col "8" for 99999 justify right
col "9" for 99999 justify right
col "10" for 99999 justify right
col "11" for 99999 justify right
col "12" for 99999 justify right
col "13" for 99999 justify right
col "14" for 99999 justify right
col "15" for 99999 justify right
col "16" for 99999 justify right
col "17" for 99999 justify right
col "18" for 99999 justify right
col "19" for 99999 justify right
col "20" for 99999 justify right
col "21" for 99999 justify right
col "22" for 99999 justify right
col "23" for 99999 justify right
col "24" for 99999 justify right

select n as namespace,
   max(decode(to_char(begin_interval_time, 'hh24'), 1,rldpct, null)) "1",
   max(decode(to_char(begin_interval_time, 'hh24'), 2,rldpct, null)) "2",
   max(decode(to_char(begin_interval_time, 'hh24'), 3,rldpct, null)) "3",
   max(decode(to_char(begin_interval_time, 'hh24'), 4,rldpct, null)) "4",
   max(decode(to_char(begin_interval_time, 'hh24'), 5,rldpct, null)) "5",
   max(decode(to_char(begin_interval_time, 'hh24'), 6,rldpct, null)) "6",
   max(decode(to_char(begin_interval_time, 'hh24'), 7,rldpct, null)) "7",
   max(decode(to_char(begin_interval_time, 'hh24'), 8,rldpct, null)) "8",
   max(decode(to_char(begin_interval_time, 'hh24'), 9,rldpct, null)) "9",
   max(decode(to_char(begin_interval_time, 'hh24'), 10,rldpct, null)) "10",
   max(decode(to_char(begin_interval_time, 'hh24'), 11,rldpct, null)) "11",
   max(decode(to_char(begin_interval_time, 'hh24'), 12,rldpct, null)) "12",
   max(decode(to_char(begin_interval_time, 'hh24'), 13,rldpct, null)) "13",
   max(decode(to_char(begin_interval_time, 'hh24'), 14,rldpct, null)) "14",
   max(decode(to_char(begin_interval_time, 'hh24'), 15,rldpct, null)) "15",
   max(decode(to_char(begin_interval_time, 'hh24'), 16,rldpct, null)) "16",
   max(decode(to_char(begin_interval_time, 'hh24'), 17,rldpct, null)) "17",
   max(decode(to_char(begin_interval_time, 'hh24'), 18,rldpct, null)) "18",
   max(decode(to_char(begin_interval_time, 'hh24'), 19,rldpct, null)) "19",
   max(decode(to_char(begin_interval_time, 'hh24'), 20,rldpct, null)) "20",
   max(decode(to_char(begin_interval_time, 'hh24'), 21,rldpct, null)) "21",
   max(decode(to_char(begin_interval_time, 'hh24'), 22,rldpct, null)) "22",
   max(decode(to_char(begin_interval_time, 'hh24'), 23,rldpct, null)) "23",
   max(decode(to_char(begin_interval_time, 'hh24'), 24,rldpct, null)) "24"
from (select '"'||namespace||'"' n, begin_interval_time, 
      round(100*((invalidations+reloads)-invalidations)/(pins-pinhits),0) rldpct
from dba_hist_librarycache a, dba_hist_snapshot b 
where (reloads > 0 or invalidations > 0) 
and a.snap_id=b.snap_id
 and (a.instance_number = &instance_number or &instance_number=0)
 and a.INSTANCE_NUMBER = b.INSTANCE_NUMBER
 and to_char(begin_interval_time,'hh24:mi') between '01:00' and '24:00'
 and to_char(begin_interval_time,'dd-mon')  = to_char(sysdate - &dias, 'dd-mon'))
group by n;

undef instance_number