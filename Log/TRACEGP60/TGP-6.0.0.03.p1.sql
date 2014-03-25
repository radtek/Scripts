/******************************************************************************\
* TraceGP 6.0.0.03                                                             *
\******************************************************************************/
define CS_TBL_DAT = &TABLESPACE_DADOS;
define CS_TBL_IND = &TABLESPACE_INDICES;

alter table projeto_formulario drop constraint PROJETO_FORMULARIO_PROJET_FK1;

alter table projeto_formulario add constraint FK_PROJETO_FORMULARIO_PROJ_01
  foreign key (projeto_id) references projeto(id) on delete cascade;
  
drop trigger TRIG_RESPONSAVELENTIDADE;

insert into tela (telaid, nome, url, visivel, grupoid, ordem, codigo, subgrupo, atalho)
values((select max(telaid)+1 from tela),'bd.tela.propriedades','Propriedade.do?command=defaultAction', 
       'S', 7,  52,'PROPRIEDADE', 'PRIMEIRO', 'N' );

insert into tela (telaid, nome, url, visivel, grupoid, ordem, codigo, subgrupo, atalho)
values((select max(telaid)+1 from tela),'label.prompt.regraValidacao','RegraValidacao.do?command=defaultAction', 
       'S', 7,  53,'REGRA_VALIDACAO', 'PRIMEIRO', 'N' );
commit;
/

create or replace view v_objetivos_indicadores_resumo as
select mi.id id, 'I' TIPO, indicador_template ,mi.entidade_id ENTIDADE_ID, mi.tipo_entidade TIPO_ENTIDADE,
       mi.objetivo_pai OBJETIVO_PAI, mi.titulo TITULO, mi.validade VALIDADE,
       mia.data_apuracao DATA_APURACAO, mia.data_atualizacao DATA_ATUALIZACAO,
       mia.situacao ESTADO, mm.comentario COMENTARIO, mm.valor VALOR_META,
       mi.unidade UNIDADE, mia.escore ESCORE, mia.escore - mm.valor DIFERENCA,
       decode(mm.valor, 0, to_number(null), (mia.escore - mm.valor) / mm.valor) DIF_PERC,
       decode(mm.valor, 0, to_number(null), mia.escore / mm.valor) PERC_META_ATING,
       mmf.cor COR, mi.descricao DESCRICAO, mi.responsavel RESPONSAVEL_ID
  from mapa_indicador          mi,
       mapa_indicador_apuracao mia,
       mapa_meta               mm,
       mapa_meta_faixa         mmf
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
union all
select mo.id id, 'O' TIPO,'N' indicador_template, mo.entidade_id ENTIDADE_ID, mo.tipo_entidade TIPO_ENTIDADE,
       mo.objetivo_pai OBJETIVO_PAI, mo.titulo TITULO, mo.validade VALIDADE,
       moa.data_apuracao DATA_APURACAO, moa.data_atualizacao DATA_ATUALIZACAO,
       moa.situacao ESTADO, mom.comentario COMENTARIO, mom.valor VALOR_META,
       mo.unidade UNIDADE, moa.escore ESCORE, moa.escore - mom.valor DIFERENCA,
       decode(mom.valor, 0, to_number(null), (moa.escore - mom.valor) / mom.valor) DIF_PERC,
       decode(mom.valor, 0, to_number(null), moa.escore / mom.valor) PERC_META_ATING,
       mof.cor COR, mo.descricao DESCRICAO, mo.responsavel
  from mapa_objetivo           mo,
       mapa_objetivo_apuracao  moa,
       mapa_objetivo_meta      mom,
       mapa_objetivo_faixa     mof
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
                                         where mof3.objetivo_id = mom.objetivo_id))));
/

declare 
  ln_conta number;
begin
  ln_conta := 1;
  while ln_conta > 0 loop
    for tab in (select table_name
                  from user_tables 
                 where table_name like 'REGRAS_%') loop
     begin
       execute immediate 'drop table ' || tab.table_name;
     exception
       when others then
         null;
     end;
    end loop;
     
    select count(1) 
      into ln_conta
      from user_tables 
     where table_name like 'REGRAS_%';
     
  end loop;
end;
/

insert into tela (telaid,nome,url,visivel,grupoid,ordem,codigo,subgrupo,atalho)
values ((select max(telaid) + 1 from tela),'bd.tela.tiposLancamento',null,'S',7,
       null,'TIPOS_LANCAMENTO',null,'N');
commit;
/
-------------CRIACAO  DA TABELA TIPO_LANCAMENTO -------------------------------------------------------------------------------------------------
CREATE TABLE TIPO_LANCAMENTO ( 
  ID        NUMBER(10)     NOT NULL,
  TITULO    VARCHAR2(255),
  DESCRICAO VARCHAR2(4000),
  VIGENTE   VARCHAR2(1)    NOT NULL,
constraint PK_TIPO_LANCAMENTO primary key (id) using index tablespace &CS_TBL_IND,
constraint CHK_TIPO_LANCAMENTO_01 check (VIGENTE in ('Y', 'N'))
)tablespace &CS_TBL_DAT;

CREATE SEQUENCE TIPO_LANCAMENTO_SEQ  START WITH 1 INCREMENT BY 1 NOCACHE;

COMMENT ON TABLE  TIPO_LANCAMENTO IS 'Cadastro de Tipos de Lançamento';
COMMENT ON COLUMN TIPO_LANCAMENTO.ID IS 'Id do Tipo de Lançamento (PK)';
COMMENT ON COLUMN TIPO_LANCAMENTO.TITULO IS 'Nome do Tipo de Lançamento';
COMMENT ON COLUMN TIPO_LANCAMENTO.DESCRICAO IS 'Descrição do Tipo de Lançamento';
COMMENT ON COLUMN TIPO_LANCAMENTO.VIGENTE IS 'Determina a vigência do Tipo de Lançamento';

insert into tipo_lancamento (ID, TITULO, DESCRICAO, VIGENTE) values (1,'Planejado','Planejado','Y'); 
insert into tipo_lancamento (ID, TITULO, DESCRICAO, VIGENTE) values (2,'Realizado','Realizado','Y');

commit;
/

-------------CRIACAO DA TABELA TIPOENTIDADE_LANCAMENTO---------------------------------------------------------------------------------------
CREATE TABLE ATRIBUTOENTIDADE_LANCAMENTO ( 
  ID                 NUMBER(10) NOT NULL,
  ATRIBUTOID         NUMBER(10) NOT NULL ENABLE,
  TIPOENTIDADE       VARCHAR2(1 BYTE),
  TIPO_LANCAMENTO_ID NUMBER(10) NOT NULL,
  IDENTIDADE         NUMBER(10), 
  OBRIGATORIO        VARCHAR2(1) NULL,
  VISIVEL            VARCHAR2(1) NULL, 
  ORDEM              NUMBER(10),
  TAMANHO_CAMPO      VARCHAR2(1),
constraint PK_TIPOENTIDADE_LANCAMENTO primary key (id) using index tablespace &CS_TBL_IND,
constraint CHK_TIPOENTIDADE_LANCAMENTO_01 check (OBRIGATORIO in ('Y', 'N'))
)tablespace &CS_TBL_DAT;

ALTER TABLE ATRIBUTOENTIDADE_LANCAMENTO ADD CONSTRAINT FK_TIPOENTIDADE_LANCAMENTO_01 
  FOREIGN KEY (TIPO_LANCAMENTO_ID) REFERENCES TIPO_LANCAMENTO (ID);

COMMENT ON table  ATRIBUTOENTIDADE_LANCAMENTO IS 'Tabela de Relacionamento do Atributo Entidade com os Tipos de Lançamentos';
COMMENT ON COLUMN ATRIBUTOENTIDADE_LANCAMENTO.ID IS 'Id (PK)';
COMMENT ON COLUMN ATRIBUTOENTIDADE_LANCAMENTO.ATRIBUTOID IS 'Id do Atributo';
COMMENT ON COLUMN ATRIBUTOENTIDADE_LANCAMENTO.TIPOENTIDADE IS 'Tipo de Entidade (C)';
COMMENT ON COLUMN ATRIBUTOENTIDADE_LANCAMENTO.TIPO_LANCAMENTO_ID IS 'Id do Tipo de Lançamento';
COMMENT ON COLUMN ATRIBUTOENTIDADE_LANCAMENTO.OBRIGATORIO IS 'Obrigatoriedade do atributo (Y ou N';
COMMENT ON COLUMN ATRIBUTOENTIDADE_LANCAMENTO.ORDEM IS 'Ordem do atributo';
COMMENT ON COLUMN ATRIBUTOENTIDADE_LANCAMENTO.IDENTIDADE IS 'Id da Entidade (se for nulo é configuração do Tipo de Lançamento)';
COMMENT ON COLUMN ATRIBUTOENTIDADE_LANCAMENTO.VISIVEL IS 'Visibilidade do atributo';

CREATE SEQUENCE ATRENTIDADE_LANCAMENTO_SEQ  START WITH 1 INCREMENT BY 1 NOCACHE;

-------------------- CRIACAO DA TABELA DE ATRIBUTO ENTIDADE VALOR PADRAO --------------------------------------------------------------
CREATE TABLE ATRIBUTOENTIDADE_VALORPADRAO (
    ID                 NUMBER(10) NOT NULL,
    ATRIBUTOID         NUMBER(10),
    TIPOENTIDADE       VARCHAR2(1 BYTE),
    TIPO_LANCAMENTO_ID NUMBER(10) NULL,
    IDENTIDADE         NUMBER(10),   
    VALOR              VARCHAR2(2000 BYTE),
    VALORDATA           DATE,
    VALORNUMERICO       NUMBER(21,2),
    DOMINIO_ATRIBUTO_ID NUMBER(10),
    VALOR_HTML          CLOB,
    CATEGORIA_ITEM_ATRIBUTO_ID NUMBER(10)
  )tablespace &CS_TBL_DAT;
  
 ALTER TABLE ATRIBUTOENTIDADE_VALORPADRAO ADD CONSTRAINT PK_ATR_ENTIDADE_VALORPADRAO
  PRIMARY KEY (ID); 

ALTER TABLE ATRIBUTOENTIDADE_VALORPADRAO ADD CONSTRAINT FK_ATR_ENTIDADE_VALORPADRAO_01 
  FOREIGN KEY (CATEGORIA_ITEM_ATRIBUTO_ID) REFERENCES CATEGORIA_ITEM_ATRIBUTO (CATEGORIA_ITEM_ID);

CREATE SEQUENCE ATR_ENTIDADE_VALORPADRAO_SEQ  START WITH 1 INCREMENT BY 1 NOCACHE;

-------------CRIACAO  DA TABELA TIPO_LANCAMENTO_ENTIDADE ------------------------------------------------------------------------------------------
CREATE TABLE TIPO_LANCAMENTO_ENTIDADE ( 
  ID NUMBER(10) NOT NULL,
  IDENTIDADE NUMBER(10) NOT NULL,
  TIPO_LANCAMENTO_ID NUMBER(10) NOT NULL,
  TIPOENTIDADE  VARCHAR2(1 BYTE),
  VISIVEL VARCHAR2(1) NULL,
  ORDEM NUMBER(10)
)tablespace &CS_TBL_DAT;

ALTER TABLE TIPO_LANCAMENTO_ENTIDADE ADD CONSTRAINT PK_TIPO_LANCAMENTO_ENTIDADE
  PRIMARY KEY (ID);  

ALTER TABLE TIPO_LANCAMENTO_ENTIDADE ADD CONSTRAINT FK_TIPO_LANCAMENTO_ENTIDADE_01 
  FOREIGN KEY (TIPO_LANCAMENTO_ID) REFERENCES TIPO_LANCAMENTO (ID);  

CREATE SEQUENCE TIPO_LANCAMENTO_ENTIDADE_SEQ  START WITH 1 INCREMENT BY 1 NOCACHE;

COMMENT ON TABLE TIPO_LANCAMENTO_ENTIDADE IS 'Tabela de Associação do Tipo de Lançamento com Entidade';
COMMENT ON COLUMN TIPO_LANCAMENTO_ENTIDADE.TIPO_LANCAMENTO_ID IS 'Id do Tipo de Lançamento (PK)';
COMMENT ON COLUMN TIPO_LANCAMENTO_ENTIDADE.IDENTIDADE IS 'Id da Entidade (Projeto, Demanda,etc...)';
COMMENT ON COLUMN TIPO_LANCAMENTO_ENTIDADE.ORDEM IS 'Ordem do tipo de lançamento no projeto';

-------------CRIACAO  DA TABELA REGRA_TIPO_LANC_FORMULARIO ------------------------------------------------------------------------------------------
CREATE TABLE REGRA_TIPO_LANC_FORMULARIO ( 
  ID NUMBER(10)         NOT NULL,
  TIPO_LANC_ENTIDADE_ID NUMBER(10) NOT NULL,
  REGRA_ID              NUMBER(10) NOT NULL,
  FORMULARIO_ID         NUMBER(10) NOT NULL,
  TIPO_PERMISSAO        VARCHAR2(1),
  constraint UK_REGRA_TIPO_LANC_FORMULARIO UNIQUE (TIPO_LANC_ENTIDADE_ID, REGRA_ID, TIPO_PERMISSAO),
  constraint CHK_REGRA_TIPO_LANC_FORM_01 CHECK (TIPO_PERMISSAO  IN ('I', 'V', 'E')) ENABLE
)tablespace &CS_TBL_DAT;

ALTER TABLE REGRA_TIPO_LANC_FORMULARIO ADD CONSTRAINT PK_REGRA_TIPO_LANC_FORMULARIO
	PRIMARY KEY (ID);  

ALTER TABLE REGRA_TIPO_LANC_FORMULARIO ADD CONSTRAINT FK_REGRA_TP_LANC_FORMULARIO_01 
	FOREIGN KEY (TIPO_LANC_ENTIDADE_ID) REFERENCES TIPO_LANCAMENTO_ENTIDADE (ID);  

ALTER TABLE REGRA_TIPO_LANC_FORMULARIO ADD CONSTRAINT FK_REGRA_TP_LANC_FORMULARIO_02 
	FOREIGN KEY (FORMULARIO_ID,REGRA_ID) REFERENCES REGRA_FORMULARIO (FORMULARIO_ID,REGRA_ID);

CREATE SEQUENCE REGRA_TIPO_LANC_FORMULARIO_SEQ  START WITH 1 INCREMENT BY 1 NOCACHE;

COMMENT ON TABLE REGRA_TIPO_LANC_FORMULARIO IS 'Tabela de Associação do Tipo de Lançamento com Entidade';
COMMENT ON COLUMN REGRA_TIPO_LANC_FORMULARIO.TIPO_LANC_ENTIDADE_ID IS 'Id do Tipo de Lançamento Entidade';
COMMENT ON COLUMN REGRA_TIPO_LANC_FORMULARIO.REGRA_ID IS 'Id da regra';
COMMENT ON COLUMN REGRA_TIPO_LANC_FORMULARIO.FORMULARIO_ID IS 'Id do Formulario';
COMMENT ON COLUMN REGRA_TIPO_LANC_FORMULARIO.TIPO_PERMISSAO IS 'Tipo de Permissao (I,V,E)';
insert into tela (telaid,nome,url,visivel,grupoid,ordem,codigo,subgrupo,atalho)
values ((select max(telaid) + 1 from tela),'bd.tela.tela475','ConfiguracaoProjetoCustos.do?command=defaultAction',
       'S',16,4,'VISUALIZACAO_CUSTOS','SEGUNDO','N');
commit;
/
-------------CRIACAO  DA FORMULARIO_CUSTO ------------------------------------------------------------------------------------------
CREATE TABLE FORMULARIO_CUSTO ( 
  ID NUMBER(10) NOT NULL,
  FORMULARIO_ID NUMBER(10) NOT NULL,
  TIPO_DATA_INI VARCHAR2(1 BYTE) NULL,
  DATA_INICIO DATE,
  NUM_DIAS_INI NUMERIC(5) NULL,
  FREQUENCIA_INI VARCHAR2(1 BYTE) NULL,
  ACAO_INI VARCHAR2(1 BYTE) NULL,
  TIPO_DATA_FIM VARCHAR2(1 BYTE) NULL,
  DATA_FIM DATE,
  NUM_DIAS_FIM NUMERIC(5) NULL,
  FREQUENCIA_FIM VARCHAR2(1 BYTE) NULL,
  ACAO_FIM VARCHAR2(1 BYTE) NULL
);

ALTER TABLE FORMULARIO_CUSTO ADD CONSTRAINT PK_FORMULARIO_CUSTO
	PRIMARY KEY (ID);  

ALTER TABLE FORMULARIO_CUSTO ADD CONSTRAINT FK_FORMULARIO_CUSTO_01 
	FOREIGN KEY (FORMULARIO_ID) REFERENCES FORMULARIO (FORMULARIO_ID); 
  

COMMENT ON TABLE FORMULARIO_CUSTO IS 'Tabela de Custos do Formulario';
COMMENT ON COLUMN FORMULARIO_CUSTO.ID IS 'Identificador';
COMMENT ON COLUMN FORMULARIO_CUSTO.FORMULARIO_ID IS 'Id do Formulario';
COMMENT ON COLUMN FORMULARIO_CUSTO.DATA_INICIO IS 'Data de Início';
COMMENT ON COLUMN FORMULARIO_CUSTO.DATA_FIM IS 'Data Final';
COMMENT ON COLUMN FORMULARIO_CUSTO.TIPO_DATA_INI IS 'Tipo de Data (N,D) Número de dias ou por data especifica';
COMMENT ON COLUMN FORMULARIO_CUSTO.NUM_DIAS_INI IS 'Número de dias da data de criação da demanda';
COMMENT ON COLUMN FORMULARIO_CUSTO.FREQUENCIA_INI IS 'Tipo de frquencia (D - dias, S - semanas)';
COMMENT ON COLUMN FORMULARIO_CUSTO.ACAO_INI IS 'Tipo de Açao P - Posterior ou A - Anterior a data de criação da demanda';
COMMENT ON COLUMN FORMULARIO_CUSTO.TIPO_DATA_FIM IS 'Tipo de Data (N,D) Número de dias ou por data especifica';
COMMENT ON COLUMN FORMULARIO_CUSTO.NUM_DIAS_FIM IS 'Número de dias da data de criação da demanda';
COMMENT ON COLUMN FORMULARIO_CUSTO.FREQUENCIA_FIM IS 'Tipo de frquencia (D - dias, S - semanas)';
COMMENT ON COLUMN FORMULARIO_CUSTO.ACAO_FIM IS 'Tipo de Açao P - Posterior ou A - Anterior a data de criação da demanda';


------------- Tabela de Valores Padrão do Atributo Entidade custo -----------------------------------------------  
CREATE TABLE ATRIBUTOENTIDADE_CUSTO ( 
  ID NUMBER(10) NOT NULL,
  ATRIBUTOID NUMBER(10) NOT NULL ENABLE,
  TIPOENTIDADE       VARCHAR2(1 BYTE),
  IDENTIDADE NUMBER(10), 
  VISIVEL VARCHAR2(1) NULL, 
  ORDEM NUMBER(10),
  TAMANHO_CAMPO VARCHAR2(1)
)tablespace &CS_TBL_DAT;

ALTER TABLE ATRIBUTOENTIDADE_CUSTO ADD CONSTRAINT PK_ATRIBUTOENTIDADE_CUSTO
	PRIMARY KEY (ID);

COMMENT ON TABLE ATRIBUTOENTIDADE_CUSTO IS 'Tabela de Valores Padrão do Atributo Entidade Custo';
COMMENT ON COLUMN ATRIBUTOENTIDADE_CUSTO.ID IS 'Id (PK)';
COMMENT ON COLUMN ATRIBUTOENTIDADE_CUSTO.ATRIBUTOID IS 'Id do Atributo';
COMMENT ON COLUMN ATRIBUTOENTIDADE_CUSTO.TIPOENTIDADE IS 'Tipo de Entidade (C)';
COMMENT ON COLUMN ATRIBUTOENTIDADE_CUSTO.ORDEM IS 'Ordem do atributo';
COMMENT ON COLUMN ATRIBUTOENTIDADE_CUSTO.IDENTIDADE IS 'Id da Entidade (se for nulo é configuração do Tipo de Lançamento)';
COMMENT ON COLUMN ATRIBUTOENTIDADE_CUSTO.VISIVEL IS 'Visibilidade do atributo';


CREATE SEQUENCE ATRIBUTOENTIDADE_CUSTO_SEQ  START WITH 1 INCREMENT BY 1 NOCACHE;
 
-------------CRIACAO DA TABELA TIPO_LANCAMENTO_PAPEL ---------------------------------------------------------------------------------------
CREATE TABLE TIPO_LANCAMENTO_PAPEL ( 
  ID NUMBER(10) NOT NULL,
  TIPO_LANCAMENTO_ID NUMBER(10) NOT NULL,
  PAPEL_ID NUMBER(10) NOT NULL,
  TIPOENTIDADE  VARCHAR2(1 BYTE) NOT NULL,
  INCLUSAO VARCHAR2(1) NULL,
  VISUALIZACAO VARCHAR2(1) NULL,
  ESTORNO VARCHAR2(1) NULL,
constraint PK_TIPO_LANCAMENTO_PAPEL primary key (id) using index tablespace &CS_TBL_IND,
constraint CHK_TIPO_LANCAMENTO_PAPEL_01 check (INCLUSAO in ('Y', 'N')),
constraint CHK_TIPO_LANCAMENTO_PAPEL_02 check (VISUALIZACAO in ('Y', 'N')),
constraint CHK_TIPO_LANCAMENTO_PAPEL_03 check (ESTORNO in ('Y', 'N')),
constraint UK_TIPO_LANCAMENTO_PAPEL UNIQUE (TIPO_LANCAMENTO_ID, PAPEL_ID, TIPOENTIDADE)
)tablespace &CS_TBL_DAT;

ALTER TABLE TIPO_LANCAMENTO_PAPEL ADD CONSTRAINT FK_TIPO_LANCAMENTO_PAPEL_01 
	FOREIGN KEY (TIPO_LANCAMENTO_ID) REFERENCES TIPO_LANCAMENTO (ID);

ALTER TABLE TIPO_LANCAMENTO_PAPEL ADD CONSTRAINT FK_TIPO_LANCAMENTO_PAPEL_02 
	FOREIGN KEY (PAPEL_ID) REFERENCES PAPELPROJETO (PAPELPROJETOID);


COMMENT ON TABLE TIPO_LANCAMENTO_PAPEL IS 'Tabela de Permissão de Tipos de Lançamentos por Papel';
COMMENT ON COLUMN TIPO_LANCAMENTO_PAPEL.ID IS 'Id (PK)';
COMMENT ON COLUMN TIPO_LANCAMENTO_PAPEL.PAPEL_ID IS 'Id do Papel do Projeto';
COMMENT ON COLUMN TIPO_LANCAMENTO_PAPEL.TIPO_LANCAMENTO_ID IS 'Id do Tipo de Lançamento';
COMMENT ON COLUMN TIPO_LANCAMENTO_PAPEL.INCLUSAO IS 'Permissão de Inclusão e Edição';
COMMENT ON COLUMN TIPO_LANCAMENTO_PAPEL.VISUALIZACAO IS 'Permissão de Visualização';
COMMENT ON COLUMN TIPO_LANCAMENTO_PAPEL.ESTORNO IS 'Permissão de Estorno';

CREATE SEQUENCE TIPO_LANCAMENTO_PAPEL_SEQ  START WITH 1 INCREMENT BY 1 NOCACHE;

-------------CRIACAO DA TABELA TIPO_LANCAMENTO_PERFIL ---------------------------------------------------------------------------------------
CREATE TABLE TIPO_LANCAMENTO_PERFIL ( 
  ID NUMBER(10) NOT NULL,
  TIPO_LANCAMENTO_ID NUMBER(10) NOT NULL,
  PERFILID NUMBER(10) NOT NULL,
  TIPOENTIDADE  VARCHAR2(1 BYTE) NOT NULL,
  INCLUSAO VARCHAR2(1) NULL,
  VISUALIZACAO VARCHAR2(1) NULL,
  ESTORNO VARCHAR2(1) NULL,
  constraint CHK_TIPO_LANCAMENTO_PERFIL_01 check (INCLUSAO in ('Y', 'N')),
  constraint CHK_TIPO_LANCAMENTO_PERFIL_02 check (VISUALIZACAO in ('Y', 'N')),
  constraint CHK_TIPO_LANCAMENTO_PERFIL_03 check (ESTORNO in ('Y', 'N')),
  constraint UNQ_TIPO_LANCAMENTO_PERFIL UNIQUE (TIPO_LANCAMENTO_ID, PERFILID, TIPOENTIDADE)
)tablespace &CS_TBL_DAT;


ALTER TABLE TIPO_LANCAMENTO_PERFIL ADD CONSTRAINT PK_TIPO_LANCAMENTO_PERFIL
	PRIMARY KEY (ID);

ALTER TABLE TIPO_LANCAMENTO_PERFIL ADD CONSTRAINT FK_TIPO_LANCAMENTO_PERFIL_01 
	FOREIGN KEY (TIPO_LANCAMENTO_ID) REFERENCES TIPO_LANCAMENTO (ID);

ALTER TABLE TIPO_LANCAMENTO_PERFIL ADD CONSTRAINT FK_TIPO_LANCAMENTO_PERFIL_02 
	FOREIGN KEY (PERFILID) REFERENCES PERFIL (PERFILID);


COMMENT ON TABLE TIPO_LANCAMENTO_PERFIL IS 'Tabela de Permissão de Tipos de Lançamentos por Perfil';
COMMENT ON COLUMN TIPO_LANCAMENTO_PERFIL.ID IS 'Id (PK)';
COMMENT ON COLUMN TIPO_LANCAMENTO_PERFIL.TIPO_LANCAMENTO_ID IS 'Id do Tipo de Lançamento';
COMMENT ON COLUMN TIPO_LANCAMENTO_PERFIL.TIPOENTIDADE  IS 'Tipo de Entidade';
COMMENT ON COLUMN TIPO_LANCAMENTO_PERFIL.INCLUSAO IS 'Permissão de Inclusão e Edição';
COMMENT ON COLUMN TIPO_LANCAMENTO_PERFIL.VISUALIZACAO IS 'Permissão de Visualização';
COMMENT ON COLUMN TIPO_LANCAMENTO_PERFIL.ESTORNO IS 'Permissão de Estorno';


CREATE SEQUENCE TIPO_LANCAMENTO_PERFIL_SEQ  START WITH 1 INCREMENT BY 1 NOCACHE;

-------------------------------------------------------------------------------
-- Create table

create table REGRAS_VALIDACAO
(
  ID               NUMBER(10) not null,
  TITULO           VARCHAR2(100) not null,
  VIGENTE          VARCHAR2(1) default 'Y' not null,
  OPERADOR_LIGACAO VARCHAR2(1) default 'E' not null,
  DESCRICAO        VARCHAR2(4000)
)tablespace &CS_TBL_DAT;
-- Add comments to the columns 
comment on column REGRAS_VALIDACAO.OPERADOR_LIGACAO
  is 'E, Ou, Xor';
comment on column REGRAS_VALIDACAO.DESCRICAO
  is 'Descricao da regra';
-- Create/Recreate primary, unique and foreign key constraints 
alter table REGRAS_VALIDACAO
  add constraint PK_REGRAS_VALIDACAO primary key (ID)
  using index 
  tablespace &CS_TBL_IND;
-- Create/Recreate check constraints 
alter table REGRAS_VALIDACAO
  add constraint CHK_REGRAS_VALIDACAO_01
  check (operador_ligacao in ('O','E','X'));
alter table REGRAS_VALIDACAO
  add constraint CHK_REGRAS_VALIDACAO_02
  check (vigente in ('Y','N'));


-- Create table
create table REGRAS_VALIDACAO_ITEM
(
  ID               NUMBER(10) not null,
  VALIDACAO_ID     NUMBER(10) not null,
  TIPO             VARCHAR2(1) default 'T' not null,
  REF_VALIDACAO_ID NUMBER(10),
  TIPO_FUNCAO_ID_1 NUMBER(10),
  TIPO_FUNCAO_ID_2 NUMBER(10),
  PROPRIEDADE_ID_1 NUMBER(10),
  PROPRIEDADE_ID_2 NUMBER(10),
  TIPO_OPERADOR_ID NUMBER(10),
  VALOR_1          VARCHAR2(4000),
  VALOR_2          VARCHAR2(4000),
  ORDEM            NUMBER(3) not null,
  TIPO_VALOR_ID_1  NUMBER(10) default 1,
  TIPO_VALOR_ID_2  NUMBER(10) default 1,
  TIPO_OPERANDO_1  VARCHAR2(1),
  TIPO_OPERANDO_2  VARCHAR2(1)
)tablespace &CS_TBL_DAT;
-- Add comments to the columns 
comment on column REGRAS_VALIDACAO_ITEM.TIPO
  is 'outra Validacao, novo Teste';
comment on column REGRAS_VALIDACAO_ITEM.REF_VALIDACAO_ID
  is 'Validacao referenciada quando o tipo for outra validacao';
comment on column REGRAS_VALIDACAO_ITEM.TIPO_FUNCAO_ID_1
  is 'Funcao do lado esquerdo da operacao, devem ser buscadas as propriedade na tabela regras_valid_funcao_item';
comment on column REGRAS_VALIDACAO_ITEM.TIPO_FUNCAO_ID_2
  is 'Funcao do lado direito da operacao, devem ser buscadas as propriedade na tabela regras_valid_funcao_item';
comment on column REGRAS_VALIDACAO_ITEM.PROPRIEDADE_ID_1
  is 'Propriedade da esquerda da operacao';
comment on column REGRAS_VALIDACAO_ITEM.PROPRIEDADE_ID_2
  is 'Propriedade da direita da operacao';
comment on column REGRAS_VALIDACAO_ITEM.ORDEM
  is 'Ordem de execucao';
-- Create/Recreate primary, unique and foreign key constraints 
alter table REGRAS_VALIDACAO_ITEM
  add constraint PK_REGRAS_VALIDACAO_ITEM primary key (ID)
  using index 
  tablespace &CS_TBL_IND;
alter table REGRAS_VALIDACAO_ITEM
  add constraint UK_REGRAS_VALIDACAO_ITEM_01 unique (VALIDACAO_ID, ORDEM)
  using index 
  tablespace &CS_TBL_IND;

-- Create table
create table REGRAS_VALID_FUNCAO_ITEM
(
  ID                   NUMBER(10) not null,
  ORDEM                NUMBER(2) not null,
  VALIDACAO_ITEM_ID    NUMBER(10),
  VALOR                VARCHAR2(4000),
  PROPRIEDADE_ID       NUMBER(10),
  VAL_1_2              NUMBER(1) default 1 not null,
  VALID_FUNCAO_ITEM_ID NUMBER(10),
  TIPO_FUNCAO_ID       NUMBER(10),
  TIPO_VALOR_ID        NUMBER(10),
  TIPO_OPERANDO        VARCHAR2(1)
)tablespace &CS_TBL_DAT;
-- Add comments to the columns 
comment on column REGRAS_VALID_FUNCAO_ITEM.VALIDACAO_ITEM_ID
  is 'o pai e um item de uma validacao';
comment on column REGRAS_VALID_FUNCAO_ITEM.VAL_1_2
  is 'Indica se sao os parametros do valor a esquerda (1) ou a direita (2)';
comment on column REGRAS_VALID_FUNCAO_ITEM.VALID_FUNCAO_ITEM_ID
  is 'Usado para funcoes dentro de funcoes';
-- Create/Recreate primary, unique and foreign key constraints 
alter table REGRAS_VALID_FUNCAO_ITEM
  add constraint PK_REGRAS_VALID_FUNCAO_ITEM primary key (ID)
  using index tablespace &CS_TBL_IND;
alter table REGRAS_VALID_FUNCAO_ITEM
  add constraint UK_REGRAS_VALID_FUNCAO_ITEM_01 unique (VALIDACAO_ITEM_ID, ORDEM)
  using index tablespace &CS_TBL_IND;

-- Create/Recreate check constraints 
alter table REGRAS_VALID_FUNCAO_ITEM
  add constraint CHK_REGRAS_VALID_FUNCAO_IT_01
  check (valor is not null or propriedade_id is not null);
alter table REGRAS_VALID_FUNCAO_ITEM
  add constraint CHK_REGRAS_VALID_FUNCAO_IT_02
  check (val_1_2 in (1,2));
  
------------------------------------------------------------
ALTER TABLE CUSTO_RECEITA ADD DATA_INICIO_LANCAMENTO DATE;
ALTER TABLE CUSTO_RECEITA ADD DATA_FIM_LANCAMENTO DATE;
ALTER TABLE CUSTO_RECEITA ADD DATA_INICIO_VISUALIZACAO DATE;
ALTER TABLE CUSTO_RECEITA ADD DATA_FIM_VISUALIZACAO DATE;
ALTER TABLE CUSTO_LANCAMENTO ADD TIPO_LANCAMENTO_ID NUMBER(10) NULL;
ALTER TABLE CUSTO_LANCAMENTO DROP CONSTRAINT CHK_CUSTO_LANCAMENTO_01;
ALTER TABLE CUSTO_LANCAMENTO ADD CONSTRAINT CHK_CUSTO_LANCAMENTO_01 CHECK (tipo IN ('P', 'R', 'O'));

CREATE SEQUENCE REGRAS_VALIDACAO_SEQ  START WITH 1 INCREMENT BY 1 nocache;
CREATE SEQUENCE REGRAS_VALIDACAO_ITEM_SEQ  START WITH 1 INCREMENT BY 1 nocache;
CREATE SEQUENCE REGRAS_VALID_FUNCAO_ITEM_SEQ  START WITH 1 INCREMENT BY 1 nocache;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
CREATE TABLE REGRAS_TIPO_AGRUPADOR(	
  id       NUMBER(10)  not null, 
	CODIGO  VARCHAR2(30) NOT null, 
	TITULO  VARCHAR2(200), 
CONSTRAINT PK_REGRAS_TIPO_AGRUPADOR PRIMARY KEY (id) ,
CONSTRAINT UK_REGRAS_TIPO_AGRUPADOR UNIQUE (CODIGO)
) TABLESPACE &CS_TBL_DAT;

COMMENT ON COLUMN REGRAS_TIPO_AGRUPADOR.ID IS 'Id';
COMMENT ON COLUMN REGRAS_TIPO_AGRUPADOR.CODIGO IS 'Codigo que identifica o operador';
 
CREATE TABLE REGRAS_TIPO_ENTIDADE(
	TITULO      VARCHAR2(40)  NOT null, 
	NOME_TABELA VARCHAR2(100) DEFAULT 'DEMANDA' NOT null, 
	COLUNA_PK   VARCHAR2(50)  DEFAULT 'ID' NOT null, 
	id          NUMBER(10)    NOT NULL , 
	COLUNA_ATRIBUTO_ID        VARCHAR2(50), 
	TIPO_ENTIDADE             VARCHAR2(3), 
CONSTRAINT PK_REGRAS_TIPO_ENTIDADE PRIMARY KEY (id)
) TABLESPACE &CS_TBL_DAT;

COMMENT ON COLUMN REGRAS_TIPO_ENTIDADE.TITULO             IS 'Nome do tipo de entidade';
COMMENT ON column REGRAS_TIPO_ENTIDADE.NOME_TABELA        IS 'Nome da tabela do tipo da entidade';
COMMENT ON COLUMN REGRAS_TIPO_ENTIDADE.COLUNA_PK          IS 'Nome da coluna PK';
COMMENT ON COLUMN REGRAS_TIPO_ENTIDADE.COLUNA_ATRIBUTO_ID IS 'Nome da coluna que contem o id do atributo';
COMMENT ON COLUMN REGRAS_TIPO_ENTIDADE.TIPO_ENTIDADE       IS 'Informar o caractere que identifica o tipo de entidade no sistema Projeto Demanda Tarefa...';
 
CREATE TABLE REGRAS_TIPO_ESCOPO (
	id NUMBER(10) NOT null, 
	CODIGO VARCHAR2(50) NOT null, 
	TITULO VARCHAR2(400) NOT null, 
	TIPO_ENTIDADE_ID NUMBER(10) NOT null, 
CONSTRAINT PK_REGRAS_TIPO_ESCOPO PRIMARY KEY (id),
CONSTRAINT UK_REGRAS_TIPO_ESCOPO_01 unique (codigo)
) TABLESPACE &CS_TBL_DAT;
 
COMMENT ON COLUMN REGRAS_TIPO_ESCOPO.ID IS 'Id';
COMMENT ON COLUMN REGRAS_TIPO_ESCOPO.CODIGO IS 'Identifica o tipo de escopo';
COMMENT ON COLUMN REGRAS_TIPO_ESCOPO.TITULO IS 'Descrição do tipo de escopo';
COMMENT ON COLUMN REGRAS_TIPO_ESCOPO.TIPO_ENTIDADE_ID IS 'Tipo de entidade relacionada';

CREATE TABLE REGRAS_TIPO_FUNCAO(	
  id     NUMBER(10) NOT null, 
	CODIGO VARCHAR2(20 BYTE) NOT null, 
CONSTRAINT PK_REGRAS_TIPO_FUNCAO PRIMARY KEY (id),
CONSTRAINT UK_REGRAS_TIPO_FUNCAO UNIQUE (CODIGO)
) TABLESPACE &CS_TBL_DAT;
 

CREATE TABLE REGRAS_TIPO_OPERADOR(	
  id NUMBER(10) NOT null, 
	CODIGO VARCHAR2(30) NOT null, 
	TITULO VARCHAR2(30) DEFAULT ' ' NOT null, 
CONSTRAINT PK_REGRAS_TIPO_OPERADOR PRIMARY KEY (id),
CONSTRAINT UK_REGRAS_TIPO_OPERADOR_01 UNIQUE (CODIGO)
) TABLESPACE &CS_TBL_DAT;
 
COMMENT ON COLUMN REGRAS_TIPO_OPERADOR.ID IS 'Id';
COMMENT ON COLUMN REGRAS_TIPO_OPERADOR.CODIGO IS 'Codigo que identifica o operador';

CREATE TABLE REGRAS_TIPO_VALOR(	
  id NUMBER(10) NOT null, 
	CODIGO VARCHAR2(30) NOT null, 
	TITULO VARCHAR2(40) NOT null,
CONSTRAINT PK_REGRAS_TIPO_VALOR PRIMARY KEY (id),
CONSTRAINT UK_REGRAS_TIPO_VALOR_01 UNIQUE (CODIGO)
) TABLESPACE &CS_TBL_DAT;
 
COMMENT ON COLUMN REGRAS_TIPO_VALOR.ID IS 'Id';
COMMENT ON COLUMN REGRAS_TIPO_VALOR.CODIGO IS 'Codigo que indica o tipo';
COMMENT ON COLUMN REGRAS_TIPO_VALOR.TITULO IS 'Nome do tipo';
 
CREATE TABLE REGRAS_TIPO_PROPRIEDADE (	
  id NUMBER(10) NOT null, 
	TITULO VARCHAR2(100) NOT null, 
	COLUNA VARCHAR2(100), 
	TIPO_VALOR_ID NUMBER(10), 
	VIGENTE VARCHAR2(1) DEFAULT 'N' NOT null, 
	WHERE_JOIN VARCHAR2(4000), 
	TIPO_ENTIDADE_ID NUMBER(10) NOT null, 
	REF_TIPO_ENTIDADE_ID NUMBER(10), 
	CHAVE VARCHAR2(1) DEFAULT 'N' NOT null, 
CONSTRAINT PK_TIPO_PROPRIEDADE PRIMARY KEY (ID)
) TABLESPACE &CS_TBL_DAT;

COMMENT ON COLUMN REGRAS_TIPO_PROPRIEDADE.ID IS 'Id';
COMMENT ON COLUMN REGRAS_TIPO_PROPRIEDADE.TITULO IS 'String que identifica o elemento';
COMMENT ON COLUMN REGRAS_TIPO_PROPRIEDADE.COLUNA IS 'Nome da coluna da tabela que contem a informacao';
COMMENT ON COLUMN REGRAS_TIPO_PROPRIEDADE.TIPO_VALOR_ID IS 'Tipo da informacao';
COMMENT ON COLUMN REGRAS_TIPO_PROPRIEDADE.VIGENTE IS 'Tipo de propriedade disponivel';
COMMENT ON COLUMN REGRAS_TIPO_PROPRIEDADE.WHERE_JOIN IS 'Clausula where para relacionar a entidade pai com a entidade referenciada pela propriedade. Substituir [ENTIDADE-PAI] pela entidade que contem a propriedade e [ENTIDADE-FILHA] pela entidade referenciada';
COMMENT ON COLUMN REGRAS_TIPO_PROPRIEDADE.CHAVE IS 'Define se faz parte da pk';
 
alter table REGRAS_TIPO_PROPRIEDADE add constraint FK_TIPO_PROPRIEDADE_01 
foreign key (TIPO_VALOR_ID) references REGRAS_TIPO_VALOR(id); 
alter table REGRAS_TIPO_PROPRIEDADE add constraint FK_TIPO_PROPRIEDADE_02 
foreign key (TIPO_ENTIDADE_ID) references REGRAS_TIPO_ENTIDADE(id); 
alter table REGRAS_TIPO_PROPRIEDADE add constraint FK_TIPO_PROPRIEDADE_03 
foreign key (REF_TIPO_ENTIDADE_ID) references REGRAS_TIPO_ENTIDADE(id); 

CREATE GLOBAL TEMPORARY TABLE REGRAS_LISTA_TEMP (	
  LISTA_ID NUMBER(10) not null, 
	ITEM NUMBER(10)     not null, 
	VALOR VARCHAR2(4000), 
CONSTRAINT PK_REGRAS_LISTA_TEMP PRIMARY KEY (LISTA_ID, ITEM)
) ON COMMIT DELETE ROWS ;

CREATE TABLE REGRAS_PROP_NIVEL_ITEM (	
  id NUMBER(10) not null, 
	ORDEM NUMBER(2) not null, 
	TIPO_PROPRIEDADE_ID NUMBER(10) not null, 
	ATRIBUTO_ID NUMBER(10), 
	TEXTO VARCHAR2(4000 BYTE), 
	NIVEL_ID NUMBER(10) not null, 
CONSTRAINT PK_REGRAS_PROP_NIVEL_ITEM PRIMARY KEY (id),
CONSTRAINT UK_REGRAS_PROP_NIVEL_ITEM UNIQUE (NIVEL_ID, ORDEM)
) TABLESPACE &CS_TBL_DAT;

   
CREATE TABLE REGRAS_PROPRIEDADE(	
  id NUMBER(10) NOT null, 
	AGRUPADOR_ID NUMBER(10) NOT null, 
	TITULO VARCHAR2(100 BYTE) NOT null, 
	ESCOPO_ID NUMBER(10) NOT null, 
	WHERE_FILTRO VARCHAR2(4000), 
	FILTRO_ID NUMBER(10), 
	DESCRICAO VARCHAR2(4000), 
CONSTRAINT PK_REGRAS_PROPRIEDADE PRIMARY KEY (id),
CONSTRAINT CHK_REGRAS_PROPRIEDADE_01 CHECK ((where_filtro is not null and filtro_id is not null) or (where_filtro is null and filtro_id is null)) 
) TABLESPACE &CS_TBL_DAT;


COMMENT ON COLUMN REGRAS_PROPRIEDADE.ID IS 'Id';
COMMENT ON COLUMN REGRAS_PROPRIEDADE.AGRUPADOR_ID IS 'Tipo de agrupamento';
COMMENT ON COLUMN REGRAS_PROPRIEDADE.TITULO IS 'Titulo';
COMMENT ON COLUMN REGRAS_PROPRIEDADE.ESCOPO_ID IS 'Tipo de escopo da busca';
COMMENT ON COLUMN REGRAS_PROPRIEDADE.WHERE_FILTRO IS 'Clausula where gerada com base no filtro referenciado';
COMMENT ON COLUMN REGRAS_PROPRIEDADE.FILTRO_ID IS 'Filtro referenciado';
COMMENT ON COLUMN REGRAS_PROPRIEDADE.DESCRICAO IS 'Descricao da regra';
 
CREATE TABLE REGRAS_PROPRIEDADE_NIVEIS(	
  id NUMBER(10) NOT NULL, 
	PROPRIEDADE_ID NUMBER(10) NOT null, 
	TIPO_PROPRIEDADE_ID NUMBER(10), 
	ORDEM NUMBER(1) NOT NULL, 
	ATRIBUTO_ID NUMBER(10), 
	WHERE_FILTRO VARCHAR2(4000), 
	FILTRO_ID NUMBER(10), 
CONSTRAINT PK_REGRAS_PROPRIEDADE_NIVEIS PRIMARY KEY (id),
CONSTRAINT CHK_REGRAS_PROP_NIVEIS_01 CHECK ((where_filtro is not null and filtro_id is not null) or (where_filtro is null and filtro_id is null))
) TABLESPACE &CS_TBL_DAT;

COMMENT ON COLUMN REGRAS_PROPRIEDADE_NIVEIS.ID IS 'Id';
COMMENT ON COLUMN REGRAS_PROPRIEDADE_NIVEIS.PROPRIEDADE_ID IS  'Propriedade que e definida pelos niveis de tipos de propriedade';
COMMENT ON COLUMN REGRAS_PROPRIEDADE_NIVEIS.TIPO_PROPRIEDADE_ID IS  'Tipo de Propriedade';
COMMENT ON COLUMN REGRAS_PROPRIEDADE_NIVEIS.ORDEM IS  'Sequencia de formacao da propriedade';
COMMENT ON COLUMN REGRAS_PROPRIEDADE_NIVEIS.ATRIBUTO_ID IS  'Id do Atributo vinculado';
COMMENT ON COLUMN REGRAS_PROPRIEDADE_NIVEIS.WHERE_FILTRO IS  'Filtro do nivel';
COMMENT ON COLUMN REGRAS_PROPRIEDADE_NIVEIS.FILTRO_ID IS  'Id do filtro';
 
CREATE TABLE REGRAS_TIPO_AGRUPADOR_VALOR(	
  id NUMBER(10) NOT null, 
	TIPO_AGRUPADOR_ID NUMBER(10) NOT null, 
	TIPO_VALOR_ID NUMBER(10) NOT NULL, 
CONSTRAINT PK_REGRAS_TIPO_AGRUPADOR_VALOR PRIMARY KEY (id), 
CONSTRAINT UK_REGRAS_TIPO_AGRUP_VALOR_01 UNIQUE (TIPO_AGRUPADOR_ID, TIPO_VALOR_ID)
) TABLESPACE &CS_TBL_DAT;

COMMENT ON COLUMN REGRAS_TIPO_AGRUPADOR_VALOR.id IS 'Id';
COMMENT ON COLUMN REGRAS_TIPO_AGRUPADOR_VALOR.TIPO_AGRUPADOR_ID IS 'Agrupador';
COMMENT ON COLUMN REGRAS_TIPO_AGRUPADOR_VALOR.TIPO_VALOR_ID IS 'Tipo de valor';
 
CREATE TABLE REGRAS_TIPO_OPERADOR_VAL(
	id NUMBER(10) NOT null, 
	TIPO_VALOR_ID_1 NUMBER(10) NOT null, 
	TIPO_VALOR_ID_2 NUMBER(10) NOT null, 
	TIPO_OPERADOR_ID NUMBER(10) NOT null, 
CONSTRAINT PK_REGRAS_TIPO_OPERADOR_VAL PRIMARY KEY (id)
) TABLESPACE &CS_TBL_DAT;
  
COMMENT ON COLUMN REGRAS_TIPO_OPERADOR_VAL.ID IS 'Id';
COMMENT ON COLUMN REGRAS_TIPO_OPERADOR_VAL.TIPO_VALOR_ID_1 IS 'Tipo do operando que fica a esquerda';
COMMENT ON COLUMN REGRAS_TIPO_OPERADOR_VAL.TIPO_VALOR_ID_2 IS 'Tipo do operando que fica a direita';
COMMENT ON COLUMN REGRAS_TIPO_OPERADOR_VAL.TIPO_OPERADOR_ID IS 'operador';
 
CREATE TABLE REGRAS_TRANSICAO_VALIDACAO (	
  id NUMBER(10) NOT null, 
	FORMULARIO_ID NUMBER(10,0) NOT null, 
	ESTADO_ID_ORIGEM NUMBER(10,0) NOT null, 
	ESTADO_ID_DESTINO NUMBER(10,0) NOT null, 
	OBRIGATORIA VARCHAR2(1 BYTE) DEFAULT 'Y' NOT null, 
	VALIDACAO_ID NUMBER(10,0) NOT null, 
CONSTRAINT PK_REGRAS_TRANSICAO_VALIDACAO PRIMARY KEY (id)
) TABLESPACE &CS_TBL_DAT;

COMMENT ON TABLE REGRAS_TRANSICAO_VALIDACAO  IS 'Vincula regras a transições de estados de formulários';
 
alter table REGRAS_VALIDACAO_ITEM
  add constraint FK_REGRAS_VALIDACAO_ITEM_01 foreign key (VALIDACAO_ID)
  references REGRAS_VALIDACAO (ID);
alter table REGRAS_VALIDACAO_ITEM
  add constraint FK_REGRAS_VALIDACAO_ITEM_02 foreign key (TIPO_OPERADOR_ID)
  references REGRAS_TIPO_OPERADOR (ID);
alter table REGRAS_VALIDACAO_ITEM
  add constraint FK_REGRAS_VALIDACAO_ITEM_03 foreign key (PROPRIEDADE_ID_1)
  references REGRAS_PROPRIEDADE (ID);
alter table REGRAS_VALIDACAO_ITEM
  add constraint FK_REGRAS_VALIDACAO_ITEM_04 foreign key (PROPRIEDADE_ID_2)
  references REGRAS_PROPRIEDADE (ID);
alter table REGRAS_VALIDACAO_ITEM
  add constraint FK_REGRAS_VALIDACAO_ITEM_05 foreign key (REF_VALIDACAO_ID)
  references REGRAS_VALIDACAO (ID);
alter table REGRAS_VALIDACAO_ITEM
  add constraint FK_REGRAS_VALIDACAO_ITEM_06 foreign key (TIPO_FUNCAO_ID_1)
  references REGRAS_TIPO_FUNCAO (ID);
alter table REGRAS_VALIDACAO_ITEM
  add constraint FK_REGRAS_VALIDACAO_ITEM_07 foreign key (TIPO_FUNCAO_ID_2)
  references REGRAS_TIPO_FUNCAO (ID);
alter table REGRAS_VALIDACAO_ITEM
  add constraint FK_REGRAS_VALIDACAO_ITEM_08 foreign key (TIPO_VALOR_ID_1)
  references REGRAS_TIPO_VALOR (ID);
alter table REGRAS_VALIDACAO_ITEM
  add constraint FK_REGRAS_VALIDACAO_ITEM_09 foreign key (TIPO_VALOR_ID_2)
  references REGRAS_TIPO_VALOR (ID);

alter table REGRAS_VALID_FUNCAO_ITEM
  add constraint FK_REGRAS_VALID_FUNCAO_ITEM_01 foreign key (VALIDACAO_ITEM_ID)
  references REGRAS_VALIDACAO_ITEM (ID);
alter table REGRAS_VALID_FUNCAO_ITEM
  add constraint FK_REGRAS_VALID_FUNCAO_ITEM_02 foreign key (PROPRIEDADE_ID)
  references REGRAS_PROPRIEDADE (ID);
alter table REGRAS_VALID_FUNCAO_ITEM
  add constraint FK_REGRAS_VALID_FUNCAO_ITEM_03 foreign key (TIPO_VALOR_ID)
  references REGRAS_TIPO_VALOR (ID) on delete cascade;

alter table REGRAS_PROP_NIVEL_ITEM add CONSTRAINT FK_REGRAS_PROP_NIVEL_ITEM_01 
  FOREIGN KEY (TIPO_PROPRIEDADE_ID) REFERENCES REGRAS_TIPO_PROPRIEDADE (id);
alter table REGRAS_PROP_NIVEL_ITEM add CONSTRAINT FK_REGRAS_PROP_NIVEL_ITEM_02 
  FOREIGN KEY (ATRIBUTO_ID) REFERENCES ATRIBUTO (ATRIBUTOID);
alter table REGRAS_PROP_NIVEL_ITEM add CONSTRAINT FK_REGRAS_PROP_NIVEL_ITEM_03 
  FOREIGN KEY (NIVEL_ID) REFERENCES REGRAS_PROPRIEDADE_NIVEIS (id); 

alter TABLE REGRAS_PROPRIEDADE add CONSTRAINT FK_REGRAS_PROPRIEDADE_01
  FOREIGN KEY (FILTRO_ID) REFERENCES FILTRO (id);
alter TABLE REGRAS_PROPRIEDADE add CONSTRAINT FK_REGRAS_PROPRIEDADE_02 
  FOREIGN KEY (AGRUPADOR_ID) REFERENCES REGRAS_TIPO_AGRUPADOR (id);
alter TABLE REGRAS_PROPRIEDADE add CONSTRAINT FK_REGRAS_PROPRIEDADE_03 
  FOREIGN KEY (ESCOPO_ID) REFERENCES REGRAS_TIPO_ESCOPO (id);

alter table REGRAS_PROPRIEDADE_NIVEIS add constraint FK_REGRAS_PROP_NIVEIS_01
  FOREIGN KEY (PROPRIEDADE_ID) REFERENCES REGRAS_PROPRIEDADE (id); 
alter table REGRAS_PROPRIEDADE_NIVEIS add constraint FK_REGRAS_PROP_NIVEIS_02
	FOREIGN KEY (TIPO_PROPRIEDADE_ID) REFERENCES REGRAS_TIPO_PROPRIEDADE (id); 
alter table REGRAS_PROPRIEDADE_NIVEIS add constraint FK_REGRAS_PROP_NIVEIS_03
	FOREIGN KEY (ATRIBUTO_ID) REFERENCES ATRIBUTO (ATRIBUTOID); 
alter table REGRAS_PROPRIEDADE_NIVEIS add constraint FK_REGRAS_PROP_NIVEIS_04
	FOREIGN KEY (FILTRO_ID) REFERENCES FILTRO (id);

alter table REGRAS_TIPO_AGRUPADOR_VALOR add constraint FK_REGRAS_TIPO_AGRUP_VALOR_01
  FOREIGN KEY (TIPO_AGRUPADOR_ID) REFERENCES REGRAS_TIPO_AGRUPADOR (id); 
alter table REGRAS_TIPO_AGRUPADOR_VALOR add constraint FK_REGRAS_TIPO_AGRUP_VALOR_02
  FOREIGN KEY (TIPO_VALOR_ID) REFERENCES REGRAS_TIPO_VALOR (id);

alter table REGRAS_TIPO_OPERADOR_VAL add constraint FK_REGRAS_TIPO_OPERADOR_VAL_01
  FOREIGN KEY (TIPO_VALOR_ID_1) REFERENCES REGRAS_TIPO_VALOR (id);
alter table REGRAS_TIPO_OPERADOR_VAL add constraint FK_REGRAS_TIPO_OPERADOR_VAL_02
  FOREIGN KEY (TIPO_VALOR_ID_2) REFERENCES REGRAS_TIPO_VALOR (id);
alter table REGRAS_TIPO_OPERADOR_VAL add constraint FK_REGRAS_TIPO_OPERADOR_VAL_03
  FOREIGN KEY (TIPO_OPERADOR_ID) REFERENCES REGRAS_TIPO_VALOR (id);   

alter table REGRAS_TRANSICAO_VALIDACAO add constraint FK_REGRAS_TRANSICAO_VALID_01
  FOREIGN KEY (FORMULARIO_ID, ESTADO_ID_ORIGEM, ESTADO_ID_DESTINO) REFERENCES PROXIMO_ESTADO (FORMULARIO_ID, ESTADO_ORIGEM, ESTADO_DESTINO); 
alter table REGRAS_TRANSICAO_VALIDACAO add constraint FK_REGRAS_TRANSICAO_VALID_02	 
  FOREIGN KEY (VALIDACAO_ID) REFERENCES REGRAS_VALIDACAO (id);
  
create or replace
PACKAGE PCK_CONHECIMENTO_PROFISSIONAL AS
function f_get_titulo_conhecimento (usuario VARCHAR2) return varchar2;
end PCK_CONHECIMENTO_PROFISSIONAL;
/


create or replace
PACKAGE body PCK_CONHECIMENTO_PROFISSIONAL AS

/**
 * Function responsável por concatenar o título do conhecimento com o nível do mesmo, por usuário
 * é utlizado na consulta do selecionador de usuários
 */
function f_get_titulo_conhecimento (usuario VARCHAR2) return varchar2 is
  strRetorno varchar2(4000) := '';
 begin
 
    for c in (select cp.titulo as conhecimento, ni.titulo as nivel
    from conhecimento_profissional cp, conhec_usuario_aval cu, nivelconhecimento ni
    where cp.id = cu.conhecimento_id
    and ni.nivelid = cu.nivel_id
    and cu.usuario_id = usuario) loop
      if (trim(strRetorno) is null) then
        strRetorno := c.conhecimento || ' - ' || c.nivel;
        dbms_output.put_line('step 0: '|| strRetorno);
      else
        strRetorno := strRetorno || ' / ' || c.conhecimento || ' - ' || c.nivel;
        dbms_output.put_line('step 1: '|| strRetorno);
      end if;
    end loop;
    
    return strRetorno;
 end;

END PCK_CONHECIMENTO_PROFISSIONAL;
/

alter table REGRAS_VALID_FUNCAO_ITEM
  drop constraint UK_REGRAS_VALID_FUNCAO_ITEM_01 cascade;

alter table REGRAS_VALID_FUNCAO_ITEM
  add constraint FK_REGRAS_VALID_FUNCAO_ITEM_01 foreign key (VALIDACAO_ITEM_ID)
  references REGRAS_VALIDACAO_ITEM (ID) on delete cascade;

alter table REGRAS_VALID_FUNCAO_ITEM
  add constraint FK_REGRAS_VALID_FUNCAO_ITEM_02 foreign key (PROPRIEDADE_ID)
  references REGRAS_PROPRIEDADE (ID) on delete cascade;

alter table TRANSICAO_ESTADO add ATIVA_TESTE varchar2(1);
alter table ACAO_CONDICIONAL add TIPO_VALIDACAO varchar2(1);

alter table ACAO_CONDICIONAL add TRANSICAO_ID NUMBER(10);
ALTER TABLE ACAO_CONDICIONAL ADD CONSTRAINT FK_ACAO_CONDICIONAL_09 
  FOREIGN KEY (TRANSICAO_ID) REFERENCES TRANSICAO_ESTADO(TRANSICAO_ESTADO_ID)
ON DELETE cascade;

alter table ACAO_CONDICIONAL add PROPRIEDADE_ID NUMBER(10);
ALTER TABLE ACAO_CONDICIONAL ADD CONSTRAINT FK_ACAO_CONDICIONAL_10
  FOREIGN KEY (PROPRIEDADE_ID) REFERENCES REGRAS_PROPRIEDADE(ID)
ON DELETE cascade;

alter table ACAO_CONDICIONAL add TIPO_LANCAMENTO_ID NUMBER(10);
ALTER TABLE ACAO_CONDICIONAL ADD CONSTRAINT FK_ACAO_CONDICIONAL_11 
  FOREIGN KEY (TIPO_LANCAMENTO_ID) REFERENCES TIPO_LANCAMENTO(ID)
ON DELETE cascade;


alter table ACAO_CONDICIONAL add TIPO_ESCOPO_ID NUMBER(10);
ALTER TABLE ACAO_CONDICIONAL ADD CONSTRAINT FK_ACAO_CONDICIONAL_12 
  FOREIGN KEY (TIPO_ESCOPO_ID) REFERENCES REGRAS_TIPO_ESCOPO(ID)
ON DELETE cascade;

alter table ACAO_CONDICIONAL add FILTRO_ESCOPO_ID NUMBER(10);
ALTER TABLE ACAO_CONDICIONAL ADD CONSTRAINT FK_ACAO_CONDICIONAL_13 
  FOREIGN KEY (FILTRO_ESCOPO_ID) REFERENCES FILTRO(ID)
ON DELETE cascade;

----------------------

CREATE TABLE REGRAS_VALID_TRANSICAO ( 
  ID NUMBER(10) NOT NULL,
  TRANSICAO_ID NUMBER(10) NOT NULL,
  REGRA_VALIDACAO_ID NUMBER(10),
  TIPO VARCHAR2(1)
);

ALTER TABLE REGRAS_VALID_TRANSICAO ADD CONSTRAINT PK_REGRAS_VALID_TRANSICAO
  PRIMARY KEY (ID);

ALTER TABLE REGRAS_VALID_TRANSICAO ADD CONSTRAINT FK_REGRAS_VALID_TRANSICAO_01 
  FOREIGN KEY (TRANSICAO_ID) REFERENCES TRANSICAO_ESTADO (TRANSICAO_ESTADO_ID)
ON DELETE cascade;

ALTER TABLE REGRAS_VALID_TRANSICAO ADD CONSTRAINT FK_REGRAS_VALID_TRANSICAO_02 
  FOREIGN KEY (REGRA_VALIDACAO_ID) REFERENCES REGRAS_VALIDACAO (ID)
ON DELETE cascade;
--------------------------

CREATE TABLE USUARIO_AUTORIZADOR ( 
  USUARIO_ID VARCHAR(50) NOT NULL,
  TRANSICAO_ID NUMBER(10)
);

ALTER TABLE USUARIO_AUTORIZADOR ADD CONSTRAINT PK_USUARIO_AUTORIZADOR
  PRIMARY KEY (USUARIO_ID, TRANSICAO_ID);

ALTER TABLE USUARIO_AUTORIZADOR ADD CONSTRAINT FK_USUARIO_AUTORIZADOR_01 
  FOREIGN KEY (USUARIO_ID) REFERENCES USUARIO(USUARIOID)
ON DELETE cascade;

ALTER TABLE USUARIO_AUTORIZADOR ADD CONSTRAINT FK_USUARIO_AUTORIZADOR_02 
  FOREIGN KEY (TRANSICAO_ID) REFERENCES TRANSICAO_ESTADO(TRANSICAO_ESTADO_ID)
ON DELETE cascade;
-------------------

CREATE SEQUENCE REGRAS_VALID_TRANSICAO_SEQ START WITH 1 INCREMENT BY 1 nocache;
CREATE SEQUENCE DETALHE_ACAO_CONDIC_SEQ START WITH 1 INCREMENT BY 1 nocache;
CREATE SEQUENCE USUARIO_AUTORIZADOR_SEQ START WITH 1 INCREMENT BY 1 nocache;

--------------ALTERADO 28-06-2010---------------------

CREATE TABLE DETALHE_ACAO_CONDIC ( 
  ID NUMBER(10) NOT NULL,
  ACAO_CONDICIONAL_ID NUMBER(10) NOT NULL,
  PAPEL_ID NUMBER(10),
  TITULO_PAPEL_ID VARCHAR2(250),
  MODELO_IMPRESSAO_ID NUMBER(10),
  DESCRICAO VARCHAR2(4000),
  TIPO number(10),
  PROCEDIMENTO VARCHAR2(1)
);

ALTER TABLE DETALHE_ACAO_CONDIC ADD CONSTRAINT PK_DETALHE_ACAO_CONDIC
  PRIMARY KEY (ID);

ALTER TABLE DETALHE_ACAO_CONDIC ADD CONSTRAINT FK_DETALHE_ACAO_CONDIC_01 
  FOREIGN KEY (ACAO_CONDICIONAL_ID) REFERENCES ACAO_CONDICIONAL (ID)
ON DELETE cascade;

ALTER TABLE DETALHE_ACAO_CONDIC ADD CONSTRAINT FK_DETALHE_ACAO_CONDIC_02 
  FOREIGN KEY (PAPEL_ID) REFERENCES PAPELPROJETO (PAPELPROJETOID)
ON DELETE cascade;

ALTER TABLE DETALHE_ACAO_CONDIC ADD CONSTRAINT FK_DETALHE_ACAO_CONDIC_03 
  FOREIGN KEY (MODELO_IMPRESSAO_ID) REFERENCES MODELO_IMPRESSAO_FORM(ID)
ON DELETE cascade;

ALTER TABLE acao_condicional
drop CONSTRAINT CHK_ACAO_CONDICIONAL_01;

ALTER TABLE acao_condicional
add CONSTRAINT CHK_ACAO_CONDICIONAL_01
   CHECK (acao in ('DE','EX','HA','LI','OC','PO','OB','TO', 'PF', 'DS', 'EE', 'GM', 'GB', 'AM', 'VE', 'CO', 'CL', 'CP', 'GD'));

update transicao_estado set ativa_teste = 'N';
commit;
/

create or replace package pck_regras is

  -- Author  : MDIAS
  -- Created : 7/5/2010 13:20:57
  
   function f_get_valor_propriedade ( pn_demanda_id demanda.demanda_id%type,
                                      pv_usuario_id usuario.usuarioid%type,
                                      pn_propriedade_id regras_propriedade.id%type ) return varchar2;

   function f_formata (pn_numero number) return varchar2;
   
   function f_get_numero (pv_numero varchar2) return number;
   
   function f_formata (pd_data date) return varchar2;
     
   function f_get_Data (pv_data varchar2) return date;
   
   function f_teste_validacao ( pn_demanda_id   demanda.demanda_id%type,
                                pn_validacao_id regras_validacao.id%type,
                                pv_usuario_id   usuario.usuarioid%type) return boolean;

   procedure p_copia_propriedade ( pn_demanda_id demanda.demanda_id%type,
                                   pv_usuario_id usuario.usuarioid%type,
                                   pn_propriedade_id_origem regras_propriedade.id%type,
                                   pv_valor_origem varchar2,
                                   pn_propriedade_id_destino regras_propriedade.id%type,
                                   pb_append boolean );

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
             lv_where := ' and '|| lv_alias_atual || '.demanda_id in (select identidade from solicitacaoentidade p, solicitacaoentidade d where p.tipoentidade = d.tipoentidade and p.identidade = d.identidade and p.tipoentidade = ''P'' and p.solicitacao = ' || pn_demanda_id ||') '||
                         ' and '|| lv_alias_atual || '.demanda_id <> ' || pn_demanda_id|| ' ';
          elsif c.escopo = 'demandasProjetosAssociadosMaisCorrente' then
             lv_where := ' and '|| lv_alias_atual || '.demanda_id in (select identidade from solicitacaoentidade p, solicitacaoentidade d where p.tipoentidade = d.tipoentidade and p.identidade = d.identidade and p.tipoentidade = ''P'' and p.solicitacao = ' || pn_demanda_id ||') ';
          elsif c.escopo = 'projetosDemandasFilhas' then
             lv_where := ' and '|| lv_alias_atual || '.id in (select identidade from solicitacaoentidade where tipoentidade = ''P'' and solicitacao in (select demanda_id from demanda where demanda_pai =  ' || pn_demanda_id ||')) ';
          elsif c.escopo = 'projetosDemandasFilhas' then
             lv_where := ' and '|| lv_alias_atual || '.id in (select identidade from solicitacaoentidade where tipoentidade = ''P'' and solicitacao in (select demanda_pai from demanda where demanda_id =  ' || pn_demanda_id ||')) ';
          end if;
          
          if c.where_filtro_propriedade is not null then
             lv_where := ' and '|| replace(c.where_filtro_propriedade, '[ENTIDADE]', lv_alias_atual);
          end if;
          
          lv_coluna_pk_entidade := c.p_coluna_pk;
          lv_from_entidade := lv_from;
          lv_where_entidade := lv_where;
          pn_tipo_entidade_id := c.p_tipo_entidade_id;
          lv_alias_atual_entidade := lv_alias_atual;
          
       end if;
       
       --Se a propriedade referencia uma outra entidade e devem ser buscadas 
       --propriedades da entidade referenciada (nao e o ultimo nivel)
       if c.r_nome_tabela is not null and c.r_nome_tabela not in ('ATRIBUTO_VALOR','ATRIBUTOENTIDADEVALOR') then
          ln_seq_alias := ln_seq_alias + 1;
          lv_alias_anterior := lv_alias_atual;
          lv_alias_atual := 'tab_'||ln_seq_alias;
          
          lv_coluna := c.r_coluna_pk;
          
          lv_nome_tabela_atual := c.r_nome_tabela;
          
          lv_from := lv_from || ', ' || c.r_nome_tabela || ' '|| lv_alias_atual;

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
       if c.total = c.linha then
           if c.itens is null then
              if c.agrupador<>'concatena' and 
                 c.tipo_valor in ('numero', 'horas', 'data', 'entidade', 'lancamento') then
                 if c.tipo_valor in ('numero', 'horas', 'entidade', 'lancamento') then
                    lv_formato := const_formato_numero;
                 else
                    lv_formato := const_formato_data;
                 end if;
                 lb_to_char := true;
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
                 lb_to_char := false;
                 if c.agrupador<>'concatena' and
                    it.total = 1 and 
                    it.tipo_valor in ('numero', 'horas', 'data', 'entidade', 'lancamento') then
                    if it.tipo_valor in ('numero', 'horas', 'entidade', 'lancamento') then
                       lv_formato := const_formato_numero;
                    else
                       lv_formato := const_formato_data;
                    end if;
                    lb_to_char := true;
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
                          elsif c.agrupador = 'lista' then
                             lb_lista := true;
                          elsif c.agrupador = 'concatena' then
                             lb_concatena := true;
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
              if c.tipo_valor in ('numero','data','string','horas','entidade', 'lancamento') then
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
                 elsif c.agrupador = 'lista' then
                    lb_lista := true;
                    lv_coluna := lv_coluna;
                 elsif c.agrupador = 'concatena' then
                    lb_concatena := true;
                    lv_coluna := lv_coluna;
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

     --Se o agrupador for do tipo lista, salva em tabela temporaria e 
     --retorna o ID da lista
     if pb_get_update then
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
        
        execute immediate lv_sql;
        
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
      
      return f_get_val_sel_propriedade ( pn_demanda_id, pv_usuario_id, pn_propriedade_id, false, ln_tipo_entidade_id);

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
   
   function f_funcao ( pn_id                       regras_validacao_item.id%type,  
                       pv_codigo_funcao            regras_tipo_funcao.codigo%type,
                       pn_val_1_2                  regras_valid_funcao_item.val_1_2%type,
                       pn_demanda_id               demanda.demanda_id%type, 
                       pv_usuario_id               usuario.usuarioid%type ) return varchar2 is
     lv_retorno       varchar2(32000);
     lv_valor         varchar2(32000);
     ln_retorno       number;
     lb_par1          boolean:= true;
     begin
       
        for c in (select i.*, f.codigo codigo_funcao_filha
                  from regras_valid_funcao_item i,
                       regras_propriedade p,
                       regras_tipo_funcao f
                  where (i.validacao_item_id = pn_id or i.valid_funcao_item_id = pn_id)
                  and   i.val_1_2 = pn_val_1_2
                  and   i.propriedade_id = p.id (+)
                  and   i.tipo_funcao_id = f.id
                  order by i.ordem) loop
           
           if c.codigo_funcao_filha is not null then
              lv_valor := f_funcao ( c.id, c.codigo_funcao_filha, 1, pn_demanda_id, pv_usuario_id );
           elsif c.propriedade_id is not null then
              lv_valor := f_get_valor_propriedade(pn_demanda_id,pv_usuario_id, c.propriedade_id);
           else
              lv_valor := c.valor;
           end if; 
           
           if lb_par1 then
              if pv_codigo_funcao in ('soma','multiplicacao') then
                 ln_retorno := f_get_numero(lv_valor);
              else
                 lv_retorno := lv_valor;
              end if;
           else
              if pv_codigo_funcao = 'soma' then
                 ln_retorno := ln_retorno + f_get_numero(lv_valor);
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
                                pv_usuario_id   usuario.usuarioid%type) return boolean is
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
     begin
        for c in (select v.operador_ligacao, 
                         i.*,
                         f1.codigo f1_codigo,
                         f2.codigo f2_codigo,
                         v.vigente,
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
           
           --outra validacao
           if c.vigente = 'N' then
              lb_result_item := true;
           elsif c.tipo = 'V' then
              lb_result_item := f_teste_validacao ( pn_demanda_id, c.validacao_id, pv_usuario_id );
           else
              if c.f1_codigo is not null then
                 lv_valor_1 := f_funcao (  c.id, c.f1_codigo, 1, pn_demanda_id, pv_usuario_id );
              elsif c.propriedade_id_1 is not null then
                 lv_valor_1 := f_get_valor_propriedade ( pn_demanda_id, pv_usuario_id, c.propriedade_id_1 );
              else
                 lv_valor_1 := c.valor_1;
              end if;
              if c.f2_codigo is not null then
                 lv_valor_2 := f_funcao (  c.id, c.f2_codigo, 2, pn_demanda_id, pv_usuario_id );
              elsif c.propriedade_id_2 is not null then
                 lv_valor_2 := f_get_valor_propriedade ( pn_demanda_id, pv_usuario_id, c.propriedade_id_2 );
              else
                 lv_valor_2 := c.valor_2;
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
                 
                 if c.operador = 'estaContido' then
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
                 elsif c.operador = 'estaContido' then
                    lb_result_item := instr(lv_valor_2, lv_valor_1) > 0;
                 elsif c.operador = 'vazio' then
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
              
              if c.operador_ligacao = 'E' and not lb_result_item then
                 return false;
              elsif c.operador_ligacao = 'O' and lb_result_item then
                 return true;
              elsif c.operador_ligacao = 'X' and ln_cont_true > 1 then
                 return false;
              end if;
              
              lb_result(c.item) := lb_result_item;
                             
           end if;
        
        end loop;
        
        if lv_operador_ligacao is null then
           return false;
        elsif lv_operador_ligacao = 'E' then
           if ln_cont_true = lb_result.count then
              return true;
           else 
              return false;
           end if;
        elsif lv_operador_ligacao = 'O' then
           if ln_cont_true > 0 then
              return true;
           else 
              return false;
           end if;
        elsif lv_operador_ligacao = 'X' then
           if ln_cont_true = 1 then
              return true;
           else 
              return false;
           end if;
        end if;
        
        return false;
     end; 
     
   procedure p_copia_propriedade ( pn_demanda_id demanda.demanda_id%type,
                                   pv_usuario_id usuario.usuarioid%type,
                                   pn_propriedade_id_origem regras_propriedade.id%type,
                                   pv_valor_origem varchar2,
                                   pn_propriedade_id_destino regras_propriedade.id%type,
                                   pb_append boolean ) is
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
   
   begin
      if pn_propriedade_id_origem is not null then
         lv_valor_origem := f_get_valor_propriedade(pn_demanda_id, pv_usuario_id, pn_propriedade_id_origem);
      else
         lv_valor_origem := pv_valor_origem;
      end if;
      lv_sql_destino := f_get_val_sel_propriedade(pn_demanda_id, pv_usuario_id, pn_propriedade_id_destino, true, ln_tipo_entidade_id);
      
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
                   lv_valor_atualizar := ' pck_regras.f_get_data('''''|| lv_valor_origem ||''''','''''|| const_formato_data || ''''') ';
                   
                elsif lv_tipo_atributo in (pck_atributo.Tipo_NUMERO, pck_atributo.Tipo_MONETARIO,
                                          pck_atributo.Tipo_HORA) then
                   lv_valor_atualizar := ' pck_regras.f_get_numero('''''|| lv_valor_origem ||''''','''''|| const_formato_numero || ''''','''''|| const_nls_numero_sql || ''''') ';
                   
                elsif lv_tipo_atributo in (pck_atributo.Tipo_LISTA, pck_atributo.Tipo_LISTA_MULTIPLA_ESCOLHA,
                                          pck_atributo.Tipo_ARVORE) then
                   lv_valor_atualizar := ' pck_regras.f_get_numero('''''|| lv_valor_origem ||''''','''''|| const_formato_numero || ''''','''''|| const_nls_numero_sql || ''''') ';
                   
                else
                   lv_valor_atualizar := ' '''''|| lv_valor_origem ||''''' ';
                end if;

                if c.nome_tabela in ('ATRIBUTO_VALOR', 'ATRIBUTOENTIDADEVALOR') then
     
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
                             if c.nome_tabela = 'ATRIBUTO_VALOR' then
                                 lv_update_valor := ' begin '||
                                                    ' delete ' || c.nome_tabela ||
                                                    ' where demanda_id = ' || ln_id || 
                                                    ' and   atributo_id = '|| ln_atributo_id || 
                                                    ' and ' ||lv_coluna_insert ||' not in (' || lv_lista_valores ||');' ||
                                                    ' end; ';
                             elsif c.nome_tabela = 'ATRIBUTOENTIDADEVALOR' then
                                 lv_delete_valor := ' begin '||
                                                    ' delete ' || c.nome_tabela ||
                                                    ' where identidade = ' || ln_id || 
                                                    ' and   atributo_id = '|| ln_atributo_id || 
                                                    ' and ' ||lv_coluna_insert ||' not in (' || lv_lista_valores || ') ' ||
                                                    ' and   tipoentidade '''||rec_tipo_entidade.tipo_entidade || ''';' ||
                                                    ' end; ';
                             end if;
                             execute immediate lv_delete_valor;
                          end if;

                          if c.nome_tabela = 'ATRIBUTO_VALOR' then
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
                          elsif c.nome_tabela = 'ATRIBUTOENTIDADEVALOR' then
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
                                                                   ' and   atributo_id = '|| ln_atributo_id ||' '||
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
                          if c.nome_tabela = 'ATRIBUTO_VALOR' then
                             lv_update_valor := ' begin '||
                                                ' update ' || c.nome_tabela ||
                                                lv_update_valor || ', '||
                                                '     date_update = sysdate, ' ||
                                                '     user_update = '''||pv_usuario_id||''''||
                                                ' where demanda_id = ' || ln_id || 
                                                ' and   atributo_id = '|| ln_atributo_id || ';' ||
                                                ' end; ';
                          elsif c.nome_tabela = 'ATRIBUTOENTIDADEVALOR' then
                             lv_update_valor := ' begin '||
                                                ' update ' || c.nome_tabela ||
                                                ' set '||lv_coluna_insert|| ' = ' ||lv_valor_atualizar || ' '||
                                                ' where identidade = ' || ln_id || 
                                                ' and   atributo_id = '|| ln_atributo_id || 
                                                ' and   tipoentidade '''||rec_tipo_entidade.tipo_entidade || ''';' ||
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
                         
                         if lb_primeiro_lancamento or ln_custo_entidade_id <> rec_lancamento.custo_entidade_id then
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
                            
                         end if;
                         
                         select custo_lancamento_seq.nextval
                         into ln_custo_lancamento_id_novo
                         from dual;
                         
                         lv_insert_valor := ' insert into custo_lancamento ( id, custo_entidade_id, tipo, '||
                                            '                                situacao, data, valor_unitario, '||
                                            '                                quantidade, valor, usuario_id, '||
                                            '                                data_alteracao ) '||
                                            ' values ( '||ln_custo_lancamento_id_novo||', '||ln_custo_entidade_id||','''||
                                                       rec_lancamento.tipo ||''','''||rec_lancamento.situacao||''','||
                                                       ' to_date('''||to_char(rec_lancamento.data, const_formato_data)||''','''||const_formato_data||'''),'||
                                                       to_char(rec_lancamento.valor_unitario, 'fm99999999999999999990D9999999999',const_nls_numero_update)||','||
                                                       to_char(rec_lancamento.quantidade, 'fm99999999999999999990D9999999999',const_nls_numero_update)||','||
                                                       to_char(rec_lancamento.valor, 'fm99999999999999999990D9999999999',const_nls_numero_update)||','||
                                                       ''''||pv_usuario_id||''','||
                                                       ' sysdate)';
                         execute immediate lv_insert_valor;
                         /*
                         insert into atributoentidade_lancvalor (id, atributoid,tipoentidade,
                           tipo_lancamento_id,identidade,valor,valordata,valornumerico,
                           dominio_atributo_id,valor_html, categoria_item_atributo_id)
                         select id, atributoid,tipoentidade,
                           tipo_lancamento_id,identidade,valor,valordata,valornumerico,
                           dominio_atributo_id,valor_html, categoria_item_atributo_id
                         from atributoentidade_lancvalor
                         where */
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
                                ' update ' || c.nome_tabela ||
                                '        ' || c.coluna || ' = ' ||c.coluna || '||' || lv_valor_atualizar ||
                                ' where '|| rec_tipo_entidade.coluna_pk ||' in (' ||lv_sql_destino || '); '||
                                ' end; ';
                   else
                      raise_application_error(-20001, 'Tipo de propriedade nao permitida para concatenacao(append)');
                   end if;
                   lv_sql := ' begin '||
                             ' update ' || c.nome_tabela ||
                             '        ' || c.coluna || ' = ' || lv_valor_atualizar ||
                             ' where '|| rec_tipo_entidade.coluna_pk ||' in (' ||lv_sql_destino || '); '||
                             ' end; ';
                end if;
             end if;
         end loop;
         close lc_valores;
      end loop;

   end;
end pck_regras;
/


alter table estado_formulario add prox_estado_padrao number(10);
--
begin
  pck_processo.pRecompila;
  commit;
end;
/

-------------------------------------------------------------------------------
-- Finalização
-------------------------------------------------------------------------------

insert into versao(id, titulo, patch, versao_tgp_id, comentario)
       values (versao_seq.nextval, '6.0.0', '03', 3, 'Aplicação de patch (parte1)');
commit;
/

begin
  pck_processo.precompila;
  commit;
end;
/
                      
select * from v_versao;
/


  
