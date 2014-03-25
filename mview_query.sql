set long 999999
col query format a9999999

select query
from dba_mviews
where mview_name like upper('&mviewname')
and owner = upper('&owner'); 
