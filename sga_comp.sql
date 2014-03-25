select 
   component, 
   current_size/1024/1024 "CURRENT_SIZE", 
   min_size/1024/1024 "MIN_SIZE",
   user_specified_size/1024/1024 "USER_SPECIFIED_SIZE", 
   last_oper_type "TYPE" 
from 
   v$sga_dynamic_components;
