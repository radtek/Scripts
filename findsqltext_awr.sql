col sql_text for a200;

Select sql_id, SQL_TEXT 
from DBA_HIST_SQLTEXT
where sql_text like '%&texto%'
order by sql_id;