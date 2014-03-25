col sql_text for a100;

Select * 
from STATS$SQLTEXT 
where sql_text like '%&texto%'
order by hash_value, piece;
