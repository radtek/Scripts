prompt ### ### ### BROKER ### ### ### 
select pid, program from v$process where program like 'oracle%(N%)';

prompt ### ### ### POOL ### ### ### 
select pid, program from v$process where program like 'oracle%(L0%)';