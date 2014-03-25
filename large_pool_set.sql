select name, round((bytes) / 1024 / 1024) value_MB 
from v$sgastat where pool='large pool'
order by 2;