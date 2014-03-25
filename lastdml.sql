define schema=&schema
define table=&table


select to_char(scn_to_timestamp(max(ora_rowscn))) from "&schema"."&table";

select * from DBA_TAB_MODIFICATIONS where table_owner = upper('&schema') and table_name = UPPER('&table');

undef schema
undef table