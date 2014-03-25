
def instance_number=&instance_number

prompt
prompt demostra valores relacionado com buffer cache
prompt informe o parametro dias relativo ao dia atual, ex: 1 para dia de ontem e 2 para antes de ontem
prompt 

break on name skip 1 

select a.INSTANCE_NUMBER, 	
	NAME, 	
	to_char(b.begin_interval_time,'hh24:mi') as hr, 
	AVG(SET_MSIZE) AS SET_MSIZE, 
	AVG(CNUM_REPL) AS CNUM_REPL, 
	AVG(CNUM_WRITE) AS CNUM_WRITE,
	AVG(CNUM_SET) AS CNUM_SET,
	AVG(BUF_GOT) AS BUF_GOT, 
	AVG(SUM_WRITE) AS SUM_WRITE, 
	AVG(SUM_SCAN) AS SUM_SCAN, 
	AVG(FREE_BUFFER_WAIT) AS FREE_BUFFER_WAIT, 
	AVG(WRITE_COMPLETE_WAIT) AS WRITE_COMPLETE_WAIT, 
	AVG(BUFFER_BUSY_WAIT) AS BUFFER_BUSY_WAIT, 
	AVG(FREE_BUFFER_INSPECTED) AS FREE_BUFFER_INSPECTED,  
	AVG(DIRTY_BUFFERS_INSPECTED) AS DIRTY_BUFFERS_INSPECTED, 
	AVG(DB_BLOCK_CHANGE) AS DB_BLOCK_CHANGE, 
	AVG(DB_BLOCK_GETS) AS DB_BLOCK_GETS, 
	AVG(CONSISTENT_GETS) AS CONSISTENT_GETS, 
	AVG(PHYSICAL_READS) AS PHYSICAL_READS, 
	AVG(PHYSICAL_WRITES) AS PHYSICAL_WRITES
FROM DBA_HIST_BUFFER_POOL_STAT a, dba_hist_snapshot b 
WHERE (a.instance_number = &instance_number or &instance_number=0)
and a.INSTANCE_NUMBER = b.INSTANCE_NUMBER
and to_char(begin_interval_time,'hh24:mi') between '01:00' and '24:00'
and to_char(begin_interval_time,'dd-mon')  = to_char(sysdate - &dias, 'dd-mon')
GROUP BY a.INSTANCE_NUMBER, 	
	NAME, 	
	to_char(b.begin_interval_time,'hh24:mi')  
ORDER BY a.INSTANCE_NUMBER, NAME, hr;


undef instance_number