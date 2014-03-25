select
   *
from
   v$sess_time_model
where
   sid = &sid
order by 
   value desc;
