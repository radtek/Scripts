set long 99999
col query format a9999 wrapped

select query
from dba_mviews
where mview_name like upper('&mviewname')
and owner = upper('&owner'); 
