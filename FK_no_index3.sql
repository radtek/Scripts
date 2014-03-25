
----> usado na APISUL

--Verificar FKS sem index

 SELECT d.owner, d.table_name, d.column_name
   FROM dba_constraints a
   JOIN dba_cons_columns d
     ON a.constraint_name = d.constraint_name
  WHERE a.owner = d.owner
    AND a.constraint_type = 'R'
    AND NOT EXISTS (SELECT 1
           FROM dba_ind_columns ind
          WHERE d.owner = ind.index_owner
            AND d.table_name = ind.table_name
            AND d.column_name = ind.column_name)
    AND a.owner not in('RMAN','MDSYS','SYS','SYSTEM','DBSNMP','EXFSYS')
ORDER BY 1,2,3;

--GERAR DDLs CREATE INDEX

--RISCO

SELECT 'execute ''CREATE INDEX ' || substr(constraint_name, 1, 28) ||
           '_I ON ' || owner||'.'||table_name || '(' || cname1 ||
           nvl2(cname2, ',' || cname2, NULL) ||
           nvl2(cname3, ',' || cname3, NULL) ||
           nvl2(cname4, ',' || cname4, NULL) ||
           nvl2(cname5, ',' || cname5, NULL) ||
           nvl2(cname6, ',' || cname6, NULL) ||
           nvl2(cname7, ',' || cname7, NULL) ||
           nvl2(cname8, ',' || cname8, NULL) || ') TABLESPACE RISCO_INDEX'';'
      FROM (SELECT b.owner,
                   b.table_name,
                   b.constraint_name,
                   MAX(decode(position, 1, column_name, NULL)) cname1,
                   MAX(decode(position, 2, column_name, NULL)) cname2,
                   MAX(decode(position, 3, column_name, NULL)) cname3,
                   MAX(decode(position, 4, column_name, NULL)) cname4,
                   MAX(decode(position, 5, column_name, NULL)) cname5,
                   MAX(decode(position, 6, column_name, NULL)) cname6,
                   MAX(decode(position, 7, column_name, NULL)) cname7,
                   MAX(decode(position, 8, column_name, NULL)) cname8,
                   COUNT(*) col_cnt
              FROM (SELECT substr(table_name, 1, 30) table_name,
                           substr(constraint_name, 1, 30) constraint_name,
                           substr(column_name, 1, 30) column_name,
                           position
                      FROM dba_cons_columns
		      WHERE OWNER IN ('CADASTRO')) a,
                   dba_constraints b
             WHERE a.constraint_name = b.constraint_name
               AND b.constraint_type = 'R'
               --AND b.owner not in('RMAN','MDSYS','SYS','SYSTEM','DBSNMP','EXFSYS')
                 AND b.owner in ('CADASTRO')
             GROUP BY b.owner, b.table_name, b.constraint_name) cons
     WHERE col_cnt > ALL (SELECT COUNT(*)
              FROM dba_ind_columns i
             WHERE i.table_name = cons.table_name
               AND i.column_name IN (cname1,
                                     cname2,
                                     cname3,
                                     cname4,
                                     cname5,
                                     cname6,
                                     cname7,
                                     cname8)
               AND i.column_position <= cons.col_cnt
             GROUP BY i.index_name);



