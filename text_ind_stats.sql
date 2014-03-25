  create table output (result CLOB);
 
  declare
    x clob := null;
  begin
    ctx_report.index_stats('&owner'||'.'||'&indexName',x);
    insert into output values (x);
    commit;
    dbms_lob.freetemporary(x);
  end;
  /
 
set long 32000
set head off
set pagesize 10000
select * from output; 
drop table output;
