alter session set current_Schema=bi_dw;

create table fto_carteira_servico_BKP13 as 
select * 
from fto_carteira_servico as of timestamp TO_TIMESTAMP('18-04-12 08:00:00', 'dd-mm-yy hh24:mi:ss') 
where sk_tempo = 20120313 ;

commit;

create table fto_carteira_valores_BKP13 as
select * 
from  fto_carteira_valores  as of timestamp TO_TIMESTAMP('18-04-12 08:00:00', 'dd-mm-yy hh24:mi:ss') 
where sk_tempo = 20120313;

commit;

create table fto_carteira_pacote_BKP13 as
select *
from  fto_carteira_pacote as of timestamp TO_TIMESTAMP('18-04-12 08:00:00', 'dd-mm-yy hh24:mi:ss') 
where sk_tempo = 20120313;

commit;