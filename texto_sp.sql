col sql_text for a100;

undef hash_value

Select sql_text
from STATS$SQLTEXT 
where hash_value = &hash_value
order by piece;

