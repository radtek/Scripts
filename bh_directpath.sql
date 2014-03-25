WITH sysstat AS
(
 SELECT name, VALUE,
	SUM(DECODE(name, 'physical reads', VALUE)) OVER () total_phys_reads,
	SUM(DECODE(name, 'physical reads direct', VALUE)) OVER () tot_direct_reads
 FROM v$sysstat
 WHERE name IN
 ('physical reads', 'physical reads direct', 'physical reads direct temporary tablespace')
)
SELECT name, 
	VALUE, 
	ROUND(VALUE * 100 / total_phys_reads, 2) pct_of_physical,
	decode(name,'physical reads',0,ROUND(VALUE * 100 / tot_direct_reads, 2)) pct_of_direct
 FROM sysstat
/