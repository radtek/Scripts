SELECT xid
FROM v$transaction t, v$session s, v$mystat m
WHERE t.ses_addr = s.saddr
AND s.sid = m.sid
AND ROWNUM = 1
/
