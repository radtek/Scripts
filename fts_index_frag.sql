prompt O sql abaixo motra a fragmentação dos índices textuais. Conforme as recomendações da Oracle existe uma tolerância de até 40% de fragmentação, depois disso a prompt performance cai gradualmente, e se passar de 75% deve se executar o optimizer o mais breve possível.
prompt 
prompt 

set serveroutput on

declare
sqldin varchar2(6000) := null;
sqlout number := null;
 
begin
  for a in (select idx_owner, idx_name, idx_status
              from ctxsys.ctx_indexes
             where idx_owner not in ('SYS', 'SYSTEM', 'CTXSYS','WKSYS','WMSYS','XDB')
               and idx_status = 'INDEXED') loop
sqldin := '
select avg(tfrag) from (select /*+ ORDERED USE_NL(i) INDEX(i '||a.idx_owner||'.DR$'||a.idx_name||'$X) */ i.token_text, (1-(least(round((sum(dbms_lob.getlength(i.token_info))/3800)+(0.50 - (1/3800))),count(*))/count(*)))*100 tfrag
from (select token_text, token_type from '||a.idx_owner||'.dr$'||a.idx_name||'$i sample(0.149) where rownum <= 100) t, '||a.idx_owner||'.dr$'||a.idx_name||'$i i
where i.token_text = t.token_text and i.token_type = t.token_type group by i.token_text, i.token_type)';
execute immediate sqldin into sqlout; 
DBMS_OUTPUT.PUT_LINE('Fragmentação estimada para o Index: '||a.idx_owner || '.' || a.idx_name||': '||to_char(sqlout)); 
--dbms_output.put_line(sqldin);
end loop;
 
end ;
/


prompt agendar para corrigir fragmentacao
prompt 
prompt declare
prompt   command varchar2(4000);
prompt begin
prompt   for i in (select idx_owner, idx_name, idx_status
prompt               from ctxsys.ctx_indexes
prompt              where idx_owner not in ('SYS', 'SYSTEM', 'CTXSYS','WKSYS','WMSYS','XDB')
prompt                and idx_status = 'INDEXED') loop
prompt DBMS_OUTPUT.PUT_LINE('Otimizando indice '||i.idx_owner || '.' || i.idx_name);
prompt     ctxsys.CTX_DDL.OPTIMIZE_INDEX ( idx_name =>i.idx_owner || '.' || i.idx_name, optlevel => 'FULL', maxtime  => 180 );
prompt   end loop;
prompt end;
prompt 