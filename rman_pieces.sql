Accept dt1  prompt 'Begin (dd/mm/yyyy hh24:mi:ss):'
Accept dt2  prompt 'End   (dd/mm/yyyy hh24:mi:ss):'
Accept tag  prompt 'TAG ou % para todos		 :'

column handle format a32
column tag format a20
column DEVICE_TYPE format a10

select 
  b.TAG, 
  b.DEVICE_TYPE, 
  b.HANDLE,  
  b.START_TIME, 
  b.COMPLETION_TIME, 
  round(bytes/1024/1024)  TAM_MB
from v$backup_piece b
where tag like '&tag'
  and start_time between TO_DATE('&dt1', 'dd/mm/yyyy hh24:mi:ss') and TO_DATE('&dt2', 'dd/mm/yyyy hh24:mi:ss')
order by start_time desc;

undef dt1
undef dt2
undef tag