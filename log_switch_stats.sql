col  "month" format a10
col  archive_date format a25
col  switches format 999999999

compute AVG of switches on month
compute AVG of switches on REPORT

break on month skip 1 on REPORT skip 1

select
   to_char(trunc(first_time), 'Month') 	"month",
   to_char(trunc(first_time), 'Day : DD-Mon-YYYY') archive_date,
   count(*) switches   
from
   v$log_history lh
where
   trunc(first_time) > last_day(sysdate-100) +1
group by
   trunc(first_time)
order by trunc(first_time);

clear breaks;
clear columns;
clear computes;