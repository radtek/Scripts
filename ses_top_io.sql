prompt 20 tops 
prompt Informe a coluna para ordenamento:
prompt 2 - block_gets
prompt 3 - CONSISTENT_GETS
prompt 4 - PHYSICAL_READS
prompt 5 - BLOCK_CHANGES
accept order prompt "Informe o numero:"

select * from (select sid, block_gets, CONSISTENT_GETS, PHYSICAL_READS, BLOCK_CHANGES from V$SESS_IO order by &order desc)
where rownum < 20 ;

undef order


