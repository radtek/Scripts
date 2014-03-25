/*****************************************************************************\ 
 * TraceGP 6.0.1.7                                                           *
\*****************************************************************************/
--define CS_TBL_DAT = &TABLESPACE_DADOS;
--define CS_TBL_IND = &TABLESPACE_INDICES;
-------------------------------------------------------------------------------

-- Tabelas -- Alterações
alter table avaliacaoqualidade modify observacao varchar2(2000);

alter table configuracoes add limpar_cookie_logoff varchar2(1) default 'Y' not null;

alter table EVA add PERCENTUAL_CONCLUIDO NUMBER(21,2) default 0 not null;
comment on column EVA.PERCENTUAL_CONCLUIDO
  is 'Percentual concluído do momento da inclusão na tabela, para que siga a funcionalidade de D - 1';

alter table EVA_TEMPO add PERCENTUAL_CONCLUIDO number(21,2) default 0 not null;
comment on column EVA_TEMPO.PERCENTUAL_CONCLUIDO
  is 'Percentual concluído do momento da inclusão na tabela, para que siga a funcionalidade de D - 1';

alter table FORMULARIO add OBRIGATORIO_DATAS_PREVISTAS  varchar2(1) default 'N' not null;
alter table FORMULARIO add OBRIGATORIO_DATAS_REALIZADAS varchar2(1) default 'N' not null;

alter table mapeamento_atributo_abertura add pai number(10);
comment on column mapeamento_atributo_abertura.pai is 'Id do Mapeamento Pai (recursivo)';

alter table relat_dataset_campo modify titulo varchar2(100);

alter table RELAT_RELATORIO add ALTURA number(10);
comment on column RELAT_RELATORIO.ALTURA is 'Tamanho da área de criação';

-- Sequences
-- Create sequence 
create sequence IMPACTO_SEQ
  minvalue 1 maxvalue 999999999999999999999999999
  start with 1 increment by 1 nocache;
  
insert into versao_sequencia(id, versao_tgp_id, nome_sequencia, tabela, coluna)
       values (versao_sequencia_seq.nextval, 4, 'IMPACTO_SEQ', 'IMPACTO', 'IMPACTOID');
commit;
/       

insert into tela (TELAID, nome, url, visivel, grupoid, ordem, codigo, subgrupo, atalho)
values  ((select max(telaid) + 1 from tela),    'bd.tela.telaEntidades', 'Entidade.do?command=defaultAction',   
          'S', 7, 54,    'ENTIDADES',    'PRIMEIRO', 'N');
commit;
/          
 
-- Views

create or replace view v_eva_percentual_dados as
select vd.dia, pc.entidade_id, pc.tipo_entidade, pc.perc_concluido
  from percentual_concluido pc,
       v_dias               vd
 where pc.data = (select max(pc2.data) from percentual_concluido pc2
                    where pc2.tipo_entidade = pc.tipo_entidade
                      and pc2.entidade_id   = pc.entidade_id
                      and pc2.data         <= vd.dia);
                      
create or replace view v_eva as
select vecd.dia, vecd.tipo_entidade, vecd.entidade_id, vecd.projeto_id,
       vecd.tipo_entidade_pai, vecd.entidade_id_pai, vecd.titulo,
       vecd.pv, vecd.ac, vecd.bac, vepd.perc_concluido,
       vecd.bac * (vepd.perc_concluido/100) EV,
       (vecd.bac * (vepd.perc_concluido/100)) - vecd.ac CV,
       (vecd.bac * (vepd.perc_concluido/100)) - vecd.pv SV,
       decode(vecd.ac, 0, 1, (vecd.bac * (vepd.perc_concluido/100)) / vecd.ac) CPI,
       decode(vecd.pv, 0, 1, (vecd.bac * (vepd.perc_concluido/100)) / vecd.pv) SPI,
       decode(vecd.bac - vecd.ac, 0, 0, (vecd.bac - (vecd.bac * (vepd.perc_concluido/100))) / (vecd.bac - vecd.ac)) TCPI,
       decode(vecd.bac * vepd.perc_concluido, 0, vecd.bac, (vecd.bac - vecd.bac * (vepd.perc_concluido/100) )/(decode(vecd.ac, 0, 1, (vecd.bac * (vepd.perc_concluido/100)) / vecd.ac)) ) ETC,
       vecd.ac + decode(vecd.bac * vepd.perc_concluido, 0, vecd.bac, (vecd.bac - vecd.bac * (vepd.perc_concluido/100))/(decode(vecd.ac, 0, 1, (vecd.bac * (vepd.perc_concluido/100)) / vecd.ac)) ) EAC,
       vecd.bac - (vecd.ac + decode(vecd.bac * vepd.perc_concluido, 0, vecd.bac, (vecd.bac - vecd.bac * (vepd.perc_concluido/100))/(decode(vecd.ac, 0, 1, (vecd.bac * (vepd.perc_concluido/100)) / vecd.ac)) )) VAC,
       vecd.pv_ano,
       decode(vecd.pv_ano * vepd.perc_concluido, 0, vecd.pv_ano, (vecd.pv_ano - vecd.pv_ano * (vepd.perc_concluido/100) )/(decode(vecd.ac, 0, 1, (vecd.pv_ano * (vepd.perc_concluido/100)) / vecd.ac)) ) ETC_ANO,
       vecd.ac + decode(vecd.pv_ano * vepd.perc_concluido, 0, vecd.pv_ano, (vecd.pv_ano - vecd.pv_ano * (vepd.perc_concluido/100))/(decode(vecd.ac, 0, 1, (vecd.pv_ano * (vepd.perc_concluido/100)) / vecd.ac)) ) EAC_ANO,
       vecd.ac_geral, vecd.bac_geral, vecd.ac_pessoal, vecd.bac_pessoal
  from v_eva_percentual vepd,
       v_eva_calculo_dados    vecd
 where  vecd.entidade_id   = vepd.entidade_id
   and  vecd.tipo_entidade = vepd.tipo_entidade
   and  vecd.dia           = vepd.dia;
   
create or replace view v_eva_percentual as
select vd.dia, eva.entidade_id, eva.tipo_entidade, eva.percentual_concluido perc_concluido
  from eva,
       v_dias               vd
 where eva.data = (select max(pc2.data) from percentual_concluido pc2
                    where pc2.tipo_entidade = eva.tipo_entidade
                      and pc2.entidade_id   = eva.entidade_id
                      and pc2.data         <= vd.dia);                         

create or replace view v_eva_tempo as
select vecd.dia, vecd.tipo_entidade, vecd.entidade_id, vecd.projeto_id,
       vecd.tipo_entidade_pai, vecd.entidade_id_pai, vecd.titulo,
       vecd.pv, vecd.ac, vecd.bac, vepd.perc_concluido,
       vecd.bac * (vepd.perc_concluido/100) EV,
       (vecd.bac * (vepd.perc_concluido/100)) - vecd.ac CV,
       (vecd.bac * (vepd.perc_concluido/100)) - vecd.pv SV,
       decode(vecd.ac, 0, 1, (vecd.bac * (vepd.perc_concluido/100)) / vecd.ac) CPI,
       decode(vecd.pv, 0, 1, (vecd.bac * (vepd.perc_concluido/100)) / vecd.pv) SPI,
       decode(vecd.bac - vecd.ac, 0, 0, (vecd.bac - (vecd.bac * (vepd.perc_concluido/100))) / (vecd.bac - vecd.ac)) TCPI,
       decode(vecd.bac * vepd.perc_concluido, 0, vecd.bac, (vecd.bac - vecd.bac * (vepd.perc_concluido/100))/(decode(vecd.ac, 0, 1, (vecd.bac * (vepd.perc_concluido/100)) / vecd.ac)) ) ETC,
       vecd.ac + decode(vecd.bac * vepd.perc_concluido, 0, vecd.bac, (vecd.bac - vecd.bac * (vepd.perc_concluido/100))/(decode(vecd.ac, 0, 1, (vecd.bac * (vepd.perc_concluido/100)) / vecd.ac)) ) EAC,
       vecd.bac - (vecd.ac + decode(vecd.bac * vepd.perc_concluido, 0, vecd.bac, (vecd.bac - vecd.bac * (vepd.perc_concluido/100))/(decode(vecd.ac, 0, 1, (vecd.bac * (vepd.perc_concluido/100)) / vecd.ac)) )) VAC,
       vecd.pv_ano,
       decode(vecd.pv_ano * vepd.perc_concluido, 0, vecd.pv_ano, (vecd.pv_ano - vecd.pv_ano * (vepd.perc_concluido/100) )/(decode(vecd.ac, 0, 1, (vecd.pv_ano * (vepd.perc_concluido/100)) / vecd.ac)) ) ETC_ANO,
       vecd.ac + decode(vecd.pv_ano * vepd.perc_concluido, 0, vecd.pv_ano, (vecd.pv_ano - vecd.pv_ano * (vepd.perc_concluido/100))/(decode(vecd.ac, 0, 1, (vecd.pv_ano * (vepd.perc_concluido/100)) / vecd.ac)) ) EAC_ANO
  from v_eva_percentual   vepd,
       v_eva_calculo_dados_tempo vecd
 where  vecd.entidade_id   = vepd.entidade_id
   and  vecd.tipo_entidade = vepd.tipo_entidade
   and  vecd.dia           = vepd.dia;

CREATE OR REPLACE VIEW V_HORAS AS
select tarefa_id, usuario_id, data,     
       decode (tipo, 'HP', 'Y', 'N') ind_planejamento,                              
       decode (tipo, 'HP', situacao, 0) situacao_planejada,
       decode (tipo, 'HP',
                       decode (situacao,
                               'A', 1,
                               'R', 2,
                               'E', 3,
                               'P', 4, 0), 0) situacao_valor,
       decode (tipo, 'HP', hora_id, 0) hora_planejada_id,
       decode (tipo, 'HP', minutos, 0) hora_planejada,
       decode (tipo, 'HT', minutos, 0) hora_trabalhada,
       decode (tipo, 'HA', minutos, 0) hora_alocada                               
  from MV_HORAS_ALTBPL;
  
CREATE OR REPLACE FORCE VIEW V_USUARIOS_RECURSO  (ID, USUARIO_ID_DEP, USUARIO_ID) AS
  SELECT rownum id, SUBSTR(path, 2, instr(SUBSTR(path, 2), ';')-1) USUARIO_ID_DEP, USUARIO_ID
  FROM
    (SELECT sys_connect_by_path(u.usuarioid, ';') path,
      u.usuarioid USUARIO_ID
    FROM usuario u
      CONNECT BY nocycle u.usuarioid =  prior u.gerente_recurso
    )
  WHERE  path is not null; 
  
create or replace view DEMANDAS_SLA AS 
select DADOS_FINAL.*,
       (CASE WHEN HORAMIN(TEMPO) < HORAMIN(HORAS_SLA) THEN 'Dentro do Prazo'
        ELSE 'Fora do Prazo' END) Atendimento,
        (select valor from atributo_valor av where av.atributo_id in (30) and av.demanda_id = dados_final.demanda_id) SOLUCAO_DEMANDA
  from (
        select DEMANDA_ID, SOLICITANTE, uo UnidadeOrganizacional, Destino, Responsavel,
               CRIADOR, SOLUCAO, IDPRIMEIROATEND, ORIGEM, MOTIVO, DESCRICAO, TIPO, ITEM, COMPONENTE,
               T.TEXTO_TERMO SITUACAO,
               decode(prioridadeid, 5, '04:00', 6, '24:00', 7, '16:00', '00:00') HORAS_SLA, prioridade SLA, 
               CRIACAO, to_char(criacao, 'DD') DIA_CRIACAO, to_char(criacao, 'MM') MES_CRIACAO, to_char(criacao, 'YYYY') ANO_CRIACAO,
               DATA_FINAL, MINHORA(SUM((CASE WHEN HORAS_VALIDAS < 0 THEN 0 ELSE HORAS_VALIDAS END))) TEMPO  
          from (
                select (CASE WHEN trunc(criacao) = trunc(data_FINAL) THEN HORA_FINAL - HORA_CRIACAO 
                             WHEN trunc(criacao) = trunc(dia) THEN TEMPO1 
                             WHEN trunc(data_FINAL) = trunc(dia) THEN TEMPO2 
                             ELSE HORAS_DIA - HORAMIN('07:30') END) HORAS_VALIDAS, DADOS.* 
                  from (
                        select DEMANDAS.*, DIAS.DIA, DIAS.HORAS_DIA, (DIAS.HORAS_DIA - DEMANDAS.HORA_CRIACAO) TEMPO1, (DEMANDAS.HORA_FINAL - HORAMIN('07:30')) TEMPO2
                          from  
                               (select DEMANDA_ID, CRIADOR, SITUACAO, PRIORIDADEID, prioridade, SOLICITANTE, uo, Destino, Responsavel,
                                       SOLUCAO, IDPRIMEIROATEND, TIPO, ORIGEM, MOTIVO, DESCRICAO, ITEM, COMPONENTE, 
                                       CRIACAO, HORA_CRIACAO, nvl(DATA_SCA, DATA_SDA) DATA_FINAL, NVL(HORA_SCA, HORA_SDA) HORA_FINAL 
                                  from(
                                        select d.demanda_id, criador.nome CRIADOR, situacao, prioridade PRIORIDADEID, p.descricao PRIORIDADE,
                                               solic.nome SOLICITANTE, uo.titulo uo, des.descricao Destino,resp.nome Responsavel,
                                               atr_descricao.valor Descricao, dom_item.titulo Item, dom_componente.titulo Componente,
                                               dom_tipo.titulo TIPO, dom_origem.titulo ORIGEM, dom_motivo.titulo MOTIVO,
                                               atr_solucao.valor SOLUCAO, atr_primeiroatend.valor IDPRIMEIROATEND,
                                               SQL_CRIACAO.DATE_UPDATE CRIACAO, HORAMIN(TO_CHAR(SQL_CRIACAO.DATE_UPDATE,'hh24:mi')) HORA_CRIACAO,
                                               SQL_SCA.DATE_UPDATE DATA_SCA, HORAMIN(TO_CHAR(SQL_SCA.DATE_UPDATE,'hh24:mi')) HORA_SCA,
                                               SQL_SDA.DATE_UPDATE DATA_SDA, HORAMIN(TO_CHAR(SQL_SDA.DATE_UPDATE,'hh24:mi')) HORA_SDA
                                          from demanda d, prioridade p, usuario criador, usuario solic, uo, destino des, usuario resp,
                                               (select min(date_update)date_update, demanda_id from h_demanda where formulario_id = 4 group by demanda_id) SQL_CRIACAO,
                                               (select min(date_update)date_update, demanda_id from h_demanda where formulario_id = 4 and situacao = 11 group by demanda_id) SQL_SCA,
                                               (select min(date_update)date_update, demanda_id from h_demanda where formulario_id = 4 and situacao = 14 group by demanda_id) SQL_SDA,
                                               atributo_valor atr_descricao, atributo_valor atr_item, dominioatributo dom_item, 
                                               atributo_valor atr_componente, dominioatributo dom_componente,
                                               atributo_valor atr_tipo, dominioatributo dom_tipo,
                                               atributo_valor atr_origem, dominioatributo dom_origem,
                                               atributo_valor atr_motivo, dominioatributo dom_motivo,
                                               atributo_valor atr_solucao, atributo_valor atr_primeiroatend
                                         where d.formulario_id = 4 and d.demanda_id = SQL_CRIACAO.demanda_id
                                           and (d.modelo is null OR d.modelo = 'N') and d.ativo = 'Y'
                                           and d.demanda_id = SQL_SCA.demanda_id(+) and d.demanda_id = SQL_SDA.demanda_id(+)
                                           and d.prioridade = p.prioridadeid(+)
                                           and d.solicitante = solic.usuarioid(+)
                                           and d.destino_ID = des.destinoid(+)
                                           and d.responsavel = resp.usuarioid(+)
                                           and d.criador = criador.usuarioid(+)
                                           and d.uo_id = uo.id(+)
                                           and atr_primeiroatend.atributo_id(+) = 15 and d.demanda_id = atr_primeiroatend.demanda_id(+)
                                           and atr_solucao.atributo_id(+) = 19 and d.demanda_id = atr_solucao.demanda_id(+)
                                           and atr_motivo.atributo_id(+) = 13 and d.demanda_id = atr_motivo.demanda_id(+) and dom_motivo.dominioatributoid(+) = atr_motivo.dominio_atributo_id
                                           and atr_origem.atributo_id(+) = 18 and d.demanda_id = atr_origem.demanda_id(+) and dom_origem.dominioatributoid(+) = atr_origem.dominio_atributo_id
                                           and atr_tipo.atributo_id(+) = 14 and d.demanda_id = atr_tipo.demanda_id(+) and dom_tipo.dominioatributoid(+) = atr_tipo.dominio_atributo_id
                                           and atr_componente.atributo_id(+) = 17 and d.demanda_id = atr_componente.demanda_id(+) and dom_componente.dominioatributoid(+) = atr_componente.dominio_atributo_id
                                           and atr_item.atributo_id(+) = 16 and d.demanda_id = atr_item.demanda_id(+) and dom_item.dominioatributoid(+) = atr_item.dominio_atributo_id
                                           and atr_descricao.atributo_id(+) = 7 and d.demanda_id = atr_descricao.demanda_id(+))
                                 ) DEMANDAS,
                              (SELECT trunc(sysdate)-level+1 Dia,
                                      HORAMIN(DECODE(to_char(trunc(trunc(sysdate)-level+1),'d'),2,'17:30',3,'17:30',4,'17:30',5,'17:30',6,'16:30','00:00')) HORAS_DIA
                                FROM dual 
                               WHERE -- Define data final (se não incluir essa cláusula a data final sera o dia corrente
                                     trunc(sysdate)-level+1 <= to_date('20111231','yyyymmdd')   
                                     -- Retira os finais de semana
                                 AND to_char(trunc(sysdate)-level+1,'d') not in ('1' /* Domingo */, '7' /* Sábado */)
                              CONNECT BY trunc(sysdate)-level+1 >= to_date('20090101','yyyymmdd')) DIAS
                         where dias.dia >= trunc(DEMANDAS.criacao) and dias.dia <= nvl(DEMANDAS.DATA_FINAL,sysdate)) DADOS),
          ESTADO E, TERMO T
          WHERE SITUACAO = E.ESTADO_ID AND E.TITULO_TERMO_ID = T.TERMO_ID
        GROUP BY DEMANDA_ID, SOLICITANTE, UO, Destino, Responsavel, criador, SOLUCAO, 
                 IDPRIMEIROATEND, ORIGEM, MOTIVO, DESCRICAO, TIPO, ITEM, COMPONENTE, T.TEXTO_TERMO, 
                 decode(prioridadeid, 5, '04:00', 6, '24:00', 7, '16:00', '00:00'), PRIORIDADE,
                 CRIACAO, to_char(criacao, 'DD'), to_char(criacao, 'MM'), to_char(criacao, 'YYYY'), DATA_FINAL) DADOS_FINAL;
  
-- Dados básicos do sistema
update tela set url = 'Impacto.do?command=defaultAction' where url like '%Impacto%';
update tela set url = 'OrigemRisco.do?command=defaultAction' where telaid = 88
commit;
/


-- ROTINAS
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
   lb_grava                 boolean;
   lb_grava_tempo           boolean;
   lt_ipg_ant               v_eva_ipg%rowtype;
   ln_conta                 number; 
   ln_pv_original           number; 
   ln_bac_original          number; 
   ln_pv_geral_original     number; 
   ln_bac_geral_original    number; 
   ln_conta_reg             number;
   ln_conta_reg_total       number;
   ln_percentual_concluido  number;
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
    ln_percentual_concluido := 0;
    
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
    
    begin
      --Obtem o percentual concluído da data
      
      select nvl(vep.perc_concluido, 0) into ln_percentual_concluido
      from v_eva_percentual_dados vep 
      where vep.tipo_entidade = ipg.tipo_entidade 
      and vep.entidade_id = ipg.entidade_id
      and vep.dia = ipg.data;
                   
     EXCEPTION   
     when OTHERS then
       ln_percentual_concluido := 0;
     end;                     
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
                         pv_original, bac_original, pv_geral_original, bac_geral_original, percentual_concluido)
                  values(eva_seq.nextval, ipg.data, ipg.entidade_id, ipg.tipo_entidade,
                         ipg.pv, ipg.pv_ano, ipg.ac, ipg.bac, ipg.pv_geral, ipg.pv_ano_geral, 
                         ipg.ac_geral, ipg.bac_geral, 'N', ln_pv_original, ln_bac_original, 
                         ln_pv_geral_original, ln_bac_geral_original, ln_percentual_concluido);                                     
      else                                            
         update eva
            set pv = ipg.pv, pv_ano = ipg.pv_ano, ac = ipg.ac, bac = ipg.bac,
                pv_geral = ipg.pv_geral, pv_ano_geral = ipg.pv_ano_geral, 
                ac_geral = ipg.ac_geral, bac_geral = ipg.bac_geral, atualizar = 'N',
                percentual_concluido = ln_percentual_concluido
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
                               pv, pv_ano, ac, bac, pv_original, bac_original, percentual_concluido)
                        values(eva_tempo_seq.nextval, ipg.data, ipg.entidade_id, ipg.tipo_entidade,
                               ipg.pv_tempo, ipg.pv_ano_tempo, ipg.ac_tempo, ipg.bac_tempo, 
                               ln_pv_original, ln_bac_original, ln_percentual_concluido);  
      else
         update eva_tempo
            set pv = ipg.pv_tempo, 
                pv_ano = ipg.pv_ano_tempo, 
                ac = ipg.ac_tempo, 
                bac = ipg.bac_tempo,
                percentual_concluido = ln_percentual_concluido
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
  ln_conta                number;
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

update eva
   set atualizar = 'Y';
commit;
/

-------------------------------------------------------------------------------
-- Finalização
-------------------------------------------------------------------------------
insert into versao(id, titulo, patch, versao_tgp_id, comentario)
       values (versao_seq.nextval, '6.0.1', '7', 4, 'Aplicação de patch');
commit;
/

begin
  pck_processo.precompila;
  commit;
end;
/

select * from v_versao;
/
