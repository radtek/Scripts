
def instance_number=&instance_number

prompt
prompt valores são listados em MB
prompt
prompt informe o parametro dias relativo ao dia atual, ex: 1 para dia de ontem e 2 para antes de ontem
prompt 

col "1" for 99999 justify right
col "2" for 99999 justify right
col "3" for 99999 justify right
col "4" for 99999 justify right
col "5" for 99999 justify right
col "6" for 99999 justify right
col "7" for 99999 justify right
col "8" for 99999 justify right
col "9" for 99999 justify right
col "10" for 99999 justify right
col "11" for 99999 justify right
col "12" for 99999 justify right
col "13" for 99999 justify right
col "14" for 99999 justify right
col "15" for 99999 justify right
col "16" for 99999 justify right
col "17" for 99999 justify right
col "18" for 99999 justify right
col "19" for 99999 justify right
col "20" for 99999 justify right
col "21" for 99999 justify right
col "22" for 99999 justify right
col "23" for 99999 justify right
col "24" for 99999 justify right

select n as nome, 
   round(max(decode(to_char(begin_interval_time, 'hh24'), 1,bytes, null))) "1",
   round(max(decode(to_char(begin_interval_time, 'hh24'), 2,bytes, null))) "2",
   round(max(decode(to_char(begin_interval_time, 'hh24'), 3,bytes, null))) "3",
   round(max(decode(to_char(begin_interval_time, 'hh24'), 4,bytes, null))) "4",
   round(max(decode(to_char(begin_interval_time, 'hh24'), 5,bytes, null))) "5",
   round(max(decode(to_char(begin_interval_time, 'hh24'), 6,bytes, null))) "6",
   round(max(decode(to_char(begin_interval_time, 'hh24'), 7,bytes, null))) "7",
   round(max(decode(to_char(begin_interval_time, 'hh24'), 8,bytes, null))) "8",
   round(max(decode(to_char(begin_interval_time, 'hh24'), 9,bytes, null))) "9",
   round(max(decode(to_char(begin_interval_time, 'hh24'), 10,bytes, null))) "10",
   round(max(decode(to_char(begin_interval_time, 'hh24'), 11,bytes, null))) "11",
   round(max(decode(to_char(begin_interval_time, 'hh24'), 12,bytes, null))) "12",
   round(max(decode(to_char(begin_interval_time, 'hh24'), 13,bytes, null))) "13",
   round(max(decode(to_char(begin_interval_time, 'hh24'), 14,bytes, null))) "14",
   round(max(decode(to_char(begin_interval_time, 'hh24'), 15,bytes, null))) "15",
   round(max(decode(to_char(begin_interval_time, 'hh24'), 16,bytes, null))) "16",
   round(max(decode(to_char(begin_interval_time, 'hh24'), 17,bytes, null))) "17",
   round(max(decode(to_char(begin_interval_time, 'hh24'), 18,bytes, null))) "18",
   round(max(decode(to_char(begin_interval_time, 'hh24'), 19,bytes, null))) "19",
   round(max(decode(to_char(begin_interval_time, 'hh24'), 20,bytes, null))) "20",
   round(max(decode(to_char(begin_interval_time, 'hh24'), 21,bytes, null))) "21",
   round(max(decode(to_char(begin_interval_time, 'hh24'), 22,bytes, null))) "22",
   round(max(decode(to_char(begin_interval_time, 'hh24'), 23,bytes, null))) "23",
   round(max(decode(to_char(begin_interval_time, 'hh24'), 24,bytes, null))) "24"
from (select case when name like 'gcs%'
                                then 'gcs'
                        when name like 'sql area%' then 'sql_area'
                        when name like 'library%'  then 'library_cache'
                        when name like 'free memory' then 'free_memory'
                        when name like 'CCursor%' then 'CCursor'
                        when name like 'db_block_hash_buckets%' then 'db_block_hash_buckets'
			when name like 'kzsna:login name' then 'kzsna_login name'
			when name like 'Oracle%Text%Commit%' then 'Oracle_Text_Commit_new_id'
                        else 'others'
                end n, 
	       begin_interval_time, 
	       sum(bytes / 1024 / 1024) as  bytes 
	from dba_hist_sgastat a, 
		dba_hist_snapshot b 
	where pool='shared pool' 
	and a.snap_id=b.snap_id
	and (a.instance_number = &instance_number or &instance_number=0)
	and a.INSTANCE_NUMBER = b.INSTANCE_NUMBER
	and to_char(begin_interval_time,'hh24:mi') between '01:00' and '24:00'
	and to_char(begin_interval_time,'dd-mon')  = to_char(sysdate - &dias, 'dd-mon')
	group by case when name like 'gcs%'
                                then 'gcs'
                        when name like 'sql area%' then 'sql_area'
                        when name like 'library%'  then 'library_cache'
                        when name like 'free memory' then 'free_memory'
                        when name like 'CCursor%' then 'CCursor'
                        when name like 'db_block_hash_buckets%' then 'db_block_hash_buckets'
			when name like 'kzsna:login name' then 'kzsna_login name'
			when name like 'Oracle%Text%Commit%' then 'Oracle_Text_Commit_new_id'
                        else 'others'
                end, 
	       begin_interval_time
	)
group by n;

undef instance_number


