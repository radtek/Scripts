/******************************************************************************\
* TraceGP 5.2.0.24                                                             *
\******************************************************************************/

insert into detalhe_disponivel_info (detalhe_disponivel_info_id, titulo, informacao_disponivel_doc_id, vigente, codigo, ordem) values
((select MAX(detalhe_disponivel_info_id)+1 from detalhe_disponivel_info), 'label.prompt.porcentagemConcluidaPrevista', 1, 'S', 'PORCENTAGEM_CONCLUIDA_PREVISTA',15);
commit;
/


alter table h_usuario modify email varchar2(100);
alter table usuario add autenticacao_nativa varchar2(1);
--
begin
  -- Monta cursos com tarefas concluídas e último percentual concluído <> 100%
  for trf in (select t.id id, t.situacao, pc.data data, pc.perc_concluido
                from tarefa t,
                     percentual_concluido pc
               where pc.perc_concluido <> 100
                 and pc.entidade_id   = t.id
                 and pc.tipo_entidade = 'T'
                 and pc.data = (select max(pc2.data)
                                  from percentual_concluido pc2
                                 where pc2.tipo_entidade = 'T'
                                   and pc2.entidade_id   = t.id)
                 and t.situacao       = 3) loop
    --
    begin
      update percentual_concluido
         set perc_concluido = 100
       where tipo_entidade = 'T'
         and entidade_id   = trf.id
         and data          = trf.data;
     exception
       when others then
         dbms_output.put_line('Erro na atualização da tarefa ' || trf.id || '[' || sqlerrm);
     end;
  end loop;
  commit;
end;
/


create or replace package pck_eva is

   -- tipos
   type t_entidade is record (
        tipo_entidade  varchar2(1),
        entidade_id    number(10),
        data           date,
        perc_concluido number(5,2),
        inicio         date);

   type tt_array_entidade is table of t_entidade index by binary_integer;
   
   gt_alteracao_perc_concluido tt_array_entidade;
   gt_alteracao_hora_prevista  tt_array_entidade;
   gt_array_vazio              tt_array_entidade;
   
   -- Rotinas para calculo EV
   procedure p_calcula_pv_ac_bac_diverso;
   procedure p_calcula_pv_ac_bac_pessoal;
   procedure p_atribui_pv_ac_bac(pd_data_processo date);   
   procedure p_prepara_calculo_pv_ac_bac;
   procedure p_atualiza_tab_eva(pd_data date default trunc(sysdate));
   procedure p_atualiza_cpi_spi;
   
   -- Rotinas para atualizaçao de Percentual concluido
   procedure p_calculo_percentual_pai(pv_tipo_entidade  in percentual_concluido.tipo_entidade%type,
                                      pn_entidade_id    in percentual_concluido.entidade_id%type,
                                      pd_data           in percentual_concluido.data%type,
                                      pn_perc_concluido in percentual_concluido.perc_concluido%type);

  
  -- Rotinas para atualizaçao de Percentual concluido das atividades e dos projetos
   procedure p_calculo_percentual(pv_tipo_entidade  in percentual_concluido.tipo_entidade%type,
                                  pn_entidade_id    in percentual_concluido.entidade_id%type,
                                  pd_data           in percentual_concluido.data%type);
                                  
  -- ROtina para incluir percentual concluido inicial a entidades que nao possuem nenhum registro de percentual
  procedure p_inicializa_percentual(pd_data_processo date);
  
  function f_versao return varchar2;
end pck_eva;
/

--==============================================================================
create or replace package body pck_eva is

--------------------------------------------------------------------------------
-- 
function f_versao return varchar2 is
  begin
    return '1.00.03';
  end f_versao;
  
  
procedure p_calcula_pv_ac_bac_diverso is

begin
   insert into eva_ipg(tipo_entidade, entidade_id, data, pv, ac, bac, pv_ano, tipo)
   select tipo_entidade, entidade_id, data, PV, AC, BAC, PV_ANO, tipo
     from v_eva_calculo_diverso
    where data < trunc(sysdate+1);
   commit;
       
end p_calcula_pv_ac_bac_diverso;
--------------------------------------------------------------------------------
-- 
procedure p_calcula_pv_ac_bac_pessoal is

begin
-- Calculo de valores realizados
   pck_versao.p_log_versao('I', '     Calcula valores realizados', 
                           pck_versao.CN_STD_EVA); 
   insert into eva_ipg(entidade_id, tipo_entidade, data, ac, ac_tempo, tipo)
          select evp.entidade_id, evp.tipo_entidade, evp.data, 
                 sum(nvl(vcht.custo_total,0)), sum(nvl(vcht.minutos_trab,0)), 'R'
            from eva_ipg                 evp,
                 v_entidade_dependentes  ved,
                 v_custo_hora_trabalhada vcht
           where vcht.data_trab       <= evp.data
             and vcht.tarefa           = ved.entidade_id_dep
             and ved.tipo_entidade_dep = 'T'
             and ved.entidade_id       = evp.entidade_id
             and ved.tipo_entidade     = evp.tipo_entidade
             and evp.tipo              = 'O'
             and vcht.data_trab        < trunc(sysdate+1)
          group by evp.tipo_entidade, evp.entidade_id, evp.data;
   commit;
     
-- Calculo de valores planejados
   pck_versao.p_log_versao('I', '     Calcula valores planejados', 
                           pck_versao.CN_STD_EVA); 
   insert into eva_ipg(entidade_id, tipo_entidade, data, pv, pv_tempo, bac, bac_tempo, pv_ano, pv_ano_tempo, tipo)
          select x.entidade_id, x.tipo_entidade, x.data,
                 sum(nvl(x.pv_tempo,0) * nvl(x.valor_hora,0)) PV,
                 sum(nvl(x.pv_tempo,0)) PV_TEMPO,
                 sum(nvl(x.bac_tempo,0) * nvl(x.valor_hora,0)) BAC,
                 sum(nvl(x.bac_tempo,0)) BAC_TEMPO,
                 sum(nvl(x.pv_ano_tempo,0) * nvl(x.valor_hora,0)) PV_ANO,
                 sum(nvl(x.pv_ano_tempo,0)) PV_ANO_TEMPO,                 
                 'P'
            from ( select evp.entidade_id, evp.tipo_entidade, evp.data, vct.valor_hora,
                          case when least(evp.data, vct.final_valor) >= vct.inicio_valor 
                               then least(evp.data, vct.final_valor) - vct.inicio_valor + 1
                               else 0
                          end * vct.horas_por_dia PV_TEMPO,
                          nvl((vct.final_valor - vct.inicio_valor + 1),0) * vct.horas_por_dia BAC_TEMPO,
                          case when least(add_months(evp.data,12), vct.final_valor) > vct.inicio_valor 
                               then least(add_months(evp.data,12), vct.final_valor) - vct.inicio_valor + 1
                               else 0
                          end * vct.horas_por_dia PV_ANO_TEMPO
                     from v_custo_tarefa         vct,
                          eva_ipg                evp,
                          v_entidade_dependentes ved
                    where vct.id                = ved.entidade_id_dep
                      and ved.tipo_entidade_dep = 'T'
                      and evp.tipo              = 'O'
                      and ved.entidade_id       = evp.entidade_id
                      and ved.tipo_entidade     = evp.tipo_entidade) x
             where x.data < trunc(sysdate+1)
            group by x.tipo_entidade, x.entidade_id, x.data;
   commit;
            
end p_calcula_pv_ac_bac_pessoal;

--------------------------------------------------------------------------------
-- 
procedure p_atribui_pv_ac_bac(pd_data_processo date) is
   lb_grava              boolean;
   lb_grava_tempo        boolean;
   lt_ipg_ant            v_eva_ipg%rowtype;
   ln_conta              number; 
   ln_pv_original        number; 
   ln_bac_original       number; 
   ln_pv_geral_original  number; 
   ln_bac_geral_original number; 
   ln_conta_reg          number;
   ln_conta_reg_total    number;
begin

-- Inicia variaveis
lt_ipg_ant.tipo_entidade := 'X';
lt_ipg_ant.entidade_id   := 0;
ln_conta              := 0;
ln_pv_original        := 0;
ln_bac_original       := 0;
ln_pv_geral_original  := 0;
ln_bac_geral_original := 0;
ln_conta_reg          := 0;
ln_conta_reg_total    := 0;

pck_versao.p_log_versao('I', '     Inícia atribuíção de valores calculados', 
                        pck_versao.CN_STD_EVA); 
for ipg in (select * from v_eva_ipg
            order by tipo_entidade, entidade_id, data) loop
    
    lb_grava       := false;            
    lb_grava_tempo := false;
    
    -- Verifica se data já existe na tabela de EVA
    select count(1)
      into ln_conta
      from eva
     where tipo_entidade = ipg.tipo_entidade 
       and entidade_id   = ipg.entidade_id     
       and data          = ipg.data;
    if ln_conta > 0 then
      lb_grava := true; 
    end if;
    
    -- Verifica se data já existe na tabela de EVA
    select count(1)
      into ln_conta
      from eva_tempo
     where tipo_entidade = ipg.tipo_entidade 
       and entidade_id   = ipg.entidade_id     
       and data          = ipg.data;
    if ln_conta > 0 then
      lb_grava_tempo := true; 
    end if;
    
    -- Verifica se existe alteraçao alterou entidade
    if (lt_ipg_ant.tipo_entidade <> ipg.tipo_entidade) or 
       (lt_ipg_ant.entidade_id   <> ipg.entidade_id) then
       lb_grava       := true;            
       lb_grava_tempo := true;
    end if;
    
    -- Verifica se ocorreu mudança de valor, se sim realiza alteraçao
    if (lt_ipg_ant.pv           <> ipg.pv           or
        lt_ipg_ant.pv_ano       <> ipg.pv_ano       or
        lt_ipg_ant.ac           <> ipg.ac           or
        lt_ipg_ant.bac          <> ipg.bac          or
        lt_ipg_ant.pv_geral     <> ipg.pv_geral     or
        lt_ipg_ant.pv_ano_geral <> ipg.pv_ano_geral or
        lt_ipg_ant.ac_geral     <> ipg.ac_geral     or
        lt_ipg_ant.bac_geral    <> ipg.bac_geral    ) then
      lb_grava := true;                  
    end if;
    
    -- Verifica se ocorreu mudança de valor em relaçao ao tempo, se sim realiza alteraçao
    if (lt_ipg_ant.pv_tempo      <> ipg.pv_tempo     or
        lt_ipg_ant.pv_ano_tempo  <> ipg.pv_ano_tempo or
        lt_ipg_ant.ac_tempo      <> ipg.ac_tempo     or
        lt_ipg_ant.bac_tempo     <> ipg.bac_tempo    ) then
      lb_grava_tempo := true;                  
    end if;    
    
    -- Trabalha com EVA (monetario)
    -------
    if (lb_grava) then 
      -- verifica se necessaria inclusao
      select count(1)
        into ln_conta
        from eva
       where tipo_entidade = ipg.tipo_entidade
         and entidade_id   = ipg.entidade_id
         and data          = ipg.data;
    
      if (ln_conta = 0) then -- Inclusao apenas de novos registros diferentes
         if (trunc(pd_data_processo) <= trunc(ipg.data)) then -- Verifica se deve inserir os originais, ou utilizar o último existente
            -- Inclui com originais calculados (dia do processo)
            ln_pv_original        := ipg.pv;
            ln_bac_original       := ipg.bac; 
            ln_pv_geral_original  := ipg.pv_geral;
            ln_bac_geral_original := ipg.bac_geral;
         else -- Registro passado, utilzar original existente para a data
            begin
            select pv_original, bac_original, pv_geral_original, bac_geral_original
              into ln_pv_original, ln_bac_original, ln_pv_geral_original, ln_bac_geral_original
                   from eva e
                  where e.tipo_entidade = ipg.tipo_entidade
                    and e.entidade_id   = ipg.entidade_id
                    and e.data          = (select max(e2.data) from eva e2 
                                            where e2.tipo_entidade = ipg.tipo_entidade
                                              and e2.entidade_id   = ipg.entidade_id);
            exception
               when NO_DATA_FOUND then
                  ln_pv_original        := ipg.pv;
                  ln_bac_original       := ipg.bac; 
                  ln_pv_geral_original  := ipg.pv_geral;
                  ln_bac_geral_original := ipg.bac_geral;
            end;
         end if;
        
         insert into eva(id, data, entidade_id, tipo_entidade, 
                         pv, pv_ano, ac, bac, pv_geral, pv_ano_geral, ac_geral, bac_geral, atualizar,
                         pv_original, bac_original, pv_geral_original, bac_geral_original)
                  values(eva_seq.nextval, ipg.data, ipg.entidade_id, ipg.tipo_entidade,
                         ipg.pv, ipg.pv_ano, ipg.ac, ipg.bac, ipg.pv_geral, ipg.pv_ano_geral, 
                         ipg.ac_geral, ipg.bac_geral, 'N', ln_pv_original, ln_bac_original, 
                         ln_pv_geral_original, ln_bac_geral_original);                                     
      else                                            
         update eva
            set pv = ipg.pv, pv_ano = ipg.pv_ano, ac = ipg.ac, bac = ipg.bac,
                pv_geral = ipg.pv_geral, pv_ano_geral = ipg.pv_ano_geral, 
                ac_geral = ipg.ac_geral, bac_geral = ipg.bac_geral, atualizar = 'N'
          where tipo_entidade = ipg.tipo_entidade
            and entidade_id   = ipg.entidade_id
            and data          = ipg.data;
      end if; -- ln_conta
    end if; -- lb_grava
     
   
    -- Trabalha com EVA Tempo
    -------
    if (lb_grava_tempo) then
      -- verifica se necessaria inclusao
      select count(1)
        into ln_conta
        from eva_tempo
       where tipo_entidade = ipg.tipo_entidade
         and entidade_id   = ipg.entidade_id
         and data          = ipg.data;
            
      if (ln_conta = 0) then -- Inclusao apenas de novos registros diferentes
         if (trunc(pd_data_processo) <= trunc(ipg.data)) then -- Verifica se deve inserir os originais, ou utilizar o último existente
            -- Inclui com originais calculados (dia do processo)
            ln_pv_original        := ipg.pv_tempo;
            ln_bac_original       := ipg.bac_tempo; 
         else -- Registro passado, utilzar original existente para a data
            begin
            select pv_original, bac_original
              into ln_pv_original, ln_bac_original
                   from eva_tempo e
                  where e.tipo_entidade = ipg.tipo_entidade
                    and e.entidade_id   = ipg.entidade_id
                    and e.data          = (select max(e2.data) from eva_tempo e2 
                                            where e2.tipo_entidade = ipg.tipo_entidade
                                              and e2.entidade_id   = ipg.entidade_id);
            exception
               when NO_DATA_FOUND then
                  ln_pv_original        := ipg.pv;
                  ln_bac_original       := ipg.bac; 
            end;                                            
         end if;
        
         insert into eva_tempo(id, data, entidade_id, tipo_entidade, 
                               pv, pv_ano, ac, bac, pv_original, bac_original)
                        values(eva_tempo_seq.nextval, ipg.data, ipg.entidade_id, ipg.tipo_entidade,
                               ipg.pv_tempo, ipg.pv_ano_tempo, ipg.ac_tempo, ipg.bac_tempo, 
                               ln_pv_original, ln_bac_original);  
      else
         update eva_tempo
            set pv = ipg.pv_tempo, pv_ano = ipg.pv_ano_tempo, ac = ipg.ac_tempo, bac = ipg.bac_tempo
          where tipo_entidade = ipg.tipo_entidade
            and entidade_id   = ipg.entidade_id
            and data          = ipg.data;
      end if; -- ln_conta
    end if;
    
    ln_conta_reg       := ln_conta_reg + 1;
    ln_conta_reg_total := ln_conta_reg_total + 1;
    if ln_conta_reg >= 5000 then
      pck_versao.p_log_versao('I', '     Cálculados ' || ln_conta_reg_total || ' registros', 
                              pck_versao.CN_STD_EVA);
      commit; 
      ln_conta_reg := 0;
    end if;
    
    lt_ipg_ant := ipg;
    
    end loop;
  pck_versao.p_log_versao('I', '     Cálculados ' || ln_conta_reg_total || ' registros', 
                          pck_versao.CN_STD_EVA); 
  commit;
  pck_versao.p_log_versao('I', '     Termina atribuíção de valores calculados', 
                        pck_versao.CN_STD_EVA); 
end p_atribui_pv_ac_bac;

--------------------------------------------------------------------------------
-- 
procedure p_prepara_calculo_pv_ac_bac is

begin 

-- Passo 1. 
-- Inclui registro para os dias em que iniciam projetos, atividades e tarefas, e nao ha registro
-- Projetos
   pck_versao.p_log_versao('I', '     Verifica possiveis datas de inicio de projetos sem calculo de EVA realizado', 
                           pck_versao.CN_STD_EVA); 
   insert into eva_ipg(tipo_entidade, entidade_id, data, tipo)   
   select distinct 'P', p.id, trunc(dia), 'O'
     from v_dias,
          projeto p
    where dia between least(p.datainicio, nvl(p.iniciorealizado,p.datainicio))
                  and greatest(p.prazoprevisto, nvl(p.prazorealizado, p.prazoprevisto))         
      and not exists (select 1 from eva 
                       where tipo_entidade = 'P'
                         and entidade_id   = p.id
                         and trunc(data)   = dia)
      and dia < trunc(sysdate+1); 
   commit;
                         
-- Atividades
   pck_versao.p_log_versao('I', '     Verifica possiveis datas de inicio de atividades sem calculo de EVA realizado', 
                           pck_versao.CN_STD_EVA); 
   dbms_output.put_line('Passo 1.Atividades [p_prepara_calculo_pv_ac_bac]');
   insert into eva_ipg(tipo_entidade, entidade_id, data, tipo)   
   select distinct 'A', a.id, trunc(dia), 'O'
     from v_dias,
          atividade a
    where dia between least(a.datainicio, nvl(a.iniciorealizado,a.datainicio))
                  and greatest(a.prazoprevisto, nvl(a.prazorealizado, a.prazoprevisto))        
      and not exists (select 1 from eva 
                       where tipo_entidade = 'A'
                         and entidade_id   = a.id
                         and trunc(data)   = dia)
      and dia < trunc(sysdate+1);   
   commit;                         

-- Tarefas
   pck_versao.p_log_versao('I', '     Verifica possiveis datas de inicio de tarefas sem calculo de EVA realizado', 
                           pck_versao.CN_STD_EVA); 
   insert into eva_ipg(tipo_entidade, entidade_id, data, tipo)   
   select distinct 'T', t.id, trunc(dia), 'O'
     from v_dias,
          tarefa t
    where dia between least(t.datainicio, nvl(t.iniciorealizado,t.datainicio))
                  and greatest(t.prazoprevisto, nvl(t.prazorealizado, t.prazoprevisto))         
      and not exists (select 1 from eva 
                       where tipo_entidade = 'T'
                         and entidade_id   = t.id
                         and trunc(data)   = dia)
      and projeto is not null
      and dia < trunc(sysdate+1);   
   commit;      

-- Passo 2. 
-- Inclui registros para os dias que existem custos/receitas diversos, mas nao existe registro em EVA
   pck_versao.p_log_versao('I', '     Verifica possiveis datas com lançamentos de custos diversos, mas sem calculo de EVA realizado', 
                           pck_versao.CN_STD_EVA);
insert into eva_ipg(tipo_entidade, entidade_id, data, tipo)
select distinct mvcl.tipo_entidade, mvcl.entidade_id, mvcl.data, 'O'
  from mv_custo_lancamento mvcl
 where mvcl.situacao = 'V'
   and mvcl.tipo_entidade in ('P', 'A', 'T')
   and not exists (select data 
                     from eva
                    where tipo_entidade = mvcl.tipo_entidade 
                      and entidade_id   = mvcl.entidade_id
                      and data          = mvcl.data)
   and not exists (select data 
                     from eva_ipg 
                    where tipo_entidade = mvcl.tipo_entidade 
                      and entidade_id   = mvcl.entidade_id
                      and data          = mvcl.data)
   and mvcl.data < trunc(sysdate+1);
   commit;                            

-- Passo 3.
-- Inclui registros para os dias que existem lançamento de horas, mas nao ha registro
   pck_versao.p_log_versao('I', '     Verifica possiveis datas com registro de horas trabalhadas mas sem calculo de EVA realizado', 
                           pck_versao.CN_STD_EVA); 
   insert into eva_ipg(tipo_entidade, entidade_id, data, tipo)
   select distinct 'T', ht.tarefa, ht.datatrabalho, 'O'
     from horatrabalhada ht
    where ht.minutos > 0
      and not exists (select 1 
                        from eva
                       where tipo_entidade = 'T'
                         and entidade_id   = ht.tarefa
                         and data          = ht.datatrabalho)
      and not exists (select 1 
                        from eva_ipg 
                       where tipo_entidade = 'T' 
                         and entidade_id   = ht.tarefa
                         and data          = ht.datatrabalho)
      and ht.datatrabalho < trunc(sysdate+1);                                   
                                     
                                     
   commit;
end p_prepara_calculo_pv_ac_bac;



-------------------------------------------------------------------------------
--
procedure p_atualiza_tab_eva(pd_data date default trunc(sysdate)) is
   ld_ult_exec date;
   ln_conta    number;
begin
  -- Limpa tabela temporaria do processo de calculo do EVA
  pck_versao.p_log_versao('I', '  Truncate na tabela EVA_IPG', pck_versao.CN_STD_EVA);  
  execute immediate 'truncate table eva_ipg';
  
  -- Atualiza tabela EVA
  pck_versao.p_log_versao('I', '  Busca entidades que necessitam novo calculo', pck_versao.CN_STD_EVA);    
  begin
     select valor_data
       into ld_ult_exec
       from tracegp_config
      where variavel = 'EVA: ULTIMA_EXECUCAO';
  exception
     when OTHERS then
        ld_ult_exec := to_date('01011900','ddmmyyyy');
  end;
   
   update eva
      set atualizar     = 'Y'
    where (tipo_entidade = 'T' and entidade_id in (select tarefa_id from h_tarefa       
                                                    where trunc(data) >= ld_ult_exec))
       or (tipo_entidade = 'A' and entidade_id in (select atividade_id from h_atividade 
                                                    where trunc(data) >= ld_ult_exec))
       or (tipo_entidade = 'P' and entidade_id in (select projeto_id from h_projeto     
                                                    where trunc(data) >= ld_ult_exec));
   
   insert into eva (id, tipo_entidade, entidade_id, data)  
   select eva_seq.nextval, ent.tipo, ent.id, trunc(ent.data)
     from ( select distinct 'T' tipo, tarefa_id id, trunc(data) data
              from h_tarefa 
             where trunc(data) > ld_ult_exec
            union 
            select distinct 'A' tipo, atividade_id id, trunc(data) data
              from h_atividade 
             where trunc(data) > ld_ult_exec
            union 
            select distinct 'P' tipo, projeto_id id, trunc(data) data
              from h_projeto
             where trunc(data) >= ld_ult_exec ) ENT
    where not exists ( select 1 from eva
                        where tipo_entidade = ent.tipo
                          and entidade_id   = ent.id
                          and trunc(data)   = trunc(ent.data) );
  
  -- Copia registros para calculo
  pck_versao.p_log_versao('I', '  Insere registro de entidades x datas em EVA_IPG para calculo', pck_versao.CN_STD_EVA);    
  insert into eva_ipg(entidade_id, tipo_entidade, data, tipo)
  select distinct entidade_id, tipo_entidade, data, 'O'
    from eva
   where atualizar = 'Y';
  commit;
  
  -- Verifica necessidade de inclusao de outros registros para a realizaçao do calculo
  pck_versao.p_log_versao('I', '  Verifica outras potenciais entidades e datas para calculo', pck_versao.CN_STD_EVA);    
  p_prepara_calculo_pv_ac_bac;
  commit;
  
  -- Calcula informações sobre custos diversos
  pck_versao.p_log_versao('I', '  Calculo de informações relativas a custo diverso', pck_versao.CN_STD_EVA);    
  p_calcula_pv_ac_bac_diverso;
  commit;
  pck_versao.p_log_versao('I', '  Calculo de informações relativas a custo de pessoal', pck_versao.CN_STD_EVA);    
  p_calcula_pv_ac_bac_pessoal;
  commit;
  
  -- Retira possiveis valores com datas problematicas da eva_ipg
  delete from eva_ipg where data > sysdate;
  commit;
  
  -- Inclui valores nas tabelas EVA e EVA_TEMPO
  pck_versao.p_log_versao('I', '  Atualiza tabela com informações de EVA calculadas', pck_versao.CN_STD_EVA);    
  p_atribui_pv_ac_bac(pd_data);
  commit;
  
  -- Atualiza informações de CPI e SPI nas tabelas das entidades
  pck_versao.p_log_versao('I', '  Atualiza CPI e SPI nas entidades', pck_versao.CN_STD_EVA);    
  p_atualiza_cpi_spi;
  commit;
  
  -- Verifica/ajusta registros de entidades sem percentual concluido
  pck_versao.p_log_versao('I', '  Verifica/ajusta entidades sem informaçao de percentual concluido', 
                          pck_versao.CN_STD_EVA);    
  p_inicializa_percentual(pd_data);
  commit;
  
  -- Limpa tabela temporaria do processo de calculo do EVA
  --execute immediate 'truncate table eva_ipg';
  
  -- Atualiza data da última execuçao
  pck_versao.p_log_versao('I', '  Atualiza parâmetro com data da última execuçao para ' || 
                          to_char(pd_data, 'dd/mm/yyyy'), pck_versao.CN_STD_EVA);    
  select count(1) into ln_conta 
    from tracegp_config 
   where variavel = 'EVA: ULTIMA_EXECUCAO';
  
  if ln_conta = 0 then
     insert into tracegp_config (variavel, valor_data)
            values ('EVA: ULTIMA_EXECUCAO', trunc(pd_data));
  else
     update tracegp_config
        set valor_data = trunc(pd_data)
      where variavel = 'EVA: ULTIMA_EXECUCAO';  
  end if;
  commit;
  
end p_atualiza_tab_eva;


procedure p_calculo_percentual_pai(pv_tipo_entidade  in percentual_concluido.tipo_entidade%type,
                                   pn_entidade_id    in percentual_concluido.entidade_id%type,
                                   pd_data           in percentual_concluido.data%type,
                                   pn_perc_concluido in percentual_concluido.perc_concluido%type) is 
                                   
    lv_tipo_entidade        percentual_concluido.tipo_entidade%type;
    ln_entidade_id          percentual_concluido.entidade_id%type;
begin
   -- Busca dados entidade pai
   begin
   select tipo_entidade_pai, entidade_id_pai
     into lv_tipo_entidade, ln_entidade_id
     from v_cronograma_hierarquia
    where tipo_entidade = pv_tipo_entidade
      and entidade_id   = pn_entidade_id;
   exception
      when NO_DATA_FOUND then
         lv_tipo_entidade := null;
         ln_entidade_id   := null;
         return;
   end;
  
   p_calculo_percentual(lv_tipo_entidade, ln_entidade_id, pd_data);
   
end p_calculo_percentual_pai;

procedure p_calculo_percentual(pv_tipo_entidade in percentual_concluido.tipo_entidade%type,
                                pn_entidade_id   in percentual_concluido.entidade_id%type,
                                pd_data          in percentual_concluido.data%type) is
    ln_horas_concluidas     number(16,2);
    ln_horas_previstas      number(16,2);
    ln_percentual_concluido percentual_concluido.perc_concluido%type;
    ln_conta                number;
    ln_max_data             date;
    ln_situacao             projeto.situacao%type;
 begin                                  
    -- Busca situaçao da entidade pai
   begin
      if pv_tipo_entidade = 'P' then
         select situacao into ln_situacao from projeto
          where id = pn_entidade_id;
      elsif (pv_tipo_entidade = 'A') then
         select situacao into ln_situacao from atividade
          where id = pn_entidade_id;
      elsif (pv_tipo_entidade = 'T') then
         select situacao into ln_situacao from tarefa
          where id = pn_entidade_id;
      else
         ln_situacao := null;
      end if;    
   exception
      when OTHERS then
         ln_situacao := null;
   end;
  
   -- Nao possui entidade pai
   if (pv_tipo_entidade is null or pn_entidade_id is null or ln_situacao is null) then
      return;
   end if;

   -- Calcula total de horas consideradas concluidas
   begin
   select sum(nvl(vch.horas_previstas,0) * (nvl(vepd.perc_concluido,0)/100)),
          sum(nvl(vch.horas_previstas,0))
     into ln_horas_concluidas, ln_horas_previstas
     from v_cronograma_hierarquia vch,
          v_eva_percentual_dados vepd
    where vepd.tipo_entidade    = vch.tipo_entidade
      and vepd.entidade_id      = vch.entidade_id
      and vepd.dia              = pd_data
      and vch.tipo_entidade_pai = pv_tipo_entidade
      and vch.entidade_id_pai   = pn_entidade_id 
      and vch.situacao         <> 4 /* Nao considera itens cancelados */;
           
   exception
      when NO_DATA_FOUND then
         ln_horas_concluidas := 0;
         ln_horas_previstas  := 0;
         return;
   end;      
   
   if (nvl(ln_horas_previstas,0) <> 0) then
      ln_percentual_concluido := round((nvl(ln_horas_concluidas,0) / nvl(ln_horas_previstas,0)) * 100);
   else
      ln_percentual_concluido := 0; -- Assume 0 quando nao existe horas previstas
   end if;
   
   -- Ajusta conforme situacao da entidade
   if (ln_situacao <> 3 and ln_percentual_concluido = 100) then
      ln_percentual_concluido := 99;
   elsif (ln_situacao = 3 and ln_percentual_concluido <> 100) then
      ln_percentual_concluido := 100;
   end if;
   
   -- Verifica se o percentual e diferente do hoje valido para a data
   select count(1)
     into ln_conta
     from v_eva_percentual_dados vepd
    where vepd.tipo_entidade  = pv_tipo_entidade
      and vepd.entidade_id    = pn_entidade_id
      and vepd.dia            = pd_data
      and vepd.perc_concluido = ln_percentual_concluido;
      
   --
   if ln_conta = 0 then
      -- Atualiza percentual concluido
      update percentual_concluido
         set perc_concluido = ln_percentual_concluido
       where tipo_entidade  = pv_tipo_entidade
         and entidade_id    = pn_entidade_id
         and data           = pd_data;
 
      -- Verifica se algum registro foi modificado, se nao, inclui um registro.
      if sql%rowcount = 0 then
         insert into percentual_concluido (id, data, tipo_entidade, 
                                           entidade_id, perc_concluido)
                values (percentual_concluido_seq.nextval, pd_data, pv_tipo_entidade, 
                        pn_entidade_id, ln_percentual_concluido);
      end if;
   end if;

exception
   when NO_DATA_FOUND then
      return;
 end p_calculo_percentual;


----------------------------------------------------------------------------------------------------
procedure p_atualiza_cpi_spi is
begin
   pck_versao.p_log_versao('I', '     Inclui valores calculados de CPI e SPI na tabela EVA_IPG', 
                           pck_versao.CN_STD_EVA);    
   
   insert into eva_ipg(tipo_entidade, entidade_id, tipo, cpi_calculado, spi_calculado)
          select v.tipo_entidade, v.entidade_id, 'I', max(v.cpi), max(v.spi)
            from v_eva v,
                 eva_ipg ei
           where ei.tipo = 'O'
             and ei.tipo_entidade = v.tipo_entidade
             and ei.entidade_id   = v.entidade_id
             and ei.data          = v.dia
             and v.dia = (select max(e.data)
                            from eva e
                           where e.tipo_entidade = v.tipo_entidade
                             and e.entidade_id   = v.entidade_id
                             and e.data          < trunc(sysdate+1))
          group by v.tipo_entidade, v.entidade_id;
                             
                            
   -- Atualiza valor das colunas CPI e SPI nos projetos 
   pck_versao.p_log_versao('I', '     Atualiza valores em projetos', 
                           pck_versao.CN_STD_EVA); 
   update projeto
      set cpi_monetario = (select cpi_calculado from eva_ipg 
                            where tipo_entidade = 'P' and entidade_id = id and tipo = 'I'),
          spi_monetario = (select spi_calculado from eva_ipg 
                            where tipo_entidade = 'P' and entidade_id = id and tipo = 'I');
   -- Atualiza valor das colunas CPI e SPI nas atividades
   pck_versao.p_log_versao('I', '     Atualiza valores em atividades', 
                           pck_versao.CN_STD_EVA); 
   update atividade 
      set cpi_monetario = (select cpi_calculado from eva_ipg 
                            where tipo_entidade = 'A' and entidade_id = id and tipo = 'I'),
          spi_monetario = (select spi_calculado from eva_ipg 
                            where tipo_entidade = 'A' and entidade_id = id and tipo = 'I');
   -- Atualiza valor das colunas CPI e SPI nos tarefas 
   pck_versao.p_log_versao('I', '     Atualiza valores em tarefas', 
                           pck_versao.CN_STD_EVA); 
   update tarefa 
      set cpi_monetario = (select cpi_calculado from eva_ipg 
                            where tipo_entidade = 'T' and entidade_id = id and tipo = 'I'),
          spi_monetario = (select spi_calculado from eva_ipg 
                            where tipo_entidade = 'T' and entidade_id = id and tipo = 'I');
end p_atualiza_cpi_spi;


procedure p_inicializa_percentual(pd_data_processo date) is
  begin  
     insert into percentual_concluido (id, data, tipo_entidade, entidade_id, perc_concluido)
     select percentual_concluido_seq.nextval, data, tipo_entidade, entidade_id, 0
       from (  select p.datainicio data, 'P' tipo_entidade, p.id entidade_id
                 from projeto p
                where p.datainicio <= trunc(pd_data_processo)
                  and not exists (select 1
                                    from percentual_concluido pc
                                   where pc.entidade_id   = p.id
                                     and pc.tipo_entidade = 'P')
               union all
               select a.datainicio, 'A', a.id
                 from atividade a
                where a.datainicio <= trunc(pd_data_processo)
                  and not exists (select 1
                                    from percentual_concluido pc
                                   where pc.entidade_id   = a.id
                                     and pc.tipo_entidade = 'A') 
               union all
               select t.datainicio, 'T', t.id
                 from tarefa t
                where t.datainicio <= trunc(pd_data_processo)
                  and not exists (select 1
                                    from percentual_concluido pc
                                   where pc.entidade_id   = t.id
                                     and pc.tipo_entidade = 'T')  ); 
  end p_inicializa_percentual;

end pck_eva ;
/


create or replace package pck_indicador is

  -- Author  : MDIAS
  -- Created : 26/1/2010 16:14:39
  
  Freq_DIA               varchar2(1) := 'D';
  Freq_SEMANA            varchar2(1) := 'S';
  Freq_MES               varchar2(1) := 'M';
  Freq_ANO               varchar2(1) := 'A';
  Freq_ULT_MES           varchar2(1) := 'U';
  Freq_ULT_ANO           varchar2(1) := 'L';

  procedure pApuraIndicadores (pd_fim_proc date);
  procedure pPublicaIndicador ( pn_apuracao_id mapa_indicador_apuracao.id%type, pv_usuario varchar2 );
   procedure pPublicaObjetivo ( pn_apuracao_id mapa_objetivo_apuracao.id%type, pv_usuario varchar2 );
end pck_indicador;
/
create or replace package body pck_indicador is

   procedure pPublicaIndicador ( pn_apuracao_id mapa_indicador_apuracao.id%type, pv_usuario varchar2 ) is
   lv_formula         mapa_indicador.formula%type;
   lv_sql             mapa_indicador.consultasql%type;
   ln_rotina_id       mapa_indicador.rotina_id%type;
   lv_subtipo         mapa_indicador.subtipo%type;
   ln_indicador_id    mapa_indicador.id%type;
   ld_data_apuracao   mapa_indicador_apuracao.data_apuracao%type;
   ln_valor           mapa_indicador_apuracao.escore%type;
   ln_total           mapa_indicador_apuracao.escore%type;
   lv_select          mapa_indicador.formula%type;
   lv_situacao        mapa_indicador_apuracao.situacao%type;
   ln_objetivo_pai    mapa_indicador.objetivo_pai%type;
   lv_package         mapa_rotina.package%type;
   lv_nome            mapa_rotina.nome%type;
   ln_apuracao_objetivo_id mapa_objetivo_apuracao.id%type;
   lb_primeiro        boolean;
   type t_calculo is ref cursor;
   lc_calculo t_calculo;
   begin
      --Busca informacoes da apuracao
      select formula,
             consultasql, 
             i.rotina_id,
             i.id,
             i.subtipo,
             a.data_apuracao,
             a.situacao,
             i.objetivo_pai
      into lv_formula, 
           lv_sql,
           ln_rotina_id,
           ln_indicador_id,
           lv_subtipo,
           ld_data_apuracao,
           lv_situacao,
           ln_objetivo_pai
      from mapa_indicador i, mapa_indicador_apuracao a
      where i.id = a.indicador_id 
      and   a.id = pn_apuracao_id;
      
      if lv_subtipo = 'M' then
          lv_formula := replace(lv_formula, ',', '.');
          
          --Substitui mnemonicos de variaveis pelos respectivos valores
          for c in (select v.mnemonico, a.valor_variavel
                    from mapa_indicador_apuracao_var a, mapa_indicador_variavel v
                    where a.apuracao_id (+) = pn_apuracao_id
                    and   a.variavel_id (+) = v.id
                    and   v.indicador_id = ln_indicador_id) loop
             lv_formula := replace(lv_formula, '['||c.mnemonico||'_V]',nvl(replace(to_char(c.valor_variavel), ',','.'),'NULL'));
             
          end loop;

          --Substitui mnemonicos de indicadores pelos respectivos valores
          for c in (select *
                    from mapa_indicador i
                    where i.indicador_origem_id = ln_indicador_id) loop
             select max(escore), max(situacao)
             into ln_valor, lv_situacao
             from mapa_indicador_apuracao
             where indicador_id = c.id
             and   data_apuracao = (select max(data_apuracao)
                                    from mapa_indicador_apuracao
                                    where indicador_id = c.id
                                    and   data_apuracao <= ld_data_apuracao);
          
             if ln_valor is null or lv_situacao is null or lv_situacao = 'E' then
                ln_valor := null;
             end if;
             
             lv_formula := replace(lv_formula, '['||c.mnemonico||'_I]',nvl(replace(to_char(ln_valor), ',','.'),'NULL'));
          
          end loop;
          
          --evita erro de divisao por zero
          lv_formula := pck_geral.f_insere_zeroisnull(lv_formula);
      elsif lv_subtipo = 'C' then
         for a in (select p.nome, p.valor
                   from mapa_consulta_params p
                   where indicador_id = ln_indicador_id) loop
             lv_sql := replace(lv_sql, '['||a.nome||']', a.valor);
         end loop;
         lv_formula := '('||lv_sql||')';
      elsif lv_subtipo = 'R' then
         lb_primeiro := true;
         for a in (select r.package, r.nome, p.ordem, p.nome nome_param, p.tipo, v.valor_numerico, v.valor_texto
                   from mapa_rotina r, mapa_rotina_params p, mapa_rotina_params_valor v
                   where r.id = ln_rotina_id
                   and   r.id = p.rotina_id
                   and   p.id = v.parametro_id
                   order by p.ordem) loop
            if lb_primeiro then
               lv_formula := '(select '|| a.package || '.' ||a.nome || '(';
               lb_primeiro := false;
            else
               lv_formula := lv_formula || ',';
            end if;
            if a.tipo = 'N' then
               lv_formula := lv_formula || a.valor_numerico;
            else
               lv_formula := lv_formula || '''' || a.valor_texto || '''';
            end if;
         end loop;

         if lb_primeiro then
            select a.package, a.nome
            into lv_package, lv_nome
            from mapa_rotina a
            where a.id = ln_rotina_id;
            lv_formula := '(select '|| lv_package || '.' ||lv_nome ||' from dual)';
         else
            lv_formula := lv_formula || ') from dual)';
         end if;
      end if;
      
      lv_select := 'select trunc('||lv_formula||',2) from dual';

      begin
         open lc_calculo for lv_select;
         fetch lc_calculo into ln_total;
      exception when others then
          if sqlcode = -936 then
             ln_total := null;
          end if;
      end;
      update mapa_indicador_apuracao
      set situacao = 'P',
          escore = ln_total,
          usuario_atualizacao_id = pv_usuario,
          data_atualizacao = sysdate
      where id = pn_apuracao_id;
      
      if ln_objetivo_pai is not null then
         select max(id)
         into ln_apuracao_objetivo_id 
         from mapa_objetivo_apuracao a
         where objetivo_id = ln_objetivo_pai
         and   a.data_apuracao = (select max(data_apuracao)
                                  from mapa_objetivo_apuracao 
                                  where objetivo_id = ln_objetivo_pai);
         if ln_apuracao_objetivo_id is not null then
            pPublicaObjetivo(ln_apuracao_objetivo_id, pv_usuario);
         end if;
      end if;
   end;
     
   procedure pPublicaObjetivo ( pn_apuracao_id mapa_objetivo_apuracao.id%type, pv_usuario varchar2 ) is
   lv_formula         mapa_objetivo.formula%type;
   ln_objetivo_id     mapa_objetivo.id%type;
   ld_data_apuracao   mapa_objetivo_apuracao.data_apuracao%type;
   ln_valor           mapa_objetivo_apuracao.escore%type;
   ln_total           mapa_objetivo_apuracao.escore%type;
   lv_select          mapa_objetivo.formula%type;
   lv_situacao        mapa_objetivo_apuracao.situacao%type;
   lv_situacao_objetivo mapa_objetivo_apuracao.situacao%type;
   ln_objetivo_pai    mapa_objetivo.objetivo_pai%type;
   ln_apuracao_objetivo_id mapa_objetivo_apuracao.id%type;
   type t_calculo is ref cursor;
   lc_calculo t_calculo;
   begin
      --Busca informacoes da apuracao
      select formula, 
             i.id,
             a.data_apuracao,
             a.situacao
      into lv_formula, 
           ln_objetivo_id,
           ld_data_apuracao,
           lv_situacao
      from mapa_objetivo i, mapa_objetivo_apuracao a
      where i.id = a.objetivo_id 
      and   a.id = pn_apuracao_id;
      
      lv_formula := replace(lv_formula, ',', '.');
      
      lv_situacao_objetivo := 'P';
      --Substitui indicadores e objetivos filhos na formula
      for c in (select 'I' tipo, i.id, i.mnemonico
                from mapa_indicador i
                where i.objetivo_pai = ln_objetivo_id
                union all
                select 'O', o.id, o.mnemonico
                from mapa_objetivo o
                where o.objetivo_pai = ln_objetivo_id) loop

         if c.tipo = 'I' then
            select max(escore), max(situacao)
            into ln_valor, lv_situacao
            from mapa_indicador_apuracao
            where indicador_id = c.id
            and   data_apuracao = (select max(data_apuracao)
                                   from mapa_indicador_apuracao
                                   where indicador_id = c.id
                                   and   data_apuracao <= ld_data_apuracao);
         else
            select max(escore), max(situacao)
            into ln_valor, lv_situacao
            from mapa_objetivo_apuracao
            where objetivo_id = c.id
            and   data_apuracao = (select max(data_apuracao)
                                   from mapa_objetivo_apuracao
                                   where objetivo_id = c.id
                                   and   data_apuracao <= ld_data_apuracao);
         end if;
         
         if lv_situacao <> 'P' then
            lv_situacao_objetivo := 'E';
         end if;

         if ln_valor is null or lv_situacao is null or lv_situacao = 'E' then
            ln_valor := null;
         end if;
         
         if c.tipo = 'I' then
            lv_formula := replace(lv_formula, 'I_'||c.id,nvl(replace(to_char(ln_valor), ',','.'),'NULL'));
         else
            lv_formula := replace(lv_formula, 'O_'||c.id,nvl(replace(to_char(ln_valor), ',','.'),'NULL'));
         end if;
      
      end loop;
      
      --evita erro de divisao por zero
      lv_formula := pck_geral.f_insere_zeroisnull(lv_formula);
      
      lv_select := 'select trunc('||lv_formula||',2) from dual';

      begin
         open lc_calculo for lv_select;
         fetch lc_calculo into ln_total;
      exception when others then
          if sqlcode = -936 then
             ln_total := null;
          end if;
      end;
      
      update mapa_objetivo_apuracao
      set situacao = lv_situacao_objetivo,
          escore = ln_total,
          usuario_atualizacao_id = pv_usuario,
          data_atualizacao = sysdate
      where id = pn_apuracao_id;

      if ln_objetivo_pai is not null then
         select max(id)
         into ln_apuracao_objetivo_id 
         from mapa_objetivo_apuracao a
         where objetivo_id = ln_objetivo_pai
         and   a.data_apuracao = (select max(data_apuracao)
                                  from mapa_objetivo_apuracao 
                                  where objetivo_id = ln_objetivo_pai);
         if ln_apuracao_objetivo_id is not null then
            pPublicaObjetivo(ln_apuracao_objetivo_id, pv_usuario);
         end if;
      end if;

   end;

   procedure pApuraIndicadores (pd_fim_proc date) is
   ld_inicio date;
   ld_proc date;
   ld_aux  date;
   lv_usuario usuario.usuarioid%type;
   ln_apuracao_id mapa_indicador_apuracao.id%type;
   ld_proc_ind_filtro date;
   begin
     
      --Obtem usuario administrador
      select max(c.valor_varchar)
      into lv_usuario
      from tracegp_config c
      where c.variavel = 'GERAL: USR_ADM_TRACE';
      
      if lv_usuario is null then
         lv_usuario := 'auto';
      end if;
      
      --Inicio do periodo de apuracao
      select max(trunc(c.valor_data))
      into ld_inicio
      from tracegp_config c
      where c.variavel = 'PROC_NOTURNO: PROC_INDICADORES';
      
      --Inicio do periodo de apuracao
      select max(trunc(c.valor_data))
      into ld_proc_ind_filtro
      from tracegp_config c
      where c.variavel = 'APLICACAO: PROC_IND_FILTRO';
      
      --Data de inicio do processamento
      if ld_inicio is null then
         ld_inicio := to_date('20040101', 'yyyymmdd');
         insert into tracegp_config ( variavel, valor_data ) 
         values ( 'PROC_NOTURNO: PROC_INDICADORES', ld_inicio );
      else
         ld_inicio := ld_inicio + 1;
      end if;
      
      if ld_inicio > pd_fim_proc then
         pck_versao.p_log_versao('E','Tentou processar Indicadores com data inválida. Última: '||(ld_inicio-1)||' Processamento: '||pd_fim_proc);
         commit;
         return;
      end if;
      
      --Nao processa indicadores enquanto nao rodar os indicadores calculados em java
      --que sao os indicadores baseados em filtros salvos
      if ld_inicio > ld_proc_ind_filtro then
         return;
      end if;
      
      ld_aux := ld_inicio;

      --Apuracao de indicador
      while ld_aux <= pd_fim_proc loop
        ld_proc := ld_aux;
        for c in (--Indicadores com data marcada para iniciar primeira apuracao
                  select * 
                  from mapa_indicador i
                  where i.indicador_apuracao = 'D'
                  and   i.previsao_apuracao = ld_proc
                  and   i.inicio_apuracao is null
                  union all
                  --Indicadores com inicio de primeira apuracao a partir de evento
                  select *
                  from mapa_indicador i
                  where i.indicador_apuracao <> 'D'
                  and   i.inicio_apuracao is null
                  and   ((i.tipo_entidade_apuracao = 'P' and
                          exists (select 1 
                                  from h_projeto p
                                  where p.projeto_id = i.entidade_apuracao_id
                                  and   p.h_situacao = 'Y'
                                  and   p.situacao = i.situacao_prj_apuracao_id)) or
                         (i.tipo_entidade_apuracao = 'A' and
                          exists (select 1 
                                  from h_atividade a
                                  where a.atividade_id = i.entidade_apuracao_id
                                  and   a.h_situacao = 'Y'
                                  and   a.situacao = i.situacao_prj_apuracao_id)) or
                         (i.tipo_entidade_apuracao = 'T' and
                          exists (select 1 
                                  from h_tarefa t
                                  where t.tarefa_id = i.entidade_apuracao_id
                                  and   t.h_situacao = 'Y'
                                  and   t.situacao = i.situacao_prj_apuracao_id)))
                  union all
                  select i.*
                  from mapa_indicador i
                  where not exists (select 1
                                    from mapa_indicador_apuracao ia
                                    where ia.indicador_id = i.id
                                    and   ia.data_apuracao = ld_proc)
                  and   i.inicio_apuracao is not null
                  and   nvl(i.validade,to_date('31122999', 'ddmmyyyy')) >= ld_proc
                  and   (--Todos os dias
                         (i.frequencia_apuracao = pck_indicador.Freq_DIA and
                          (i.periodo_apuracao * 1 + (select max(data_apuracao) from mapa_indicador_apuracao ia 
                                where ia.indicador_id = i.id)) = ld_proc) or 
                         --Semanalmente
                         (i.frequencia_apuracao = pck_indicador.Freq_SEMANA and 
                          (i.periodo_apuracao * 7 + (select max(data_apuracao) from mapa_indicador_apuracao ia 
                                where ia.indicador_id = i.id)) = ld_proc)  or
                         --Anualmente
                         (i.frequencia_apuracao = pck_indicador.Freq_ANO and 
                          add_months((select max(data_apuracao) from mapa_indicador_apuracao ia 
                                where ia.indicador_id = i.id),i.periodo_apuracao * 12) = ld_proc) or
                         --Mensalmente
                         (i.frequencia_apuracao = pck_indicador.Freq_MES and 
                          --Meses seguintes
                          ((pck_geral.f_meses_entre((select max(data_apuracao)
                                           from mapa_indicador_apuracao ia 
                                           where ia.indicador_id = i.id), ld_proc ) / i.periodo_apuracao) - 
                           abs((pck_geral.f_meses_entre((select max(data_apuracao)
                                               from mapa_indicador_apuracao ia 
                                               where ia.indicador_id = i.id), ld_proc ) / i.periodo_apuracao))) = 0 and
                          --Mesmo dia no mes seguinte
                          to_number(to_char(i.inicio_apuracao, 'DD')) = to_number(to_char(ld_proc,'DD'))) or
                         --Ultimo dia de cada mes
                         (i.frequencia_apuracao = pck_indicador.Freq_ULT_MES and 
                          ld_proc = last_day(ld_proc) and
                          (
                           --Meses seguintes
                          --Meses seguintes
                          ((pck_geral.f_meses_entre((select max(data_apuracao)
                                           from mapa_indicador_apuracao ia 
                                           where ia.indicador_id = i.id), ld_proc ) / i.periodo_apuracao) - 
                           abs((pck_geral.f_meses_entre((select max(data_apuracao)
                                               from mapa_indicador_apuracao ia 
                                               where ia.indicador_id = i.id), ld_proc ) / i.periodo_apuracao))) = 0 or
                           --Iniciou no meio do mes
                           (select max(data_apuracao) from mapa_indicador_apuracao ia 
                                               where ia.indicador_id = i.id) <> 
                           last_day((select max(data_apuracao) from mapa_indicador_apuracao ia 
                                               where ia.indicador_id = i.id))
                                               ) ) or
                         --Ultimo dia de cada ano
                         (i.frequencia_apuracao = pck_indicador.Freq_ULT_ANO and 
                          ld_proc = to_date(to_char(ld_proc,'yyyy')||'1231','yyyymmdd') and
                          (add_months((select max(data_apuracao) from mapa_indicador_apuracao ia 
                                       where ia.indicador_id = i.id),i.periodo_apuracao * 12) = ld_proc or
                           --Iniciou no meio do mes
                           (select max(data_apuracao) from mapa_indicador_apuracao ia 
                                               where ia.indicador_id = i.id) <> 
                           last_day((select max(data_apuracao) from mapa_indicador_apuracao ia 
                                               where ia.indicador_id = i.id))
                                               )) 
                      )
                  ) loop
              
           select mapa_indicador_apuracao_seq.nextval
           into ln_apuracao_id
           from dual;
              
           --Inicia apuracao
           insert into mapa_indicador_apuracao (id, indicador_id, data_apuracao, quebra_id, situacao, 
                                                escore, forma, data_criacao, data_atualizacao, usuario_criacao_id,
                                                usuario_atualizacao_id)
           values ( ln_apuracao_id, c.id, ld_proc, null, 'E',
                    null, 'M', sysdate, sysdate, lv_usuario,
                    lv_usuario );
              
           --Registra inicio da apuracao
           update mapa_indicador mi
           set inicio_apuracao = nvl(inicio_apuracao, ld_proc),
               usuario_atualizacao_id = lv_usuario,
               data_atualizacao = sysdate
           where id = c.id;
              
           /*--Insere registros para variaveis do indicador
           insert into mapa_indicador_apuracao_var ( id, apuracao_id, variavel_id, valor_variavel,
                                                     data_criacao, data_atualizacao, usuario_criacao_id, 
                                                     usuario_atualizacao_id )
           select mapa_ind_apuracao_var_seq.nextval, ln_apuracao_id, v.id, null,
                  sysdate, sysdate, lv_usuario, lv_usuario
           from mapa_indicador_variavel v
           where indicador_id = c.id;*/
              
        end loop;
        --Apuracao de objetivo
        for c in (select * 
                  from mapa_objetivo o
                  where o.previsao_apuracao = ld_proc
                  and   o.inicio_apuracao is null
                  union all
                  select i.*
                  from mapa_objetivo i
                  where not exists (select 1
                                    from mapa_objetivo_apuracao ia
                                    where ia.objetivo_id = i.id
                                    and   ia.data_apuracao = ld_proc)
                  and   i.inicio_apuracao is not null
                  and   nvl(i.validade,to_date('31122999', 'ddmmyyyy')) >= ld_proc
                  and   i.tipo = 'Q'
                  and   (--Todos os dias
                         (i.frequencia_apuracao = pck_indicador.Freq_DIA and
                          (i.periodo_apuracao * 1 + (select max(data_apuracao) from mapa_objetivo_apuracao ia 
                                where ia.objetivo_id = i.id)) = ld_proc) or 
                         --Semanalmente
                         (i.frequencia_apuracao = pck_indicador.Freq_SEMANA and 
                          (i.periodo_apuracao * 7 + (select max(data_apuracao) from mapa_objetivo_apuracao ia 
                                where ia.objetivo_id = i.id)) = ld_proc)  or
                         --Anualmente
                         (i.frequencia_apuracao = pck_indicador.Freq_ANO and 
                          add_months((select max(data_apuracao) from mapa_objetivo_apuracao ia 
                                where ia.objetivo_id = i.id),i.periodo_apuracao * 12) = ld_proc) or
                         --Mensalmente
                         (i.frequencia_apuracao = pck_indicador.Freq_MES and 
                          --Meses seguintes
                          ((pck_geral.f_meses_entre((select max(data_apuracao)
                                           from mapa_objetivo_apuracao ia 
                                           where ia.objetivo_id = i.id), ld_proc ) / i.periodo_apuracao) - 
                           abs((pck_geral.f_meses_entre((select max(data_apuracao)
                                               from mapa_objetivo_apuracao ia 
                                               where ia.objetivo_id = i.id), ld_proc ) / i.periodo_apuracao))) = 0 and
                          --Mesmo dia no mes seguinte
                          to_number(to_char(i.inicio_apuracao, 'DD')) = to_number(to_char(ld_proc,'DD'))) or
                         --Ultimo dia de cada mes
                         (i.frequencia_apuracao = pck_indicador.Freq_ULT_MES and 
                          ld_proc = last_day(ld_proc) and
                          (
                           --Meses seguintes
                          --Meses seguintes
                          ((pck_geral.f_meses_entre((select max(data_apuracao)
                                           from mapa_objetivo_apuracao ia 
                                           where ia.objetivo_id = i.id), ld_proc ) / i.periodo_apuracao) - 
                           abs((pck_geral.f_meses_entre((select max(data_apuracao)
                                               from mapa_objetivo_apuracao ia 
                                               where ia.objetivo_id = i.id), ld_proc ) / i.periodo_apuracao))) = 0 or
                           --Iniciou no meio do mes
                           (select max(data_apuracao) from mapa_objetivo_apuracao ia 
                                               where ia.objetivo_id = i.id) <> 
                           last_day((select max(data_apuracao) from mapa_objetivo_apuracao ia 
                                               where ia.objetivo_id = i.id))
                                               ) ) or
                         --Ultimo dia de cada ano
                         (i.frequencia_apuracao = pck_indicador.Freq_ULT_ANO and 
                          ld_proc = to_date(to_char(ld_proc,'yyyy')||'1231','yyyymmdd') and
                          (add_months((select max(data_apuracao) from mapa_objetivo_apuracao ia 
                                       where ia.objetivo_id = i.id),i.periodo_apuracao * 12) = ld_proc or
                           --Iniciou no meio do mes
                           (select max(data_apuracao) from mapa_objetivo_apuracao ia 
                                               where ia.objetivo_id = i.id) <> 
                           last_day((select max(data_apuracao) from mapa_objetivo_apuracao ia 
                                               where ia.objetivo_id = i.id))
                                               )) 
                      )
                  ) loop
              
           select mapa_objetivo_apuracao_seq.nextval
           into ln_apuracao_id
           from dual;
              
           --Inicia apuracao
           insert into mapa_objetivo_apuracao (id, objetivo_id, data_apuracao, situacao, 
                                                escore, data_criacao, data_atualizacao, usuario_criacao_id,
                                                usuario_atualizacao_id)
           values ( ln_apuracao_id, c.id, ld_proc, 'E',
                    null, sysdate, sysdate, lv_usuario,
                    lv_usuario );
              
           --Registra inicio da apuracao
           update mapa_objetivo mo
           set inicio_apuracao = nvl(inicio_apuracao, ld_proc),
               usuario_atualizacao_id = lv_usuario,
               data_atualizacao = sysdate
           where id = c.id;
              
        end loop;

        ld_aux := ld_aux + 1;
      end loop;
      
      --Apura indicadores e objetivos para os quais ja esta no prazo
      for c in (select *
                from (select level nivel, a.*
                      from (select 'I' tipoMapa, a.id, i.tipo, i.subtipo, a.situacao, 'I'||i.id mapaId, 
                                   case 
                                     when i.indicador_origem_id is not null then 'I'||i.indicador_origem_id
                                     when i.objetivo_pai is not null then 'O'||i.objetivo_pai
                                     else null end pai
                            from mapa_indicador i,
                                 mapa_indicador_apuracao a
                            where a.indicador_id = i.id
                            and   a.data_apuracao + i.prazo_apuracao <= pd_fim_proc
                            union all
                            select 'O' tipoMapa, a.id, 'M', 'M', a.situacao, 'O'||i.id mapaId, 
                                   case 
                                     when i.objetivo_pai is not null then 'O'||i.objetivo_pai
                                     else null end pai
                            from mapa_objetivo i,
                                 mapa_objetivo_apuracao a
                            where a.objetivo_id = i.id) a
                      connect by prior mapaId = pai
                      start with pai is null)
                order by nivel desc) loop
         if c.subtipo <> 'F' and --Matematico
            c.situacao = 'E' then
            if c.tipoMapa = 'I' then
               pPublicaIndicador (c.id, lv_usuario);
            else
               pPublicaObjetivo (c.id, lv_usuario);
            end if;
         end if;
      end loop;
      
      update tracegp_config
      set valor_data = pd_fim_proc - 1
      where variavel = 'PROC_NOTURNO: PROC_INDICADORES';
      
      commit;
      
   end;
   
end pck_indicador;
/


-------------------------------------------------------------------------------
-- Finalização
-------------------------------------------------------------------------------

insert into versao(id, titulo, patch, versao_tgp_id, comentario)
       values (versao_seq.nextval, '5.2.0', '24', 2, 'Aplicação de Patch');
commit;
/

begin
  pck_processo.precompila;
  commit;
end;
/
                      
select * from v_versao;
/
