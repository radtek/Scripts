col sid for 999999999
col username for a10
col machine for a20 
col event for a30

SELECT S.SID, S.USERNAME, S.MACHINE, S.STATUS, S.EVENT, S.SQL_ID, last_call_et/60 Idle_min, 
	T.XID, T.START_TIME, T.STATUS, T.USED_UBLK as undo_blocks, T.USED_UREC as undo_records, 
	(sysdate - to_date(t.start_time, 'MM/DD/YY HH24:MI:SS')) * 24 as hours_active
FROM V$SESSION S
	INNER JOIN V$TRANSACTION T
		ON T.SES_ADDR = S.SADDR
order by s.sid;