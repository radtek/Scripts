prompt cria as views no schema BKP para consulta
prompt views:
prompt 	 -> bkp.DBA_TICKETS_HOJE
prompt 	 -> bkp.DBA_TICKETS_HOLD
prompt 	 -> bkp.DBA_TICKETS_ATIVOS

select '&ok' from dual;

-- aberto hoje
create or replace view bkp.DBA_TICKETS_HOJE
as
select  M.mrid as "Ticket",
	M.mrstatus as "Status", 
	M.mrtitle as "Titulo", 
	case M.MRPRIORITY when 1 then 'ALTA' when 2 then 'MEDIA' when 3 then 'BAIXA' end as "Prioridade", 
	AB.USER__BID as "Usuário", 
	M.MRSUBMITDATE as "Data de Abertura", 
	substr(M.mrdescription, 1, 250) as "Ultima descrição"
from FP.MASTER89 M
	inner join FP.MASTER89_ABDATA AB
		oN AB.mrid = M.mrid 
where trunc(M.MRSUBMITDATE) = trunc(sysdate)
order by M.mrstatus
/

create or replace view bkp.DBA_TICKETS_HOLD
as
select M.mrid as "Ticket",
	M.mrstatus as "Status", 
	M.mrtitle as "Titulo", 
	case M.MRPRIORITY when 1 then 'ALTA' when 2 then 'MEDIA' when 3 then 'BAIXA' end as "Prioridade", 
	AB.USER__BID as "Usuário", 
	M.MRSUBMITDATE as "Data de Abertura", 
	substr(M.mrdescription, 1, 250) as "Ultima descrição"
from FP.MASTER89 M
	inner join FP.MASTER89_ABDATA AB
		oN AB.mrid = M.mrid 
where M.mrstatus in ('Hold') 
order by M.mrstatus
/


create or replace view bkp.DBA_TICKETS_ATIVOS
as
select M.mrid as "Ticket",
	M.mrstatus as "Status", 
	M.mrtitle as "Titulo", 
	case M.MRPRIORITY when 1 then 'ALTA' when 2 then 'MEDIA' when 3 then 'BAIXA' end as "Prioridade", 
	AB.USER__BID as "Usuário", 
	M.MRSUBMITDATE as "Data de Abertura", 
	substr(M.mrdescription, 1, 250) as "Ultima descrição"
from FP.MASTER89 M
	inner join FP.MASTER89_ABDATA AB
		oN AB.mrid = M.mrid 
where M.mrstatus in ('In__bProcess', 'Open') 
order by M.mrstatus
/






create or replace view bkp.DBA_TICKETS_MOV
as
select  count(M.mrid) "Tickets",
	M.mrstatus as "Status"	
from FP.MASTER89 M
	inner join FP.MASTER89_ABDATA AB
		oN AB.mrid = M.mrid 
where trunc(M.MRUPDATEDATE) = trunc(sysdate)
and M.mrstatus not in ('In__bProcess', 'Open', 'hold') 
group by M.mrstatus
order by 1 desc
