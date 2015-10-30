col low_value for a100
col high_value for a100
-- somente para colunas number
define TABLENAME=&TABLENAME
define OWNER=&OWNER
define COLNAME=&COLNAME

select
    endpoint_value              column_value,
    endpoint_number - nvl(prev_endpoint,0)  frequency
from    (
    select
        endpoint_number,
        lag(endpoint_number,1) over(
            order by endpoint_number
        )               prev_endpoint,
        endpoint_value
    from
        DBA_tab_histograms
    where
        table_name  = UPPER('&TABLENAME')
    and column_name = UPPER('&COLNAME')
	and owner = UPPER('&OWNER')
    )
order by endpoint_number;

SELECT num_distinct, UTL_RAW.cast_to_number (low_value) low_value, UTL_RAW.cast_to_number (high_value) high_value
FROM DBA_tab_col_statistics
WHERE table_name = UPPER('&TABLENAME')
AND column_name = UPPER('&COLNAME')
and owner = UPPER('&OWNER');

undef TABLENAME
undef COLNAME
undef OWNER