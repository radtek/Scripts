var task_id number
declare 
    name varchar2(100); 
    descr varchar2(500); 
    obj_id number; 
begin 
    name := ''; -- unique name generated from create_task 
    descr := 'Check &&TABLENAME table'; 
    dbms_advisor.create_task 
         ('Segment Advisor', :task_id, name, descr, NULL); 
    dbms_advisor.create_object 
         (name, 'TABLE', '&&OWNER', '&&TABLENAME', NULL, NULL, obj_id); 
    dbms_advisor.set_task_parameter(name, 'RECOMMEND_ALL', 'TRUE'); 
    dbms_advisor.execute_task(name); 
end; 
/
select owner, task_id, task_name, type, 
message, more_info from dba_advisor_findings 
where task_id = :task_id; 
select owner, task_id, task_name, command, attr1 
from dba_advisor_actions where task_id = :task_id;

undef TABLENAME
undef OWNER