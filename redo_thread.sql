col CURRENT_GROUP# for a20
select thread#, status, enabled, groups, instance current_group#, enable_time, disable_time, last_redo_time
from v$thread;