prompt opções:
prompt 		group_number = 0 para todos
prompt 		group_name = % para todos
prompt 

define group_name = &group_name
define group_number = &group_number

col GROUP_NAME format a8
col DISK_NAME format a10
col FAILGROUP format a8
col PATH format a20

select g.group_number, 
       g.name as group_name, 
       g.block_size / 1024 as block_size_kb, 
       g.state, 
       g.type, 
       g.total_mb group_total_mb, 
       g.free_mb group_free_mb,  	   	   
       round(g.free_mb / g.total_mb * 100.0) AS "%FREE",
       d.disk_number, 
	   d.name as disk_name, 
       d.mode_status, 
       d.state,  
       d.total_mb disk_total_mb,
       d.free_mb disk_free_mb, 
       round(d.free_mb / d.total_mb * 100.0) AS "%FREE",
       d.failgroup, 
       d.path, 
       d.mount_date
from v$asm_diskgroup g
     inner join v$asm_disk d
           on d.group_number = g.group_number
where (g.group_number = &group_number or &group_number = 0)
or g.name like '&group_name';

undef group_name
undef group_number 