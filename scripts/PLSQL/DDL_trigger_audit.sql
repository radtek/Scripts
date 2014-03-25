CREATE TABLE AUDIT_DDL (
  d date,
  OSUSER varchar2(255),
  CURRENT_USER varchar2(255),
  HOST varchar2(255),
  TERMINAL varchar2(255),
  owner varchar2(30),
  type varchar2(30),
  name varchar2(30),
  sysevent varchar2(30));
   
create or replace trigger audit_ddl_trg after ddl on schema 
begin
  if (ora_sysevent='TRUNCATE')
  then
    null; -- I do not care about truncate
  else
    insert into audit_ddl(d, osuser,current_user,host,terminal,owner,type,name,sysevent)
    values(
      sysdate,
      sys_context('USERENV','OS_USER') ,
      sys_context('USERENV','CURRENT_USER') ,
      sys_context('USERENV','HOST') , 
      sys_context('USERENV','TERMINAL') ,
      ora_dict_obj_owner,
      ora_dict_obj_type,
      ora_dict_obj_name,
      ora_sysevent
    );
  end if;
end;
/