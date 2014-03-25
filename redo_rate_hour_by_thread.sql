set lines 400; 
set pages 9999; 
col "00" format 99999
col "01" format 99999
col "02" format 99999
col "03" format 99999
col "04" format 99999
col "05" format 99999
col "06" format 99999
col "07" format 99999
col "08" format 99999
col "09" format 99999
col "10" format 99999
col "11" format 99999
col "12" format 99999
col "13" format 99999
col "14" format 99999
col "15" format 99999
col "16" format 99999
col "17" format 99999
col "18" format 99999
col "19" format 99999
col "20" format 99999
col "21" format 99999
col "22" format 99999
col "23" format 99999

BREAK ON thread# SKIP 1

COMPUTE AVG MIN MAX OF "00" ON thread#
COMPUTE AVG MIN MAX OF "01" ON thread#
COMPUTE AVG MIN MAX OF "02" ON thread#
COMPUTE AVG MIN MAX OF "03" ON thread#
COMPUTE AVG MIN MAX OF "04" ON thread#
COMPUTE AVG MIN MAX OF "05" ON thread#
COMPUTE AVG MIN MAX OF "06" ON thread#
COMPUTE AVG MIN MAX OF "07" ON thread#
COMPUTE AVG MIN MAX OF "08" ON thread#
COMPUTE AVG MIN MAX OF "09" ON thread#
COMPUTE AVG MIN MAX OF "10" ON thread#
COMPUTE AVG MIN MAX OF "11" ON thread#
COMPUTE AVG MIN MAX OF "12" ON thread#
COMPUTE AVG MIN MAX OF "13" ON thread#
COMPUTE AVG MIN MAX OF "14" ON thread#
COMPUTE AVG MIN MAX OF "15" ON thread#
COMPUTE AVG MIN MAX OF "16" ON thread#
COMPUTE AVG MIN MAX OF "17" ON thread#
COMPUTE AVG MIN MAX OF "18" ON thread#
COMPUTE AVG MIN MAX OF "19" ON thread#
COMPUTE AVG MIN MAX OF "20" ON thread#
COMPUTE AVG MIN MAX OF "21" ON thread#
COMPUTE AVG MIN MAX OF "22" ON thread#
COMPUTE AVG MIN MAX OF "23" ON thread#

SELECT 	
	thread#,
	to_char(COMPLETION_TIME,'YYYY-MON-DD') "day",
	sum(decode(to_char(COMPLETION_TIME,'HH24'),'00',BLOCKS*BLOCK_SIZE/ 1024 / 1024,0)) "00",
	sum(decode(to_char(COMPLETION_TIME,'HH24'),'01',BLOCKS*BLOCK_SIZE/ 1024 / 1024,0)) "01",
	sum(decode(to_char(COMPLETION_TIME,'HH24'),'02',BLOCKS*BLOCK_SIZE/ 1024 / 1024,0)) "02",
	sum(decode(to_char(COMPLETION_TIME,'HH24'),'03',BLOCKS*BLOCK_SIZE/ 1024 / 1024,0)) "03",
	sum(decode(to_char(COMPLETION_TIME,'HH24'),'04',BLOCKS*BLOCK_SIZE/ 1024 / 1024,0)) "04",
	sum(decode(to_char(COMPLETION_TIME,'HH24'),'05',BLOCKS*BLOCK_SIZE/ 1024 / 1024,0)) "05",
	sum(decode(to_char(COMPLETION_TIME,'HH24'),'06',BLOCKS*BLOCK_SIZE/ 1024 / 1024,0)) "06",
	sum(decode(to_char(COMPLETION_TIME,'HH24'),'07',BLOCKS*BLOCK_SIZE/ 1024 / 1024,0)) "07",
	sum(decode(to_char(COMPLETION_TIME,'HH24'),'08',BLOCKS*BLOCK_SIZE/ 1024 / 1024,0)) "08",
	sum(decode(to_char(COMPLETION_TIME,'HH24'),'09',BLOCKS*BLOCK_SIZE/ 1024 / 1024,0)) "09",
	sum(decode(to_char(COMPLETION_TIME,'HH24'),'10',BLOCKS*BLOCK_SIZE/ 1024 / 1024,0)) "10",
	sum(decode(to_char(COMPLETION_TIME,'HH24'),'11',BLOCKS*BLOCK_SIZE/ 1024 / 1024,0)) "11",
	sum(decode(to_char(COMPLETION_TIME,'HH24'),'12',BLOCKS*BLOCK_SIZE/ 1024 / 1024,0)) "12",
	sum(decode(to_char(COMPLETION_TIME,'HH24'),'13',BLOCKS*BLOCK_SIZE/ 1024 / 1024,0)) "13",
	sum(decode(to_char(COMPLETION_TIME,'HH24'),'14',BLOCKS*BLOCK_SIZE/ 1024 / 1024,0)) "14",
	sum(decode(to_char(COMPLETION_TIME,'HH24'),'15',BLOCKS*BLOCK_SIZE/ 1024 / 1024,0)) "15",
	sum(decode(to_char(COMPLETION_TIME,'HH24'),'16',BLOCKS*BLOCK_SIZE/ 1024 / 1024,0)) "16",
	sum(decode(to_char(COMPLETION_TIME,'HH24'),'17',BLOCKS*BLOCK_SIZE/ 1024 / 1024,0)) "17",
	sum(decode(to_char(COMPLETION_TIME,'HH24'),'18',BLOCKS*BLOCK_SIZE/ 1024 / 1024,0)) "18",
	sum(decode(to_char(COMPLETION_TIME,'HH24'),'19',BLOCKS*BLOCK_SIZE/ 1024 / 1024,0)) "19",
	sum(decode(to_char(COMPLETION_TIME,'HH24'),'20',BLOCKS*BLOCK_SIZE/ 1024 / 1024,0)) "20",
	sum(decode(to_char(COMPLETION_TIME,'HH24'),'21',BLOCKS*BLOCK_SIZE/ 1024 / 1024,0)) "21",
	sum(decode(to_char(COMPLETION_TIME,'HH24'),'22',BLOCKS*BLOCK_SIZE/ 1024 / 1024,0)) "22",
	sum(decode(to_char(COMPLETION_TIME,'HH24'),'23',BLOCKS*BLOCK_SIZE/ 1024 / 1024,0)) "23"
from
   v$archived_log
WHERE COMPLETION_TIME > (sysdate - 30)
GROUP by 
   thread#, to_char(COMPLETION_TIME,'YYYY-MON-DD')
ORDER BY thread#, to_char(COMPLETION_TIME,'YYYY-MON-DD');
