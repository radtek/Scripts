set pages 2000
set lines 121
select 'alter table "'||table_name||'" drop constraint '||constraint_name||';'
from user_constraints
where constraint_type = 'R'
union all
select 'drop '||object_type||' '||object_name||';'
from user_objects
where object_type in ('PACKAGE','SEQUENCE','SYNONYM','VIEW',
                      'PROCEDURE','FUNCTION')
union all
select 'drop     table "'||table_name||'";'
from user_tables
union all
select 'drop public synonym '||synonym_name||';'
from user_synonyms
union all
select 'DROP TYPE '||type_name||';'
from user_types
union all
select 'drop '||object_type||' '||object_name||';'
from user_objects
where object_type like 'JAVA%'
union all
select 'DROP MATERIALIZED VIEW '||MVIEW_NAME||';'
from user_mviews
/
