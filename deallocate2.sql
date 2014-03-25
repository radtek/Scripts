col "Mb a lib" for 9999.99
col "Mb Frag" for 9999.99
col file_name for a45
col comando for a200
select Mb,hwm,free "Free-Total",mb-hwm "Free-HWM",'alter database datafile '''||file_name||''' resize '||to_char(round(hwm,0)+1)||'M;' Comando
from (
     select f.file_name,
            sum(f.blocks*p.value) Mb,      -- Tamanho do datafile
            nvl(sum(e.max_block*p.value),0) hwm,      -- HWM
            nvl(sum(fs.Mbytes),0) free,               -- Free Space (fragmentado + continuous)
            nvl(sum(f.overhead*p.value),0) overhead
     from (select file_name,file_id,blocks,user_blocks,blocks-user_blocks overhead
           from dba_data_files
           where tablespace_name like upper('&&Tbs')
           union all
           select file_name,file_id,blocks,user_blocks,blocks-user_blocks overhead
           from dba_temp_files
           where tablespace_name like upper('&&Tbs')) f,
          (select file_id,max(block_id+blocks-1) max_block    -- HighWaterMark
           from dba_extents
           group by file_id) e,
          (select value/1024/1024 value
           from v$parameter
           where name = 'db_block_size') p,
          (select file_id,sum(bytes)/1024/1024 Mbytes
           from dba_free_space
           where tablespace_name like upper('&&Tbs')
           group by file_id) fs
     where e.file_id(+) = f.file_id and
           f.file_id = fs.file_id(+)
     group by rollup(f.file_name) )
order by file_name
/
undef tbs
spool off