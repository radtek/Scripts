col trigger_name format a30
col trigger_type format a20
col column_name format a20
col TRIGGERING_EVENT  format a15
col REFERENCING_NAMES  format a15
col WHEN_CLAUSE  format a30
col STATUS  format a10
col ACTION_TYPE  format a20

select trigger_name, trigger_type, column_name, TRIGGERING_EVENT, REFERENCING_NAMES, WHEN_CLAUSE, STATUS, ACTION_TYPE
from dba_triggers
where TABLE_OWNER like upper('&owner')
and TABLE_NAME like upper('&table_name');
