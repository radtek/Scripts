col sql_id for a13

break on sql_id skip 1

select sql_id, sql_text
from
(select distinct s.sql_id, st.sql_text, st.piece
from v$sqltext st
	inner join v$sql s
		on s.sql_id = st.sql_id
where s.plan_hash_value =  &plan_hash_value) tbl
order by sql_id, piece
/

clear breaks