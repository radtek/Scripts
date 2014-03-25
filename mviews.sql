prompt informe % para todos do owner
select mview_name, rewrite_enabled, refresh_mode , refresh_method , last_refresh_date, last_refresh_type, staleness, STALE_SINCE, compile_state, build_mode , fast_refreshable, updatable, UPDATE_LOG
from dba_mviews
where mview_name like upper('&mviewname')
and owner = upper('&owner'); 
