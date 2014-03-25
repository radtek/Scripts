--View capture status
SELECT c.capture_name, SUBSTR (s.program, INSTR (s.program, '(') + 1, 4) process_name, c.SID,
       c.serial#, c.state, c.total_messages_captured,
       c.total_messages_enqueued, c.enqueue_time last_enqueue, sysdate
FROM v$streams_capture c, v$session s
WHERE c.SID = s.SID AND c.serial# = s.serial#;