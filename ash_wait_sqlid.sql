prompt "tempo de banco de dados por sqlid"
select sql_id
, count(*) DBTime
, round(count(*)*100/sum(count(*))
over (), 2) pctload
from v$active_session_history
where sample_time > sysdate - 1/24/60
and session_type <> 'BACKGROUND'
group by sql_id
order by count(*) desc;