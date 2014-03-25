prompt ***** warning *****
prompt USERNAME é informado com IN, portanto é necessário incluir aspas simples
prompt 
prompt 
select 'CREATE USER '||username||' identified by values  '''||password||''' default tablespace '||default_tablespace||';' 
from dba_users 
where username in (&USERNAME);