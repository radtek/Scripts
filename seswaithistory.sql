define sid=&sid
SELECT   sid, seq#, event, wait_time, p1, p2, p3 
FROM     v$session_wait_history
WHERE    sid = &sid
ORDER BY seq#;

undef sid