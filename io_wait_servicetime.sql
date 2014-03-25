prompt v$file_histogram demonstra um histograma de IOs por tempo de resposta

col read_time format a20
col histogram format a100

SELECT LAG(singleblkrdtim_milli, 1) OVER (ORDER BY singleblkrdtim_milli) || '<' || singleblkrdtim_milli read_time,
	 SUM(singleblkrds) reads,
	 RPAD(' ', ROUND(SUM(singleblkrds) * 50 / MAX(SUM(singleblkrds)) OVER ()), '*') histogram
FROM v$file_histogram
GROUP BY singleblkrdtim_milli
ORDER BY singleblkrdtim_milli;