col sql_text for a100;

undef hash_value

Select sql_text
from STATS$SQLTEXT 
where OLD_HASH_VALUE = &hash_value
order by piece;

