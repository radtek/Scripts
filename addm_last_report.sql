prompt
prompt lista ultima execução do ADDM
prompt
set long 999999
select dbms_advisor.get_task_report
       (t.task_name,'TEXT','TYPICAL','ALL',t.owner) as ADDM_report
                     from dba_advisor_tasks t
                    where task_id =
                          (select max(t.task_id)
                             from dba_advisor_tasks t, dba_advisor_log l
                            where t.task_id = l.task_id
                              and t.advisor_name = 'ADDM'
                              and l.status = 'COMPLETED');
