break on inst_id skip 1
compute sum of MB on inst_id

select inst_id, 
       name_calc,
       round(sum(bytes / 1024 / 1024)) as MB
FROM (	select inst_id, 
		case when name like 'gcs%' 
						then 'gcs' 
					when name like 'sql area%' then 'sql_area' 
					when name like 'library%'  then 'library_cache' 
					when name like 'free memory' then 'free_memory' 
					when name like 'CCursor%' then 'CCursor'
					when name like 'db_block_hash_buckets%' then 'db_block_hash_buckets'
					else 'others' 
				end as name_calc, 
				bytes
		from gv$sgastat where pool = 'shared pool')
group by inst_id, name_calc
order by inst_id, MB
/
