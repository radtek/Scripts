-- Gera relatorio em HTML de FK sem indice 
set echo off 
set linesize 255 
set trims on 
set trimo on 
set feedback off 
set pagesize 0 
set arraysize 1 

prompt Aguarde a obtencao das FKs sem indices... 
set termout off 
spool fknoindex.htm 
prompt <HTML><HEAD><TITLE>FKs sem Indices</TITLE> 
prompt <STYLE type="text/css"> 
select 'h1 {' from dual union all 
select ' font-family: Verdana, Arial;' from dual union all 
select ' font-size: 18px;' from dual union all 
select ' font-weight : bold; ' from dual union all 
select ' color: silver; ' from dual union all 
select ' margin: 50px 0px 50px 20px;' from dual union all 
select ' }' from dual union all 
select '' from dual union all 
select '' from dual union all 
select ' td {' from dual union all 
select ' font-family: Tahoma, verdana, arial;' from dual union all 
select ' font-size: 10px;' from dual union all 
select ' font-weight: normal;' from dual union all 
select ' }' from dual union all 
select '' from dual union all 
select ' th { font-family: verdana, arial;' from dual union all 
select ' font-size: 10px;' from dual union all 
select ' font-weight: bold;' from dual union all 
select ' text-align: left;' from dual union all 
select ' vertical-align : top;' from dual union all 
select ' background-color: silver;' from dual union all 
select ' color: white;' from dual union all 
select ' }' from dual; 
prompt </STYLE></HEAD> 
prompt <BODY> 
set heading off 
select '<h1>FKs sem indices (' || name || ') ' || to_char(sysdate,'YYYY.MON.DD HH:MI:SS') || '</h1>' 
from v$database; 
prompt <TABLE border="1" cellspacing="0" cellpadding="3"> 
prompt <TR><TH>Owner pai</TH><TH>Pai</th><th>Owner filha</th><th>Filha</th><th>Nome FK</th><th>Coluna</th></tr> 
select '<tr><td>' || rc.owner || '</td><td>' || chr(10) || 
rc.table_name || '</td><td>' || acc.owner || '</td><td>' || chr(10) || 
acc.table_name || '</td><td>' || acc.constraint_name || '</td><td>' || chr(10) || 
acc.column_name ||'['||acc.position||']</td></tr>' 
from dba_constraints rc, dba_cons_columns acc, dba_constraints ac 
where ac.constraint_name = acc.constraint_name 
and ac.owner = acc.owner 
and ac.constraint_type = 'R' 
and rc.constraint_name = ac.r_constraint_name 
and rc.owner = ac.r_owner 
and (acc.owner, acc.table_name, acc.column_name, acc.position) in 
(select acc.owner, acc.table_name, acc.column_name, acc.position 
from dba_cons_columns acc, dba_constraints ac 
where ac.constraint_name = acc.constraint_name 
and ac.constraint_type = 'R' 
MINUS 
select table_owner, table_name, column_name, column_position 
from dba_ind_columns) 
order by rc.owner, rc.table_name, acc.owner, acc.table_name, acc.column_name, acc.position; 
prompt </table></body></html> 
spool off; 
set termout on 
prompt Terminado! 
host iexplore fknoindex.htm