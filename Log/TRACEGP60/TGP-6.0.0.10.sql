/*****************************************************************************\ 
 * TraceGP 6.0.0.10                                                          *
\*****************************************************************************/

define CS_TBL_DAT = &TABLESPACE_DADOS;
define CS_TBL_IND = &TABLESPACE_INDICES;

--
create table mapeamento_atributo_abertura (
  id_mapeamento_atr_abertura number(10)    not null,
  id_atributo                number(10)    not null,
  campo                      varchar2(200) not null,
  id_abertura_via_email      number(10)    not null,
constraint PK_MAP_ATR_ABERTURA primary key (id_mapeamento_atr_abertura) USING INDEX TABLESPACE &CS_TBL_IND
) TABLESPACE &CS_TBL_DAT;

comment on table mapeamento_atributo_abertura   
        is 'Mapeamento de atributos para um campo preenchido na abertura de demanda por email.';


create sequence MAPEAMENTO_ATR_ABERTURA_SEQ start with 1 increment by 1 nocache;

--

alter table tela add constraint UK_TELA_01
  unique (nome, codigo) using index tablespace &CS_TBL_IND;
  
insert into tela (telaid,nome,url,visivel,grupoid,ordem,codigo,subgrupo,atalho)
select max(telaid) + 1,'bd.tela.tiposHoraExtra',null,'S',7,null,'TIPOS_HORA_EXTRA',null,'N'
  from tela;
commit;
/

-- Alteração de objetos

alter table CONFIGURACOES add PERMITE_PLAN_RETRO varchar2(1);
alter table CONFIGURACOES add UTILIZA_WORKFLOW varchar2(1);
alter table CONFIGURACOES add REABRIR_PLANEJAMENTO varchar2(1);
alter table CONFIGURACOES add REQUERER_MOTIVO varchar2(1);
alter table CONFIGURACOES add ENVIAR_USU_SUBMETER varchar2(1);
alter table CONFIGURACOES add ENVIAR_GERENTE_APROVAR varchar2(1);
alter table CONFIGURACOES add ENVIAR_GERENTE_REPROVAR varchar2(1);
alter table CONFIGURACOES add EMAIL_GERENTE_REABRIR varchar2(1);
alter table CONFIGURACOES add VISU_HORA_PREVISTA varchar2(1);
alter table CONFIGURACOES add VISU_HORA_REALIZADA varchar2(1);
alter table CONFIGURACOES add HORA_PREVISTA_ACUMULADA varchar2(1);
alter table CONFIGURACOES add HORA_REALIZADA_ACUMULADA varchar2(1);
alter table CONFIGURACOES add HORA_PREVISTA_TOTAL varchar2(1);
alter table CONFIGURACOES add HORA_REALIZADA_TOTAL varchar2(1);
alter table CONFIGURACOES add CORES_PLANEJAMENTO varchar2(1);

alter table USUARIO drop constraint CHK_USUARIO_06;
alter table USUARIO add constraint CHK_USUARIO_06
  check (agenda_aba_padrao in ('C', 'P', 'A', 'D','T'));

alter table COMUNICACAO_DASHBOARD add orientacao varchar2(1) default 'R' not null;
comment on column COMUNICACAO_DASHBOARD.orientacao
  is 'Retrato/Paisagem';
  
alter table RELAT_COMPONENTE_FILTRO modify SIGLA_PARAMETRO_DESTINO VARCHAR2(60);
alter table RELAT_COMPONENTE_FILTRO modify SIGLA_CAMPO_ORIGEM VARCHAR2(60);

------------------------------------------------------------------------------
update CONFIGURACOES set PERMITE_PLAN_RETRO = 'Y' where dataalteracao = (select max(c1.dataalteracao) from configuracoes c1);
update CONFIGURACOES set UTILIZA_WORKFLOW  = 'Y' where dataalteracao = (select max(c1.dataalteracao) from configuracoes c1);
update CONFIGURACOES set REABRIR_PLANEJAMENTO  = 'Y' where dataalteracao = (select max(c1.dataalteracao) from configuracoes c1);
update CONFIGURACOES set REQUERER_MOTIVO  = 'Y' where dataalteracao = (select max(c1.dataalteracao) from configuracoes c1);
update CONFIGURACOES set ENVIAR_USU_SUBMETER  = 'Y' where dataalteracao = (select max(c1.dataalteracao) from configuracoes c1);
update CONFIGURACOES set ENVIAR_GERENTE_APROVAR  = 'Y' where dataalteracao = (select max(c1.dataalteracao) from configuracoes c1);
update CONFIGURACOES set ENVIAR_GERENTE_REPROVAR  = 'Y' where dataalteracao = (select max(c1.dataalteracao) from configuracoes c1);
update CONFIGURACOES set EMAIL_GERENTE_REABRIR  = 'Y' where dataalteracao = (select max(c1.dataalteracao) from configuracoes c1);
update CONFIGURACOES set VISU_HORA_PREVISTA  = 'Y' where dataalteracao = (select max(c1.dataalteracao) from configuracoes c1);
update CONFIGURACOES set VISU_HORA_REALIZADA  = 'Y' where dataalteracao = (select max(c1.dataalteracao) from configuracoes c1);
update CONFIGURACOES set HORA_PREVISTA_ACUMULADA  = 'Y' where dataalteracao = (select max(c1.dataalteracao) from configuracoes c1);
update CONFIGURACOES set HORA_REALIZADA_ACUMULADA  = 'Y' where dataalteracao = (select max(c1.dataalteracao) from configuracoes c1);
update CONFIGURACOES set HORA_PREVISTA_TOTAL  = 'Y' where dataalteracao = (select max(c1.dataalteracao) from configuracoes c1);
update CONFIGURACOES set HORA_REALIZADA_TOTAL  = 'Y' where dataalteracao = (select max(c1.dataalteracao) from configuracoes c1);
update CONFIGURACOES set CORES_PLANEJAMENTO  = 'Y' where dataalteracao = (select max(c1.dataalteracao) from configuracoes c1);
commit;
/

------------------------------------------------------------------------------
alter table projeto add padrao_mostrar_custos_filhas varchar2(1) default 'N';

update projeto set padrao_mostrar_custos_filhas = 'Y';
commit;
/

------------------------------------------------------------------------------

insert into regras_tipo_funcao(id, codigo) values (9, 'subtracao');
commit;
/

------------------------------------------------------------------------------
CREATE OR REPLACE FORCE VIEW V_DADOS_CRONO_OUTROS AS
SELECT
    /*+ full(cl) full(ce) full(cr) full(fa) full(td) full(p) full(cce) full(cc)
    use_hash(cl) use_hash(ce) use_hash(cr) use_hash(fa) use_hash(td) use_hash(p) use_hash(cce) use_hash(cc) */
    -- Dados tabela CUSTO_LANCAMENTO
    cl.data CUSTO_LANCAMENTO_DATA,                
    -- Detalhar valor por CV, CE, RV, RE
    NVL(cce.influencia,100)/100 * DECODE(cr.tipo, 'C', DECODE(cl.tipo, 'O', DECODE(cl.situacao, 'V', cl.valor, 0), 0), 0) CV,
    NVL(cce.influencia,100)/100 * DECODE(cr.tipo, 'C', DECODE(cl.tipo, 'O', DECODE(cl.situacao, 'E', cl.valor, 0), 0), 0) CE,
    NVL(cce.influencia,100)/100 * DECODE(cr.tipo, 'R', DECODE(cl.tipo, 'O', DECODE(cl.situacao, 'V', cl.valor, 0), 0), 0) RV,
    NVL(cce.influencia,100)/100 * DECODE(cr.tipo, 'R', DECODE(cl.tipo, 'O', DECODE(cl.situacao, 'E', cl.valor, 0), 0), 0) RE,
    -- Dados tabela CUSTO_ENTIDADE
    ce.id CUSTO_ENTIDADE_ID,
    -- Dados tabela CUSTO_RECEITA
    cr.id CUSTO_RECEITA_ID,
    -- Dados tabela FORMAAQUISICAO
    fa.id FORMA_AQUISICAO_ID,
    -- Dados tabela TIPODESPESA
    td.id TIPO_DESPESA_ID,
    -- Dados tabela PROJETO
    'P' TIPO_ENTIDADE,
    p.id ENTIDADE_ID,
    p.id PROJETO_ID,
    -- Dados tabela CENTRO_CUSTO
    cc.id CENTRO_CUSTO_ID,    
    CL.TIPO_LANCAMENTO_ID
  FROM custo_lancamento cl,
    custo_entidade ce,
    custo_receita cr,
    formaaquisicao fa,
    tipodespesa td,
    projeto p,
    centro_custo_entidade cce,
    centro_custo cc
  WHERE cc.id(+)          = cce.centrocustoid
  AND fa.id               = ce.forma_aquisicao_id
  AND td.id               = ce.tipo_despesa_id
  AND cr.id               = ce.custo_receita_id
  AND cce.tipoentidade(+) = 'P'
  AND cce.identidade(+)   = p.id
  AND p.id                = ce.entidade_id
  AND ce.tipo_entidade    = 'P'
  AND ce.id               = cl.custo_entidade_id
  AND cl.tipo             = 'O'
  UNION
  SELECT
    /*+ full(cl) full(ce) full(cr) full(fa) full(td) full(a) full(cce) full(cc)
    use_hash(cl) use_hash(ce) use_hash(cr) use_hash(fa) use_hash(td) use_hash(a) use_hash(cce) use_hash(cc) */
    -- Dados tabela CUSTO_LANCAMENTO
    cl.data CUSTO_LANCAMENTO_DATA,        
    -- Detalhar valor por CV, CE, RV, RE
    NVL(cce.influencia,100)/100 * DECODE(cr.tipo, 'C', DECODE(cl.tipo, 'O', DECODE(cl.situacao, 'V', cl.valor, 0), 0), 0) CV,
    NVL(cce.influencia,100)/100 * DECODE(cr.tipo, 'C', DECODE(cl.tipo, 'O', DECODE(cl.situacao, 'E', cl.valor, 0), 0), 0) CE,
    NVL(cce.influencia,100)/100 * DECODE(cr.tipo, 'R', DECODE(cl.tipo, 'O', DECODE(cl.situacao, 'V', cl.valor, 0), 0), 0) RV,
    NVL(cce.influencia,100)/100 * DECODE(cr.tipo, 'R', DECODE(cl.tipo, 'O', DECODE(cl.situacao, 'E', cl.valor, 0), 0), 0) RE,
    -- Dados tabela CUSTO_ENTIDADE
    ce.id CUSTO_ENTIDADE_ID,
    -- Dados tabela CUSTO_RECEITA
    cr.id CUSTO_RECEITA_ID,
    -- Dados tabela FORMAAQUISICAO
    fa.id FORMA_AQUISICAO_ID,
    -- Dados tabela TIPODESPESA
    td.id TIPO_DESPESA_ID,
    -- Dados tabela ATIVIDADE
    'A' TIPO_ENTIDADE,
    a.id ENTIDADE_ID,
    a.projeto PROJETO_ID,
    -- Dados tabela CENTRO_CUSTO
    cc.id CENTRO_CUSTO_ID,
    CL.TIPO_LANCAMENTO_ID
  FROM custo_lancamento cl,
    custo_entidade ce,
    custo_receita cr,
    formaaquisicao fa,
    tipodespesa td,
    atividade a,
    centro_custo_entidade cce,
    centro_custo cc
  WHERE cc.id(+)          = cce.centrocustoid
  AND fa.id               = ce.forma_aquisicao_id
  AND td.id               = ce.tipo_despesa_id
  AND cr.id               = ce.custo_receita_id
  AND cce.tipoentidade(+) = 'A'
  AND cce.identidade(+)   = a.id
  AND a.id                = ce.entidade_id
  AND ce.tipo_entidade    = 'A'
  AND ce.id               = cl.custo_entidade_id
  AND cl.tipo             = 'O'
  UNION
  SELECT
    /*+ full(cl) full(ce) full(cr) full(fa) full(td) full(t) full(cce) full(cc)
    use_hash(cl) use_hash(ce) use_hash(cr) use_hash(fa) use_hash(td) use_hash(t) use_hash(cce) use_hash(cc) */
    -- Dados tabela CUSTO_LANCAMENTO
    cl.data CUSTO_LANCAMENTO_DATA,               
    -- Detalhar valor por CV, CE, RV, RE
    NVL(cce.influencia,100)/100 * DECODE(cr.tipo, 'C', DECODE(cl.tipo, 'O', DECODE(cl.situacao, 'V', cl.valor, 0), 0), 0) CV,
    NVL(cce.influencia,100)/100 * DECODE(cr.tipo, 'C', DECODE(cl.tipo, 'O', DECODE(cl.situacao, 'E', cl.valor, 0), 0), 0) CE,
    NVL(cce.influencia,100)/100 * DECODE(cr.tipo, 'R', DECODE(cl.tipo, 'O', DECODE(cl.situacao, 'V', cl.valor, 0), 0), 0) RV,
    NVL(cce.influencia,100)/100 * DECODE(cr.tipo, 'R', DECODE(cl.tipo, 'O', DECODE(cl.situacao, 'E', cl.valor, 0), 0), 0) RE,
    -- Dados tabela CUSTO_ENTIDADE
    ce.id CUSTO_ENTIDADE_ID,
    -- Dados tabela CUSTO_RECEITA
    cr.id CUSTO_RECEITA_ID,
    -- Dados tabela FORMAAQUISICAO
    fa.id FORMA_AQUISICAO_ID,
    -- Dados tabela TIPODESPESA
    td.id TIPO_DESPESA_ID,
    -- Dados tabela ATIVIDADE
    'T' TIPO_ENTIDADE,
    t.id ENTIDADE_ID,
    t.projeto PROJETO_ID,
    -- Dados tabela CENTRO_CUSTO
    cc.id CENTRO_CUSTO_ID,
    CL.TIPO_LANCAMENTO_ID
  FROM custo_lancamento cl,
    custo_entidade ce,
    custo_receita cr,
    formaaquisicao fa,
    tipodespesa td,
    tarefa t,
    centro_custo_entidade cce,
    centro_custo cc
  WHERE cc.id(+)          = cce.centrocustoid
  AND fa.id               = ce.forma_aquisicao_id
  AND td.id               = ce.tipo_despesa_id
  AND cr.id               = ce.custo_receita_id
  AND cce.tipoentidade(+) = 'T'
  AND cce.identidade(+)   = t.id
  AND t.id                = ce.entidade_id
  AND ce.tipo_entidade    = 'T'
  AND ce.id               = cl.custo_entidade_id
  AND cl.tipo             = 'O';
/

CREATE OR REPLACE VIEW V_EVOLUCAO_HISTORICA AS
SELECT x.id PROJETO_ID,
    x.data,
    SUM(NVL(minutos_ate_data,0)) PREVISTO,
    SUM(NVL(minutos_totais,0)) PREVISTO_TOTAL,
    SUM(NVL(x.minutos_realizados,0)) REALIZADO,
    CASE
      WHEN SUM(NVL(minutos_totais,0)) > 0
      THEN (SUM(NVL(minutos_ate_data,0)) / SUM(NVL(minutos_totais,0))) * 100
      ELSE 0
    END PERCENTUAL_PREVISTO,
    MAX(NVL(x.percentual_concluido,0)) PERCENTUAL_CONCLUIDO
  FROM
    (
    -- PLANEJADO
    SELECT p.id ID,
      vdf.dia data,
      CASE
        WHEN vdf.dia >= t.datainicio
        THEN (least(vdf.dia, t.prazoprevisto) - t.datainicio) + 1
        ELSE 0
      END * (CASE WHEN ((t.prazoprevisto - t.datainicio)+1) > 0 THEN (t.horasprevistas / ((t.prazoprevisto - t.datainicio)+1)) ELSE 0 END)  MINUTOS_ATE_DATA,
      t.horasprevistas MINUTOS_TOTAIS,
      to_number('0', '0.')MINUTOS_REALIZADOS,
      to_number('0', '0.00') PERCENTUAL_CONCLUIDO
    FROM v_dias_futuro vdf,
      tarefa t,
      projeto p
    WHERE vdf.dia BETWEEN least(NVL(p.iniciorealizado, to_date('31129999', 'ddmmyyyy')), NVL(p.datainicio, to_date('31129999', 'ddmmyyyy'))) AND greatest(NVL(p.prazorealizado, to_date('01011900', 'ddmmyyyy')), NVL(p.prazoprevisto, to_date('01011900', 'ddmmyyyy')))
    AND t.projeto = p.id
    UNION ALL
    -- REALIZADO
    SELECT p.id,
      vdf.dia,
      0,
      0,
      ht.minutos,
      0.00
    FROM v_dias_futuro vdf,
      horatrabalhada ht,
      tarefa t,
      projeto p
    WHERE vdf.dia BETWEEN least(NVL(p.iniciorealizado, to_date('31129999', 'ddmmyyyy')), NVL(p.datainicio, to_date('31129999', 'ddmmyyyy'))) AND greatest(NVL(p.prazorealizado, trunc(sysdate)), NVL(p.prazoprevisto, to_date('01011900', 'ddmmyyyy')))
    AND ht.datatrabalho <= vdf.dia
    AND ht.tarefa        = t.id
    AND t.projeto        = p.id
    UNION ALL
    -- PERCENTUAL_CONCLUÍDO
    SELECT p.id,
      vdf.dia,
      0,
      0,
      0,
      pc.perc_concluido
    FROM percentual_concluido pc,
      v_dias_futuro vdf,
      projeto p
    WHERE vdf.dia BETWEEN least(NVL(p.iniciorealizado, to_date('31129999', 'ddmmyyyy')), NVL(p.datainicio, to_date('31129999', 'ddmmyyyy'))) AND greatest(NVL(p.prazorealizado, trunc(sysdate)), NVL(p.prazoprevisto, to_date('01011900', 'ddmmyyyy')))
    AND pc.data =
      (SELECT MAX(pc2.data)
      FROM percentual_concluido pc2
      WHERE pc2.tipo_entidade = pc.tipo_entidade
      AND pc2.entidade_id     = pc.entidade_id
      AND pc2.data           <= vdf.dia
      )
    AND pc.tipo_entidade = 'P'
    AND pc.entidade_id   = p.id
    ) x
  GROUP BY x.id,
    x.data;
/

create or replace view v_objetivos_indicadores_resumo as
select mi.id id, 'I' TIPO, indicador_template ,mi.entidade_id ENTIDADE_ID, mi.tipo_entidade TIPO_ENTIDADE,
       mi.objetivo_pai OBJETIVO_PAI, mi.titulo TITULO, mi.validade VALIDADE,
       mia.data_apuracao DATA_APURACAO, mia.data_atualizacao DATA_ATUALIZACAO,
       mia.situacao ESTADO, mm.comentario COMENTARIO, mm.valor VALOR_META,
       mi.unidade UNIDADE, mia.escore ESCORE, mia.escore - mm.valor DIFERENCA,
       decode(mm.valor, 0, to_number(null), (mia.escore - mm.valor) / mm.valor) DIF_PERC,
       decode(mm.valor, 0, to_number(null), mia.escore / mm.valor) PERC_META_ATING,
       mmf.cor COR, mi.descricao DESCRICAO, mi.responsavel RESPONSAVEL_ID,
       mi.desc_meta DESC_META,
       ma.analise ANALISE,
       ma.decisoes DECISOES,
       ma.acoes_realizadas ACOES_REALIZADAS,
       ma.recomendacoes RECOMENDACOES
  from mapa_indicador          mi,
       mapa_indicador_apuracao mia,
       mapa_meta               mm,
       mapa_meta_faixa         mmf,
       mapa_avaliacao          ma
 where mi.id = mia.indicador_id (+)
   and ( ( mia.data_apuracao is null ) or
         ( mia.data_apuracao = nvl( (select max(mia2.data_apuracao)
                                       from mapa_indicador_apuracao mia2
                                      where mia2.indicador_id = mi.id
                                        and mia2.quebra_id is null)
                                   , mia.data_apuracao)))
   -- META
   and mia.indicador_id = mm.indicador_id (+)
   and ( ( mm.data_limite is null ) or
         ( mm.data_limite = nvl( (select min(mm2.data_limite)
                                    from mapa_meta mm2
                                   where mm2.indicador_id = mia.indicador_id
                                     and mm2.data_limite >= mia.data_apuracao
                                     and mm2.quebra_id is null)
                                , mm.data_limite)))
   -- FAIXA
   and mm.indicador_id = mmf.indicador_id (+)
   and ( ( mmf.percentual_meta is null ) or
         ( mmf.percentual_meta = nvl( (select min(mmf2.percentual_meta)
                                         from mapa_meta_faixa mmf2
                                        where mmf2.indicador_id = mm.indicador_id
                                          and mmf2.percentual_meta >= nvl((mia.escore / decode(mm.valor,0,0.0001,mm.valor))*100,0))
                                     , (select max(mmf3.percentual_meta)
                                         from mapa_meta_faixa mmf3
                                         where mmf3.indicador_id = mm.indicador_id))))
   -- AVALIACAO
   and mi.id = ma.indicador_id (+)
   and ( (ma.id is null) or
         (ma.data = (select max(data)
                     from mapa_avaliacao ma1
                     where ma1.indicador_id = mi.id
                     and   ma1.id = (select max(id) from mapa_avaliacao ma2
                                     where ma2.data = ma1.data
                                     and   ma2.indicador_id = ma1.indicador_id))))
union all
select mo.id id, 'O' TIPO,'N' indicador_template, mo.entidade_id ENTIDADE_ID, mo.tipo_entidade TIPO_ENTIDADE,
       mo.objetivo_pai OBJETIVO_PAI, mo.titulo TITULO, mo.validade VALIDADE,
       moa.data_apuracao DATA_APURACAO, moa.data_atualizacao DATA_ATUALIZACAO,
       moa.situacao ESTADO, mom.comentario COMENTARIO, mom.valor VALOR_META,
       mo.unidade UNIDADE, moa.escore ESCORE, moa.escore - mom.valor DIFERENCA,
       decode(mom.valor, 0, to_number(null), (moa.escore - mom.valor) / mom.valor) DIF_PERC,
       decode(mom.valor, 0, to_number(null), moa.escore / mom.valor) PERC_META_ATING,
       mof.cor COR, mo.descricao DESCRICAO, mo.responsavel,
       mo.desc_meta,
       ma.analise ANALISE,
       ma.decisoes DECISOES,
       ma.acoes_realizadas ACOES_REALIZADAS,
       ma.recomendacoes RECOMENDACOES
  from mapa_objetivo           mo,
       mapa_objetivo_apuracao  moa,
       mapa_objetivo_meta      mom,
       mapa_objetivo_faixa     mof,
       mapa_avaliacao          ma
 where mo.id = moa.objetivo_id (+)
   and ( ( moa.data_apuracao is null ) or
         ( moa.data_apuracao = nvl( (select max(moa2.data_apuracao)
                                       from mapa_objetivo_apuracao moa2
                                      where moa2.objetivo_id = mo.id)
                                   , moa.data_apuracao)))
   -- META
   and moa.objetivo_id = mom.objetivo_id (+)
   and ( ( mom.data_limite is null ) or
         ( mom.data_limite = nvl( (select min(mom2.data_limite)
                                     from mapa_objetivo_meta mom2
                                    where mom2.objetivo_id = moa.objetivo_id
                                      and mom2.data_limite >= moa.data_apuracao)
                                 , mom.data_limite)))
   -- FAIXA
   and mom.objetivo_id = mof.objetivo_id (+)
   and ( ( mof.percentual_meta is null ) or
         ( mof.percentual_meta = nvl( (select min(mof2.percentual_meta)
                                         from mapa_objetivo_faixa mof2
                                        where mof2.objetivo_id = mom.objetivo_id
                                          and mof2.percentual_meta >= nvl((moa.escore / decode(mom.valor,0,0.0001,mom.valor))*100,0))
                                     , (select max(mof3.percentual_meta)
                                         from mapa_objetivo_faixa mof3
                                         where mof3.objetivo_id = mom.objetivo_id))))
   -- AVALIACAO
   and mo.id = ma.objetivo_id (+)
   and ( (ma.id is null) or
         (ma.data = (select max(data)
                     from mapa_avaliacao ma1
                     where ma1.objetivo_id = mo.id
                     and   ma1.id = (select max(id) from mapa_avaliacao ma2
                                     where ma2.data = ma1.data
                                     and   ma2.objetivo_id = ma1.objetivo_id))));
/

CREATE TABLE HORA_PLANEJADA ( 
  ID               NUMBER(10) NOT NULL,
  TAREFA_ID        NUMBER(10) NOT NULL,
  DATA             DATE,
  USUARIO_ID       VARCHAR2(50),
  HORAS_PLANEJADAS NUMBER(10),
  SITUACAO         VARCHAR2(1),
  USER_UPDATE      VARCHAR2(50),
  DATE_UPDATE      DATE,
CONSTRAINT PK_HORA_PLANEJADA PRIMARY KEY (ID) USING INDEX TABLESPACE &CS_TBL_IND 
) TABLESPACE &CS_TBL_DAT;

ALTER TABLE HORA_PLANEJADA ADD CONSTRAINT FK_HORA_PLANEJADA_01 
  FOREIGN KEY (TAREFA_ID) REFERENCES TAREFA(ID) ON DELETE CASCADE;
ALTER TABLE HORA_PLANEJADA ADD CONSTRAINT FK_HORA_PLANEJADA_02 
  FOREIGN KEY (USUARIO_ID) REFERENCES USUARIO (USUARIOID) ON DELETE CASCADE;

CREATE SEQUENCE HORA_PLANEJADA_SEQ  START WITH 1 INCREMENT BY 1 NOCACHE;

-----------------------------------------------------------------------
CREATE TABLE H_HORA_PLANEJADA ( 
  ID                NUMBER(10) NOT NULL,
  ID_HORA_PLANEJADA NUMBER(10) NOT NULL,
  TAREFA_ID         NUMBER(10) NOT NULL,
  DATA              DATE,
  USUARIO_ID        VARCHAR2(50),
  HORAS_PLANEJADAS  NUMBER(10),
  SITUACAO          VARCHAR2(1),
  USER_UPDATE       VARCHAR2(50),
  DATA_UPDATE       DATE,
CONSTRAINT PK_H_HORA_PLANEJADA PRIMARY KEY (ID) USING INDEX TABLESPACE &CS_TBL_IND 
) TABLESPACE &CS_TBL_DAT;

ALTER TABLE H_HORA_PLANEJADA ADD CONSTRAINT FK_H_HORA_PLANEJADA_01 
  FOREIGN KEY (TAREFA_ID) REFERENCES TAREFA(ID) ON DELETE CASCADE;
ALTER TABLE H_HORA_PLANEJADA ADD CONSTRAINT FK_H_HORA_PLANEJADA_02 
  FOREIGN KEY (USUARIO_ID) REFERENCES USUARIO (USUARIOID) ON DELETE CASCADE;
ALTER TABLE H_HORA_PLANEJADA ADD CONSTRAINT FK_H_HORA_PLANEJADA_03 
  FOREIGN KEY (USER_UPDATE) REFERENCES USUARIO (USUARIOID) ON DELETE CASCADE;

CREATE SEQUENCE H_HORA_PLANEJADA_SEQ  START WITH 1 INCREMENT BY 1 NOCACHE;

------------------------------------------------------

CREATE TABLE COMENTARIO_HORA_PLANEJADA ( 
  ID                NUMBER(10) NOT NULL,
  ID_HORA_PLANEJADA NUMBER(10) NOT NULL,
  COMENTARIO        VARCHAR2(4000),
  USER_UPDATE       VARCHAR2(50),
  DATA_UPDATE       DATE,
CONSTRAINT PK_COMENTARIO_HORA_PLANEJADA PRIMARY KEY (ID) USING INDEX TABLESPACE &CS_TBL_IND   
) TABLESPACE &CS_TBL_DAT;


ALTER TABLE COMENTARIO_HORA_PLANEJADA ADD CONSTRAINT FK_COMENTARIO_HORA_PLANEJ_01 
  FOREIGN KEY (USER_UPDATE) REFERENCES USUARIO(USUARIOID) ON DELETE CASCADE;

CREATE SEQUENCE COMENTARIO_HORA_PLANEJADA_SEQ  START WITH 1 INCREMENT BY 1 NOCACHE;

-------------------------------------------------------------------------------
CREATE TABLE DETALHE_HORA_PLANEJADA ( 
  ID                 NUMBER(10) NOT NULL,
  ID_HORA_PLANEJADA  NUMBER(10) NOT NULL,
  LOCAL              VARCHAR2(4000),
  RECURSO_NECESSARIO VARCHAR2(4000),
  OBSERVACAO         VARCHAR2(4000),
  USER_UPDATE        VARCHAR2(50),
  DATA_UPDATE        DATE,  
  HORA_INICIO        NUMBER(10),
  HORA_FIM           NUMBER(10),
CONSTRAINT PK_DETALHE_HORA_PLANEJADA PRIMARY KEY (ID) USING INDEX TABLESPACE &CS_TBL_IND   
) TABLESPACE &CS_TBL_DAT;

ALTER TABLE DETALHE_HORA_PLANEJADA ADD CONSTRAINT FK_DETALHE_HORA_PLANEJADA_01 
  FOREIGN KEY (USER_UPDATE) REFERENCES USUARIO(USUARIOID) ON DELETE CASCADE;
ALTER TABLE DETALHE_HORA_PLANEJADA ADD CONSTRAINT FK_DETALHE_HORA_PLANEJADA_02 
  FOREIGN KEY (ID_HORA_PLANEJADA) REFERENCES HORA_PLANEJADA(ID) ON DELETE CASCADE;

CREATE SEQUENCE DETALHE_HORA_PLANEJADA_SEQ  START WITH 1 INCREMENT BY 1 NOCACHE;

-------------------------------------------------------------------------------
CREATE TABLE HORA_PLANEJADA_MOTIVO ( 
  ID          NUMBER(10) NOT NULL,
  DATA        DATE,
  USUARIO_ID  VARCHAR2(50),
  MOTIVO      VARCHAR2(4000),
  USER_UPDATE VARCHAR2(50),
  DATE_UPDATE date,
constraint PK_HORA_PLANEJADA_MOTIVO PRIMARY KEY (ID) USING INDEX TABLESPACE &CS_TBL_IND   
) TABLESPACE &CS_TBL_DAT;

ALTER TABLE HORA_PLANEJADA_MOTIVO ADD CONSTRAINT FK_HORA_PLANEJADA_MOTIVO_01
  FOREIGN KEY (USUARIO_ID) REFERENCES USUARIO (USUARIOID) ON DELETE cascade;

CREATE SEQUENCE HORA_PLANEJADA_MOTIVO_SEQ  START WITH 1 INCREMENT BY 1 nocache;
----------------------------------------------------------
-- Create table
create table RELAT_DRILL (
  ID        NUMBER(10) not null,
  TITULO    VARCHAR2(60) not null,
  DESCRICAO VARCHAR2(4000),
  URL       VARCHAR2(4000),
  TIPO_URL  VARCHAR2(1) default 'T' not null,
constraint PK_RELAT_DRILL primary key (id) using index tablespace &CS_TBL_IND
) tablespace &CS_TBL_DAT;

comment on column RELAT_DRILL.TIPO_URL
  is 'TraceGP/Url';
  
-- Create table
create table RELAT_DRILL_PARAMETRO (
  ID            NUMBER(10) not null,
  DRILL_ID      NUMBER(10) not null,
  TITULO        VARCHAR2(60) not null,
  SIGLA         VARCHAR2(60) not null,
  VALOR_DEFAULT VARCHAR2(4000),
constraint PK_RELAT_DRILL_PARAMETRO primary key (id) using index tablespace &CS_TBL_IND
) tablespace &CS_TBL_DAT;

alter table RELAT_DRILL_PARAMETRO add constraint FK_RELAT_DRILL_PARAMETRO_01 
  foreign key (DRILL_ID) references RELAT_DRILL (ID);

alter table RELAT_RELATORIO_COMPONENTE add drill_drill_id number(10);
comment on column RELAT_RELATORIO_COMPONENTE.drill_drill_id
  is 'Drill para url';

alter table RELAT_RELATORIO_COMPONENTE add constraint fk_relat_relatorio_comp_04 
  foreign key (DRILL_DRILL_ID) references relat_drill (ID);

insert into relat_drill (ID, TITULO, DESCRICAO, URL, TIPO_URL)
  values (1, 'Diagrama de Gantt do Projeto', 'Diagrama de Gantt do Projeto', 
          'Cronograma.do?command=montarGrafico'||CHR(38)||'grafico1=-1', 'T');
insert into relat_drill_parametro (ID, DRILL_ID, TITULO, SIGLA, VALOR_DEFAULT)
  values (1, 1, 'Projeto', 'projeto_quadro_avisos', '');
commit;
/

---------------------------------------------------------
insert into responsavelentidade (tipoentidade,identidade, responsavel,permissaocriacaotarefas,modificador,motivo) 
select 'T', id, modificador, null, modificador, null from tarefa t 
where papelprojeto_id is null 
--and responsavel is null 
and projeto is not null 
and not exists (select 1 from responsavelentidade r where r.identidade = t.id and r.tipoentidade = 'T');
commit;
/

-------------------------------------------------------------

create table tipo_hora_extra ( 
  id      number(10)    not null, 
  titulo  varchar2(150) not null, 
  vigente varchar2(1)   default 'N' not null, 
constraint PK_TIPO_HORA_EXTRA primary key (id) using index tablespace &CS_TBL_IND, 
constraint CHK_TIPO_HORA_EXTRA_01 check (vigente in ('Y', 'N')) 
) tablespace &CS_TBL_DAT; 

comment on table tipo_hora_extra is 'Tabela com tipos de hora extra'; 
comment on column tipo_hora_extra.id 
     is 'Chave única para tipos de hora extra'; 
comment on column tipo_hora_extra.titulo 
     is 'Título do tipo de hora extra'; 
comment on column tipo_hora_extra.vigente 
     is 'Determina se o tipo está vigente (Y) ou não (N)';     

create sequence tipo_hora_extra_seq 
       increment by 1      start with 1 
       maxvalue 9999999999 minvalue 1 nocache;  
	   
------------------------------------------------------------------------------
create or replace package pck_sla is

   type t_rec_sla is record (
      row_id rowid);
   
   type tt_array_sla is table of t_rec_sla index by binary_integer;

   gt_registros_alterados tt_array_sla;
   gt_array_vazio        tt_array_sla;
   
   function f_diasuteisentre(pid_inicio date, pid_fim date) return number;

   procedure pCalcula (pn_demanda_id demanda.demanda_id%type,
                       pb_processo   boolean,
                       pb_estado     boolean,
                       pb_tendencia  boolean);
   procedure pCalcula_Lote (pn_demanda_id demanda.demanda_id%type,
                       pn_sla_id     sla.id%type,
                       pb_processo   boolean,
                       pb_estado     boolean,
                       pb_tendencia  boolean);
                       
  function f_restante_critico ( pn_demanda_id    demanda.demanda_id%type ) return number;

 end;
/
create or replace
package body pck_sla is


	function f_diasuteisentre(pid_inicio date, pid_fim date) return number is
		ld_data date;
		ln_dias number:=0;
	begin
	 ld_data := pid_inicio;
	 while ld_data <= pid_fim loop
		if to_char(ld_data,'D') not in ('1','7') then
		  ln_dias := ln_dias + 1;
		end if;
		ld_data := ld_data + 1;
	 end loop;
	 return ln_dias;
	end;


   function f_get_restante_critico ( pn_demanda_id    demanda.demanda_id%type,
                                     pn_formulario_id formulario.formulario_id%type, 
                                     pn_estado_id     estado_formulario.estado_id%type,
                                     pv_visitados     varchar2 ) return number is
     ln_max_minutos number:=0;
     ln_min_prox number;
   begin
      for c in (select t.estado_destino, nvl(nvl(av.valornumerico,sla.qtd_minutos),0) qtd_minutos_aux
                from proximo_estado t, 
                     estado_formulario ef, 
                     sla, 
                     (select * from atributo_valor where demanda_id = pn_demanda_id) av
                where t.formulario_id = pn_formulario_id
                and   t.estado_origem = pn_estado_id
                and   t.formulario_id = ef.formulario_id
                and   t.estado_destino = ef.estado_id
                and   ef.sla_default_id = sla.id
                and   sla.atributo_id = av.atributo_id (+)) loop
         if instr(pv_visitados, '<'||c.estado_destino||'>') = 0 then
            ln_min_prox := f_get_restante_critico(pn_demanda_id, pn_formulario_id, c.estado_destino, pv_visitados ||'<'||c.estado_destino||'>');
            if ln_max_minutos < c.qtd_minutos_aux + ln_min_prox then
               ln_max_minutos := c.qtd_minutos_aux + ln_min_prox;
            end if;
         end if;
      end loop;
      return ln_max_minutos;
   end;

   function f_restante_critico ( pn_demanda_id    demanda.demanda_id%type ) return number is
   ln_estado_id     demanda.situacao%type;
   ln_formulario_id demanda.formulario_id%type;
   lv_visitados     varchar2(4000):='';
   begin
      select situacao, formulario_id
      into ln_estado_id, ln_formulario_id
      from demanda
      where demanda_id = pn_demanda_id;
      
      for c in (select distinct t.situacao from h_demanda t where demanda_id = pn_demanda_id) loop
         lv_visitados := lv_visitados || '<'||c.situacao||'>';
      end loop;
      return f_get_restante_critico(pn_demanda_id, ln_formulario_id, ln_estado_id, lv_visitados);
   end;

   procedure pCalcula (pn_demanda_id demanda.demanda_id%type,
                       pb_processo   boolean,
                       pb_estado     boolean,
                       pb_tendencia  boolean) is

   ln_processo number;
   ln_estado number;
   ln_tendencia number;
   ln_demanda_id demanda.demanda_id%type;
   ld_inicio demanda.data_inicio_sla%type;
   lv_cor sla_nivel.cor%type;
   ln_estado_sla_id sla_nivel.estado_sla_id%type;
   ld_fim demanda.data_inicio_sla%type;
   ln_qtd_minutos sla.qtd_minutos%type;
   ln_perc sla_nivel.porcentagem%type;
   ln_padrao_horario_id number;
   
   begin
      if pb_processo then
         ln_processo := 1;
      else
         ln_processo := 0;
      end if;
      if pb_estado then
         ln_estado := 1;
      else
         ln_estado := 0;
      end if;
      if pb_tendencia then
         ln_tendencia := 1;
      else
         ln_tendencia := 0;
      end if;
      
      delete demanda_faixas_sla
      where  demanda_id = pn_demanda_id
      and    ((ln_processo = 1 and tipo_sla = 'P') or
              (ln_tendencia = 1 and tipo_sla = 'T') or
              (ln_estado = 1 and tipo_sla = 'E'));
      
      if pb_processo then
         ln_demanda_id := null;
         ld_inicio := null;
         lv_cor := null;
         ln_estado_sla_id := null;
         ln_qtd_minutos:=null;
         ln_perc := null;
         ln_padrao_horario_id := null;
         for c in (select d.demanda_id demanda_id, 
                         nvl(av.valornumerico, d.qtd_minutos) qtd_minutos_aux,
                         nivel.porcentagem porcentagem, 
                         nivel.cor cor,
                         nivel.estado_sla_id estado_sla_id,
                         nvl(case when  pad.saidaintervalo - pad.entrada >=
                                    ((nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - 
                                     (f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0) + 
                                      f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                                     (f_diasuteisentre(trunc(d.data_inicio_sla+1),dia.data-1)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440)))
                              then dia.data + 
                                   (nvl(pad.entrada,0) +
                                    ((nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - 
                                    (f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0) + 
                                     f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                                     ((f_diasuteisentre(trunc(d.data_inicio_sla+1),dia.data-1)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440)))))/24/60
                              else dia.data + 
                                   (nvl(pad.entradaintervalo,720) + 
                                    ((nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - 
                                      nvl(pad.saidaintervalo - pad.entrada,720) - 
                                     (f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0) + 
                                      f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                                     ((f_diasuteisentre(trunc(d.data_inicio_sla+1),dia.data-1)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440)))))/24/60
                              end, to_date('29991231','yyyymmdd')) horario,
                       d.padrao_horario_id padrao_horario_id
                  from (select /* ordered */ d.demanda_id, a.sla_processo_id, sla.atributo_id, sla.qtd_minutos, sla.padrao_horario_id, d.data_inicio_sla
                        from demanda d, sla_ativo_demanda a, sla, 
                             (select formulario_id, e.estado_id from estado_formulario e 
                              where (e.estado_final = 'N' or estado_final is null)) dems
                        where d.data_inicio_sla is not null
                        and   d.demanda_id = a.demanda_id
                        and   dems.formulario_id = d.formulario_id
                        and   dems.estado_id = d.situacao
                        and   a.sla_processo_id = sla.id
                        and   d.demanda_id = pn_demanda_id) d,
                       atributo_valor av,
                       sla_nivel nivel, padraohorario pad, dia
                  where d.sla_processo_id = nivel.sla_id
                  and   d.padrao_horario_id = pad.id (+)
                  and   d.demanda_id = av.demanda_id (+)
                  and   d.atributo_id = av.atributo_id (+)
                  and   d.data_inicio_sla < dia.data
                  --Para melhorar a performance da consulta limita o dia maximo de calculo do SLA a partir da sysdate
                  --considerando o maximo de minutos para o sla e o percentual da maior faixa de sla
                  --considera finais de semana multiplicando por 1.4 e somando 2 dias
                  and   dia.data <= trunc(sysdate) +
                                (greatest(nvl((select max(qtd_minutos)* max(n.porcentagem/100 / (saida-entradaintervalo+saidaintervalo-entrada)) dias
                                      from sla, padraohorario p, sla_nivel n
                                      where sla.padrao_horario_id = p.id
                                      and   sla.id = n.sla_id
                                      and   sla.id = d.sla_processo_id),0
                                      ),
                                      nvl((select max(valornumerico)* max(n.porcentagem/100 / (saida-entradaintervalo+saidaintervalo-entrada)) dias
                                      from sla, atributo_valor av, sla_nivel n, padraohorario p
                                      where sla.atributo_id = av.atributo_id
                                      and   sla.padrao_horario_id = p.id
                                      and   sla.id = n.sla_id
                                      and   sla.id = d.sla_processo_id
                                      and   av.demanda_id = pn_demanda_id),0
                                      )) *1.4 + 2)
                  and   (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) > 
                        (f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0) + 
                         f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                         (f_diasuteisentre(trunc(d.data_inicio_sla+1),dia.data-1)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440))
                  and   (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) <=
                        (f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0) + 
                         f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                         (f_diasuteisentre(trunc(d.data_inicio_sla+1),dia.data)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440))
                  union all
                  --SLA de Processo no dia
                  select d.demanda_id, 
                         nvl(av.valornumerico, d.qtd_minutos),
                         nivel.porcentagem, 
                         nivel.cor,
                         nivel.estado_sla_id,
                         nvl(case when (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) <=
                                            f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0)
                                      then d.data_inicio_sla + 
                                            ((nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100)/24/60)
                                      else trunc(d.data_inicio_sla) + 
                                           (greatest(nvl(pad.entradaintervalo,720),(d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60) + 
                                            (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - 
                                            (greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0)))/24/60
                              end, to_date('29991231','yyyymmdd')),
                        d.padrao_horario_id
                  from (select /*  ordered */ d.demanda_id, a.sla_processo_id, sla.atributo_id, sla.qtd_minutos, sla.padrao_horario_id, d.data_inicio_sla
                        from demanda d, sla_ativo_demanda a, sla, 
                             (select formulario_id, e.estado_id from estado_formulario e 
                              where (e.estado_final = 'N' or estado_final is null)) dems
                        where d.data_inicio_sla is not null
                        and   d.demanda_id = a.demanda_id
                        and   dems.formulario_id = d.formulario_id
                        and   dems.estado_id = d.situacao
                        and   a.sla_processo_id = sla.id
                        and   d.demanda_id = pn_demanda_id) d,
                       atributo_valor av,
                       sla_nivel nivel, padraohorario pad
                  where d.sla_processo_id = nivel.sla_id
                  and   d.padrao_horario_id = pad.id (+)
                  and   d.demanda_id = av.demanda_id (+)
                  and   d.atributo_id = av.atributo_id (+)
                  and   (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) <= 
                        (f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0) + 
                         f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entradaintervalo,720))),0))
                  order by demanda_id, horario) loop

             if ln_demanda_id is not null then
                if ln_demanda_id = c.demanda_id then
                   ld_fim := c.horario;
                else
                   ld_fim := to_date ( '29991231', 'yyyymmdd');
                end if;
             
                insert into demanda_faixas_sla (demanda_id, tipo_sla, estado_sla_id, inicio, fim, cor, tempo_sla, porcentagem, padrao_horario_id)
                values (ln_demanda_id, 'P', ln_estado_sla_id, ld_inicio, ld_fim, lv_cor, ln_qtd_minutos, ln_perc, ln_padrao_horario_id);
             end if;
             
             ln_demanda_id := c.demanda_id;
             ln_estado_sla_id := c.estado_sla_id;
             ld_inicio := c.horario;
             lv_cor := c.cor;
             ln_qtd_minutos := c.qtd_minutos_aux;
             ln_perc := c.porcentagem;
             ln_padrao_horario_id := c.padrao_horario_id;
         end loop;
         
         if ln_demanda_id is not null then
            ld_fim := to_date ( '29991231', 'yyyymmdd');
         
            insert into demanda_faixas_sla (demanda_id, tipo_sla, estado_sla_id, inicio, fim, cor, tempo_sla, porcentagem, padrao_horario_id )
            values (ln_demanda_id, 'P', ln_estado_sla_id, ld_inicio, ld_fim, lv_cor, ln_qtd_minutos, ln_perc, ln_padrao_horario_id);
         end if;
      end if;

      if pb_tendencia then
         ln_demanda_id := null;
         ld_inicio := null;
         lv_cor := null;
         ln_estado_sla_id := null;
         ln_qtd_minutos := null;
         ln_perc:= null;
         ln_padrao_horario_id := null;
         for c in (select d.demanda_id demanda_id, 
                           nvl(av.valornumerico, d.qtd_minutos_critico) qtd_minutos_aux,
                           nivel.porcentagem porcentagem, 
                           nivel.estado_sla_id estado_sla_id,
                           nivel.cor cor,
                           case when  pad.saidaintervalo - pad.entrada >=
                                      ((nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - 
                                       d.qtd_minutos_critico - 
                                      (f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0) + 
                                       f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                                       (f_diasuteisentre(trunc(d.data_inicio_sla+1),dia.data-1)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440)))
                                then dia.data + 
                                     (nvl(pad.entrada,0) +
                                      ((nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - 
                                       d.qtd_minutos_critico - 
                                      (f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0) + 
                                       f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                                       ((f_diasuteisentre(trunc(d.data_inicio_sla+1),dia.data-1)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440)))))/24/60
                                else dia.data + 
                                     (nvl(pad.entradaintervalo,720) + 
                                      ((nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - 
                                       d.qtd_minutos_critico - 
                                       nvl(pad.saidaintervalo - pad.entrada,720) - 
                                      (f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0) + 
                                       f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                                       ((f_diasuteisentre(trunc(d.data_inicio_sla+1),dia.data-1)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440)))))/24/60
                                end horario,
                          d.padrao_horario_id padrao_horario_id
                    from (select /*  ordered */ d.demanda_id, d.formulario_id, d.situacao, a.sla_tendencia_id, sla.atributo_id, sla.qtd_minutos, sla.padrao_horario_id, d.data_inicio_sla, a.qtd_minutos_critico
                        from demanda d, sla_ativo_demanda a, sla, 
                             (select formulario_id, e.estado_id from estado_formulario e 
                              where (e.estado_final = 'N' or estado_final is null)) dems
                        where d.demanda_id = a.demanda_id
                        and   dems.formulario_id = d.formulario_id
                        and   dems.estado_id = d.situacao
                        and   a.sla_tendencia_id = sla.id
                        and   d.demanda_id = pn_demanda_id) d,
                       atributo_valor av,
                       sla_nivel nivel, padraohorario pad, dia,
                         estado_formulario ef
                    where d.formulario_id = ef.formulario_id
                    and   d.situacao = ef.estado_id
                    and   d.sla_tendencia_id = nivel.sla_id
                    and   d.padrao_horario_id = pad.id (+)
                    and   d.demanda_id = av.demanda_id (+)
                    and   d.atributo_id = av.atributo_id (+)
                    and   d.data_inicio_sla < dia.data
                    --Para melhorar a performance da consulta limita o dia maximo de calculo do SLA a partir da sysdate
                    --considerando os minutos do caminho critico e o percentual da maior faixa de sla
                    --considera finais de semana multiplicando por 1.4 e somando 2 dias
                    and   dia.data <= trunc(sysdate) +
                                  (nvl((select max(d.qtd_minutos_critico)* max(n.porcentagem/100 / (saida-entradaintervalo+saidaintervalo-entrada)) dias
                                        from sla, padraohorario p, sla_nivel n
                                        where sla.padrao_horario_id = p.id
                                        and   sla.id = n.sla_id
                                        and   sla.id = d.sla_tendencia_id),0
                                        ) *1.4 + 2)
                    and   (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - d.qtd_minutos_critico > 
                          (f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0) + 
                           f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                           (f_diasuteisentre(trunc(d.data_inicio_sla+1),dia.data-1)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440))
                    and   (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - d.qtd_minutos_critico <=
                          (f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0) + 
                           f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                           (f_diasuteisentre(trunc(d.data_inicio_sla+1),dia.data)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440))
                    union all
                    --SLA de Tendencia no dia
                    select d.demanda_id, 
                           nvl(av.valornumerico, d.qtd_minutos_critico),
                           nivel.porcentagem, 
                           nivel.estado_sla_id,
                           nivel.cor,
                           greatest(d.data_inicio_sla, case when  (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - d.qtd_minutos_critico <=
                                      f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0)
                                then  d.data_inicio_sla + 
                                      ((nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - d.qtd_minutos_critico)/24/60
                                else  trunc(d.data_inicio_sla) + 
                                      (greatest(nvl(pad.entradaintervalo,720),(d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60) + 
                                       (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - 
                                       d.qtd_minutos_critico - 
                                       f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0))/24/60
                                end),                                 
                          d.padrao_horario_id
                    from (select /*  ordered */ d.demanda_id, d.formulario_id, d.situacao, a.sla_tendencia_id, sla.atributo_id, sla.qtd_minutos, sla.padrao_horario_id, d.data_inicio_sla, a.qtd_minutos_critico
                        from demanda d, sla_ativo_demanda a, sla, 
                             (select formulario_id, e.estado_id from estado_formulario e 
                              where (e.estado_final = 'N' or estado_final is null)) dems
                        where d.demanda_id = a.demanda_id
                        and   dems.formulario_id = d.formulario_id
                        and   dems.estado_id = d.situacao
                        and   a.sla_tendencia_id = sla.id
                        and   d.demanda_id = pn_demanda_id) d,
                       atributo_valor av,
                       sla_nivel nivel, padraohorario pad,
                       estado_formulario ef
                    where d.formulario_id = ef.formulario_id
                    and   d.situacao = ef.estado_id
                    and   d.sla_tendencia_id = nivel.sla_id
                    and   d.padrao_horario_id = pad.id (+)
                    and   d.demanda_id = av.demanda_id (+)
                    and   d.atributo_id = av.atributo_id (+)
                    and   (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - d.qtd_minutos_critico <= 
                          (f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0) + 
                           f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entradaintervalo,720))),0))
                    order by demanda_id, porcentagem) loop

             if ln_demanda_id is not null and
                (ln_demanda_id <> c.demanda_id or ld_inicio <> c.horario) then
                if ln_demanda_id = c.demanda_id then
                   ld_fim := c.horario;
                else
                   ld_fim := to_date ( '29991231', 'yyyymmdd');
                end if;
             
                insert into demanda_faixas_sla (demanda_id, tipo_sla, estado_sla_id, inicio, fim, cor, tempo_sla, porcentagem, padrao_horario_id)
                values (ln_demanda_id, 'T', ln_estado_sla_id, ld_inicio, ld_fim, lv_cor, ln_qtd_minutos, ln_perc, ln_padrao_horario_id);
             end if;
             
             ln_demanda_id := c.demanda_id;
             ln_estado_sla_id := c.estado_sla_id;
             ld_inicio := c.horario;
             lv_cor := c.cor;
             ln_qtd_minutos := 0;
             ln_perc := c.porcentagem;
             ln_padrao_horario_id := c.padrao_horario_id;
         end loop;
         
         if ln_demanda_id is not null then
            ld_fim := to_date ( '29991231', 'yyyymmdd');
         
            insert into demanda_faixas_sla (demanda_id, tipo_sla, estado_sla_id, inicio, fim, cor, tempo_sla, porcentagem, padrao_horario_id)
            values (ln_demanda_id, 'T', ln_estado_sla_id, ld_inicio, ld_fim, lv_cor, ln_qtd_minutos, ln_perc, ln_padrao_horario_id);
         end if;
      end if;

      if pb_estado then
         ln_demanda_id := null;
         ld_inicio := null;
         lv_cor := null;
         ln_estado_sla_id := null;
         ln_qtd_minutos := null;
         ln_perc := null;
         ln_padrao_horario_id := null;
         for c in (select d.demanda_id demanda_id, 
                           nvl(av.valornumerico, d.qtd_minutos) qtd_minutos_aux,
                           nivel.porcentagem porcentagem, 
                           nivel.estado_sla_id estado_sla_id,
                           nivel.cor cor,
                           case when nvl(pad.saidaintervalo,720) - nvl(pad.entrada,0) >=
                                      ((nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - 
                                      (f_diasuteisentre(d.date_update_situacao,d.date_update_situacao)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.date_update_situacao - trunc(d.date_update_situacao))*24*60,nvl(pad.entrada,0))),0) + 
                                       f_diasuteisentre(d.date_update_situacao,d.date_update_situacao)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.date_update_situacao - trunc(d.date_update_situacao))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                                       (f_diasuteisentre(trunc(d.date_update_situacao+1),dia.data-1)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440)))
                                then dia.data + 
                                     (nvl(pad.entrada,0) +
                                      ((nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - 
                                      (f_diasuteisentre(d.date_update_situacao,d.date_update_situacao)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.date_update_situacao - trunc(d.date_update_situacao))*24*60,nvl(pad.entrada,0))),0) + 
                                       f_diasuteisentre(d.date_update_situacao,d.date_update_situacao)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.date_update_situacao - trunc(d.date_update_situacao))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                                       ((f_diasuteisentre(trunc(d.date_update_situacao+1),dia.data-1)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440)))))/24/60
                                else dia.data + 
                                     (nvl(pad.entradaintervalo,720) + 
                                      ((nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - 
                                       (nvl(pad.saidaintervalo,720) - nvl(pad.entrada,0)) - 
                                      (f_diasuteisentre(d.date_update_situacao,d.date_update_situacao)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.date_update_situacao - trunc(d.date_update_situacao))*24*60,nvl(pad.entrada,0))),0) + 
                                       f_diasuteisentre(d.date_update_situacao,d.date_update_situacao)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.date_update_situacao - trunc(d.date_update_situacao))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                                       ((f_diasuteisentre(trunc(d.date_update_situacao+1),dia.data-1)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440)))))/24/60
                                end horario,
                          d.padrao_horario_id padrao_horario_id
                    from (select /*  ordered */ d.demanda_id, d.formulario_id, d.situacao, a.sla_estado_id sla, sla.atributo_id, sla.qtd_minutos, sla.padrao_horario_id, d.date_update_situacao
                          from demanda d, sla_ativo_demanda a, sla, 
                             (select formulario_id, e.estado_id from estado_formulario e 
                              where (e.estado_final = 'N' or estado_final is null)) dems
                        where d.demanda_id = a.demanda_id
                        and   dems.formulario_id = d.formulario_id
                        and   dems.estado_id = d.situacao
                        and   a.sla_estado_id = sla.id
                        and   d.demanda_id = pn_demanda_id) d,
                        atributo_valor av,
                        sla_nivel nivel, padraohorario pad, dia
                    where d.sla = nivel.sla_id
                    and   d.padrao_horario_id = pad.id (+)
                    and   d.demanda_id = av.demanda_id (+)
                    and   d.atributo_id = av.atributo_id (+)
                    and   d.date_update_situacao < dia.data
                    and   dia.data <= trunc(sysdate) +
                                  (greatest(nvl((select max(qtd_minutos)* max(n.porcentagem/100 / (saida-entradaintervalo+saidaintervalo-entrada)) dias
                                        from sla, padraohorario p, sla_nivel n
                                        where sla.padrao_horario_id = p.id
                                        and   sla.id = n.sla_id
                                        and   sla.id = d.sla),0
                                        ),
                                        nvl((select max(valornumerico)* max(n.porcentagem/100 / (saida-entradaintervalo+saidaintervalo-entrada)) dias
                                        from sla, atributo_valor av, sla_nivel n, padraohorario p
                                        where sla.atributo_id = av.atributo_id
                                        and   sla.padrao_horario_id = p.id
                                        and   sla.id = n.sla_id
                                        and   sla.id = d.sla
                                        and   av.demanda_id = pn_demanda_id),0
                                        )) *1.4 + 2)
                    and   (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) > 
                          (f_diasuteisentre(d.date_update_situacao,d.date_update_situacao)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.date_update_situacao - trunc(d.date_update_situacao))*24*60,nvl(pad.entrada,0))),0) + 
                           f_diasuteisentre(d.date_update_situacao,d.date_update_situacao)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.date_update_situacao - trunc(d.date_update_situacao))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                           (f_diasuteisentre(trunc(d.date_update_situacao+1),dia.data-1)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440))
                    and   (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) <=
                          (f_diasuteisentre(d.date_update_situacao,d.date_update_situacao)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.date_update_situacao - trunc(d.date_update_situacao))*24*60,nvl(pad.entrada,0))),0) + 
                           f_diasuteisentre(d.date_update_situacao,d.date_update_situacao)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.date_update_situacao - trunc(d.date_update_situacao))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                           (f_diasuteisentre(trunc(d.date_update_situacao+1),dia.data)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440))
                    union all
                    -- SLA de Estado para o dia da troca de estado
                    select d.demanda_id, 
                           nvl(av.valornumerico, d.qtd_minutos),
                           nivel.porcentagem, 
                           nivel.estado_sla_id,
                           nivel.cor,
                           case when (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) <=
                                      f_diasuteisentre(d.date_update_situacao,d.date_update_situacao)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.date_update_situacao - trunc(d.date_update_situacao))*24*60,nvl(pad.entrada,0))),0)
                                then d.date_update_situacao + 
                                      (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) /24/60
                                else trunc(d.date_update_situacao) + 
                                     (greatest(nvl(entradaintervalo,720),(d.date_update_situacao - trunc(d.date_update_situacao))*24*60) + 
                                      (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - 
                                       f_diasuteisentre(d.date_update_situacao,d.date_update_situacao)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.date_update_situacao - trunc(d.date_update_situacao))*24*60,nvl(pad.entrada,0))),0))/24/60
                           end,
                           d.padrao_horario_id
                    from (select /*  ordered */ d.demanda_id, d.formulario_id, d.situacao, a.sla_estado_id sla, sla.atributo_id, sla.qtd_minutos, sla.padrao_horario_id, d.date_update_situacao
                          from demanda d, sla_ativo_demanda a, sla, 
                             (select formulario_id, e.estado_id, e.sla_default_id sla from estado_formulario e 
                              where (e.estado_final = 'N' or estado_final is null)) dems
                          where d.demanda_id = a.demanda_id
                          and   dems.formulario_id = d.formulario_id
                          and   dems.estado_id = d.situacao
                          and   a.sla_estado_id = sla.id
                          and   d.demanda_id = pn_demanda_id) d,
                          atributo_valor av,
                          sla_nivel nivel, padraohorario pad
                    where d.sla = nivel.sla_id
                    and   d.padrao_horario_id = pad.id (+)
                    and   d.demanda_id = av.demanda_id (+)
                    and   d.atributo_id = av.atributo_id (+)
                    and   (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) <= 
                          (f_diasuteisentre(d.date_update_situacao,d.date_update_situacao)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.date_update_situacao - trunc(d.date_update_situacao))*24*60,nvl(pad.entrada,0))),0) + 
                           f_diasuteisentre(d.date_update_situacao,d.date_update_situacao)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.date_update_situacao - trunc(d.date_update_situacao))*24*60,nvl(pad.entradaintervalo,720))),0))
                    order by demanda_id, horario) loop

             if ln_demanda_id is not null and
                (ln_demanda_id <> c.demanda_id or ld_inicio <> c.horario) then
                if ln_demanda_id = c.demanda_id then
                   ld_fim := c.horario;
                else
                   ld_fim := to_date ( '29991231', 'yyyymmdd');
                end if;
             
                insert into demanda_faixas_sla (demanda_id, tipo_sla, estado_sla_id, inicio, fim, cor, tempo_sla, porcentagem, padrao_horario_id)
                values (ln_demanda_id, 'E', ln_estado_sla_id, ld_inicio, ld_fim, lv_cor, ln_qtd_minutos, ln_perc, ln_padrao_horario_id);
             end if;
             
             ln_demanda_id := c.demanda_id;
             ln_estado_sla_id := c.estado_sla_id;
             ld_inicio := c.horario;
             lv_cor := c.cor;
             ln_qtd_minutos := c.qtd_minutos_aux;
             ln_perc := c.porcentagem;
             ln_padrao_horario_id := c.padrao_horario_id;
         end loop;
         
         if ln_demanda_id is not null then
            ld_fim := to_date ( '29991231', 'yyyymmdd');
         
            insert into demanda_faixas_sla (demanda_id, tipo_sla, estado_sla_id, inicio, fim, cor, tempo_sla, porcentagem, padrao_horario_id)
            values (ln_demanda_id, 'E', ln_estado_sla_id, ld_inicio, ld_fim, lv_cor, ln_qtd_minutos, ln_perc, ln_padrao_horario_id);
         end if;
      end if;

   end;

   procedure pCalcula_Lote (pn_demanda_id demanda.demanda_id%type,
                       pn_sla_id     sla.id%type,
                       pb_processo   boolean,
                       pb_estado     boolean,
                       pb_tendencia  boolean) is

   ln_processo number;
   ln_estado number;
   ln_tendencia number;
   ln_demanda_id demanda.demanda_id%type;
   ld_inicio demanda.data_inicio_sla%type;
   lv_cor sla_nivel.cor%type;
   ln_estado_sla_id sla_nivel.estado_sla_id%type;
   ld_fim demanda.data_inicio_sla%type;
   ln_qtd_minutos sla.qtd_minutos%type;
   ln_perc number;
   ln_padrao_horario_id number;
   cont number:=0;
   
   begin
      if pb_processo then
         ln_processo := 1;
      else
         ln_processo := 0;
      end if;
      if pb_estado then
         ln_estado := 1;
      else
         ln_estado := 0;
      end if;
      if pb_tendencia then
         ln_tendencia := 1;
      else
         ln_tendencia := 0;
      end if;

      delete demanda_faixas_sla
      where  demanda_id = pn_demanda_id
      and    ((ln_processo = 1 and tipo_sla = 'P') or
              (ln_tendencia = 1 and tipo_sla = 'T') or
              (ln_estado = 1 and tipo_sla = 'E'));
      
      if pb_processo then
         ln_demanda_id := null;
         ld_inicio := null;
         lv_cor := null;
         ln_estado_sla_id := null;
         ln_qtd_minutos:=null;
         ln_perc := null;
         ln_padrao_horario_id := null;
         for c in (select /*  full(av) use_hash(av) */ d.demanda_id demanda_id, 
                         nvl(av.valornumerico, d.qtd_minutos) qtd_minutos_aux,
                         nivel.porcentagem porcentagem, 
                         nivel.cor cor,
                         nivel.estado_sla_id estado_sla_id,
                         case when  pad.saidaintervalo - pad.entrada >=
                                    ((nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - 
                                     (f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0) + 
                                      f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                                     (f_diasuteisentre(trunc(d.data_inicio_sla+1),dia.data-1)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440)))
                              then dia.data + 
                                   (nvl(pad.entrada,0) +
                                    ((nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - 
                                    (f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0) + 
                                     f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                                     ((f_diasuteisentre(trunc(d.data_inicio_sla+1),dia.data-1)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440)))))/24/60
                              else dia.data + 
                                   (nvl(pad.entradaintervalo,720) + 
                                    ((nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - 
                                     nvl(pad.saidaintervalo - pad.entrada,720) - 
                                     (f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0) + 
                                      f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                                     ((f_diasuteisentre(trunc(d.data_inicio_sla+1),dia.data-1)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440)))))/24/60
                              end horario,
                         d.padrao_horario_id padrao_horario_id
                  from (select /*  ordered */ d.demanda_id, a.sla_processo_id, sla.atributo_id, sla.qtd_minutos, sla.padrao_horario_id, d.data_inicio_sla
                        from demanda d, sla_ativo_demanda a, sla, 
                             (select formulario_id, e.estado_id from estado_formulario e 
                              ) dems
                        where d.demanda_id = a.demanda_id
                        and   dems.formulario_id = d.formulario_id
                        and   dems.estado_id = d.situacao
                        and   a.sla_processo_id = sla.id) d,
                       atributo_valor av,
                       sla_nivel nivel, padraohorario pad, dia
                  where d.sla_processo_id = nivel.sla_id
                  and   d.padrao_horario_id = pad.id (+)
                  and   d.demanda_id = av.demanda_id (+)
                  and   d.atributo_id = av.atributo_id (+)
                  and   d.data_inicio_sla < dia.data
                  and   dia.data <= trunc(sysdate) +
                                (greatest(nvl((select max(qtd_minutos)* max(n.porcentagem/100 / (saida-entradaintervalo+saidaintervalo-entrada)) dias
                                      from sla, padraohorario p, sla_nivel n
                                      where sla.padrao_horario_id = p.id
                                      and   sla.id = n.sla_id),0
                                      ),
                                      nvl((select max(valornumerico)* max(n.porcentagem/100 / (saida-entradaintervalo+saidaintervalo-entrada)) dias
                                      from sla, atributo_valor av, sla_nivel n, padraohorario p
                                      where sla.atributo_id = av.atributo_id
                                      and   sla.padrao_horario_id = p.id
                                      and   sla.id = n.sla_id),0
                                      )) *1.4 + 2)
                  and   (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) > 
                        (f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0) + 
                         f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                         (f_diasuteisentre(trunc(d.data_inicio_sla+1),dia.data-1)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440))
                  and   (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) <=
                        (f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0) + 
                         f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                         (f_diasuteisentre(trunc(d.data_inicio_sla+1),dia.data)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440))
                  union all
                  --SLA de Processo no dia
                  select /*  full(av) use_hash(av) */ d.demanda_id, 
                         nvl(av.valornumerico, d.qtd_minutos) ,
                         nivel.porcentagem, 
                         nivel.cor,
                         nivel.estado_sla_id,
                         case when (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) <=
                                            f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0)
                                      then d.data_inicio_sla + 
                                            ((nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100)/24/60)
                                      else trunc(d.data_inicio_sla) + 
                                           (greatest(nvl(pad.entradaintervalo,720),(d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60) + 
                                            (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - 
                                            (greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0)))/24/60
                              end,
                         d.padrao_horario_id
                  from (select /*  ordered */ d.demanda_id, a.sla_processo_id, sla.atributo_id, sla.qtd_minutos, sla.padrao_horario_id, d.data_inicio_sla
                        from demanda d, sla_ativo_demanda a, sla, 
                             (select formulario_id, e.estado_id from estado_formulario e 
                              ) dems
                        where d.demanda_id = a.demanda_id
                        and   dems.formulario_id = d.formulario_id
                        and   dems.estado_id = d.situacao
                        and   a.sla_processo_id = sla.id) d,
                       atributo_valor av,
                       sla_nivel nivel, padraohorario pad
                  where d.sla_processo_id = nivel.sla_id
                  and   d.padrao_horario_id = pad.id (+)
                  and   d.demanda_id = av.demanda_id (+)
                  and   d.atributo_id = av.atributo_id (+)
                  and   (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) <= 
                        (f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0) + 
                         f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entradaintervalo,720))),0))
                  order by demanda_id, horario) loop

             if ln_demanda_id is not null then
                if ln_demanda_id = c.demanda_id then
                   ld_fim := c.horario;
                else
                   ld_fim := to_date ( '29991231', 'yyyymmdd');
                end if;
             
                insert into demanda_faixas_sla (demanda_id, tipo_sla, estado_sla_id, inicio, fim, cor, tempo_sla, porcentagem, padrao_horario_id)
                values (ln_demanda_id, 'P', ln_estado_sla_id, ld_inicio, ld_fim, lv_cor, ln_qtd_minutos, ln_perc, ln_padrao_horario_id);
             end if;
             
             cont:= cont+1;
             
             if mod(cont,1000)=0 then
                commit;
             end if;
             
             ln_demanda_id := c.demanda_id;
             ln_estado_sla_id := c.estado_sla_id;
             ld_inicio := c.horario;
             lv_cor := c.cor;
             ln_qtd_minutos := c.qtd_minutos_aux;
             ln_perc := c.porcentagem;
             ln_padrao_horario_id := c.padrao_horario_id;
         end loop;
         
         if ln_demanda_id is not null then
            ld_fim := to_date ( '29991231', 'yyyymmdd');
         
            insert into demanda_faixas_sla (demanda_id, tipo_sla, estado_sla_id, inicio, fim, cor, tempo_sla, porcentagem, padrao_horario_id )
            values (ln_demanda_id, 'P', ln_estado_sla_id, ld_inicio, ld_fim, lv_cor, ln_qtd_minutos, ln_perc, ln_padrao_horario_id);
         end if;
      end if;

      if pb_tendencia then
         ln_demanda_id := null;
         ld_inicio := null;
         lv_cor := null;
         ln_estado_sla_id := null;
         ln_qtd_minutos := null;
         ln_perc:= null;
         ln_padrao_horario_id := null;
         for c in (select /*  full(av) use_hash(av) */ d.demanda_id demanda_id, 
                           nvl(av.valornumerico, d.qtd_minutos_critico) qtd_minutos_aux,
                           nivel.porcentagem porcentagem, 
                           nivel.estado_sla_id estado_sla_id,
                           nivel.cor cor,
                           case when  pad.saidaintervalo - pad.entrada >=
                                      ((nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - 
                                       d.qtd_minutos_critico - 
                                      (f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0) + 
                                       f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                                       (f_diasuteisentre(trunc(d.data_inicio_sla+1),dia.data-1)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440)))
                                then dia.data + 
                                     (nvl(pad.entrada,0) +
                                      ((nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - 
                                       d.qtd_minutos_critico - 
                                      (f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0) + 
                                       f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                                       ((f_diasuteisentre(trunc(d.data_inicio_sla+1),dia.data-1)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440)))))/24/60
                                else dia.data + 
                                     (nvl(pad.entradaintervalo,720) + 
                                      ((nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - 
                                       d.qtd_minutos_critico - 
                                       nvl(pad.saidaintervalo - pad.entrada,720) - 
                                      (f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0) + 
                                       f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                                       ((f_diasuteisentre(trunc(d.data_inicio_sla+1),dia.data-1)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440)))))/24/60
                                end horario,
                         d.padrao_horario_id padrao_horario_id
                    from (select /*  ordered */ d.demanda_id, d.formulario_id, d.situacao, a.sla_tendencia_id, sla.atributo_id, sla.qtd_minutos, sla.padrao_horario_id, d.data_inicio_sla, a.qtd_minutos_critico
                        from demanda d, sla_ativo_demanda a, sla, 
                             (select formulario_id, e.estado_id from estado_formulario e 
                              where estado_final = 'N' or estado_final is null
                              ) dems
                        where d.demanda_id = a.demanda_id
                        and   dems.formulario_id = d.formulario_id
                        and   dems.estado_id = d.situacao
                        and   a.sla_tendencia_id = sla.id) d,
                       atributo_valor av,
                       sla_nivel nivel, padraohorario pad, dia,
                         estado_formulario ef
                    where d.formulario_id = ef.formulario_id
                    and   d.situacao = ef.estado_id
                    and   d.sla_tendencia_id = nivel.sla_id
                    and   d.padrao_horario_id = pad.id (+)
                    and   d.demanda_id = av.demanda_id (+)
                    and   d.atributo_id = av.atributo_id (+)
                    and   d.data_inicio_sla < dia.data
                    --Para melhorar a performance da consulta limita o dia maximo de calculo do SLA a partir da sysdate
                    --considerando os minutos do caminho critico e o percentual da maior faixa de sla
                    --considera finais de semana multiplicando por 1.4 e somando 2 dias
                    and   dia.data <= trunc(sysdate) + 
                                  (nvl((select max(a.qtd_minutos_critico) * max(n.porcentagem/100 / (saida-entradaintervalo+saidaintervalo-entrada)) dias
                                        from sla, padraohorario p, sla_nivel n, sla_ativo_demanda a
                                        where sla.padrao_horario_id = p.id
                                        and   sla.id = n.sla_id),0
                                        ) *1.4 + 2)
                    and   (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - d.qtd_minutos_critico > 
                          (f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0) + 
                           f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                           (f_diasuteisentre(trunc(d.data_inicio_sla+1),dia.data-1)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440))
                    and   (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - d.qtd_minutos_critico <=
                          (f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0) + 
                           f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                           (f_diasuteisentre(trunc(d.data_inicio_sla+1),dia.data)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440))
                    union all
                    --SLA de Tendencia no dia
                    select /*  full(av) use_hash(av) */d.demanda_id, 
                           nvl(av.valornumerico, d.qtd_minutos_critico),
                           nivel.porcentagem, 
                           nivel.estado_sla_id,
                           nivel.cor,
                           greatest(d.data_inicio_sla, case when  (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - d.qtd_minutos_critico <=
                                      f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0)
                                then  d.data_inicio_sla + 
                                      ((nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - d.qtd_minutos_critico)/24/60
                                else  trunc(d.data_inicio_sla) + 
                                      (greatest(nvl(pad.entradaintervalo,720),(d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60) + 
                                       (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - 
                                       d.qtd_minutos_critico - 
                                       f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0))/24/60
                                end) ,
                          d.padrao_horario_id 
                    from (select /*  ordered */ d.demanda_id, d.formulario_id, d.situacao, a.sla_tendencia_id, sla.atributo_id, sla.qtd_minutos, sla.padrao_horario_id, d.data_inicio_sla, a.qtd_minutos_critico
                        from demanda d, sla_ativo_demanda a, sla, 
                             (select formulario_id, e.estado_id from estado_formulario e 
                              where estado_final = 'N' or estado_final is null
                              ) dems
                        where d.demanda_id = a.demanda_id
                        and   dems.formulario_id = d.formulario_id
                        and   dems.estado_id = d.situacao
                        and   a.sla_tendencia_id = sla.id) d,
                       atributo_valor av,
                       sla_nivel nivel, padraohorario pad,
                       estado_formulario ef
                    where d.formulario_id = ef.formulario_id
                    and   d.situacao = ef.estado_id
                    and   d.sla_tendencia_id = nivel.sla_id
                    and   d.padrao_horario_id = pad.id (+)
                    and   d.demanda_id = av.demanda_id (+)
                    and   d.atributo_id = av.atributo_id (+)
                    and   (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - d.qtd_minutos_critico <= 
                          (f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entrada,0))),0) + 
                           f_diasuteisentre(d.data_inicio_sla,d.data_inicio_sla)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.data_inicio_sla - trunc(d.data_inicio_sla))*24*60,nvl(pad.entradaintervalo,720))),0))
                    order by demanda_id, porcentagem) loop

             if ln_demanda_id is not null and
                (ln_demanda_id <> c.demanda_id or ld_inicio <> c.horario) then
                if ln_demanda_id = c.demanda_id then
                   ld_fim := c.horario;
                else
                   ld_fim := to_date ( '29991231', 'yyyymmdd');
                end if;
             
                insert into demanda_faixas_sla (demanda_id, tipo_sla, estado_sla_id, inicio, fim, cor, tempo_sla, porcentagem, padrao_horario_id)
                values (ln_demanda_id, 'T', ln_estado_sla_id, ld_inicio, ld_fim, lv_cor, ln_qtd_minutos, ln_perc, ln_padrao_horario_id);
             end if;
             
             cont:= cont+1;
             
             if mod(cont,1000)=0 then
                commit;
             end if;
             
             ln_demanda_id := c.demanda_id;
             ln_estado_sla_id := c.estado_sla_id;
             ld_inicio := c.horario;
             lv_cor := c.cor;
             ln_qtd_minutos := 0;
             ln_perc := c.porcentagem;
             ln_padrao_horario_id := c.padrao_horario_id;
         end loop;
         
         if ln_demanda_id is not null then
            ld_fim := to_date ( '29991231', 'yyyymmdd');
         
            insert into demanda_faixas_sla (demanda_id, tipo_sla, estado_sla_id, inicio, fim, cor, tempo_sla, porcentagem, padrao_horario_id)
            values (ln_demanda_id, 'T', ln_estado_sla_id, ld_inicio, ld_fim, lv_cor, ln_qtd_minutos, ln_perc, ln_padrao_horario_id);
         end if;
      end if;

      if pb_estado then
         ln_demanda_id := null;
         ld_inicio := null;
         lv_cor := null;
         ln_estado_sla_id := null;
         ln_qtd_minutos := null;
         ln_perc := null;
         ln_padrao_horario_id := null;
         for c in (select /*  full(av) use_hash(av) */d.demanda_id demanda_id, 
                           nvl(av.valornumerico, d.qtd_minutos) qtd_minutos_aux,
                           nivel.porcentagem porcentagem, 
                           nivel.estado_sla_id estado_sla_id,
                           nivel.cor cor,
                           case when nvl(pad.saidaintervalo,720) - nvl(pad.entrada,0) >=
                                      ((nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - 
                                      (f_diasuteisentre(d.date_update_situacao,d.date_update_situacao)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.date_update_situacao - trunc(d.date_update_situacao))*24*60,nvl(pad.entrada,0))),0) + 
                                       f_diasuteisentre(d.date_update_situacao,d.date_update_situacao)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.date_update_situacao - trunc(d.date_update_situacao))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                                       (f_diasuteisentre(trunc(d.date_update_situacao+1),dia.data-1)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440)))
                                then dia.data + 
                                     (nvl(pad.entrada,0) +
                                      ((nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - 
                                      (f_diasuteisentre(d.date_update_situacao,d.date_update_situacao)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.date_update_situacao - trunc(d.date_update_situacao))*24*60,nvl(pad.entrada,0))),0) + 
                                       f_diasuteisentre(d.date_update_situacao,d.date_update_situacao)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.date_update_situacao - trunc(d.date_update_situacao))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                                       ((f_diasuteisentre(trunc(d.date_update_situacao+1),dia.data-1)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440)))))/24/60
                                else dia.data + 
                                     (nvl(pad.entradaintervalo,720) + 
                                      ((nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - 
                                       (nvl(pad.saidaintervalo,720) - nvl(pad.entrada,0)) - 
                                      (f_diasuteisentre(d.date_update_situacao,d.date_update_situacao)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.date_update_situacao - trunc(d.date_update_situacao))*24*60,nvl(pad.entrada,0))),0) + 
                                       f_diasuteisentre(d.date_update_situacao,d.date_update_situacao)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.date_update_situacao - trunc(d.date_update_situacao))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                                       ((f_diasuteisentre(trunc(d.date_update_situacao+1),dia.data-1)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440)))))/24/60
                                end horario,
                         d.padrao_horario_id padrao_horario_id
                    from (select /*  ordered */ d.demanda_id, d.formulario_id, d.situacao, a.sla_estado_id sla, sla.atributo_id, sla.qtd_minutos, sla.padrao_horario_id, d.date_update_situacao
                          from demanda d, sla_ativo_demanda a, sla, 
                             (select formulario_id, e.estado_id, e.sla_default_id sla from estado_formulario e 
                              where estado_final = 'N' or estado_final is null
                              ) dems
                        where d.demanda_id = a.demanda_id
                        and   dems.formulario_id = d.formulario_id
                        and   dems.estado_id = d.situacao
                        and   a.sla_estado_id = sla.id) d,
                        atributo_valor av,
                        sla_nivel nivel, padraohorario pad, dia
                    where d.sla = nivel.sla_id
                    and   d.padrao_horario_id = pad.id (+)
                    and   d.demanda_id = av.demanda_id (+)
                    and   d.atributo_id = av.atributo_id (+)
                    and   d.date_update_situacao < dia.data
                    and   dia.data <= trunc(sysdate) +
                                  (greatest(nvl((select max(qtd_minutos)* max(n.porcentagem/100 / (saida-entradaintervalo+saidaintervalo-entrada)) dias
                                        from sla, padraohorario p, sla_nivel n
                                        where sla.padrao_horario_id = p.id
                                        and   sla.id = n.sla_id),0
                                        ),
                                        nvl((select max(valornumerico)* max(n.porcentagem/100 / (saida-entradaintervalo+saidaintervalo-entrada)) dias
                                        from sla, atributo_valor av, sla_nivel n, padraohorario p
                                        where sla.atributo_id = av.atributo_id
                                        and   sla.padrao_horario_id = p.id
                                        and   sla.id = n.sla_id),0
                                        )) *1.4 + 2)
                    and   (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) > 
                          (f_diasuteisentre(d.date_update_situacao,d.date_update_situacao)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.date_update_situacao - trunc(d.date_update_situacao))*24*60,nvl(pad.entrada,0))),0) + 
                           f_diasuteisentre(d.date_update_situacao,d.date_update_situacao)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.date_update_situacao - trunc(d.date_update_situacao))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                           (f_diasuteisentre(trunc(d.date_update_situacao+1),dia.data-1)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440))
                    and   (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) <=
                          (f_diasuteisentre(d.date_update_situacao,d.date_update_situacao)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.date_update_situacao - trunc(d.date_update_situacao))*24*60,nvl(pad.entrada,0))),0) + 
                           f_diasuteisentre(d.date_update_situacao,d.date_update_situacao)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.date_update_situacao - trunc(d.date_update_situacao))*24*60,nvl(pad.entradaintervalo,720))),0) + 
                           (f_diasuteisentre(trunc(d.date_update_situacao+1),dia.data)) * nvl(pad.saidaintervalo - pad.entrada + pad.saida - pad.entradaintervalo,1440))
                    union all
                    -- SLA de Estado para o dia da troca de estado
                    select /*  full(av) use_hash(av) */ d.demanda_id, 
                           nvl(av.valornumerico, d.qtd_minutos) ,
                           nivel.porcentagem, 
                           nivel.estado_sla_id,
                           nivel.cor,
                           case when (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) <=
                                      f_diasuteisentre(d.date_update_situacao,d.date_update_situacao)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.date_update_situacao - trunc(d.date_update_situacao))*24*60,nvl(pad.entrada,0))),0)
                                then d.date_update_situacao + 
                                      (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) /24/60
                                else trunc(d.date_update_situacao) + 
                                     (greatest(nvl(entradaintervalo,720),(d.date_update_situacao - trunc(d.date_update_situacao))*24*60) + 
                                      (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) - 
                                       f_diasuteisentre(d.date_update_situacao,d.date_update_situacao)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.date_update_situacao - trunc(d.date_update_situacao))*24*60,nvl(pad.entrada,0))),0))/24/60
                           end,
                           padrao_horario_id
                    from (select /*  ordered */ d.demanda_id, d.formulario_id, d.situacao, a.sla_estado_id sla, sla.atributo_id, sla.qtd_minutos, sla.padrao_horario_id, d.date_update_situacao
                          from demanda d, sla_ativo_demanda a, sla, 
                             (select formulario_id, e.estado_id, e.sla_default_id sla from estado_formulario e 
                              where estado_final = 'N' or estado_final is null
                              ) dems
                          where d.demanda_id = a.demanda_id
                          and   dems.formulario_id = d.formulario_id
                          and   dems.estado_id = d.situacao
                          and   a.sla_estado_id = sla.id) d,
                          atributo_valor av,
                          sla_nivel nivel, padraohorario pad
                    where d.sla = nivel.sla_id
                    and   d.padrao_horario_id = pad.id (+)
                    and   d.demanda_id = av.demanda_id (+)
                    and   d.atributo_id = av.atributo_id (+)
                    and   (nivel.porcentagem * nvl(av.valornumerico, d.qtd_minutos) /100) <= 
                          (f_diasuteisentre(d.date_update_situacao,d.date_update_situacao)*greatest(trunc(nvl(pad.saidaintervalo,720) - greatest((d.date_update_situacao - trunc(d.date_update_situacao))*24*60,nvl(pad.entrada,0))),0) + 
                           f_diasuteisentre(d.date_update_situacao,d.date_update_situacao)*greatest(trunc(nvl(pad.saida,1440) - greatest((d.date_update_situacao - trunc(d.date_update_situacao))*24*60,nvl(pad.entradaintervalo,720))),0))
                    order by demanda_id, horario) loop

             if ln_demanda_id is not null and
                (ln_demanda_id <> c.demanda_id or ld_inicio <> c.horario) then
                if ln_demanda_id = c.demanda_id then
                   ld_fim := c.horario;
                else
                   ld_fim := to_date ( '29991231', 'yyyymmdd');
                end if;
             
                insert into demanda_faixas_sla (demanda_id, tipo_sla, estado_sla_id, inicio, fim, cor, tempo_sla, porcentagem, padrao_horario_id)
                values (ln_demanda_id, 'E', ln_estado_sla_id, ld_inicio, ld_fim, lv_cor, ln_qtd_minutos, ln_perc, ln_padrao_horario_id);
             end if;
             
             cont:= cont+1;
             
             if mod(cont,1000)=0 then
                commit;
             end if;
                          
             ln_demanda_id := c.demanda_id;
             ln_estado_sla_id := c.estado_sla_id;
             ld_inicio := c.horario;
             lv_cor := c.cor;
             ln_qtd_minutos := c.qtd_minutos_aux;
             ln_perc := c.porcentagem;
             ln_padrao_horario_id := c.padrao_horario_id;
         end loop;
         
         if ln_demanda_id is not null then
            ld_fim := to_date ( '29991231', 'yyyymmdd');
         
            insert into demanda_faixas_sla (demanda_id, tipo_sla, estado_sla_id, inicio, fim, cor, tempo_sla, porcentagem, padrao_horario_id)
            values (ln_demanda_id, 'E', ln_estado_sla_id, ld_inicio, ld_fim, lv_cor, ln_qtd_minutos, ln_perc, ln_padrao_horario_id);
         end if;
      end if;

   end;

end;
/


commit;
/
-- Add/modify columns 
alter table HORAEXTRA add tipo_hora_extra_id number(10);
-- Create/Recreate primary, unique and foreign key constraints 
alter table HORAEXTRA
  add constraint FK_HORAEXTRA_03 foreign key (TIPO_HORA_EXTRA_ID)
  references tipo_hora_extra (ID);
  
alter table RELAT_DRILL_PARAMETRO add ordem number(10) default 0 not null;

alter table MAPA_INDICADOR modify PERIODO_APURACAO NUMBER(3);

alter table sla modify qtd_minutos number(10);

  
---------------------------------------
insert into relat_drill (ID, TITULO, DESCRICAO, URL, TIPO_URL)
values (4, 'Edição/Consulta de Tarefa', 'Edição/Consulta de Tarefa', 'f_editar_tarefa', 'F');

insert into relat_drill (ID, TITULO, DESCRICAO, URL, TIPO_URL)
values (5, 'Edição/Consulta de Atividade', 'Edição/Consulta de Atividade', 'f_editar_atividade', 'F');

insert into relat_drill (ID, TITULO, DESCRICAO, URL, TIPO_URL)
values (6, 'Edição/Consulta de Entidade', 'Edição/Consulta de Entidade', 'f_editar_entidade', 'F');

insert into relat_drill (ID, TITULO, DESCRICAO, URL, TIPO_URL)
values (2, 'Edição/Consulta de Projeto', 'Edição/Consulta de Projeto', 'f_editar_projeto', 'F');

insert into relat_drill (ID, TITULO, DESCRICAO, URL, TIPO_URL)
values (3, 'Edição/Consulta de Demanda', 'Edição/Consulta de Demanda', 'f_editar_demanda', 'F');

insert into relat_drill_parametro (ID, DRILL_ID, TITULO, SIGLA, VALOR_DEFAULT, ORDEM)
values (5, 4, 'Tarefa', 'tarefa', '', 0);

insert into relat_drill_parametro (ID, DRILL_ID, TITULO, SIGLA, VALOR_DEFAULT, ORDEM)
values (6, 5, 'Atividade', 'atividade', '', 0);

insert into relat_drill_parametro (ID, DRILL_ID, TITULO, SIGLA, VALOR_DEFAULT, ORDEM)
values (7, 6, 'Tipo (P,A,T,D)', 'tipo_entidade', '', 0);

insert into relat_drill_parametro (ID, DRILL_ID, TITULO, SIGLA, VALOR_DEFAULT, ORDEM)
values (8, 6, 'Id Entidade', 'entidade_id', '', 1);

insert into relat_drill_parametro (ID, DRILL_ID, TITULO, SIGLA, VALOR_DEFAULT, ORDEM)
values (2, 2, 'Projeto', 'projeto', '', 0);

insert into relat_drill_parametro (ID, DRILL_ID, TITULO, SIGLA, VALOR_DEFAULT, ORDEM)
values (3, 3, 'Demanda', 'demanda', '', 0);

commit;
/

------------------------------------------------------------------------------

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
          from (select hp.tarefa_id TAREFA_ID, hp.usuario_id USUARIO_ID, hp.data DATA,
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

create or replace view v_horas_acum as
select vh.tarefa_id, vh.usuario_id, vh.data, vh.hora_planejada_id, 
       vh.situacao_planejada, vh.situacao_valor, vh.ind_planejamento,
       vh.hora_alocada    HORAS_ALOCADAS_DIA,
       vh.hora_trabalhada HORAS_TRABALHADAS_DIA,
       vh.hora_planejada  HORAS_PLANEJADAS_DIA,
       sum(vh_acum.hora_alocada)    HORAS_ALOCADAS_ACUM,
       sum(vh_acum.hora_trabalhada) HORAS_TRABALHADAS_ACUM,
       sum(vh_acum.hora_planejada)  HORAS_PLANEJADAS_ACUM
  from v_horas vh,
       v_horas vh_acum
 where vh.tarefa_id  = vh_acum.tarefa_id
   and vh.usuario_id = vh_acum.usuario_id
   and vh.data >= vh_acum.data
group by vh.tarefa_id, vh.usuario_id, vh.data, vh.hora_planejada_id,
       vh.hora_alocada, vh.hora_trabalhada, vh.hora_planejada,   
       vh.situacao_planejada, vh.situacao_valor, vh.ind_planejamento;
   
create or replace view v_horas_totais as
select vh_acum.tarefa_id, vh_acum.usuario_id, vh_acum.data, vh_acum.hora_planejada_id,
       vh_acum.situacao_planejada, vh_acum.situacao_valor, vh_acum.ind_planejamento, 
       vh_acum.HORAS_ALOCADAS_DIA,
       vh_acum.HORAS_TRABALHADAS_DIA,
       vh_acum.HORAS_PLANEJADAS_DIA,
       vh_acum.HORAS_ALOCADAS_ACUM,
       vh_acum.HORAS_TRABALHADAS_ACUM,
       vh_acum.HORAS_PLANEJADAS_ACUM,
       sum(vh_total.HORAS_ALOCADAS_DIA)    HORAS_ALOCADAS_TOTAL,
       sum(vh_total.HORAS_TRABALHADAS_DIA) HORAS_TRABALHADAS_TOTAL,
       sum(vh_total.HORAS_PLANEJADAS_DIA)  HORAS_PLANEJADAS_TOTAL
  from v_horas_acum vh_acum,
       v_horas_acum vh_total
 where vh_acum.tarefa_id  = vh_total.tarefa_id
   and vh_acum.usuario_id = vh_total.usuario_id
group by vh_acum.tarefa_id, vh_acum.usuario_id, vh_acum.data, vh_acum.hora_planejada_id,
         vh_acum.situacao_planejada, vh_acum.situacao_valor, vh_acum.ind_planejamento,
         vh_acum.HORAS_ALOCADAS_DIA, vh_acum.HORAS_TRABALHADAS_DIA,
         vh_acum.HORAS_PLANEJADAS_DIA, vh_acum.HORAS_ALOCADAS_ACUM,
         vh_acum.HORAS_TRABALHADAS_ACUM, vh_acum.HORAS_PLANEJADAS_ACUM;

create or replace view v_horas_resumo as
select vht.tarefa_id, vht.usuario_id, vht.data, 
       decode (vht.hora_planejada_id, 0, null, vht.hora_planejada_id) hora_planejada_id,
       vht.situacao_planejada, vht.situacao_valor, vht.ind_planejamento, 
       vht.HORAS_PLANEJADAS_DIA, vht.HORAS_ALOCADAS_DIA, vht.HORAS_TRABALHADAS_DIA,
       vht.HORAS_PLANEJADAS_ACUM, vht.HORAS_ALOCADAS_ACUM, vht.HORAS_TRABALHADAS_ACUM,
       vht.HORAS_PLANEJADAS_TOTAL, vht.HORAS_ALOCADAS_TOTAL, vht.HORAS_TRABALHADAS_TOTAL,
       t.horasprevistas HORAS_PREVISTAS_TOTAL,
       chp.comentario ULTIMO_COMENTARIO, chp.data_update DATA_ULTIMO_COMENTARIO,
       chp.user_update USUARIO_ULTIMO_COMENTARIO,
       dhp.id DETALHE_ID,
       t.titulo TITULO_TAREFA, decode(t.projeto, null, 'A', 'P') CLASSE_TAREFA,
       t.situacao SITUACAO_TAREFA,
       case
         when nvl(t.prazorealizado, vht.data) < vht.data then 'Y'
         else 'N'
       end IND_CONCLUSAO_PREVIA
  from v_horas_totais vht,
       tarefa t,
       comentario_hora_planejada chp,
       detalhe_hora_planejada dhp
 where vht.tarefa_id = t.id
   and dhp.id_hora_planejada (+) = vht.hora_planejada_id
   and chp.id_hora_planejada (+) = vht.hora_planejada_id
   and (chp.data_update is null or
        chp.data_update = (select max(chp2.data_update)
                             from comentario_hora_planejada chp2
                            where chp2.id_hora_planejada = chp.id_hora_planejada));

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
 function regra_relevante_permite(pn_acao_id number, la_ids_invalidos t_ids) return number;
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
   
   ln_count number;
   begin
     --Se estiver buscando a entidade destino de atualizacao
     --vai ate a ultima entidade que pode conter atributos ou lancamentos
     if pb_get_update then
        ln_update := 1;
     end if;
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
       if pb_get_update then
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
             lv_where := ' and '|| lv_alias_atual || '.id in (select identidade from solicitacaoentidade where tipoentidade = ''P'' and solicitacao = ' || pn_demanda_id ||') ';
          elsif c.escopo = 'usuarioLogado' then
             lv_where := ' and '|| lv_alias_atual || '.usuarioid = '''||pv_usuario_id||''' ';
          elsif c.escopo = 'demandasProjetosAssociados' then
             lv_where := ' and '|| lv_alias_atual || '.demanda_id in (select d.identidade from solicitacaoentidade p, solicitacaoentidade d where p.tipoentidade = d.tipoentidade and p.identidade = d.identidade and p.tipoentidade = ''P'' and p.solicitacao = ' || pn_demanda_id ||') '||
                         ' and '|| lv_alias_atual || '.demanda_id <> ' || pn_demanda_id|| ' ';
          elsif c.escopo = 'demandasProjetosAssociadosMaisCorrente' then
             lv_where := ' and '|| lv_alias_atual || '.demanda_id in (select d.identidade from solicitacaoentidade p, solicitacaoentidade d where p.tipoentidade = d.tipoentidade and p.identidade = d.identidade and p.tipoentidade = ''P'' and p.solicitacao = ' || pn_demanda_id ||') ';
          elsif c.escopo = 'projetosDemandasFilhas' then
             lv_where := ' and '|| lv_alias_atual || '.id in (select identidade from solicitacaoentidade where tipoentidade = ''P'' and solicitacao in (select demanda_id from demanda where demanda_pai =  ' || pn_demanda_id ||')) ';
          elsif c.escopo = 'projetosDemandasFilhas' then
             lv_where := ' and '|| lv_alias_atual || '.id in (select identidade from solicitacaoentidade where tipoentidade = ''P'' and solicitacao in (select demanda_pai from demanda where demanda_id =  ' || pn_demanda_id ||')) ';
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
          if c.coluna is not null then
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
                 end if;
              else
                 lv_coluna := lv_alias_atual||'.'||lv_coluna;
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
           end if;
                  
           if c.total = c.linha then    
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
                    if c.tipo_valor in ('numero','horas','entidade', 'lancamento') then
                       lv_coluna := ' to_char('||lv_coluna||','''||lv_formato||''','''||const_nls_numero_sql||''') ';
                    else
                       lv_coluna := ' to_char('||lv_coluna||','''||lv_formato||''') ';
                    end if;
                 else
                    lv_coluna := ' ' || lv_coluna || ' ';
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

     if pb_get_sub_propriedade then
        lv_sql := ' select ' || lv_coluna || ' id '||
                  ' from ' || lv_from;
        if lv_where > ' ' then
           lv_sql := lv_sql || ' where ' || substr(lv_where, 5);
        end if;     
        return '('||lv_sql||')';   
     --Se o agrupador for do tipo lista, salva em tabela temporaria e 
     --retorna o ID da lista
     elsif pb_get_update then
        if lv_ultimo_tipo_valor in ('atributo','lancamento') then
           lv_sql := ' select distinct ' || lv_alias_atual_entidade||'.' || lv_coluna_pk_entidade || ' id '||
                     ' from ' || lv_from_entidade;
           if lv_where_entidade > ' ' then
              lv_sql := lv_sql || ' where ' || substr(lv_where_entidade, 5);
           end if;        
        else
           lv_sql := ' select distinct ' || lv_alias_atual||'.' || lv_coluna_pk || ' id '||
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

        lv_sql := ' begin ' ||
                  ' insert into regras_lista_temp ( lista_id, item, valor ) ' ||
                  ' select ' ||ln_seq_lista||', rownum, coluna ' || 
                  ' from (select distinct ' || lv_coluna || ' coluna ' ||
                  ' from ' || lv_from;
        if lv_where > ' ' then
           lv_sql := lv_sql || ' where ' || substr(lv_where, 5);
        end if;
         
        lv_sql := lv_sql || '); end;';
        --dbms_output.put_line('lv_sql:' || lv_sql);        
        execute immediate lv_sql;
        
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
        

        select count(*) into ln_count from  regras_lista_temp where lista_id = ln_seq_lista;

        lv_valor := '<REGRAS-LISTA-TEMP>'|| ln_seq_lista || '</REGRAS-LISTA-TEMP>';
        
        return lv_valor;
        
     elsif lb_concatena then
        lv_sql := ' select distinct ' || lv_coluna || ' coluna ' ||
                  ' from ' || lv_from;
        if lv_where > ' ' then
           lv_sql := lv_sql || ' where ' || substr(lv_where, 5);
        end if;
        
        execute immediate lv_sql;
        
        lv_valor := null;

        open lc_sql for lv_sql;
        
        while true loop
           fetch lc_sql into lv_valor_aux;
           exit when lc_sql%notfound;
           lv_valor := lv_valor || lv_valor_aux;
        end loop;

        return lv_valor;
        
     else
        lv_sql := ' select ' || lv_coluna ||
                  ' from ' || lv_from;
        if lv_where > ' ' then
           lv_sql := lv_sql || ' where ' || substr(lv_where, 5);
        end if;
        
        lv_sql := lv_sql || ' order by 1';

        lv_valor := null;
        dbms_output.put_line(lv_sql);
        open lc_sql for lv_sql;
        fetch lc_sql into lv_valor;
        
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
        for c in (select i.*, f.codigo codigo_funcao_filha
                  from regras_valid_funcao_item i,
                       regras_propriedade p,
                       regras_tipo_funcao f
                  where (i.validacao_item_id = pn_id or i.valid_funcao_item_id = pn_id)
                  and   i.val_1_2 = pn_val_1_2
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
           elsif c.tipo = 'V' then
              lb_result_item := f_teste_validacao ( pn_demanda_id, c.validacao_id, pv_usuario_id, pb_salvar_log_hist_trans, pn_transicao_id, ln_log_hist_condicao, 'O', pd_data_hist, pv_somente_teste, pv_usuario_autorizador);
           else
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
                     
                    if lv_valor = 'achou' then
                       lb_result_item := true;
                    else
                       lb_result_item := false;
                    end if;
                    
                 end if;
                 dbms_output.put_line('');
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
              
              if lb_result_item then
                 ln_cont_true := ln_cont_true + 1;
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
                                 lv_update_valor := ' begin '||
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
                lv_lista_lancamentos := lv_lista_lancamentos || ',' || f_get_numero(lv_valor_origem);
                if ln_linha = ln_total then
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
                         
                         if ln_tipo_lanc_dest is null and (lb_primeiro_lancamento or ln_custo_entidade_id <> rec_lancamento.custo_entidade_id) then
                            select custo_entidade_seq.nextval
                            into ln_custo_entidade_id_novo
                            from dual;
                            
                            insert into custo_entidade ( id, tipo_entidade, entidade_id, custo_receita_id, titulo,
                                                         tipo_despesa_id, forma_aquisicao_id, unidade, motivo )
                            select ln_custo_entidade_id_novo, rec_tipo_entidade.tipo_entidade, ln_id, custo_receita_id, titulo,
                                   tipo_despesa_id, forma_aquisicao_id, unidade, motivo
                            from custo_entidade
                            where id = rec_lancamento.custo_entidade_id;
                            
                            ln_custo_entidade_id := ln_custo_entidade_id_novo;

                            if rec_tipo_entidade.tipo_entidade = 'P' then
                              ln_tipo_lanc_dest := 1;
                            elsif rec_tipo_entidade.tipo_entidade = 'R'  then
                              ln_tipo_lanc_dest := 2;
                            end if;
                            
                         else
                             ln_custo_entidade_id := rec_lancamento.custo_entidade_id;
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
                               
                               lv_insert_valor := ' insert into custo_lancamento ( id, custo_entidade_id, tipo, '||
                                                  '                                situacao, data, valor_unitario, '||
                                                  '                                quantidade, valor, usuario_id, '||
                                                  '                                data_alteracao, tipo_lancamento_id ) '||
                                                  ' values ( '||ln_custo_lancamento_id_novo||', '||ln_custo_entidade_id||','''||
                                                             lv_tipo_lanc ||''','''||rec_lancamento.situacao||''','||
                                                             ' to_date('''||to_char(rec_lancamento.data, const_formato_data)||''','''||const_formato_data||'''),'||
                                                             to_char(rec_lancamento.valor_unitario, 'fm99999999999999999990D9999999999',const_nls_numero_update)||','||
                                                             to_char(rec_lancamento.quantidade, 'fm99999999999999999990D9999999999',const_nls_numero_update)||','||
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
                   end loop;
                end if;
             elsif c.coluna is null then
                raise_application_error(-20001,'Nao foi possivel fazer a copia.');
             else
                if lv_valor_origem is null then
                   lv_valor_atualizar := ' null ';
                elsif c.tipo_valor in ('numero', 'entidade', 'horas', 'lancamento') then
                   lv_valor_atualizar := ' pck_regras.f_get_numero('''''|| lv_valor_origem ||''''','''''|| const_formato_numero || ''''','''''|| const_nls_numero_sql || ''''') ';
                elsif c.tipo_valor in ('string') then
                   lv_valor_atualizar := ' '''''|| lv_valor_origem ||''''' ';
                elsif c.tipo_valor in ('data') then
                   lv_valor_atualizar := ' pck_regras.f_get_data('''''|| lv_valor_origem ||''''','''''|| const_formato_data || ''''') ';
                end if;
               
                if pb_append then
                   if c.tipo_valor = 'string' then
                      lv_sql := ' begin '||
                                ' update ' || lv_nome_tabela ||
                                '        ' || c.coluna || ' = ' ||c.coluna || '||' || lv_valor_atualizar ||
                                ' where '|| rec_tipo_entidade.coluna_pk ||' in (' ||lv_sql_destino || '); '||
                                ' end; ';
                   else
                      raise_application_error(-20001, 'Tipo de propriedade nao permitida para concatenacao(append)');
                   end if;
                   lv_sql := ' begin '||
                             ' update ' || lv_nome_tabela ||
                             '        ' || c.coluna || ' = ' || lv_valor_atualizar ||
                             ' where '|| rec_tipo_entidade.coluna_pk ||' in (' ||lv_sql_destino || '); '||
                             ' end; ';
                end if;
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
    la_ids_invalidos t_ids;
        
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
          la_ind := la_ind + 1;
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
             dbms_output.put_line('acao:' || a.id);            
             select * into rec_demanda from demanda where demanda_id = pn_demanda_id;
           
             lv_texto_acao := f_monta_texto_acao(a);
             
             if pn_somente_testar = 1 or regra_relevante_permite(a.id, la_ids_invalidos) = -1 then 
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
             dbms_output.put_line('acao:' || a.id); 
             select * into rec_demanda from demanda where demanda_id = pn_demanda_id;

             lv_texto_acao := f_monta_texto_acao(a);
             if pn_somente_testar = 1 or regra_relevante_permite(a.id, la_ids_invalidos) = -1 then 
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
             dbms_output.put_line('acao:' || a.id);            
             select * into rec_demanda from demanda where demanda_id = pn_demanda_id;
           
             lv_texto_acao := f_monta_texto_acao(a);
             if pn_somente_testar = 1 or regra_relevante_permite(a.id, la_ids_invalidos) = -1 then 
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
      
      if pn_usuario_autorizador = 1 then
        --Se a transição foi forçada por um usuário autorizador.
        for a in (select * from acao_condicional ac where ac.transicao_id = pn_transicao_id and ac.tipo_validacao = 4 order by ordem asc) loop
        
             dbms_output.put_line('acao:' || a.id);            
             select * into rec_demanda from demanda where demanda_id = pn_demanda_id;
           
             lv_texto_acao := f_monta_texto_acao(a);
             if pn_somente_testar = 1 or regra_relevante_permite(a.id, la_ids_invalidos) = -1 then 
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
        end if;
      else
         pn_return := 0;
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
     
    function regra_relevante_permite(pn_acao_id number, la_ids_invalidos t_ids) return number is
    ln_ret number;
    ln_value_hash varchar(50);
    begin
        ln_ret := 1;
        
        for r_relevantes_ in (select * from regras_relevantes_acao where acao_id = pn_acao_id) loop
            for la_ind in 1..la_ids_invalidos.count loop
                if (la_ids_invalidos(la_ind) = r_relevantes_.regra_relevante) then
                   ln_ret := -1;              
                end if;
            end loop;       
        end loop;
       
        return ln_ret;
    end;
     
end pck_regras;
/


-------------------------------------------------------------------------------
-- Finalização
-------------------------------------------------------------------------------

insert into versao(id, titulo, patch, versao_tgp_id, comentario)
       values (versao_seq.nextval, '6.0.0', '10', 3, 'Aplicação de patch');
commit;
/

begin
  pck_processo.precompila;
  commit;
end;
/
                      
select * from v_versao;
/
