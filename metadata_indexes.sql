set pages 2000
set lines 121
undef owner
undef tablename

--- não cobre indices particionados ou com função
SELECT 'DROP INDEX ' || I.owner || '.' || I.index_name || ';'
FROM  dba_indexes I
WHERE   I.table_owner like '&&owner' 
   and  I.table_name like '&&tablename'
order by 1;

--- não cobre indices particionados ou com função
SELECT 'CREATE ' || DECODE(I.UNIQUENESS, 'UNIQUE', 'UNIQUE', DECODE(I.INDEX_TYPE, 'BITMAP', 'BITMAP', '')) 
       || ' INDEX ' || I.owner || '.' || I.index_name
       || ' ON ' || I.table_owner || '.' || I.table_name 
       || '(' || "1" || 
       DECODE("2", '', '', ',' || "2") ||
       DECODE("3", '', '', ',' || "3") ||
       DECODE("4", '', '', ',' || "4") ||
       DECODE("5", '', '', ',' || "5") ||
       DECODE("6", '', '', ',' || "6") ||
       DECODE("7", '', '', ',' || "7") ||
       DECODE("8", '', '', ',' || "8") ||
       DECODE("9", '', '', ',' || "9") ||
       DECODE("10", '', '', ',' || "10") ||
       DECODE("11", '', '', ',' || "11") ||
       DECODE("12", '', '', ',' || "12") ||
       DECODE("13", '', '', ',' || "13") ||
       DECODE("14", '', '', ',' || "14") ||
       DECODE("15", '', '', ',' || "15") ||
       DECODE("16", '', '', ',' || "16") ||
       DECODE("17", '', '', ',' || "17") ||
       DECODE("18", '', '', ',' || "18") ||
       DECODE("19", '', '', ',' || "19") ||
       DECODE("20", '', '', ',' || "20") || ')' 
       || ' ' || DECODE(COMPRESSION, 'ENABLED', 'COMPRESS ' || PREFIX_LENGTH, 'NOCOMPRESS') 
       || ' ' || DECODE(LOGGING, 'YES', 'LOGGING', 'NOLOGGING') 
       || ' TABLESPACE ' || I.tablespace_name || ';'
FROM (  select table_name, 
       index_name, 
       table_owner,
		MAX(CASE  column_position WHEN 1 THEN column_name ELSE '' END) AS "1",
		  MAX(CASE  column_position WHEN 2 THEN column_name ELSE '' END) AS "2",
		  MAX(CASE  column_position WHEN 3 THEN column_name ELSE '' END) AS "3",
		  MAX(CASE  column_position WHEN 4 THEN column_name ELSE '' END) AS "4",
		  MAX(CASE  column_position WHEN 5 THEN column_name ELSE '' END) AS "5",
		  MAX(CASE  column_position WHEN 6 THEN column_name ELSE '' END) AS "6",
		  MAX(CASE  column_position WHEN 7 THEN column_name ELSE '' END) AS "7",
		  MAX(CASE  column_position WHEN 8 THEN column_name ELSE '' END) AS "8",
		  MAX(CASE  column_position WHEN 9 THEN column_name ELSE '' END) AS "9",
		  MAX(CASE  column_position WHEN 10 THEN column_name ELSE '' END) AS "10",
		  MAX(CASE  column_position WHEN 11 THEN column_name ELSE '' END) AS "11",
		  MAX(CASE  column_position WHEN 12 THEN column_name ELSE '' END) AS "12",
		  MAX(CASE  column_position WHEN 13 THEN column_name ELSE '' END) AS "13",
		  MAX(CASE  column_position WHEN 14 THEN column_name ELSE '' END) AS "14",
		  MAX(CASE  column_position WHEN 15 THEN column_name ELSE '' END) AS "15",
		  MAX(CASE  column_position WHEN 16 THEN column_name ELSE '' END) AS "16",
		  MAX(CASE  column_position WHEN 17 THEN column_name ELSE '' END) AS "17",
		  MAX(CASE  column_position WHEN 18 THEN column_name ELSE '' END) AS "18",
		  MAX(CASE  column_position WHEN 19 THEN column_name ELSE '' END) AS "19",
		  MAX(CASE  column_position WHEN 20 THEN column_name ELSE '' END) AS "20"
    from dba_ind_columns
    where table_owner like '&&owner' 
	  and table_name like '&&tablename'
    group by index_name, 
       table_name, 
       table_owner)  TBL
  inner join dba_indexes I
    on i.index_name = TBL.index_name
    and I.table_name =TBL.table_name
    and I.table_owner = TBL.table_owner
order by 1;

undef owner
undef tablename
