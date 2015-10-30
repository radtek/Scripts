undef dblink 
undef owner 
accept owner prompt 'informe o nome de um dos owners....:'
accept dblink prompt 'informe o nome do dblink..........:'
SELECT O.owner, 
       O.object_type, 
       O.nro_objs              nro_objs_orig, 
       D.nro_objs              nro_objs_dest, 
       Decode(O.nro_objs, D.nro_objs, ' ', 
                          '*') Warn 
FROM   (SELECT owner, 
               object_type, 
               Count(*) nro_objs 
        FROM   dba_objects@&&dblink 
        WHERE  owner NOT LIKE 'SYS%' 
        GROUP  BY owner, 
                  object_type) O, 
       (SELECT owner, 
               object_type, 
               Count(*) nro_objs 
        FROM   dba_objects 
        WHERE  owner NOT LIKE 'SYS%' 
        GROUP  BY owner, 
                  object_type) D 
WHERE  O.owner = D.owner (+) 
       AND O.object_type = D.object_type (+) 
       AND O.owner NOT IN ( 'DBSNMP', 'OUTLN', 'PUBLIC', 'DMSYS', 
                            'CTXSYS', 'EXFSYS', 'MDSYS', 'OLAPSYS', 
                            'ORDSYS', 'SCOTT', 'TSMSYS', 'WMSYS', 'XDB' ) 
       AND O.owner LIKE Upper('%&&owner') 
ORDER  BY 5, 
          1, 
          2; 	