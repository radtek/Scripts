prompt *************************************
prompt 	Possivel também usar:
prompt 		commit|rollback force 'local_tran_id'
prompt *************************************
select OS_TERMINAL, OS_USER, 'exec DBMS_TRANSACTION.purge_lost_db_entry('''||LOCAL_TRAN_ID||''');'||chr(10)||'commit;' from DBA_2PC_PENDING;