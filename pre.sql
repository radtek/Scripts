drop table my_stats; 
create table my_stats as select * from v$mystat;