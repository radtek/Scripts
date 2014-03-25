col EVENT format a60 heading "Event"
col histogram format a70 heading ""
col wait_time_ms format a8

SELECT EVENT, 
	   WAIT_TIME_MILLI || '<' as wait_time_ms, 
	   LPAD(' ', WAIT_COUNT / max(WAIT_COUNT) over(partition by EVENT) * 50, '*') as  histogram,
	   WAIT_COUNT
FROM v$event_histogram 
where upper(event) like upper('&event_name');