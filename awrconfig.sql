prompt 
prompt -----> show AWR settings <-----
prompt   
prompt *********** no 11g verificar "control_management_pack_access + statistics_level"
prompt   
prompt   
set linesize 100
col snap_interval format a20
col retention format a20
col topnsql format a20

select * from dba_hist_wr_control;
prompt 
prompt Para Ajustar:
prompt 		--> execute dbms_workload_repository.modify_snapshot_settings( interval => 60, retention => 87840);