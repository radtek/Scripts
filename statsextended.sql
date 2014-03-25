define owner = &owner
define table_name = &table_name

SELECT extension_name, extension, density, num_distinct
FROM all_stat_extensions e JOIN all_tab_col_statistics s
ON ( e.owner = s.owner
AND e.table_name = s.table_name
AND e.extension_name = s.column_name
)
WHERE e.owner = UPPER('&owner') AND e.table_name = UPPER('&table_name')

undef table_name 
undef owner