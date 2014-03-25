col QUERY format a30 wrapped

prompt KNOWN_STALE - dados da mview foi atualizado deste utlimo refresh está incosistente com a master table

select OWNER. MVIEW_NAME, REFRESH_METHOD, LAST_REFRESH_DATE, KNOWN_STALE, INVALID, REWRITE_ENABLED, INC_REFRESHABLE, QUERY
FROM DBA_MVIEW_ANALYSIS;