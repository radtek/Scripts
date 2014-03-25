col mount for a10

select substr(name, 1, instr(name, '/', 2) - 1) mount, 
	round(SUM(PHYRDS / 1000)) PHYRDS_k, round(SUM(PHYWRTS  / 1000)) PHYWRTS_k, round(SUM(PHYBLKRD  / 1000)) PHYBLKRD_k, round(SUM(PHYBLKWRT / 1000)) PHYBLKWRT_k,
	round(AVG(READTIM / 10)) READTIM_AVG_MS, round(AVG(WRITETIM/ 10 )) WRITETIM_AVG_MS, round(AVG(SINGLEBLKRDTIM / 10)) SINGLEBLKRDTIM_AVG_MS,
	round(AVG(AVGIOTIM / 10 )) AVGIOTIM_AVG_MS,   round(AVG(LSTIOTIM  / 10 )) LASTIOTIM_AVG_MS,  round(AVG(MINIOTIM  / 10 )) MINIOTIM_AVG_MS,  
	round(AVG(MAXIORTM  / 10 )) MAXIORTM_AVG_MS, round(AVG(MAXIOWTM  / 10 )) MAXIOWTM_AVG_MS
from v$tempstat ts
	inner join v$tempfile tf
		on ts.FILE# =  tf.FILE#
group by substr(name, 1, instr(name, '/', 2) - 1)
order by 1
/
