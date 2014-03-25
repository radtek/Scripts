
define object_type =&object_type
define OWNER=&OWNER
define OBJECT_NAME=&OBJECT_NAME

set echo off
set feedback off
set verify off
drop sequence deptree_seq
/
create sequence deptree_seq cache 200 /* cache 200 to make sequence faster */
/
drop table deptree_temptab
/
create table deptree_temptab
(
  object_id            number,
  referenced_object_id number,
  nest_level           number,
  seq#                 number
)
/
create or replace procedure deptree_fill (type char, schema char, name char) is
  obj_id number;
begin
  delete from deptree_temptab;
  commit;
  select object_id into obj_id from all_objects
    where owner        = upper(deptree_fill.schema)
    and   object_name  = upper(deptree_fill.name)
    and   object_type  = upper(deptree_fill.type);
  insert into deptree_temptab
    values(obj_id, 0, 0, 0);
  insert into deptree_temptab
    select object_id, referenced_object_id,
        level, deptree_seq.nextval
      from public_dependency
      connect by prior object_id = referenced_object_id
      start with referenced_object_id = deptree_fill.obj_id;
exception
  when no_data_found then
    raise_application_error(-20000, 'ORU-10013: ' ||
      type || ' ' || schema || '.' || name || ' was not found.');
end;
/

drop view deptree
/

create view sys.deptree
  (nested_level, type, schema, name, seq#)
as
  select d.nest_level, o.object_type, o.owner, o.object_name, d.seq#
  from deptree_temptab d, dba_objects o
  where d.object_id = o.object_id (+)
union all
  select d.nest_level+1, 'CURSOR', '<shared>', '"'||c.kglnaobj||'"', d.seq#+.5
  from deptree_temptab d, x$kgldp k, x$kglob g, obj$ o, user$ u, x$kglob c,
      x$kglxs a
    where d.object_id = o.obj#
    and   o.name = g.kglnaobj
    and   o.owner# = u.user#
    and   u.name = g.kglnaown
    and   g.kglhdadr = k.kglrfhdl
    and   k.kglhdadr = a.kglhdadr   /* make sure it is not a transitive */
    and   k.kgldepno = a.kglxsdep   /* reference, but a direct one */
    and   k.kglhdadr = c.kglhdadr
    and   c.kglhdnsp = 0 /* a cursor */
/


create or replace view deptree
  (nested_level, type, schema, name, seq#)
as
  select d.nest_level, o.object_type, o.owner, o.object_name, d.seq#
  from deptree_temptab d, all_objects o
  where d.object_id = o.object_id (+)
/

drop view ideptree
/
create view ideptree (dependencies)
as
  select lpad(' ',3*(max(nested_level))) || max(nvl(type, '<no permission>')
    || ' ' || schema || decode(type, NULL, '', '.') || name)
  from deptree
  group by seq# /* So user can omit sort-by when selecting from ideptree */
/


exec deptree_fill(type =>'&object_type',schema => '&OWNER',name => '&OBJECT_NAME');

prompt 
prompt --> usam o objeto informado deptree
select * from deptree order by seq#;
prompt 
prompt --> usam o objeto informado ideptree
select * from ideptree;


col owner for a15
col name for a30
col type for a10
col referenced_owner for a15
col referenced_name for a30
col referenced_link_name for a10

prompt 
prompt --> objeto informado depende
select  * 
from dba_dependencies 
where name='&OBJECT_NAME' and owner='&OWNER';

prompt 
prompt --> usam o objeto informado dba_dependencies 
select  * 
from dba_dependencies 
where REFERENCED_NAME='&OBJECT_NAME' and REFERENCED_OWNER='&OWNER';

undefine object_type
undefine OWNER
undefine OBJECT_NAME
set feedback on
set verify on