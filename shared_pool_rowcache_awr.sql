def instance_number=&instance_number
col UPDATES for 999999999999999

SELECT a.INSTANCE_NUMBER	
, to_char(b.begin_interval_time,'hh24:mi') as hr
, PARAMETER
, SUM(GETS) AS GETS
, SUM(GETMISSES) AS GETMISSES
, (100*  (SUM(GETS) - SUM(GETMISSES)) / SUM(GETS)) AS PCT_SUCC_GETS
, SUM(MODIFICATIONS) AS  UPDATES
, AVG(TOTAL_USAGE) AVG_TOTAL_USAGE
, SUM(FLUSHES) FLUSHES
FROM DBA_HIST_ROWCACHE_SUMMARY a, dba_hist_snapshot b 
WHERE (a.instance_number = &instance_number or &instance_number=0)
   and a.INSTANCE_NUMBER = b.INSTANCE_NUMBER
   and to_char(b.begin_interval_time,'hh24:mi') between '01:00' and '24:00'
   and to_char(b.begin_interval_time,'dd-mon')  = to_char(sysdate - &dias, 'dd-mon')
   and GETS > 0
group by a.INSTANCE_NUMBER, to_char(b.begin_interval_time,'hh24:mi'), PARAMETER
order by PARAMETER, hr;
   
undef instance_number
