select owner, program_name, program_type, enabled, max_runs 
from dba_scheduler_programs 
where owner = '&owner';