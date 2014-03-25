set lines 2000
col window_name format a30
col resource_plan format a30
col repeat_interval format a30
col end_date format a15
col start_date format a15
col duration format a15
col schedule_name format a30

select  g.WINDOW_GROUP_NAME, w.window_name, w.resource_plan, w.start_date, w.repeat_interval, 
		w.duration, w.active, w.enabled, w.end_date, w.schedule_name
from dba_scheduler_wingroup_members M
   inner join dba_scheduler_windows w 
	on w.window_name = M.window_name
   inner join dba_scheduler_window_groups g
      on g.WINDOW_GROUP_NAME = M.window_group_name;