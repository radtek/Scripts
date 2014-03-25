col wait_class format a15
col event format a30

break on event skip 1 on report skip 1 
compute sum label "Total evento: " OF ctd sec_wait ON event
compute sum label "Total evento: " OF ctd sec_wait ON report

select  event, p1, p1text, p2, p2text, p3, p3text, wait_class,  state, sum(seconds_in_wait) as sec_wait,count(1) ctd, status
from v$session
group by event, p1, p1text, p2, p2text, p3, p3text, wait_class, state, status
order by event desc, ctd desc;