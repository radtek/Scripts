/******************************************************************************\
* TraceGP 6.0.0.01                                                             *
\******************************************************************************/

define CS_TBL_DAT = &TABLESPACE_DADOS;
define CS_TBL_IND = &TABLESPACE_INDICES;
--------------------------------------------------------------------------------

alter table mapa_indicador_questao_resp add APURACAO_ID number(10);
alter table mapa_indicador_questao_resp add constraint FK_MAPA_IND_QUESTAO_RESP
  foreign key (apuracao_id) references mapa_indicador_apuracao(id) on delete cascade;
  
create or replace view v_objetivos_indicadores_resumo as
select mi.id id, 'I' TIPO, indicador_template ,mi.entidade_id ENTIDADE_ID, mi.tipo_entidade TIPO_ENTIDADE,
       mi.objetivo_pai OBJETIVO_PAI, mi.titulo TITULO, mi.validade VALIDADE,
       mia.data_apuracao DATA_APURACAO, mia.data_atualizacao DATA_ATUALIZACAO,
       mia.situacao ESTADO, mm.comentario COMENTARIO, mm.valor VALOR_META,
       mi.unidade UNIDADE, mia.escore ESCORE, mia.escore - mm.valor DIFERENCA,
       decode(mm.valor, 0, to_number(null), (mia.escore - mm.valor) / mm.valor) DIF_PERC,
       decode(mm.valor, 0, to_number(null), mia.escore / mm.valor) PERC_META_ATING,
       mmf.cor COR, mi.descricao DESCRICAO
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
       mof.cor COR, mo.descricao DESCRICAO
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
create or replace view v_objetivos_resumo as
select * from v_objetivos_indicadores_resumo
where tipo = 'O';
/
create or replace view v_indicadores_resumo as
select * from v_objetivos_indicadores_resumo
where tipo = 'I';
/
create or replace view v_sla_atual as
select f.demanda_id, f.tipo_sla, f.estado_sla_id
from demanda_sla_final f
where 'P' = f.tipo_sla
and   f.demanda_id = f.demanda_id 
union all
select f2.demanda_id, f2.tipo_sla, f2.estado_sla_id
from demanda_faixas_sla f2
where   sysdate >= inicio
and   sysdate < fim;
/
create or replace view v_centro_custo_entidade as
select cc."ID",cc."TITULO",cc."PARENT_ID",cc."VIGENTE",cc."TIPO", cce.tipoentidade, cce.identidade, cce.influencia
from centro_custo_entidade cce, centro_custo cc
where cce.centrocustoid = cc.id;
/
create or replace view v_escopo as
select projeto, 
       dbms_lob.substr(descproduto,4000) descproduto,
       dbms_lob.substr(justificativaprojeto,4000) justificativaprojeto,
       dbms_lob.substr(objetivosprojeto,4000) objetivosprojeto,
       dbms_lob.substr(limitesprojeto,4000) limitesprojeto,
       dbms_lob.substr(listafatoresessenciais,4000) listafatoresessenciais,
       case when fechado in ('Y','S') then 'Y'
            else 'N' end fechado
from escopo;
/

------------------------------------------------------------------------------------------------------------------------------
-- Create table
create global temporary table REGRAS_LISTA_TEMP (
  ID_LISTA NUMBER(10) not null,
  ITEM     NUMBER(10) not null,
  VALOR    VARCHAR2(4000),
constraint PK_REGRAS_LISTA_TEMP primary key (ID_LISTA, ITEM)
) on commit delete rows;

-- Create table
create table REGRAS_TIPO_AGRUPADOR (
  ID     NUMBER(10)   not null,
  CODIGO VARCHAR2(30) not null,
constraint PK_REGRAS_TIPO_AGRUPADOR primary key (id) using index tablespace &CS_TBL_IND,
constraint UK_REGRAS_TIPO_AGRUPADOR unique (codigo)
) tablespace &CS_TBL_DAT;

-- Add comments to the columns 
comment on column REGRAS_TIPO_AGRUPADOR.ID
  is 'Id';
comment on column REGRAS_TIPO_AGRUPADOR.CODIGO
  is 'Codigo que identifica o operador';
  
-- Create table
create table REGRAS_TIPO_ENTIDADE (
  TITULO             VARCHAR2(40)  not null,
  NOME_TABELA        VARCHAR2(100) default 'DEMANDA' not null,
  COLUNA_PK          VARCHAR2(50)  default 'ID' not null,
  ID                 NUMBER(10)    not null,
  COLUNA_ATRIBUTO_ID VARCHAR2(50),
  TIPO_ENTIDADE      varchar2(1),
constraint PK_REGRAS_TIPO_ENTIDADE primary key (id) using index tablespace &CS_TBL_IND
) tablespace &CS_TBL_DAT;

-- Add comments to the columns 
comment on column REGRAS_TIPO_ENTIDADE.TITULO
  is 'Nome do tipo de entidade';
comment on column REGRAS_TIPO_ENTIDADE.NOME_TABELA
  is 'Nome da tabela do tipo da entidade';
comment on column REGRAS_TIPO_ENTIDADE.COLUNA_PK
  is 'Nome da coluna PK';
comment on column REGRAS_TIPO_ENTIDADE.COLUNA_ATRIBUTO_ID
  is 'Nome da coluna que contem o id do atributo';
  
-- Create table
create table REGRAS_TIPO_VALOR (
  ID     NUMBER(10)   not null,
  CODIGO VARCHAR2(30) not null,
  TITULO VARCHAR2(40) not null,
constraint PK_REGRAS_TIPO_VALOR primary key (id) using index tablespace &CS_TBL_IND,
constraint UK_REGRAS_TIPO_VALOR_01 unique (codigo) using index tablespace &CS_TBL_IND
) tablespace &CS_TBL_DAT;

-- Add comments to the columns 
comment on column REGRAS_TIPO_VALOR.ID
  is 'Id';
comment on column REGRAS_TIPO_VALOR.CODIGO
  is 'Codigo que indica o tipo';
comment on column REGRAS_TIPO_VALOR.TITULO
  is 'Nome do tipo';
  
-- Create table
create table REGRAS_TIPO_ESCOPO (
  ID               NUMBER(10)    not null,
  CODIGO           VARCHAR2(50)  not null,
  TITULO           VARCHAR2(400) not null,
  TIPO_ENTIDADE_ID NUMBER(10)    not null,
constraint PK_REGRAS_TIPO_ESCOPO primary key (id) using index tablespace &CS_TBL_IND,
constraint UK_REGRAS_TIPO_ESCOPO_01 unique (codigo) using index tablespace &CS_TBL_IND
)tablespace &CS_TBL_DAT;

-- Add comments to the columns 
comment on column REGRAS_TIPO_ESCOPO.ID
  is 'Id';
comment on column REGRAS_TIPO_ESCOPO.CODIGO
  is 'Identifica o tipo de escopo';
comment on column REGRAS_TIPO_ESCOPO.TITULO
  is 'Descrição do tipo de escopo';
comment on column REGRAS_TIPO_ESCOPO.TIPO_ENTIDADE_ID
  is 'Tipo de entidade relacionada';
  
alter table REGRAS_TIPO_ESCOPO add constraint FK_REGRAS_TIPO_ESCOPO_01 
  foreign key (TIPO_ENTIDADE_ID) references REGRAS_TIPO_ENTIDADE (ID);

-- Create table
create table REGRAS_TIPO_FUNCAO (
  ID     NUMBER(10)   not null,
  CODIGO VARCHAR2(20) not null,
constraint PK_REGRAS_TIPO_FUNCAO primary key (ID) using index tablespace &CS_TBL_IND,
constraint UK_REGRAS_TIPO_FUNCAO_01 unique (codigo) using index tablespace &CS_TBL_IND
)tablespace &CS_TBL_DAT;

-- Create table
create table REGRAS_TIPO_OPERADOR (
  ID     NUMBER(10)   not null,
  CODIGO VARCHAR2(30) not null,
  TITULO VARCHAR2(30) default ' ' not null,
constraint PK_REGRAS_TIPO_OPERADOR primary key (ID) using index tablespace &CS_TBL_IND,
constraint UK_REGRAS_TIPO_OPERADOR_01 unique (CODIGO) using index tablespace &CS_TBL_IND
)tablespace &CS_TBL_DAT;

-- Add comments to the columns 
comment on column REGRAS_TIPO_OPERADOR.ID
  is 'Id';
comment on column REGRAS_TIPO_OPERADOR.CODIGO
  is 'Codigo que identifica o operador';

-- Create table
create table REGRAS_TIPO_OPERADOR_VAL (
  ID               NUMBER(10) not null,
  TIPO_VALOR_ID_1  NUMBER(10) not null,
  TIPO_VALOR_ID_2  NUMBER(10) not null,
  TIPO_OPERADOR_ID NUMBER(10) not null,
constraint PK_REGRAS_TIPO_OPERADOR_VAL primary key (ID) using index tablespace &CS_TBL_IND
)tablespace &CS_TBL_DAT;

-- Add comments to the columns 
comment on column REGRAS_TIPO_OPERADOR_VAL.ID
  is 'Id';
comment on column REGRAS_TIPO_OPERADOR_VAL.TIPO_VALOR_ID_1
  is 'Tipo do operando que fica a esquerda';
comment on column REGRAS_TIPO_OPERADOR_VAL.TIPO_VALOR_ID_2
  is 'Tipo do operando que fica a direita';
comment on column REGRAS_TIPO_OPERADOR_VAL.TIPO_OPERADOR_ID
  is 'operador';

alter table REGRAS_TIPO_OPERADOR_VAL add constraint FK_REGRAS_TIPO_OPERADOR_VAL_01 
  foreign key (TIPO_VALOR_ID_1) references REGRAS_TIPO_VALOR (ID);
alter table REGRAS_TIPO_OPERADOR_VAL add constraint FK_REGRAS_TIPO_OPERADOR_VAL_02 
  foreign key (TIPO_VALOR_ID_2) references REGRAS_TIPO_VALOR (ID);
alter table REGRAS_TIPO_OPERADOR_VAL add constraint FK_REGRAS_TIPO_OPERADOR_VAL_03
 foreign key (TIPO_OPERADOR_ID) references REGRAS_TIPO_OPERADOR (ID);

-- Create table
create table REGRAS_TIPO_AGRUPADOR_VALOR (
  ID                NUMBER(10) not null,
  TIPO_AGRUPADOR_ID NUMBER(10) not null,
  TIPO_VALOR_ID     NUMBER(10) not null,
constraint PK_REGRAS_TIPO_AGRUPADOR_VALOR primary key (ID) using index tablespace &CS_TBL_IND,
constraint UK_REGRAS_TIPO_AGRUP_VALOR_01 unique (TIPO_AGRUPADOR_ID, TIPO_VALOR_ID) using index tablespace &CS_TBL_IND
)tablespace &CS_TBL_DAT;
-- Add comments to the columns 
comment on column REGRAS_TIPO_AGRUPADOR_VALOR.ID
  is 'Id';
comment on column REGRAS_TIPO_AGRUPADOR_VALOR.TIPO_AGRUPADOR_ID
  is 'Agrupador';
comment on column REGRAS_TIPO_AGRUPADOR_VALOR.TIPO_VALOR_ID
  is 'Tipo de valor';


alter table REGRAS_TIPO_AGRUPADOR_VALOR add constraint FK_REGRAS_TIPO_AGRUP_VALOR_01 
  foreign key (TIPO_AGRUPADOR_ID) references REGRAS_TIPO_AGRUPADOR (ID);
alter table REGRAS_TIPO_AGRUPADOR_VALOR add constraint FK_REGRAS_TIPO_AGRUP_VALOR_02 
  foreign key (TIPO_VALOR_ID) references REGRAS_TIPO_VALOR (ID);

-- Create table
create table REGRAS_TIPO_PROPRIEDADE (
  ID                   NUMBER(10)    not null,
  TITULO               VARCHAR2(100) not null,
  COLUNA               VARCHAR2(100),
  TIPO_VALOR_ID        NUMBER(10),
  VIGENTE              VARCHAR2(1)   default 'N' not null,
  WHERE_JOIN           VARCHAR2(4000),
  TIPO_ENTIDADE_ID     NUMBER(10)    not null,
  REF_TIPO_ENTIDADE_ID NUMBER(10),
constraint PK_TIPO_PROPRIEDADE primary key (ID) using index tablespace &CS_TBL_IND
)tablespace &CS_TBL_DAT;
-- Add comments to the columns 
comment on column REGRAS_TIPO_PROPRIEDADE.ID
  is 'Id';
comment on column REGRAS_TIPO_PROPRIEDADE.TITULO
  is 'String que identifica o elemento';
comment on column REGRAS_TIPO_PROPRIEDADE.COLUNA
  is 'Nome da coluna da tabela que contem a informacao';
comment on column REGRAS_TIPO_PROPRIEDADE.TIPO_VALOR_ID
  is 'Tipo da informacao';
comment on column REGRAS_TIPO_PROPRIEDADE.VIGENTE
  is 'Tipo de propriedade disponivel';
comment on column REGRAS_TIPO_PROPRIEDADE.WHERE_JOIN
  is 'Clausula where para relacionar a entidade pai com a entidade referenciada pela propriedade. Substituir [ENTIDADE-PAI] pela entidade que contem a propriedade e [ENTIDADE-FILHA] pela entidade referenciada';

alter table REGRAS_TIPO_PROPRIEDADE add constraint FK_TIPO_PROPRIEDADE_01 
  foreign key (TIPO_VALOR_ID) references REGRAS_TIPO_VALOR (ID);
alter table REGRAS_TIPO_PROPRIEDADE add constraint FK_TIPO_PROPRIEDADE_02 
  foreign key (TIPO_ENTIDADE_ID) references REGRAS_TIPO_ENTIDADE (ID);
alter table REGRAS_TIPO_PROPRIEDADE add constraint FK_TIPO_PROPRIEDADE_03 
  foreign key (REF_TIPO_ENTIDADE_ID)references REGRAS_TIPO_ENTIDADE (ID);

-- Create table
create table REGRAS_PROPRIEDADE (
  ID           NUMBER(10)    not null,
  AGRUPADOR_ID NUMBER(10)    not null,
  TITULO       VARCHAR2(100) not null,
  ESCOPO_ID    NUMBER(10)    not null,
  WHERE_FILTRO VARCHAR2(4000),
  FILTRO_ID    NUMBER(10),
constraint PK_REGRAS_PROPRIEDADE primary key (ID) using index tablespace &CS_TBL_IND,
constraint CHK_REGRAS_PROPRIEDADE_01 check ((where_filtro is not null and filtro_id is not null) 
                                         or (where_filtro is null and filtro_id is null))
)tablespace &CS_TBL_DAT;
-- Add comments to the columns 
comment on column REGRAS_PROPRIEDADE.ID
  is 'Id';
comment on column REGRAS_PROPRIEDADE.AGRUPADOR_ID
  is 'Tipo de agrupamento';
comment on column REGRAS_PROPRIEDADE.TITULO
  is 'Titulo';
comment on column REGRAS_PROPRIEDADE.ESCOPO_ID
  is 'Tipo de escopo da busca';
comment on column REGRAS_PROPRIEDADE.WHERE_FILTRO
  is 'Clausula where gerada com base no filtro referenciado';
comment on column REGRAS_PROPRIEDADE.FILTRO_ID
  is 'Filtro referenciado';
  
alter table REGRAS_PROPRIEDADE add constraint FK_REGRAS_PROPRIEDADE_01 
  foreign key (FILTRO_ID) references FILTRO (ID);
alter table REGRAS_PROPRIEDADE add constraint FK_REGRAS_PROPRIEDADE_02 
  foreign key (AGRUPADOR_ID) references REGRAS_TIPO_AGRUPADOR (ID);
alter table REGRAS_PROPRIEDADE add constraint FK_REGRAS_PROPRIEDADE_03 
  foreign key (ESCOPO_ID) references REGRAS_TIPO_ESCOPO (ID);


-- Create table
create table REGRAS_PROPRIEDADE_NIVEIS (
  ID                  NUMBER(10) not null,
  PROPRIEDADE_ID      NUMBER(10) not null,
  TIPO_PROPRIEDADE_ID NUMBER(10) null,
  ORDEM               NUMBER(1)  not null,
  ATRIBUTO_ID         NUMBER(10),
  WHERE_FILTRO        VARCHAR2(4000),
  FILTRO_ID           NUMBER(10),
constraint PK_REGRAS_PROPRIEDADE_NIVEIS primary key (ID) using index tablespace &CS_TBL_IND,
constraint CHK_REGRAS_PROP_NIVEIS_01 check ((where_filtro is not null and filtro_id is not null) 
                                         or (where_filtro is null and filtro_id is null))
) tablespace &CS_TBL_DAT;
-- Add comments to the columns 
comment on column REGRAS_PROPRIEDADE_NIVEIS.ID
  is 'Id';
comment on column REGRAS_PROPRIEDADE_NIVEIS.PROPRIEDADE_ID
  is 'Propriedade que e definida pelos niveis de tipos de propriedade';
comment on column REGRAS_PROPRIEDADE_NIVEIS.TIPO_PROPRIEDADE_ID
  is 'Tipo de Propriedade';
comment on column REGRAS_PROPRIEDADE_NIVEIS.ORDEM
  is 'Sequencia de formacao da propriedade';
comment on column REGRAS_PROPRIEDADE_NIVEIS.ATRIBUTO_ID
  is 'Id do Atributo vinculado';
comment on column REGRAS_PROPRIEDADE_NIVEIS.WHERE_FILTRO
  is 'Filtro do nivel';
comment on column REGRAS_PROPRIEDADE_NIVEIS.FILTRO_ID
  is 'Id do filtro';

alter table REGRAS_PROPRIEDADE_NIVEIS add constraint FK_REGRAS_PROP_NIVEIS_01 
  foreign key (PROPRIEDADE_ID) references REGRAS_PROPRIEDADE (ID);
alter table REGRAS_PROPRIEDADE_NIVEIS add constraint FK_REGRAS_PROP_NIVEIS_02 
  foreign key (TIPO_PROPRIEDADE_ID) references REGRAS_TIPO_PROPRIEDADE (ID);
alter table REGRAS_PROPRIEDADE_NIVEIS add constraint FK_REGRAS_PROP_NIVEIS_03 
  foreign key (ATRIBUTO_ID) references ATRIBUTO (ATRIBUTOID);
alter table REGRAS_PROPRIEDADE_NIVEIS add constraint FK_REGRAS_PROP_NIVEIS_04 
  foreign key (FILTRO_ID) references FILTRO (ID);

-- Create table
create table REGRAS_PROP_NIVEL_ITEM (
  ID                  NUMBER(10) not null,
  ORDEM               NUMBER(2) not null,
  TIPO_PROPRIEDADE_ID NUMBER(10),
  ATRIBUTO_ID         NUMBER(10),
  TEXTO               VARCHAR2(4000),
  NIVEL_ID            NUMBER(10) not null,
constraint PK_REGRAS_PROP_NIVEL_ITEM primary key (ID),
constraint UK_REGRAS_PROP_NIVEL_ITEM unique (NIVEL_ID, ORDEM),
constraint CHK_REGRAS_PROP_NIVEL_ITEM_01 check ((tipo_propriedade_id is null and atributo_id is null and texto is not null) 
                                             or (tipo_propriedade_id is not null and texto is null))
) tablespace &CS_TBL_DAT;

alter table REGRAS_PROP_NIVEL_ITEM add constraint FK_REGRAS_PROP_NIVEL_ITEM_01 
  foreign key (TIPO_PROPRIEDADE_ID) references REGRAS_TIPO_PROPRIEDADE (ID);
alter table REGRAS_PROP_NIVEL_ITEM add constraint FK_REGRAS_PROP_NIVEL_ITEM_02
 foreign key (ATRIBUTO_ID) references ATRIBUTO (ATRIBUTOID);
alter table REGRAS_PROP_NIVEL_ITEM  add constraint FK_REGRAS_PROP_NIVEL_ITEM_03
 foreign key (NIVEL_ID) references REGRAS_PROPRIEDADE_NIVEIS (ID);

-- Add/modify columns 
alter table REGRAS_TIPO_ENTIDADE add tipo_entidade varchar2(1) default '-' not null;
-- Add comments to the columns 
comment on column REGRAS_TIPO_ENTIDADE.tipo_entidade
  is 'Informar o caractere que identifica o tipo de entidade no sistema Projeto Demanda Tarefa...';
  
-- Add/modify columns 
alter table REGRAS_PROP_NIVEL_ITEM modify TIPO_PROPRIEDADE_ID not null;
-- Drop check constraints 
alter table REGRAS_PROP_NIVEL_ITEM
  drop constraint CHK_REGRAS_PROP_NIVEL_ITEM_01;  
  
CREATE SEQUENCE REGRAS_PROPRIEDADE_SEQ START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE REGRAS_PROPRIEDADE_NIVEIS_SEQ START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE REGRAS_PROP_NIVEL_ITEM_SEQ START WITH 1 INCREMENT BY 1 NOCACHE;

create or replace
PACKAGE PCK_CONHECIMENTO_PROFISSIONAL as
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

create table log_tracegp(
  id number(10) not null,
  nome_metodo varchar2(250),
  argumentos_Metodo varchar2(2000),
  data date not null,
  nome_class varchar2(250),
  message varchar2(2000),
  exception_class varchar2(500),
  stacktrace varchar2(2000),
  message_cause varchar2(2000),
  exception_class_cause varchar2(250),
  stacktrace_cause varchar2(2000),
  versao_tracegp varchar2(50),
  enviado varchar2(1),
  constraint pk_log_tracegp primary key (id) using index tablespace &CS_TBL_IND 
);

create sequence log_tracegp_seq increment by 1     
 start with 1 maxvalue 9999999999 minvalue 1 nocache; 
 
create or replace package PCK_CALENDARIO is
  type t_cursor is ref cursor;
  function f_cria_calendario_projeto (pn_projeto_id number, pn_calendario_id number) return number;
  
end PCK_CALENDARIO;
/

create or replace package body PCK_CALENDARIO is

  function f_cria_calendario_projeto (pn_projeto_id number, pn_calendario_id number) return number is
    ln_conta          number;
    ln_cal_projeto_id number;
    ln_carga          number;
    lb_continua       boolean;
    lb_fim_existe     boolean;
    ld_inicio         date;
    ld_fim            date;
    ld_aplica_ant     date;
    ld_aplica         date;
    ld_existe_regra   date;
    c_aplica          t_cursor;
    c_existe_regra    t_cursor;
    
    begin 
      -- Encerra caso projeto ja possua calendario
      select count(1)
        into ln_conta
        from calendario
       where projeto_id = pn_projeto_id
         and tipo       = 'P';
      if ln_conta > 0 then
        pck_versao.p_log_versao('E', '[pck_calendario|f_cria_calendario_projeto] Projeto ' 
                                || pn_projeto_id  || ' já possui calendário');
        return null;
      end if;
               
      -- Gera ID para calendario
      select calendario_seq.nextval into ln_cal_projeto_id from dual;
      
      -- Busca carga horária para calendário do projeto
      ln_carga := 0;
      for cal in (select id, level, carga_horaria 
                    from calendario 
                  connect by prior pai_id = id
                  start with id = pn_calendario_id) loop
        if nvl(cal.carga_horaria,0) > 0 then
          ln_carga := cal.carga_horaria;
        end if;
      end loop;
      if ln_carga = 0 then
        pck_versao.p_log_versao('E', '[pck_calendario|f_cria_calendario_projeto] ' || 
                                'Não é possível criar calendário de projeto com carga horária 0 (zero)');                       
        return null;
      end if;
      
      -- Cria registro na tabela 
      begin
        insert into calendario (id, titulo, pai_id, projeto_id, vigente, carga_horaria, tipo)
               values (ln_cal_projeto_id, 'Calendário do projeto ' || pn_projeto_id, null,
                       pn_projeto_id, 'Y', ln_carga, 'P');
      exception 
        when others then
          pck_versao.p_log_versao('E', '[pck_calendario|f_cria_calendario_projeto] ' || 
                                  'Erro ao criar calendário para o projeto: ' || sqlerrm);                     
          return null;
      end;
      
      -- Cria regras
      for cal in (select id, level nivel, carga_horaria 
                    from calendario 
                  connect by prior pai_id = id
                  start with id = pn_calendario_id) loop
        if cal.nivel = 1 then
          -- Copia diretamente regras desse nível
          insert into regra_calendario (id, calendario_id, projeto_id, usuario_id, titulo, descricao, 
                                        periodo, tipo_periodo_n_util, carga_horaria, frequencia,
                                        frequencia_data, frequencia_numero, freq_domingo, freq_segunda,
                                        freq_terca, freq_quarta, freq_quinta, freq_sexta, freq_sabado,
                                        vigencia_inicial, vigencia_final)
                 select regra_calendario_seq.nextval, ln_cal_projeto_id, pn_projeto_id, null,
                        titulo, descricao, periodo, tipo_periodo_n_util, carga_horaria, frequencia,
                        frequencia_data, frequencia_numero, freq_domingo, freq_segunda, freq_terca,
                        freq_quarta, freq_quinta, freq_sexta, freq_sabado, vigencia_inicial, vigencia_final
                   from regra_calendario
                  where calendario_id = cal.id
                    and projeto_id    is null
                    and usuario_id    is null;
        else   
          -- Trata demais níveis
          for regra in (select * 
                          from regra_calendario 
                         where calendario_id = cal.id
                        order by decode(frequencia, 'U', 1, 'A', 2, 'M', 3, 'S', 4, 5) ) loop
            -- Verifica períodos para criação da regra
            open c_aplica for select data
                                from v_regra_calendario_detalhe
                               where id = regra.id
                              order by data;
                              
            open c_existe_regra for select data
                                      from v_regra_calendario_projeto
                                     where projeto_id = pn_projeto_id
                                    order by data;
            
            fetch c_aplica into ld_aplica;
            if (c_aplica%notfound) then
              lb_continua := false;

            end if;
            fetch c_existe_regra into ld_existe_regra;
                   
            lb_continua   := true;
            lb_fim_existe := false;
            ld_inicio     := null;
            ld_aplica_ant := null;
            
           while (lb_continua) loop
              
              ld_aplica_ant := ld_aplica;  
              
              if ld_aplica < ld_existe_regra and ld_inicio is null then
                ld_inicio := ld_aplica;
                fetch c_aplica into ld_aplica;
                if (c_aplica%notfound) then
                  lb_continua := false;
                end if;
                
              elsif ld_aplica < ld_existe_regra and ld_inicio is not null then
                fetch c_aplica into ld_aplica;
                if (c_aplica%notfound) then
                  lb_continua := false;
                end if;
                
              elsif ld_aplica = ld_existe_regra and ld_inicio is not null then
                ld_fim := ld_existe_regra - 1;
                -- Grava regra
                insert into regra_calendario (id, calendario_id, projeto_id, usuario_id, titulo, descricao, 
                                              periodo, tipo_periodo_n_util, carga_horaria, frequencia,
                                              frequencia_data, frequencia_numero, freq_domingo, freq_segunda,
                                              freq_terca, freq_quarta, freq_quinta, freq_sexta, freq_sabado,
                                              vigencia_inicial, vigencia_final)
                       select regra_calendario_seq.nextval, ln_cal_projeto_id, pn_projeto_id, null,
                              titulo, descricao, periodo, tipo_periodo_n_util, carga_horaria, frequencia,
                              frequencia_data, frequencia_numero, freq_domingo, freq_segunda, freq_terca,
                              freq_quarta, freq_quinta, freq_sexta, freq_sabado, ld_inicio, ld_fim
                         from regra_calendario
                        where id = regra.id; 
                        
                ld_inicio := null;
                fetch c_aplica into ld_aplica;
                if (c_aplica%notfound) then
                  lb_continua := false;
                end if;
                if not lb_fim_existe then
                  fetch c_existe_regra into ld_existe_regra;
                  if (c_existe_regra%notfound) then
                    lb_fim_existe := true;
                  end if;
                end if;
                
              elsif ld_aplica > ld_existe_regra then 
                if not lb_fim_existe then
                  fetch c_existe_regra into ld_existe_regra; 
                  if (c_existe_regra%notfound) then
                    lb_fim_existe := true;
                  end if; 
                else
                  fetch c_aplica into ld_aplica;
                  if (c_aplica%notfound) then
                    lb_continua := false;
                  end if;     
                end if;  
                
              else
                fetch c_aplica into ld_aplica;
                if (c_aplica%notfound) then
                  lb_continua := false;
                end if;
                if not lb_fim_existe then
                  fetch c_existe_regra into ld_existe_regra;
                  if (c_existe_regra%notfound) then
                    lb_fim_existe := true;
                  end if;
                end if;
                       
              end if;
              
            end loop;
            
            close c_aplica;
            close c_existe_regra;
            
            if ld_inicio is not null then
              -- Ultimo registro
              insert into regra_calendario (id, calendario_id, projeto_id, usuario_id, titulo, descricao, 
                                            periodo, tipo_periodo_n_util, carga_horaria, frequencia,
                                            frequencia_data, frequencia_numero, freq_domingo, freq_segunda,
                                            freq_terca, freq_quarta, freq_quinta, freq_sexta, freq_sabado,
                                            vigencia_inicial, vigencia_final)
                     select regra_calendario_seq.nextval, ln_cal_projeto_id, pn_projeto_id, null,
                            titulo, descricao, periodo, tipo_periodo_n_util, carga_horaria, frequencia,
                            frequencia_data, frequencia_numero, freq_domingo, freq_segunda, freq_terca,
                            freq_quarta, freq_quinta, freq_sexta, freq_sabado, ld_inicio, ld_aplica_ant
                       from regra_calendario
                      where id = regra.id; 
            end if;
          
          end loop;
        end if;
      end loop;
    return ln_cal_projeto_id;
    exception
      when others then
         pck_versao.p_log_versao('E', '[pck_calendario|f_cria_calendario_projeto] ' || sqlerrm);
         begin close c_aplica; exception when others then null; end;
         begin close c_existe_regra; exception when others then null; end;
         return null;
    end f_cria_calendario_projeto;  
end PCK_CALENDARIO;
/

begin
   pck_processo.precompila;
   commit;
end;
/

create or replace view v_distribuicao_usuario as
select vcr.usuario_id, vcr.data, sum(vcr.carga_horaria) distribuicao
  from v_calendario_recurso vcr
group by vcr.usuario_id, vcr.data;

create or replace view v_distribuicao_usuario_prj as
select vcr.usuario_id, vcr.data, vcr.projeto_id, vcr.carga_horaria distribuicao
  from v_calendario_recurso vcr;
  
create or replace view v_calendario_projeto_sr as
select vd.dia data, 
       decode(to_char(vd.dia, 'd'), 1, 'N', 7, 'N', 'U') periodo,
       decode(to_char(vd.dia, 'd'), 1, 0, 7, 0, c.carga_horaria) carga_horaria,
       c.id calendario_id, c.projeto_id projeto_id,
       p.datainicio, p.iniciorealizado, p.prazoprevisto, p.prazorealizado
  from projeto        p,  
       calendario     c,
       v_dias_futuros vd
 where c.tipo = 'P'
   and p.id = c.projeto_id;
   
   --   and vd.dia between p.datainicio and 
   --                   least (p.prazoprevisto, nvl(p.prazorealizado,p.prazoprevisto));
   
create or replace view v_calendario_dependente as
select nivel, id calendario_id, to_number(substr(path, 2, 11)) calendario_dep_id,
       carga_horaria
  from ( select level nivel, sys_connect_by_path(to_char(c.id, '9999999999'), '#') path,
                c.id, c.carga_horaria
           from calendario c
          where c.tipo = 'B'
         connect by c.id = prior c.pai_id
         start with c.id is not null );
   
  
-- Cria grupo de conhecimento onde não existe  
declare
  ln_existe number; 
  ln_conhec number;                 
begin
  select count(1) 
    into ln_existe 
    from conhecimento_profissional
   where tipo = 'C'
     and id_pai is null;
   
  if ln_existe > 0 then
    select conhecimento_profissional_seq.nextval into ln_conhec from dual;
    insert into conhecimento_profissional (id, titulo, vigente, tipo)
           values (ln_conhec, 'Conhecimentos', 'Y', 'G');
    update conhecimento_profissional
       set id_pai = ln_conhec
     where tipo = 'C'
       and id_pai is null;
    commit;
  end if;
end;
/


----------------------------------------

--Insere a permissao Alocação para todos os papéis de todos os projetos como Acesso Total.
insert into permissao_item_papel (papel_projeto_id, permissao_item_id, tipo_acesso)
select pp.papelprojetoid, pi.permissao_item_id, 'T'
  from papelprojeto pp,
       permissao_item pi
 where pi.codigo = 'I_TAR_PROJ_ALOCACAO'
   and not exists (select 1
                     from permissao_item_papel
                    where papel_projeto_id  = pp.papelprojetoid
                      and permissao_item_id = pi.permissao_item_id);
       
--Insere a aba de Objetivo de Indicadores em Todos os Projetos (Projeto,Atividade,Tarefa) como visível.
insert into permissaoaba (abaid, projetoid)
select a.abaid, p.id
  from aba a,
       projeto p
 where a.nome = 'bd.tela.objetivosIndicadores'
   and not exists (select 1
                     from permissaoaba
                    where abaid     = a.abaid
                      and projetoid = p.id);

commit;
/

alter table custo_lancamento add descricao varchar2(4000) null;

create or replace trigger TRIG_RESPONSAVELENTIDADE
  before insert
  on RESPONSAVELENTIDADE
  for each row
declare
  ln_conta     number; 
begin

  IF :new.TIPOENTIDADE = 'T' then
    
      SELECT COUNT(1) INTO ln_conta FROM RESPONSAVELENTIDADE r where 	r.TIPOENTIDADE = :new.TIPOENTIDADE 
      	and r.IDENTIDADE = :new.IDENTIDADE;
      
      IF ln_conta > 0 then
        raise_application_error(-20001, 'Não pode haver mais de um responsável para a tarefa.'); 
      END IF;      
  
  END IF;  
end TRIG_RESPONSAVELENTIDADE;
/

create or replace
package pck_estado_formulario is

   type t_rec_estado_formulario is record (
      row_id rowid,
      formulario_id estado_formulario.formulario_id%type,
      estado_id estado_formulario.estado_id%type);
   
   type tt_array_estado_formulario is table of t_rec_estado_formulario index by binary_integer;

   gt_registros_alterados tt_array_estado_formulario;
   gt_array_vazio        tt_array_estado_formulario;

end;
/
create or replace
package body pck_estado_formulario is

end;
/

/******************************************************************************\
* TRIGGERS para a tabela estado_formulario                                     *
\******************************************************************************/

--> Triggers no arquivo:
--       trg_estado_formulario_iud_bs
--       trg_estado_formulario_iud_ar
--       trg_estado_formulario_iud_as

--------------------------------------------------------------------------------
create or replace
TRIGGER trg_estado_formulario_iud_bs
BEFORE DELETE OR INSERT OR UPDATE
      OF sla_default_id
      ON estado_formulario
DECLARE

BEGIN
   pck_estado_formulario.gt_registros_alterados := pck_estado_formulario.gt_array_vazio;

END trg_estado_formulario_iud_bs;
/
--------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_estado_formulario_iud_ar
AFTER DELETE OR INSERT OR UPDATE
      OF sla_default_id
      ON estado_formulario
FOR EACH ROW	  
DECLARE
ln_ind number;
BEGIN
   ln_ind := pck_estado_formulario.gt_registros_alterados.count + 1;
   if (inserting) then
        pck_estado_formulario.gt_registros_alterados(ln_ind).row_id  := :new.rowid;
        pck_estado_formulario.gt_registros_alterados(ln_ind).formulario_id  := :new.formulario_id;
        pck_estado_formulario.gt_registros_alterados(ln_ind).estado_id  := :new.estado_id;
   elsif (updating) or (deleting) then
        pck_estado_formulario.gt_registros_alterados(ln_ind).row_id  := :old.rowid;
        pck_estado_formulario.gt_registros_alterados(ln_ind).formulario_id  := :old.formulario_id;
        pck_estado_formulario.gt_registros_alterados(ln_ind).estado_id  := :old.estado_id;
   end if;

END trg_estado_formulario_iud_ar;
/
--------------------------------------------------------------------------------
create or replace
TRIGGER trg_estado_formulario_iud_as
AFTER DELETE OR INSERT OR UPDATE
      OF sla_default_id
      ON estado_formulario 
DECLARE
ln_formulario_id estado_formulario.formulario_id%type;
ln_estado_id estado_formulario.estado_id%type;
ln_sla_id estado_formulario.sla%type;
ln_ret number;
BEGIN
for i in 1 .. pck_estado_formulario.gt_registros_alterados.count loop 

   begin
      select formulario_id, estado_id, sla_default_id
      into ln_formulario_id, ln_estado_id,ln_sla_id
      from estado_formulario
      where rowid = pck_estado_formulario.gt_registros_alterados(i).row_id;
   exception
   when others then
      ln_formulario_id := pck_estado_formulario.gt_registros_alterados(i).formulario_id;
      ln_estado_id := pck_estado_formulario.gt_registros_alterados(i).estado_id;
   end;

   if ln_formulario_id > 0 then
     for c in (select d.demanda_id
          from demanda d
          where d.formulario_id = ln_formulario_id
          and   d.situacao = ln_estado_id
          for update) loop
  
        update sla_ativo_demanda
        set sla_estado_id = ln_sla_id,
            qtd_minutos_critico = pck_sla.f_restante_critico(c.demanda_id)
        where demanda_id = c.demanda_id;
  
        pck_condicional.p_ExecutarRegrasCondicionais (c.demanda_id, 'auto', ln_ret);
  
     end loop;
   else
     for c in (select d.demanda_id
          from demanda d
          where (formulario_id, situacao) not in (select formulario_id, estado_id from estado_formulario where estado_final = 'S')
          for update) loop
  
        update sla_ativo_demanda
        set sla_estado_id = ln_sla_id,
            qtd_minutos_critico = pck_sla.f_restante_critico(c.demanda_id)
        where demanda_id = c.demanda_id;
  
        pck_condicional.p_ExecutarRegrasCondicionais (c.demanda_id, 'auto', ln_ret);
  
     end loop;
   end if;
   

end loop; 
END trg_estado_formulario_iud_as;
/



    
-------------------------------------------------------------------------------
-- Finalização
-------------------------------------------------------------------------------

insert into versao(id, titulo, patch, versao_tgp_id, comentario)
       values (versao_seq.nextval, '6.0.0', '01', 3, 'Aplicação de patch');
commit;
/

begin
  pck_processo.precompila;
  commit;
end;
/
                      
select * from v_versao;
/

prompt ... para conclusao da aplicacao do patch devem ser executadas as rotinas ...
prompt ... de ajustes de materialized views (AdjMviewXX.sql) e sequences (sequence.sql)







  
