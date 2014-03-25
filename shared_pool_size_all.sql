select * 
from (select name, round(bytes / 1024 / 1024) MB from v$sgastat where pool = 'shared pool' order by 2 desc) where rownum < 20 ;