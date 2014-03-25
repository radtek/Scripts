/******************************************************************************\
* TraceGP 6.0.0.04                                                             *
\******************************************************************************/

define CS_TBL_DAT = &TABLESPACE_DADOS;
define CS_TBL_IND = &TABLESPACE_INDICES;
 
--  
alter table solicitacao_ajuste_ponto drop constraint FK_SOLICITACAOAJUSTEPONTO_03;
alter table solicitacao_ajuste_ponto add constraint  FK_SOLICITACAOAJUSTEPONTO_03
  foreign key (ponto_eletronico_id) references pontoeletronico(id) on delete cascade;
  
--
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
    cc.id CENTRO_CUSTO_ID
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
    cc.id CENTRO_CUSTO_ID
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
    cc.id CENTRO_CUSTO_ID
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

--
alter table H_DEMANDA add constraint PK_H_DEMANDA  primary key (id);

alter table AGENDAMENTO_TRANSICAO_EST_LOG add constraint FK_AGENDAMENTO_TRAN_EST_LOG_03
  foreign key (estado_atual_id) references H_DEMANDA(ID) on delete cascade;
  
--
alter table ACAO_CONDICIONAL modify CONDICIONAL_SE_ID null;


-- GERADOR DE RELATORIOS
create table RELAT_COMPONENTE (
  ID     NUMBER(10)   not null,
  TITULO VARCHAR2(50) not null,
  SIGLA  VARCHAR2(20) not null,
constraint PK_RELAT_COMPONENTE primary key (id) using index tablespace &CS_TBL_IND
) tablespace &CS_TBL_DAT;

create table RELAT_COMPONENTE_FILTRO (
  ID                      NUMBER(10)   not null,
  SIGLA_COMP_DESTINO      VARCHAR2(20) not null,
  SIGLA_PARAMETRO_DESTINO VARCHAR2(20) not null,
  SIGLA_COMP_ORIGEM       VARCHAR2(20) not null,
  SIGLA_CAMPO_ORIGEM      VARCHAR2(20) not null,
  RELATORIO_ID            NUMBER(10)   not null,
constraint PK_RELAT_COMPONENTE_FILTRO primary key (id) using index tablespace &CS_TBL_IND  
) tablespace &CS_TBL_DAT;

create table RELAT_DATASET (
  ID          NUMBER(10)    not null,
  TITULO      VARCHAR2(100) not null,
  DESCRICAO   VARCHAR2(4000),
  VIGENTE     VARCHAR2(1)   default 'Y' not null,
  COMANDO_SQL CLOB,
constraint PK_RELAT_DATASET primary key (id) using index tablespace &CS_TBL_IND  
) tablespace &CS_TBL_DAT;

comment on column RELAT_DATASET.VIGENTE
  is 'Y/N';

create table RELAT_DATASET_CAMPO (
  ID         NUMBER(10)   not null,
  DATASET_ID NUMBER(10)   not null,
  ORDEM      NUMBER(2)    not null,
  TITULO     VARCHAR2(50) not null,
  TIPO       VARCHAR2(1)  default 'S' not null,
  SIGLA      VARCHAR2(20) not null,
  TAMANHO    number(10)   default 10 not null,
constraint PK_RELAT_DATASET_CAMPO primary key (id) using index tablespace &CS_TBL_IND,
constraint UK_RELAT_DATASET_CAMPO_01 unique (DATASET_ID, SIGLA) using index tablespace &CS_TBL_IND
) tablespace &CS_TBL_DAT;

comment on column RELAT_DATASET_CAMPO.TIPO
  is '(S)tring/(N)úmero/(D)ata';

create table RELAT_DATASET_PARAMETRO (
  ID          NUMBER(10)   not null,
  DATASET_ID  NUMBER(10)   not null,
  ORDEM       NUMBER(2)    not null,
  TITULO      VARCHAR2(50) not null,
  TIPO        VARCHAR2(1)  default 'S' not null,
  LISTA       VARCHAR2(1)  default 'N' not null,
  OBRIGATORIO VARCHAR2(1)  default 'N' not null,
  SIGLA       VARCHAR2(20) not null,
constraint PK_RELAT_DATASET_PARAMETRO primary key (id) using index tablespace &CS_TBL_IND,
constraint UK_RELAT_DATASET_PARAMETRO_01 unique (DATASET_ID, SIGLA) using index tablespace &CS_TBL_IND 
) tablespace &CS_TBL_DAT;

comment on column RELAT_DATASET_PARAMETRO.TIPO
  is '(S)tring/(N)úmero/(D)ata';
comment on column RELAT_DATASET_PARAMETRO.LISTA
  is 'Y/N';
comment on column RELAT_DATASET_PARAMETRO.OBRIGATORIO
  is 'Y/N';
comment on column RELAT_DATASET_PARAMETRO.SIGLA
  is 'Campo utilizado como referencia nos relatorios';

create table RELAT_RELATORIO (
  ID         NUMBER(10)    not null,
  TITULO     VARCHAR2(100) not null,
  DESCRICAO  VARCHAR2(4000),
  VIGENTE    VARCHAR2(1)   default 'Y' not null,
  DATASET_ID NUMBER(10),
  ORIENTACAO varchar2(1)   default 'R' not null,
constraint PK_RELAT_RELATORIO primary key (id) using index tablespace &CS_TBL_IND
) tablespace &CS_TBL_DAT;

comment on column RELAT_RELATORIO.VIGENTE
  is 'Y/N';
comment on column RELAT_RELATORIO.ORIENTACAO
  is '(R)etrato/(P)aisagem';

create table RELAT_RELATORIO_COMPONENTE (
  ID                   NUMBER(10)  not null,
  RELATORIO_ID         NUMBER(10)  not null,
  ORDEM                NUMBER(4)   not null,
  POS_X                NUMBER(4)   not null,
  POS_Y                NUMBER(4)   not null,
  LARGURA              NUMBER(4)   not null,
  ALTURA               NUMBER(4)   not null,
  ALTURA_AUTO          VARCHAR2(1) default 'N' not null,
  TIPO                 VARCHAR2(1),
  TEXTO                VARCHAR2(4000),
  TIPO_GRAFICO         VARCHAR2(1),
  TIPO_POS_X           VARCHAR2(1) default 'F' not null,
  TIPO_POS_Y           VARCHAR2(1) default 'F' not null,
  TIPO_LARGURA         VARCHAR2(1) default 'F' not null,
  TIPO_ALTURA          VARCHAR2(1) default 'F' not null,
  NEGRITO              VARCHAR2(1),
  ITALICO              VARCHAR2(1),
  FONTSIZE             NUMBER(2),
  COLOR                VARCHAR2(6),
  TEXTDECORATION       VARCHAR2(40),
  TEXTALIGN            VARCHAR2(10),
  BORDER               VARCHAR2(1),
  BACKGROUNDCOLOR      VARCHAR2(6),
  FORMATO              VARCHAR2(50),
  DATASET_ID           NUMBER(10),
  GRAF_CAMPO_CATEGORIA VARCHAR2(50),
  GRAF_CAMPO_SERIE     VARCHAR2(50),
  COMP_CAMPO_GRUPO     VARCHAR2(50),
  COMP_COLUNAS_GRUPO   NUMBER(2),
  SIGLA                VARCHAR2(20),
  GRAF_CAMPO_VALOR     VARCHAR2(50),
  CAMPO_LINHAS         VARCHAR2(4000),
  CAMPO_COLUNAS        VARCHAR2(4000),
  CAMPO_TOTAIS         VARCHAR2(4000),
  CAMPOS               VARCHAR2(4000),
  drill_relat_id       number(10), 
constraint PK_RELAT_RELATORIO_COMPONENTE primary key (id) using index tablespace &CS_TBL_IND
) tablespace &CS_TBL_DAT;

create table RELAT_RELATORIO_PARAMETRO (
  ID            NUMBER(10)   not null,
  RELATORIO_ID  NUMBER(10)   not null,
  ORDEM         NUMBER(2)    not null,
  TITULO        VARCHAR2(50) not null,
  COMPONENTE_ID NUMBER(10),
  SIGLA         VARCHAR2(20) not null,
  OBRIGATORIO   VARCHAR2(1)  default 'N' not null,
constraint PK_RELAT_RELATORIO_PARAMETRO primary key (id) using index tablespace &CS_TBL_IND,
constraint UK_RELAT_RELAT_PARAMETRO_01 unique (RELATORIO_ID, SIGLA) using index tablespace &CS_TBL_IND
) tablespace &CS_TBL_DAT;

comment on column RELAT_RELATORIO_PARAMETRO.COMPONENTE_ID
  is 'Componente ext';

alter table RELAT_RELATORIO_PARAMETRO add constraint FK_RELAT_RELAT_PARAMETRO_01 
  foreign key (RELATORIO_ID) references RELAT_RELATORIO (ID);

alter table RELAT_DATASET_CAMPO add constraint FK_RELAT_DATASET_CAMPO_01 
  foreign key (DATASET_ID) references RELAT_DATASET (ID);
  
alter table RELAT_DATASET_PARAMETRO add constraint FK_RELAT_DATASET_PARAMETRO_01 
  foreign key (DATASET_ID) references RELAT_DATASET (ID);
  
alter table RELAT_RELATORIO add constraint FK_RELAT_RELATORIO_01 
  foreign key (DATASET_ID)references RELAT_DATASET (ID);
  
alter table RELAT_RELATORIO_COMPONENTE add constraint FK_RELAT_RELATORIO_COMP_01 
  foreign key (RELATORIO_ID) references RELAT_RELATORIO (ID);
  
alter table RELAT_RELATORIO_COMPONENTE add constraint FK_RELAT_RELATORIO_COMP_02 
  foreign key (DATASET_ID) references RELAT_DATASET (ID);

alter table RELAT_RELATORIO_COMPONENTE add constraint FK_RELAT_RELATORIO_COMP_03 
  foreign key (DRILL_RELAT_ID) references relat_relatorio (ID);
  
  
create sequence relat_dataset_seq
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache; 
create sequence relat_dataset_campo_seq
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache; 
create sequence relat_dataset_parametro_seq
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache; 
create sequence RELAT_COMPONENTE_FILTRO_SEQ
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache; 
create sequence RELAT_RELATORIO_PARAMETRO_SEQ
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache; 
create sequence RELAT_RELATORIO_COMPONENTE_SEQ
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache;  
       
-- Tabela de Relacionamento entre o Modelo de Impressão do Formulários com Estados
CREATE TABLE MODELO_FORM_ESTADO ( 
  MODELO_IMPRESSAO_FORM_ID NUMBER(10) NOT null,
  ESTADO_ID                NUMBER(10) NOT null,
constraint PK_MODELO_FORM_ESTADO primary key (MODELO_IMPRESSAO_FORM_ID, ESTADO_ID) using index tablespace &CS_TBL_IND
) tablespace &CS_TBL_DAT;

create sequence MODELO_FORM_ESTADO_SEQ
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache;  

COMMENT ON TABLE MODELO_FORM_ESTADO 
  IS 'Tabela de Relacionamento entre o Modelo de Impressão do Formulários com Estados';
COMMENT ON COLUMN MODELO_FORM_ESTADO.MODELO_IMPRESSAO_FORM_ID 
  IS 'Identificação do Modelo de Impressão do Formulário';
COMMENT ON COLUMN MODELO_FORM_ESTADO.ESTADO_ID 
  IS 'Identificador do Estado';

---------------------------------------------------------------------------------------------------------------
ALTER TABLE MODELO_IMPRESSAO_FORM ADD PERMITE_GERACAO VARCHAR2(1 BYTE) DEFAULT 'O';

---------------Tabela de Relacionamento entre o Modelo de Impressão do Formulários com Regras------------------
CREATE TABLE MODELO_FORM_REGRA ( 
  ID                       NUMBER(10) NOT null,
  MODELO_IMPRESSAO_FORM_ID NUMBER(10) NOT NULL,
  REGRA_ID                 NUMBER(10) NOT NULL, 
  FORMULARIO_ID            NUMBER(10) NOT NULL,
constraint PK_MODELO_FORM_REGRA primary key (ID) using index tablespace &CS_TBL_IND,
constraint UK_MODELO_FORM_REGRA_01 unique (FORMULARIO_ID, REGRA_ID, MODELO_IMPRESSAO_FORM_ID) using index tablespace &CS_TBL_IND
) tablespace &CS_TBL_DAT;

create sequence MODELO_FORM_REGRA_SEQ
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache;  
       
COMMENT ON TABLE MODELO_FORM_REGRA 
  IS 'Tabela de Relacionamento entre o Modelo de Impressão do Formulários com Regras';
COMMENT ON COLUMN MODELO_FORM_REGRA.ID 
  IS 'Identificador da Tabela'; 
COMMENT ON COLUMN MODELO_FORM_REGRA.MODELO_IMPRESSAO_FORM_ID 
  IS 'Identificação do Modelo de Impressão do Formulário';
COMMENT ON COLUMN MODELO_FORM_REGRA.REGRA_ID 
  IS 'Identificador do Estado';
COMMENT ON COLUMN MODELO_FORM_REGRA.FORMULARIO_ID 
  IS 'Identificador do Formulario';
       
----------------------------------------------------------------------------------------------------------------------------------
ALTER TABLE COMP_MODELO_IMPRESSAO DROP CONSTRAINT CHK_COMP_MODELO_IMPRESSAO_05;

ALTER TABLE COMP_MODELO_IMPRESSAO DROP CONSTRAINT CHK_COMP_MODELO_IMPRESSAO_01;
ALTER TABLE COMP_MODELO_IMPRESSAO ADD CONSTRAINT CHK_COMP_MODELO_IMPRESSAO_01 
  CHECK (tipo IN ('D', 'L', 'H','V','Z','I'));   

ALTER TABLE COMP_MODELO_IMPRESSAO ADD NOME_ARQUIVO VARCHAR2(255 BYTE);

ALTER TABLE COMP_MODELO_IMPRESSAO ADD FORMA_EXIBICAO VARCHAR2(1 BYTE);

--------------------------------------------------------------------------------------------------------------------
alter table TIPO_DOCUMENTO ADD NRO_VERSOES NUMBER(10,0) DEFAULT 0;

alter table TIPO_DOCUMENTO ADD NRO_MAX_ANEXOS NUMBER(10,0) DEFAULT 0;

ALTER TABLE MODELO_FORM_REGRA ADD CONSTRAINT FK_MODELO_FORM_REGRA_01 
	FOREIGN KEY (MODELO_IMPRESSAO_FORM_ID) REFERENCES MODELO_IMPRESSAO_FORM (ID);  
ALTER TABLE MODELO_FORM_REGRA ADD CONSTRAINT FK_MODELO_FORM_REGRA_02 
	FOREIGN KEY (FORMULARIO_ID,REGRA_ID) REFERENCES REGRA_FORMULARIO (FORMULARIO_ID,REGRA_ID);

--
alter table TRANSICAO_ESTADO add ATIVA_TESTE varchar2(1);
alter table ACAO_CONDICIONAL add TIPO_VALIDACAO varchar2(1);
alter table ACAO_CONDICIONAL add TRANSICAO_ID NUMBER(10);

ALTER TABLE ACAO_CONDICIONAL ADD CONSTRAINT FK_ACAO_CONDICIONAL_09 
  FOREIGN KEY (TRANSICAO_ID) REFERENCES TRANSICAO_ESTADO(TRANSICAO_ESTADO_ID) ON DELETE cascade;

alter table ACAO_CONDICIONAL add PROPRIEDADE_ID NUMBER(10);
ALTER TABLE ACAO_CONDICIONAL ADD CONSTRAINT FK_ACAO_CONDICIONAL_10
  FOREIGN KEY (PROPRIEDADE_ID) REFERENCES REGRAS_PROPRIEDADE(ID) ON DELETE cascade;

alter table ACAO_CONDICIONAL add TIPO_LANCAMENTO_ID NUMBER(10);
ALTER TABLE ACAO_CONDICIONAL ADD CONSTRAINT FK_ACAO_CONDICIONAL_11 
  FOREIGN KEY (TIPO_LANCAMENTO_ID) REFERENCES TIPO_LANCAMENTO(ID) ON DELETE cascade;

alter table ACAO_CONDICIONAL add TIPO_ESCOPO_ID NUMBER(10);
ALTER TABLE ACAO_CONDICIONAL ADD CONSTRAINT FK_ACAO_CONDICIONAL_12 
  FOREIGN KEY (TIPO_ESCOPO_ID) REFERENCES REGRAS_TIPO_ESCOPO(ID) ON DELETE cascade;

alter table ACAO_CONDICIONAL add FILTRO_ESCOPO_ID NUMBER(10);
ALTER TABLE ACAO_CONDICIONAL ADD CONSTRAINT FK_ACAO_CONDICIONAL_13 
  FOREIGN KEY (FILTRO_ESCOPO_ID) REFERENCES FILTRO(ID) ON DELETE cascade;

----------------------

CREATE TABLE REGRAS_VALID_TRANSICAO ( 
  ID                 NUMBER(10) NOT NULL,
  TRANSICAO_ID       NUMBER(10) NOT NULL,
  REGRA_VALIDACAO_ID NUMBER(10),
  TIPO               VARCHAR2(1),
CONSTRAINT PK_REGRAS_VALID_TRANSICAO PRIMARY KEY (ID) using index tablespace &CS_TBL_IND
) tablespace &CS_TBL_DAT;


ALTER TABLE REGRAS_VALID_TRANSICAO ADD CONSTRAINT FK_REGRAS_VALID_TRANSICAO_01 
  FOREIGN KEY (TRANSICAO_ID) REFERENCES TRANSICAO_ESTADO (TRANSICAO_ESTADO_ID) ON DELETE cascade;

ALTER TABLE REGRAS_VALID_TRANSICAO ADD CONSTRAINT FK_REGRAS_VALID_TRANSICAO_02 
  FOREIGN KEY (REGRA_VALIDACAO_ID) REFERENCES REGRAS_VALIDACAO (ID) ON DELETE cascade;
--------------------------

CREATE TABLE USUARIO_AUTORIZADOR ( 
  USUARIO_ID   VARCHAR(50) NOT NULL,
  TRANSICAO_ID NUMBER(10),
CONSTRAINT PK_USUARIO_AUTORIZADOR PRIMARY KEY (ID) using index tablespace &CS_TBL_IND
) tablespace &CS_TBL_DAT;

ALTER TABLE USUARIO_AUTORIZADOR ADD CONSTRAINT FK_USUARIO_AUTORIZADOR_01 
  FOREIGN KEY (USUARIO_ID) REFERENCES USUARIO(USUARIOID) on DELETE cascade;

ALTER TABLE USUARIO_AUTORIZADOR ADD CONSTRAINT FK_USUARIO_AUTORIZADOR_02 
  FOREIGN KEY (TRANSICAO_ID) REFERENCES TRANSICAO_ESTADO(TRANSICAO_ESTADO_ID) ON DELETE cascade;
-------------------

create sequence REGRAS_VALID_TRANSICAO_SEQ
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache;  
create sequence DETALHE_ACAO_CONDIC_SEQ
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache;  
create sequence USUARIO_AUTORIZADOR_SEQ
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache;        

--------------ALTERADO 28-06-2010---------------------

CREATE TABLE DETALHE_ACAO_CONDIC ( 
  ID NUMBER(10)       NOT NULL,
  ACAO_CONDICIONAL_ID NUMBER(10) NOT NULL,
  PAPEL_ID            NUMBER(10),
  TITULO_PAPEL_ID     VARCHAR2(250),
  MODELO_IMPRESSAO_ID NUMBER(10),
  DESCRICAO           VARCHAR2(4000),
  TIPO                number(10),
  PROCEDIMENTO        VARCHAR2(1),
CONSTRAINT PK_DETALHE_ACAO_CONDIC PRIMARY KEY (ID) using index tablespace &CS_TBL_IND
) tablespace &CS_TBL_DAT;

ALTER TABLE DETALHE_ACAO_CONDIC ADD CONSTRAINT FK_DETALHE_ACAO_CONDIC_01 
  FOREIGN KEY (ACAO_CONDICIONAL_ID) REFERENCES ACAO_CONDICIONAL (ID) ON DELETE cascade;

ALTER TABLE DETALHE_ACAO_CONDIC ADD CONSTRAINT FK_DETALHE_ACAO_CONDIC_02 
  FOREIGN KEY (PAPEL_ID) REFERENCES PAPELPROJETO (PAPELPROJETOID) ON DELETE cascade;

ALTER TABLE DETALHE_ACAO_CONDIC ADD CONSTRAINT FK_DETALHE_ACAO_CONDIC_03 
  FOREIGN KEY (MODELO_IMPRESSAO_ID) REFERENCES MODELO_IMPRESSAO_FORM(ID) ON DELETE cascade;

ALTER TABLE acao_condicional drop CONSTRAINT CHK_ACAO_CONDICIONAL_01;
ALTER TABLE acao_condicional add CONSTRAINT CHK_ACAO_CONDICIONAL_01
   CHECK (acao in ('DE','EX','HA','LI','OC','PO','OB','TO', 'PF', 'DS', 'EE', 'GM', 'GB', 'AM', 'VE', 'CO', 'CL', 'CP', 'GD'));

CREATE TABLE LOG_HIST_TRANSICAO ( 
  ID NUMBER(10)  NOT NULL,
  HISTORICO_ID   NUMBER(10) NOT NULL,
  TRANSICAO_ID   NUMBER(10) NOT NULL,  
  LOG_PAI_ID     NUMBER(10),
  REGRA_ID       NUMBER(10),
  PROPRIEDADE_ID NUMBER(10),
  TIPO           VARCHAR2(2),
  VALIDACAO      VARCHAR2(4000),
  RESULTADO      VARCHAR2(100),
  DATA           DATE,
  TESTE          VARCHAR2(1),
  USUARIO_AUTORIZADOR VARCHAR2(1),
CONSTRAINT PK_LOG_HIST_TRANSICAO PRIMARY KEY (ID) using index tablespace &CS_TBL_IND
) tablespace &CS_TBL_DAT;

ALTER TABLE LOG_HIST_TRANSICAO ADD CONSTRAINT FK_LOG_HIST_TRANSICAO_01 
  FOREIGN KEY (HISTORICO_ID) REFERENCES H_DEMANDA(ID) ON DELETE cascade;
ALTER TABLE LOG_HIST_TRANSICAO ADD CONSTRAINT FK_LOG_HIST_TRANSICAO_02 
  FOREIGN KEY (TRANSICAO_ID) REFERENCES TRANSICAO_ESTADO(TRANSICAO_ESTADO_ID) ON DELETE cascade;

ALTER TABLE LOG_HIST_TRANSICAO add CONSTRAINT CHK_LOG_HIST_TRANSICAO_01
  CHECK (TIPO in ('OB', 'IN', 'AC', 'OP', 'CO', 'VA'));

-------------------------------------------------------------------------------

CREATE TABLE LOG_LISTA_HIST_TRANS ( 
  ID NUMBER(10) NOT NULL,
  LOG_PAI_ID NUMBER(10),
  TITULO VARCHAR2(150),
CONSTRAINT PK_LOG_LISTA_HIST_TRANS PRIMARY KEY (ID) using index tablespace &CS_TBL_IND
) tablespace &CS_TBL_DAT;

ALTER TABLE LOG_LISTA_HIST_TRANS ADD CONSTRAINT FK_LOG_LISTA_HIST_TRANS_01 
  FOREIGN KEY (LOG_PAI_ID) REFERENCES LOG_LISTA_HIST_TRANS(ID) ON DELETE cascade;
  
create sequence LOG_HIST_TRANSICAO_SEQ
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache;  
create sequence LOG_LISTA_HIST_TRANS_SEQ
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache;    

-------------------------------------------------------------------------------

insert into relat_componente (ID, TITULO, SIGLA) values ( 1, 'label.prompt.selecionadorPeriodo', 'periodo');
insert into relat_componente (ID, TITULO, SIGLA) values ( 2, 'label.prompt.texto', 'texto');
insert into relat_componente (ID, TITULO, SIGLA) values ( 3, 'label.prompt.formularios', 'formularios');
insert into relat_componente (ID, TITULO, SIGLA) values ( 4, 'label.prompt.tiposDemanda', 'tiposDemanda');
insert into relat_componente (ID, TITULO, SIGLA) values ( 5, 'label.prompt.tiposProjeto', 'tiposProjeto');
insert into relat_componente (ID, TITULO, SIGLA) values ( 6, 'label.prompt.tiposDespesa', 'tiposDespesa');
insert into relat_componente (ID, TITULO, SIGLA) values ( 7, 'label.prompt.tiposTarefa', 'tiposTarefa');
insert into relat_componente (ID, TITULO, SIGLA) values ( 8, 'label.prompt.usuarios', 'usuarios');
insert into relat_componente (ID, TITULO, SIGLA) values ( 9, 'label.prompt.unidadeOrganizacional', 'uo');
insert into relat_componente (ID, TITULO, SIGLA) values (10, 'label.prompt.centroCusto', 'centroCusto');
insert into relat_componente (ID, TITULO, SIGLA) values (11, 'label.prompt.usuarioLogado', 'usuarioLogado');
insert into relat_componente (ID, TITULO, SIGLA) values (12, 'label.prompt.uoUsuarioLogado', 'uoUsuarioLogado');
insert into relat_componente (ID, TITULO, SIGLA) values (13, 'label.prompt.projetoSelecionado', 'projetoSelecionado');
insert into relat_componente (ID, TITULO, SIGLA) values (14, 'label.prompt.destino', 'destino');
insert into relat_componente (ID, TITULO, SIGLA) values (15, 'label.prompt.selecionadorProgramaPortfolioProjeto', 'progPortProjeto');
insert into relat_componente (ID, TITULO, SIGLA) values (16, 'label.prompt.selecionadorDemanda', 'selecionadorDemanda');
insert into relat_componente (ID, TITULO, SIGLA) values (17, 'label.prompt.selecionadorAtividade', 'selecionadorAtiv');
insert into relat_componente (ID, TITULO, SIGLA) values (18, 'label.prompt.selecionadorTarefa', 'selecionadorTarefa');
insert into relat_componente (ID, TITULO, SIGLA) values (19, 'label.prompt.selecionadorIndicador', 'selecionadorInd');
insert into relat_componente (ID, TITULO, SIGLA) values (20, 'label.prompt.selecionadorObjetivo', 'selecionadorObjetivo');
insert into relat_componente (ID, TITULO, SIGLA) values (21, 'label.prompt.selecionadorMapaEstrategico', 'selecionadorMapa');
insert into relat_componente (ID, TITULO, SIGLA) values (22, 'label.prompt.arvoreCustos', 'arvoreCusto');
insert into relat_componente (ID, TITULO, SIGLA) values (23, 'label.prompt.tipoLancamento', 'tipoLancamento');
insert into relat_componente (ID, TITULO, SIGLA) values (24, 'label.prompt.calendario', 'calendario');
insert into relat_componente (ID, TITULO, SIGLA) values (25, 'label.prompt.estadoDemanda', 'estado');
insert into relat_componente (ID, TITULO, SIGLA) values (26, 'label.prompt.estadoEntidade', 'estadoEntidade');
insert into relat_componente (ID, TITULO, SIGLA) values (27, 'label.prompt.data', 'data');
insert into relat_componente (ID, TITULO, SIGLA) values (28, 'label.prompt.numero', 'numero');
insert into relat_componente (ID, TITULO, SIGLA) values (29, 'label.prompt.monetario', 'monetario');

insert into tela (TELAID, NOME, URL, VISIVEL, GRUPOID, ORDEM, CODIGO, SUBGRUPO, ATALHO)
  values (996, 'bd.tela.construtorRelatorios', 'RelatRelatorio.do?command=listagemAction', 'S', 6, 20, 'RELAT_RELATORIO_CADASTRO', 'PRIMEIRO', 'N');
insert into tela (TELAID, NOME, URL, VISIVEL, GRUPOID, ORDEM, CODIGO, SUBGRUPO, ATALHO)
  values (997, 'bd.tela.relatorioDinamico', 'RelatRelatorio.do?command=defaultAction', 'S', 6, 19, 'RELAT_RELATORIO', 'PRIMEIRO', 'N');
  
commit;
/

--
create or replace view v_calendario_dependente as
select nivel, id calendario_id, to_number(substr(path, 2, 11)) calendario_dep_id,
       carga_horaria
  from ( select level nivel, sys_connect_by_path(to_char(nvl(c.id,0), '9999999999'), '&') path,
                c.id, c.carga_horaria
           from calendario c
          where c.tipo = 'B'
            and level > 1
         connect by c.id = prior c.pai_id
         start with c.id is not null
             and c.pai_id is not null)
union
 select 1, id, id, carga_horaria from calendario;
 
--
begin
  update tarefa set datainicio = datarestricao 
  where tiporestricao = 2
  and projeto is not null
  and datarestricao != datainicio;
  commit;

  update tarefa set prazoprevisto = datarestricao
  where tiporestricao = 3
  and projeto is not null
  and datarestricao != prazoprevisto;
  commit;

  update tarefa set datainicio = datarestricao
  where tiporestricao = 4
  and projeto is not null
  and datarestricao != datainicio;
  commit;

  update tarefa set datarestricao = trunc(datarestricao),
                    datainicio = trunc(datainicio)
  where trunc(datarestricao) <> datarestricao
  and tiporestricao = 2;
  commit;

  update tarefa set datarestricao = trunc(datarestricao),
                    prazoprevisto = trunc(prazoprevisto)
  where trunc(datarestricao) <> datarestricao
  and tiporestricao = 3;
  commit;
    
  update tarefa set datarestricao = trunc(datarestricao),
                    datainicio = trunc(datainicio)
  where trunc(datarestricao) <> datarestricao
  and tiporestricao = 4;
  commit;

  update atividade set datarestricao = to_date('01/01/2010','dd/mm/yyyy') where id = 1722;
  commit;

end;
/
--
declare
ln_count_r_cal number;
ln_seq number;
ld_data_ini date;
ld_data_fim date;
ld_data_menor date;
ld_data_maior date;
begin 
     --Seleciona tarefa com data de restrição no sábado ou no domingo
     for tarefa_ in (select * from tarefa 
                     where (to_char(datarestricao, 'd') = 7 
                     or to_char(datarestricao, 'd') = 1) and projeto is not null) loop
                     
          select count(regra_calendario.id) into ln_count_r_cal from regra_calendario 
          where regra_calendario.projeto_id = tarefa_.projeto
          and regra_calendario.periodo = 'U'--Dia útil
          and tarefa_.datarestricao between  regra_calendario.vigencia_inicial and  regra_calendario.vigencia_final;
          
          --Se não existe regra de calendário, configurando dia útil para a restrição
          --cria uma regra para tal.
          if ln_count_r_cal <= 0 then

              select regra_calendario_seq.nextval into ln_seq from dual;
             
             insert into regra_calendario(id, calendario_id, projeto_id, usuario_id, titulo, descricao, periodo,
                                          tipo_periodo_n_util, carga_horaria, frequencia, frequencia_data,
                                          freq_domingo, freq_segunda, freq_terca, freq_quarta, freq_quinta, 
                                          freq_sexta, freq_sabado, vigencia_inicial, vigencia_final)
                                          values(ln_seq, null, tarefa_.projeto, 
                                          null, 'Regra dia útil-final de semana', null, 'U', null,
                                          (select carga_horaria from calendario where projeto_id = tarefa_.projeto ),
                                          'U', null, 'Y','Y','Y','Y','Y','Y','Y', tarefa_.datarestricao, tarefa_.datarestricao);

             --Acabar em                             
             if tarefa_.tiporestricao = 3 and tarefa_.duracao = 1 then
                if tarefa_.datarestricao != tarefa_.datainicio then
                  update tarefa set datainicio = tarefa_.datarestricao where tarefa.id = tarefa_.id;
                end if;  
             end if;                                              
             --Deve iniciar em, Não iniciar antes de
             if tarefa_.tiporestricao = 2 or tarefa_.tiporestricao = 4  then
                if tarefa_.duracao = 1 and tarefa_.datarestricao != tarefa_.prazoprevisto then
                  update tarefa set prazoprevisto = tarefa_.datarestricao where tarefa.id = tarefa_.id;
                end if;  
             end if;                                              

          end if;
     end loop;
     commit;
end;
/ 

--
update tarefa set porcentagemconcluida = 0 where porcentagemconcluida is null;
commit;
/


--
CREATE OR REPLACE FORCE VIEW V_EVOLUCAO_HISTORICA AS
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
    WHERE vdf.dia BETWEEN least(NVL(p.iniciorealizado, to_date('31129999', 'ddmmyyyy')), NVL(p.datainicio, to_date('31129999', 'ddmmyyyy'))) AND greatest(NVL(p.prazorealizado, to_date('01011900', 'ddmmyyyy')), NVL(p.prazoprevisto, to_date('01011900', 'ddmmyyyy')))
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
    WHERE vdf.dia BETWEEN least(NVL(p.iniciorealizado, to_date('31129999', 'ddmmyyyy')), NVL(p.datainicio, to_date('31129999', 'ddmmyyyy'))) AND greatest(NVL(p.prazorealizado, to_date('01011900', 'ddmmyyyy')), NVL(p.prazoprevisto, to_date('01011900', 'ddmmyyyy')))
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
    x.data ;
/

declare
  ln_conta number;
  ln_tela  number;
begin
  select count(1)
    into ln_conta
    from tela
   where nome = 'label.prompt.visaoEstrategica';
   
  if ln_conta = 0 then
    select nvl(max(telaid),0) + 1 into ln_tela from tela;
    insert into tela (telaid, nome, url, visivel, grupoid, ordem, codigo, subgrupo, atalho)
    values (ln_tela, 'label.prompt.visaoEstrategica', 'VisaoEstrategica.do?command=defaultAction',
            'S', 28, 2, 'VISAO_ESTRATEGICA', 'PRIMEIRO', 'N');
  end if;
commit; 
end;
/

create or replace view v_custo_tarefa as
select /*+ ordered */
       t.id, re.responsavel, nvl(vvh.valor_hora,0) VALOR_HORA,
       greatest(t.datainicio, vvh.inicio) INICIO_VALOR,
       least(t.prazoprevisto, vvh.fim) FINAL_VALOR,
       t.datainicio INICIO_TAREFA, t.prazoprevisto FINAL_TAREFA,
       (CASE WHEN (t.prazoprevisto - t.datainicio + 1) > 0 THEN nvl((t.horasprevistas/60) / (t.prazoprevisto - t.datainicio + 1),0) ELSE 0 END) HORAS_POR_DIA,       
       t.projeto PROJETO_ID
  from tarefa              t,
       responsavelentidade re,
       v_valor_hora        vvh
 where re.identidade   = t.id
   and re.tipoentidade = 'T'
   and re.responsavel  = vvh.usuario (+)
   and vvh.fim        >= t.datainicio
   and vvh.inicio     <= t.prazoprevisto;
/

-- Inserts devem ser incluidos no arquivo de dados

insert into PERMISSAO_MAPA_ESTRATEGICO (ID, CODIGO, LABEL, MAPA, PERSPECTIVA, OBJETIVO, INDICADOR, PAPEL)
       values (1, 'VISUALIZA_MAPA', 'label.prompt.visualizarMapa', 'Y', 'N', 'N', 'N', 'N');
insert into PERMISSAO_MAPA_ESTRATEGICO (ID, CODIGO, LABEL, MAPA, PERSPECTIVA, OBJETIVO, INDICADOR, PAPEL)
       values (2, 'EDITAR_MAPA', 'label.prompt.editarMapa', 'Y', 'N', 'N', 'N', 'N');
insert into PERMISSAO_MAPA_ESTRATEGICO (ID, CODIGO, LABEL, MAPA, PERSPECTIVA, OBJETIVO, INDICADOR, PAPEL)
       values (3, 'EDITAR', 'label.prompt.editar', 'N', 'Y', 'N', 'N', 'N');
insert into PERMISSAO_MAPA_ESTRATEGICO (ID, CODIGO, LABEL, MAPA, PERSPECTIVA, OBJETIVO, INDICADOR, PAPEL)
       values (4, 'CRIAR_PERSPECTIVA', 'label.prompt.criarExcluirPerspectiva', 'Y', 'N', 'N', 'N', 'N');
insert into PERMISSAO_MAPA_ESTRATEGICO (ID, CODIGO, LABEL, MAPA, PERSPECTIVA, OBJETIVO, INDICADOR, PAPEL)
       values (5, 'CRIAR_OBJETIVO', 'label.prompt.criarExcluirObjetivo', 'N', 'Y', 'N', 'N', 'N');
insert into PERMISSAO_MAPA_ESTRATEGICO (ID, CODIGO, LABEL, MAPA, PERSPECTIVA, OBJETIVO, INDICADOR, PAPEL)
       values (6, 'CRIAR_OBJETIVO_PROJETO', 'label.prompt.criarExcluirObjetivoProjeto', 'N', 'N', 'N', 'N', 'Y');
insert into PERMISSAO_MAPA_ESTRATEGICO (ID, CODIGO, LABEL, MAPA, PERSPECTIVA, OBJETIVO, INDICADOR, PAPEL)
       values (7, 'EDITAR_BASICO_OBJ', 'label.prompt.editarBasico', 'N', 'N', 'Y', 'N', 'N');
insert into PERMISSAO_MAPA_ESTRATEGICO (ID, CODIGO, LABEL, MAPA, PERSPECTIVA, OBJETIVO, INDICADOR, PAPEL)
       values (8, 'EDITAR_BASICO_IND', 'label.prompt.editarBasico', 'N', 'N', 'N', 'Y', 'N');
insert into PERMISSAO_MAPA_ESTRATEGICO (ID, CODIGO, LABEL, MAPA, PERSPECTIVA, OBJETIVO, INDICADOR, PAPEL)
       values (9, 'EDITAR_AVANCADO_OBJ', 'label.prompt.editarAvancado', 'N', 'N', 'Y', 'N', 'N');
insert into PERMISSAO_MAPA_ESTRATEGICO (ID, CODIGO, LABEL, MAPA, PERSPECTIVA, OBJETIVO, INDICADOR, PAPEL)
       values (10, 'EDITAR_AVANCADO_IND', 'label.prompt.editarAvancado', 'N', 'N', 'N', 'Y', 'N');
insert into PERMISSAO_MAPA_ESTRATEGICO (ID, CODIGO, LABEL, MAPA, PERSPECTIVA, OBJETIVO, INDICADOR, PAPEL)
       values (11, 'CRIAR_FILHO', 'label.prompt.criarExcluirObjetivoFilho', 'N', 'N', 'Y', 'N', 'N');
insert into PERMISSAO_MAPA_ESTRATEGICO (ID, CODIGO, LABEL, MAPA, PERSPECTIVA, OBJETIVO, INDICADOR, PAPEL)
       values (12, 'CRIAR_INDICADOR', 'label.prompt.criarIndicador', 'N', 'N', 'Y', 'N', 'N');
insert into PERMISSAO_MAPA_ESTRATEGICO (ID, CODIGO, LABEL, MAPA, PERSPECTIVA, OBJETIVO, INDICADOR, PAPEL)
       values (13, 'CRIAR_INDICADOR_PROJETO', 'label.prompt.criarIndicadorProjeto', 'N', 'N', 'N', 'N', 'Y');
insert into PERMISSAO_MAPA_ESTRATEGICO (ID, CODIGO, LABEL, MAPA, PERSPECTIVA, OBJETIVO, INDICADOR, PAPEL)
       values (14, 'CRIAR_INDICADOR_TEMPLATE', 'label.prompt.criarIndicadorTemplate', 'N', 'N', 'Y', 'N', 'N');
insert into PERMISSAO_MAPA_ESTRATEGICO (ID, CODIGO, LABEL, MAPA, PERSPECTIVA, OBJETIVO, INDICADOR, PAPEL)
       values (15, 'CRIAR_INDICADOR_PROJETO_TEMPLATE', 'label.prompt.criarIndicadorProjetoTemplate', 'N', 'N', 'N', 'N', 'Y');
insert into PERMISSAO_MAPA_ESTRATEGICO (ID, CODIGO, LABEL, MAPA, PERSPECTIVA, OBJETIVO, INDICADOR, PAPEL)
       values (16, 'EXCLUIR_INDICADOR', 'label.prompt.excluirIndicador', 'N', 'N', 'Y', 'N', 'N');
insert into PERMISSAO_MAPA_ESTRATEGICO (ID, CODIGO, LABEL, MAPA, PERSPECTIVA, OBJETIVO, INDICADOR, PAPEL)
       values (17, 'EXCLUIR_INDICADOR_PROJETO', 'label.prompt.excluirIndicadorProjeto', 'N', 'N', 'N', 'N', 'Y');
insert into PERMISSAO_MAPA_ESTRATEGICO (ID, CODIGO, LABEL, MAPA, PERSPECTIVA, OBJETIVO, INDICADOR, PAPEL)
       values (18, 'ATUALIZAR_ESCORE', 'label.prompt.atualizarEscore', 'N', 'N', 'N', 'Y', 'N');
insert into PERMISSAO_MAPA_ESTRATEGICO (ID, CODIGO, LABEL, MAPA, PERSPECTIVA, OBJETIVO, INDICADOR, PAPEL)
       values (19, 'ALTERAR_ESCORE', 'label.prompt.alterarEscore', 'N', 'N', 'N', 'Y', 'N');
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

------------------------------------------

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
                                   pb_append boolean );
   
                                                     
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
       if c.r_nome_tabela is not null and 
          (c.linha = c.total or 
           c.r_nome_tabela not in ('ATRIBUTO_VALOR','ATRIBUTOENTIDADEVALOR')) then
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
        if pv_tipo = 'OB' or  pv_tipo = 'IF' then
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
    begin
          select log_hist_transicao_seq.nextval into ln_id_log from dual; 
            
          --Cria registro dao operando  
          insert into log_hist_transicao(id,historico_id, transicao_id,log_pai_id, tipo, validacao, resultado, data, regra_id, propriedade_id, teste, usuario_autorizador)
          values(ln_id_log,pn_historico_id, pn_transicao_id, pn_log_pai, 'OP', pv_validacao , pv_resultado, pd_data, null, pn_propriedade, pv_somente_teste, pv_usuario_autorizador);
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
          select tipo into lv_tipo_campo from atributo 
          where atributoid in (select atributo_id from regras_propriedade_niveis r1 
                               where r1.propriedade_id = pn_id_propriedade 
                               and   r1.ordem = (select max(ordem) from regras_propriedade_niveis r2 
                                                 where r2.propriedade_id = r1.propriedade_id));
                                                 
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
                  and   i.tipo_funcao_id = f.id
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
                          ln_retorno := p_salvar_op_log_hist_trans(pn_historico_id,
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
                          ln_retorno := p_salvar_op_log_hist_trans(pn_historico_id,
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
                 
              
             
              
              
                 lv_valor_1 := f_funcao(c.id, c.f1_codigo, 1, pn_demanda_id, pv_usuario_id, pb_salvar_log_hist_trans, ln_log_hist_operando,pn_transicao_id, ln_log_hist_condicao, pd_data_hist, pv_somente_teste, pv_usuario_autorizador);
                 
                 ----Início lógica de gravação de log de histórico de transição.
                 if pb_salvar_log_hist_trans = true then
                       if c.vigente = 'Y' then
                          update log_hist_transicao set resultado = lv_valor_1 where id = ln_log_hist_operando;
                       end if;
                 end if;
                 ----Fim lógica de gravação de log de histórico de transição.
              elsif c.propriedade_id_1 is not null then
                 lv_valor_1 := f_get_valor_propriedade (pn_demanda_id, pv_usuario_id, c.propriedade_id_1 );
                 
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
                                pb_salvar_log_hist_trans, ln_log_hist_operando,pn_transicao_id, ln_log_hist_condicao, pd_data_hist, pv_somente_teste, pv_usuario_autorizador);
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
              else
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
            elsif  rec_acao.acao = 'CP' then
              lv_acao := 'label.prompt.copiarPermissaoPapelProjeto';
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
    lv_usuario_autorizador                       varchar(1);
       
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
      
      for r in (select * from regras_valid_transicao rvt where rvt.transicao_id = pn_transicao_id) loop
      
          if r.tipo = 'O' then
            lv_tipo_regra := 'OB';--obrigatório
          elsif r.tipo = 'I' then
            lv_tipo_regra := 'IN';--Informativo
          end if;  
      
          lv_regra_valida := f_teste_validacao(pn_demanda_id, r.regra_validacao_id, pn_usuario_id, true,
                                               pn_transicao_id, null,lv_tipo_regra, lv_data_hist, lv_somente_teste, lv_usuario_autorizador);

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
      select max(id) into ln_historico from h_demanda where h_demanda.demanda_id = pn_demanda_id;

      if lv_t_regras_OK = true then 
         --Se todas regras ok
          for a in (select * from acao_condicional ac where ac.transicao_id = pn_transicao_id and ac.tipo_validacao = 1 order by ordem asc) loop
             dbms_output.put_line('acao:' || a.id);            
             select * into rec_demanda from demanda where demanda_id = pn_demanda_id;
           
             lv_texto_acao := f_monta_texto_acao(a);
             if pn_somente_testar = 1 then 
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
                                                               ln_gerar_baseline);
                                                  
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
                   p_salvar_acao_log_hist_trans (ln_historico,
                                                 pn_transicao_id,
                                                 lv_texto_acao,
                                                 'r_ok',
                                                 lv_data_hist,
                                                 'N',
                                                 lv_usuario_autorizador);
             end if;                               
             
                                                                                                                           
          end loop;
      elsif lv_t_regras_obrig_apr_inf_NOK = true then
        --Se todas regras obrigatórias ok mas alguma regra informativa não ok.
          for a in (select * from acao_condicional ac where ac.transicao_id = pn_transicao_id and ac.tipo_validacao = 2 order by ordem asc) loop
             dbms_output.put_line('acao:' || a.id); 
             select * into rec_demanda from demanda where demanda_id = pn_demanda_id;

             lv_texto_acao := f_monta_texto_acao(a);
             if pn_somente_testar = 1 then 
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
                                                          ln_gerar_baseline);
                                                          
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
                 p_salvar_acao_log_hist_trans (ln_historico,
                                               pn_transicao_id,
                                                lv_texto_acao,
                                                'r_ok',
                                                lv_data_hist,
                                                'N',
                                                lv_usuario_autorizador);  
             end if;                                                                                                                                                                                           
          end loop;
      elsif lv_t_regras_obrig_OK = false then 
         --Se alguma regra obrigatótia not ok.
          for a in (select * from acao_condicional ac where ac.transicao_id = pn_transicao_id and ac.tipo_validacao = 3 order by ordem asc) loop
             dbms_output.put_line('acao:' || a.id);            
             select * into rec_demanda from demanda where demanda_id = pn_demanda_id;
           
             lv_texto_acao := f_monta_texto_acao(a);
             if pn_somente_testar = 1 then 
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
                                                          ln_gerar_baseline);
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
                 p_salvar_acao_log_hist_trans (ln_historico,
                                               pn_transicao_id,
                                                lv_texto_acao,
                                                'r_ok',
                                                lv_data_hist,
                                                'N',
                                                lv_usuario_autorizador); 
              end if;                                                                                                                                                                 
           end loop;
      end if;
      
      if pn_usuario_autorizador = 1 then
        --Se a transição foi forçada por um usuário autorizador.
        for a in (select * from acao_condicional ac where ac.transicao_id = pn_transicao_id and ac.tipo_validacao = 4 order by ordem asc) loop
        
             dbms_output.put_line('acao:' || a.id);            
             select * into rec_demanda from demanda where demanda_id = pn_demanda_id;
           
             lv_texto_acao := f_monta_texto_acao(a);
             if pn_somente_testar = 1 then 
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
                                                          ln_gerar_baseline);
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
                 p_salvar_acao_log_hist_trans (ln_historico,
                                               pn_transicao_id,
                                                lv_texto_acao,
                                                'r_ok',
                                                lv_data_hist,
                                                'N',
                                                lv_usuario_autorizador); 
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

         elsif pck_atributo.Tipo_TEXTO = rec_atributo.tipo then
                
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
   begin
				--Internamente, somente ações de preencher valor deve ser executado.
        if 'GB' = upper(acao.acao) then
           pn_gerar_baseline := acao.id;
        elsif 'GM' = upper(acao.acao) then
           if substr(acao.valor_troca,1,2) <> 'TL' then
              pn_enviar_email := acao.id;
           end if;
        elsif 'EE' = upper(acao.acao) then
           pn_estado_id := acao.valor_troca;
        elsif 'AM' = upper(acao.acao) then
           p_AcumulaMensagem(rec_demanda, pprojetos, acao, pn_estado_mensagem_id);
        elsif 'PO' = upper(acao.acao) or 'PF' = upper(acao.acao) or 'CO' = upper(acao.acao) or 'AP' = upper(acao.acao) then
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
                 lv_formula := replace(UPPER(lv_formula), '[ATRIBUTO_'||c.tipo||'_'||c.atributo_id||']', lv_valor);
              end loop;
              
              lv_formula := pck_geral.f_insere_zeroisnull(lv_formula);
              
              lv_select := 'select trunc('||lv_formula||',2) from dual';

              begin 
                 open lc_calculo for lv_select;
                 fetch lc_calculo into ln_total;
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
           
           if acao.propriedade_id is not null then
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
              pck_regras.p_copia_propriedade(rec_demanda.demanda_id,
                                             pv_usuario,
                                             ln_propriedade_id,
                                             lv_valor_troca,
                                             acao.propriedade_id,
                                             acao.acao='AP');
           elsif acao.secao_atributo_id is not null then
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
             pck_regras.p_copia_propriedade(rec_demanda.demanda_id,
                                            pv_usuario,
                                            null,
                                            null,
                                            acao.propriedade_id,
                                            false);
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


-------------------------------------------------------------------------------
-- Finalização
-------------------------------------------------------------------------------
begin
  pck_processo.pRecompila;
  commit;
end;
/

insert into versao(id, titulo, patch, versao_tgp_id, comentario)
       values (versao_seq.nextval, '6.0.0', '04', 3, 'Aplicação de patch');
commit;
/
                    
select * from v_versao;
/
      
       





