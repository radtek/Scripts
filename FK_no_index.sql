----> usado na APISUL, considera posicao da coluna

define owner=&owner

col owner format a15
col table_name format a35 
col column_name format a35
col CONSTRAINT_NAME format a35
col col1 format a30
col col2 format a30
col col3 format a30
col col4 format a30

 SELECT a.CONSTRAINT_NAME,d.owner, d.table_name, d.column_name
   FROM dba_constraints a
   JOIN dba_cons_columns d
     ON a.constraint_name = d.constraint_name
  WHERE a.owner = d.owner
    AND a.owner like upper('&owner')
    AND a.constraint_type = 'R'
    AND NOT EXISTS (SELECT 1
           FROM dba_ind_columns ind
          WHERE d.owner = ind.index_owner
            AND d.table_name = ind.table_name
	    AND d.POSITION = ind.COLUMN_POSITION
            AND d.column_name = ind.column_name)
	    AND a.owner not in('RMAN','MDSYS','SYS','SYSTEM','DBSNMP','EXFSYS')
ORDER BY 1,2,3;


SELECT 'CREATE INDEX ' || t.owner || '.' || t.CONSTRAINT_NAME || 
	   ' ON  ' || t.owner || '.' || t.table_name || '(' || NVL(t.col1, '') || NVL2(t.col2, ',' || t.col2, '') || NVL2(t.col3, ',' || t.col3, '') || NVL2(t.col4, ',' || t.col4, '') || NVL2(t.col5, ',' || t.col5, '') || NVL2(t.col6, ',' || t.col6, '') || NVL2(t.col7, ',' || t.col7, '') || NVL2(t.col8, ',' || t.col8, '') || NVL2(t.col9, ',' || t.col9, '') || NVL2(t.col10, ',' || t.col10, '') || ')' || 
	   ' TABLESPACE ' || (select tablespace_name from dba_indexes where owner = t.owner and rownum = 1)	|| ';'
FROM (SELECT a.CONSTRAINT_NAME,
			d.owner, 
		   d.table_name,
		   max( case d.position when 1 then d.column_name else null end) as col1, 
		   max( case d.position when 2 then d.column_name else null end) as col2,
		   max( case d.position when 3 then d.column_name else null end) as col3,
		   max( case d.position when 4 then d.column_name else null end) as col4,
		   max( case d.position when 5 then d.column_name else null end) as col5,
		   max( case d.position when 6 then d.column_name else null end) as col6,
		   max( case d.position when 7 then d.column_name else null end) as col7,
		   max( case d.position when 8 then d.column_name else null end) as col8,
		   max( case d.position when 9 then d.column_name else null end) as col9,
		   max( case d.position when 10 then d.column_name else null end) as col10
	FROM dba_constraints a
	   JOIN dba_cons_columns d
		 ON a.constraint_name = d.constraint_name
	WHERE a.owner = d.owner
		AND a.owner like upper('&owner')
		AND a.constraint_type = 'R'
		AND NOT EXISTS (SELECT 1
						FROM dba_ind_columns ind
						WHERE d.owner = ind.index_owner
							AND d.table_name = ind.table_name
							AND d.POSITION = ind.COLUMN_POSITION
							AND d.column_name = ind.column_name)
		AND a.owner not in('RMAN','MDSYS','SYS','SYSTEM','DBSNMP','EXFSYS')
	GROUP BY a.CONSTRAINT_NAME,d.owner, d.table_name) T	   
ORDER BY owner, table_name, constraint_name;


undef owner