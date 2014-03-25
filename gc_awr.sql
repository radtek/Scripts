def instance_number=&instance_number

SELECT a.INSTANCE_NUMBER	
, to_char(b.begin_interval_time,'hh24:mi') as hr
,CLASS
,SUM(CR_BLOCK)CR_BLOCK
,SUM(CR_BUSY)CR_BUSY
,SUM(CR_CONGESTED)CR_CONGESTED
,SUM(CURRENT_BLOCK)CURRENT_BLOCK
,SUM(CURRENT_BUSY)CURRENT_BUSY
,SUM(CURRENT_CONGESTED)CURRENT_CONGESTED
FROM DBA_HIST_INST_CACHE_TRANSFER a, dba_hist_snapshot b 
WHERE (a.instance_number = &instance_number or &instance_number=0)
   and a.INSTANCE_NUMBER = b.INSTANCE_NUMBER
   and to_char(b.begin_interval_time,'hh24:mi') between '01:00' and '24:00'
   and to_char(b.begin_interval_time,'dd-mon')  = to_char(sysdate - &dias, 'dd-mon')   
group by a.INSTANCE_NUMBER	
,CLASS   
, to_char(b.begin_interval_time,'hh24:mi') 
order by a.INSTANCE_NUMBER, CLASS, hr;

undef instance_number
