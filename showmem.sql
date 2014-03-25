col COMPONENT format a50
select component, current_size / 1024 / 1024 AS current_size_MB, 	user_specified_size / 1024 / 1024 AS user_specified_size_MB, 
	min_size / 1024 / 1024 AS min_size_MB, 
	max_size / 1024 / 1024 AS max_size_MB, 
	granule_size / 1024 / 1024 AS granule_size_MB
from V$MEMORY_DYNAMIC_COMPONENTS 
/
