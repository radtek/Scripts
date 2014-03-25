/*****************************************************************************\ 
 * TraceGP 6.0.1.0                                                            *
\*****************************************************************************/

define CS_TBL_DAT = &TABLESPACE_DADOS;
define CS_TBL_IND = &TABLESPACE_INDICES;

---------------------------------------------------------------
-- Integrações patches 5.2 -> 6.0
---------------------------------------------------------------
alter table PADRAOHORARIO add FECHAR_PONTO_FINAL_DIA VARCHAR2(1);

update PADRAOHORARIO 
   set FECHAR_PONTO_FINAL_DIA = 'S';
commit;
/

alter table CONFIGURACOES add PERMITSOLICAJUSTEPONTO VARCHAR2(1) DEFAULT 'H';

declare
  ln_conta number;
begin
  select count(1)
    into ln_conta
    from permissao_item
   where codigo = 'R_DEM_INTERESSADOS';
   
  if ln_conta = 0 then
    insert into permissao_item (permissao_item_id, titulo, codigo, permissao_categoria_id, 
                                tipo_permissao, mostrar_acesso_total, mostrar_somente_leitura)
         values ( (select max(permissao_item_id)+1 from permissao_item), 
                'permissao.relacionamento.solicitacao.interessados', 'R_DEM_INTERESSADOS', 3, 'R', 'S', 'N');
  end if;
  commit;
end;
/

---------------------------------------------------------------
-- Alterações em Tabelas
---------------------------------------------------------------
alter table ACAO_CONDICIONAL modify VALOR_TROCA VARCHAR2(4000);

ALTER TABLE ATRIBUTO ADD COR_FUNDO       VARCHAR2(7);
ALTER TABLE ATRIBUTO ADD COR_SELECIONADO VARCHAR2(7);
ALTER TABLE ATRIBUTO ADD LARGURA         NUMBER(4);
ALTER TABLE ATRIBUTO ADD ALTURA          NUMBER(4);

alter table atributo_coluna add tamanho number(10);

alter table log_hist_transicao add demanda_filha_id number(10);
alter table LOG_HIST_TRANSICAO drop constraint CHK_LOG_HIST_TRANSICAO_01;
alter table LOG_HIST_TRANSICAO add constraint CHK_LOG_HIST_TRANSICAO_01
  check (TIPO in ('OB', 'IN', 'AC', 'OP', 'CO', 'VA','FU', 'DF'));

alter table RELAT_RELATORIO_PARAMETRO  add atributo_id number(10);
alter table RELAT_RELATORIO_COMPONENTE add area_fixa_olap number(2); 

alter table regras_propriedade add sql varchar2(4000);

---------------------------------------------------------------
-- Criações de Tabelas e Objetos
---------------------------------------------------------------

-- TRANSICAO_ESTADO_FILHAS [INI]
create table transicao_estado_filhas(
  id                  number(10) not null,
  transicao_estado_id number(10) not null,
  formulario_id       number(10) not null,
  estado_origem_id    number(10) not null,
  estado_destino_id   number(10) not null,
constraint PK_TRANSICAO_ESTADO_FILHAS primary key (id) using index tablespace &CS_TBL_IND
) tablespace &CS_TBL_DAT;

comment on column transicao_estado_filhas.transicao_estado_id is 'Transicao na qual está inserida a transição das demandas filhas';
comment on column transicao_estado_filhas.formulario_id is 'Formulário da demanda filha';
comment on column transicao_estado_filhas.estado_origem_id is 'Estado origem na qual a demanda filha se encontra';
comment on column transicao_estado_filhas.estado_destino_id is 'Estado para qual a demanda filha será transacionada';

create sequence TRANSICAO_ESTADO_FILHAS_SEQ 
  start with 1 increment by 1 nocache;
-- TRANSICAO_ESTADO_FILHAS [FIM]

-- UNIDADE_FEDERATIVA [INI]
CREATE TABLE UNIDADE_FEDERATIVA (
  SIGLA  VARCHAR2(2)   NOT NULL ENABLE,
  NOME   VARCHAR2(200) NOT NULL,
constraint PK_UNIDADE_FEDERATIVA primary key (sigla) using index tablespace &CS_TBL_IND
) tablespace &CS_TBL_DAT;
-- UNIDADE_FEDERATIVA [FIM]

---------------------------------------------------------------
-- Criações de FKs
---------------------------------------------------------------
ALTER TABLE transicao_estado_filhas ADD CONSTRAINT FK_TRANSICAO_ESTADO_FILHAS_01 
  FOREIGN KEY (FORMULARIO_ID) REFERENCES FORMULARIO(FORMULARIO_ID) ON DELETE CASCADE;
ALTER TABLE transicao_estado_filhas ADD CONSTRAINT FK_TRANSICAO_ESTADO_FILHAS_02 
  FOREIGN KEY (TRANSICAO_ESTADO_ID) REFERENCES TRANSICAO_ESTADO(TRANSICAO_ESTADO_ID) ON DELETE CASCADE;
ALTER TABLE transicao_estado_filhas ADD CONSTRAINT FK_TRANSICAO_ESTADO_FILHAS_03 
  FOREIGN KEY (FORMULARIO_ID, ESTADO_ORIGEM_ID) REFERENCES ESTADO_FORMULARIO(FORMULARIO_ID, ESTADO_ID) ON DELETE CASCADE;
ALTER TABLE transicao_estado_filhas ADD CONSTRAINT FK_TRANSICAO_ESTADO_FILHAS_04 
  FOREIGN KEY (FORMULARIO_ID, ESTADO_DESTINO_ID) REFERENCES ESTADO_FORMULARIO(FORMULARIO_ID, ESTADO_ID) ON DELETE CASCADE;
ALTER TABLE transicao_estado_filhas ADD CONSTRAINT FK_TRANSICAO_ESTADO_FILHAS_05 
  FOREIGN KEY (ESTADO_ORIGEM_ID) REFERENCES ESTADO(ESTADO_ID) ON DELETE CASCADE;
ALTER TABLE transicao_estado_filhas ADD CONSTRAINT FK_TRANSICAO_ESTADO_FILHAS_06 
  FOREIGN KEY (ESTADO_DESTINO_ID) REFERENCES ESTADO(ESTADO_ID) ON DELETE CASCADE;


---------------------------------------------------------------
-- Criações e alterações em Views
---------------------------------------------------------------
create or replace view v_sla_atual as
select f.demanda_id, f.tipo_sla, f.estado_sla_id, f.tempo_total
from demanda_sla_final f
where 'P' = f.tipo_sla
and   f.demanda_id = f.demanda_id
union all
select f2.demanda_id, f2.tipo_sla, f2.estado_sla_id, 
       decode(f2.tipo_sla, 'P', pck_geral.f_minutos_entre(d.data_inicio_sla,sysdate,f2.padrao_horario_id),
                                pck_geral.f_minutos_entre(d.date_update_situacao,sysdate,f2.padrao_horario_id))
from demanda_faixas_sla f2, demanda d, sla
where   sysdate >= inicio
and   sysdate < fim
and   f2.demanda_id = d.demanda_id;

create or replace view v_horas as
select tarefa_id, usuario_id, data,
       max(nvl(ind_planejamento, 'N'))   IND_PLANEJAMENTO,
       max(nvl(situacao_planejada, ' ')) SITUACAO_PLANEJADA,
       max(nvl(situacao_valor, 0))       SITUACAO_VALOR,
       max(nvl(hora_planejada_id, 0))    HORA_PLANEJADA_ID,
       sum(hora_planejada)               HORA_PLANEJADA,
       sum(hora_trabalhada)              HORA_TRABALHADA,
       sum(hora_alocada)                 HORA_ALOCADA
  from (select tarefa_id, usuario_id, data,
               decode (tipo, 'HP', minutos, 0) HORA_PLANEJADA,
               decode (tipo, 'HT', minutos, 0) HORA_TRABALHADA,
               decode (tipo, 'HA', minutos, 0) HORA_ALOCADA,
               decode (tipo, 'HP', hora_id, null) HORA_PLANEJADA_ID,
               decode (tipo, 'HP', situacao, null) SITUACAO_PLANEJADA,
               decode (tipo, 'HP',
                       decode (situacao,
                               'A', 1,
                               'R', 2,
                               'E', 3,
                               'P', 4, 0)
                       , 0) SITUACAO_VALOR,
               decode (tipo, 'HP', 'Y', 'N') IND_PLANEJAMENTO
          from (select id tarefa_id, r.responsavel USUARIO_ID, dia data,
                       0 MINUTOS, NULL HORA_ID,
                       NULL SITUACAO, 'HPREV' TIPO
                from tarefa t,
                     responsavelentidade r, 
                     v_dias_futuro f
                where least(t.datainicio, nvl(t.iniciorealizado, t.datainicio)) <= f.Dia
                and   greatest(t.prazoprevisto, nvl(t.prazorealizado, t.prazoprevisto)) >= f.Dia
                and   t.id = r.identidade(+)
                and   'T' = r.tipoentidade (+)
                union all
                select hp.tarefa_id TAREFA_ID, hp.usuario_id USUARIO_ID, hp.data DATA,
                       hp.horas_planejadas MINUTOS, hp.id HORA_ID,
                       hp.situacao SITUACAO, 'HP' TIPO
                  from hora_planejada hp
                union all
                select ht.tarefa TAREFA_ID, ht.responsavel, ht.datatrabalho,
                       ht.minutos, ht.id, null, 'HT'
                  from horatrabalhada ht
                union all
                select ha.tarefa_id, re.responsavel, ha.data,
                       ha.minutos, ha.id, null, 'HA'
                  from hora_alocada ha,
                       responsavelentidade re
                 where re.identidade   = ha.tarefa_id
                   and re.tipoentidade = 'T'))
group by tarefa_id, usuario_id, data;

---------------------------------------------------------------
-- Dados básicos TraceGP
---------------------------------------------------------------
insert into UNIDADE_FEDERATIVA (NOME, SIGLA) values ('Acre','AC');
insert into UNIDADE_FEDERATIVA (NOME, SIGLA) values ('Alagoas','AL');
insert into UNIDADE_FEDERATIVA (NOME, SIGLA) values ('Amapá','AP');
insert into UNIDADE_FEDERATIVA (NOME, SIGLA) values ('Amazonas','AM');
insert into UNIDADE_FEDERATIVA (NOME, SIGLA) values ('Bahia','BA');
insert into UNIDADE_FEDERATIVA (NOME, SIGLA) values ('Ceará','CE');
insert into UNIDADE_FEDERATIVA (NOME, SIGLA) values ('Distrito Federal','DF');
insert into UNIDADE_FEDERATIVA (NOME, SIGLA) values ('Goiás','GO');
insert into UNIDADE_FEDERATIVA (NOME, SIGLA) values ('Espírito Santo','ES');
insert into UNIDADE_FEDERATIVA (NOME, SIGLA) values ('Maranhão','MA');
insert into UNIDADE_FEDERATIVA (NOME, SIGLA) values ('Mato Grosso','MT');
insert into UNIDADE_FEDERATIVA (NOME, SIGLA) values ('Mato Grosso do Sul','MS');
insert into UNIDADE_FEDERATIVA (NOME, SIGLA) values ('Minas Gerais','MG');
insert into UNIDADE_FEDERATIVA (NOME, SIGLA) values ('Pará','PA');
insert into UNIDADE_FEDERATIVA (NOME, SIGLA) values ('Paraiba','PB');
insert into UNIDADE_FEDERATIVA (NOME, SIGLA) values ('Paraná','PR');
insert into UNIDADE_FEDERATIVA (NOME, SIGLA) values ('Pernambuco','PE');
insert into UNIDADE_FEDERATIVA (NOME, SIGLA) values ('Piauí','PI');
insert into UNIDADE_FEDERATIVA (NOME, SIGLA) values ('Rio de Janeiro','RJ');
insert into UNIDADE_FEDERATIVA (NOME, SIGLA) values ('Rio Grande do Norte','RN');
insert into UNIDADE_FEDERATIVA (NOME, SIGLA) values ('Rio Grande do Sul','RS');
insert into UNIDADE_FEDERATIVA (NOME, SIGLA) values ('Rondônia','RO');
insert into UNIDADE_FEDERATIVA (NOME, SIGLA) values ('Rorâima','RR');
insert into UNIDADE_FEDERATIVA (NOME, SIGLA) values ('São Paulo','SP');
insert into UNIDADE_FEDERATIVA (NOME, SIGLA) values ('Santa Catarina','SC');
insert into UNIDADE_FEDERATIVA (NOME, SIGLA) values ('Sergipe','SE');
insert into UNIDADE_FEDERATIVA (NOME, SIGLA) values ('Tocantins','TO');
commit;
/

insert into regras_tipo_escopo (ID, CODIGO, TITULO, TIPO_ENTIDADE_ID)
  values (24, 'sql', 'SQL', 33);
insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
  values ('SQL', 'SQL', 'ID', 33, '', '');
commit;
/

insert into tela (telaid, nome, visivel, grupoid, ordem, codigo, atalho)
        select max(telaid)+1, 'bd.prompt.permitePlanTrabDiasNaoUteis', 
               'S', 26, 8, 'PERM_PLAN_TRAB_DIAS_N_UTEIS', 'N'
          from tela;       
commit;
/

update aba 
   set src = 'CalendarioProjeto.do?command=abaCalendarioProjetoAction'|| chr(38) ||
             'projeto_quadro_avisos=<form.DadosProjetoForm.idProjeto/>' 
 where src like 'Calendario.do?command=abaCalendarioProjetoAction%';
commit;
/

-- Cria permissão SLA onde não existir
declare
  ln_conta number;
begin
  select count(1)
    into ln_conta
    from permissao_item pi
   where pi.codigo = 'R_DEM_SLA';
   
  if ln_conta = 0 then  
    insert into permissao_item(permissao_item_id, titulo, codigo, permissao_categoria_id, 
                               tipo_permissao, mostrar_acesso_total, mostrar_somente_leitura)
           select max(permissao_item_id)+1, 'permissao.relacionamento.solicitacao.visualizarSla',
                  'R_DEM_SLA', 3, 'R', 'S', 'N'
             from permissao_item;
  end if;
end;
/
commit;
/

declare
  ln_conta number;
begin
  select count(1)
    into ln_conta
    from tela t
   where t.codigo = 'PERM_PLAN_TRAB_DIAS_N_UTEIS';
   
  if ln_conta = 0 then
    insert into tela (telaid, nome, visivel, grupoid, ordem, codigo, atalho)
           select max(telaid)+1, 'bd.prompt.permitePlanTrabDiasNaoUteis', 
                  'S', 26, 8, 'PERM_PLAN_TRAB_DIAS_N_UTEIS', 'N'
             from tela;
  end if;
end;
/
commit;
/

delete from USUARIODIVISAO where divisaoid not in (select id from uo);
commit;
/

insert into regras_tipo_escopo (ID, CODIGO, TITULO, TIPO_ENTIDADE_ID)
  values (25, 'descententesDemandasAssociadasProjetoDemandaPai', 'Demandas Descendentes do Projeto Associado a Demanda Pai da Demanda Corrente', 1);
insert into regras_tipo_escopo (ID, CODIGO, TITULO, TIPO_ENTIDADE_ID)
  values (26, 'descententesDemandasAssociadasProjetoDemanda', 'Demandas Descendentes do Projeto Associado a Demanda Corrente', 1);
insert into regras_tipo_escopo (ID, CODIGO, TITULO, TIPO_ENTIDADE_ID)
  values (27, 'demandaPai', 'Demanda Pai', 1);
commit;
/

-- Acerta escopo
begin
  for proj in (select * from projeto where projeto.id not in (select projeto from escopo)) loop
    insert into escopo(projeto) values (proj.id);
  end loop;
end;
/
commit;
/

---------------------------------------------------------------
-- Alterações em Views
---------------------------------------------------------------
create or replace view v_versao as
select * from (select titulo || '.' || patch versao
  from versao
order by id desc) where rownum = 1;
/
---------------------------------------------------------------
-- Alterações em Rotinas
---------------------------------------------------------------
CREATE OR REPLACE PACKAGE PCK_VALIDA_DEMANDA AS
       procedure executa(p_usuario varchar2, p_demanda_id varchar2, p_proximo_estado varchar2, ret in out varchar2);
       function F_VERIFICA_PERM_EDICAO_DEMANDA(pusuario_id varchar2, pdemanda_id varchar2, vpossuiPermissao in out varchar2, pregra_id number) return varchar2;
       function F_VERIFICA_ITENS_TRANSICAO_DEM (pdemanda_id varchar2, pestado_destino varchar2) return varchar2;
       function F_VERIFICA_PERM_CAMPOS_DEMANDA(pusuario_id varchar2, pdemanda_id varchar2) return varchar2;
       function F_VERIFICA_PERM_ATR_DEMANDA(pusuario_id varchar2, pdemanda_id varchar2) return varchar2;
       procedure p_verifica_campos_e_atributos(pusuario_id varchar2, pdemanda_id varchar2, pagendamento_id varchar2, ret in out varchar2);

end PCK_VALIDA_DEMANDA;
/

CREATE OR REPLACE PACKAGE BODY PCK_VALIDA_DEMANDA as

procedure executa(p_usuario varchar2, p_demanda_id varchar2, p_proximo_estado varchar2, ret in out varchar2) is
 v_permissao_estado varchar2(2) := 'N';
 v_retorno_edicao varchar2(4000);
 v_retorno_campos varchar2(4000);
 v_retorno_atr varchar2(4000);
 v_retorno_transicao varchar2(4000);
 v_retorno_regras varchar2(4000);

 vn_ret number;
 vn_estado_id number;
 vn_estado_mensagem_id number;
 vn_enviar_email number;
 vn_gerar_baseline number;

 ln_count1 binary_integer;
 ln_count2 binary_integer;
 lt_regras pck_geral.t_varchar_array;
 lt_regra_interna pck_geral.t_varchar_array;
 lt_campos pck_geral.t_varchar_array;
 lt_campo_interno pck_geral.t_varchar_array;
 lt_atr pck_geral.t_varchar_array;
 lt_atr_interno pck_geral.t_varchar_array;
 lt_outros_obrigatorios pck_geral.t_varchar_array;
 t_demanda_id pck_geral.t_varchar_array;

 vn_id_indicador number;
 contador number;
 existe varchar2(2) := 'N';
 ln_contador binary_integer := 0;


begin
   -- executa verificação de permissão no estado
   v_retorno_edicao := f_verifica_perm_edicao_demanda(p_usuario, p_demanda_id, v_permissao_estado, null);

   if v_permissao_estado = 'N' then
     dbms_output.put_line('##### NAO TEM PERMISSAO EDICAO NO ESTADO: '|| v_retorno_edicao);
     ret := v_retorno_edicao; --retorna a violação de permissão de edição no estado
   else
     v_retorno_transicao := f_verifica_itens_transicao_dem(p_demanda_id, p_proximo_estado);

     if v_retorno_transicao is not null then
        dbms_output.put_line('NAO TEM PERMISSAO TRANSICAO: '|| v_retorno_transicao);
        ret := v_retorno_transicao; --retorna a violação de permissão de transição
     else
        v_retorno_campos := f_verifica_perm_campos_demanda(p_usuario, p_demanda_id);
        v_retorno_atr := f_verifica_perm_atr_demanda(p_usuario, p_demanda_id);

        t_demanda_id := pck_geral.f_split(p_demanda_id, ',');

        for contador in 1..t_demanda_id.count loop
            pck_condicional.p_executarregrascondicionaisp(pn_demanda_id => t_demanda_id(contador),
                                                pn_prox_estado => '',
                                                pv_usuario => p_usuario,
                                                pn_ret => vn_ret,
                                                pn_estado_id => vn_estado_id,
                                                pn_estado_mensagem_id => vn_estado_mensagem_id,
                                                pn_enviar_email => vn_enviar_email,
                                                pn_gerar_baseline => vn_gerar_baseline,
                                                pv_retorno_campos => v_retorno_regras);
         end loop;

        dbms_output.put_line('v_retorno_campos: '|| v_retorno_campos);
        dbms_output.put_line('v_retorno_atr: '|| v_retorno_atr);
        dbms_output.put_line('v_retorno_regras: '|| v_retorno_regras);


        lt_campos := pck_geral.f_split(v_retorno_campos, '/');
        lt_atr := pck_geral.f_split(v_retorno_atr, '/');
        lt_regras := pck_geral.f_split(v_retorno_regras, '/');


        dbms_output.put_line('lt_campos: '|| lt_campos.count);
        dbms_output.put_line('lt_atr: '|| lt_atr.count);
        dbms_output.put_line('lt_regras: '|| lt_regras.count);


         for ln_count1 in 1..lt_regras.count loop

           lt_regra_interna := pck_geral.f_split(lt_regras(ln_count1), ',');

           dbms_output.put_line('OPCIONAL OU OBRIGATORIO: '|| lt_regra_interna(2));

           if lt_regra_interna(2) = 'OP' then

              dbms_output.put_line('ATR? : '|| substr(lt_regra_interna(1), 1, 3));

              if substr(lt_regra_interna(1), 1, 3) = 'ATR' then
                for ln_count2 in 1..lt_atr.count loop
                  lt_atr_interno := pck_geral.f_split(lt_atr(ln_count2), ',');

                  dbms_output.put_line('lt_atr_interno(2): '|| lt_atr_interno(2));
                  dbms_output.put_line('lt_campo_interno(1): '|| lt_regra_interna(1));

                  if lt_atr_interno(2) = lt_regra_interna(1) then
                    lt_atr(ln_count2) := ''; --retira o atributo das pendencias
                  end if;
                end loop;
              else
                for ln_count2 in 1..lt_campos.count loop
                  lt_campo_interno := pck_geral.f_split(lt_campos(ln_count2), ',');

                  dbms_output.put_line('lt_campo_interno(1): '|| lt_campo_interno(1));
                  dbms_output.put_line('lt_campo_interno(1): '|| lt_regra_interna(1));

                  if lt_campo_interno(2) = lt_regra_interna(1) then
                    lt_campos(ln_count2) := ''; --retira o campo das pendencias
                  end if;
                end loop;
              end if;

           elsif lt_regra_interna(2) = 'OB' then
                  -- adiciona aqui outros campos obrigatorios

                  if substr(lt_regra_interna(1), 1, 3) = 'ATR' then -- é um atributo
                    dbms_output.put_line('lt_regra_interna(1): '|| lt_regra_interna(1));
                    vn_id_indicador := substr(lt_regra_interna(1), 5, length(lt_regra_interna(1)));

                    dbms_output.put_line('vn_id_indicador: '|| vn_id_indicador);
                    dbms_output.put_line('id_demanda: '|| lt_regra_interna(3));

                     select count(*) into contador
                     from atributo_valor av
                     where av.atributo_id = vn_id_indicador
                     and demanda_id = lt_regra_interna(3);

                     if contador <= 0 then --não existe valor para o atributo OBRIGATORIO
                        existe := 'N';
                        for ln_count2 in 1..lt_atr.count loop --verifica se já foi adicionado na lista de ATRIBUTOS
                            lt_atr_interno := pck_geral.f_split(lt_atr(ln_count2), ',');
                            if lt_atr_interno(2) = vn_id_indicador then
                              existe := 'S';
                            end if;
                        end loop;

                        if existe <> 'S' then
                          ln_contador := ln_contador + 1;
                          dbms_output.put_line('>>>>>>>> '|| lt_regra_interna(1) || ' -- '|| lt_regra_interna(2) || ' -- '|| lt_regra_interna(3));
                          lt_outros_obrigatorios(ln_contador) := lt_regra_interna(1) || ',' || lt_regra_interna(2) || ',' || lt_regra_interna(3) || '/';
                        end if;
                     end if;
                  else  --  é um campo do formulário

                    dbms_output.put_line('é um campo do formulário');

                    existe := 'N';
                    for ln_count2 in 1..lt_campos.count loop --verifica se já foi adicionado na lista de CAMPOS
                        lt_campo_interno := pck_geral.f_split(lt_campos(ln_count2), ',');
                        if lt_campo_interno(2) = lt_regra_interna(1) then
                          existe := 'S';
                        end if;
                    end loop;

                    if existe <> 'S' then
                      ln_contador := ln_contador + 1;
                      lt_outros_obrigatorios(ln_contador) := lt_regra_interna(1) || ',' || lt_regra_interna(2) || ',' || lt_regra_interna(3) || '/';
                    end if;

                  end if;
           end if;
         end loop;

         for ln_count2 in 1..lt_campos.count loop
           ret := ret || lt_campos(ln_count2) || '/';
         end loop;

         for ln_count2 in 1..lt_atr.count loop
           ret := ret || lt_atr(ln_count2) || '/';
         end loop;

         for ln_count2 in 1..lt_outros_obrigatorios.count loop
           ret := ret || lt_outros_obrigatorios(ln_count2) || '/';
         end loop;
         -- LOGAR Zarpelon INICIO


         -- LOGAR Zarpelon FIM

      end if;
   end if;
  --commit;
end;


function F_VERIFICA_PERM_EDICAO_DEMANDA(pusuario_id varchar2, pdemanda_id varchar2, vpossuiPermissao in out varchar2, pregra_id number) return varchar2 is
 Result varchar(4000);

 contador binary_integer := 0;
 contador2 binary_integer := 0;
 contador3 binary_integer := 0;
 lv_sql varchar2(32000);
 type t_sql is ref cursor;
 lc_sql t_sql;
 cursor c_dom is select rft.tipo, de.demanda_id from regra_formulario_tipo rft, estado_formulario ef, demanda de;
 dom c_dom%rowtype;

begin

  if pregra_id is null then
     lv_sql := 'select rft.tipo, de.demanda_id '||
              ' from regra_formulario_tipo rft, estado_formulario ef, demanda de '||
              ' where de.demanda_id in ('||pdemanda_id||') '||
              ' and de.formulario_id = ef.formulario_id '||
              ' and de.situacao = ef.estado_id '||
              ' and rft.regra_id = ef.regra_id '||
              ' and rft.formulario_id = ef.formulario_id ';
   else
     lv_sql := 'select rft.tipo, de.demanda_id '||
              ' from regra_formulario_tipo rft, estado_formulario ef, demanda de '||
              ' where de.demanda_id in ('||pdemanda_id||') '||
              ' and de.formulario_id = ef.formulario_id '||
              ' and de.situacao = ef.estado_id '||
              ' and rft.regra_id = '|| pregra_id || ' ' ||
              ' and rft.formulario_id = ef.formulario_id ';
   end if;

    open lc_sql for lv_sql;
    while true loop
      fetch lc_sql into dom;
      exit when lc_sql%notfound;
     if dom.tipo = 'C' then -- CRIADOR
            select count(*) into contador
            from demanda where demanda_id = dom.demanda_id
            and criador = pusuario_id;
            if contador > 0 then
              vpossuiPermissao := 'S';
            else
              Result := Result ||'EDICAO,' || dom.tipo || ',' || dom.demanda_id || '/';
            end if;
     elsif dom.tipo = 'CE' then -- SOMENTE CONTADOS DA EMPRESA DO SOLICITANTE
            select count(*) into contador from usuario u, demanda de, usuario c
            where de.demanda_id = dom.demanda_id
            and de.solicitante = u.usuarioid
            and c.empresaid = u.empresaid
            and c.tipo_usuario = 'C'
            and c.usuarioid in (pusuario_id);

           if contador > 0 then
             Result := Result || dom.tipo || ',S,' || dom.demanda_id || '/';
             vpossuiPermissao := 'S';
            else
              Result := Result ||'EDICAO,' || dom.tipo || ',' || dom.demanda_id || '/';
            end if;

     elsif dom.tipo = 'E' then -- EQUIPE
           select count(*) into contador from regra_formulario_equipe rfe, usuario_equipe ue, demanda de
           where rfe.formulario_id = de.formulario_id
           and de.demanda_id = dom.demanda_id
           and rfe.equipe_id = ue.equipe_id
           and ue.usuarioid = pusuario_id;

           if contador > 0 then
             vpossuiPermissao := 'S';
            else
              Result := Result ||'EDICAO,' || dom.tipo || ',' || dom.demanda_id || '/';
            end if;

     elsif dom.tipo = 'P' then -- PERFIL

           select count(*) into contador from
           estado_formulario ef,  regra_formulario_perfil rfp, usuario_perfil up, demanda de
           where de.demanda_id = dom.demanda_id
           and ef.estado_id = de.situacao
           and ef.formulario_id = de.formulario_id
           and nvl(pregra_id, rfp.regra_id) = ef.regra_id
           and rfp.formulario_id = ef.formulario_id
           and up.perfilid = rfp.perfil_id
           and up.usuarioid = pusuario_id;

           if contador > 0 then
             vpossuiPermissao := 'S';
            else
              Result := Result ||'EDICAO,' || dom.tipo || ',' || dom.demanda_id || '/';
            end if;

     elsif dom.tipo = 'R' then -- RESPONSAVEL PELO DESTINO

           if pregra_id is not null then
             select count(*) into contador from regra_destino rd, demanda de, estado_formulario ef
             where rd.formulario_id = de.formulario_id
             and de.demanda_id = dom.demanda_id
             and rd.destino_id = de.destino_id
             and ef.formulario_id = de.formulario_id
             and ef.estado_id = de.situacao
             and nvl(pregra_id, rd.regra_id) = ef.regra_id;
           else

             select count(*) into contador3
             from demanda de
             where de.demanda_id = dom.demanda_id
             and de.destino_id is not null;

             if contador3 > 0 then --caso a demanda possua destino
               select count(*) into contador2
               from demanda de, destino_usuario du
               where demanda_id = dom.demanda_id
               and de.destino_id = du.destino
               and du.usuario = pusuario_id;
             else
               contador2 := 1; --caso a demanda nao possua destino, deve ignorar a validacao
             end if;
           end if;

           if contador+contador2 > 0 then
             vpossuiPermissao := 'S';
             dbms_output.put_line('pregra_id: '|| pregra_id);
            else
              Result := Result ||'EDICAO,' || dom.tipo || ',' || dom.demanda_id || '/';
            end if;

     elsif dom.tipo = 'RA' then -- RESPONSAVEL DE ATENDIMENTO
           select count(*) into contador
           from demanda de
           where de.responsavel = pusuario_id
           and de.demanda_id = dom.demanda_id;

           if contador > 0 then
             vpossuiPermissao := 'S';
            else
              Result := Result ||'EDICAO,' || dom.tipo || ',' || dom.demanda_id || '/';
            end if;

     elsif dom.tipo = 'RC' then -- RESPONSAVEL DO CRIADOR
           select count(*) into contador
           from demanda de, usuario u
           where de.criador = u.usuarioid
           and de.demanda_id = dom.demanda_id
           and u.responsavel_id = pusuario_id;

           if contador > 0 then
             vpossuiPermissao := 'S';
            else
              Result := Result ||'EDICAO,' || dom.tipo || ',' || dom.demanda_id || '/';
            end if;

     elsif dom.tipo = 'RS' then -- RESPONSAVEL DO SOLICITANTE
           select count(*) into contador
           from demanda de, usuario u
           where de.solicitante = u.usuarioid
           and de.demanda_id = dom.demanda_id
           and u.responsavel_id = pusuario_id;

           if contador > 0 then
             vpossuiPermissao := 'S';
            else
              Result := Result ||'EDICAO,' || dom.tipo || ',' || dom.demanda_id || '/';
            end if;

     elsif dom.tipo = 'S' then -- SOLICITANTE
           select count(*) into contador
           from demanda de
           where de.solicitante = pusuario_id
           and de.demanda_id = dom.demanda_id;

           if contador > 0 then
             vpossuiPermissao := 'S';
            else
             Result := Result ||'EDICAO,' || dom.tipo || ',' || dom.demanda_id || '/';
            end if;

     elsif dom.tipo = 'UC' then -- 1º RESPONSAVEL DA UNIDADE ORGANIZACIONAL DO CRIADOR
           select count(*) into contador
           from demanda de, usuario u, uo
           where de.criador = u.usuarioid
           and u.uo_id = uo.id
           and de.demanda_id = dom.demanda_id
           and uo.responsavel = pusuario_id;

           if contador > 0 then
             vpossuiPermissao := 'S';
            else
              Result := Result ||'EDICAO,' || dom.tipo || ',' || dom.demanda_id || '/';
            end if;

     elsif dom.tipo = 'UC2' then -- 2º RESPONSAVEL DA UNIDADE ORGANIZACIONAL DO CRIADOR
           select count(*) into contador
           from demanda de, usuario u, uo
           where de.criador = u.usuarioid
           and u.uo_id = uo.id
           and de.demanda_id = dom.demanda_id
           and uo.responsavel_2 = pusuario_id;

            if contador > 0 then
              vpossuiPermissao := 'S';
            else
              Result := Result ||'EDICAO,' || dom.tipo || ',' || dom.demanda_id || '/';
            end if;

     elsif dom.tipo = 'UE' then -- USUARIOS ESPECIFICOS
           select count(*) into contador
           from demanda de, regra_formulario rf, estado_formulario ef, atributo_valor av
           where rf.formulario_id = de.formulario_id
           and ef.formulario_id = de.formulario_id
           and ef.regra_id = nvl(pregra_id, rf.regra_id)
           and ef.estado_id = de.situacao
           and de.demanda_id = dom.demanda_id
           and av.atributo_id = rf.atributo_id(+)
           and de.demanda_id(+) = av.demanda_id
           and av.valor = pusuario_id;

            if contador > 0 then
              vpossuiPermissao := 'S';
            else
              Result := Result ||'EDICAO,' || dom.tipo || ',' || dom.demanda_id || '/';
            end if;

     elsif dom.tipo = 'US' then -- 1º RESPONSAVEL DA UNIDADE ORGANIZACIONAL DO SOLICITANTE
           select count(*) into contador
           from demanda de, usuario u, uo
           where de.solicitante = u.usuarioid
           and u.uo_id = uo.id
           and de.demanda_id = dom.demanda_id
           and uo.responsavel = pusuario_id;

            if contador > 0 then
              vpossuiPermissao := 'S';
            else
              Result := Result ||'EDICAO,' || dom.tipo || ',' || dom.demanda_id || '/';
            end if;

     elsif dom.tipo = 'US2' then -- 2º RESPONSAVEL DA UNIDADE ORGANIZACIONAL DO SOLICITANTE
           select count(*) into contador
           from demanda de, usuario u, uo
           where de.solicitante = u.usuarioid
           and u.uo_id = uo.id
           and de.demanda_id = dom.demanda_id
           and uo.responsavel_2 = pusuario_id;

            if contador > 0 then
              vpossuiPermissao := 'S';
            else
              Result := Result ||'EDICAO,' || dom.tipo || ',' || dom.demanda_id || '/';
            end if;
     end if;

     if vpossuiPermissao = 'S' then
       exit;
     end if;
  end loop;
 return Result;
end;

function F_VERIFICA_ITENS_TRANSICAO_DEM (pdemanda_id varchar2, pestado_destino varchar2) return varchar2 is
  Result varchar2(4000);
  rec_demanda demanda%rowtype;
  contador number;
  contador2 number;
  idDemandas pck_geral.t_varchar_array;
  idProximosEstados pck_geral.t_varchar_array;
begin

  idDemandas := pck_geral.f_split(pdemanda_id, ',');
  idProximosEstados := pck_geral.f_split(pestado_destino, ',');

  for contador2 in 1..idDemandas.count loop
    for dom in (select de.demanda_id, te.obrigar_documento, te.obrigar_ter_documento, te.obrigar_entidade, te.obrigar_ter_entidade from transicao_estado te, demanda de
              where te.formulario_id = de.formulario_id
              and te.estado_id = de.situacao
              and de.demanda_id = idDemandas(contador2)
              and te.estado_destino_id = idProximosEstados(contador2)) loop

             if dom.obrigar_documento = 'S' then

                select count(*) into contador from documento
                where tipoentidade = 'D'
                and identidade = dom.demanda_id;

                if contador <= 0 then
                  Result := Result || 'TRANSICAO,' || 'OBRIGAR_DOCUMENTO' || ',' || dom.demanda_id || '/';
                end if;
             end if;
             if dom.obrigar_ter_documento = 'S' then
              begin
              select de.* into rec_demanda from demanda de
              where de.demanda_id = dom.demanda_id;
              exception when others then
              rec_demanda := null;
              end;

               if rec_demanda.documento_vinc_estado <> 'S' then
                 Result := Result || 'TRANSICAO,' || 'OBRIGAR_TER_DOCUMENTO' || ',' || dom.demanda_id || '/';
               end if;
             end if;
             if dom.obrigar_entidade = 'S' then
               select count(*) into contador
               from solicitacaoentidade
               where solicitacao = dom.demanda_id;

               if contador <= 0 then
                  Result := Result || 'TRANSICAO,' || 'OBRIGAR_ENTIDADE' || ',' || dom.demanda_id || '/';
               end if;
             end if;
             if dom.obrigar_ter_entidade = 'S' then

               select de.* into rec_demanda from demanda de
               where de.demanda_id = dom.demanda_id;

               if rec_demanda.entidade_vinc_estado <> 'S' then
                  Result := Result || 'TRANSICAO,' || 'OBRIGAR_TER_ENTIDADE' || ',' || dom.demanda_id || '/';
               end if;
             end if;
       end loop;
  end loop;
  return(Result);
end;

function F_VERIFICA_PERM_CAMPOS_DEMANDA(pusuario_id varchar2, pdemanda_id varchar2) return varchar2 is
  Result varchar2(4000);
  vcampo varchar2(1000);
  rec_demanda demanda%rowtype;
  contador binary_integer := 0;
  v_permissao_campo varchar2(2) := 'N';
  v_retorno_qualquer varchar2(4000);
  lv_sql varchar2(32000);
  type t_sql is ref cursor;
  lc_sql t_sql;
  cursor c_dom is select cf.chave_campo, de.demanda_id, cf.regra_id from demanda de, campo_formulario_estado cfe, campo_formulario cf;
  dom c_dom%rowtype;

begin

  lv_sql := 'select cf.chave_campo, de.demanda_id, cf.regra_id '||
              'from demanda de, campo_formulario_estado cfe, campo_formulario cf '||
              'where de.demanda_id in ('||pdemanda_id||') '||
              'and cfe.formulario_id = de.formulario_id '||
              'and cfe.estado_id = de.situacao '||
              'and cfe.campo_invisivel = ''N'' '||
              'and cfe.campo_bloqueado = ''N'' '||
              'and cf.formulario_id = de.formulario_id '||
              'and cf.chave_campo = cfe.chave_campo '||
              'and cf.visivel = ''S'' '||
              'and cf.obrigatorio = ''S'' ';


  open lc_sql for lv_sql;
    while true loop
      fetch lc_sql into dom;
      exit when lc_sql%notfound;

              if dom.chave_campo = 'BENEFICIO' then
                 begin
                  select descricao into vcampo from beneficio
                  where demanda_id = dom.demanda_id;
                 exception when others then
                           vcampo:=null;
                 end;

                 if dom.regra_id is not null and pusuario_id is not null then
                   v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                 end if;

                 if (vcampo is null and dom.regra_id is null) or
                   (dom.regra_id is not null and v_permissao_campo = 'S' and vcampo is null) then
                    Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id ||'/';
                 end if;

              elsif dom.chave_campo = 'BENEFICIO_VALOR' then
                 begin
                 select valor into vcampo from beneficio
                 where demanda_id = dom.demanda_id;
                 exception when others then
                 vcampo := null;
                 end;

                 if dom.regra_id is not null and pusuario_id is not null then
                   v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                 end if;

                 if (vcampo is null and dom.regra_id is null) or
                   (dom.regra_id is not null and v_permissao_campo = 'S' and vcampo is null) then
                    Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id ||'/';
                 end if;
              elsif dom.chave_campo = 'DATAS_PREVISTAS' then
                    begin
                    select * into rec_demanda
                    from demanda de
                    where de.demanda_id = dom.demanda_id;
                    exception when others then
                    rec_demanda := null;
                    end;

                    if dom.regra_id is not null and pusuario_id is not null then
                     v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                    end if;

                   if (dom.regra_id is not null and v_permissao_campo = 'S' and (rec_demanda.data_inicio_previsto is null or rec_demanda.data_fim_previsto is null)) or
                     ((rec_demanda.data_inicio_previsto is null or rec_demanda.data_fim_previsto is null) and dom.regra_id is null) then
                     Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id || '/';
                   end if;

              elsif dom.chave_campo = 'DATAS_REALIZADAS' then
                    begin
                    select * into rec_demanda
                    from demanda de
                    where de.demanda_id = dom.demanda_id;
                    exception when others then
                    rec_demanda := null;
                    end;

                    if dom.regra_id is not null and pusuario_id is not null then
                     v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                    end if;

                    if (dom.regra_id is not null and v_permissao_campo = 'S' and (rec_demanda.data_inicio_atendimento is null or rec_demanda.data_fim_atendimento is null)) or
                     ((rec_demanda.data_inicio_atendimento is null or rec_demanda.data_fim_atendimento is null) and dom.regra_id is null) then
                      Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id || '/';
                    end if;
              elsif dom.chave_campo = 'DESTINO' then
                    begin
                    select * into rec_demanda
                    from demanda de
                    where de.demanda_id = dom.demanda_id;
                    exception when others then
                    rec_demanda := null;
                    end;

                    if dom.regra_id is not null and pusuario_id is not null then
                     v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                    end if;

                    if (rec_demanda.destino_id is null and dom.regra_id is null) or
                      (rec_demanda.destino_id is null and dom.regra_id is not null and v_permissao_campo = 'S')then
                       Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id || '/';
                    end if;

              elsif dom.chave_campo = 'INTERESSADOS' then

                    select count(*) into contador
                    from parte_interessada
                    where demanda_id = dom.demanda_id;

                    if dom.regra_id is not null and pusuario_id is not null then
                     v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                    end if;

                    if (contador <= 0 and dom.regra_id is null) or
                      (contador <= 0 and dom.regra_id is not null and v_permissao_campo = 'S')then
                      Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id || '/';
                    end if;
              /* CAMPO MOTIVO NAO EXISTE MAIS NO FORMULARIO
               elsif dom.chave_campo = 'MOTIVO' then
                    begin
                    select * into rec_demanda
                    from demanda de
                    where de.demanda_id = dom.demanda_id;
                    exception when others then
                    rec_demanda := null;
                    end;

                    if dom.regra_id is not null and pusuario_id is not null then
                     v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                    end if;

                    if (rec_demanda.motivo is null and dom.regra_id is null) or
                      (rec_demanda.motivo is null and dom.regra_id is not null and v_permissao_campo = 'S')then
                       Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id || '/';
                    end if;*/

              elsif dom.chave_campo = 'OUTRO' then
                    begin
                    select * into rec_demanda
                    from demanda de
                    where de.demanda_id = dom.demanda_id;
                    exception when others then
                    rec_demanda := null;
                    end;

                    if dom.regra_id is not null and pusuario_id is not null then
                     v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                    end if;

                    if (rec_demanda.outro is null and dom.regra_id is null) or
                      (rec_demanda.outro is null and dom.regra_id is not null and v_permissao_campo = 'S')then
                       Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id || '/';
                    end if;
              elsif dom.chave_campo = 'PESO' then
                    begin
                    select * into rec_demanda
                    from demanda de
                    where de.demanda_id = dom.demanda_id;
                    exception when others then
                    rec_demanda := null;
                    end;

                    if dom.regra_id is not null and pusuario_id is not null then
                     v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                    end if;

                    if (rec_demanda.peso is null and dom.regra_id is null) or
                      (rec_demanda.peso is null and dom.regra_id is not null and v_permissao_campo = 'S')then
                       Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id || '/';
                    end if;
              elsif dom.chave_campo = 'PRIORIDADE' then
                    begin
                    select * into rec_demanda
                    from demanda de
                    where de.demanda_id = dom.demanda_id;
                    exception when others then
                    rec_demanda := null;
                    end;

                    if dom.regra_id is not null and pusuario_id is not null then
                     v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                    end if;

                    if (rec_demanda.prioridade is null and dom.regra_id is null) or
                      (rec_demanda.prioridade is null and dom.regra_id is not null and v_permissao_campo = 'S')then
                       Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id || '/';
                    end if;
              elsif dom.chave_campo = 'PRIORIDADE_ATENDIMENTO' then
                    begin
                    select * into rec_demanda
                    from demanda de
                    where de.demanda_id = dom.demanda_id;
                    exception when others then
                    rec_demanda := null;
                    end;

                    if dom.regra_id is not null and pusuario_id is not null then
                     v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                    end if;

                    dbms_output.put_line('v_permissao_campo: '|| v_permissao_campo || ' - dom.regra_id: '|| dom.regra_id);

                    if (rec_demanda.prioridade_responsavel is null and dom.regra_id is null) or
                      (rec_demanda.prioridade_responsavel is null and dom.regra_id is not null and v_permissao_campo = 'S') then
                       Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id || '/';
                    end if;
              elsif dom.chave_campo = 'RESPONSAVEL' then
                    begin
                     select * into rec_demanda
                    from demanda de
                    where de.demanda_id = dom.demanda_id;
                    exception when others then
                    rec_demanda := null;
                    end;

                    if dom.regra_id is not null and pusuario_id is not null then
                     v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                    end if;

                    if (rec_demanda.responsavel is null and dom.regra_id is null) or
                      (rec_demanda.responsavel is null and dom.regra_id is not null and v_permissao_campo = 'S')then
                       Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id || '/';
                    end if;
              elsif dom.chave_campo = 'SOLICITANTE' then
                    begin
                     select * into rec_demanda
                    from demanda de
                    where de.demanda_id = dom.demanda_id;
                    exception when others then
                    rec_demanda := null;
                    end;

                    if dom.regra_id is not null and pusuario_id is not null then
                     v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                    end if;

                    if (rec_demanda.solicitante is null and dom.regra_id is null) or
                      (rec_demanda.solicitante is null and dom.regra_id is not null and v_permissao_campo = 'S')then
                       Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id || '/';
                    end if;
              elsif dom.chave_campo = 'TIPO' then
                    begin
                     select * into rec_demanda
                    from demanda de
                    where de.demanda_id = dom.demanda_id;
                    exception when others then
                    rec_demanda := null;
                    end;

                    if dom.regra_id is not null and pusuario_id is not null then
                     v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                    end if;

                    if (rec_demanda.tipo is null and dom.regra_id is null) or
                      (rec_demanda.tipo is null and dom.regra_id is not null and v_permissao_campo = 'S')then
                       Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id || '/';
                    end if;
              elsif dom.chave_campo = 'TITULO' then
                    begin
                     select * into rec_demanda
                    from demanda de
                    where de.demanda_id = dom.demanda_id;
                    exception when others then
                    rec_demanda := null;
                    end;

                    if dom.regra_id is not null and pusuario_id is not null then
                     v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
                    end if;

                    if (rec_demanda.titulo is null and dom.regra_id is null) or
                      (rec_demanda.titulo is null and dom.regra_id is not null and v_permissao_campo = 'S')then
                       Result := Result || 'CAMPOS,' || dom.chave_campo || ',' || dom.demanda_id || '/';
                    end if;
              end if;
              v_permissao_campo := 'N';
   end loop;

  return(Result);
end;

function F_VERIFICA_PERM_ATR_DEMANDA(pusuario_id varchar2, pdemanda_id varchar2) return varchar2 is
  Result varchar2(4000);
  contador binary_integer := 0;
  v_permissao_campo varchar2(2) := 'N';
  v_retorno_qualquer varchar2(4000);

  lv_sql varchar2(32000);
  type t_sql is ref cursor;
  lc_sql t_sql;
  cursor c_dom is select de.demanda_id, a.atributoid, te.texto_termo, te.idioma, a.tipo, sa.regra_id from demanda de, atributo_form_estado afe, secao_atributo sa, atributo a, termo te;
  dom c_dom%rowtype;
  cursor av_dom is select dominio_atributo_id, valor, valordata, valornumerico, valor_html, categoria_item_atributo_id, matriz_id from atributo_valor;
  a_dom av_dom%rowtype;
begin

  lv_sql := 'select de.demanda_id, a.atributoid, te.texto_termo, te.idioma, a.tipo, sa.regra_id '||
             'from demanda de, atributo_form_estado afe, secao_atributo sa, atributo a, termo te '||
             'where de.demanda_id in ('|| pdemanda_id || ') '||
             'and afe.formulario_id = de.formulario_id '||
             'and afe.estado_id = de.situacao '||
             'and afe.campo_invisivel = ''N'' '||
             'and afe.campo_bloqueado = ''N'' '||
             'and sa.formulario_id = de.formulario_id '||
             'and sa.atributo_id = afe.atributo_id '||
             'and sa.obrigatorio = ''S'' '||
             'and sa.vigente = ''S'' '||
             'and sa.visivel = ''S'' '||
             'and a.atributoid = sa.atributo_id '||
             'and a.titulo_termo_id = te.termo_id ';

  open lc_sql for lv_sql;
    while true loop
      fetch lc_sql into dom;
      exit when lc_sql%notfound;

             select dominio_atributo_id, valor, valordata, valornumerico, valor_html, categoria_item_atributo_id, matriz_id into a_dom
              from atributo_valor av
              where av.atributo_id = dom.atributoid
              and demanda_id = dom.demanda_id;

              dbms_output.put_line('atributo ::::::::::::: '|| dom.atributoid);

             if dom.regra_id is not null and pusuario_id is not null then
                 v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
              end if;

              if (a_dom.dominio_atributo_id is not null or a_dom.valor is not null or a_dom.valordata is not null or a_dom.valornumerico is not null or a_dom.valor_html is not null or a_dom.categoria_item_atributo_id is not null or a_dom.matriz_id is not null) then
                contador := 1; --tem valor
              else
                contador := 0; --NAO tem valor
              end if;

              if (contador <= 0 and dom.regra_id is null) or
                (contador <= 0  and dom.regra_id is not null and v_permissao_campo = 'S') then
                Result := Result || 'ATR' || ',' || dom.atributoid || ',' || dom.demanda_id || '/';
              end if;

  end loop;
  return(Result);
end;

procedure p_verifica_campos_e_atributos(pusuario_id varchar2, pdemanda_id varchar2, pagendamento_id varchar2, ret in out varchar2) is
ret1 varchar2(100);
ret2 varchar2(100);
  begin
  ret1:=F_VERIFICA_PERM_CAMPOS_DEMANDA(pusuario_id, pdemanda_id);
  ret2:=F_VERIFICA_PERM_ATR_DEMANDA(pusuario_id, pdemanda_id);
  ret:=nvl(ret1,'')||nvl(ret2,'');

   -- LOGAR Zarpelon INICIO

    insert into AGENDAMENTO_TRANSICAO_EST_LOG (id,agendamento_id,data_execucao,demanda_id,estado_atual_id,
                                               estado_destino_id, executado, mensagem)
    select AGENDAMENTO_TRAN_EST_LOG_SEQ.Nextval, a.id, sysdate,
           a.demanda_id, (select max(h2.id) from h_demanda h2 where h2.demanda_id=a.demanda_id),
           a.estado_destino,case when trim(nvl(ret1,'')||nvl(ret2,'')) is null then 'Y' else 'N' end,
           nvl(ret1,'')||nvl(ret2,'')
    from AGENDAMENTO_TRANSICAO_ESTADO a where a.id=pagendamento_id;

   -- LOGAR Zarpelon FIM

  end;

end PCK_VALIDA_DEMANDA;
/

create or replace package pck_regras is

  -- Author  : MDIAS
  -- Created : 7/5/2010 13:20:57
   type t_ids is table of number index by binary_integer;
      
   function f_get_valor_propriedade ( pn_demanda_id demanda.demanda_id%type,
                                      pv_usuario_id usuario.usuarioid%type,
                                      pn_propriedade_id regras_propriedade.id%type ) return varchar2;

   function f_formata (pn_numero number) return varchar2;
   
   function f_get_numero (pv_numero varchar2) return number;
   
   function f_formata (pd_data date) return varchar2;
     
   function f_get_Data (pv_data varchar2) return date;
   
   /*function f_teste_validacao ( pn_demanda_id   demanda.demanda_id%type,
                                pn_validacao_id regras_validacao.id%type,
                                pv_usuario_id   usuario.usuarioid%type) return boolean;*/
                                
   function f_teste_validacao ( pn_demanda_id   demanda.demanda_id%type,
                                pn_validacao_id regras_validacao.id%type,
                                pv_usuario_id   usuario.usuarioid%type,
                                pb_salvar_log_hist_trans boolean,
                                pn_transicao_id transicao_estado.transicao_estado_id%type,
                                pn_log_pai      log_hist_transicao.id%type,
                                pv_tipo_regra_hist varchar2,                
                                pd_data_hist date,
                                pv_somente_teste varchar2,
                                pv_usuario_autorizador varchar2) return boolean;   

                                                              

   procedure p_copia_propriedade ( pn_demanda_id demanda.demanda_id%type,
                                   pv_usuario_id usuario.usuarioid%type,
                                   pn_propriedade_id_origem regras_propriedade.id%type,
                                   pv_valor_origem varchar2,
                                   pn_propriedade_id_destino regras_propriedade.id%type,
                                   pb_append boolean,
                                   pn_tipo_lanc_dest number,
                                   pn_msg_erro_lanc out varchar2);
   
                                                     
  procedure p_exec_regras_valid_trans ( pn_demanda_id demanda.demanda_id%type,
                                                     pn_transicao_id transicao_estado.transicao_estado_id%type,
                                                     pn_usuario_id usuario.usuarioid%type,
                                                     pn_usuario_autorizador number,
                                                     pn_somente_testar number,
                                                     pn_return out number,
                                                     pn_estado_id out number, 
                                                     pn_estado_mensagem_id out number, 
                                                     pn_enviar_email out number, 
                                                     pn_gerar_baseline out number,
                                                     pn_gerar_documento out varchar2);   
                                                     
                                                     
  function p_formata_valor_prop (pv_valor varchar2, pn_id_propriedade number) return varchar2;                                                                                                       
  
  procedure p_copia_permissoes_papel(pn_demanda_id demanda.demanda_id%type, rec_acao in acao_condicional%rowtype);
  
  procedure p_copia_conh_papel_proj(pn_projeto_id number, pn_papel_id number, pv_titulo_papel varchar2, pv_procedimento varchar2);
                                      
  procedure p_copia_perm_papel_proj(pn_projeto_id number, pn_papel_id number, pv_titulo_papel varchar2, pv_procedimento varchar2);

  function f_atr_obrig_nao_preenchido(pn_id_entidade number, pn_id_lancamento number, pv_tipo varchar2) return number;
  
  procedure get_v_padrao_atr_lanc(pn_id_entidade number, 
                                   pn_atr_id number, 
                                   pv_valor out varchar2,
                                   pd_valordata out date,
                                   pn_valornumerico out number,
                                   pn_dominio out number,
                                   pv_valorhtml out clob,
                                   pn_categoria out number,
                                   pv_tipo varchar2);
                                   
 function config_permite_geracao_doc(pn_demanda_id number,pn_acao_id number) return number;                                   
 function regra_relevante_permite(pn_acao_id number, la_ids_invalidos t_ids, pn_tipo_regra varchar2) return number;
end pck_regras;
/
create or replace package body pck_regras is

   const_formato_numero   varchar2(33) := 'fm00000000000000000000D0000000000';
   const_formato_data     varchar2(16) := 'yyyymmddhh24miss';
   const_nls_numero_sql       varchar2(30) := 'NLS_NUMERIC_CHARACTERS ='''',.''''';
   const_nls_numero       varchar2(30) := 'NLS_NUMERIC_CHARACTERS ='',.''';

   const_nls_numero_update       varchar2(30) := 'NLS_NUMERIC_CHARACTERS =''.,''';
   
   /*
       retorno o valor da propriedade ou o id da lista que contem as propriedades na tabela
       regras_lista_temp.
       Se pb_get_update, retorna
   */

   function f_get_val_sel_propriedade ( pn_demanda_id demanda.demanda_id%type,
                                      pv_usuario_id usuario.usuarioid%type,
                                      pn_propriedade_id regras_propriedade.id%type,
                                      pb_get_update     boolean,
                                      pb_get_sub_propriedade boolean,
                                      pn_tipo_entidade_id in out regras_tipo_entidade.id%type ) return varchar2 is
   lv_sql              varchar2(32000);
   lv_formato          varchar2(33);
   lb_to_char          boolean:=false;
   lv_coluna           varchar2(32000);
   lv_coluna_pk        varchar2(100);
   lv_coluna_aux       varchar2(32000);
   lv_from             varchar2(1000);
   lv_where            varchar2(32000);
   lv_coluna_pk_entidade varchar2(100);
   lv_from_entidade    varchar2(1000);
   lv_where_entidade   varchar2(32000);
   lv_where_temp       varchar2(32000);
   lv_p1               varchar2(32000);
   lv_p2               varchar2(32000);
   type t_sql is ref cursor;
   lc_sql t_sql;
   lv_valor            varchar2(32000);
   lv_valor_aux        varchar2(32000);
   ln_seq_alias        number := 0;
   lv_nome_tabela_atual varchar2(50);
   lv_alias_anterior   varchar2(20);
   lv_alias_atual      varchar2(20);
   lv_alias_atual_entidade varchar2(20);
   lv_alias_tab_item   varchar2(20);
   lb_lista            boolean;
   ln_seq_lista        number;
   ln_update           number:=0;
   lv_ultimo_tipo_valor regras_tipo_valor.codigo%type;
   lb_concatena        boolean:=false;
   
   ln_inicio_prop      number;
   ln_fim_prop         number;
   lv_propriedade_id   varchar2(10);
   ln_aux              regras_tipo_entidade.id%type;
   lv_tipo_atributo    atributo.tipo%type;
   
   ln_count number;
   begin
     --Se estiver buscando a entidade destino de atualizacao
     --vai ate a ultima entidade que pode conter atributos ou lancamentos
     if pb_get_update then
        ln_update := 1;
     end if;
     
     select count(1), max(sql)
     into ln_aux, lv_sql
     from regras_propriedade p
     where id = pn_propriedade_id
     and   sql is not null
     and   not exists (select 1 from regras_propriedade_niveis n where n.propriedade_id = p.id);
     
     if (ln_aux=0) then
     
         for c in (select ep.nome_tabela p_nome_tabela, ep.coluna_pk p_coluna_pk, ep.id p_tipo_entidade_id,
                          et.nome_tabela t_nome_tabela, et.coluna_pk t_coluna_pk, et.id t_tipo_entidade_id,
                          v.codigo tipo_valor,
                          e.codigo escopo,
                          p.where_filtro where_filtro_propriedade,
                          n.where_filtro,
                          n.id nivel_id,
                          t.id tipo_propriedade_id,
                          t.coluna,
                          t.atualizavel,
                          n.atributo_id atributoid,
                          a.codigo agrupador,
                          er.nome_tabela r_nome_tabela, er.coluna_pk r_coluna_pk, er.tipo_entidade r_tipo_entidade,
                          er.id r_tipo_entidade_id,
                          er.coluna_atributo_id coluna_atributo_id, 
                          t.where_join where_join_ref,
                          (select max(id) from regras_prop_nivel_item it where it.nivel_id = n.id) itens,
                          COUNT(*) OVER () total, 
                          row_number() over (order by n.ordem) linha
                   from regras_propriedade p, 
                        regras_tipo_escopo e,
                        regras_propriedade_niveis n,
                        regras_tipo_propriedade t,
                        regras_tipo_valor v,
                        regras_tipo_entidade ep,
                        regras_tipo_entidade et,
                        regras_tipo_agrupador a,
                        regras_tipo_entidade er
                   where p.id = pn_propriedade_id
                   and   p.id = n.propriedade_id
                   and   p.escopo_id = e.id
                   and   n.tipo_propriedade_id = t.id (+)
                   and   t.tipo_valor_id = v.id (+)
                   and   e.tipo_entidade_id = ep.id
                   and   t.tipo_entidade_id = et.id (+)
                   and   p.agrupador_id = a.id
                   and   t.ref_tipo_entidade_id = er.id (+)
                   order by n.ordem) loop
                   
           if pb_get_update and c.itens is not null then
              raise_application_error (-20001, 'Nao foi possivel identificar propriedade a ser atualizada. Muitos tipos selecionados.');
           end if;

           --Apenas entidades identificadas nas tabelas de atributos e custo_entidade sao retornadas
           --Retorna a ultima encontrada no caminho da definicao da propriedade
           if pb_get_update and upper(c.t_nome_tabela) not in ('CUSTO_ENTIDADE','MV_CUSTO_LANCAMENTO') then
              pn_tipo_entidade_id := c.t_tipo_entidade_id;
           end if;
           
           lv_coluna := c.coluna;
           lv_coluna_pk := c.t_coluna_pk;
           
           lv_ultimo_tipo_valor := c.tipo_valor;

           --Primeiro nivel
           if c.linha = 1 then
              ln_seq_alias := ln_seq_alias + 1;
              lv_alias_atual := 'tab_'||ln_seq_alias;
              
              --Adiciona tabela vinculada ao escopo da propriedade
              lv_from := c.p_nome_tabela || ' '|| lv_alias_atual;
              
              lv_nome_tabela_atual := c.p_nome_tabela;
              
              --Monta where do escopo
             if c.escopo = 'demandaCorrente' then
                 lv_where := ' and '|| lv_alias_atual || '.demanda_id = ' || pn_demanda_id|| ' ';
              elsif c.escopo = 'demandasFilhas' then
                 lv_where := ' and '|| lv_alias_atual || '.demanda_pai = ' || pn_demanda_id|| ' ';
              elsif c.escopo = 'demandasIrmas' then
                 lv_where := ' and '|| lv_alias_atual || '.demanda_pai in (select demanda_pai from demanda where demanda_id = ' || pn_demanda_id ||') '||
                             ' and '|| lv_alias_atual || '.demanda_id <> ' || pn_demanda_id|| ' ';
              elsif c.escopo = 'demandasIrmasMaisCorrente' then
                 lv_where := ' and '|| lv_alias_atual || '.demanda_pai in (select demanda_pai from demanda where demanda_id = ' || pn_demanda_id ||') ';
              elsif c.escopo = 'projetosAssociados' then
                 lv_where := ' and '|| lv_alias_atual || '.id in (select case when tipoentidade = ''P'' then identidade else projeto end identidade  from solicitacaoentidade where (tipoentidade = ''P'' or tipoentidade = ''L'') and solicitacao = ' || pn_demanda_id ||') ';
              elsif c.escopo = 'usuarioLogado' then
                 lv_where := ' and '|| lv_alias_atual || '.usuarioid = '''||pv_usuario_id||''' ';
              elsif c.escopo = 'demandasProjetosAssociados' then
                 lv_where := ' and '|| lv_alias_atual || '.demanda_id in (select d.solicitacao  from solicitacaoentidade p, solicitacaoentidade d where p.tipoentidade = d.tipoentidade and p.identidade = d.identidade and p.tipoentidade = ''P''  and p.solicitacao = ' || pn_demanda_id ||') '||
                             ' and '|| lv_alias_atual || '.demanda_id <> ' || pn_demanda_id|| ' ';
              elsif c.escopo = 'demandasProjetosAssociadosMaisCorrente' then
                 lv_where := ' and '|| lv_alias_atual || '.demanda_id in (select d.solicitacao  from solicitacaoentidade p, solicitacaoentidade d where p.tipoentidade = d.tipoentidade and p.identidade = d.identidade and p.tipoentidade = ''P''  and p.solicitacao = ' || pn_demanda_id ||') ';
              elsif c.escopo = 'projetosDemandasFilhas' then
                 lv_where := ' and '|| lv_alias_atual || '.id in (select case when tipoentidade = ''P'' then identidade else projeto end identidade  from solicitacaoentidade where (tipoentidade = ''P'' or tipoentidade = ''L'') and solicitacao in (select demanda_id from demanda where demanda_pai =  ' || pn_demanda_id ||')) ';
              elsif c.escopo = 'projetosDemandasFilhas' then
                 lv_where := ' and '|| lv_alias_atual || '.id in (select case when tipoentidade = ''P'' then identidade else projeto end identidade  from solicitacaoentidade where (tipoentidade = ''P'' or tipoentidade = ''L'') and solicitacao in (select demanda_pai from demanda where demanda_id =  ' || pn_demanda_id ||')) ';
              elsif c.escopo = 'descententesDemandasAssociadasProjetoDemandaPai' then
                 lv_where := ' and '|| lv_alias_atual || '.demanda_id in (select demanda_id from demanda connect by prior demanda_id = demanda_pai start with demanda_id in (select d.solicitacao from solicitacaoentidade p, solicitacaoentidade d where p.tipoentidade = d.tipoentidade and p.identidade = d.identidade and p.tipoentidade = ''P''  and p.solicitacao = (select demanda_pai from demanda where demanda_id = ' || pn_demanda_id ||'))) ';
              elsif c.escopo = 'descententesDemandasAssociadasProjetoDemanda' then
                 lv_where := ' and '|| lv_alias_atual || '.demanda_id in (select demanda_id from demanda connect by prior demanda_id = demanda_pai start with demanda_id in (select d.solicitacao from solicitacaoentidade p, solicitacaoentidade d where p.tipoentidade = d.tipoentidade and p.identidade = d.identidade and p.tipoentidade = ''P''  and p.solicitacao = ' || pn_demanda_id ||')) ';
              elsif c.escopo = 'demandaPai' then
                 lv_where := ' and '|| lv_alias_atual || '.demanda_id in (select demanda_pai from demanda where demanda_id = ' || pn_demanda_id ||') ';
              end if;
              
              if c.where_filtro_propriedade is not null then
                 lv_where := lv_where || ' and '|| replace(c.where_filtro_propriedade, '[ENTIDADE]', lv_alias_atual);
              end if;
              
              lv_coluna_pk_entidade := c.p_coluna_pk;
              lv_from_entidade := lv_from;
              lv_where_entidade := lv_where;
              pn_tipo_entidade_id := c.p_tipo_entidade_id;
              lv_alias_atual_entidade := lv_alias_atual;
              
           end if;
           
           --Se a propriedade referencia uma outra entidade e devem ser buscadas 
           --propriedades da entidade referenciada (nao e o ultimo nivel)
           if c.r_nome_tabela is not null /*and 
              (c.linha = c.total or 
               c.r_nome_tabela not in ('ATRIBUTO_VALOR','ATRIBUTOENTIDADEVALOR'))*/ then
              ln_seq_alias := ln_seq_alias + 1;
              lv_alias_anterior := lv_alias_atual;
              lv_alias_atual := 'tab_'||ln_seq_alias;
              
              lv_coluna := c.r_coluna_pk;
              
              lv_nome_tabela_atual := c.r_nome_tabela;
              
              lv_from := lv_from || ', ' || c.r_nome_tabela || ' '|| lv_alias_atual;
              
              if c.coluna is null and c.where_join_ref is null then
                 raise_application_error(-20001, 'Tipo de Propriedade referencia outra entidade sem criterio de join. Propriedade: '||pn_propriedade_id);
              end if;

              --relacionamento/join atraves de chave estrangeira na tabela
              --faz o join pelo campo da tabela e a pk da referenciada
              if c.coluna is not null and c.where_join_ref is null then
                 lv_where := lv_where || ' and ' || lv_alias_anterior || '.' || c.coluna || ' = ' || lv_alias_atual ||'.'||c.r_coluna_pk;
              end if;
              
              if c.atributoid is not null then
                 lv_where := lv_where || ' and ' || lv_alias_atual ||'.'||c.coluna_atributo_id||' (+) = '||c.atributoid;
              end if;
              
              --join efetuado atraves de clausula where pre-salva
              --com as entidades identificadas por [ENTIDADE-PAI] e [ENTIDADE-FILHA]
              if c.where_join_ref is not null then
                 lv_where_temp := replace(replace(c.where_join_ref, '[ENTIDADE-PAI]', lv_alias_anterior), '[ENTIDADE-FILHA]', lv_alias_atual);
                 lv_where := lv_where || ' and ' || lv_where_temp;
              end if;

              --Where para filtrar a entidade referenciada
              if c.where_filtro is not null then
                 lv_where := lv_where || ' and '|| replace(c.where_filtro, '[ENTIDADE]', lv_alias_atual);
              end if;
              
              if c.r_tipo_entidade is not null then
                 lv_coluna_pk_entidade := c.r_coluna_pk;
                 lv_from_entidade := lv_from;
                 lv_where_entidade := lv_where;
                 pn_tipo_entidade_id := c.r_tipo_entidade_id;
                 lv_alias_atual_entidade := lv_alias_atual;
              end if;
              
           end if;
           
           --Formata o campo conforme o tipo
           if c.agrupador = 'lista' then
              lb_lista := true;
           elsif c.agrupador = 'concatena' then
              lb_concatena := true;
           end if;
           if c.total = c.linha then
               if c.itens is null then
                  if c.atualizavel = 'N' and pb_get_update then
                     raise_application_error(-20001,'Proibido efetuar cópia para esta propriedade. Propriedade: ' || pn_propriedade_id);
                  end if;
                  if c.agrupador<>'concatena' and 
                     c.tipo_valor in ('numero', 'horas', 'data', 'entidade', 'lancamento') then
                     if c.tipo_valor in ('numero', 'horas', 'entidade', 'lancamento') then
                        lv_formato := const_formato_numero;
                     else
                        lv_formato := const_formato_data;
                     end if;
                     if not pb_get_sub_propriedade then
                        lb_to_char := true;
                     end if;
                  end if;
                  
                  if c.tipo_valor = 'lancamento' and pb_get_update then
                        lv_coluna := lv_alias_atual ||'.'||c.t_coluna_pk;
                  elsif c.tipo_valor = 'atributo' then
                     if pb_get_update then
                        lv_coluna := lv_alias_atual ||'.'||c.t_coluna_pk;
                     else
                        lv_coluna := '(case when [ALIAS-TAB-ATRIB].valor is not null then [ALIAS-TAB-ATRIB].valor ' ||
                                     '      when [ALIAS-TAB-ATRIB].valordata is not null then to_char([ALIAS-TAB-ATRIB].valordata, ''[FORMATO-DATA]'') ' ||
                                     '      when [ALIAS-TAB-ATRIB].valornumerico is not null then to_char([ALIAS-TAB-ATRIB].valornumerico, ''[FORMATO-NUMERO]'', ''[NLS-NUMERO]'' ) ' ||
                                     '      when [ALIAS-TAB-ATRIB].dominio_atributo_id is not null then to_char([ALIAS-TAB-ATRIB].dominio_atributo_id, ''[FORMATO-NUMERO]'', ''[NLS-NUMERO]'' ) ' ||
                                     '      when [ALIAS-TAB-ATRIB].categoria_item_atributo_id is not null then to_char([ALIAS-TAB-ATRIB].categoria_item_atributo_id, ''[FORMATO-NUMERO]'', ''[NLS-NUMERO]'' ) ' ||
    /*Alerta quando copiar > 4000 char*/'      when dbms_lob.getlength([ALIAS-TAB-ATRIB].valor_html) > 4000 then to_char(to_number(''campo html grande demais. Gera erro.''))' ||
                                     '      when [ALIAS-TAB-ATRIB].valor_html is not null then dbms_lob.substr([ALIAS-TAB-ATRIB].valor_html,4000)  ' ||
                                     '      else null end) ';
                        lv_coluna := replace(lv_coluna, '[ALIAS-TAB-ATRIB]', lv_alias_atual);
                        lv_coluna := replace(lv_coluna, '[FORMATO-DATA]', const_formato_data);
                        lv_coluna := replace(lv_coluna, '[FORMATO-NUMERO]', const_formato_numero);
                        lv_coluna := replace(lv_coluna, '[NLS-NUMERO]', const_nls_numero_sql);
                        if c.atributoid is not null then
                           select a.tipo
                           into lv_tipo_atributo
                           from atributo a
                           where a.atributoid = c.atributoid;
                           
                           if lv_tipo_atributo = pck_atributo.Tipo_NUMERO or
                              lv_tipo_atributo = pck_atributo.Tipo_MONETARIO then
                              lb_to_char := true;
                           end if;
                        end if;
                     end if;
                  else 
                     lv_coluna := lv_alias_atual||'.'||lv_coluna;
                  end if;
                  if c.tipo_valor is not null then
                     if c.agrupador = 'menor' then
                        lv_coluna := ' min('||lv_coluna||') ';
                     elsif c.agrupador = 'maior' then
                        lv_coluna := ' max('||lv_coluna||') ';
                     elsif c.agrupador = 'semValor' then
                        lv_coluna := ' min('||lv_coluna||') ';
                     elsif c.agrupador = 'media' then
                        lv_coluna := ' avg('||lv_coluna||') ';
                     elsif c.agrupador = 'soma' then
                        lv_coluna := ' sum('||lv_coluna||') ';
                     elsif c.agrupador = 'somaNvlZero' then
                        lv_coluna := ' nvl(sum('||lv_coluna||'),0) ';
                     elsif c.agrupador = 'contar' then
                        lv_coluna := ' count(1) ';
                     elsif c.agrupador = 'contarDistinct' then
                        lv_coluna := ' count( distinct '||lv_coluna||') ';
                     end if;
                     if lb_to_char then
                        --apenas atributos numericos e monetarios terao lb_to_char == true
                        if c.tipo_valor in ('atributo','numero','horas','entidade', 'lancamento') then
                           lv_coluna := ' to_char('||lv_coluna||','''||const_formato_numero||''','''||const_nls_numero_sql||''') ';
                        else
                           lv_coluna := ' to_char('||lv_coluna||','''||const_formato_data||''') ';
                        end if;
                     else
                        lv_coluna := ' ' || lv_coluna || ' ';
                     end if;
                  end if;
               else 
                  -- 
                  --Concatena colunas do mesmo registro
                  lv_coluna := '';
                  for it in (select v.codigo tipo_valor,
                                    t.coluna, 
                                    t.where_join where_join_ref,
                                    i.atributo_id,
                                    i.texto,
                                    e.nome_tabela,
                                    e.coluna_pk,
                                    e.coluna_atributo_id, 
                                    t.atualizavel,
                                    COUNT(*) OVER () total, 
                                    row_number() over (order by i.ordem) linha
                             from regras_prop_nivel_item i,
                                  regras_tipo_propriedade t,
                                  regras_tipo_valor v,
                                  regras_tipo_entidade e
                             where i.nivel_id = c.nivel_id
                             and   i.tipo_propriedade_id = t.id (+)
                             and   t.tipo_valor_id = v.id (+)
                             and   t.ref_tipo_entidade_id = e.id (+)
                             order by i.ordem) loop
                     if it.atualizavel = 'N' and pb_get_update then
                        raise_application_error(-20001,'Proibido efetuar cópia para esta propriedade. Propriedade: ' || pn_propriedade_id);
                     end if;
                     lb_to_char := false;
                     if c.agrupador<>'concatena' and
                        it.total = 1 and 
                        it.tipo_valor in ('numero', 'horas', 'data', 'entidade', 'lancamento') then
                        if it.tipo_valor in ('numero', 'horas', 'entidade', 'lancamento') then
                           lv_formato := const_formato_numero;
                        else
                           lv_formato := const_formato_data;
                        end if;
                        if not pb_get_sub_propriedade then
                           lb_to_char := true;
                        end if;
                     end if;
                     
                     lv_alias_tab_item := lv_alias_atual;
                     if it.atributo_id is not null then
                        ln_seq_alias := ln_seq_alias + 1;
                        lv_alias_tab_item := 'TAB_'||ln_seq_alias;
                        lv_from := lv_from || ', ' || it.nome_tabela || ' '|| lv_alias_tab_item;

                        lv_where := lv_where || ' and ' || lv_alias_tab_item ||'.'||it.coluna_atributo_id||' (+) = '||it.atributo_id;

                        --join efetuado atraves de clausula where pre-salva
                        --com as entidades identificadas por [ENTIDADE_PAI] e [ENTIDADE_FILHA]
                        if it.where_join_ref is not null then
                           lv_where_temp := replace(replace(it.where_join_ref, '[ENTIDADE-PAI]', lv_alias_atual), '[ENTIDADE-FILHA]', lv_alias_tab_item);
                           lv_where := lv_where || ' and ' || lv_where_temp;
                        end if;
                     end if;
                     
                     lv_coluna_aux := it.coluna;
                     
                     if it.tipo_valor = 'atributo' then
                        lv_coluna_aux := '(case when [ALIAS-TAB-ATRIB].valor is not null then [ALIAS-TAB-ATRIB].valor ' ||
                                     '      when [ALIAS-TAB-ATRIB].valordata is not null then to_char([ALIAS-TAB-ATRIB].valordata, ''[FORMATO-DATA]'') ' ||
                                     '      when [ALIAS-TAB-ATRIB].valornumerico is not null then to_char([ALIAS-TAB-ATRIB].valornumerico, ''[FORMATO-NUMERO]'') ' ||
                                     '      when [ALIAS-TAB-ATRIB].dominio_atributo_id is not null then to_char([ALIAS-TAB-ATRIB].dominio_atributo_id, ''[FORMATO-NUMERO]'') ' ||
                                     '      when [ALIAS-TAB-ATRIB].categoria_item_atributo_id is not null then to_char([ALIAS-TAB-ATRIB].categoria_item_atributo_id, ''[FORMATO-NUMERO]'') ' ||
    /*Alerta quando copiar > 4000 char*/'      when dbms_lob.getlength([ALIAS-TAB-ATRIB].valor_html) > 4000 then to_char(to_number(''campo html grande demais. Gera erro.''))' ||
                                     '      when [ALIAS-TAB-ATRIB].valor_html is not null then dbms_lob.substr([ALIAS-TAB-ATRIB].valor_html,4000)  ' ||
                                     '      else null end) ';
                        lv_coluna_aux := replace(lv_coluna_aux, '[ALIAS-TAB-ATRIB]', lv_alias_tab_item);
                        if lb_to_char then
                           lv_coluna_aux := replace(lv_coluna_aux, '[FORMATO-DATA]', const_formato_data);
                           lv_coluna_aux := replace(lv_coluna_aux, '[FORMATO-NUMERO]', const_formato_numero);
                        else
                           lv_coluna_aux := replace(lv_coluna_aux, '[FORMATO-DATA]', 'dd/mm/yyyy');
                           lv_coluna_aux := replace(lv_coluna_aux, '[FORMATO-NUMERO]', 'fm0D0');
                        end if;
                     else
                        if lb_to_char then
                           if it.tipo_valor = 'data' then
                              lv_coluna_aux := ' to_char(' || lv_alias_tab_item||'.'||lv_coluna_aux || ','''||lv_formato||''') ';
                              if c.agrupador = 'menor' then
                                 lv_coluna_aux := ' min('||lv_coluna_aux||') ';
                              elsif c.agrupador = 'maior' then
                                 lv_coluna_aux := ' max('||lv_coluna_aux||') ';
                              elsif c.agrupador = 'semValor' then
                                 lv_coluna_aux := ' min('||lv_coluna_aux||') ';
                              elsif c.agrupador = 'contar' then
                                 lv_coluna_aux := ' count(1) ';
                              elsif c.agrupador = 'contarDistinct' then
                                 lv_coluna_aux := ' count( distinct '||lv_coluna_aux||') ';
                              elsif c.agrupador = 'concatena' then
                                 lb_concatena := true;
                              end if;
                           elsif it.tipo_valor = 'numero' and it.total = 1 then
                              lv_coluna_aux := lv_alias_tab_item||'.'||lv_coluna_aux;
                              if c.agrupador = 'menor' then
                                 lv_coluna_aux := ' min('||lv_coluna_aux||') ';
                              elsif c.agrupador = 'maior' then
                                 lv_coluna_aux := ' max('||lv_coluna_aux||') ';
                              elsif c.agrupador = 'semValor' then
                                 lv_coluna_aux := ' min('||lv_coluna_aux||') ';
                              elsif c.agrupador = 'media' then
                                 lv_coluna_aux := ' avg('||lv_coluna_aux||') ';
                              elsif c.agrupador = 'soma' then
                                 lv_coluna_aux := ' sum('||lv_coluna_aux||') ';
                              elsif c.agrupador = 'somaNvlZero' then
                                 lv_coluna_aux := ' nvl(sum('||lv_coluna_aux||'),0) ';
                              elsif c.agrupador = 'contar' then
                                 lv_coluna_aux := ' count(1) ';
                              elsif c.agrupador = 'contarDistinct' then
                                 lv_coluna_aux := ' count( distinct '||lv_coluna_aux||') ';
                              end if;
                              lv_coluna_aux := ' to_char(' || lv_coluna_aux || ','''||lv_formato||''','''||const_nls_numero_sql||''') ';
                           else
                              lv_coluna_aux := ' to_char(' || lv_alias_tab_item||'.'||lv_coluna_aux || ','''||lv_formato||''','''||const_nls_numero_sql||''') ';
                           end if;
                        else
                           lv_coluna_aux := lv_alias_tab_item||'.'||lv_coluna_aux;
                        end if;
                     end if;
                     
                     if it.texto is not null then
                        if instr(it.texto, '{ITEM}')> 1 then
                           lv_p1 := substr(it.texto, 1, instr(it.texto, '{ITEM}')-1);
                        end if;
                        if instr(it.texto, '{ITEM}') + length('{ITEM}') -1 < length(it.texto) then
                           lv_p2 := substr(it.texto, instr(it.texto, '{ITEM}')+length('{ITEM}'));
                        end if;
                        lv_coluna_aux := ''''||lv_p1||'''||'||lv_coluna_aux||'||'''||lv_p2||'''';
                     end if;

                     if it.linha > 1 then
                        lv_coluna := lv_coluna || '||';
                     end if;
                     lv_coluna := lv_coluna || lv_coluna_aux;
                  end loop;
                  
                  if not ( trim(lv_coluna) like 'min(%' or
                           trim(lv_coluna) like 'max(%' or
                           trim(lv_coluna) like 'avg(%' or
                           trim(lv_coluna) like 'count(%' or
                           trim(lv_coluna) like 'sum(%' or
                           trim(lv_coluna) like 'nvl(%' or
                           trim(lv_coluna) like 'to_char(%') then
                     if c.agrupador = 'menor' then
                        lv_coluna := ' min('||lv_coluna||') ';
                     elsif c.agrupador = 'maior' then
                        lv_coluna := ' max('||lv_coluna||') ';
                     elsif c.agrupador = 'semValor' then
                        lv_coluna := ' min('||lv_coluna||') ';
                     elsif c.agrupador = 'contar' then
                        lv_coluna := ' count(1) ';
                        lv_coluna := ' to_char(' || lv_coluna || ','''||const_formato_numero||''','''||const_nls_numero_sql||''') ';
                     elsif c.agrupador = 'contarDistinct' then
                        lv_coluna := ' count( distinct '||lv_coluna||') ';
                        lv_coluna := ' to_char(' || lv_coluna || ','''||const_formato_numero||''','''||const_nls_numero_sql||''') ';
                     end if;
                  end if;
               end if;
                      
            end if;
         end loop;
         
         while instr(lv_where, '[PROP_')>0 loop
            ln_inicio_prop := instr(lv_where, '[PROP_');
            ln_fim_prop := instr(lv_where, ']', ln_inicio_prop);
            
            lv_propriedade_id := substr(lv_where, ln_inicio_prop + length('[PROP_'), ln_fim_prop - (ln_inicio_prop + length('[PROP_')));
            
            lv_where := substr(lv_where, 1, ln_inicio_prop - 1) ||
                        f_get_val_sel_propriedade(pn_demanda_id,
                                                pv_usuario_id,
                                                to_number(lv_propriedade_id),
                                                false,
                                                true, --deve retornar no formato padrao
                                                ln_aux) ||
                        substr(lv_where, ln_fim_prop + 1);

         end loop;
         
         lv_sql := null;

     else
        lv_sql := replace(lv_sql, '[DEMANDA-ID]', pn_demanda_id);         
        lv_sql := replace(lv_sql, '[USUARIO-LOGADO]', ''''||pv_usuario_id||'''');
     end if;

     if lv_sql is null and pb_get_sub_propriedade then
        lv_sql := ' select ' || lv_coluna || ' id '||
                  ' from ' || lv_from;
        if lv_where > ' ' then
           lv_sql := lv_sql || ' where ' || substr(lv_where, 5);
        end if;     
        return '('||lv_sql||')';   
     --Se o agrupador for do tipo lista, salva em tabela temporaria e 
     --retorna o ID da lista
     elsif lv_sql is null and pb_get_update then
        if lv_ultimo_tipo_valor in ('atributo','lancamento') then
           lv_sql := ' select distinct ' || lv_alias_atual_entidade||'.' || lv_coluna_pk_entidade || ' id '||
                     ' from ' || lv_from_entidade;
           if lv_where_entidade > ' ' then
              lv_sql := lv_sql || ' where ' || substr(lv_where_entidade, 5);
           end if;        
        else
           lv_sql := ' select distinct ' || lv_alias_anterior ||'.' || lv_coluna_pk || ' id '||
                     ' from ' || lv_from;
           if lv_where > ' ' then
              lv_sql := lv_sql || ' where ' || substr(lv_where, 5);
           end if;        
        end if;
        
        return lv_sql;
     elsif lb_lista then
        select regras_lista_temp_seq.nextval
        into ln_seq_lista 
        from dual;

        if lv_sql is null then
            lv_sql := ' begin ' ||
                      ' insert into regras_lista_temp ( lista_id, item, valor ) ' ||
                      ' select ' ||ln_seq_lista||', rownum, coluna ' || 
                      ' from (select distinct ' || lv_coluna || ' coluna ' ||
                      ' from ' || lv_from;
            if lv_where > ' ' then
               lv_sql := lv_sql || ' where ' || substr(lv_where, 5);
            end if;
             
            lv_sql := lv_sql || '); end;';
    --        dbms_output.put_line('lv_sql:' || lv_sql);        
            
            for ln_count in 0..50 loop
              if ln_count * 1000 > length(lv_sql) then
                 exit;
               else
                  if (ln_count+1) * 1000 >= length(lv_sql) then
                      dbms_output.put_line(substr(lv_sql,ln_count * 1000));
                  else
                      dbms_output.put_line(substr(lv_sql,ln_count * 1000,999));
                  end if;
               end if;
            end loop;
         else
            ln_aux := instr(upper(lv_sql), 'SELECT');
            lv_sql := ' begin ' ||
                      ' insert into regras_lista_temp ( lista_id, item, valor ) ' ||
                      ' select ' ||ln_seq_lista||', rownum, a.* ' || 
                      ' from (select distinct * ' ||
                      ' from ('||substr(lv_sql,ln_aux)||')) a';
        end if;
        execute immediate lv_sql;        

        select count(*) into ln_count from  regras_lista_temp where lista_id = ln_seq_lista;

        lv_valor := '<REGRAS-LISTA-TEMP>'|| ln_seq_lista || '</REGRAS-LISTA-TEMP>';
        
        return lv_valor;
        
     elsif lb_concatena then
        if lv_sql is null then
           lv_sql := ' select distinct ' || lv_coluna || ' coluna ' ||
                     ' from ' || lv_from;
           if lv_where > ' ' then
              lv_sql := lv_sql || ' where ' || substr(lv_where, 5);
           end if;
        else
           lv_sql := ' select distinct a.* ' ||
                     ' from ('||lv_sql||' ) a ';
        end if;
        
        execute immediate lv_sql;
        
        lv_valor := null;

        open lc_sql for lv_sql;
        
        while true loop
           fetch lc_sql into lv_valor_aux;
           exit when lc_sql%notfound;
           lv_valor := lv_valor || lv_valor_aux;
        end loop;
        close lc_sql;
        return lv_valor;

     else
        if lv_sql is null then
           lv_sql := ' select ' || lv_coluna ||
                     ' from ' || lv_from;
           if lv_where > ' ' then
              lv_sql := lv_sql || ' where ' || substr(lv_where, 5);
           end if;
           lv_sql := lv_sql || ' order by 1';

        end if;           
        
        lv_valor := null;
        --dbms_output.put_line(lv_sql);
        open lc_sql for lv_sql;
        fetch lc_sql into lv_valor;
        close lc_sql;
        return lv_valor;
     end if;

   end;

   function f_get_valor_propriedade ( pn_demanda_id demanda.demanda_id%type,
                                      pv_usuario_id usuario.usuarioid%type,
                                      pn_propriedade_id regras_propriedade.id%type) return varchar2 is
   ln_tipo_entidade_id regras_tipo_entidade.id%type;
   begin
      
      return f_get_val_sel_propriedade ( pn_demanda_id, pv_usuario_id, pn_propriedade_id, false, false, ln_tipo_entidade_id);

   end;   
   
   function f_formata (pn_numero number) return varchar2 is
     lv_retorno varchar2(32000);
     begin
        lv_retorno := to_char(trunc(pn_numero, 10), const_formato_numero, const_nls_numero);
        return lv_retorno;
     end;
   
   function f_get_numero (pv_numero varchar2) return number is
     begin
        return to_number(pv_numero, const_formato_numero, const_nls_numero);
     end;
   
   function f_formata (pd_data date) return varchar2 is
     begin
        return to_char(pd_data, const_formato_data, const_formato_data);
     end;
     
   function f_get_Data (pv_data varchar2) return date is
     begin
        return to_date(pv_data, const_formato_data);
     end;
   
   
     function f_is_dominio_atributo(pn_propriedade number) return number is
       lv_tipo atributo.tipo%type;
       begin
         select nvl(max(an.tipo), max(ai.tipo))
         into lv_tipo
         from atributo an, 
              atributo ai, 
              regras_propriedade_niveis n,
              regras_prop_nivel_item i
         where n.propriedade_id = pn_propriedade
         and   n.id = i.nivel_id
         and   n.atributo_id = an.atributoid (+)
         and   i.atributo_id = ai.atributoid (+)
         and   n.ordem = (select max(ordem)
                          from regras_propriedade_niveis n2
                          where n2.propriedade_id = pn_propriedade);
                          
         if lv_tipo = pck_atributo.Tipo_LISTA then
            return 1;
         elsif lv_tipo = pck_atributo.Tipo_LISTA_MULTIPLA_ESCOLHA then
            return 1;
         end if;
         
         return 0;

       end;   
    -------------------------------------------------------------
    --Salva o log de uma Regra
    function p_salvar_regra_log_hist_trans (pn_historico_id h_demanda.id%type,
                                            pn_transicao_id transicao_estado.transicao_estado_id%type,
                                            pn_id_log_pai number,
                                            pn_id_regra number,
                                            pv_tipo varchar2,
                                            pv_titulo_regra varchar2,
                                            pv_resultado varchar2,
                                            pd_data date,
                                            pv_somente_teste varchar2,
                                            pv_usuario_autorizador varchar2) return number is

        ln_id_log                  number;
    begin
        if pv_tipo = 'OB' or  pv_tipo = 'IN' then
            select log_hist_transicao_seq.nextval into ln_id_log from dual;
            insert into log_hist_transicao(id,historico_id, transicao_id,log_pai_id, tipo, validacao, resultado, data, regra_id, propriedade_id, teste, usuario_autorizador)
            values(ln_id_log,pn_historico_id, pn_transicao_id, pn_id_log_pai, pv_tipo,  pv_titulo_regra, pv_resultado, pd_data, pn_id_regra, null, pv_somente_teste, pv_usuario_autorizador);
        end if;
        return ln_id_log;
    end;
    
    --Salva o Log de uma condição
    function p_salvar_cond_log_hist_trans (pn_historico_id h_demanda.id%type,
                                                pn_transicao_id transicao_estado.transicao_estado_id%type,
                                                pn_log_pai log_hist_transicao.id%type,
                                                pd_data date,
                                                pv_somente_teste varchar2,
                                                pv_usuario_autorizador varchar2) return number is
        ln_id_log                     number;
    begin
        select log_hist_transicao_seq.nextval into ln_id_log from dual; 
            
        insert into log_hist_transicao(id,historico_id, transicao_id,log_pai_id, tipo, validacao, resultado, data, regra_id, propriedade_id, teste, usuario_autorizador)
        values(ln_id_log,pn_historico_id, pn_transicao_id, pn_log_pai, 'CO', null , null, pd_data, null, null, pv_somente_teste, pv_usuario_autorizador);
        return ln_id_log;
    end;

    --Salva o Log de um operando
    function p_salvar_op_log_hist_trans (pn_historico_id h_demanda.id%type,
                                                pn_transicao_id transicao_estado.transicao_estado_id%type,
                                                pn_log_pai log_hist_transicao.id%type,
                                                pv_validacao varchar2,
                                                pv_resultado varchar2,
                                                pn_propriedade number,
                                                pd_data date,
                                                pv_somente_teste varchar2,
                                                pv_usuario_autorizador varchar2) return number is
        ln_id_log                     number;
        ln_seq_lista                  number;
        lv_titulo_dominio             varchar2(1000);
        lv_tipo_dado                  varchar2(1);
        ln_tipo_propriedade           number;        
    begin
          select log_hist_transicao_seq.nextval into ln_id_log from dual; 
          
          if instr(pv_resultado, '<REGRAS-LISTA-TEMP>') > 0 then 
              ln_seq_lista := to_number(substr(pv_resultado, length('<REGRAS-LISTA-TEMP>') + 1, instr(pv_resultado, '</REGRAS-LISTA-TEMP>') -1 -length('<REGRAS-LISTA-TEMP>')));
              --Insere a lista de valores testada, para ser apresentado no log da transição.      
              for rlt_ in (select lista_id, item, valor from regras_lista_temp where lista_id = ln_seq_lista) loop

                if f_is_dominio_atributo(pn_propriedade) = 1 then
                   select titulo into lv_titulo_dominio from dominioatributo where dominioatributoid = f_get_numero(rlt_.valor);
                else
                   lv_titulo_dominio := rlt_.valor;
                end if;
                
                select log_lista_hist_trans_seq.nextval into ln_seq_lista from dual;
                
                insert into LOG_LISTA_HIST_TRANS(id, LISTA_ID, LOG_PAI_ID, ITEM, VALOR, VALOR_TITULO)
                values(ln_seq_lista, rlt_.lista_id, pn_log_pai, rlt_.item, rlt_.valor, lv_titulo_dominio);
              end loop;
              
          end if; 
          lv_tipo_dado := null;
          begin
            select tipo_valor_id into ln_tipo_propriedade from regras_tipo_propriedade where id in(
                  select 
                         case when r.tipo_propriedade_id is null then
                           (select rn.tipo_propriedade_id from regras_prop_nivel_item rn where nivel_id = r.id)
                         else
                           r.tipo_propriedade_id  
                         end  
                  from regras_propriedade_niveis r 
                  where r.propriedade_id = pn_propriedade
                  and r.ordem = (select max(r1.ordem) 
                                 from regras_propriedade_niveis r1 
                                 where r1.propriedade_id = r.propriedade_id));

            
            if ln_tipo_propriedade = 3 then
              lv_tipo_dado := 'D';
            end if;  
          exception
            when OTHERS then
              lv_tipo_dado := null;
          end; 
          --Cria registro dao operando  
          insert into log_hist_transicao(id,historico_id, transicao_id,log_pai_id, tipo, validacao, resultado, data, regra_id, propriedade_id, teste, usuario_autorizador, tipo_dado)
          values(ln_id_log,pn_historico_id, pn_transicao_id, pn_log_pai, 'OP', pv_validacao , pv_resultado, pd_data, null, pn_propriedade, pv_somente_teste, pv_usuario_autorizador, lv_tipo_dado);
          return ln_id_log;
    end;
    
    --Salva o Log de uma função
    function p_salvar_funcao_log_hist_trans (pn_historico_id h_demanda.id%type,
                                              pn_transicao_id transicao_estado.transicao_estado_id%type,
                                              pn_log_pai log_hist_transicao.id%type,
                                              pv_validacao varchar2,
                                              pv_resultado varchar2,
                                              pn_propriedade number,
                                              pd_data date,
                                              pv_somente_teste varchar2,
                                              pv_usuario_autorizador varchar2) return number is
        ln_id_log                     number;
    begin
          select log_hist_transicao_seq.nextval into ln_id_log from dual;

          insert into log_hist_transicao(id,historico_id, transicao_id,log_pai_id, tipo, validacao, resultado, data, regra_id, propriedade_id, teste, usuario_autorizador)
          values(ln_id_log,pn_historico_id, pn_transicao_id, pn_log_pai, 'FU', pv_validacao , pv_resultado, pd_data, null, pn_propriedade, pv_somente_teste, pv_usuario_autorizador);
          return ln_id_log;
    end;

    --Salva o log de uma Ação
    procedure p_salvar_acao_log_hist_trans (pn_historico_id h_demanda.id%type,
                                            pn_transicao_id transicao_estado.transicao_estado_id%type,
                                            pv_titulo_regra varchar2,
                                            pv_resultado varchar2,
                                            pd_data date, 
                                            pv_somente_teste varchar2,
                                            pv_usuario_autorizador varchar2) is

        ln_id_log                  number;
        PRAGMA AUTONOMOUS_TRANSACTION;

    begin
        select log_hist_transicao_seq.nextval into ln_id_log from dual;
        insert into log_hist_transicao(id,historico_id, transicao_id,log_pai_id, tipo, validacao, resultado, data, regra_id, propriedade_id, teste, usuario_autorizador)
        values(ln_id_log,pn_historico_id, pn_transicao_id, null, 'AC',  pv_titulo_regra, pv_resultado, pd_data, null, null, pv_somente_teste, pv_usuario_autorizador);
        commit;
    end;
    
   procedure p_salvar_acao_log_hist_desf (pn_historico_id h_demanda.id%type) is
        ln_id_log                  number;
        PRAGMA AUTONOMOUS_TRANSACTION;

    begin
        update log_hist_transicao set log_hist_transicao.resultado = 'r_ok_desf' 
        where log_hist_transicao.historico_id = pn_historico_id
        and tipo = 'AC' and resultado = 'r_ok';
        commit;
    end;

    --Salvar o log de Validação
    procedure p_salvar_v_log_hist_trans (pn_historico_id h_demanda.id%type,
                                            pn_transicao_id transicao_estado.transicao_estado_id%type,
                                            pv_titulo_regra varchar2,
                                            pv_resultado varchar2,
                                            pd_data date, 
                                            pv_somente_teste varchar2,
                                            pv_usuario_autorizador varchar2) is

        ln_id_log                  number;
        PRAGMA AUTONOMOUS_TRANSACTION;

    begin
        select log_hist_transicao_seq.nextval into ln_id_log from dual;
        insert into log_hist_transicao(id,historico_id, transicao_id,log_pai_id, tipo, validacao, resultado, data, regra_id, propriedade_id, teste, usuario_autorizador)
        values(ln_id_log,pn_historico_id, pn_transicao_id, null, 'VA',  pv_titulo_regra, pv_resultado, pd_data, null, null, pv_somente_teste, pv_usuario_autorizador);
        commit;
    end;

    function p_executa_log_hist_trans (pb_salvar_log_hist_trans boolean,
                                        pn_historico_id h_demanda.id%type,
                                        pn_transicao_id transicao_estado.transicao_estado_id%type,
                                        pn_log_pai log_hist_transicao.id%type,
                                        pv_tipo_regra_hist varchar2,
                                        pd_data date,
                                        pv_validacao varchar2,
                                        pn_id_regra number,
                                        pn_propriedade number,
                                        pv_resultado varchar2,
                                        pv_somente_teste varchar2,
                                        pv_usuario_autorizador varchar2) return number is
    ln_log_hist_pai  number;
    lv_resultado_tmp  varchar2(1000);
                                            
    begin
           lv_resultado_tmp := pv_resultado;        
           if pn_propriedade is not null then
             lv_resultado_tmp := pck_regras.p_formata_valor_prop(pv_resultado, pn_propriedade);
           end if;            
    
           if pb_salvar_log_hist_trans = true then
              if pv_tipo_regra_hist = 'OB' or pv_tipo_regra_hist = 'IN' then 
                  --Cria log da Regra                      
                  ln_log_hist_pai := p_salvar_regra_log_hist_trans(pn_historico_id,
                                                                   pn_transicao_id,
                                                                   pn_log_pai,
                                                                   pn_id_regra,
                                                                   pv_tipo_regra_hist,
                                                                   pv_validacao,
                                                                   null,
                                                                   pd_data,
                                                                   pv_somente_teste,
                                                                   pv_usuario_autorizador);
              elsif pv_tipo_regra_hist = 'C' then
                  --Cria Condição
                   ln_log_hist_pai := p_salvar_cond_log_hist_trans(pn_historico_id,
                                                                       pn_transicao_id,
                                                                       pn_log_pai,
                                                                       pd_data,
                                                                       pv_somente_teste,
                                                                       pv_usuario_autorizador);   
              elsif pv_tipo_regra_hist = 'O' then
                    --Cria Operando
                    ln_log_hist_pai := p_salvar_op_log_hist_trans(pn_historico_id,
                                                                        pn_transicao_id,
                                                                        pn_log_pai,
                                                                        pv_validacao,
                                                                        lv_resultado_tmp,
                                                                        pn_propriedade,
                                                                        pd_data,
                                                                        pv_somente_teste,
                                                                        pv_usuario_autorizador);
                                                                        
              end if;
              return ln_log_hist_pai;
           end if;  
           return null;
    end;
    
    --------Formata um valor de propriedade
    function p_formata_valor_prop (pv_valor varchar2, pn_id_propriedade number) return varchar2 is
    lv_tipo_campo           varchar2(1);
    ld_data                 date;
    lv_ret                  varchar(1000);
    begin
          lv_ret := pv_valor;
          begin
              select tipo into lv_tipo_campo from atributo 
              where atributoid in (select atributo_id from regras_propriedade_niveis r1 
                               where r1.propriedade_id = pn_id_propriedade 
                               and   r1.ordem = (select max(ordem) from regras_propriedade_niveis r2 
                                                 where r2.propriedade_id = r1.propriedade_id));
          
          exception
            when NO_DATA_FOUND then
              lv_tipo_campo := '';
          end;                                       
          if lv_tipo_campo = 'd' then 
            ld_data := pck_regras.f_get_Data(pv_valor);
            lv_ret := to_char(ld_data, 'dd/mm/yyyy');
            
          end if;
    
          return lv_ret;
    end;
    
    -------------------------------------------------------------
   
   
   
   
   
   function f_funcao ( pn_id                       regras_validacao_item.id%type,  
                       pv_codigo_funcao            regras_tipo_funcao.codigo%type,
                       pn_val_1_2                  regras_valid_funcao_item.val_1_2%type,
                       pn_demanda_id               demanda.demanda_id%type, 
                       pv_usuario_id               usuario.usuarioid%type,
                       pb_salvar_log_hist_trans    boolean,
                       pn_historico_id h_demanda.id%type,
                       pn_transicao_id transicao_estado.transicao_estado_id%type,
                       pn_log_pai log_hist_transicao.id%type,
                       pd_data date,
                       pv_somente_teste varchar2,
                       pv_usuario_autorizador varchar2) return varchar2 is
                       
     lv_retorno             varchar2(32000); 
     lv_valor               varchar2(32000);
     ln_retorno             number;
     ln_ret             number;
     ln_id_log_funcao_filha number;     
     lb_par1                boolean:= true;
     lv_titulo              varchar2(1000);
     begin
        lv_titulo := lv_titulo;
        for c in (select i.*, f.codigo codigo_funcao_filha
                  from regras_valid_funcao_item i,
                       regras_propriedade p,
                       regras_tipo_funcao f
                  where ((i.validacao_item_id = pn_id and i.valid_funcao_item_id is null and   i.val_1_2 = pn_val_1_2) or 
                         i.valid_funcao_item_id = pn_id)
                  and   i.propriedade_id = p.id (+)
                  and   i.tipo_funcao_id = f.id(+)
                  order by i.ordem) loop
           
           if c.codigo_funcao_filha is not null then
               ----Início lógica de gravação de log de histórico de transição.
                    if pb_salvar_log_hist_trans = true then
                          lv_titulo := c.codigo_funcao_filha;
                          ln_id_log_funcao_filha := p_salvar_funcao_log_hist_trans(pn_historico_id,
                                                                                   pn_transicao_id,
                                                                                   pn_log_pai,
                                                                                   lv_titulo,
                                                                                   null,
                                                                                   null,
                                                                                   pd_data,
                                                                                   pv_somente_teste,
                                                                                   pv_usuario_autorizador);
                         
                    end if;
              ----Fim lógica de gravação de log de histórico de transição.
              
              lv_valor := f_funcao(c.id, c.codigo_funcao_filha, 1, pn_demanda_id, pv_usuario_id, pb_salvar_log_hist_trans, pn_historico_id,pn_transicao_id, ln_id_log_funcao_filha, pd_data, pv_somente_teste, pv_usuario_autorizador);
              
              ----Início lógica de gravação de log de histórico de transição.
                    if pb_salvar_log_hist_trans = true then
                       update log_hist_transicao set resultado = lv_valor where id = ln_id_log_funcao_filha; 
                    end if;
              ----Fim lógica de gravação de log de histórico de transição.
              
              
              
           elsif c.propriedade_id is not null then
              lv_valor := f_get_valor_propriedade(pn_demanda_id,pv_usuario_id, c.propriedade_id);
              
              ----Início lógica de gravação de log de histórico de transição.
                    if pb_salvar_log_hist_trans = true then
                          select regras_propriedade.titulo into lv_titulo from regras_propriedade where regras_propriedade.id = c.propriedade_id;
                          ln_ret := p_salvar_op_log_hist_trans(pn_historico_id,
                                                         pn_transicao_id,
                                                         pn_log_pai,
                                                         lv_titulo,
                                                         lv_valor,
                                                         c.propriedade_id,
                                                         pd_data,
                                                         pv_somente_teste,
                                                         pv_usuario_autorizador);
                         
                    end if;
              ----Fim lógica de gravação de log de histórico de transição.
              
           else
              lv_valor := c.valor;
               ----Início lógica de gravação de log de histórico de transição.
                    if pb_salvar_log_hist_trans = true then
                          lv_titulo := 'Constante';
                          ln_ret := p_salvar_op_log_hist_trans(pn_historico_id,
                                                         pn_transicao_id,
                                                         pn_log_pai,
                                                         lv_titulo,
                                                         lv_valor,
                                                         c.propriedade_id,
                                                         pd_data,
                                                         pv_somente_teste,
                                                         pv_usuario_autorizador);
                         
                    end if;
              ----Fim lógica de gravação de log de histórico de transição.
              
           end if; 
           
           if lb_par1 then
              if pv_codigo_funcao in ('soma','multiplicacao', 'subtracao') then
                 ln_retorno := f_get_numero(lv_valor);
              else
                 lv_retorno := lv_valor;
              end if;
           else
              if pv_codigo_funcao = 'soma' then
                 ln_retorno := ln_retorno + f_get_numero(lv_valor);

              elsif pv_codigo_funcao = 'subtracao' then
                 ln_retorno := ln_retorno - f_get_numero(lv_valor);
              elsif pv_codigo_funcao = 'multiplicacao' then
                 ln_retorno := ln_retorno * f_get_numero(lv_valor);
              elsif pv_codigo_funcao = 'minimo' then
                 if lv_valor < lv_retorno then
                    lv_retorno := lv_valor;
                 end if;
              elsif pv_codigo_funcao = 'maximo' then
                 if lv_valor > lv_retorno or lv_retorno is null then
                    lv_retorno := lv_valor;
                 end if;
              elsif pv_codigo_funcao = 'concatena' then
                 lv_retorno := lv_retorno || lv_valor;
              elsif pv_codigo_funcao = 'contar' then
                 ln_retorno := ln_retorno + 1;
              elsif pv_codigo_funcao = 'diasEntre' then
                 lv_retorno := f_formata(f_get_data(lv_valor) - f_get_data(lv_retorno));
              elsif pv_codigo_funcao = 'mesesEntre' then
                 lv_retorno := f_formata(months_between(f_get_data(lv_valor),f_get_data(lv_retorno)));
              end if;
           end if;
           lb_par1 := false;
        end loop;
       if ln_retorno is not null then
          return f_formata(ln_retorno);
       else
          return lv_retorno;
       end if;
       return '';
     end;
   
   function f_teste_validacao ( pn_demanda_id   demanda.demanda_id%type,
                                pn_validacao_id regras_validacao.id%type,
                                pv_usuario_id   usuario.usuarioid%type,
                                pb_salvar_log_hist_trans boolean,
                                pn_transicao_id transicao_estado.transicao_estado_id%type,
                                pn_log_pai      log_hist_transicao.id%type,
                                pv_tipo_regra_hist varchar2,                
                                pd_data_hist date,
                                pv_somente_teste varchar2,
                                pv_usuario_autorizador varchar2) return boolean is
     type tb_result is table of boolean index by binary_integer;
     lb_result tb_result;
     lb_result_item boolean;
     lv_valor_1 varchar2(32000);
     lv_valor_2 varchar2(32000);
     lv_valor   varchar2(32000);
     lv_sql_1   varchar2(32000);
     lv_sql_2   varchar2(32000);
     lv_sql     varchar2(32000);
     ln_seq_lista_1 number;
     ln_seq_lista_2 number;
     ln_cont_true number:=0;
     lv_operador_ligacao regras_validacao.operador_ligacao%type;
     type t_sql is ref cursor;
     lc_sql t_sql;
     ln_log_hist_pai              number;
     ln_log_hist_condicao         number;     
     ln_log_hist_operando         number;
     ln_historico                 number;
     lv_titulo_regra_valid        varchar2(1000);
     lv_resultado                 varchar2(1000);
     lv_return                    boolean;     
     lv_resultado_cod             varchar2(1000);     
     lv_operando_1                varchar2(5000);
     lv_operando_2                varchar2(5000);     
     lv_validacao                 varchar2(32000);    
     ln_seq_lista                 number; 
     begin
        select max(id) into ln_historico from h_demanda where h_demanda.demanda_id = pn_demanda_id;
        select titulo into lv_titulo_regra_valid from regras_validacao where id = pn_validacao_id;
                                        
        ln_log_hist_pai := p_executa_log_hist_trans(pb_salvar_log_hist_trans,
                                                    ln_historico, 
                                                    pn_transicao_id, 
                                                    pn_log_pai, 
                                                    pv_tipo_regra_hist, 
                                                    pd_data_hist,
                                                    lv_titulo_regra_valid,
                                                    pn_validacao_id,
                                                    null,
                                                    null,
                                                    pv_somente_teste,
                                                    pv_usuario_autorizador);
           
        for c in (select v.operador_ligacao, 
                         i.*,
                         f1.codigo f1_codigo,
                         f2.codigo f2_codigo,
                         v.vigente,
                         v.titulo,
                         v.id id_regra_validacao,
                         o.codigo operador,
                         row_number () over(order by i.ordem) item
                  from regras_validacao v,
                       regras_validacao_item i,
                       regras_tipo_operador o,
                       regras_tipo_funcao f1,
                       regras_tipo_funcao f2
                  where v.id = pn_validacao_id
                  and   v.id = i.validacao_id
                  and   i.tipo_operador_id = o.id (+)
                  and   i.tipo_funcao_id_1 = f1.id (+)
                  and   i.tipo_funcao_id_2 = f2.id (+)
                  order by i.ordem) loop

           lv_operador_ligacao := c.operador_ligacao;            
           lb_result_item := false;
           
           if c.vigente <> 'N' then
                      ln_log_hist_condicao := p_executa_log_hist_trans(pb_salvar_log_hist_trans,
                                                                        ln_historico, 
                                                                        pn_transicao_id, 
                                                                        ln_log_hist_pai,--pai 
                                                                        'C', 
                                                                        pd_data_hist,
                                                                        null,null,null,null,
                                                                        pv_somente_teste,
                                                                        pv_usuario_autorizador);
            end if;                                                            
        
           --outra validacao
           if c.vigente = 'N' then
              lb_result_item := true;
              lb_result(c.item) := lb_result_item;
           elsif c.tipo = 'V' then
              lb_result_item := f_teste_validacao ( pn_demanda_id, c.ref_validacao_id, pv_usuario_id, pb_salvar_log_hist_trans, pn_transicao_id, ln_log_hist_condicao, 'O', pd_data_hist, pv_somente_teste, pv_usuario_autorizador);
              lb_result(c.item) := lb_result_item;
           else
              lv_operando_1 := null;
              lv_operando_2 := null;
              lv_valor_1 := null;
              lv_valor_2 := null;
              
              if c.f1_codigo is not null then
                  lv_operando_1 := c.f1_codigo;
                  ln_log_hist_operando := p_executa_log_hist_trans(pb_salvar_log_hist_trans,
                                                    ln_historico, 
                                                    pn_transicao_id, 
                                                    ln_log_hist_condicao,--pai 
                                                    'O',  
                                                    pd_data_hist,
                                                    lv_operando_1,
                                                    null,null,null,
                                                    pv_somente_teste,
                                                    pv_usuario_autorizador);
                 
              
             
              
              
                 lv_valor_1 := f_funcao(c.id, c.f1_codigo, 1, pn_demanda_id, pv_usuario_id, pb_salvar_log_hist_trans, 
                                        ln_historico,pn_transicao_id, ln_log_hist_operando, pd_data_hist, pv_somente_teste, pv_usuario_autorizador);
                 
                 ----Início lógica de gravação de log de histórico de transição.
                 if pb_salvar_log_hist_trans = true then
                       if c.vigente = 'Y' then
                          update log_hist_transicao set resultado = lv_valor_1 where id = ln_log_hist_operando;
                       end if;
                 end if;
                 ----Fim lógica de gravação de log de histórico de transição.
              elsif c.propriedade_id_1 is not null then
                 lv_valor_1 := f_get_valor_propriedade (pn_demanda_id, pv_usuario_id, c.propriedade_id_1 );
                 
                 ln_seq_lista := to_number(substr(lv_valor_1, length('<REGRAS-LISTA-TEMP>') + 1, instr(lv_valor_1, '</REGRAS-LISTA-TEMP>') -1 -length('<REGRAS-LISTA-TEMP>')));
                 
                 select regras_propriedade.titulo into lv_operando_1 from regras_propriedade where regras_propriedade.id = c.propriedade_id_1;
                 ln_log_hist_operando := p_executa_log_hist_trans(pb_salvar_log_hist_trans,
                                                                  ln_historico, 
                                                                  pn_transicao_id, 
                                                                  ln_log_hist_condicao,--pai 
                                                                  'O', 
                                                                  pd_data_hist,
                                                                  lv_operando_1,
                                                                  null,
                                                                  c.propriedade_id_1,
                                                                  lv_valor_1,
                                                                  pv_somente_teste,
                                                                  pv_usuario_autorizador);
              else
                 lv_valor_1 := c.valor_1;
                 lv_operando_1 := 'label.prompt.constante';
                 ln_log_hist_operando := p_executa_log_hist_trans(pb_salvar_log_hist_trans,
                                                                  ln_historico, 
                                                                  pn_transicao_id, 
                                                                  ln_log_hist_condicao, 
                                                                  'O', 
                                                                  pd_data_hist,
                                                                  lv_operando_1,
                                                                  null,
                                                                  null,
                                                                  lv_valor_1,
                                                                  pv_somente_teste,
                                                                  pv_usuario_autorizador);
 
              end if;
              
              if c.f2_codigo is not null then
                  lv_operando_2 := c.f2_codigo;
                  ln_log_hist_operando := p_executa_log_hist_trans(pb_salvar_log_hist_trans,
                                                    ln_historico, 
                                                    pn_transicao_id, 
                                                    ln_log_hist_condicao,--pai 
                                                    'O',  
                                                    pd_data_hist,
                                                    lv_operando_2,
                                                    null,null,null,
                                                    pv_somente_teste,
                                                    pv_usuario_autorizador);
                                                    
                 lv_valor_2 := f_funcao (c.id, c.f2_codigo, 2, pn_demanda_id, pv_usuario_id,
                                pb_salvar_log_hist_trans, ln_historico,pn_transicao_id, ln_log_hist_operando, pd_data_hist, pv_somente_teste, pv_usuario_autorizador);
                 ----Início lógica de gravação de log de histórico de transição.
                 if pb_salvar_log_hist_trans = true then
                       if c.vigente = 'Y' then
                          update log_hist_transicao set resultado = lv_valor_2 where id = ln_log_hist_operando;
                       end if;
                 end if;
                 ----Fim lógica de gravação de log de histórico de transição.
              elsif c.propriedade_id_2 is not null then
                 lv_valor_2 := f_get_valor_propriedade ( pn_demanda_id, pv_usuario_id, c.propriedade_id_2 );
                 select regras_propriedade.titulo into lv_operando_2 from regras_propriedade where regras_propriedade.id = c.propriedade_id_2;
                 ln_log_hist_operando := p_executa_log_hist_trans(pb_salvar_log_hist_trans,
                                                                  ln_historico, 
                                                                  pn_transicao_id, 
                                                                  ln_log_hist_condicao,--pai 
                                                                  'O', 
                                                                  pd_data_hist,
                                                                  lv_operando_2,
                                                                  null,
                                                                  c.propriedade_id_2,
                                                                  lv_valor_2,
                                                                  pv_somente_teste,
                                                                  pv_usuario_autorizador);
              elsif (c.tipo_operando_2 <> 'S') then
                 lv_valor_2 := c.valor_2;
                 
                 
                 lv_operando_2 := 'Constante';
                 ln_log_hist_operando := p_executa_log_hist_trans(pb_salvar_log_hist_trans,
                                                                  ln_historico, 
                                                                  pn_transicao_id, 
                                                                  ln_log_hist_condicao, 
                                                                  'O', 
                                                                  pd_data_hist,
                                                                  lv_operando_2,
                                                                  null,
                                                                  null,
                                                                  lv_valor_2,
                                                                  pv_somente_teste,
                                                                  pv_usuario_autorizador);
              end if;
              
              if (instr(lv_valor_1, '<REGRAS-LISTA-TEMP>') > 0 and instr(lv_valor_1, '</REGRAS-LISTA-TEMP>') > 0)  or
                 (instr(lv_valor_2, '<REGRAS-LISTA-TEMP>') > 0 and instr(lv_valor_2, '</REGRAS-LISTA-TEMP>') > 0) then
                 
                 if instr(lv_valor_1, '<REGRAS-LISTA-TEMP>') > 0 and instr(lv_valor_1, '</REGRAS-LISTA-TEMP>') > 0 then
                    ln_seq_lista_1 := to_number(substr(lv_valor_1, length('<REGRAS-LISTA-TEMP>') + 1, instr(lv_valor_1, '</REGRAS-LISTA-TEMP>') -1 -length('<REGRAS-LISTA-TEMP>')));
                    lv_sql_1 := 'select valor from regras_lista_temp where lista_id = '||ln_seq_lista_1;
                 else
                    if lv_valor_1 is null then
                       lv_sql_1 := 'select null valor from dual where rownum < 1'; --nenhuma linha
                    else
                       lv_sql_1 := 'select '''|| lv_valor_1 ||''' valor from dual';
                    end if;
                 end if;

                 if instr(lv_valor_2, '<REGRAS-LISTA-TEMP>') > 0 and instr(lv_valor_2, '</REGRAS-LISTA-TEMP>') > 0 then
                    ln_seq_lista_2 := to_number(substr(lv_valor_2, length('<REGRAS-LISTA-TEMP>') + 1, instr(lv_valor_2, '</REGRAS-LISTA-TEMP>') -1 -length('<REGRAS-LISTA-TEMP>')));
                    lv_sql_2 := 'select valor from regras_lista_temp where lista_id = '||ln_seq_lista_2;
                 else
                    if lv_valor_2 is null then
                       lv_sql_2 := 'select null valor from dual where rownum < 1'; --nenhuma linha
                    else
                       lv_sql_2 := 'select '''|| lv_valor_2 ||''' valor from dual';
                    end if;
                 end if;
                 
                 if c.operador = 'pertence' then
                    lv_sql :=  ' select distinct ''achou'' from '||
                               '((' || lv_sql_1 ||') minus (' || lv_sql_2  || '))';
                    lv_valor := null;
                    open lc_sql for lv_sql;
                    fetch lc_sql into lv_valor;
                    close lc_sql;
                     
                    if lv_valor = 'achou' then
                       lb_result_item := false;
                    else
                       lb_result_item := true;
                    end if;
                 elsif c.operador = 'naoPertence' then
                    lv_sql :=  ' select distinct ''achou'' from '||
                               '((' || lv_sql_1 ||') minus (' || lv_sql_2  || '))';
                    lv_valor := null;
                    open lc_sql for lv_sql;
                    fetch lc_sql into lv_valor;
                    close lc_sql;
                    if lv_valor = 'achou' then
                       lb_result_item := true;
                    else
                       lb_result_item := false;
                    end if;
                 elsif c.operador = 'contem' then
                    lv_sql :=  ' select distinct ''achou'' from '||
                               '((' || lv_sql_2 ||') minus (' || lv_sql_1  || '))';
                    lv_valor := null;
                    open lc_sql for lv_sql;
                    fetch lc_sql into lv_valor;
                    close lc_sql; 
                    if lv_valor = 'achou' then
                       lb_result_item := false;
                    else
                       lb_result_item := true;
                    end if;
                 elsif c.operador = 'naoContem' then
                    lv_sql :=  ' select distinct ''achou'' from '||
                               '((' || lv_sql_2 ||') minus (' || lv_sql_1  || '))';
                    lv_valor := null;
                    open lc_sql for lv_sql;
                    fetch lc_sql into lv_valor;
                    close lc_sql; 
                    if lv_valor = 'achou' then
                       lb_result_item := true;
                    else
                       lb_result_item := false;
                    end if;
                 elsif c.operador = 'algumElemento' then
                    lv_sql :=  ' select distinct ''achou'' from '||
                               '((' || lv_sql_1 ||') intersect (' || lv_sql_2  || '))';
                    lv_valor := null;
                    open lc_sql for lv_sql;
                    fetch lc_sql into lv_valor;
                    close lc_sql; 
                    if lv_valor = 'achou' then
                       lb_result_item := true;
                    else
                       lb_result_item := false;
                    end if;
                 elsif c.operador = 'nenhumElemento' then
                    lv_sql :=  ' select distinct ''achou'' from '||
                               '((' || lv_sql_1 ||') intersect (' || lv_sql_2  || '))';
                    lv_valor := null;
                    open lc_sql for lv_sql;
                    fetch lc_sql into lv_valor;
                    close lc_sql; 
                    if lv_valor = 'achou' then
                       lb_result_item := false;
                    else
                       lb_result_item := true;
                    end if;
                    
                 elsif c.operador = '=' then
                    lv_sql :=  ' select distinct ''achou'' from '||
                               '((' || lv_sql_1 ||') minus (' || lv_sql_2  || ')'||
                               ' union ' ||
                               '(' || lv_sql_2 ||') minus (' || lv_sql_1  || '))';
                    lv_valor := null;
                    open lc_sql for lv_sql;
                    fetch lc_sql into lv_valor;
                    close lc_sql; 
                    if lv_valor = 'achou' then
                       lb_result_item := false;
                    else
                       lb_result_item := true;
                    end if;
                    
                 elsif c.operador = 'vazia' then
                    lv_sql :=  ' select distinct ''achou'' from '||
                               '(' || lv_sql_1 ||')';
                    lv_valor := null;
                    open lc_sql for lv_sql;
                    fetch lc_sql into lv_valor;
                    close lc_sql; 
                    if lv_valor = 'achou' then
                       lb_result_item := false;
                    else
                       lb_result_item := true;
                    end if;
                    
                 elsif c.operador = 'umOuMais' then
                    lv_sql :=  ' select distinct ''achou'' from '||
                               '(' || lv_sql_1 ||')';
                    lv_valor := null;
                    open lc_sql for lv_sql;
                    fetch lc_sql into lv_valor;
                    close lc_sql; 
                    if lv_valor = 'achou' then
                       lb_result_item := true;
                    else
                       lb_result_item := false;
                    end if;
                    
                 elsif c.operador = 'maisQueUm' then
                    lv_sql :=  ' select distinct ''achou'' from '||
                               '((' || lv_sql_1 ||') t1, ' ||
                               '((' || lv_sql_1 ||') t2) ' ||
                               ' where t1.valor <> t2.valor ';
                    lv_valor := null;
                    open lc_sql for lv_sql;
                    fetch lc_sql into lv_valor;
                    close lc_sql; 
                    if lv_valor = 'achou' then
                       lb_result_item := true;
                    else
                       lb_result_item := false;
                    end if;
                    
                 end if;
              else
                 if c.operador = '>' then
                    lb_result_item := lv_valor_1 > lv_valor_2;
                 elsif c.operador = '>=' then
                    lb_result_item := lv_valor_1 >= lv_valor_2;
                 elsif c.operador = '<' then
                    lb_result_item := lv_valor_1 < lv_valor_2;
                 elsif c.operador = '<=' then
                    lb_result_item := lv_valor_1 <= lv_valor_2;
                 elsif c.operador = '=' then
                    lb_result_item := lv_valor_1 = lv_valor_2;
                 elsif c.operador = '<>' then
                    lb_result_item := lv_valor_1 <> lv_valor_2;
                 elsif c.operador = 'pertence' then
                    lb_result_item := instr(lv_valor_2, lv_valor_1) > 0;
                 elsif c.operador = 'contem' then
                    lb_result_item := instr(lv_valor_2, lv_valor_1) > 0;
                 elsif c.operador = 'naoPertence' then
                    lb_result_item := instr(lv_valor_2, lv_valor_1) > 0;
                 elsif c.operador = 'naoContem' then
                    lb_result_item := instr(lv_valor_2, lv_valor_1) > 0;
                 elsif c.operador = 'vazio' or c.operador = 'vazia' then
                    lb_result_item := trim(lv_valor_1) is null;
                 elsif c.operador = 'preenchido' then
                    lb_result_item := trim(lv_valor_1) is not null;
                 else
                    lb_result_item := false;
                 end if;
              end if;
              
             /* if c.operador_ligacao = 'E' and not lb_result_item then
                 return false;
              elsif c.operador_ligacao = 'O' and lb_result_item then
                 return true;
              elsif c.operador_ligacao = 'X' and ln_cont_true > 1 then
                 return false;
              end if;*/
              
              lb_result(c.item) := lb_result_item;
                             
           end if;
           
            if lb_result_item then
               ln_cont_true := ln_cont_true + 1;
            end if;
            ----Início lógica de gravação de log de histórico de transição.
                     if pb_salvar_log_hist_trans = true then
                       if c.vigente = 'Y' then
                       
                         if lb_result_item = true then
                           lv_resultado := 'true';
                         else
                           lv_resultado := 'false';  
                         end if;   
                       
                         lv_validacao := 'Condição('|| ln_cont_true ||') ' || lv_operando_1 || '(' || c.operador || ')' || lv_operando_2;
                         update log_hist_transicao set validacao = lv_validacao, resultado = lv_resultado where log_hist_transicao.id = ln_log_hist_condicao;

                         lv_resultado := '';  
                         
                       end if;
                     end if;
            ----Fim lógica de gravação de log de histórico de transição.
        
        end loop;

        lv_return := false;
        if lv_operador_ligacao is null then
           lv_return := false;
        elsif lv_operador_ligacao = 'E' then
           if ln_cont_true = lb_result.count then
              lv_return := true;
           else 
              lv_return := false;
           end if;
        elsif lv_operador_ligacao = 'O' then
           if ln_cont_true > 0 then
              lv_return := true;
           else 
              lv_return := false;
           end if;
        elsif lv_operador_ligacao = 'X' then
           if ln_cont_true = 1 then
              lv_return := true;
           else 
              lv_return := false;
           end if;
        end if;
        
        lv_resultado := 'nok';
        if lv_return then 
                lv_resultado := 'ok';
        end if;        
        ----Início lógica de gravação de log de histórico de transição.
        if pb_salvar_log_hist_trans = true then
            --Ajuste do resultado.
            update log_hist_transicao set resultado = lv_resultado where id = ln_log_hist_pai;
        end if;
        ----Fim lógica de gravação de log de histórico de transição.
        
        return lv_return;
     end; 
     
   procedure p_copia_propriedade ( pn_demanda_id demanda.demanda_id%type,
                                   pv_usuario_id usuario.usuarioid%type,
                                   pn_propriedade_id_origem regras_propriedade.id%type,
                                   pv_valor_origem varchar2,
                                   pn_propriedade_id_destino regras_propriedade.id%type,
                                   pb_append boolean,
                                   pn_tipo_lanc_dest number,
                                   pn_msg_erro_lanc out varchar2) is
   lv_valor_origem                 varchar2(32000);
   lv_sql_destino                  varchar2(32000);
   lv_sql_valores                  varchar2(32000);
   ln_tipo_propriedade_id          regras_tipo_propriedade.id%type;
   ln_tipo_entidade_id             regras_tipo_entidade.id%type;
   ln_atributo_id                  atributo.atributoid%type;
   ln_lista_id                     regras_lista_temp.lista_id%type;
   ln_cont_lista                   number;
   lv_valor_atualizar              varchar2(32000);
   lv_sql                          varchar2(32000);
   lv_sql_lancamentos              varchar2(32000);
   lv_delete_valor                 varchar2(32000);
   lv_insert_valor                 varchar2(32000);
   lv_update_valor                 varchar2(32000);
   lv_escopo                       regras_tipo_escopo.codigo%type;
   lv_coluna_insert                varchar2(50);
   type t_sql is ref cursor;
   lc_sql     t_sql;
   lc_valores t_sql;
   lc_lancamentos t_sql;
   ln_id                           number;
   rec_tipo_entidade               regras_tipo_entidade%rowtype;
   rec_lancamento                  custo_lancamento%rowtype;
   ln_total                        number;
   ln_linha                        number;
   lv_lista_lancamentos            varchar2(32000);
   lv_lista_valores                varchar2(32000);
   lb_primeiro_lancamento          boolean;
   ln_custo_entidade_id            number:= -1;
   ln_custo_entidade_id_novo       number:= -1;
   ln_custo_lancamento_id_novo     number:= -1;
   lv_tipo_atributo                atributo.tipo%type;
   lv_formato_lista                atributo.formato_lista%type;
   lv_nome_tabela                  varchar2(1000);   
   ln_tipo_lanc_dest               number;
   lv_tipo_lanc                    varchar2(1);
   lv_tipo_ent_cust                varchar2(1);
   ln_aev_seq                      number; 
   ln_atr_obrig                    number;
   ln_entidade                     number;    
   lv_atr_valor                    varchar2(32000); 
   ld_atr_valordata                date;
   ln_atr_valornumerico            number;
   ln_atr_dominio                  number;
   lv_atr_valor_html               clob;
   ln_atr_categoria                number;
   lv_valor_unitario               varchar2(100);
   lv_quantidade                   varchar2(100);
   lv_descricao                    custo_lancamento.descricao%type;
   
   
   begin
      ln_tipo_lanc_dest := pn_tipo_lanc_dest;
      
      if pn_propriedade_id_origem is not null then
         lv_valor_origem := f_get_valor_propriedade(pn_demanda_id, pv_usuario_id, pn_propriedade_id_origem);
      else
         lv_valor_origem := pv_valor_origem;
      end if;
      if pn_propriedade_id_destino is not null then
         lv_sql_destino := f_get_val_sel_propriedade(pn_demanda_id, pv_usuario_id, pn_propriedade_id_destino, true, false, ln_tipo_entidade_id);
      else
         lv_sql_destino := f_get_val_sel_propriedade(pn_demanda_id, pv_usuario_id, pn_propriedade_id_origem, true, false, ln_tipo_entidade_id);
      end if;
      
      if pn_propriedade_id_destino is not null then
        
        select tipo_propriedade_id, atributo_id
        into ln_tipo_propriedade_id, ln_atributo_id
        from regras_propriedade_niveis n
        where n.propriedade_id = pn_propriedade_id_destino
        and   ordem = (select max(ordem)
                       from regras_propriedade_niveis n2
                       where n2.propriedade_id = n.propriedade_id);   
               
      
        select e.codigo
        into lv_escopo 
        from regras_propriedade p, regras_tipo_escopo e
        where p.id = pn_propriedade_id_destino
        and   p.escopo_id = e.id;
      else 
        
        select tipo_propriedade_id, atributo_id
        into ln_tipo_propriedade_id, ln_atributo_id
        from regras_propriedade_niveis n
        where n.propriedade_id = pn_propriedade_id_origem
        and   ordem = (select max(ordem)
                       from regras_propriedade_niveis n2
                       where n2.propriedade_id = n.propriedade_id); 

        select e.codigo
        into lv_escopo 
        from regras_propriedade p, regras_tipo_escopo e
        where p.id = pn_propriedade_id_origem
        and   p.escopo_id = e.id;
        
      end if;  
      
      select *
      into rec_tipo_entidade
      from regras_tipo_entidade
      where id = ln_tipo_entidade_id;
      
      if lv_escopo not in ('demandaCorrente','demandasFilhas','demandasIrmas',
                           'projetosAssociados','usuarioLogado','demandasProjetosAssociados',
                           'demandasIrmasMaisCorrente','demandasProjetosAssociadosMaisCorrente') then
         raise_application_error(-20001, 'Escopo nao permitido para atualizacao.');
      end if;
      
      if ln_atributo_id > 0 then
         select a.tipo, a.formato_lista
         into lv_tipo_atributo, lv_formato_lista
         from atributo a
         where a.atributoid = ln_atributo_id;
      end if;
      
      --Loop roda apenas uma vez
      for c in (select e.nome_tabela,
                       t.coluna, tv.codigo tipo_valor, pkv.codigo tipo_valor_pk
                from regras_tipo_propriedade t,
                     regras_tipo_entidade e,
                     regras_tipo_entidade er,
                     regras_tipo_propriedade pk,
                     regras_tipo_valor tv,
                     regras_tipo_valor pkv
                where t.id = ln_tipo_propriedade_id
                and   t.tipo_entidade_id = e.id
                and   t.ref_tipo_entidade_id = er.id (+)
                and   er.id = pk.tipo_entidade_id (+)
                and   'Y' = pk.chave (+)
                and   t.tipo_valor_id = tv.id
                and   pk.tipo_valor_id = pkv.id (+)) loop
                
         lv_nome_tabela := c.nome_tabela;
                
         if instr(lv_valor_origem, '<REGRAS-LISTA-TEMP>') > 0 and instr(lv_valor_origem, '</REGRAS-LISTA-TEMP>') > 0 then
            ln_lista_id := to_number(substr(lv_valor_origem, length('<REGRAS-LISTA-TEMP>') + 1, instr(lv_valor_origem, '</REGRAS-LISTA-TEMP>') -1 -length('<REGRAS-LISTA-TEMP>')));
         
            select count(1)
            into ln_cont_lista
            from regras_lista_temp t
            where t.lista_id = ln_lista_id;
            
            if ln_cont_lista > 1 and c.coluna is not null then
               raise_application_error(-20001, 'Nao e possivel atualizar uma coluna a partir de uma lista com mais de um elemento');
            end if;
            
            if ln_cont_lista > 0 then
               lv_sql_valores := 'select valor, '||
                                 ' COUNT(*) OVER () total, '||
                                 ' row_number() over (order by 1) linha '||
                                 ' from regras_lista_temp where lista_id = '||ln_lista_id;
            else
               lv_sql_valores := 'select null valor, '||
                                 ' COUNT(*) OVER () total, '||
                                 ' row_number() over (order by 1) linha '||
                                 ' from dual';
            end if;
         else
            lv_sql_valores := 'select '''||lv_valor_origem||''' valor, '||
                                 ' COUNT(*) OVER () total, '||
                                 ' row_number() over (order by 1) linha '||
                                 ' from dual';
         end if;
         
         lv_lista_valores := '-1';
         open lc_valores for lv_sql_valores;
         while true loop
            fetch lc_valores into lv_valor_origem, ln_total, ln_linha;
            exit when lc_valores%notfound;
         
             if c.tipo_valor in ('atributo') then

                if lv_valor_origem is null then
                   lv_valor_atualizar := ' null ';
                elsif lv_tipo_atributo in (pck_atributo.Tipo_DATA) then
                   lv_valor_atualizar := ' pck_regras.f_get_data('''|| lv_valor_origem ||''') ';
                   
                elsif lv_tipo_atributo in (pck_atributo.Tipo_NUMERO, pck_atributo.Tipo_MONETARIO,
                                          pck_atributo.Tipo_HORA) then
                   lv_valor_atualizar := ' pck_regras.f_get_numero('''|| lv_valor_origem ||''') ';
                   
                elsif lv_tipo_atributo in (pck_atributo.Tipo_LISTA, pck_atributo.Tipo_LISTA_MULTIPLA_ESCOLHA,
                                          pck_atributo.Tipo_ARVORE) then
                   lv_valor_atualizar := ' pck_regras.f_get_numero('''|| lv_valor_origem ||''') ';
                   
                else
                   lv_valor_atualizar := ' '''|| lv_valor_origem ||''' ';
                end if;
                
                if c.nome_tabela = 'DEMANDA' then
                  lv_nome_tabela := 'ATRIBUTO_VALOR';
                else 
                  lv_nome_tabela := 'ATRIBUTOENTIDADEVALOR';  
                end if;

                if lv_nome_tabela in ('ATRIBUTO_VALOR', 'ATRIBUTOENTIDADEVALOR') then
     
                   if lv_tipo_atributo in (pck_atributo.Tipo_DATA) then
                      lv_coluna_insert := ' valordata ';

                   elsif lv_tipo_atributo in (pck_atributo.Tipo_NUMERO, pck_atributo.Tipo_MONETARIO,
                                            pck_atributo.Tipo_HORA) then
                      lv_coluna_insert := ' valornumerico ';
                     
                   elsif lv_tipo_atributo in (pck_atributo.Tipo_LISTA, pck_atributo.Tipo_LISTA_MULTIPLA_ESCOLHA) then
                      lv_coluna_insert := ' dominio_atributo_id ';
     
                   elsif lv_tipo_atributo in (pck_atributo.Tipo_ARVORE) then
                      lv_coluna_insert := ' categoria_item_atributo_id ';
     
                   elsif lv_tipo_atributo in (pck_atributo.Tipo_TEXTO_HTML) then
                      lv_coluna_insert := ' valor_html ';

                   else
                      lv_coluna_insert := ' valor ';
                   end if;
                   
                   open lc_sql for lv_sql_destino;
                   
                   while true loop
                      fetch lc_sql into ln_id;
                      exit when lc_sql%notfound;
                      
                       if lv_tipo_atributo in (pck_atributo.Tipo_LISTA, pck_atributo.Tipo_LISTA_MULTIPLA_ESCOLHA,pck_atributo.Tipo_ARVORE) then
         
                          if not pb_append then
                             if lv_nome_tabela = 'ATRIBUTO_VALOR' then
                                 lv_delete_valor := ' begin '||
                                                    ' delete ATRIBUTO_VALOR ' ||
                                                    ' where demanda_id = ' || ln_id || 
                                                    ' and   atributo_id = '|| ln_atributo_id || 
                                                    ' and ' ||lv_coluna_insert ||' not in (' || lv_lista_valores ||');' ||
                                                    ' end; ';
                             elsif lv_nome_tabela = 'ATRIBUTOENTIDADEVALOR' then
                                 lv_delete_valor := ' begin '||
                                                    ' delete ATRIBUTOENTIDADEVALOR '||
                                                    ' where identidade = ' || ln_id || 
                                                    ' and   atributoid = '|| ln_atributo_id || 
                                                    ' and ' ||lv_coluna_insert ||' not in (' || lv_lista_valores || ') ' ||
                                                    ' and   tipoentidade = '''||rec_tipo_entidade.tipo_entidade || ''';' ||
                                                    ' end; ';
                             end if;
                             execute immediate lv_delete_valor;
                          end if;

                          if lv_nome_tabela = 'ATRIBUTO_VALOR' then
                              lv_insert_valor := ' insert into atributo_valor (atributo_valor_id, '||
                                                                              ' demanda_id, '||
                                                                              ' atributo_id, '||
                                                                              ' date_update, '||
                                                                              ' user_update, '||
                                                                              lv_coluna_insert ||' ) '||
                                                 ' select atributo_valor_seq.nextval, '||
                                                 ' '|| ln_id ||', '||
                                                 ' '|| ln_atributo_id || ', '||
                                                 '     sysdate, '||
                                                 ' '''||pv_usuario_id ||''', '||
                                                 ' ' || lv_valor_atualizar || ' '||
                                                 ' from dual '||
                                                 --Garante que nao serao incluidos itens repetidos
                                                 ' where not exists (select 1 from atributo_valor ' ||
                                                                   ' where demanda_id = '||ln_id||' '||
                                                                   ' and   atributo_id = '|| ln_atributo_id ||' '||
                                                                   ' and '|| lv_coluna_insert || ' = ' || lv_valor_atualizar ||')';
                          elsif lv_nome_tabela = 'ATRIBUTOENTIDADEVALOR' then
                              lv_insert_valor := ' insert into atributoentidadevalor (atributoentidadeid, '||
                                                                              ' identidade, '||
                                                                              ' tipoentidade, '||
                                                                              ' atributoid, '||
                                                                              lv_coluna_insert ||' ) '||
                                                 ' select atributoentidadevalor_seq.nextval, '||
                                                 ' '|| ln_id ||', '||
                                                 ' '''||rec_tipo_entidade.tipo_entidade||''', '||
                                                 ' '|| ln_atributo_id || ', '||
                                                 ' ' || lv_valor_atualizar || ' '||
                                                 ' from dual '||
                                                 --Garante que nao serao incluidos itens repetidos
                                                 ' where not exists (select 1 from atributoentidadevalor ' ||
                                                                   ' where identidade = '||ln_id||' '||
                                                                   ' and   tipoentidade = '''||rec_tipo_entidade.tipo_entidade||''''||
                                                                   ' and   atributoid = '|| ln_atributo_id ||' '||
                                                                   ' and '|| lv_coluna_insert || ' = ' || lv_valor_atualizar ||')';
                          end if;
                          execute immediate lv_insert_valor;
                          lv_lista_valores := lv_lista_valores || ',' || lv_valor_atualizar;
                       else
                          if pb_append then
                             if lv_tipo_atributo = pck_atributo.Tipo_TEXTO then
                                lv_update_valor := ' set '||lv_coluna_insert|| ' = ' ||lv_coluna_insert|| '||' ||lv_valor_atualizar;
                             elsif lv_tipo_atributo = pck_atributo.Tipo_TEXTO_HTML then
                                lv_update_valor := ' set '||lv_coluna_insert|| ' = dbms_lob.substr(' ||lv_coluna_insert||',4000)'|| '|| ''<br><p>''' || lv_valor_atualizar ||'''</p>''';
                             else 
                                raise_application_error(-20001,'Tipo de atributo nao permitido para operacao de concatenar (append)');
                             end if;
                          else
                             lv_update_valor := ' set '||lv_coluna_insert|| ' = ' ||lv_valor_atualizar;
                          end if;
                          if lv_nome_tabela = 'ATRIBUTO_VALOR' then
                             lv_update_valor :=' declare ' ||
                                               ' ln_has_atr number; ' ||
                                               ' begin '||
                                                 ' select count(1) into ln_has_atr from '|| lv_nome_tabela  ||
                                                 ' where demanda_id = '|| ln_id ||
                                                 ' and   atributo_id = '|| ln_atributo_id || ';'||
                                                   ' if ln_has_atr = 0 then  '||
                                                     ' insert into '|| lv_nome_tabela  ||'(atributo_valor_id, demanda_id,atributo_id, date_update, user_update) '||
                                                     ' values('|| lv_nome_tabela  ||'_seq.nextval, '|| ln_id ||', '|| ln_atributo_id ||', sysdate, '''||pv_usuario_id||'''); '||
                                                   ' end if; '||
                                                ' update ' || lv_nome_tabela  ||
                                                lv_update_valor || ', '||
                                                '     date_update = sysdate, ' ||
                                                '     user_update = '''||pv_usuario_id||''''||
                                                ' where demanda_id = ' || ln_id || 
                                                ' and   atributo_id = '|| ln_atributo_id || ';' ||
                                                ' end; ';
                          elsif lv_nome_tabela = 'ATRIBUTOENTIDADEVALOR' then
                             lv_update_valor := ' declare ' ||
                                                ' ln_has_atr number; '||
                                                ' begin '||
                                                 ' select count(1) into ln_has_atr from '|| lv_nome_tabela  ||
                                                 ' where identidade = '|| ln_id ||
                                                 ' and   atributoid = '|| ln_atributo_id || 
                                                 ' and   tipoentidade = '||rec_tipo_entidade.tipo_entidade ||';'||
                                                   ' if ln_has_atr = 0 then  '||
                                                     ' insert into '|| lv_nome_tabela  ||'(atributoentidadeid, atributoid, entidadeid, tipoentidade) '||
                                                     ' values('|| lv_nome_tabela  ||'_seq.nextval, '|| ln_atributo_id ||', '|| ln_id ||','||rec_tipo_entidade.tipo_entidade ||'); '||
                                                   ' end if; '||
                                                ' begin '||
                                                ' update ' || lv_nome_tabela ||
                                                ' set '||lv_coluna_insert|| ' = ' ||lv_valor_atualizar || ' '||
                                                ' where identidade = ' || ln_id || 
                                                ' and   atributoid = '|| ln_atributo_id || 
                                                ' and   tipoentidade = '''||rec_tipo_entidade.tipo_entidade || ''';' ||
                                                ' end; ';
                          end if;
                          execute immediate lv_update_valor;
                       end if;
                   end loop;
                   close lc_sql;
                end if;
             
             elsif c.tipo_valor = 'lancamento' then
                if f_get_numero(lv_valor_origem) is not null then
                   lv_lista_lancamentos := lv_lista_lancamentos || ',' || f_get_numero(lv_valor_origem);
                end if;
                if ln_linha = ln_total and length(lv_lista_lancamentos) > 1 then
                   open lc_sql for lv_sql_destino;
                   
                   while true loop
                      fetch lc_sql into ln_id;
                      exit when lc_sql%notfound;
                      
                      lv_sql_lancamentos := ' select * '||
                                            ' from custo_lancamento ' ||
                                            ' where id in ('||substr(lv_lista_lancamentos,2)|| ') '||
                                            ' order by custo_entidade_id ';
                      
                      open lc_lancamentos for lv_sql_lancamentos;
                      lb_primeiro_lancamento := true;
                      while true loop
                         fetch lc_lancamentos into rec_lancamento;
                         exit when lc_lancamentos%notfound;
                         lv_tipo_lanc := rec_lancamento.tipo;
                         
                         if pn_tipo_lanc_dest is null and (lb_primeiro_lancamento or ln_custo_entidade_id <> rec_lancamento.custo_entidade_id) then
                            select custo_entidade_seq.nextval
                            into ln_custo_entidade_id_novo
                            from dual;
                            
                            insert into custo_entidade ( id, tipo_entidade, entidade_id, custo_receita_id, titulo,
                                                         tipo_despesa_id, forma_aquisicao_id, unidade, motivo )
                            select ln_custo_entidade_id_novo, rec_tipo_entidade.tipo_entidade, ln_id, custo_receita_id, titulo,
                                   tipo_despesa_id, forma_aquisicao_id, unidade, motivo
                            from custo_entidade
                            where id = rec_lancamento.custo_entidade_id;
                            
                            ln_custo_entidade_id := rec_lancamento.custo_entidade_id;

                            if rec_tipo_entidade.tipo_entidade = 'P' then
                              ln_tipo_lanc_dest := 1;
                            elsif rec_tipo_entidade.tipo_entidade = 'R'  then
                              ln_tipo_lanc_dest := 2;
                            end if;
                            
                         elsif pn_tipo_lanc_dest is null then
                             ln_custo_entidade_id := rec_lancamento.custo_entidade_id;
                         else
                             ln_custo_entidade_id := rec_lancamento.custo_entidade_id;
                             ln_custo_entidade_id_novo := rec_lancamento.custo_entidade_id;
                             if ln_tipo_lanc_dest = 1 then
                                lv_tipo_lanc := 'P';
                             elsif ln_tipo_lanc_dest = 2 then
                                lv_tipo_lanc := 'R';
                             else
                                lv_tipo_lanc := 'O'; 
                             end if; 
                         end if;
                         
                         ln_atr_obrig := 0;
                         select tipo_entidade, entidade_id into lv_tipo_ent_cust, ln_entidade 
                         from custo_entidade where custo_entidade.id = rec_lancamento.custo_entidade_id;

                         ln_atr_obrig := f_atr_obrig_nao_preenchido(ln_entidade, rec_lancamento.id, lv_tipo_ent_cust);
                          
                         if ln_atr_obrig > 0 then
                            --Deve desfazer as ações da base e retornar a mensagem de erro.
                            pn_msg_erro_lanc := 'label.alert.naoFoiPossivelCopiarLancamento';
                         end if; 
                         
                         if ln_atr_obrig = 0 then 
                               select custo_lancamento_seq.nextval
                               into ln_custo_lancamento_id_novo
                               from dual;
                               
                               if ln_tipo_lanc_dest is null then
                                  ln_tipo_lanc_dest := rec_lancamento.tipo_lancamento_id;
                               end if;
                               if rec_lancamento.valor_unitario is not null then
                                  lv_valor_unitario := to_char(rec_lancamento.valor_unitario, 'fm99999999999999999990D9999999999',const_nls_numero_update);
                               else 
                                  lv_valor_unitario := 'null';
                               end if;
                               if rec_lancamento.descricao is not null then
                                  lv_descricao := ''''||rec_lancamento.descricao||''' ';
                               else
                                  lv_descricao := 'null';
                               end if;
                               if rec_lancamento.quantidade is not null then
                                  lv_quantidade := to_char(rec_lancamento.quantidade, 'fm99999999999999999990D9999999999',const_nls_numero_update);
                               else
                                  lv_quantidade := 'null';
                               end if;
                               
                               lv_insert_valor := ' insert into custo_lancamento ( id, custo_entidade_id, tipo, '||
                                                  '                                situacao, data, valor_unitario, '||
                                                  '                                descricao, '||
                                                  '                                quantidade, valor, usuario_id, '||
                                                  '                                data_alteracao, tipo_lancamento_id ) '||
                                                  ' values ( '||ln_custo_lancamento_id_novo||', '||ln_custo_entidade_id_novo||','''||
                                                             lv_tipo_lanc ||''','''||rec_lancamento.situacao||''','||
                                                             ' to_date('''||to_char(rec_lancamento.data, const_formato_data)||''','''||const_formato_data||'''),'||
                                                             lv_valor_unitario||','||
                                                             lv_descricao||', '||
                                                             lv_quantidade||','||
                                                             to_char(rec_lancamento.valor, 'fm99999999999999999990D9999999999',const_nls_numero_update)||','||
                                                             ''''||pv_usuario_id||''','||
                                                             ' sysdate, '|| ln_tipo_lanc_dest ||')';
                               execute immediate lv_insert_valor;

                               --Cópia de atributos do lançamento
                               
                               if lv_tipo_ent_cust = 'D' then--Demanda
                                      select formulario_id into ln_entidade from demanda where demanda_id = (select entidade_id from custo_entidade where custo_entidade.id = rec_lancamento.custo_entidade_id);
                               elsif lv_tipo_ent_cust = 'P' then--Projeto
                                      select entidade_id into ln_entidade from custo_entidade where custo_entidade.id = rec_lancamento.custo_entidade_id;      
                               end if;
                                      
                               for atributovalor_ in (select * from atributoentidadevalor where atributoentidadevalor.tipoentidade = 'C'
                                                       and atributoentidadevalor.identidade = rec_lancamento.id) loop
                                                                       
                                     lv_atr_valor := atributovalor_.valor; 
                                     ld_atr_valordata := atributovalor_.valordata;
                                     ln_atr_valornumerico := atributovalor_.valornumerico;
                                     ln_atr_dominio := atributovalor_.dominio_atributo_id;
                                     lv_atr_valor_html := atributovalor_.valor_html;
                                     ln_atr_categoria := atributovalor_.categoria_item_atributo_id;

                                     select atributoentidadevalor_seq.nextval into ln_aev_seq from dual;
                                                     
                                     --Se o lançamento não tem valor preenchido, 
                                     --pega do padrão do tipo de lançamento ou do formulário          
                                     if ( lv_atr_valor is null and 
                                          ld_atr_valordata is null and
                                          ln_atr_valornumerico is null and
                                          ln_atr_dominio is null and
                                          lv_atr_valor_html is null and
                                          ln_atr_categoria is null) then 
                                                         
                                          get_v_padrao_atr_lanc(ln_entidade, 
                                                                atributovalor_.atributoid, 
                                                                lv_atr_valor,
                                                                ld_atr_valordata,
                                                                ln_atr_valornumerico,
                                                                ln_atr_dominio,
                                                                lv_atr_valor_html,
                                                                ln_atr_categoria,
                                                                lv_tipo_ent_cust);
                                     end if;   
                                                        
                                     insert into  atributoentidadevalor(atributoentidadeid, tipoentidade, identidade, 
                                                                        atributoid, valor, valordata, valornumerico, 
                                                                        dominio_atributo_id, valor_html, categoria_item_atributo_id) 
                                     values(ln_aev_seq, atributovalor_.tipoentidade, ln_custo_lancamento_id_novo,
                                            atributovalor_.atributoid, lv_atr_valor, ld_atr_valordata,
                                            ln_atr_valornumerico, ln_atr_dominio, lv_atr_valor_html,
                                            ln_atr_categoria);                                                  
                                end loop; 
                                 
                                       
                               
                               
                         end if;
                         
                         
                         lb_primeiro_lancamento := false;
                      end loop;
                      close lc_lancamentos;
                   end loop;
                   close lc_sql;
                end if;
             elsif c.coluna is null then
                raise_application_error(-20001,'Nao foi possivel fazer a copia.');
             else
                if lv_valor_origem is null then
                   lv_valor_atualizar := ' null ';
                elsif c.tipo_valor in ('numero', 'entidade', 'horas', 'lancamento') then
                   lv_valor_atualizar := ' pck_regras.f_get_numero('''''|| lv_valor_origem ||''''','''''|| const_formato_numero || ''''','''''|| const_nls_numero_sql || ''''') ';
                elsif c.tipo_valor in ('string') then
                   lv_valor_atualizar := ' '''|| lv_valor_origem ||''' ';
                elsif c.tipo_valor in ('data') then
                   lv_valor_atualizar := ' pck_regras.f_get_data('''''|| lv_valor_origem ||''''','''''|| const_formato_data || ''''') ';
                end if;
               
               if pb_append then
                     if c.tipo_valor = 'string' then
                        lv_sql := ' update ' || lv_nome_tabela ||
                                  ' set    ' || c.coluna || ' = ' ||c.coluna || '||' || lv_valor_atualizar ||
                                  ' where '|| rec_tipo_entidade.coluna_pk ||' in (' ||lv_sql_destino || ') ';
                     else
                        raise_application_error(-20001, 'Tipo de propriedade nao permitida para concatenacao(append)');
                     end if;
                 else
                     lv_sql := ' update ' || lv_nome_tabela ||
                               ' set    ' || c.coluna || ' = ' || lv_valor_atualizar ||
                               ' where '|| rec_tipo_entidade.coluna_pk ||' in (' ||lv_sql_destino || ') ';
                 end if;
                 execute immediate lv_sql;
             end if;
         end loop;
         close lc_valores;
      end loop;

   end;
   
   ----Essa função verifica se algum atributo do lamçamento não esta
   ----preenchido, se é o obrigatório e se não tem valor padrão.
   function f_atr_obrig_nao_preenchido(pn_id_entidade number, pn_id_lancamento number, pv_tipo varchar2) return number is
     ln_count number; 
   begin
        ln_count := 0;      
        select count (*) into ln_count from (
            select CONFIGPADRAO.atributoid 
            from ( select ael.tipo_lancamento_id,ael.identidade,ael.tipoentidade,ael.atributoid,ael.obrigatorio, aev.valor,
                          aev.valordata, aev.valornumerico, aev.dominio_atributo_id, aev.valor_html, aev.categoria_item_atributo_id
                   from atributoentidade_lancamento  ael,
                            atributoentidade_valorpadrao aev
                   where ael.tipo_lancamento_id  = aev.tipo_lancamento_id(+)
                     and ael.identidade         = aev.identidade(+)
                     and ael.tipoentidade       = aev.tipoentidade(+)
                     and ael.atributoid         = aev.atributoid(+)
                     and ael.tipoentidade       = pv_tipo
                     and aev.tipo_lancamento_id = (select tipo_lancamento_id from custo_lancamento where id = pn_id_lancamento)
                     and (aev.valor is null and
                          aev.valordata is null and
                          aev.valornumerico is null and
                          aev.valor_html is null and
                          aev.dominio_atributo_id is null and
                          aev.categoria_item_atributo_id is null)) CONFIGFORMULARIO,
                 ( select ael.tipo_lancamento_id,ael.identidade,ael.tipoentidade,ael.atributoid,ael.obrigatorio, aev.valor,
                          aev.valordata, aev.valornumerico, aev.dominio_atributo_id, aev.valor_html, aev.categoria_item_atributo_id        
                   from atributoentidade_lancamento  ael,
                        atributoentidade_valorpadrao aev 
                   where ael.tipo_lancamento_id  = aev.tipo_lancamento_id(+)
                     and ael.tipoentidade        = aev.tipoentidade(+)
                     and ael.atributoid          = aev.atributoid(+)
                     and ael.tipoentidade        = 'C'
                     and aev.tipo_lancamento_id = (select tipo_lancamento_id from custo_lancamento where id = pn_id_lancamento)
                     and (aev.valor is null and
                          aev.valordata is null and
                          aev.valornumerico is null and
                          aev.valor_html is null and
                          aev.dominio_atributo_id is null and
                          aev.categoria_item_atributo_id is null)) CONFIGPADRAO
            where CONFIGPADRAO.tipo_lancamento_id  = CONFIGFORMULARIO.tipo_lancamento_id(+)
              and CONFIGPADRAO.atributoid          = CONFIGFORMULARIO.atributoid(+)
              and CONFIGFORMULARIO.identidade (+)  = pn_id_entidade
              and CONFIGPADRAO.obrigatorio         = 'Y'
            minus
            select aev.atributoid from atributoentidadevalor aev 
            where aev.tipoentidade = 'C'
            and aev.identidade = pn_id_lancamento
            and (aev.valor is not null or
                 aev.valordata is not null or
                 aev.valornumerico is not null or
                 aev.valor_html is not null or
                 aev.dominio_atributo_id is not null or
                 aev.categoria_item_atributo_id is not null));
                 
       return ln_count;          
   end;  
   
   -----
   procedure get_v_padrao_atr_lanc(pn_id_entidade number, 
                                   pn_atr_id number, 
                                   pv_valor out varchar2,
                                   pd_valordata out date,
                                   pn_valornumerico out number,
                                   pn_dominio out number,
                                   pv_valorhtml out clob,
                                   pn_categoria out number,
                                   pv_tipo varchar2) is
     begin
          
            select nvl(CONFIG.valor, CONFIGPADRAO.valor) valor,
             nvl(CONFIG.valordata, CONFIGPADRAO.valordata) valordata,
             nvl(CONFIG.valornumerico, CONFIGPADRAO.valornumerico) valornumerico,
             nvl(CONFIG.dominio_atributo_id, CONFIGPADRAO.dominio_atributo_id) dominio,
             nvl(CONFIG.valor_html, CONFIGPADRAO.valor_html) valorhtml,
             nvl(CONFIG.categoria_item_atributo_id, CONFIGPADRAO.categoria_item_atributo_id) categoria
--             nvl(CONFIG.obrigatorio, CONFIGPADRAO.obrigatorio) obrigatorio
            into pv_valor, pd_valordata, pn_valornumerico, pn_dominio, pv_valorhtml, pn_categoria
            from ( select ael.tipo_lancamento_id,ael.identidade,ael.tipoentidade,ael.atributoid,ael.obrigatorio, aev.valor,
                          aev.valordata, aev.valornumerico, aev.dominio_atributo_id, aev.valor_html, aev.categoria_item_atributo_id
                   from atributoentidade_lancamento  ael,
                            atributoentidade_valorpadrao aev
                   where ael.tipo_lancamento_id  = aev.tipo_lancamento_id(+)
                     and ael.identidade         = aev.identidade(+)
                     and ael.tipoentidade       = aev.tipoentidade(+)
                     and ael.atributoid         = aev.atributoid(+)
                     and ael.tipoentidade       = pv_tipo) CONFIG,
                 ( select ael.tipo_lancamento_id,ael.identidade,ael.tipoentidade,ael.atributoid,ael.obrigatorio, aev.valor,
                          aev.valordata, aev.valornumerico, aev.dominio_atributo_id, aev.valor_html, aev.categoria_item_atributo_id        
                   from atributoentidade_lancamento  ael,
                        atributoentidade_valorpadrao aev
                   where ael.tipo_lancamento_id  = aev.tipo_lancamento_id(+)
                     and ael.tipoentidade        = aev.tipoentidade(+)
                     and ael.atributoid          = aev.atributoid(+)
                     and ael.tipoentidade        = 'C') CONFIGPADRAO
            where CONFIGPADRAO.tipo_lancamento_id  = CONFIG.tipo_lancamento_id(+)
              and CONFIGPADRAO.atributoid          = CONFIG.atributoid(+)
              and CONFIG.identidade (+)  = pn_id_entidade
              and CONFIGPADRAO.obrigatorio         = 'Y'
              and CONFIGPADRAO.atributoid = pn_atr_id;
     end;
   
   ------
   function f_monta_label_dominio(pv_dominio varchar2) return varchar2 is 
   begin
        if pv_dominio = 'IG' then
           return 'label.prompt.igualValor';
        elsif pv_dominio = 'IN' then
           return 'label.prompt.iniciaValor';
        elsif pv_dominio = 'TV' then
           return 'label.prompt.terminaValor';
        elsif pv_dominio = 'PO' then
           return 'label.prompt.possuiValor';
        elsif pv_dominio = 'MA' then
           return 'label.prompt.maiorValor';
        elsif pv_dominio = 'MI' then
           return 'label.prompt.maiorIgualValor';
        elsif pv_dominio = 'ME' then
           return 'label.prompt.menorValor';
        elsif pv_dominio = 'NI' then
           return 'label.prompt.menorIgualValor';
        elsif pv_dominio = 'DI' then
           return 'label.prompt.diferenteDe';
        elsif pv_dominio = 'PM' then
           return 'label.prompt.percMaxOrcTotal';
        elsif pv_dominio = 'PI' then
           return 'label.prompt.percMinOrcTotal';
        elsif pv_dominio = 'SV' then
           return 'label.prompt.semValor';
        elsif pv_dominio = 'ET' then
           return 'label.prompt.idProjetoTitulo';
        elsif pv_dominio = 'ID' then
           return 'label.prompt.idDemanda';
        elsif pv_dominio = 'DG' then
           return 'label.prompt.dataGeracaoBaseline';
        elsif pv_dominio = 'HG' then
           return 'label.prompt.dataHoraGeracaoBaseline';
        elsif pv_dominio = 'IE' then
           return 'label.prompt.idProjeto';
        elsif pv_dominio = 'TE' then
           return 'label.prompt.tituloProjeto';
        elsif pv_dominio = 'ED' then
           return 'label.prompt.estadoDemanda';
        elsif pv_dominio = 'DT' then
           return 'label.prompt.data';
        elsif pv_dominio = 'DH' then
           return 'label.prompt.dataHora';
        elsif pv_dominio = 'TL' then
           return 'label.prompt.tela';
        elsif pv_dominio = 'EM' then
           return 'label.prompt.email'; 
        elsif pv_dominio = 'CC' then
           return 'label.prompt.campoCondicionalValTeste';
        else
           return '';
        end if;  
   end; 
   
   ---------funcao de texto para acao
   function f_monta_texto_acao(rec_acao in out nocopy acao_condicional%rowtype) return varchar2 is 
     lv_acao                                varchar2(1000);
     lv_campo                               varchar2(1000); 
     lv_valor_troca                         varchar2(1000);     
     lv_texto_formatado                     varchar2(1000);     
     lv_temp1_atr                           varchar2(1000);     
     lv_temp2                               varchar2(1000);     
     ln_atr_id                              number;     
     ln_atr_prj_id                          number;     
     la_list_dominio                        pck_geral.t_varchar_array;
     begin
            lv_texto_formatado := '';
            if rec_acao.acao = 'DE' then
               lv_acao := 'label.prompt.desabilitar';
            elsif  rec_acao.acao = 'EX' then  
               lv_acao := 'label.prompt.exibir';
            elsif  rec_acao.acao = 'HA' then
               lv_acao := 'label.prompt.habilitar';
            elsif  rec_acao.acao = 'LI' then
              lv_acao := 'label.prompt.limpar';
            elsif  rec_acao.acao = 'OC' then
              lv_acao := 'label.prompt.ocultar';
            elsif  rec_acao.acao = 'PO' then
              lv_acao := 'label.prompt.preencher';
            elsif  rec_acao.acao = 'PF' then                      
              lv_acao := 'label.prompt.preencherComFormula';
            elsif  rec_acao.acao = 'OB' then
              lv_acao := 'label.prompt.tornarObrigatorio';
            elsif  rec_acao.acao = 'TO' then
              lv_acao := 'label.prompt.tornarOpcional';
            elsif  rec_acao.acao = 'TL' then
              lv_acao := 'label.prompt.tela';
            elsif  rec_acao.acao = 'EM' then        
              lv_acao := 'label.prompt.email';
            elsif  rec_acao.acao = 'DS' then
              lv_acao := 'label.prompt.definirSLA';
            elsif  rec_acao.acao = 'AC' then
              lv_acao := 'label.prompt.acumularMensagem';
            elsif  rec_acao.acao = 'EE' then
              lv_acao := 'label.prompt.encerraVaiEstado';
            elsif  rec_acao.acao = 'GB' then                                          
              lv_acao := 'label.prompt.gerarBaseline';
            elsif  rec_acao.acao = 'GM' then
              lv_acao := 'label.prompt.gerarMensagem';
              if rec_acao.valor_troca is not null then
                 if rec_acao.valor_troca = 'TL:;:' then
                    lv_valor_troca := 'label.prompt.tela';
                 end if;                 
              end if;
            elsif  rec_acao.acao = 'AM' then            
              lv_acao := 'label.prompt.acumularMensagem';
              if rec_acao.valor_troca is not null then
                  lv_valor_troca := rec_acao.valor_troca;
                 
                  la_list_dominio := pck_geral.f_split(lv_valor_troca, ':;:');
                  lv_temp1_atr := '';
                  for i in 1 .. la_list_dominio.count loop
                       lv_temp1_atr := lv_temp1_atr || f_monta_label_dominio(la_list_dominio(i));
                       if (i+1) < la_list_dominio.count then
                          lv_temp1_atr := lv_temp1_atr || ':;:' ;
                       end if;
                  end loop;
                  lv_valor_troca := lv_temp1_atr;
              end if;
            elsif  rec_acao.acao = 'VE' then
              lv_acao := 'label.prompt.vaiEstado';
            elsif  rec_acao.acao = 'CO' then
              lv_acao := 'label.prompt.copiarDados';
              if rec_acao.valor_troca is not null then
                  select titulo into lv_temp1_atr from regras_propriedade where id = to_number(rec_acao.valor_troca);                    
                  lv_valor_troca := lv_temp1_atr;
              end if;   
              
              if rec_acao.propriedade_id is not null then
                  select titulo into lv_temp1_atr from regras_propriedade where id = rec_acao.propriedade_id;                    
                  lv_valor_troca := lv_valor_troca || ' label.prompt.para ' || lv_temp1_atr;
              end if;                
            elsif  rec_acao.acao = 'CL' then
              lv_acao := 'label.prompt.copiarSimplesLancamento';
              
              select titulo into lv_temp1_atr from regras_propriedade where id = rec_acao.propriedade_id;
              select titulo into lv_temp2 from tipo_lancamento where tipo_lancamento.id = rec_acao.tipo_lancamento_id;
              
              lv_valor_troca := lv_temp1_atr || ' label.prompt.para ' || lv_temp2;
              
            elsif  rec_acao.acao = 'CP' then
              lv_acao := 'label.prompt.copiarPermissaoPapelProjeto';
              
              select papelprojeto.titulo, detalhe_acao_condic.titulo_papel_id
              into lv_temp2, lv_temp1_atr from detalhe_acao_condic, papelprojeto 
              where detalhe_acao_condic.acao_condicional_id = rec_acao.id
              and detalhe_acao_condic.papel_id = papelprojeto.papelprojetoid;
              
              lv_valor_troca := lv_temp2 || ' label.prompt.para ' || lv_temp1_atr;
              
            elsif  rec_acao.acao = 'GD' then
              lv_acao := 'label.prompt.gerarDocumentoApartirModeloImpressao';
              select titulo into lv_campo from modelo_impressao_form 
              where id in (select modelo_impressao_id 
              from detalhe_acao_condic 
              where detalhe_acao_condic.acao_condicional_id = rec_acao.id);
            else
              lv_acao := '';
         end if;       
     
         if rec_acao.chave_campo is not null then
            if rec_acao.chave_campo = 'DESTINO' then
               lv_campo := 'label.prompt.destino';
               if rec_acao.valor_troca is not null then
                  select descricao into lv_valor_troca from destino where destinoid = to_number(rec_acao.valor_troca);
               end if;
            elsif rec_acao.chave_campo = 'TITULO' then  
               lv_campo := 'label.prompt.titulo';
               if rec_acao.valor_troca is not null then               
                  lv_valor_troca := rec_acao.valor_troca; 
               end if;               
            elsif rec_acao.chave_campo = 'EMPRESA' then
               lv_campo := 'label.prompt.empresa';
               if rec_acao.valor_troca is not null then               
                  select nome into lv_valor_troca from empresa where id = to_number(rec_acao.valor_troca);
               end if;               
              
            elsif rec_acao.chave_campo = 'PRIORIDADE' then
               lv_campo := 'label.prompt.propriedade';
               if rec_acao.valor_troca is not null then               
                  select descricao into lv_valor_troca from prioridade where prioridadeid = to_number(rec_acao.valor_troca);
               end if;
            elsif rec_acao.chave_campo = 'PRIORIDADE_ATENDIMENTO' then
               lv_campo := 'label.prompt.propriedadeAtendimento';
               if rec_acao.valor_troca is not null then               
                  select descricao into lv_valor_troca from prioridade where prioridadeid = to_number(rec_acao.valor_troca);
               end if;
               
            elsif rec_acao.chave_campo = 'UO' then
               lv_campo := 'label.prompt.uo';
               if rec_acao.valor_troca is not null then               
                  select titulo into lv_valor_troca from uo where id = to_number(rec_acao.valor_troca);
               end if;
            elsif rec_acao.chave_campo = 'TIPO' then
               lv_campo := 'label.prompt.tipo';
               if rec_acao.valor_troca is not null then               
                  select descricao into lv_valor_troca from tiposolicitacao where tiposolicitacaoid = to_number(rec_acao.valor_troca);
               end if;
            elsif rec_acao.chave_campo = 'SOLICITANTE' then
               lv_campo := 'label.prompt.solicitante';
               if rec_acao.valor_troca is not null then               
                  select nome into lv_valor_troca from usuario where usuarioid = rec_acao.valor_troca;
               end if;
            elsif rec_acao.chave_campo = 'RESPONSAVEL' then
               lv_campo := 'label.prompt.responsavel';
               if rec_acao.valor_troca is not null then               
                  select nome into lv_valor_troca from usuario where usuarioid = rec_acao.valor_troca;
               end if;
            elsif rec_acao.chave_campo = 'ATUALIZACAO_AUTOMATICA' then
               lv_campo := 'label.prompt.atualizacaoAutomEstado';
               if rec_acao.valor_troca = 'SI' then               
                  lv_valor_troca := 'label.prompt.sim';
               else
                 lv_valor_troca := 'label.prompt.nao';    
               end if;
            else 
               lv_campo := '';
            end if;    
        elsif rec_acao.chave_campo is null and rec_acao.secao_atributo_id is not null then
                 select atributo_id into ln_atr_id from secao_atributo where secao_atributo_id = rec_acao.secao_atributo_id;
                 
                 select termo.texto_termo, tipo into lv_campo, lv_temp1_atr from atributo, termo 
                 where atributoid = ln_atr_id and atributo.titulo_termo_id = termo.termo_id;
                 
                 if rec_acao.valor_troca is not null then
                   if lv_temp1_atr = 'P' then
                       if rec_acao.valor_troca is not null then            
                         lv_valor_troca := replace(rec_acao.valor_troca, 'P','');
                         ln_atr_prj_id := to_number(lv_valor_troca);
                         select titulo into lv_valor_troca from projeto where id = ln_atr_prj_id;
                       end if;
                   elsif lv_temp1_atr = 'B' then
                         if rec_acao.valor_troca is not null then                   
                           if rec_acao.valor_troca = 'SI' then               
                              lv_valor_troca := 'label.prompt.sim';
                           else
                             lv_valor_troca := 'label.prompt.nao';    
                           end if;
                         end if;  
                   elsif lv_temp1_atr = 'L' then
                         if rec_acao.valor_troca is not null then
                            select titulo into lv_valor_troca from dominioatributo 
                            where dominioatributo.atributoid = ln_atr_id 
                            and dominioatributo.dominioatributoid = to_number(rec_acao.valor_troca);
                         end if;
                   
                   elsif lv_temp1_atr = 'M' then
                         if rec_acao.valor_troca is not null then
                           la_list_dominio := pck_geral.f_split(rec_acao.valor_troca, ',');
                     
                           for i in 1 .. la_list_dominio.count loop
                               select titulo into lv_temp1_atr from dominioatributo 
                               where dominioatributo.atributoid = ln_atr_id 
                               and dominioatributo.dominioatributoid = to_number(la_list_dominio(i));
                               
                               lv_valor_troca := lv_valor_troca || lv_temp1_atr;
                               
                               if (i+1) < la_list_dominio.count then
                                  lv_valor_troca := lv_valor_troca || ', ';
                               end if;  
                           end loop;
                         end if;
                   elsif lv_temp1_atr = 'U' then
                         if rec_acao.valor_troca is not null then               
                             select nome into lv_valor_troca from usuario where usuarioid = rec_acao.valor_troca;
                         end if;
                   elsif lv_temp1_atr = 'E' then
                         if rec_acao.valor_troca is not null then               
                            select nome into lv_valor_troca from empresa where id = to_number(rec_acao.valor_troca);
                         end if;                         
                   else
                      lv_valor_troca := rec_acao.valor_troca;
                   
                   end if;  
                 end if;    
         end if;
           
         lv_texto_formatado := lv_acao || ' - ' || lv_campo;
         if lv_valor_troca is not null then
           lv_texto_formatado := lv_texto_formatado || ' >> ' || lv_valor_troca;
         end if;
            
       return lv_texto_formatado;
   end;  
   
   --Essa procedure executa as lógicas de regras de validação para transicação de estado
   --e salva na tabela log_historico_transicao os testes e ações realizados               
   procedure p_exec_regras_valid_trans ( pn_demanda_id demanda.demanda_id%type,
                                                     pn_transicao_id transicao_estado.transicao_estado_id%type,
                                                     pn_usuario_id usuario.usuarioid%type,
                                                     pn_usuario_autorizador number,
                                                     pn_somente_testar number,
                                                     pn_return out number,
                                                     pn_estado_id out number, 
                                                     pn_estado_mensagem_id out number, 
                                                     pn_enviar_email out number, 
                                                     pn_gerar_baseline out number,
                                                     pn_gerar_documento out varchar2)is 
           
    lv_t_regras_OK                               boolean;
    lv_t_regras_obrig_OK                         boolean;
    lv_t_regras_inf_OK                           boolean;
    lv_t_regras_obrig_apr_inf_NOK                boolean;
    lv_regra_valida                              boolean;
    lv_tipo_regra                                varchar2(1000);
    lv_data_hist                                 date;
    rec_demanda                                  demanda%rowtype;
    lt_proj                                      pck_condicional.tab_projeto;
    ln_seq                                       binary_integer:=0;
    
    ln_estado_destino_id                         number;
    ln_return                                    number;
    ln_estado_id                                 number;
    ln_estado_mensagem_id                        number; 
    ln_enviar_email                              number; 
    ln_gerar_baseline                            number;
    ln_gerar_documento                           varchar2(1000);    
    ln_modelo_impressao_id                       number;    
    ln_historico                                 number;
    lv_retorno_validacao_campos                  varchar2(50); 
    lv_possui_permissao                          varchar2(1);
    ln_r_id                                      number;
    ln_id_log                                    number;
    lv_texto_acao                                varchar2(32000);
    lv_somente_teste                             varchar2(1);
    lv_usuario_autorizador                       varchar2(1);
    lv_msg_erro_copia                            varchar2(1000); 
    ln_permite_gerar_doc                         number;   
    lv_valido                                    varchar2(5);
    la_ind binary_integer;
    la_ids_invalidos t_ids;--Guarda todas as regras de validação que falharam
    ln_acao_nok_executada                        number;
        
    begin
    
      lv_t_regras_OK := true;
      lv_t_regras_obrig_OK := true;
      lv_t_regras_inf_OK := true;
      lv_data_hist := sysdate;
      
      pn_return := -1;
      pn_estado_id := -1; 
      pn_estado_mensagem_id := -1; 
      pn_enviar_email := -1; 
      pn_gerar_baseline := -1;
      ln_gerar_documento := '-1';
      lv_somente_teste := 'N';
      lv_usuario_autorizador := 'N';
      ln_acao_nok_executada := -1;
            
      if pn_somente_testar = 1 then
        lv_somente_teste := 'Y';
      end if;
      
      if pn_usuario_autorizador = 1 then
        lv_usuario_autorizador := 'Y';
      end if;
      la_ind := 0;
      for r in (select * from regras_valid_transicao rvt where rvt.transicao_id = pn_transicao_id) loop

          if r.tipo = 'O' then
            lv_tipo_regra := 'OB';--obrigatório
          elsif r.tipo = 'I' then
            lv_tipo_regra := 'IN';--Informativo
          end if;  
      
          lv_regra_valida := f_teste_validacao(pn_demanda_id, r.regra_validacao_id, pn_usuario_id, true,
                                               pn_transicao_id, null,lv_tipo_regra, lv_data_hist, lv_somente_teste, lv_usuario_autorizador);

          if lv_regra_valida = false then
             la_ids_invalidos(la_ind) := r.regra_validacao_id;
             la_ind := la_ind + 1;
          end if;

          --Testo se todas as regras foram aprovadas
          if lv_regra_valida <> true then
             lv_t_regras_OK := false;       
             if r.tipo = 'O' then
                --Testo se todas as regras obrigatórias foram aprovadas
                lv_t_regras_obrig_OK := false;
             elsif r.tipo = 'I' then   
                 --Testo se todas as regras Informativas foram aprovadas
                 lv_t_regras_inf_OK := false;
             end if;
          end if;
          
      end loop;

      if lv_t_regras_obrig_OK = true then
         if  lv_t_regras_inf_OK = false then 
            lv_t_regras_obrig_apr_inf_NOK := true;
         end if;
      end if;

      commit;
      ln_gerar_documento := '';
      lv_texto_acao := '';
      lv_msg_erro_copia := null;
      
      select max(id) into ln_historico from h_demanda where h_demanda.demanda_id = pn_demanda_id;

      if lv_t_regras_OK = true then 
         --Se todas regras ok
          for a in (select * from acao_condicional ac where ac.transicao_id = pn_transicao_id and ac.tipo_validacao = 1 order by ordem asc) loop
             --dbms_output.put_line('acao:' || a.id);            
             select * into rec_demanda from demanda where demanda_id = pn_demanda_id;
           
             lv_texto_acao := f_monta_texto_acao(a);
             
             if pn_somente_testar = 1 or regra_relevante_permite(a.id, la_ids_invalidos, a.tipo_regra_relevante) = -1 then 
                   p_salvar_acao_log_hist_trans (ln_historico, 
                                                 pn_transicao_id,
                                                  lv_texto_acao,
                                                  'r_nok',
                                                  lv_data_hist,
                                                  'Y',
                                                  lv_usuario_autorizador);
             else 
                   if a.acao = 'GD' then
                       ln_permite_gerar_doc := config_permite_geracao_doc(rec_demanda.demanda_id, a.id);  
                   
                       if ln_permite_gerar_doc = 1 then
                          ln_gerar_documento := ln_gerar_documento || a.id || '-';  
                       else
                          lv_msg_erro_copia := 'label.prompt.configuracaoVersionamentoInvalida';
                       end if;  
                   else  
                      pck_condicional.p_executaacaocondicional(rec_demanda, 
                                                               lt_proj, a, 
                                                               pn_usuario_id,
                                                               ln_estado_id,
                                                               ln_estado_mensagem_id,
                                                               ln_enviar_email,
                                                               ln_gerar_baseline,
                                                               lv_msg_erro_copia);
                                                  
                      if ln_estado_id is not null and ln_estado_id <> -1 then             
                          pn_estado_id := ln_estado_id; 
                      end if;
                      
                      if ln_estado_mensagem_id is not null and ln_estado_mensagem_id <> -1 then             
                          pn_estado_mensagem_id := ln_estado_mensagem_id; 
                      end if;
 
                      if ln_enviar_email is not null and ln_enviar_email <> -1 then             
                          pn_enviar_email := ln_enviar_email; 
                      end if;
 
                      if ln_gerar_baseline is not null and ln_gerar_baseline <> -1 then             
                          pn_gerar_baseline := ln_gerar_baseline; 
                      end if;
                                                               
                   end if; 
                   if lv_msg_erro_copia is not null then
                      lv_t_regras_OK := false;
                      lv_t_regras_obrig_OK := false;
                      p_salvar_acao_log_hist_trans (ln_historico,
                                                 pn_transicao_id,
                                                 lv_texto_acao,
                                                 lv_msg_erro_copia,
                                                 lv_data_hist,
                                                 'N',
                                                 lv_usuario_autorizador);
                   else                                                    
                       p_salvar_acao_log_hist_trans (ln_historico,
                                                 pn_transicao_id,
                                                 lv_texto_acao,
                                                 'r_ok',
                                                 lv_data_hist,
                                                 'N',
                                                 lv_usuario_autorizador);
                   end if;                              
             end if;                               
             
                                                                                                                           
          end loop;
      elsif lv_t_regras_obrig_apr_inf_NOK = true then
        --Se todas regras obrigatórias ok mas alguma regra informativa não ok.
          for a in (select * from acao_condicional ac where ac.transicao_id = pn_transicao_id and ac.tipo_validacao = 2 order by ordem asc) loop
             --dbms_output.put_line('acao:' || a.id); 
             select * into rec_demanda from demanda where demanda_id = pn_demanda_id;

             lv_texto_acao := f_monta_texto_acao(a);
             if pn_somente_testar = 1 or regra_relevante_permite(a.id, la_ids_invalidos, a.tipo_regra_relevante) = -1 then 
                   p_salvar_acao_log_hist_trans (ln_historico, 
                                                 pn_transicao_id,
                                                  lv_texto_acao,
                                                  'r_nok',
                                                  lv_data_hist,
                                                  'Y',
                                                  lv_usuario_autorizador);
             else 
                 if a.acao = 'GD' then
                       ln_gerar_documento := ln_gerar_documento || a.id || '-';                   
                 else  
                    pck_condicional.p_executaacaocondicional(rec_demanda, 
                                                          lt_proj, a, 
                                                          pn_usuario_id,
                                                          ln_estado_id,
                                                          ln_estado_mensagem_id,
                                                          ln_enviar_email,
                                                          ln_gerar_baseline,
                                                          lv_msg_erro_copia);
                                                          
                    if ln_estado_id is not null and ln_estado_id <> -1 then             
                          pn_estado_id := ln_estado_id; 
                    end if;
                      
                    if ln_estado_mensagem_id is not null and ln_estado_mensagem_id <> -1 then             
                          pn_estado_mensagem_id := ln_estado_mensagem_id; 
                    end if;
 
                    if ln_enviar_email is not null and ln_enviar_email <> -1 then             
                          pn_enviar_email := ln_enviar_email; 
                    end if;
 
                    if ln_gerar_baseline is not null and ln_gerar_baseline <> -1 then             
                          pn_gerar_baseline := ln_gerar_baseline; 
                    end if;                                                          
                 end if;        
                 if lv_msg_erro_copia is not null then
                      lv_t_regras_OK := false;
                      lv_t_regras_obrig_OK := false;
                      p_salvar_acao_log_hist_trans (ln_historico,
                                                 pn_transicao_id,
                                                 lv_texto_acao,
                                                 lv_msg_erro_copia,
                                                 lv_data_hist,
                                                 'N',
                                                 lv_usuario_autorizador);
                  else                                                    
                       p_salvar_acao_log_hist_trans (ln_historico,
                                                 pn_transicao_id,
                                                 lv_texto_acao,
                                                 'r_ok',
                                                 lv_data_hist,
                                                 'N',
                                                 lv_usuario_autorizador);
                  end if; 
             end if;                                                                                                                                                                                           
          end loop;
      elsif lv_t_regras_obrig_OK = false then 
         --Se alguma regra obrigatótia not ok.
          for a in (select * from acao_condicional ac where ac.transicao_id = pn_transicao_id and ac.tipo_validacao = 3 order by ordem asc) loop
             --dbms_output.put_line('acao:' || a.id);            
             select * into rec_demanda from demanda where demanda_id = pn_demanda_id;
           
             lv_texto_acao := f_monta_texto_acao(a);
             if pn_somente_testar = 1 or regra_relevante_permite(a.id, la_ids_invalidos, a.tipo_regra_relevante) = -1 then 
                   p_salvar_acao_log_hist_trans (ln_historico, 
                                                 pn_transicao_id,
                                                  lv_texto_acao,
                                                  'r_nok',
                                                  lv_data_hist,
                                                  'Y',
                                                  lv_usuario_autorizador);
             else 
                 ln_acao_nok_executada := 1;
                 if a.acao = 'GD' then
                       ln_gerar_documento := ln_gerar_documento || a.id || '-';                   
                 else  
                    pck_condicional.p_executaacaocondicional(rec_demanda, 
                                                          lt_proj, a, 
                                                          pn_usuario_id,
                                                          ln_estado_id,
                                                          ln_estado_mensagem_id,
                                                          ln_enviar_email,
                                                          ln_gerar_baseline,
                                                          lv_msg_erro_copia);
                    if ln_estado_id is not null and ln_estado_id <> -1 then             
                          pn_estado_id := ln_estado_id; 
                    end if;
                      
                    if ln_estado_mensagem_id is not null and ln_estado_mensagem_id <> -1 then             
                          pn_estado_mensagem_id := ln_estado_mensagem_id; 
                    end if;
 
                    if ln_enviar_email is not null and ln_enviar_email <> -1 then             
                          pn_enviar_email := ln_enviar_email; 
                    end if;
 
                    if ln_gerar_baseline is not null and ln_gerar_baseline <> -1 then             
                          pn_gerar_baseline := ln_gerar_baseline; 
                    end if;                                                          
                 end if;
                 if lv_msg_erro_copia is not null then
                      lv_t_regras_OK := false;
                      lv_t_regras_obrig_OK := false;
                      p_salvar_acao_log_hist_trans (ln_historico,
                                                 pn_transicao_id,
                                                 lv_texto_acao,
                                                 lv_msg_erro_copia,
                                                 lv_data_hist,
                                                 'N',
                                                 lv_usuario_autorizador);
                 else                                                    
                       p_salvar_acao_log_hist_trans (ln_historico,
                                                 pn_transicao_id,
                                                 lv_texto_acao,
                                                 'r_ok',
                                                 lv_data_hist,
                                                 'N',
                                                 lv_usuario_autorizador);
                 end if;  
              end if;                                                                                                                                                                 
           end loop;
      end if;
      
      if pn_usuario_autorizador = 1 then
        --Se a transição foi forçada por um usuário autorizador.
        for a in (select * from acao_condicional ac where ac.transicao_id = pn_transicao_id and ac.tipo_validacao = 4 order by ordem asc) loop
        
             --dbms_output.put_line('acao:' || a.id);            
             select * into rec_demanda from demanda where demanda_id = pn_demanda_id;
           
             lv_texto_acao := f_monta_texto_acao(a);
             if pn_somente_testar = 1 or regra_relevante_permite(a.id, la_ids_invalidos, a.tipo_regra_relevante) = -1 then 
                   p_salvar_acao_log_hist_trans (ln_historico,
                                                 pn_transicao_id, 
                                                  lv_texto_acao,
                                                  'r_nok',
                                                  lv_data_hist,
                                                  'Y',
                                                  lv_usuario_autorizador);
             else 
                 if a.acao = 'GD' then
                       ln_gerar_documento := ln_gerar_documento || a.id || '-';                   
                 else  
                    pck_condicional.p_executaacaocondicional(rec_demanda, 
                                                          lt_proj, a, 
                                                          pn_usuario_id,
                                                          ln_estado_id,
                                                          ln_estado_mensagem_id,
                                                          ln_enviar_email,
                                                          ln_gerar_baseline,
                                                          lv_msg_erro_copia);
                    if ln_estado_id is not null and ln_estado_id <> -1 then             
                          pn_estado_id := ln_estado_id; 
                    end if;
                      
                    if ln_estado_mensagem_id is not null and ln_estado_mensagem_id <> -1 then             
                          pn_estado_mensagem_id := ln_estado_mensagem_id; 
                    end if;
 
                    if ln_enviar_email is not null and ln_enviar_email <> -1 then             
                          pn_enviar_email := ln_enviar_email; 
                    end if;
 
                    if ln_gerar_baseline is not null and ln_gerar_baseline <> -1 then             
                          pn_gerar_baseline := ln_gerar_baseline; 
                    end if;                                                          
                                                          
                 end if;
                 if lv_msg_erro_copia is not null then
                      lv_t_regras_OK := false;
                      lv_t_regras_obrig_OK := false;
                      p_salvar_acao_log_hist_trans (ln_historico,
                                                 pn_transicao_id,
                                                 lv_texto_acao,
                                                 lv_msg_erro_copia,
                                                 lv_data_hist,
                                                 'N',
                                                 lv_usuario_autorizador);
                   else                                                    
                       p_salvar_acao_log_hist_trans (ln_historico,
                                                 pn_transicao_id,
                                                 lv_texto_acao,
                                                 'r_ok',
                                                 lv_data_hist,
                                                 'N',
                                                 lv_usuario_autorizador);
                   end if;
            end if;                                                                                                                                                                                                     
        end loop;
      end if;
      pn_gerar_documento := ln_gerar_documento;
      --Verifica as validações de campos configurados no formulário de demandas
      select estado_destino_id into ln_estado_destino_id from transicao_estado where transicao_estado.transicao_estado_id = pn_transicao_id;
      
      pck_valida_demanda.executa(pn_usuario_id,
                                 pn_demanda_id,
                                 ln_estado_destino_id,
                                 lv_retorno_validacao_campos);

       lv_possui_permissao := 'N';
       if lv_retorno_validacao_campos is null or lv_retorno_validacao_campos = '' then 
         lv_possui_permissao := 'Y';
       end if;                          

       p_salvar_v_log_hist_trans (ln_historico,
                                  pn_transicao_id,
                                  'label.prompt.validacaoCampos',
                                  lv_possui_permissao,
                                  lv_data_hist, 
                                  lv_somente_teste,
                                  lv_usuario_autorizador);


      --Verifica se deve trocar se estado
      if lv_t_regras_OK or pn_usuario_autorizador = 1 or lv_t_regras_obrig_OK then
        if lv_possui_permissao = 'Y' then
           pn_return := 1;
        else
           pn_return := 0; 
           pck_regras.p_salvar_acao_log_hist_desf(ln_historico);          
        end if;
      elsif ln_acao_nok_executada = 1 then
           pn_return := 2;--Significa que a transição não será executada, mas as ações para essa situação sim.
      else
         pn_return := 0;
         pck_regras.p_salvar_acao_log_hist_desf(ln_historico);
      end if;

   end;
 
   --Essa procedure é chamada da pck_condicional, na lógica de ações
   --e é responsável por fazer a cópia de permissões de um template de
   --papel para um papel dentro do projeto.
   procedure p_copia_permissoes_papel(pn_demanda_id demanda.demanda_id%type,
                                     rec_acao in acao_condicional%rowtype) is
     lv_tipo_escopo varchar2(250);
     ln_papel_template_id number;
     lv_titulo_papel varchar2(1000);
     lv_procedimento varchar2(1);
     ln_projeto_id  number;     
     begin
          select codigo into lv_tipo_escopo from regras_tipo_escopo where id = rec_acao.tipo_escopo_id;          
     
          select papel_id , titulo_papel_id, procedimento 
          into ln_papel_template_id, lv_titulo_papel, lv_procedimento 
          from detalhe_acao_condic 
          where acao_condicional_id = rec_acao.id;
                     
          if lv_tipo_escopo = 'projetosAssociados' then -- Projetos associados a demanda corrente
                for proj_ in (select identidade as ln_projeto_id from solicitacaoentidade where solicitacao = pn_demanda_id and tipoentidade = 'P') loop

                     --Copia os conhecimentos do papel template
                     p_copia_conh_papel_proj(proj_.ln_projeto_id, 
                                             ln_papel_template_id, 
                                             lv_titulo_papel, 
                                             lv_procedimento);
                     --Copia as permissões                        
                     p_copia_perm_papel_proj(proj_.ln_projeto_id, 
                                             ln_papel_template_id, 
                                             lv_titulo_papel, 
                                             lv_procedimento);
                     
                end loop;
          elsif lv_tipo_escopo = 'projetosDemandasFilhas' then --Projetos associados as demandas filhas da demanda corrente 
                for proj_ in (select distinct identidade as ln_projeto_id from solicitacaoentidade 
                              where solicitacao in (select demanda_id from demanda where demanda_pai = pn_demanda_id) and tipoentidade = 'P') loop
                     --Copia os conhecimentos do papel template
                     p_copia_conh_papel_proj(proj_.ln_projeto_id, 
                                             ln_papel_template_id, 
                                             lv_titulo_papel, 
                                             lv_procedimento);
                     --Copia as permissões                        
                     p_copia_perm_papel_proj(ln_projeto_id, 
                                             ln_papel_template_id, 
                                             lv_titulo_papel, 
                                             lv_procedimento);
                 end loop;
          elsif lv_tipo_escopo = 'projetosDemandaPai' then --Projetos associados a demanda pai da demanda corrente
                for proj_ in (select distinct identidade as ln_projeto_id from solicitacaoentidade 
                              where solicitacao in (select demanda_pai from demanda where demanda_id = pn_demanda_id) and tipoentidade = 'P') loop
                     --Copia os conhecimentos do papel template
                     p_copia_conh_papel_proj(proj_.ln_projeto_id, 
                                             ln_papel_template_id, 
                                             lv_titulo_papel, 
                                             lv_procedimento);
                     --Copia as permissões                        
                     p_copia_perm_papel_proj(ln_projeto_id, 
                                             ln_papel_template_id, 
                                             lv_titulo_papel, 
                                             lv_procedimento);
                 end loop;
          end if;
       
     end;  
     
     --Copia/Substitui conhecimentos de um papel para outro
     procedure p_copia_conh_papel_proj(pn_projeto_id number,
                                      pn_papel_id number,
                                      pv_titulo_papel varchar2,
                                      pv_procedimento varchar2) is
     ln_papel_id     number; 
     lv_titulo_papel varchar(1000);  
     ln_count        number;     
     begin
     
          lv_titulo_papel := pv_titulo_papel;  
          if pv_titulo_papel = 'Responsável Tarefa' then
             lv_titulo_papel := '$keyResource=papelsistema.responsaveltarefa.titulo';
          elsif pv_titulo_papel = 'Responsável Atividade' then
             lv_titulo_papel := '$keyResource=papelsistema.responsavelatividade.titulo';          
          elsif pv_titulo_papel = 'Gerente do Projeto' then  
             lv_titulo_papel := '$keyResource=papelsistema.gerenteprojeto.titulo';
          end if;    
          --Busca o papel correspondente ao título. (Por projeto)
          begin
            select papelprojetoid into ln_papel_id from papelprojeto
            where papelprojeto.projetoid = pn_projeto_id
            and papelprojeto.titulo = ''||lv_titulo_papel||'';
          exception
            when NO_DATA_FOUND then
              ln_papel_id := null;
          end;

          if ln_papel_id is not null then 
             if pv_procedimento = 'A' then --Adiciona
                for conhecimento_ in (select conhecimentoid, nivel from conhecimentopapel where papelid = pn_papel_id) loop
                     
                     select count(conhecimentoid) into ln_count from conhecimentopapel 
                     where conhecimentoid= conhecimento_.conhecimentoid
                     and papelid = ln_papel_id;

                     if ln_count = 0 then 
                       insert into conhecimentopapel(papelid, conhecimentoid, nivel)
                       values(ln_papel_id, conhecimento_.conhecimentoid, conhecimento_.nivel);
                     end if;
                      
                end loop;      
             elsif pv_procedimento = 'S' then --Substitui
                   delete conhecimentopapel where conhecimentopapel.papelid = ln_papel_id;
                   for conhecimento_ in (select conhecimentoid, nivel from conhecimentopapel where papelid = pn_papel_id) loop
                     
                       insert into conhecimentopapel(papelid, conhecimentoid, nivel)
                       values(ln_papel_id, conhecimento_.conhecimentoid, conhecimento_.nivel);
                   end loop;   
             end if;              
          end if;
     end;  
     
     
     --Copia/Substitui permissoes de um papel para outro
     procedure p_copia_perm_papel_proj(pn_projeto_id number,
                                      pn_papel_id number,
                                      pv_titulo_papel varchar2,
                                      pv_procedimento varchar2) is
     ln_papel_id            number;   
     ln_count               number;  
     ln_seq                 number;
     lv_titulo_papel        varchar(1000);
     
     begin
          lv_titulo_papel := pv_titulo_papel;  
          if pv_titulo_papel = 'Responsável Tarefa' then
             lv_titulo_papel := '$keyResource=papelsistema.responsaveltarefa.titulo';
          elsif pv_titulo_papel = 'Responsável Atividade' then
             lv_titulo_papel := '$keyResource=papelsistema.responsavelatividade.titulo';          
          elsif pv_titulo_papel = 'Gerente do Projeto' then  
             lv_titulo_papel := '$keyResource=papelsistema.gerenteprojeto.titulo';
          end if;             
 
          --Busca o papel correspondente ao título. (Por projeto)
          begin
            select papelprojetoid into ln_papel_id from papelprojeto
            where papelprojeto.projetoid = pn_projeto_id
            and papelprojeto.titulo = ''||lv_titulo_papel||'';
          exception
            when NO_DATA_FOUND then
              ln_papel_id := null;
          end;
     
          if ln_papel_id is not null then 
             if pv_procedimento = 'A' then --Adiciona
                  --Permissões de telas
                  for telapapel_ in (select telaid, somenteleitura from telapapel where papelprojetoid = pn_papel_id) loop
                       
                             select count(papelprojetoid) into ln_count
                             from telapapel where papelprojetoid = ln_papel_id
                             and telaid = telapapel_.telaid;
                             
                             if ln_count = 0 then
                               insert into telapapel(papelprojetoid, telaid, somenteleitura)
                               values(ln_papel_id, telapapel_.telaid, telapapel_.somenteleitura); 
                             end if;
                             
                  end loop;
                  --Permissões Categoria Papel
                  for perm_cat_ in (select permissao_categoria_id, inclusao, alteracao, exclusao, visualizacao 
                       from permissao_categoria_papel where papel_projeto_id = pn_papel_id) loop

                             select count(permissao_categoria_id) into ln_count from permissao_categoria_papel
                             where permissao_categoria_id = perm_cat_.permissao_categoria_id 
                             and papel_projeto_id = ln_papel_id;

                             if ln_count = 0 then 
                               insert into permissao_categoria_papel( permissao_categoria_id, papel_projeto_id, inclusao, alteracao, exclusao, visualizacao)
                               values(perm_cat_.permissao_categoria_id, ln_papel_id, perm_cat_.inclusao, perm_cat_.alteracao,perm_cat_.exclusao, perm_cat_.visualizacao);
                             end if;
                             
                  end loop;

                  --Permissões de Itens
                  for perm_item_ in (select permissao_item_id, tipo_acesso from permissao_item_papel where papel_projeto_id = pn_papel_id) loop
                           select count(papel_projeto_id) into ln_count from permissao_item_papel
                           where papel_projeto_id = ln_papel_id
                           and permissao_item_id = perm_item_.permissao_item_id;
                           
                           if ln_count = 0 then
                              insert into permissao_item_papel(papel_projeto_id, permissao_item_id, tipo_acesso)
                              values(ln_papel_id, perm_item_.permissao_item_id, perm_item_.tipo_acesso);  
                           end if;
                  end loop;                       
                  
                  --Permissões de lançamentos
                  for perm_lanc_ in (select tipo_lancamento_id, tipoentidade, inclusao, visualizacao, estorno 
                                     from tipo_lancamento_papel where papel_id = pn_papel_id) loop
                       
                           select count(papel_id) into ln_count from tipo_lancamento_papel
                           where tipo_lancamento_id = perm_lanc_.tipo_lancamento_id
                           and tipoentidade = perm_lanc_.tipoentidade
                           and papel_id = ln_papel_id;
                           
                           select tipo_lancamento_papel_seq.nextval into ln_seq from dual;
                           
                           if ln_count = 0 then
                              insert into tipo_lancamento_papel(id, tipo_lancamento_id, papel_id, tipoentidade, inclusao, visualizacao, estorno)  
                              values(ln_seq, perm_lanc_.tipo_lancamento_id, ln_papel_id, perm_lanc_.tipoentidade,perm_lanc_.inclusao,perm_lanc_.visualizacao, perm_lanc_.estorno);
                           end if;
                       
                  end loop;     
                  
                  --Responsabilidades
                  for resp_ in (select descricao from responsabilidade where papelid = pn_papel_id) loop
                  
                            select count(papelid) into ln_count from responsabilidade 
                            where papelid = ln_papel_id and descricao = ''||resp_.descricao||'';
                            
                            select responsabilidade_seq.nextval into ln_seq from dual;
                                                       
                            if ln_count = 0 then
                               insert into responsabilidade(responsabilidadeid, descricao, papelid) 
                               values(ln_seq, resp_.descricao, ln_papel_id);
                            end if;
                  
                  end loop;
                                    
             elsif pv_procedimento = 'S' then --Substitui
                    --Limpa todos os registros para substituir;
                    delete telapapel where papelprojetoid = ln_papel_id;
                    delete permissao_categoria_papel where papel_projeto_id = ln_papel_id;
                    delete permissao_item_papel where papel_projeto_id = ln_papel_id;
                    delete tipo_lancamento_papel where papel_id = ln_papel_id;
                    delete responsabilidade where papelid = ln_papel_id;
                   
                    --Permissões de telas
                    for telapapel_ in (select telaid, somenteleitura from telapapel where papelprojetoid = pn_papel_id) loop
                         insert into telapapel(papelprojetoid, telaid, somenteleitura)
                         values(ln_papel_id, telapapel_.telaid, telapapel_.somenteleitura); 
                    end loop;
                    --Permissões Categoria Papel
                    for perm_cat_ in (select permissao_categoria_id, inclusao, alteracao, exclusao, visualizacao 
                                      from permissao_categoria_papel where papel_projeto_id = pn_papel_id) loop
                         insert into permissao_categoria_papel( permissao_categoria_id, papel_projeto_id, inclusao, alteracao, exclusao, visualizacao)
                         values(perm_cat_.permissao_categoria_id, ln_papel_id, perm_cat_.inclusao, perm_cat_.alteracao,perm_cat_.exclusao, perm_cat_.visualizacao);
                    end loop;

                    --Permissões de Itens
                    for perm_item_ in (select permissao_item_id, tipo_acesso from permissao_item_papel where papel_projeto_id = pn_papel_id) loop
                          insert into permissao_item_papel(papel_projeto_id, permissao_item_id, tipo_acesso)
                          values(ln_papel_id, perm_item_.permissao_item_id, perm_item_.tipo_acesso);  
                    end loop;                       
                    
                    --Permissões de lançamentos
                    for perm_lanc_ in (select tipo_lancamento_id, tipoentidade, inclusao, visualizacao, estorno 
                                       from tipo_lancamento_papel where papel_id = pn_papel_id) loop
                         
                          select tipo_lancamento_papel_seq.nextval into ln_seq from dual;
                            
                          insert into tipo_lancamento_papel(id, tipo_lancamento_id, papel_id, tipoentidade, inclusao, visualizacao, estorno)  
                          values(ln_seq, perm_lanc_.tipo_lancamento_id, ln_papel_id, perm_lanc_.tipoentidade,perm_lanc_.inclusao,perm_lanc_.visualizacao, perm_lanc_.estorno);
                    end loop;     
                    
                    --Responsabilidades
                    for resp_ in (select descricao from responsabilidade where papelid = pn_papel_id) loop
                           select responsabilidade_seq.nextval into ln_seq from dual;
                           
                           insert into responsabilidade(responsabilidadeid, descricao, papelid) 
                           values(ln_seq, resp_.descricao, ln_papel_id);
                    end loop;
             end if;
          end if;   
     end;   
     
     function config_permite_geracao_doc(pn_demanda_id number, 
                                         pn_acao_id number) return number is
       ln_count         number;
       ln_ret           number;
       ln_versiona      varchar2(1);
       ln_nr_versao     number;
       ln_nr_anexos     number;
       ln_versao_atual  number;       
       ln_tipo_doc      number;
     begin
       select dac.tipo into ln_tipo_doc from detalhe_acao_condic dac where dac.acao_condicional_id = pn_acao_id; 
     
       select count(doc.documentoid) into ln_count from documento doc, (select dac.descricao, dac.tipo 
                              from detalhe_acao_condic dac 
                              where dac.acao_condicional_id = pn_acao_id ) dac
                where doc.identidade = pn_demanda_id
                and doc.tipoentidade = 'D'
                and doc.descricao = dac.descricao
                and dac.tipo = doc.tipo_documento_id(+);
        
        if ln_count > 0 then
                ln_ret := 1;        

                select versaosolicitacao, nversaosolicitacao into ln_versiona,ln_nr_versao
                from configuracoes
                where configuracoes.id = (select max(id) from configuracoes);
                
                if ln_versiona = 'H' then
                  if ln_nr_versao <= ln_count then
                     ln_ret := -1;
                   end if;  
                elsif ln_versiona = 'T' then
                     
                     if ln_tipo_doc is not null then
                        select nro_versoes, nro_max_anexos 
                        into ln_nr_versao, ln_nr_anexos
                        from tipo_documento 
                        where tipo_documento.id = ln_tipo_doc;
                        
                        if ln_nr_anexos <= ln_count then
                          ln_ret := -1;
                        else
                           select max(versaoatual) into ln_versao_atual
                           from documento doc, (select dac.descricao, dac.tipo 
                                               from detalhe_acao_condic dac 
                                               where dac.acao_condicional_id = pn_acao_id ) dac
                            where doc.identidade = pn_demanda_id
                            and doc.tipoentidade = 'D'
                            and doc.descricao = dac.descricao
                            and dac.tipo = doc.tipo_documento_id(+);
                            if ln_versao_atual >= ln_nr_versao then
                               ln_ret := -1;
                            end if;  
                        end if;   
                     end if;                 
                end if;   
        else 
          ln_ret := 1;  
        end if;    
        
        return ln_ret;    
     end; 
     
    function regra_relevante_permite(pn_acao_id number, la_ids_invalidos t_ids, pn_tipo_regra varchar2) return number is
    ln_ret number;
    ln_cont_invalidos number;
    ln_value_hash varchar(50);
    ln_regra number;
    ln_cont_regras_relevantes number;
    ln_id number;
    begin
        ln_ret := 1;--Indica que regras foram aprovadas
        ln_cont_invalidos := 0;
        select count(1) into ln_cont_regras_relevantes from regras_relevantes_acao where acao_id = pn_acao_id;
        for r_relevantes_ in (select * from regras_relevantes_acao where acao_id = pn_acao_id) loop
           begin
           select regra_validacao_id into ln_regra from regras_valid_transicao where regras_valid_transicao.id = r_relevantes_.regra_relevante;
           exception
             when no_data_found then
                return ln_ret;
           end;

            for la_ind in 0..la_ids_invalidos.count loop
                begin
                --Alguma regra relevante é inválida
                ln_id := la_ids_invalidos(la_ind);
                dbms_output.put_line('la_ids_invalidos('||la_ind||'):' || ln_id || ':' || ln_regra); 
                if (ln_id = ln_regra) then
                   ln_ret := -1;
                   ln_cont_invalidos := ln_cont_invalidos + 1;              
                end if;
                exception when no_data_found then
                   null;
                end;     
            end loop;       
        end loop;

        --Se todos Indica que todos foram reprovados e o teste é de Reprovado
        if (pn_tipo_regra = 'R') then 
          if(ln_cont_invalidos = ln_cont_regras_relevantes) then
             return 1;
          else 
             return -1;   
          end if;
        elsif (pn_tipo_regra = 'A' or pn_tipo_regra is null) then
              return ln_ret;
        else 
          return 1;
        end if;  
    end;
     
end pck_regras;
/

create or replace package pck_condicional is
      type tab_projeto is table of projeto%rowtype index by binary_integer;
   
      type tr_SeSenao is table of condicional_se_senao%rowtype index by binary_integer;
   
      rodando           boolean:=false;
      procedure p_ExecutarRegrasCondicionaisP (pn_demanda_id demanda.demanda_id%type, 
                                              pn_prox_estado number, 
                                              pv_usuario usuario.usuarioid%type, 
                                              pn_ret in out number, 
                                              pn_estado_id in out number, 
                                              pn_estado_mensagem_id in out estado_mensagens.id%type, 
                                              pn_enviar_email in out number, 
                                              pn_gerar_baseline in out number,
                                              pv_retorno_campos in out varchar2);
      procedure p_ExecRegrasFormulario (pn_formulario_id formulario.formulario_id%type);
      procedure p_ExecutarRegrasCondicionais (pn_demanda_id demanda.demanda_id%type, pv_usuario usuario.usuarioid%type, pn_ret out number);
      procedure p_NomeBaseline(pn_demanda_id demanda.demanda_id%type, pn_estado_id demanda.situacao%type, pn_projeto_id projeto.id%type, pn_acao_id acao_condicional.id%type, pv_nome out varchar2 );
      procedure p_ExecutaAcaoCondicional (rec_demanda in out nocopy demanda%rowtype, pprojetos in out nocopy tab_projeto, acao acao_condicional%rowtype, pv_usuario varchar2, pn_estado_id in out number, pn_estado_mensagem_id in out number, pn_enviar_email in out number, pn_gerar_baseline in out number);
      procedure p_ExecutaAcaoCondicional (rec_demanda in out nocopy demanda%rowtype, pprojetos in out nocopy tab_projeto, acao acao_condicional%rowtype, pv_usuario varchar2, pn_estado_id in out number, pn_estado_mensagem_id in out number, pn_enviar_email in out number, pn_gerar_baseline in out number, pv_msg_erro_copia in out varchar2);   

end;
/
create or replace package body pck_condicional is

   function f_compara_listas(pv_valor1 varchar2, pv_valor2 varchar2, pv_separador varchar2) return boolean is
      lista_1 pck_geral.t_varchar_array;
      lista_2 pck_geral.t_varchar_array;
   begin
       lista_1 := pck_geral.f_split(pv_valor1, pv_separador);
       lista_2 := pck_geral.f_split(pv_valor2, pv_separador);
       dbms_output.put_line('1.count: '||lista_2.count);
       dbms_output.put_line('2.count: '||lista_1.count);
       for ln_1 in 1..lista_2.count loop
          for ln_2 in 1..lista_1.count loop
             dbms_output.put_line(lista_2(ln_1)||' = '||lista_1(ln_2));
             if lista_2(ln_1) = lista_1(ln_2) then
                return true;
                exit;
             end if;
          end loop;
       end loop;
       return false;
   end;
   
   function f_ValorComparacao ( pv_campo_chave varchar2, 
                                rec_demanda demanda%rowtype, 
                                pprojeto projeto%rowtype,
                                pv_valor_teste varchar2) return varchar2 is
     ln_atributo_id number;
     ln_propriedade_atributo_id number;
     rec_atributo atributo%rowtype;
     rec_atributo_valor atributo_valor%rowtype;
     rec_av_vazio atributo_valor%rowtype;
     ln_empresa_id number;
     rec_escopo escopo%rowtype;
     rec_escopo_vazio escopo%rowtype;
     lv_premissa premissa.descricao%type;
     lv_restricao restricao.descricao%type;
     lv_produto produtoentregavel.descricao%type;
     ln_orcamento v_dados_crono_desembolso.cpv%type;
     ln_cont number;
     tab_aux pck_geral.t_varchar_array;
     lv_estado termo.texto_termo%type;
   begin
   
      dbms_output.put_line('campo chave:' || pv_campo_chave);
      
      if substr(upper(pv_campo_chave), 1, 9) = 'ATRIBUTO_' then
         if instr(pv_campo_chave, '.PROP_') > 0 then
            begin
                ln_atributo_id := to_number(substr(pv_campo_chave, length('ATRIBUTO_')+1, instr(pv_campo_chave, '.PROP_')-length('ATRIBUTO_')-1));
                ln_propriedade_atributo_id := to_number(substr(pv_campo_chave, instr(pv_campo_chave, '.PROP_')+length('.PROP_')));
            exception
            when others then
                if sqlcode = -06502 then
                  ln_atributo_id := to_number(substr(pv_campo_chave, length('ATRIBUTO_L_')+1, instr(pv_campo_chave, '.PROP_')-length('ATRIBUTO_L_')-1));
                  ln_propriedade_atributo_id := to_number(substr(pv_campo_chave, instr(pv_campo_chave, '.PROP_')+length('.PROP_X_')));
                end if;
            end;

            select *
            into rec_atributo
            from atributo
            where atributoid = ln_propriedade_atributo_id;
            
            begin
                select dac.valor, dac.valor_data, 
                       dac.valor_numerico, dac.categoria_id, 
                       dac.dominio_id
                into rec_atributo_valor.valor, rec_atributo_valor.valordata,
                     rec_atributo_valor.valornumerico, rec_atributo_valor.categoria_item_atributo_id, 
                     rec_atributo_valor.dominio_atributo_id
                from atributo_valor av,
                     dominioatributo da, 
                     atributo_coluna ac, 
                     dominio_atributo_coluna dac
                where da.dominioatributoid = dac.dominio_associado_id 
                and   dac.atributo_coluna_id = ac.id 
                and   da.atributoid = ln_atributo_id
                and   ac.atributo_relacionado_id = ln_propriedade_atributo_id
                and   av.demanda_id = rec_demanda.demanda_id
                and   av.dominio_atributo_id = dac.dominio_associado_id;
           exception
               when no_data_found then
                 rec_atributo_valor := rec_av_vazio;
           end;
                   
         else
            begin
               ln_atributo_id := to_number(replace(pv_campo_chave, 'ATRIBUTO_', ''));
            exception
            when others then
                if sqlcode = -06502 then
                   ln_atributo_id := to_number(substr(pv_campo_chave, length('ATRIBUTO_X_')+1));
                end if;
            end;

            select *
            into rec_atributo
            from atributo
            where atributoid = ln_atributo_id;
                   
            begin
               select *
               into rec_atributo_valor
               from atributo_valor
               where demanda_id = rec_demanda.demanda_id
               and   atributo_id = rec_atributo.atributoid;
            exception
            when no_data_found then
               rec_atributo_valor := rec_av_vazio;
            end;
         end if;
            
         if pck_atributo.Tipo_ARVORE = rec_atributo.tipo then
         
            return to_char(rec_atributo_valor.categoria_item_atributo_id);
                  
         elsif pck_atributo.Tipo_USUARIO = rec_atributo.tipo or
               pck_atributo.Tipo_EMPRESA = rec_atributo.tipo or
               pck_atributo.Tipo_PROJETO = rec_atributo.tipo then
         
            return upper(rec_atributo_valor.valor);
                     
         elsif pck_atributo.Tipo_LISTA = rec_atributo.tipo then
                  
            return to_char(rec_atributo_valor.dominio_atributo_id);

         elsif pck_atributo.Tipo_DATA = rec_atributo.tipo then
                  
            return to_char(rec_atributo_valor.valordata,'dd/mm/yyyy');

         elsif pck_atributo.Tipo_BOOLEANO = rec_atributo.tipo then

            if 'Y' = rec_atributo_valor.valor then
               return 'true';
            else
               return 'false';
            end if;

         elsif pck_atributo.Tipo_TEXTO = rec_atributo.tipo or
               pck_atributo.Tipo_AREA_TEXTO = rec_atributo.tipo or
               pck_atributo.Tipo_UF = rec_atributo.tipo then
                
            return upper(rec_atributo_valor.valor);
            
         elsif pck_atributo.Tipo_NUMERO = rec_atributo.tipo or
               pck_atributo.Tipo_MONETARIO = rec_atributo.tipo or
               pck_atributo.Tipo_HORA = rec_atributo.tipo then
                        
            return replace(to_char(rec_atributo_valor.valornumerico, '99999999999999999990D099999999999999999999', 'NLS_NUMERIC_CHARACTERS =''.,'''), ',', '');
                     
         end if;

      else
         if substr(pv_campo_chave, 1, 5) = 'PROJ_' then
            if substr(pv_campo_chave, 1, length('PROJ_ESCOPO_') ) = 'PROJ_ESCOPO_' then
               begin
                  select * 
                  into rec_escopo
                  from escopo
                  where projeto = pprojeto.id;
               exception
               when no_data_found then
                    rec_escopo := rec_escopo_vazio;
               end;
            end if;
            if pv_campo_chave = 'PROJ_HORAS_PREVISTAS' then
               return to_char(pprojeto.horasprevistas);
            elsif pv_campo_chave = 'PROJ_DURACAO_PREVISTA_DU' then
               return to_char(f_dias_uteis_entre(pprojeto.datainicio, pprojeto.prazoprevisto));
            elsif pv_campo_chave = 'PROJ_DURACAO_PREVISTA_DC' then
               return to_char(pprojeto.duracao);
            elsif pv_campo_chave = 'PROJ_DATA_FINAL_PREVISTA' then
               return to_char(pprojeto.prazoprevisto,'dd/mm/yyyy');
            elsif pv_campo_chave = 'PROJ_ORC_TOTAL' then
                select sum(tot) 
                into ln_orcamento
                from (select nvl(sum(c.cpv),0) tot 
                      from v_dados_crono_desembolso c 
                      where c.projeto_id = pprojeto.id
                      union all
                      select nvl(sum(c.cpv) ,0) 
                      from v_dados_crono_rh c 
                      where pprojeto.considerar_custo in ('Y','S')
                      and   c.projeto_id = pprojeto.id);
               return replace(to_char(ln_orcamento, '99999999999999999990D099999999999999999999', 'NLS_NUMERIC_CHARACTERS =''.,'''), ',', ''); 
            elsif pv_campo_chave = 'PROJ_ARVORE_CUSTO' then
                tab_aux := pck_geral.f_split(pv_valor_teste,':;:');
                select nvl(sum(c.cpv),0) tot 
                into ln_orcamento
                from v_dados_crono_desembolso c 
                where c.projeto_id = pprojeto.id
                and   custo_receita_id in (select id
                                           from custo_receita
                                           connect by prior id = id_pai
                                           start with id = to_number(tab_aux(1)));
               return replace(to_char(ln_orcamento, '99999999999999999990D099999999999999999999', 'NLS_NUMERIC_CHARACTERS =''.,'''), ',', '');
            elsif pv_campo_chave = 'PROJ_ESCOPO_ESTADO' then
               if rec_escopo.fechado in ('Y','S') then
                  return 'FE';
               else
                  return 'AB';
               end if;
            elsif pv_campo_chave = 'PROJ_ESCOPO_DESCRICAO' then
               if trim(dbms_lob.substr(rec_escopo.descproduto, 32000)) is not null then
                  return 'PR';
               else
                  return 'NP';
               end if;
            elsif pv_campo_chave = 'PROJ_ESCOPO_JUSTIFICATIVA' then
               if trim(dbms_lob.substr(rec_escopo.justificativaprojeto, 32000)) is not null then
                  return 'PR';
               else
                  return 'NP';
               end if;
            elsif pv_campo_chave = 'PROJ_ESCOPO_OBJETIVO' then
               if trim(dbms_lob.substr(rec_escopo.objetivosprojeto, 32000)) is not null then
                  return 'PR';
               else
                  return 'NP';
               end if;
            elsif pv_campo_chave = 'PROJ_ESCOPO_LIMITES' then
               if trim(dbms_lob.substr(rec_escopo.limitesprojeto, 32000)) is not null then
                  return 'PR';
               else
                  return 'NP';
               end if;
            elsif pv_campo_chave = 'PROJ_ESCOPO_LISTA_ESSENCIAIS' then
               if trim(dbms_lob.substr(rec_escopo.listafatoresessenciais, 32000)) is not null then
                  return 'PR';
               else
                  return 'NP';
               end if;
            elsif pv_campo_chave = 'PROJ_ESCOPO_ITEM_PREMISSA' then
               begin
                  select trim(max(descricao))
                  into lv_premissa
                  from premissa
                  where projeto = pprojeto.id;
               exception
               when no_data_found then
                    lv_premissa := null;
               end;
               if trim(lv_premissa) is not null then
                  return 'PR';
               else
                  return 'NP';
               end if;
            elsif pv_campo_chave = 'PROJ_ESCOPO_ITEM_RESTRICAO' then
               begin
                  select trim(max(descricao))
                  into lv_restricao
                  from restricao
                  where projeto = pprojeto.id;
               exception
                 when no_data_found then
                   lv_restricao := null;
               end;
               if trim(lv_restricao) is not null then
                  return 'PR';
               else
                  return 'NP';
               end if;
            elsif pv_campo_chave = 'PROJ_ESCOPO_ITEM_SUBPRODUTO' then
               begin
                  select trim(max(descricao))
                  into lv_produto
                  from produtoentregavel
                  where projeto = pprojeto.id;
               exception
                 when no_data_found then
                   lv_produto := null;
               end;
               if trim(lv_produto) is not null then
                  return 'PR';
               else
                  return 'NP';
               end if;
            end if;
            
         elsif pv_campo_chave = 'ID' then
            return to_char(rec_demanda.demanda_id);
         elsif pv_campo_chave = 'IE' then
            return to_char(pprojeto.id);
         elsif pv_campo_chave = 'TE' then
            return pprojeto.titulo;
         elsif pv_campo_chave = 'ET' then
            return to_char(pprojeto.id) || ' - ' ||pprojeto.titulo;
         elsif pv_campo_chave = 'DESTINO' then
            return to_char(rec_demanda.destino_id);
         elsif pv_campo_chave = 'EMPRESA' then
            select max(empresaid)
            into ln_empresa_id
            from usuario
            where usuarioid = rec_demanda.solicitante;

            return to_char(ln_empresa_id);

         elsif pv_campo_chave = 'PRIORIDADE' then
            return to_char(rec_demanda.prioridade);
         elsif pv_campo_chave = 'PRIORIDADE_ATENDIMENTO' then
            return to_char(rec_demanda.prioridade_responsavel);
         elsif pv_campo_chave = 'UO' then
            return to_char(rec_demanda.uo_id);
         elsif pv_campo_chave = 'TIPO' then
            return to_char(rec_demanda.tipo);
         elsif pv_campo_chave = 'CRIADOR' then
            return upper(rec_demanda.criador);
         elsif pv_campo_chave = 'SOLICITANTE' then
            return upper(rec_demanda.solicitante);
         elsif pv_campo_chave = 'RESPONSAVEL' then
            return upper(rec_demanda.responsavel);
         elsif pv_campo_chave = 'ATUALIZACAO_AUTOMATICA' then
            if 'Y' = rec_demanda.estado_automatico then
               return 'SI';
            else
               return 'NA';
            end if;
         elsif pv_campo_chave = 'TITULO' then
            return upper(rec_demanda.titulo);
         elsif pv_campo_chave = 'DATAS_PREVISTAS' then
            return to_char(rec_demanda.data_inicio_previsto,'dd/mm/yyyy');
         elsif pv_campo_chave = 'DATAS_REALIZADAS' then
            return to_char(rec_demanda.data_inicio_atendimento,'dd/mm/yyyy');
         elsif pv_campo_chave = 'PESO' then
            return to_char(rec_demanda.peso);
         elsif pv_campo_chave = 'DATA-CRIACAO' then
            return to_char(rec_demanda.data_criacao,'dd/mm/yyyy');
         elsif pv_campo_chave = 'DIA' then
            return to_char(to_number(to_char(rec_demanda.data_criacao,'dd')));
         elsif pv_campo_chave = 'MES' then
            return to_char(to_number(to_char(rec_demanda.data_criacao,'mm')));
         elsif pv_campo_chave = 'ANO' then
            return to_char(to_number(to_char(rec_demanda.data_criacao,'yyyy')));
         elsif pv_campo_chave = 'DATA-ATUAL' or
               pv_campo_chave = 'DT' then
            return to_char(sysdate,'dd/mm/yyyy');
         elsif pv_campo_chave = 'DH' then
            return to_char(sysdate,'dd/mm/yyyy hh24:mi');
         elsif pv_campo_chave = 'DIA-ATUAL' then
            return to_char(to_number(to_char(sysdate,'dd')));
         elsif pv_campo_chave = 'MES-ATUAL' then
            return to_char(to_number(to_char(sysdate,'mm')));
         elsif pv_campo_chave = 'ANO-ATUAL' then
            return to_char(to_number(to_char(sysdate,'yyyy')));
         elsif pv_campo_chave = 'ED' then
            select t.texto_termo
            into lv_estado
            from estado e, termo t
            where e.estado_id = rec_demanda.situacao
            and   e.titulo_termo_id = t.termo_id
            and   t.idioma = 'pt_BR';
            return lv_estado;
         end if;

      end if;
      
      return null;

   end;
   
   procedure p_AcumulaMensagem(rec_demanda in out nocopy demanda%rowtype, pprojetos tab_projeto, acao acao_condicional%rowtype, pn_estado_mensagem_id in out number) is
   lv_mensagem estado_mensagens_itens.mensagem%type:='';
   ln_h_demanda_id h_demanda.id%type;
   lv_valor varchar2(4000);
   ln_seq number;
   lt_msg pck_geral.t_varchar_array;
   ln_idx binary_integer;
   ln_qtd number;
   begin
      if pn_estado_mensagem_id is null or pn_estado_mensagem_id = 0 then
         select max(id)
         into ln_h_demanda_id
         from h_demanda
         where demanda_id = rec_demanda.demanda_id
         and   hestado in ('Y','S');
        
         select estado_mensagens_seq.nextval
         into pn_estado_mensagem_id
         from dual;
         
         insert into estado_mensagens ( id, h_demanda_id, data )
         values ( pn_estado_mensagem_id, ln_h_demanda_id, sysdate);
      end if;
      
      if pprojetos.count = 0 then 
         ln_qtd := 1;
      else
         ln_qtd := pprojetos.count;
      end if;
      for ln_i in 1..ln_qtd loop
         lt_msg := pck_geral.f_split(acao.valor_troca, ':;:');
         for ln_idx in 1..lt_msg.count loop
            if pprojetos.count = 0 then
               lv_valor := f_ValorComparacao(lt_msg(ln_idx), rec_demanda, null, null);
            else
               lv_valor := f_ValorComparacao(lt_msg(ln_idx), rec_demanda, pprojetos(ln_i), null);
            end if;
            if lv_valor is null then
               if lt_msg(ln_idx) is null then
                  lv_valor := '';
               else
                  lv_valor := lt_msg(ln_idx);
               end if;
            end if;
            lv_mensagem := lv_mensagem || lv_valor;
         end loop;
         
         select estado_mensagens_itens_seq.nextval
         into ln_seq
         from dual;
         
         insert into estado_mensagens_itens (id, estado_mensagens_id, n_item, mensagem )
         select ln_seq, pn_estado_mensagem_id, nvl(max(n_item),0)+1, lv_mensagem
         from estado_mensagens_itens
         where estado_mensagens_id = pn_estado_mensagem_id;
         
      end loop;
   end;

    /**
    * Esta procedure é responsável por retornar se um campo é obrigatorio ou opcional no estado da que a demanda se encontra.
    * As ações verificadas são: DESABILITAR, EXIBIR, HABILITAR, OCULTAR, OBRIGATORIO, OPCIONAL
    */
   procedure p_VerificaAcaoCondicionalCampo (rec_demanda in out nocopy demanda%rowtype, acao acao_condicional%rowtype, pv_retorno_campos in out varchar2) is
     ln_atributo_id number;
   begin
        
     if acao.secao_atributo_id is not null then
       select atributo_id into  ln_atributo_id from secao_atributo where secao_atributo_id = acao.secao_atributo_id;  
     elsif acao.secao_atr_obj_id is not null then
       select sa.atributo_id into  ln_atributo_id from secao_atributo sa, secao_atributo_objeto sao where sa.secao_atributo_id = sao.secao_atributo_id and sao.id = acao.secao_atr_obj_id;
     elsif acao.estado_botao is not null or acao.sla_id is not null then
       return;
     end if;
           
     if 'DE' = upper(acao.acao) or  'OC' = upper(acao.acao) or 'OP' = upper(acao.acao) then
       if ln_atributo_id is not null then
          pv_retorno_campos := pv_retorno_campos || 'ATR_' || ln_atributo_id || ',OP,' || rec_demanda.demanda_id || '/';
       else
         pv_retorno_campos := pv_retorno_campos || acao.chave_campo || ',OP,' || rec_demanda.demanda_id || '/';
       end if;
     elsif 'OB' = upper(acao.acao) then
       if ln_atributo_id is not null then
          pv_retorno_campos := pv_retorno_campos || 'ATR_' || ln_atributo_id || ',OB,' || rec_demanda.demanda_id || '/';
       else
          pv_retorno_campos := pv_retorno_campos || acao.chave_campo || ',OB,' || rec_demanda.demanda_id || '/';
       end if;
     end if;
   end;

   procedure p_ExecutaAcaoCondicional (rec_demanda in out nocopy demanda%rowtype, pprojetos in out nocopy tab_projeto, acao acao_condicional%rowtype, pv_usuario varchar2, pn_estado_id in out number, pn_estado_mensagem_id in out number, pn_enviar_email in out number, pn_gerar_baseline in out number) is
     lv_msg_erro_copia varchar2(1000); 
   begin
     lv_msg_erro_copia := ''; 
     p_ExecutaAcaoCondicional (rec_demanda, pprojetos, acao, pv_usuario, pn_estado_id, pn_estado_mensagem_id, pn_enviar_email, pn_gerar_baseline, lv_msg_erro_copia);
   end;
     
   procedure p_ExecutaAcaoCondicional (rec_demanda in out nocopy demanda%rowtype, pprojetos in out nocopy tab_projeto, acao acao_condicional%rowtype, pv_usuario varchar2, pn_estado_id in out number, pn_estado_mensagem_id in out number, pn_enviar_email in out number, pn_gerar_baseline in out number, pv_msg_erro_copia in out varchar2) is
   rec_secao_atributo secao_atributo%rowtype;
   rec_atributo atributo%rowtype;
   tab_val pck_geral.t_varchar_array;
   lv_formula varchar2(4000);
   lv_valor varchar2(4000);
   lv_select varchar2(4000);
   lv_valor_troca acao_condicional.valor_troca%type;
   ln_propriedade_id regras_propriedade.id%type;
   type t_calculo is ref cursor;
   lc_calculo t_calculo;
   ln_total number;
   ln_prop_origem number;
   lv_msg_erro_copia varchar2(1000);
   ln_has_atr number;
   begin
				--Internamente, somente ações de preencher valor deve ser executado.
        if 'GB' = upper(acao.acao) then
           pn_gerar_baseline := acao.id;
        elsif 'GM' = upper(acao.acao) then
           if substr(acao.valor_troca,1,2) <> 'TL' then
              pn_enviar_email := acao.id;
           end if;
        elsif 'EE' = upper(acao.acao) or 'VE' = upper(acao.acao) then
           pn_estado_id := acao.valor_troca;
        elsif 'AM' = upper(acao.acao) then
           p_AcumulaMensagem(rec_demanda, pprojetos, acao, pn_estado_mensagem_id);
        elsif 'PO' = upper(acao.acao) or 'PF' = upper(acao.acao)  or 'AP' = upper(acao.acao) then
           if 'PF' = upper(acao.acao) then
              lv_formula := acao.valor_troca;
           
              lv_valor := f_valorcomparacao('DURACAO', rec_demanda, null, null);
           
              lv_formula := replace(lv_formula, '[duracao]', lv_valor);
              
              while instr(lv_formula, '[PROPRIEDADE_') > 0 loop
                 ln_propriedade_id := to_number(
                                      substr(lv_formula, 
                                             instr(lv_formula, '[PROPRIEDADE_') + length('[PROPRIEDADE_'),
                                             instr(lv_formula, ']', instr(lv_formula, '[PROPRIEDADE_')) - instr(lv_formula, '[PROPRIEDADE_') - length('[PROPRIEDADE_')));
                 lv_valor := pck_regras.f_get_numero(pck_regras.f_get_valor_propriedade(rec_demanda.demanda_id,pv_usuario, ln_propriedade_id));
                 if lv_valor is null then
                    lv_valor := ' null ';
                 end if;
                 lv_formula := replace ( lv_formula, '[PROPRIEDADE_'||ln_propriedade_id||']', lv_valor);
              end loop;
           
              for c in (select a.atributoid, ac.atributo_relacionado_id, at.tipo
                        from secao_atributo s, atributo a,  atributo_coluna ac, atributo at
                        where formulario_id = rec_demanda.formulario_id
                        and   s.atributo_id = a.atributoid
                        and   a.tipo in ('L')
                        and   a.atributoid = ac.atributo_principal_id
                        and   ac.atributo_relacionado_id = at.atributoid) loop
                 lv_valor := replace(f_valorcomparacao('ATRIBUTO_L_'||c.atributoid||'.PROP_'||c.tipo||'_'||c.atributo_relacionado_id, rec_demanda, null, null),',','.');
                 lv_formula := replace(upper(lv_formula), '[ATRIBUTO_L_'||c.atributoid||'.PROP_'||c.tipo||'_'||c.atributo_relacionado_id||']', lv_valor);
              end loop;
              
              for c in (select atributo_id, a.tipo
                        from secao_atributo s, atributo a
                        where formulario_id = rec_demanda.formulario_id
                        and   s.atributo_id = a.atributoid
                        and   a.tipo in (pck_atributo.Tipo_HORA, pck_atributo.Tipo_NUMERO, pck_atributo.Tipo_MONETARIO)) loop
                 lv_valor := replace(f_valorcomparacao('ATRIBUTO_'||c.atributo_id, rec_demanda, null, null),',','.');
                 lv_formula := replace(UPPER(lv_formula), '[ATRIBUTO_'||c.tipo||'_'||c.atributo_id||']', NVL(lv_valor,0));
              end loop;
              
              lv_formula := pck_geral.f_insere_zeroisnull(lv_formula);
              
              lv_select := 'select trunc('||lv_formula||',2) from dual';

              begin 
                 open lc_calculo for lv_select;
                 fetch lc_calculo into ln_total;
                 close lc_calculo;
              exception when others then 
                 if sqlcode = -936 then
                    ln_total := null;
                 else
                    raise;
                 end if;
              end;
              
              dbms_output.put_line('lv_select: '||lv_select);
              dbms_output.put_line('ln_total: '||ln_total);
              
              lv_valor_troca := ln_total;
              
           else
              lv_valor_troca := acao.valor_troca;
           end if;
           
           /*if acao.propriedade_id is not null then
              if lv_valor_troca is not null then
                 if acao.acao = 'PF'then
                    ln_propriedade_id := null;
                    ln_total := to_number(replace(lv_valor_troca,'.',''),'99999999999999990D9999999999999999','NLS_NUMERIC_CHARACTERS =''.,''');
                    lv_valor_troca := pck_regras.f_formata(ln_total);
                 else
                    ln_propriedade_id := to_number(
                                         substr(lv_formula, 
                                                instr(lv_formula, '[PROPRIEDADE_') + length('[PROPRIEDADE_'),
                                                instr(lv_formula, ']', instr(lv_formula, '[PROPRIEDADE_')) - instr(lv_formula, '[PROPRIEDADE_') - length('[PROPRIEDADE_')));
                 end if;
              end if;
              lv_msg_erro_copia := '';
              pck_regras.p_copia_propriedade(rec_demanda.demanda_id,
                                             pv_usuario,
                                             ln_propriedade_id,
                                             lv_valor_troca,
                                             acao.propriedade_id,
                                             acao.acao='AP',
                                             null,
                                             lv_msg_erro_copia);*/
           --els
           if acao.secao_atributo_id is not null then
						  if trim(lv_valor_troca) is not null then
                 select *
                 into rec_secao_atributo
                 from secao_atributo
                 where secao_atributo_id = acao.secao_atributo_id;
                 
                 select *
                 into rec_atributo
                 from atributo
                 where atributoid = rec_secao_atributo.atributo_id;
                 
							   if rec_atributo.atributoid is not null then
                    
                    if pck_atributo.Tipo_LISTA_MULTIPLA_ESCOLHA = rec_atributo.tipo or
                       (pck_atributo.Tipo_ARVORE = rec_atributo.tipo and
                        pck_atributo.Formato_ARVORE_MULTISELECAO = rec_atributo.formato_lista) or
                       (pck_atributo.Tipo_USUARIO = rec_atributo.tipo and
                        pck_atributo.FORMATO_LISTA_MULTISELECAO = rec_atributo.formato_lista)  or
                       (pck_atributo.Tipo_EMPRESA = rec_atributo.tipo and
                        pck_atributo.FORMATO_LISTA_MULTISELECAO = rec_atributo.formato_lista)  or
                       (pck_atributo.Tipo_PROJETO = rec_atributo.tipo and
                        pck_atributo.FORMATO_LISTA_MULTISELECAO = rec_atributo.formato_lista) then
                       
                       delete atributo_valor
                       where demanda_id = rec_demanda.demanda_id
                       and   atributo_id = rec_atributo.atributoid;
                       
                       tab_val := pck_geral.f_split(lv_valor_troca,',');
                       
                       for ln_contador in 1..tab_val.count loop
                          if pck_atributo.Tipo_LISTA_MULTIPLA_ESCOLHA = rec_atributo.tipo then
                             insert into atributo_valor ( atributo_valor_id, atributo_id, demanda_id, 
                                                          date_update, user_update, dominio_atributo_id)
                             values ( atributo_valor_seq.nextval, rec_atributo.atributoid, rec_demanda.demanda_id,
                                      sysdate, pv_usuario, to_number(tab_val(ln_contador)));
                          elsif pck_atributo.Tipo_ARVORE = rec_atributo.tipo then
                             insert into atributo_valor ( atributo_valor_id, atributo_id, demanda_id, 
                                                          date_update, user_update, categoria_item_atributo_id)
                             values ( atributo_valor_seq.nextval, rec_atributo.atributoid, rec_demanda.demanda_id,
                                      sysdate, pv_usuario, to_number(tab_val(ln_contador)));
                          else
                             insert into atributo_valor ( atributo_valor_id, atributo_id, demanda_id, 
                                                          date_update, user_update, valor)
                             values ( atributo_valor_seq.nextval, rec_atributo.atributoid, rec_demanda.demanda_id,
                                      sysdate, pv_usuario, to_number(tab_val(ln_contador)));
                          end if;
                       end loop;
                    else
                      
                        select count(1) into ln_has_atr from  atributo_valor  
                        where demanda_id = rec_demanda.demanda_id
                        and   atributo_id = rec_atributo.atributoid;
                        if ln_has_atr = 0 then 
                          insert into atributo_valor(atributo_valor_id, atributo_id, demanda_id, 
                                                          date_update, user_update)
                             values ( atributo_valor_seq.nextval, rec_atributo.atributoid, rec_demanda.demanda_id,
                                      sysdate, pv_usuario);
                        end if;
                        
                    
                       if pck_atributo.Tipo_LISTA = rec_atributo.tipo then
                          if trim(acao.valor_troca) is not null then
                             update atributo_valor
                             set dominio_atributo_id = to_number(lv_valor_troca),
                                 date_update = sysdate,
                                 user_update = pv_usuario
                             where demanda_id = rec_demanda.demanda_id
                             and   atributo_id = rec_atributo.atributoid;
                             
                          end if;
                       elsif pck_atributo.Tipo_DATA = rec_atributo.tipo then
                             update atributo_valor
                             set valordata = to_date(lv_valor_troca,'dd/mm/yyyy'),
                                 date_update = sysdate,
                                 user_update = pv_usuario
                             where demanda_id = rec_demanda.demanda_id
                             and   atributo_id = rec_atributo.atributoid;
                       elsif pck_atributo.Tipo_BOOLEANO = rec_atributo.tipo then
                             if 'SI' = lv_valor_troca then
                                update atributo_valor
                                set valor = 'Y',
                                 date_update = sysdate,
                                 user_update = pv_usuario
                                where demanda_id = rec_demanda.demanda_id
                                and   atributo_id = rec_atributo.atributoid;
                             else
                                update atributo_valor
                                set valor = 'N',
                                 date_update = sysdate,
                                 user_update = pv_usuario
                                where demanda_id = rec_demanda.demanda_id
                                and   atributo_id = rec_atributo.atributoid;
                             end if;
                       elsif pck_atributo.Tipo_TEXTO = rec_atributo.tipo or
                             pck_atributo.Tipo_AREA_TEXTO = rec_atributo.tipo or
                             pck_atributo.Tipo_ARVORE = rec_atributo.tipo or
                             pck_atributo.Tipo_EMPRESA = rec_atributo.tipo or
                             pck_atributo.Tipo_USUARIO = rec_atributo.tipo or
                             pck_atributo.Tipo_PROJETO = rec_atributo.tipo then
                             if trim(lv_valor_troca) is not null then
                                update atributo_valor
                                set valor = lv_valor_troca,
                                 date_update = sysdate,
                                 user_update = pv_usuario
                                where demanda_id = rec_demanda.demanda_id
                                and   atributo_id = rec_atributo.atributoid;
                             end if;
                       elsif pck_atributo.Tipo_NUMERO = rec_atributo.tipo or
                             pck_atributo.Tipo_MONETARIO = rec_atributo.tipo then
                             
                             if trim(lv_valor_troca) is not null then
                                update atributo_valor
                                set valornumerico = to_number(replace(lv_valor_troca,'.',''),'99999999999999990D9999999999999999','NLS_NUMERIC_CHARACTERS =''.,'''),
                                 date_update = sysdate,
                                 user_update = pv_usuario
                                where demanda_id = rec_demanda.demanda_id
                                and   atributo_id = rec_atributo.atributoid;

                             end if;
                       elsif pck_atributo.Tipo_HORA = rec_atributo.tipo then

                             dbms_output.put_line('atributoid: '||rec_atributo.atributoid);
                             dbms_output.put_line('valor_troca: '||lv_valor_troca);
                             if trim(lv_valor_troca) is not null then
                                if instr(lv_valor_troca,':') > 0 then
                                   lv_valor_troca := HORAMIN(lv_valor_troca);
                                end if;
                                update atributo_valor
                                set valornumerico = lv_valor_troca,
                                 date_update = sysdate,
                                 user_update = pv_usuario
                                where demanda_id = rec_demanda.demanda_id
                                and   atributo_id = rec_atributo.atributoid;

                             end if;
                       end if;
                    end if;
                 end if;
              end if;
           else
              dbms_output.put_line('chave campo: '|| acao.chave_campo);
              dbms_output.put_line('acaoo.valor_troca: '|| lv_valor_troca);
              if acao.chave_campo = 'DESTINO' then
                 update demanda
                 set date_update = sysdate,
                     user_update = pv_usuario,
                     destino_id = to_number(replace(lv_valor_troca, 'D',''))
                 where demanda_id = rec_demanda.demanda_id;
              elsif acao.chave_campo = 'PRIORIDADE_ATENDIMENTO' then
                 update demanda
                 set date_update = sysdate,
                     user_update = pv_usuario,
                     prioridade_responsavel = to_number(lv_valor_troca)
                 where demanda_id = rec_demanda.demanda_id;
              elsif acao.chave_campo = 'PRIORIDADE' then
                 update demanda
                 set date_update = sysdate,
                     user_update = pv_usuario,
                     prioridade = to_number(lv_valor_troca)
                 where demanda_id = rec_demanda.demanda_id;
              elsif acao.chave_campo = 'TIPO' then
                 update demanda
                 set date_update = sysdate,
                     user_update = pv_usuario,
                     tipo = to_number(lv_valor_troca)
                 where demanda_id = rec_demanda.demanda_id;
              elsif acao.chave_campo = 'SOLICITANTE' then
                 update demanda
                 set date_update = sysdate,
                     user_update = pv_usuario,
                     solicitante = lv_valor_troca
                 where demanda_id = rec_demanda.demanda_id;
              elsif acao.chave_campo = 'RESPONSAVEL' then
                 update demanda
                 set date_update = sysdate,
                     user_update = pv_usuario,
                     responsavel = lv_valor_troca
                 where demanda_id = rec_demanda.demanda_id;
              elsif acao.chave_campo = 'ATUALIZACAO_AUTOMATICA' then
                 if 'SI' = upper(lv_valor_troca) then
                    update demanda
                    set date_update = sysdate,
                        user_update = pv_usuario,
                        estado_automatico = 'Y'
                    where demanda_id = rec_demanda.demanda_id;
                 else
                    update demanda
                    set date_update = sysdate,
                        user_update = pv_usuario,
                        estado_automatico = 'N'
                    where demanda_id = rec_demanda.demanda_id;
                 end if;
              elsif acao.chave_campo = 'TITULO' then
                 update demanda
                 set date_update = sysdate,
                     user_update = pv_usuario,
                     titulo = lv_valor_troca
                 where demanda_id = rec_demanda.demanda_id;
              elsif acao.chave_campo = 'DATAS_REALIZADAS' then
                 update demanda
                 set date_update = sysdate,
                     user_update = pv_usuario,
                     data_inicio_atendimento = to_date(lv_valor_troca,'dd/mm/yyyy')
                 where demanda_id = rec_demanda.demanda_id;
              elsif acao.chave_campo = 'DATAS_PREVISTAS' then
                 dbms_output.put_line('DATAS PREVISTAS');
                 update demanda
                 set date_update = sysdate,
                     user_update = pv_usuario,
                     data_inicio_previsto = to_date(lv_valor_troca,'dd/mm/yyyy')
                 where demanda_id = rec_demanda.demanda_id;
              elsif acao.chave_campo = 'PESO' then
                 update demanda
                 set date_update = sysdate,
                     user_update = pv_usuario,
                     peso = to_number(lv_valor_troca)
                 where demanda_id = rec_demanda.demanda_id;
              end if;
           end if;
        elsif 'LI' = upper(acao.acao) then
          if acao.propriedade_id is not null then
            lv_msg_erro_copia := '';
             pck_regras.p_copia_propriedade(rec_demanda.demanda_id,
                                            pv_usuario,
                                            null,
                                            null,
                                            acao.propriedade_id,
                                            false,
                                            null,
                                            lv_msg_erro_copia);
          elsif acao.secao_atr_obj_id is not null then
           
           for rec_secao_atributo_objeto in (
              select secao_atributo_objeto.id, secao_atributo_objeto.objeto_id, 
                     secao_atributo_objeto.objeto_campo_id, objeto_campo.coluna,
                     secao_atributo.atributo_id, atributo_valor.valor
              from   secao_atributo_objeto, objeto_campo, secao_atributo, atributo_valor 
              where  secao_atributo_objeto.id = acao.secao_atr_obj_id
              and    secao_atributo_objeto.objeto_campo_id = objeto_campo.id
              and    atributo_valor.demanda_id = rec_demanda.demanda_id 
              and    atributo_valor.atributo_id = secao_atributo.atributo_id
              and    secao_atributo.secao_atributo_id = secao_atributo_objeto.secao_atributo_id) loop
            
              if rec_secao_atributo_objeto.objeto_id is not null then
                    dbms_output.put_line('TESTE:' || rec_secao_atributo_objeto.coluna);
                    if rec_secao_atributo_objeto.coluna is not null then
                         if 'NOME' = upper(rec_secao_atributo_objeto.coluna) then
                               update usuario set NOME = null where usuarioid = rec_secao_atributo_objeto.valor;
                         elsif 'EMAIL' = upper(rec_secao_atributo_objeto.coluna) then 
                               update usuario set EMAIL = null where usuarioid = rec_secao_atributo_objeto.valor;
                         elsif 'PADRAOHORARIO' = upper(rec_secao_atributo_objeto.coluna) then 
                               update usuario set PADRAOHORARIO = null where usuarioid = rec_secao_atributo_objeto.valor;  
                         elsif 'VIGENTE' = upper(rec_secao_atributo_objeto.coluna) then 
                               update usuario set VIGENTE = 'N' where usuarioid = rec_secao_atributo_objeto.valor;
                         elsif 'TELEFONE' = upper(rec_secao_atributo_objeto.coluna) then 
                               update usuario set TELEFONE = null where usuarioid = rec_secao_atributo_objeto.valor;
                         elsif 'CELULAR' = upper(rec_secao_atributo_objeto.coluna) then 
                               update usuario set CELULAR = null where usuarioid = rec_secao_atributo_objeto.valor;
                         elsif 'EMPRESAID' = upper(rec_secao_atributo_objeto.coluna) then 
                               update usuario set EMPRESAID = null where usuarioid = rec_secao_atributo_objeto.valor;  
                         elsif 'RESPONSAVEL_ID' = upper(rec_secao_atributo_objeto.coluna) then 
                               dbms_output.put_line('TESTE2:' || rec_secao_atributo_objeto.valor);
                               update usuario set RESPONSAVEL_ID = null where usuarioid = rec_secao_atributo_objeto.valor;
                         elsif 'TIPO_PROFISSIONAL_ID' = upper(rec_secao_atributo_objeto.coluna) then 
                               update usuario set TIPO_PROFISSIONAL_ID = null where usuarioid = rec_secao_atributo_objeto.valor;
                         elsif 'TIPO_USUARIO' = upper(rec_secao_atributo_objeto.coluna) then 
                               update usuario set TIPO_USUARIO = null where usuarioid = rec_secao_atributo_objeto.valor;
                         elsif 'DDD_CELULAR' = upper(rec_secao_atributo_objeto.coluna) then 
                               update usuario set DDD_CELULAR = null where usuarioid = rec_secao_atributo_objeto.valor;
                         elsif 'DDD_TELEFONE' = upper(rec_secao_atributo_objeto.coluna) then 
                               update usuario set DDD_TELEFONE = null where usuarioid = rec_secao_atributo_objeto.valor;
                         elsif 'DDI_CELULAR' = upper(rec_secao_atributo_objeto.coluna) then 
                               update usuario set DDI_CELULAR = null where usuarioid = rec_secao_atributo_objeto.valor;
                         elsif 'DDI_TELEFONE' = upper(rec_secao_atributo_objeto.coluna) then 
                               update usuario set DDI_TELEFONE = null where usuarioid = rec_secao_atributo_objeto.valor;
                         elsif 'RAMAL' = upper(rec_secao_atributo_objeto.coluna) then 
                               update usuario set RAMAL = null where usuarioid = rec_secao_atributo_objeto.valor;
                         elsif 'UO_ID' = upper(rec_secao_atributo_objeto.coluna) then 
                               update usuario set UO_ID = null where usuarioid = rec_secao_atributo_objeto.valor;
                         elsif 'LOGIN' = upper(rec_secao_atributo_objeto.coluna) then 
                               update usuario set LOGIN = null where usuarioid = rec_secao_atributo_objeto.valor;
                         elsif 'IDIOMA_PADRAO' = upper(rec_secao_atributo_objeto.coluna) then 
                               update usuario set IDIOMA_PADRAO = null where usuarioid = rec_secao_atributo_objeto.valor;
                         end if;
                    end if;
                end if;
              end loop;
           elsif acao.secao_atributo_id is not null then
              select *
              into rec_secao_atributo
              from secao_atributo
              where secao_atributo_id = acao.secao_atributo_id;
              
              select *
              into rec_atributo
              from atributo
              where atributoid = rec_secao_atributo.atributo_id;

              if rec_atributo.atributoid is not null then
                 if pck_atributo.Tipo_LISTA_MULTIPLA_ESCOLHA = rec_atributo.tipo or
                    (pck_atributo.Tipo_ARVORE = rec_atributo.tipo and
                     pck_atributo.Formato_ARVORE_MULTISELECAO = rec_atributo.formato_lista) or
                    (pck_atributo.Tipo_USUARIO = rec_atributo.tipo and
                     pck_atributo.FORMATO_LISTA_MULTISELECAO = rec_atributo.formato_lista)  or
                    (pck_atributo.Tipo_EMPRESA = rec_atributo.tipo and
                     pck_atributo.FORMATO_LISTA_MULTISELECAO = rec_atributo.formato_lista)  or
                    (pck_atributo.Tipo_PROJETO = rec_atributo.tipo and
                     pck_atributo.FORMATO_LISTA_MULTISELECAO = rec_atributo.formato_lista) then
							
                    delete atributo_valor
                    where demanda_id = rec_demanda.demanda_id
                    and   atributo_id = rec_atributo.atributoid;
									 
                 else
                    update atributo_valor
                    set user_update = pv_usuario,
                        date_update = sysdate,
                        valor = '',
                        valornumerico = null,
                        valordata = null,
                        dominio_atributo_id = null,
                        categoria_item_atributo_id = null
                    where demanda_id = rec_demanda.demanda_id
                    and   atributo_id = rec_atributo.atributoid;
                    
                 end if;
              end if;
           else
              if acao.chave_campo = 'DESTINO' then
                 update demanda
                 set date_update = sysdate,
                     user_update = pv_usuario,
                     destino_id = null
                 where demanda_id = rec_demanda.demanda_id;
              elsif acao.chave_campo = 'PRIORIDADE_ATENDIMENTO' then
                 update demanda
                 set date_update = sysdate,
                     user_update = pv_usuario,
                     prioridade_responsavel = null
                 where demanda_id = rec_demanda.demanda_id;
              elsif acao.chave_campo = 'PRIORIDADE' then
                 update demanda
                 set date_update = sysdate,
                     user_update = pv_usuario,
                     prioridade = null
                 where demanda_id = rec_demanda.demanda_id;
              elsif acao.chave_campo = 'TIPO' then
                 update demanda
                 set date_update = sysdate,
                     user_update = pv_usuario,
                     tipo = null
                 where demanda_id = rec_demanda.demanda_id;
              elsif acao.chave_campo = 'SOLICITANTE' then
                 update demanda
                 set date_update = sysdate,
                     user_update = pv_usuario,
                     solicitante = null
                 where demanda_id = rec_demanda.demanda_id;
              elsif acao.chave_campo = 'RESPONSAVEL' then
                 update demanda
                 set date_update = sysdate,
                     user_update = pv_usuario,
                     responsavel = null
                 where demanda_id = rec_demanda.demanda_id;
              elsif acao.chave_campo = 'ATUALIZACAO_AUTOMATICA' then
                 update demanda
                 set date_update = sysdate,
                     user_update = pv_usuario,
                     estado_automatico = 'N'
                 where demanda_id = rec_demanda.demanda_id;
              elsif acao.chave_campo = 'TITULO' then
                 update demanda
                 set date_update = sysdate,
                     user_update = pv_usuario,
                     titulo = null
                 where demanda_id = rec_demanda.demanda_id;
              elsif acao.chave_campo = 'DATAS_REALIZADAS' then
                 update demanda
                 set date_update = sysdate,
                     user_update = pv_usuario,
                     data_inicio_atendimento = null
                 where demanda_id = rec_demanda.demanda_id;
              elsif acao.chave_campo = 'DATAS_PREVISTAS' then
                 update demanda
                 set date_update = sysdate,
                     user_update = pv_usuario,
                     data_inicio_previsto = null
                 where demanda_id = rec_demanda.demanda_id;
              elsif acao.chave_campo = 'PESO' then
                 update demanda
                 set date_update = sysdate,
                     user_update = pv_usuario,
                     peso = null
                 where demanda_id = rec_demanda.demanda_id;
              end if;
           end if;
        elsif 'DS' = upper(acao.acao) then
           if acao.campo_sla = 'SLA_PROCESSO' then
              update sla_ativo_demanda
              set sla_processo_id = acao.sla_id
              where demanda_id = rec_demanda.demanda_id;
           elsif acao.campo_sla = 'SLA_TENDENCIA' then
              update sla_ativo_demanda
              set sla_tendencia_id = acao.sla_id
              where demanda_id = rec_demanda.demanda_id;
           elsif acao.campo_sla = 'SLA_ESTADO' then
              update sla_ativo_demanda
              set sla_estado_id = acao.sla_id
              where demanda_id = rec_demanda.demanda_id;
           end if;
       elsif 'CO' = upper(acao.acao) then
               lv_msg_erro_copia := '';
              ln_prop_origem := to_number(acao.valor_troca);
              pck_regras.p_copia_propriedade(rec_demanda.demanda_id,
                                             pv_usuario,
                                             ln_prop_origem,
                                             null,
                                             acao.propriedade_id,
                                             false,
                                             null,
                                             lv_msg_erro_copia);
              
        elsif 'CL' = upper(acao.acao) then   
              --Cópia de Lançamentos
              lv_msg_erro_copia := '';
              pck_regras.p_copia_propriedade(rec_demanda.demanda_id,
                                             pv_usuario,
                                             acao.propriedade_id,
                                             null,
                                             null,
                                             false,
                                             acao.tipo_lancamento_id,
                                             lv_msg_erro_copia);
                                             
               pv_msg_erro_copia := lv_msg_erro_copia;
              
             
        elsif 'CP' = upper(acao.acao) then
              --Cópia de Papel
              pck_regras.p_copia_permissoes_papel(rec_demanda.demanda_id, acao);
              
        end if;
        
        select *
        into rec_demanda
        from demanda
        where demanda_id = rec_demanda.demanda_id;
   end;
   
   function f_condicional_satisfeito (rec_campose campo_condicional_se%rowtype, rec_demanda demanda%rowtype, pprojeto projeto%rowtype) return boolean is
   ln_atributo_id atributo.atributoid%type;
   rec_atributo atributo%rowtype;
   ln_c number;
   ln_tempValor number;
   tab_valor_teste pck_geral.t_varchar_array;
   lb_achou_lista boolean;
   lv_valor1 varchar2(4000);
   lv_valor2 varchar2(4000);
   ln_orcamento v_dados_crono_desembolso.cpv%type;
   ln_perc number;
   begin
      if substr(upper(rec_campose.chave_campo), 1, 9) = 'ATRIBUTO_' and 
         instr(rec_campose.chave_campo, '.PROP_') = 0 then
         ln_atributo_id := to_number(replace(rec_campose.chave_campo, 'ATRIBUTO_', ''));
          
         select *
         into rec_atributo
         from atributo
         where atributoid = ln_atributo_id;
          
         if pck_atributo.Tipo_LISTA_MULTIPLA_ESCOLHA = rec_atributo.tipo or
            (pck_atributo.Tipo_ARVORE = rec_atributo.tipo and
             pck_atributo.Formato_ARVORE_MULTISELECAO = rec_atributo.formato_lista) or
            (pck_atributo.Tipo_USUARIO = rec_atributo.tipo and
             pck_atributo.FORMATO_LISTA_MULTISELECAO = rec_atributo.formato_lista)  or
            (pck_atributo.Tipo_EMPRESA = rec_atributo.tipo and
             pck_atributo.FORMATO_LISTA_MULTISELECAO = rec_atributo.formato_lista)  or
            (pck_atributo.Tipo_PROJETO = rec_atributo.tipo and
             pck_atributo.FORMATO_LISTA_MULTISELECAO = rec_atributo.formato_lista) then

            select count(1)
            into ln_c
            from atributo_valor
            where demanda_id = rec_demanda.demanda_id
            and   atributo_id = ln_atributo_id;
             
            tab_valor_teste := pck_geral.f_split(rec_campose.valor_teste,',');
             
            dbms_output.put_line('valor_teste: ' || rec_campose.valor_teste);
            dbms_output.put_line('atributo_id: ' || ln_atributo_id);
            dbms_output.put_line('ln_c: ' || ln_c);
            dbms_output.put_line('tab_valor_teste.count: ' || tab_valor_teste.count);

            if ln_c <> tab_valor_teste.count then
               return false;
            end if;
            
            for cAV in (select *
                        from atributo_valor
                        where demanda_id = rec_demanda.demanda_id
                        and   atributo_id = ln_atributo_id) loop
                
               lb_achou_lista := false;
                
               for ln_contador in 1..tab_valor_teste.count loop
                
                  if pck_atributo.Tipo_LISTA_MULTIPLA_ESCOLHA = rec_atributo.tipo then
                
                    dbms_output.put_line('atrib: ' || cAV.dominio_atributo_id);
                    dbms_output.put_line('tab_lista: ' || to_number(tab_valor_teste(ln_contador)));
                     
                     if cAV.dominio_atributo_id = to_number(tab_valor_teste(ln_contador)) then
                        lb_achou_lista := true;
                     end if;

                  elsif (pck_atributo.Tipo_ARVORE = rec_atributo.tipo and
                         pck_atributo.Formato_ARVORE_MULTISELECAO = rec_atributo.formato_lista) then
                
                     if cAV.categoria_item_atributo_id = to_number(tab_valor_teste(ln_contador)) then
                        lb_achou_lista := true;
                     end if;

                  else

                     if cAV.valor = tab_valor_teste(ln_contador) then
                        lb_achou_lista := true;
                     end if;
                      
                  end if;

               end loop;
                
               if not lb_achou_lista then
                  return false;
               end if;

            end loop;

            return true;

         else

            lv_valor1 := f_valorcomparacao(rec_campose.chave_campo, rec_demanda, pprojeto, rec_campose.valor_teste);
            
            dbms_output.put_line('lv_valor1: '||lv_valor1);
            
            if rec_campose.comparar_dinamicamente = 'Y' then
               lv_valor2 := f_valorcomparacao(substr(rec_campose.valor_teste, 1+length('DINAMIC_')), rec_demanda, pprojeto, null);
            else
               lv_valor2 := upper(rec_campose.valor_teste);
               if rec_atributo.tipo = pck_atributo.Tipo_NUMERO or
                  rec_atributo.tipo = pck_atributo.Tipo_MONETARIO then
                  lv_valor2 := replace(lv_valor2,'.','');
                  lv_valor2 := replace(lv_valor2,',','.');
                  ln_tempValor:= to_number(lv_valor2, '99999999999999999990D099999999999999999999','NLS_NUMERIC_CHARACTERS =''.,''');
                  lv_valor2 := replace(to_char(ln_tempValor, '99999999999999999990D099999999999999999999', 'NLS_NUMERIC_CHARACTERS =''.,'''), ',', '');
                  
               end if;
               if rec_atributo.tipo = pck_atributo.Tipo_HORA then
                  lv_valor2 := HORAMIN(lv_valor2);
               end if;
            end if;

            dbms_output.put_line('lv_valor2: '||lv_valor2);
            dbms_output.put_line('1');
            
            dbms_output.put_line('condicional: ' ||rec_campose.condicional);
            
            if pck_atributo.Tipo_DATA = rec_atributo.tipo then
               if trim(lv_valor1) is null or trim(lv_valor2) is null then
                  return false;
               end if;
            end if;
            

            if 'IG' = rec_campose.condicional then

               if lv_valor1 = lv_valor2 then
                  return true;
               else
                  return false;
               end if;
                
            elsif 'IN' = rec_campose.condicional then
                
               if pck_atributo.Tipo_TEXTO = rec_atributo.tipo then
                
                  if upper(substr(lv_valor1, 1, length(lv_valor2))) = upper(lv_valor2) then
                     return true;
                  else
                     return false;
                  end if;
               end if;
                
            elsif 'TV' = rec_campose.condicional then

               if pck_atributo.Tipo_TEXTO = rec_atributo.tipo then

                  if upper(substr(lv_valor1, 1 + length(lv_valor1) - length(lv_valor2) )) = upper(lv_valor2) then
                     return true;
                  else
                     return false;
                  end if;
               end if;

            elsif 'PO' = rec_campose.condicional then
             
               if pck_atributo.Tipo_TEXTO = rec_atributo.tipo then
                  dbms_output.put_line('separador: '||rec_campose.separador );
                  if rec_campose.separador is not null then
                     return f_compara_listas(lv_valor1,lv_valor2,rec_campose.separador);
                  elsif instr(lv_valor1, lv_valor2) > 0 then
                     return true;
                  else
                     return false;
                  end if;
               end if;
                
            elsif 'MA' = rec_campose.condicional then
             
               if pck_atributo.Tipo_DATA = rec_atributo.tipo then
                
                  if to_date(lv_valor1,'dd/mm/yyyy') > to_date(lv_valor2,'dd/mm/yyyy') then
                     return true;
                  else
                     return false;
                  end if;
                   
               elsif pck_atributo.Tipo_NUMERO = rec_atributo.tipo or
                     pck_atributo.Tipo_MONETARIO = rec_atributo.tipo or
                     pck_atributo.Tipo_HORA = rec_atributo.tipo then
                      
                  if to_number(lv_valor1, '99999999999999999990D099999999999999999999','NLS_NUMERIC_CHARACTERS =''.,''') > to_number(lv_valor2, '99999999999999999990D099999999999999999999','NLS_NUMERIC_CHARACTERS =''.,''') then
                     return true;
                  else
                     return false;
                  end if;
                   
               end if;
                
            elsif 'MI' = rec_campose.condicional then

               if pck_atributo.Tipo_DATA = rec_atributo.tipo then
                
                  if to_date(lv_valor1,'dd/mm/yyyy') >= to_date(lv_valor2,'dd/mm/yyyy') then
                     return true;
                  else
                     return false;
                  end if;
                   
               elsif pck_atributo.Tipo_NUMERO = rec_atributo.tipo or
                     pck_atributo.Tipo_MONETARIO = rec_atributo.tipo or
                     pck_atributo.Tipo_HORA = rec_atributo.tipo then
                      
                  if to_number(lv_valor1, '99999999999999999990D099999999999999999999','NLS_NUMERIC_CHARACTERS =''.,''') >= to_number(lv_valor2, '99999999999999999990D099999999999999999999','NLS_NUMERIC_CHARACTERS =''.,''') then
                     return true;
                  else
                     return false;
                  end if;
                   
               end if;
                
            elsif 'ME' = rec_campose.condicional then

               if pck_atributo.Tipo_DATA = rec_atributo.tipo then
                
                  if to_date(lv_valor1,'dd/mm/yyyy') < to_date(lv_valor2,'dd/mm/yyyy') then
                     return true;
                  else
                     return false;
                  end if;
                   
               elsif pck_atributo.Tipo_NUMERO = rec_atributo.tipo or
                     pck_atributo.Tipo_MONETARIO = rec_atributo.tipo or
                     pck_atributo.Tipo_HORA = rec_atributo.tipo then
                      
                  if to_number(lv_valor1, '99999999999999999990D099999999999999999999','NLS_NUMERIC_CHARACTERS =''.,''') < to_number(lv_valor2, '99999999999999999990D099999999999999999999','NLS_NUMERIC_CHARACTERS =''.,''') then
                     return true;
                  else
                     return false;
                  end if;
                   
               end if;
                
            elsif 'NI' = rec_campose.condicional then

               if pck_atributo.Tipo_DATA = rec_atributo.tipo then
                
                  if to_date(lv_valor1,'dd/mm/yyyy') <= to_date(lv_valor2,'dd/mm/yyyy') then
                     return true;
                  else
                     return false;
                  end if;
                   
               elsif pck_atributo.Tipo_NUMERO = rec_atributo.tipo or
                     pck_atributo.Tipo_MONETARIO = rec_atributo.tipo or
                     pck_atributo.Tipo_HORA = rec_atributo.tipo then
                  if to_number(lv_valor1, '99999999999999999990D099999999999999999999','NLS_NUMERIC_CHARACTERS =''.,''') <= to_number(lv_valor2, '99999999999999999990D099999999999999999999','NLS_NUMERIC_CHARACTERS =''.,''') then
                     return true;
                  else
                     return false;
                  end if;
                   
               end if;
                
            elsif 'DI' = rec_campose.condicional then
             
               if pck_atributo.Tipo_LISTA = rec_atributo.tipo then

                  if (lv_valor1 is null) and trim(lv_valor2) is not null then
                     return true;
                  elsif lv_valor1 is not null and trim(lv_valor2) is null then
                     return true;
                  elsif lv_valor1 <> lv_valor2 then
                     return true;
                  else
                     return false;
                  end if;

               elsif pck_atributo.Tipo_DATA = rec_atributo.tipo then
                
                  if (lv_valor1 is null) and trim(lv_valor2) is not null then
                     return true;
                  elsif lv_valor1 is not null and trim(lv_valor2) is null then
                     return true;
                  elsif to_date(lv_valor1,'dd/mm/yyyy') <> to_date(lv_valor2,'dd/mm/yyyy') then
                     return true;
                  else
                     return false;
                  end if;
                  
               elsif pck_atributo.Tipo_NUMERO = rec_atributo.tipo or
                     pck_atributo.Tipo_MONETARIO = rec_atributo.tipo or
                     pck_atributo.Tipo_HORA = rec_atributo.tipo then
                
                  if (lv_valor1 is null) and trim(lv_valor2) is not null then
                     return true;
                  elsif lv_valor1 is not null and trim(lv_valor2) is null then
                     return true;
                  elsif to_number(lv_valor1, '99999999999999999990D099999999999999999999','NLS_NUMERIC_CHARACTERS =''.,''') <> to_number(lv_valor2, '99999999999999999990D099999999999999999999','NLS_NUMERIC_CHARACTERS =''.,''') then
                     return true;
                  else
                     return false;
                  end if;
                   
               end if;
                
            elsif 'SV' = rec_campose.condicional then
             
               if pck_atributo.Tipo_LISTA = rec_atributo.tipo or pck_atributo.Tipo_LISTA_MULTIPLA_ESCOLHA = rec_atributo.tipo then
                  if trim(lv_valor1) is null then
                     return true;
                  else
                     return false;
                  end if;
               end if;
               
            end if;
             
         end if;
          
      else
         lv_valor1 := f_valorcomparacao(rec_campose.chave_campo, rec_demanda, pprojeto, rec_campose.valor_teste);
         dbms_output.put_line('lv_valor1: '||lv_valor1);
         if rec_campose.comparar_dinamicamente = 'Y' then
            lv_valor2 := f_valorcomparacao(substr(rec_campose.valor_teste, 1+length('DINAMIC_')), rec_demanda, pprojeto, null);
         else
            lv_valor2 := upper(rec_campose.valor_teste);
         end if;
         dbms_output.put_line('lv_valor2: '||lv_valor2);
            dbms_output.put_line('2');
             
         if rec_campose.chave_campo = 'DESTINO' or
            rec_campose.chave_campo = 'EMPRESA' or
            rec_campose.chave_campo = 'PRIORIDADE' or
            rec_campose.chave_campo = 'PRIORIDADE_ATENDIMENTO' or
            rec_campose.chave_campo = 'UO' or
            rec_campose.chave_campo = 'TIPO' or
            rec_campose.chave_campo = 'CRIADOR' or
            rec_campose.chave_campo = 'SOLICITANTE' or
            rec_campose.chave_campo = 'RESPONSAVEL' or
            rec_campose.chave_campo = 'ATUALIZACAO_AUTOMATICA' then
            if lv_valor1 = lv_valor2 then
               return true;
            end if;
         elsif rec_campose.chave_campo = 'TITULO' then
            if 'IG' = upper(rec_campose.condicional) then
               if upper(lv_valor1) = upper(lv_valor2) then
                  return true;
               else
                  return false;
               end if;
            elsif 'DI' = upper(rec_campose.condicional) then
               if upper(lv_valor1) <> upper(lv_valor2) then
                  return true;
               else
                  return false;
               end if;
            elsif 'IN' = upper(rec_campose.condicional) then
               if upper(substr(lv_valor1,1,length(lv_valor2))) = upper(lv_valor2) then
                  return true;
               else
                  return false;
               end if;
            elsif 'TV' = upper(rec_campose.condicional) then
               if upper(substr(lv_valor1, 1+ length(lv_valor1) - length(lv_valor2))) = upper(lv_valor2) then
                  return true;
               else
                  return false;
               end if;
            elsif 'PO' = upper(rec_campose.condicional) then
               if instr(upper(lv_valor1), upper(lv_valor2)) > 0  then
                  return true;
               else
                  return false;
               end if;
            end if;
         
         elsif rec_campose.chave_campo = 'DATAS_PREVISTAS' or
               rec_campose.chave_campo = 'DATAS_REALIZADAS' or
               rec_campose.chave_campo = 'PROJ_DATA_FINAL_PREVISTA' then
               
            if trim(lv_valor1) is null or trim(lv_valor2) is null then
               return false;
            end if;
         
            if 'IG' = upper(rec_campose.condicional) then
               if to_date(lv_valor1,'dd/mm/yyyy') = to_date(lv_valor2,'dd/mm/yyyy') then
                  return true;
               else
                  return false;
               end if;
            elsif 'MA' = upper(rec_campose.condicional) then
               if to_date(lv_valor1,'dd/mm/yyyy')  > to_date(lv_valor2,'dd/mm/yyyy') then
                  return true;
               else
                  return false;
               end if;
            elsif 'MI' = upper(rec_campose.condicional) then
               if to_date(lv_valor1,'dd/mm/yyyy') >= to_date(lv_valor2,'dd/mm/yyyy') then
                  return true;
               else
                  return false;
               end if;
            elsif 'ME' = upper(rec_campose.condicional) then
               if to_date(lv_valor1,'dd/mm/yyyy') < to_date(lv_valor2,'dd/mm/yyyy') then
                  return true;
               else
                  return false;
               end if;
            elsif 'NI' = upper(rec_campose.condicional) then
               if to_date(lv_valor1,'dd/mm/yyyy') <= to_date(lv_valor2,'dd/mm/yyyy') then
                  return true;
               else
                  return false;
               end if;
            elsif 'DI' = upper(rec_campose.condicional) then
               if lv_valor1 is null and lv_valor2 is not null then
                  return true;
               elsif lv_valor1 is not null and lv_valor2 is null then
                  return true;
               elsif to_date(lv_valor1,'dd/mm/yyyy') <> to_date(lv_valor2,'dd/mm/yyyy') then
                  return true;
               else
                  return false;
               end if;
            end if;
         elsif rec_campose.chave_campo = 'PESO' or 
               rec_campose.chave_campo = 'PROJ_DURACAO_PREVISTA_DC' or 
               rec_campose.chave_campo = 'PROJ_DURACAO_PREVISTA_DU' or 
               rec_campose.chave_campo = 'PROJ_HORAS_PREVISTAS' then
         
            if rec_campose.chave_campo = 'PROJ_HORAS_PREVISTAS' then
               if instr(lv_valor2,':') > 0 then
                  lv_valor2 := horamin(lv_valor2);
               end if;
            end if;
            if 'IG' = upper(rec_campose.condicional) then
               if to_number(lv_valor1) = to_number(lv_valor2) then
                  return true;
               else
                  return false;
               end if;
            elsif 'MA' = upper(rec_campose.condicional) then
               if to_number(lv_valor1) > to_number(lv_valor2) then
                  return true;
               else
                  return false;
               end if;
            elsif 'MI' = upper(rec_campose.condicional) then
               if to_number(lv_valor1) >= to_number(lv_valor2) then
                  return true;
               else
                  return false;
               end if;
            elsif 'ME' = upper(rec_campose.condicional) then
               if to_number(lv_valor1) < to_number(lv_valor2) then
                  return true;
               else
                  return false;
               end if;
            elsif 'NI' = upper(rec_campose.condicional) then
               if to_number(lv_valor1) <= to_number(lv_valor2) then
                  return true;
               else
                  return false;
               end if;
            elsif 'DI' = upper(rec_campose.condicional) then
               if lv_valor1 is null and lv_valor2 is not null then
                  return true;
               elsif lv_valor1 is not null and lv_valor2 is null then
                  return true;
               elsif to_number(lv_valor1) <> to_number(lv_valor2) then
                  return true;
               else
                  return false;
               end if;
            end if;
         else
            if rec_campose.chave_campo = 'PROJ_ARVORE_CUSTO' then
               tab_valor_teste := pck_geral.f_split(rec_campose.valor_teste, ':;:');
               lv_valor2 := to_number(tab_valor_teste(tab_valor_teste.count));
            end if;
            if 'IG' = upper(rec_campose.condicional) then
               if upper(lv_valor1) = upper(lv_valor2) then
                  return true;
               else
                  return false;
               end if;
            elsif 'DI' = upper(rec_campose.condicional) then
               if upper(lv_valor1) <> upper(lv_valor2) then
                  return true;
               else
                  return false;
               end if;
            elsif 'IN' = upper(rec_campose.condicional) then
               if upper(substr(lv_valor1,1,length(lv_valor2))) = upper(lv_valor2) then
                  return true;
               else
                  return false;
               end if;
            elsif 'TV' = upper(rec_campose.condicional) then
               if upper(substr(lv_valor1, 1+ length(lv_valor1) - length(lv_valor2))) = upper(lv_valor2) then
                  return true;
               else
                  return false;
               end if;
            elsif 'PO' = upper(rec_campose.condicional) then
               if rec_campose.separador is not null then
                  return f_compara_listas(lv_valor1,lv_valor2,rec_campose.separador);
               elsif instr(upper(lv_valor1), upper(lv_valor2)) > 0  then
                  return true;
               else
                  return false;
               end if;
            elsif 'PM' = upper(rec_campose.condicional) then
               tab_valor_teste := pck_geral.f_split(rec_campose.valor_teste, ':;:');
               lv_valor2 := f_ValorComparacao('PROJ_ORC_TOTAL',rec_demanda, pprojeto, null);
               ln_orcamento := to_number(lv_valor2, '99999999999999999990D099999999999999999999','NLS_NUMERIC_CHARACTERS =''.,''');
               ln_perc := to_number(tab_valor_teste(tab_valor_teste.count));
               ln_orcamento := ln_orcamento *  ln_perc/100;
               if to_number(lv_valor1, '99999999999999999990D099999999999999999999','NLS_NUMERIC_CHARACTERS =''.,''') <= ln_orcamento then
                  return true;
               else
                  return false;
               end if;
            elsif 'PI' = upper(rec_campose.condicional) then
               tab_valor_teste := pck_geral.f_split(rec_campose.valor_teste, ':;:');
               lv_valor2 := f_ValorComparacao('PROJ_ORC_TOTAL',rec_demanda, pprojeto, null);
               ln_orcamento := to_number(lv_valor2, '99999999999999999990D099999999999999999999','NLS_NUMERIC_CHARACTERS =''.,''') *  to_number(tab_valor_teste(tab_valor_teste.count))/100;
               if to_number(lv_valor1, '99999999999999999990D099999999999999999999','NLS_NUMERIC_CHARACTERS =''.,''') >= ln_orcamento then
                  return true;
               else
                  return false;
               end if;
            end if;
         end if;
      end if;

		  return false;
   end;

   function f_AlteraDemandaPorCondicional ( rec_demanda in out demanda%rowtype, pprojetos in out nocopy tab_projeto, se condicional_se_senao%rowtype, senao condicional_se_senao%rowtype, pv_usuario usuario.usuarioid%type, pn_estado_id in out number, pn_estado_mensagem_id in out number, pn_enviar_email in out number, pn_gerar_baseline in out number, pv_retorno_campos in out varchar2) return boolean is 
   tab_SeSenao tr_SeSenao;
   type tr_acao is table of acao_condicional%rowtype index by binary_integer;
   tab_acao tr_acao;
   acao_vazia acao_condicional%rowtype;
   sesenao_vazio condicional_se_senao%rowtype;
   ln_contador binary_integer;
   ln_total binary_integer;
   
   cond_Se condicional_se_senao%rowtype;
   cond_Senao condicional_se_senao%rowtype;
   
   lb_ocorreu_alteracao boolean := false;
   
   lb_condicao_satisfeita boolean := false;
   
   lb_alterou boolean;
   
   begin
         dbms_output.put_line('demanda_id: '||rec_demanda.demanda_id);
         dbms_output.put_line('Regra Condicional: '||se.regra_condicional_id);
         dbms_output.put_line('se.id: '||se.id);
         dbms_output.put_line('senao.id: '||senao.id);
         
            lb_condicao_satisfeita := false;
            for cCampoCond in (select * from campo_condicional_se c where c.condicional_se_id = se.id) loop
               if pprojetos.count = 0 then
                  if f_Condicional_Satisfeito(cCampoCond, rec_demanda, null) then
                     lb_condicao_satisfeita := true;
                     exit;
                  end if;
               else
                  lb_condicao_satisfeita := true;
                  for ln_i_proj in 1..pprojetos.count loop
                     if not f_Condicional_Satisfeito(cCampoCond, rec_demanda, pprojetos(ln_i_proj)) then
                        lb_condicao_satisfeita := false;
                        exit;
                     end if;
                  end loop;
                  if lb_condicao_satisfeita then
                     exit;
                  end if;
               end if;
            end loop;
/*         else
            lb_condicao_satisfeita := true;
            for cCampoCond in (select * from campo_condicional_se c where c.condicional_se_id = se.id) loop
               if pprojetos.count = 0 then
                  if not f_Condicional_Satisfeito(cCampoCond, rec_demanda, null) then
                     lb_condicao_satisfeita := false;
                     exit;
                  end if;
               else
                  for ln_i_proj in 1..pprojetos.count loop
                     if not f_Condicional_Satisfeito(cCampoCond, rec_demanda, pprojetos(ln_i_proj)) then
                        lb_condicao_satisfeita := false;
                        exit;
                     end if;
                  end loop;
                  if not lb_condicao_satisfeita then
                     exit;
                  end if;
               end if;
            end loop;
         end if;*/
         
         if lb_condicao_satisfeita then
            select nvl(max(ordem),-1)
            into ln_total
            from (select max(ordem) ordem
                  from condicional_se_senao c
                  where regra_condicional_id = se.regra_condicional_id
                  and   c.id_se_pai = se.id
                  union 
                  select max(ordem) from acao_condicional where condicional_se_id = se.id);
            for ln_contador in 0..ln_total loop
               tab_sesenao(ln_contador) := sesenao_vazio;
               tab_acao(ln_contador) := acao_vazia;
            end loop;
              
            for cSeSenao in (select c.* 
                             from condicional_se_senao c
                             where regra_condicional_id = se.regra_condicional_id
                             and   c.id_se_pai = se.id
                             order by c.ordem) loop
                             
               tab_sesenao(cSeSenao.ordem) := cSeSenao;
               tab_acao(cSeSenao.ordem) := acao_vazia;
            end loop;
             
            for cAcao in (select * from acao_condicional where condicional_se_id = se.id) loop
               lb_ocorreu_alteracao := true;
               if cAcao.ordem > tab_sesenao.count then
                  tab_sesenao(cAcao.ordem) := sesenao_vazio;
               end if;
               tab_acao(cAcao.ordem) := cAcao;
            end loop;

            for ln_contador in 0..tab_sesenao.count-1 loop
               if tab_sesenao(ln_contador).id >=0  then
                   if tab_SeSenao(ln_contador).is_senao is null or tab_SeSenao(ln_contador).is_senao = 'N' then
                      cond_Se := tab_SeSenao(ln_contador);
                      if ln_contador + 1 <= tab_sesenao.count-1 then
                         if tab_SeSenao(ln_contador+1).is_senao = 'Y' then
                            cond_Senao := tab_SeSenao(ln_contador+1);
                         else
                            cond_Senao := null;
                         end if;
                      end if;
                       
                      lb_alterou := f_AlteraDemandaPorCondicional ( rec_demanda, pprojetos, cond_Se, cond_Senao, pv_usuario, pn_estado_id, pn_estado_mensagem_id, pn_enviar_email, pn_gerar_baseline, pv_retorno_campos );
                       
                      if not lb_ocorreu_alteracao then
                         lb_ocorreu_alteracao := lb_alterou;
                      end if;
                      
                      if pn_estado_id > 0 then
                         return lb_ocorreu_alteracao;
                      end if;
                   end if;  
               end if;
               if tab_acao(ln_contador).id >=0 then
                  if tab_acao(ln_contador).acao = 'DE' or tab_acao(ln_contador).acao = 'EX' or
                    tab_acao(ln_contador).acao = 'HA' or tab_acao(ln_contador).acao = 'OC' or
                    tab_acao(ln_contador).acao = 'OB' or tab_acao(ln_contador).acao = 'OP' then
                    
                    p_VerificaAcaoCondicionalCampo(rec_demanda, tab_acao(ln_contador), pv_retorno_campos);
                 else
                    p_ExecutaAcaoCondicional(rec_demanda, pprojetos, tab_acao(ln_contador), pv_usuario, pn_estado_id, pn_estado_mensagem_id, pn_enviar_email, pn_gerar_baseline);
                 end if;
               end if;
            end loop;
         else
            dbms_output.put_line('condicional_se_id: '||senao.id);
            select nvl(max(ordem),-1)
            into ln_total
            from (select max(ordem) ordem
                  from condicional_se_senao c
                  where regra_condicional_id = senao.regra_condicional_id
                  and   c.id_se_pai = senao.id
                  union 
                  select max(ordem) from acao_condicional where condicional_se_id = senao.id);
            for ln_contador in 0..ln_total loop
               tab_sesenao(ln_contador) := sesenao_vazio;
               tab_acao(ln_contador) := acao_vazia;
            end loop;
            for cSeSenao in (select c.* 
                             from condicional_se_senao c
                             where regra_condicional_id = senao.regra_condicional_id
                             and   c.id_se_pai = senao.id
                             order by c.ordem) loop
                
               tab_sesenao(cSeSenao.ordem) := cSeSenao;
               tab_acao(cSeSenao.ordem) := acao_vazia;
            end loop;
             
            for cAcao in (select * from acao_condicional where condicional_se_id = senao.id) loop
               lb_ocorreu_alteracao := true;
               if cAcao.ordem > tab_sesenao.count then
                  tab_sesenao(cAcao.ordem) := sesenao_vazio;
               end if;
               tab_acao(cAcao.ordem) := cAcao;
            end loop;
            
            for ln_contador in 0..tab_sesenao.count-1 loop
               if tab_sesenao(ln_contador).id >=0  then
                   if tab_SeSenao(ln_contador).is_senao is null or tab_SeSenao(ln_contador).is_senao = 'N' then
                      cond_Se := tab_SeSenao(ln_contador);
                      if ln_contador + 1 <= tab_sesenao.count-1 then
                         if tab_SeSenao(ln_contador+1).is_senao = 'Y' then
                            cond_Senao := tab_SeSenao(ln_contador+1);
                         else
                            cond_Senao := null;
                         end if;
                      end if;
                       
                      lb_alterou := f_AlteraDemandaPorCondicional ( rec_demanda, pprojetos, cond_Se, cond_Senao, pv_usuario, pn_estado_id, pn_estado_mensagem_id, pn_enviar_email, pn_gerar_baseline, pv_retorno_campos );
                       
                      if not lb_ocorreu_alteracao then
                         lb_ocorreu_alteracao := lb_alterou;
                      end if;
                      
                      if pn_estado_id > 0 then
                         return lb_ocorreu_alteracao;
                      end if;
                   end if;
               end if;

               if tab_acao(ln_contador).id >= 0 then
                 if tab_acao(ln_contador).acao = 'DE' or tab_acao(ln_contador).acao = 'EX' or
                    tab_acao(ln_contador).acao = 'HA' or tab_acao(ln_contador).acao = 'OC' or
                    tab_acao(ln_contador).acao = 'OB' or tab_acao(ln_contador).acao = 'OP' then
                    
                    p_VerificaAcaoCondicionalCampo(rec_demanda, tab_acao(ln_contador), pv_retorno_campos);
                 else
                    p_ExecutaAcaoCondicional(rec_demanda, pprojetos, tab_acao(ln_contador), pv_usuario, pn_estado_id, pn_estado_mensagem_id, pn_enviar_email, pn_gerar_baseline);
                 end if;
               end if;
            end loop;
         end if;

      return lb_ocorreu_alteracao;
   end;
   
   procedure p_busca_informacoes (pn_demanda_id demanda.demanda_id%type, pdemanda in out nocopy demanda%rowtype, pprojeto in out nocopy tab_projeto) is
   ln_qtd_proj number := 0;
   ln_temp number := 0;
   begin
      select *
      into pdemanda
      from demanda
      where demanda_id = pn_demanda_id
      for update;
      
      for c in (select p.* 
                from solicitacaoentidade s, projeto p
                where s.solicitacao = pn_demanda_id
                and   s.tipoentidade = 'P'
                and   s.identidade = p.id
                for update) loop
         ln_qtd_proj := ln_qtd_proj + 1;
         pprojeto(ln_qtd_proj) := c;

         for c1 in (select * from atributoentidadevalor where tipoentidade = 'P' and identidade = c.id for update) loop
            ln_temp:=1;
         end loop;
      
      end loop;
      
      for c in (select * from atributo_valor where demanda_id = pn_demanda_id for update) loop
         ln_temp:=1;
      end loop;

   end;

   procedure p_ExecutarRegrasCondicionais (pn_demanda_id demanda.demanda_id%type, pv_usuario usuario.usuarioid%type, pn_ret out number) is
     ln_estado_id number;
     ln_estado_mensagem_id number:=null;
     ln_gerar_baseline number:=0;
     ln_enviar_email number:=0;
     lv_retorno_campos varchar(4000);
   begin
     p_ExecutarRegrasCondicionaisP (pn_demanda_id, null, pv_usuario, pn_ret, ln_estado_id, ln_estado_mensagem_id, ln_enviar_email, ln_gerar_baseline, lv_retorno_campos);
   end;
   
   procedure p_ExecutarRegrasCondicionaisP (pn_demanda_id demanda.demanda_id%type, 
                                            pn_prox_estado number, 
                                            pv_usuario usuario.usuarioid%type, 
                                            pn_ret in out number, 
                                            pn_estado_id in out number, 
                                            pn_estado_mensagem_id in out estado_mensagens.id%type, 
                                            pn_enviar_email in out number, 
                                            pn_gerar_baseline in out number,
                                            pv_retorno_campos in out varchar2) is
   
   tab_SeSenao tr_SeSenao;
   ln_contador binary_integer;
   ln_total binary_integer;
   
   cond_Se condicional_se_senao%rowtype;
   cond_Senao condicional_se_senao%rowtype;
   
   lb_alterou boolean:=false;
   lb_ocorreu_alteracao boolean:=false;
   
   rec_demanda demanda%rowtype;
   projetos tab_projeto;
   
   begin
   
      dbms_output.put_line('pv_retorno_campos: '|| pv_retorno_campos);
   
      if rodando then
         return;
      end if;
   
      rodando := true;
     
      pn_ret := 1; 
      pn_estado_id := 0; 
      pn_estado_mensagem_id := null; 
      pn_enviar_email := 0; 
      pn_gerar_baseline := 0;

      p_busca_informacoes (pn_demanda_id, rec_demanda, projetos);
   
      dbms_output.put_line('busca informacoes!!');
   
      for cRegras in (select r.id regra_condicional_id 
                      from demanda d, regra_condicional r, estado_regra_condicional e 
                      where d.demanda_id = pn_demanda_id
                      and   d.formulario_id = r.formulario_id
                      and   r.id = e.regra_condicional_id
                      and   r.formulario_id = e.formulario_id
                      and   pn_prox_estado is null 
                      and   d.situacao = e.estado_id and e.estado_origem_id is null
                      union
                      select r.id regra_condicional_id 
                      from demanda d, regra_condicional r, estado_regra_condicional e 
                      where d.demanda_id = pn_demanda_id
                      and   d.formulario_id = r.formulario_id
                      and   r.id = e.regra_condicional_id
                      and   r.formulario_id = e.formulario_id
                      and   pn_prox_estado = e.estado_id 
                      and   e.estado_origem_id = d.situacao) loop
         
         dbms_output.put_line('regras');
         ln_total := 0;
         for cSeSenao in (select c.* 
                          from condicional_se_senao c
                          where regra_condicional_id = cRegras.regra_condicional_id
                          and   c.id_se_pai is null
                          order by c.ordem) loop
            
            dbms_output.put_line('sesenao');
            ln_total := ln_total + 1;
            
            tab_sesenao(ln_total) := cSeSenao;
         end loop;
         
         for ln_contador in 1..ln_total loop
            if tab_SeSenao(ln_contador).is_senao is null or tab_SeSenao(ln_contador).is_senao = 'N' then
               cond_Se := tab_SeSenao(ln_contador);
               if ln_contador + 1 <= ln_total then
                  if tab_SeSenao(ln_contador+1).is_senao = 'Y' then
                     cond_Senao := tab_SeSenao(ln_contador+1);
                  else
                     cond_Senao := null;
                  end if;
               end if;
               
               lb_alterou := f_AlteraDemandaPorCondicional ( rec_demanda, projetos, cond_Se, cond_Senao, pv_usuario, pn_estado_id, pn_estado_mensagem_id, pn_enviar_email, pn_gerar_baseline, pv_retorno_campos);
               
               if not lb_ocorreu_alteracao then
                  lb_ocorreu_alteracao := lb_alterou;
               end if;
               
               if pn_estado_id > 0 then
                  if lb_ocorreu_alteracao then
                     pn_ret := 1;
                  else
                     pn_ret := 0;
                  end if;
                  
                  rodando:=false;
                  return;
               end if;
            end if;
            
         end loop;
      end loop;
      
      if lb_ocorreu_alteracao then
         pn_ret := 1;
      else
         pn_ret := 0;
      end if;
      
      rodando:=false;
      
   exception 
   when others then
        rodando := false;
        raise;
   end;
   
  procedure p_ExecRegrasFormulario (pn_formulario_id formulario.formulario_id%type) is 
  ln_ret number;
  ln_retorno_campos varchar2(4000);
  begin
  
     for c in (select demanda_id 
               from demanda d, estado_formulario ef
               where d.formulario_id = pn_formulario_id
               and d.formulario_id = ef.formulario_id
               and d.situacao = ef.estado_id
               and (ef.estado_final = 'N' or ef.estado_final is null)) loop
        begin
        p_ExecutarRegrasCondicionais (c.demanda_id, 'auto', ln_ret);
        /*exception
        when others then
           raise_application_error(-20001, c.demanda_id);*/
        end;
     end loop;
 
  end;
  
  procedure p_NomeBaseline(pn_demanda_id demanda.demanda_id%type, pn_estado_id demanda.situacao%type, pn_projeto_id projeto.id%type, pn_acao_id acao_condicional.id%type, pv_nome out varchar2 ) is
  lt_campos pck_geral.t_varchar_array;
  lv_nome acao_condicional.valor_troca%type;
  lv_retorno varchar2(4000);
  lv_item varchar2(4000);
  begin
    select valor_troca
    into lv_nome
    from acao_condicional
    where id = pn_acao_id;
    
    lt_campos := pck_geral.f_split(lv_nome, ':;:');
    
    for ln_i in 1..lt_campos.count loop
    
       if 'ET' = lt_campos(ln_i) then
          select pn_projeto_id || ' - ' || titulo
          into lv_item
          from projeto
          where id = pn_projeto_id;
       elsif 'ID' = lt_campos(ln_i) then
          lv_item := pn_Demanda_id;
       elsif 'DG' = lt_campos(ln_i) then
          lv_item := to_char(sysdate, 'dd/mm/yyyy');
       elsif 'HG' = lt_campos(ln_i) then
          lv_item := to_char(sysdate, 'dd/mm/yyyy hh24:mi');
       elsif 'IE' = lt_campos(ln_i) then
          lv_item := pn_projeto_id;
       elsif 'TE' = lt_campos(ln_i) then
          select titulo
          into lv_item
          from projeto
          where id = pn_projeto_id;
       elsif 'ED' = lt_campos(ln_i) then
          select termo.texto_termo
          into lv_item
          from estado, termo
          where estado_id = pn_estado_id
          and   titulo_termo_id = termo_id;
       else
          lv_item := lt_campos(ln_i);
       end if;
    
       lv_retorno := lv_retorno || lv_item;
    end loop;
    
    pv_nome := lv_retorno;
    
  end;
  
end;
/


create or replace package pck_atributo is

--Tipos de Atributos
Tipo_LISTA                    varchar2(1) := 'L';
Tipo_DATA                     varchar2(1) := 'd';
Tipo_BOOLEANO                 varchar2(1) := 'B';
Tipo_TEXTO                    varchar2(1) := 'T';
Tipo_NUMERO                   varchar2(1) := 'N';
Tipo_LISTA_MULTIPLA_ESCOLHA   varchar2(1) := 'M';
Tipo_AREA_TEXTO               varchar2(1) := 'A';
Tipo_USUARIO                  varchar2(1) := 'U';
Tipo_TEXTO_HTML               varchar2(1) := 'H';
Tipo_ARVORE                   varchar2(1) := 'R';
Tipo_HORA                     varchar2(1) := 'O';
Tipo_MONETARIO                varchar2(1) := 'I';
Tipo_EMPRESA                  varchar2(1) := 'E';
Tipo_PROJETO                  varchar2(1) := 'P';
Tipo_DOCUMENTO                varchar2(1) := 'C';
Tipo_OBJETO                   varchar2(1) := 'J';
Tipo_UF                       varchar2(1) := 'F';

--Formatos de Atributos de tipo lista
FORMATO_LISTA_COMBO            varchar2(2) := 'CB';
FORMATO_LISTA_RADIO_VERTICAL   varchar2(2) := 'RV';
FORMATO_LISTA_RADIO_HORIZONTAL varchar2(2) := 'RH';
FORMATO_LISTA_SIMPLES          varchar2(2) := 'LS';
FORMATO_LISTA_MULTISELECAO     varchar2(2) := 'LM';
FORMATO_ARVORE_SIMPLES         varchar2(2) := 'AS';
FORMATO_ARVORE_MULTISELECAO    varchar2(2) := 'AM';


type t_rec_atributo is record (
   row_id rowid);
   
type tt_array_atributos is table of t_rec_atributo index by binary_integer;

gt_atributos_alterados tt_array_atributos;
gt_array_vazio        tt_array_atributos;

end;
/
create or replace package body pck_atributo is

end;
/

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Finalização
-------------------------------------------------------------------------------
insert into versao_tgp (id, nome, data_lancamento) 
       values(4, '6.0.1', to_date('22/11/2010', 'dd/mm/yyyy'));
       
insert into versao(id, titulo, patch, versao_tgp_id, comentario)
       values (versao_seq.nextval, '6.0.1', '0', 4, 'Migração de Versão');
commit;
/

begin
  pck_processo.precompila;
  commit;
end;
/
                      
select * from v_versao;
/
