INDEX----------
select INDEX_NAME, table_name from dba_indexes where owner= 'PRD_SATOP'
and index_name not like 'SYS%' order by table_name

TABLE -----------
select table_name from dba_tables where owner= 'PRD_SATOP' order by table_name

SEQUENCE ---------
select sequence_name from dba_sequences where sequence_owner= 'PRD_SATOP' order by sequence_name


TRIGGER ---------
select trigger_name from dba_triggers where owner= 'PRD_SATOP' order by trigger_name

constraint -------
select constraint_name,  table_name from dba_constraints where owner= 'PRD_SATOP' 
and constraint_name not like 'SYS%' order by table_name, constraint_name


PK -----------
Select column_name, table_name FROM dba_ind_columns Where table_owner='PRD_SATOP' Order by table_name, column_name;
