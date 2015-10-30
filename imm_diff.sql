
Accept dt1  prompt 'Dt1 (DD/MM/RRRR):'
Accept dt2  prompt 'Dt2 (DD/MM/RRRR):'

 select x.*
 from
	(select 
		trunc(i1.timestamp) dt,
		i1.segment_owner,
		i1.segment_name, 		
		round(i1.total_bytes/1024/1024) tamanho_MB_1,
	    round(i2.total_bytes/1024/1024) tamanho_MB_2,
		round(((i2.total_bytes/1024/1024) - nvl((i1.total_bytes/1024/1024), 0))) diferenca_MB,
		round(sum(((i2.total_bytes/1024/1024) - nvl((i1.total_bytes/1024/1024), 0))) over () )  as diff_total_MB,				
		round(sum(((i2.UNUSED_BYTES/1024/1024) - nvl((i1.UNUSED_BYTES/1024/1024), 0))) over () )  as diff_unused_total_MB,		
		i1.segment_type
	from imm_storage i2 
		LEFT JOIN  imm_storage i1 
			ON i1.segment_owner = i2.segment_owner
			and i1.segment_name = i2.segment_name
			and i1.segment_type = i2.segment_type
	where trunc(i1.timestamp) = to_date('&dt1','DD/MM/RRRR')
	  and trunc(i2.timestamp) = to_date('&dt2','DD/MM/RRRR')	
	order by diferenca_MB desc) x
where rownum < 20
order by diferenca_MB desc;

undef dt1
undef dt2