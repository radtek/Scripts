set pages 2000
set lines 121
undef owner
select 'alter table '||owner||'."'||table_name||'" drop constraint '||constraint_name||';'
from dba_constraints
where owner in (&&Owner) and
      r_owner in (&&Owner) and
      constraint_type = 'R' and
      owner not in ('SYS','SYSTEM','OUTLN','DBSNMP','PUBLIC')
union all
select 'drop '||object_type||' '||owner||'.'||object_name||';'
from dba_objects
where object_type in ('PACKAGE','SEQUENCE','SYNONYM','VIEW',
                      'PROCEDURE','FUNCTION') and
      owner in (&&Owner) and
      owner not in ('SYS','SYSTEM','OUTLN','DBSNMP','PUBLIC')
union all
select 'drop     table '||owner||'."'||table_name||'";'
from dba_tables
where owner in (&&Owner) and
      owner not in ('SYS','SYSTEM','OUTLN','DBSNMP','PUBLIC')
union all
select 'drop public synonym '||synonym_name||';'
from dba_synonyms
where owner in (&&Owner) and
      table_owner not in ('SYS','SYSTEM','OUTLN','DBSNMP','PUBLIC')
union all
select 'DROP TYPE '||owner||'.'||type_name||';'
from dba_types
where owner in (&&Owner)
union all
select 'drop '||object_type||' '||owner||'.'||object_name||';'
from dba_objects
where object_type like 'JAVA%'
and owner not in ('SYS','SYSTEM','OUTLN','DBSNMP','PUBLIC')
and owner in (&&Owner)
union all
select 'DROP MATERIALIZED VIEW '||owner||'.'||MVIEW_NAME||';'
from dba_mviews
where owner  in (&&Owner)
/
undef owner
