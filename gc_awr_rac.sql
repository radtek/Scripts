
def instance_number=&instance_number

prompt
prompt demostra valores relacionado com gc_resouces
prompt informe o parametro dias relativo ao dia atual, ex: 1 para dia de ontem e 2 para antes de ontem
prompt 
prompt How To : ORA-4031 Due To Large 'GCS RESOURCES' And 'GCS SHADOWS'
prompt 

break on name skip 1 

select a.INSTANCE_NUMBER, 
	   name, 
	   to_char(b.begin_interval_time,'hh24:mi') as hr, 
	   round(SUM(bytes / 1024 / 1024)) AS MB
from dba_hist_sgastat a, dba_hist_snapshot b 
where pool='shared pool' 
and a.snap_id=b.snap_id
and (a.instance_number = &instance_number or &instance_number=0)
and a.INSTANCE_NUMBER = b.INSTANCE_NUMBER
and to_char(begin_interval_time,'hh24:mi') between '01:00' and '24:00'
and to_char(begin_interval_time,'dd-mon')  = to_char(sysdate - &dias, 'dd-mon')
and (UPPER(a.name) like 'GCS%' or UPPER(a.name) like 'GES%'or UPPER(a.name) like 'KCL%')
group by a.INSTANCE_NUMBER, 
	     name, 
	     to_char(b.begin_interval_time,'hh24:mi')  
order by INSTANCE_NUMBER, name, hr;

undef instance_number