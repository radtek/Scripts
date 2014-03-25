set long 64000
set pages 0
set heading off

define owner=&owner
define indexName=&indexName

select ctxsys.ctx_report.describe_index('&owner'||'.'||'&indexName') from dual;

undefine owner
undefine indexName

set pages 1000