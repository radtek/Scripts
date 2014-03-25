prompt calcula o cache hit ratio por sessão
prompt	 informe sid=0 para todos
prompt
define sid = &sid

SELECT sid, HITRATIO
FROM	(SELECT P1.sid, 
				(P1.value + P2.value - P3.value) / (P1.value + P2.value) AS HITRATIO
		 FROM   v$sesstat P1, v$statname N1, v$sesstat P2, v$statname N2,
				v$sesstat P3, v$statname N3
		 WHERE  N1.name = 'db block gets'
		 AND    P1.statistic# = N1.statistic#
		 AND    (P1.sid = &sid OR &sid = 0)
		 AND    N2.name = 'consistent gets'
		 AND    P2.statistic# = N2.statistic#
		 AND    P2.sid = P1.sid
		 AND    N3.name = 'physical reads'
		 AND    P3.statistic# = N3.statistic#
		 AND    P3.sid = P1.sid
		 ORDER BY HITRATIO DESC) TBL
WHERE rownum < 100;
undef sid