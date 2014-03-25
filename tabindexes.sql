accept owner prompt "informe owner:"
accept table_name prompt "informe table_name:"

column table_owner format a15
column table_name format a20
column index_name format a20
column column_name format a20
 
Select index_name, column_name, column_position
FROM dba_ind_columns
Where table_owner=upper('&&owner')
AND table_name= upper('&&table_name')
Order by column_position;

undef owner
undef table_name