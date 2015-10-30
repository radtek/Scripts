col SQL_TEXT_BLOCKED for a100 wrapped
column sql_text_blocking format a35 heading "SQL text blocking"
column sql_text_blocker format a35 heading "SQL text blocker"
column blocking_user format a8 Heading "Blocking|user"
column blocked_user format a8  heading "Blocked|user"
column blocking_sid format 9999 heading "Blocking|SID"
column sql_id_blocking format 9999 heading "Blocking|SID "
column sql_id_blocker format 9999 heading "Blocked|SID "
column type format a4 heading "Lock|Type"

WITH sessions AS 
       (SELECT /*+ materialize*/ username,sid,sql_id, inst_id
          FROM gv$session),
     locks AS 
        (SELECT /*+ materialize */ *
           FROM gv$lock)
SELECT l2.type,
	   s1.username blocking_user, 
	   s1.sid blocking_sid, 
       sq1.sql_text sql_text_blocking,
	   s2.username blocked_user, 
	   s2.sid blocked_sid,  
	   sq2.sql_text sql_text_blocked, 
	   sq1.sql_id sql_id_blocking, sq2.sql_id sql_id_blocked
  FROM locks l1
  JOIN locks l2 on (l1.id1 = l2.id1 and l1.id2 = l2.id2 and l1.inst_id = l2.inst_id)
  JOIN sessions s1 ON (s1.sid = l1.sid and l1.inst_id = s1.inst_id)
  JOIN sessions s2 ON (s2.sid = l2.sid and l2.inst_id = s2.inst_id)
  LEFT OUTER JOIN  gv$sql sq1
       ON (sq1.sql_id = s2.sql_id and
	       sq1.inst_id = s2.inst_id)
  LEFT OUTER JOIN  gv$sql sq2
       ON (sq2.sql_id = s1.sql_id and
	       sq2.inst_id = s1.inst_id)
 WHERE l1.BLOCK = 1 AND l2.request > 0;