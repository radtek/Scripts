
col read_time format a9 heading "Read Time|(ms)"
col reads format 99,999,999 heading "Reads"
col histogram format a51 heading ""

SELECT LAG(singleblkrdtim_milli, 1) 
         OVER (ORDER BY singleblkrdtim_milli) 
          || '<' || singleblkrdtim_milli read_time, 
       SUM(singleblkrds) reads,
       RPAD(' ', ROUND(SUM(singleblkrds) * 50 / 
         MAX(SUM(singleblkrds)) OVER ()), '*')  histogram
FROM v$file_histogram
GROUP BY singleblkrdtim_milli
ORDER BY singleblkrdtim_milli; 