col signature for 999999999999999999999999999999
col sqltext for a60 wrapped
			
Select /* IGNORE */  b.sql_handle, b.plan_name, b.origin, b.enabled, b.accepted, b.fixed, b.reproduced, b.parsing_schema_name, substr(b.sql_text, 1, 60) as sqltext, b.signature, s.sql_id, LAST_EXECUTED, LAST_VERIFIED, s.sql_id
From dba_sql_plan_baselines b	
	left join v$sql s
		on s.exact_matching_signature (+) = b.signature
		and s.SQL_PLAN_BASELINE (+) = b.plan_name
		and upper(s.sql_text)  not like  '%EXPLAIN%' 
Where  b.sql_text not like '%IGNORE%'
order by b.created desc;