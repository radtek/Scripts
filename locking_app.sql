SELECT COUNT( * ), SUM(elapsed_time) elapsed_Time,
       SUM(application_wait_time) application_time,
       ROUND(SUM(elapsed_time) * 100 / 
            SUM(application_wait_time), 2)
            pct_application_time
FROM v$sql
WHERE module = '&app';
 