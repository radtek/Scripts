select substr(name,1,60), sum(sharable_mem), count(*)
from v$db_object_cache
group by substr(name,1,60)
having count(*)>50
order by sum(sharable_mem)
/
