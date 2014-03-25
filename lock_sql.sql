rem materialize hint é devido a v$ views não suportam leitura consistente e pode alterar durante a leitura

set lines 20000

col type format a10 
col blocking_user format a20 
col blocking_sid format 99999 
col blocked_user format a20 
col blocked_sid format 99999
col blocked_sql_text format a50 wrapped
col blocking_sql_text format a50 wrapped

WITH sessions AS
(SELECT /*+ materialize*/ username,sid,sql_id FROM v$session), 
locks AS
(SELECT /*+ materialize */ *
 FROM v$lock)
 SELECT l2.type,s1.username blocking_user, s1.sid blocking_sid,
		s2.username blocked_user, s2.sid blocked_sid, sq1.sql_text blocked_sql_text, sq2.sql_text blocking_sql_text
 FROM locks l1
	  JOIN locks l2 USING (id1, id2)
	  JOIN sessions s1 ON (s1.sid = l1.sid)
	  JOIN sessions s2 ON (s2.sid = l2.sid)
	  LEFT OUTER JOIN v$sql sq1
		ON (sq1.sql_id = s2.sql_id)
	  LEFT OUTER JOIN v$sql sq2
		ON (sq2.sql_id = s1.sql_id)
 WHERE l1.BLOCK = 1 AND l2.request > 0;