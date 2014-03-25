undefine event_name
define event_name='&event_name'

select name, parameter1, parameter2, parameter3, wait_class
from v$event_name
where upper(name) like upper('&event_name')
order by name;

undefine event_name