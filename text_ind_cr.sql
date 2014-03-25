set long 64000
set pages 0
set heading off

define owner=&owner
define indexName=&indexName

select ctxsys.ctx_report.CREATE_INDEX_SCRIPT('&owner'||'.'||'&indexName') from dual;

undefine owner
undefine indexName

set pages 1000
set heading on