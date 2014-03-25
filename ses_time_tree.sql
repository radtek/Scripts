set lines 2000
col stat_name format a100

define sid=&sid

SELECT LPAD(' ', 2*level-1)||stat_name stat_name, 
trunc(value/1000000,2) seconds 
FROM ( 
select 0 id, 9 pid, null stat_name, null value from dual union 
select decode(stat_name,'DB time',10) id , 
decode(stat_name,'DB time',0) pid , stat_name, value 
from v$sess_time_model 
where stat_name = 'DB time' 
and sid = &&sid
union 
select decode(stat_name,'DB CPU',20) id , 
decode(stat_name,'DB CPU',10) pid , stat_name, value 
from v$sess_time_model 
where stat_name = 'DB CPU' 
and sid = &&sid
union 
select decode(stat_name,'connection management call elapsed time',21) id , 
decode(stat_name,'connection management call elapsed time',10) pid , stat_name, value
 from v$sess_time_model 
where stat_name = 'connection management call elapsed time' 
and sid = &&sid
union 
select decode(stat_name,'sequence load elapsed time',22) id , 
decode(stat_name,'sequence load elapsed time',10) pid , stat_name, value 
from v$sess_time_model 
where stat_name = 'sequence load elapsed time' 
and sid = &&sid
union 
select decode(stat_name,'sql execute elapsed time',23) id , 
decode(stat_name,'sql execute elapsed time',10) pid , stat_name, value 
from v$sess_time_model 
where stat_name = 'sql execute elapsed time' 
and sid = &&sid
union 
select decode(stat_name,'parse time elapsed',24) id , 
decode(stat_name,'parse time elapsed',10) pid , stat_name, value 
from v$sess_time_model 
where stat_name = 'parse time elapsed' 
and sid = &&sid
union 
select decode(stat_name,'hard parse elapsed time',30) id , 
decode(stat_name,'hard parse elapsed time',24) pid , stat_name, value 
from v$sess_time_model 
where stat_name = 'hard parse elapsed time' 
and sid = &&sid
union 
select decode(stat_name,'hard parse (sharing criteria) elapsed time',40) id , 
decode(stat_name,'hard parse (sharing criteria) elapsed time',30) pid , stat_name, value
 from v$sess_time_model 
where stat_name = 'hard parse (sharing criteria) elapsed time' 
and sid = &&sid
union 
select decode(stat_name,'hard parse (bind mismatch) elapsed time',50) id , 
decode(stat_name,'hard parse (bind mismatch) elapsed time',40) pid , stat_name, value
 from v$sess_time_model 
where stat_name = 'hard parse (bind mismatch) elapsed time' 
and sid = &&sid
union 
select decode(stat_name,'failed parse elapsed time',31) id , 
decode(stat_name,'failed parse elapsed time',24) pid , stat_name, value 
from v$sess_time_model 
where stat_name = 'failed parse elapsed time' 
and sid = &&sid
union 
select decode(stat_name,'failed parse (out of shared memory) elapsed time',41) id ,
 decode(stat_name,'failed parse (out of shared memory) elapsed time',31) pid , stat_name, value
 from v$sess_time_model 
where stat_name = 'failed parse (out of shared memory) elapsed time' 
and sid = &&sid
union 
select decode(stat_name,'PL/SQL execution elapsed time',25) id , 
decode(stat_name,'PL/SQL execution elapsed time',10) pid , stat_name, value 
from v$sess_time_model 
where stat_name = 'PL/SQL execution elapsed time' 
and sid = &&sid
union 
select decode(stat_name,'inbound PL/SQL rpc elapsed time',26) id , 
decode(stat_name,'inbound PL/SQL rpc elapsed time',10) pid , stat_name, value 
from v$sess_time_model 
where stat_name = 'inbound PL/SQL rpc elapsed time' 
and sid = &&sid
union 
select decode(stat_name,'PL/SQL compilation elapsed time',27) id , 
decode(stat_name,'PL/SQL compilation elapsed time',10) pid , stat_name, value 
from v$sess_time_model 
where stat_name = 'PL/SQL compilation elapsed time' 
and sid = &&sid
union 
select decode(stat_name,'Java execution elapsed time',28) id , 
decode(stat_name,'Java execution elapsed time',10) pid , stat_name, value 
from v$sess_time_model 
where stat_name = 'Java execution elapsed time' 
and sid = &&sid
union 
select decode(stat_name,'repeated bind elapsed time',29) id , 
decode(stat_name,'repeated bind elapsed time',10) pid , stat_name, value 
from v$sess_time_model 
where stat_name = 'repeated bind elapsed time' 
and sid = &&sid
union 
select decode(stat_name,'background elapsed time',1) id , 
decode(stat_name,'background elapsed time',0) pid , stat_name, value 
from v$sess_time_model 
where stat_name = 'background elapsed time' 
and sid = &&sid
union 
select decode(stat_name,'background cpu time',2) id , 
decode(stat_name,'background cpu time',1) pid , stat_name, value 
from v$sess_time_model 
where stat_name = 'background cpu time' 
and sid = &&sid
union 
select decode(stat_name,'RMAN cpu time (backup/restore)',3) id , 
decode(stat_name,'RMAN cpu time (backup/restore)',2) pid , stat_name, value 
from v$sess_time_model 
where stat_name = 'RMAN cpu time (backup/restore)'
and sid = &&sid
) 
CONNECT BY PRIOR id = pid START WITH id = 0; 

undefine sid