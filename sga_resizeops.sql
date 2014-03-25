select
   component,
   oper_type,
   oper_mode,
   initial_size/1024/1024 "Initial",
   TARGET_SIZE/1024/1024  "Target",
   FINAL_SIZE/1024/1024   "Final",
   status, 
   start_time, 
   end_time
from
   v$sga_resize_ops;