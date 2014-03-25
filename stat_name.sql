
define stat_name='&stat_name'

select name, class
from V$STATNAME
where upper(name) like upper('&stat_name')
order by name;

undefine stat_name
