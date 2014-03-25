Accept dt1  prompt 'Begin (dd/mm/yyyy hh24:mi:ss):'
Accept dt2  prompt 'End   (dd/mm/yyyy hh24:mi:ss):'
Accept inst prompt 'Instance Number..............:'
drop table sys$showactivesesstmp ;
create table sys$showactivesesstmp as
Select
-- SNAP_ID                                            ,
 INSTANCE_NUMBER                                    ,
 to_char(SAMPLE_TIME,'dd/mm/yyyy hh24:mi:ss')SAMPLE_TIME,
 SESSION_ID                                         ,
 SESSION_SERIAL#                                    ,
 PROGRAM                                            ,
 USER_ID                                            ,
 SQL_ID                                             ,
 SQL_PLAN_HASH_VALUE                                ,
 EVENT                                              ,
 P1TEXT                                             ,
 P1                                                 ,
 P2TEXT                                             ,
 P2                                                 ,
 P3TEXT                                             ,
 P3                                                 ,
 SESSION_TYPE                                       ,
 SESSION_STATE                                      ,
 BLOCKING_SESSION                                   ,
 BLOCKING_SESSION_STATUS                            ,
 BLOCKING_SESSION_SERIAL#                           ,
 WAIT_CLASS                                         ,
 WAIT_TIME                                          ,
 TIME_WAITED                                        ,
 CURRENT_OBJ#                                       ,
 CURRENT_FILE#                                      ,
 CURRENT_BLOCK#                                     ,
 MODULE                                             ,
 ACTION                                             ,
 CLIENT_ID
from DBA_HIST_ACTIVE_SESS_HISTORY
where sample_time between TO_DATE('&dt1', 'dd/mm/yyyy hh24:mi:ss') and TO_DATE('&dt2', 'dd/mm/yyyy hh24:mi:ss')
  and instance_number like '&inst'||'%'
  and event is not null
  and session_type = 'FOREGROUND';
  
col program for a50

prompt query que mais aguardaram
WITH ash_query AS 
(
 SELECT substr(event,6,2) lock_type,
		program,
		h.module, 
		h.action, 
		object_name,
		SUM(time_waited)/1000 time_ms, 
		COUNT( * ) waits,
		username, 
		to_char(sql_text) as sql_text,
		RANK() OVER (ORDER BY SUM(time_waited) DESC) AS time_rank,
		ROUND(SUM(time_waited) * 100 / SUM(SUM(time_waited)) OVER (), 2) pct_of_time
 FROM sys$showactivesesstmp h
	JOIN dba_users u USING (user_id)
	LEFT OUTER JOIN dba_objects o ON (o.object_id = h.current_obj#)
	LEFT OUTER JOIN DBA_HIST_SQLTEXT s USING (sql_id)
 WHERE event LIKE 'enq: %'
 and sample_time between TO_DATE('&dt1', 'dd/mm/yyyy hh24:mi:ss') and TO_DATE('&dt2', 'dd/mm/yyyy hh24:mi:ss')
 GROUP BY substr(event,6,2) ,program, h.module, h.action, object_name, to_char(sql_text), username
)
SELECT lock_type,module, username, object_name, time_ms, pct_of_time, sql_text
FROM ash_query
WHERE time_rank < 11
ORDER BY time_rank;

Select *
  from sys$showactivesesstmp
order by sample_time,instance_number,session_id;


Select wait_class, Count(*)
from sys$showactivesesstmp
group by wait_class
order by 2;

Select a.user_id, b.username, program, Count(*)
from sys$showactivesesstmp a, dba_users b
where a.user_id = b.user_id
group by a.user_id,b.username,program
order by 4;

Select BLOCKING_SESSION, count(*)
from sys$showactivesesstmp
group by BLOCKING_SESSION
order by 2;

Select event, count(*)
from sys$showactivesesstmp
group by event
order by 2;

Select session_id, event, count(*)
from sys$showactivesesstmp
group by session_id, event
order by 3;

select SQL_ID, SQL_PLAN_HASH_VALUE, count(*)
from sys$showactivesesstmp
group by SQL_ID, SQL_PLAN_HASH_VALUE
order by 3;

prompt Table sys$showactivesesstmp was recreated with requested informations.


undef dt1
undef dt2
undef inst