set pages 2000
set lines 2000
col sql_id for a13

break on sql_id skip 1

select /*+ first_rows(1) */ s.sql_id, st.sql_text 
from dba_hist_sqltext st 
	inner join dba_hist_sqlstat s 
		on s.sql_id = st.sql_id  
where s.plan_hash_value = &plan_hash_value 
  and rownum = 1
/

clear breaks
