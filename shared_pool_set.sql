select round(sum(bytes / 1024 / 1024)) value_MB 
from V$SGASTAT 
where pool = 'shared pool';
