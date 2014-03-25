break on inst_id skip 1

select inst_id, name, round((bytes) / 1024 / 1024) value_MB 
from gv$sgastat 
where pool='large pool'
order by 1, 3;

clear breaks