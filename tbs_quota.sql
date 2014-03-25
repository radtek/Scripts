select tablespace_name, round(bytes / 1024 / 1024) as MB, round(max_bytes / 1024/ 1024) MAXMB, blocks, max_blocks, dropped from dba_ts_quotas where username = '&username'
/
