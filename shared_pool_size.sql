break on report
compute sum of MB on report

select name_calc,
	   round(sum(bytes / 1024 / 1024)) as MB
FROM (	select case when name like 'gcs%' 
						then 'gcs' 
					when name like 'sql area%' then 'sql_area' 
					when name like 'library%'  then 'library_cache' 
					when name like 'free memory' then 'free_memory' 
					when name like 'CCursor%' then 'CCursor'
					when name like 'db_block_hash_buckets%' then 'db_block_hash_buckets'
					when name like 'kzsna:login name' then 'kzsna_login name'
					when name like 'Oracle Text Commit new id' then 'Oracle_Text_Commit_new_id'
					else 'others' 
		end as name_calc, 
		bytes
		from v$sgastat where pool = 'shared pool')
group by name_calc
/
