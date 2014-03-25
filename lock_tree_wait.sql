
column session_detail format a15 heading "Sid and module"
column blocker_sid format 9999 heading "Blkd|by"
column wait_event_text format a29 heading "Wait event" 
column object_name format a20 heading "Object"
column sql_text format a70 heading "current sql"
set pages 1000
set lines 75
set echo on 

SELECT RPAD('+', LEVEL ,'-') || sid||' '||sess.module session_detail,
       blocker_sid,  wait_event_text,
       object_name,RPAD(' ', LEVEL )||sql_text sql_text
FROM          v$wait_chains c
           LEFT OUTER JOIN
              dba_objects o
           ON (row_wait_obj# = object_id)
        JOIN
           v$session sess
        USING (sid)
     LEFT OUTER JOIN
        v$sql sql
     ON (sql.sql_id = sess.sql_id 
         AND sql.child_number = sess.sql_child_number)
CONNECT BY     PRIOR sid = blocker_sid
           AND PRIOR sess_serial# = blocker_sess_serial#
           AND PRIOR INSTANCE = blocker_instance
START WITH blocker_is_valid = 'FALSE'; 