

/* shut down and restart database */ 

begin 
   dbms_workload_capture.start_capture('Data Warehouse Migration','REP_CAP_DIR'); 

   /* initiate workload */ 
. . . 


   dbms_workload_capture.finish_capture; 
end;



-- preprocessamento, gerando reply files
begin 
   dbms_workload_replay.process_capture (capture_dir => 'REP_CAP_DIR'); 
end;



-- replay
begin 
   dbms_workload_replay.initialize_replay ('Data Warehouse Migration','REP_CAP_DIR'); 
   dbms_workload_replay.start_replay; 
end;



---- reporting 
declare 
   capture_dir_id      number; 
   curr_replay_id      number; 
   replay_report      clob; 
begin 
   /* retrieve pointer to all captured sessions  */ 
   /* in the replay directory                    */ 
   capture_dir_id := 
      dbms_workload_replay.get_replay_info(dir => 'REP_CAP_DIR'); 
   /* get latest replay session id */ 
   select max(id) into curr_replay_id 
   from dba_workload_replays 
   where capture_id = capture_dir_id; 
   /* generate the report */ 
   replay_report := 
      dbms_workload_replay.report 
         (replay_id => curr_replay_id, 
          format => dbms_workload_replay.type_text); 
end;