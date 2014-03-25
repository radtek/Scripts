break on TABLE_NAME SKIP 1
set lines 2000
column "TABLE_NAME" format a20 WORD_WRAPPED
column "INDEX_NAME" format a20 WORD_WRAPPED
column "COLUMNS" format a50 WORD_WRAPPED
column "INDEX_TYPE" format a21
column "UNIQUENESS" format a10 
column "TABLESPACE_NAME" format a15 
column "NUM_ROWS" format 9999999999999
column "DISTINCT_KEYS" format 9999999999999
column "LAST_ANALYZED" format a10
column "BLEVEL" format 9999999999999
column "PARTITIONED" format a10

define owner = &owner
define table_name = &table_name

SELECT TBL.table_name, 
 	 TBL.index_name, 
	 I.INDEX_TYPE, 
	 I.UNIQUENESS,
	 "1" || 
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
	 DECODE("12", '', '', ',' || "12") as COLUMNS, 
	 I.tablespace_name, 
	 I.num_rows, 
	 I.DISTINCT_KEYS,
	 I.LAST_ANALYZED, 
	 BLEVEL, 
	 PARTITIONED, 
	 I.leaf_blocks, 
	 I.CLUSTERING_FACTOR
FROM (	select table_name, 
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
			MAX(CASE  column_position WHEN 12 THEN column_name ELSE '' END) AS "12"
		from dba_ind_columns
		where table_owner like UPPER('&owner')
		and table_name like UPPER('&table_name')
		group by index_name, 
			 table_name, 
			 table_owner)  TBL
	inner join dba_indexes I
		on i.index_name = TBL.index_name
		and I.table_name =TBL.table_name
		and I.owner = TBL.table_owner
order by 2;

clear columns
clear breaks
undef owner
undef table_name