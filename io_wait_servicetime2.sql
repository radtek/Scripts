prompt v$file_histogram demonstra um histograma de IOs por tempo de resposta

col read_time format a20
col histogram format a100

SELECT 
	 substr(name, 1, instr(name, '/') - 1) disk,
	 LAG(fh.singleblkrdtim_milli, 1) OVER (ORDER BY substr(name, 1, instr(name, '/') - 1), fh.singleblkrdtim_milli) || '<' || fh.singleblkrdtim_milli read_time,
	 SUM(fh.singleblkrds) reads,
	 RPAD(' ', ROUND(SUM(fh.singleblkrds) * 50 / MAX(SUM(fh.singleblkrds)) OVER ()), '*') histogram
FROM v$file_histogram fh
	inner join v$datafile df
		on df.file# = fh.file#
GROUP BY substr(name, 1, instr(name, '/') - 1), fh.singleblkrdtim_milli
ORDER BY substr(name, 1, instr(name, '/') - 1), fh.singleblkrdtim_milli;
