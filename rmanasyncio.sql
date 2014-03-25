select long_waits / io_count waitcountratio, filename 
from v$backup_async_io 
where long_waits / io_count > 0 
order by long_waits / io_count desc ;