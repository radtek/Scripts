/*****************************************************************************\ 
 * TraceGP 6.0.0.11                                                          *
\*****************************************************************************/

define CS_TBL_DAT = &TABLESPACE_DADOS;
define CS_TBL_IND = &TABLESPACE_INDICES;

-- Integrações patches 5.2
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
-------------------------------------------

alter table REGRAS_VALID_FUNCAO_ITEM  drop constraint FK_REGRAS_VALID_FUNCAO_ITEM_01;
alter table REGRAS_VALID_FUNCAO_ITEM  add constraint FK_REGRAS_VALID_FUNCAO_ITEM_01 
  foreign key (VALIDACAO_ITEM_ID) references REGRAS_VALIDACAO_ITEM (ID) on delete cascade;
alter table REGRAS_VALID_FUNCAO_ITEM drop constraint FK_REGRAS_VALID_FUNCAO_ITEM_02;
alter table REGRAS_VALID_FUNCAO_ITEM add constraint FK_REGRAS_VALID_FUNCAO_ITEM_02 
  foreign key (PROPRIEDADE_ID) references REGRAS_PROPRIEDADE (ID) on delete cascade;
  
alter table acao_condicional add TIPO_REGRA_RELEVANTE varchar2(1);
alter table acao_condicional add constraint CHK_ACAO_CONDICIONAL_14 check (TIPO_REGRA_RELEVANTE in ('A', 'R'));

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
       sum(vh_total.HORAS_PLANEJADAS_DIA)  HORAS_PLANEJADAS_TOTAL,
       min(decode(vh_total.horas_alocadas_dia,0,cast(null as date),null,cast(null as date),vh_total.data)) INICIO_ALOCADAS,
       min(decode(vh_total.horas_trabalhadas_dia,0,cast(null as date),null,cast(null as date),vh_total.data)) INICIO_TRABALHADAS,
       min(decode(vh_total.horas_planejadas_dia,0,cast(null as date),null,cast(null as date),vh_total.data)) INICIO_PLANEJADAS,
       max(decode(vh_total.horas_alocadas_dia,0,cast(null as date),null,cast(null as date),vh_total.data)) FIM_ALOCADAS,
       max(decode(vh_total.horas_trabalhadas_dia,0,cast(null as date),null,cast(null as date),vh_total.data)) FIM_TRABALHADAS,
       max(decode(vh_total.horas_planejadas_dia,0,cast(null as date),null,cast(null as date),vh_total.data)) FIM_PLANEJADAS
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
       vht.INICIO_ALOCADAS,
       vht.INICIO_TRABALHADAS,
       vht.INICIO_PLANEJADAS,
       vht.FIM_ALOCADAS,
       vht.FIM_TRABALHADAS,
       vht.FIM_PLANEJADAS,
       t.horasprevistas HORAS_PREVISTAS_TOTAL,
       chp.comentario ULTIMO_COMENTARIO, chp.data_update DATA_ULTIMO_COMENTARIO,
       chp.user_update USUARIO_ULTIMO_COMENTARIO,
       dhp.id DETALHE_ID,
       t.titulo TITULO_TAREFA, decode(t.projeto, null, 'A', 'P') CLASSE_TAREFA,
       t.situacao SITUACAO_TAREFA,
       case
         when nvl(t.prazorealizado, vht.data) < vht.data then 'Y'
         else 'N'
       end IND_CONCLUSAO_PREVIA,
       p.titulo TITULO_PROJETO,
       p.id ID_PROJETO
  from v_horas_totais vht,
       tarefa t,
       comentario_hora_planejada chp,
       detalhe_hora_planejada dhp,
       projeto p
 where vht.tarefa_id = t.id
   and dhp.id_hora_planejada (+) = vht.hora_planejada_id
   and chp.id_hora_planejada (+) = vht.hora_planejada_id
   and p.id (+) = t.projeto
   and (chp.data_update is null or
        chp.data_update = (select max(chp2.data_update)
                             from comentario_hora_planejada chp2
                            where chp2.id_hora_planejada = chp.id_hora_planejada));

delete telapapel where telaid = 89;
commit;
/

ALTER TABLE ATRIBUTO_COLUNA ADD TOTALIZAR VARCHAR2(1 BYTE) DEFAULT 'S';
ALTER TABLE ATRIBUTO_COLUNA ADD OBRIGATORIO VARCHAR2(1 BYTE) DEFAULT 'N';
ALTER TABLE ATRIBUTO_COLUNA ADD VIGENTE VARCHAR2(1 BYTE) DEFAULT 'Y';
ALTER TABLE ATRIBUTO_COLUNA ADD TITULO VARCHAR2(50 BYTE);
ALTER TABLE ATRIBUTO_COLUNA ADD ALINHAMENTO VARCHAR2(1 BYTE);

ALTER TABLE ATRIBUTO ADD MODO_EXIBICAO VARCHAR2(1 BYTE);

ALTER TABLE ATRIBUTO_VALOR ADD  MATRIZ_ID NUMBER(10);

ALTER TABLE ATRIBUTOENTIDADEVALOR ADD  MATRIZ_ID NUMBER(10);

CREATE TABLE MATRIZ ( 
  id number(10) not null,
constraint PK_MATRIZ primary key (id) using index tablespace &CS_TBL_IND  
) tablespace &CS_TBL_DAT;

create sequence MATRIZ_SEQ start with 1 increment by 1 nocache;

ALTER TABLE ATRIBUTO_VALOR ADD CONSTRAINT FK_ATRIBUTO_VALOR_05 
  FOREIGN KEY (MATRIZ_ID) REFERENCES MATRIZ (ID) ON DELETE CASCADE;
ALTER TABLE ATRIBUTOENTIDADEVALOR ADD CONSTRAINT FK_ATRIBUTOENTIDADEVALOR_03 
  FOREIGN KEY (MATRIZ_ID) REFERENCES MATRIZ (ID) ON DELETE CASCADE;

CREATE TABLE MATRIZ_ATRIBUTO ( 
  id number(10)        not null,
  matriz_id number(10) not null,
constraint PK_MATRIZ_ATRIBUTO primary key (id) using index tablespace &CS_TBL_IND  
) tablespace &CS_TBL_DAT;

alter table MATRIZ_ATRIBUTO add constraint FK_MATRIZ_ATRIBUTO_01 
  foreign key (matriz_id) references MATRIZ (id) on delete cascade;

create sequence MATRIZ_ATRIBUTO_SEQ  start with 1 increment by 1 nocache;

CREATE TABLE MATRIZ_ATRIBUTO_VALOR (
  ID                  	NUMBER(10,0) NOT null,
  MATRIZ_ATRIBUTO_ID		NUMBER(10,0) NOT NULL,
  ATRIBUTO_ID         	NUMBER(10,0) NOT NULL,
  VALOR               	VARCHAR2(4000 BYTE),
  VALORDATA           	DATE,
  VALORNUMERICO       	NUMBER(21,2),
  DOMINIO_ATRIBUTO_ID 	NUMBER(10,0),
  VALOR_HTML 			      CLOB,
  CATEGORIA_ITEM_ATRIBUTO_ID 	NUMBER(10,0),
constraint PK_MATRIZ_ATRIBUTO_VALOR primary key (id) using index tablespace &CS_TBL_IND   
) tablespace &CS_TBL_DAT;
  
ALTER TABLE MATRIZ_ATRIBUTO_VALOR ADD CONSTRAINT FK_MATRIZ_ATRIBUTO_VALOR_01 
  FOREIGN KEY (CATEGORIA_ITEM_ATRIBUTO_ID) REFERENCES CATEGORIA_ITEM_ATRIBUTO (CATEGORIA_ITEM_ID);
ALTER TABLE MATRIZ_ATRIBUTO_VALOR ADD CONSTRAINT FK_MATRIZ_ATRIBUTO_VALOR_02 
  FOREIGN KEY (ATRIBUTO_ID) REFERENCES ATRIBUTO (ATRIBUTOID);
ALTER TABLE MATRIZ_ATRIBUTO_VALOR ADD CONSTRAINT FK_MATRIZ_ATRIBUTO_VALOR_03 
  FOREIGN KEY (MATRIZ_ATRIBUTO_ID) REFERENCES MATRIZ_ATRIBUTO (ID) ON DELETE CASCADE;

CREATE SEQUENCE MATRIZ_ATRIBUTO_VALOR_SEQ  START WITH 1 INCREMENT BY 1 NOCACHE;

------------------------------------------------------------------------------

alter table LOG_HIST_TRANSICAO drop constraint CHK_LOG_HIST_TRANSICAO_01;
alter table LOG_HIST_TRANSICAO add constraint CHK_LOG_HIST_TRANSICAO_01
  check (TIPO in ('OB', 'IN', 'AC', 'OP', 'CO', 'VA','FU'));
  
-------------------------------

update regras_tipo_propriedade 
   set atualizavel = 'Y' 
 where titulo like '%resp%' 
   and tipo_entidade_id = 1 
   and tipo_valor_id    = 2;

update regras_tipo_propriedade 
   set atualizavel = 'Y' 
 where titulo like '%gerente%' 
   and tipo_entidade_id = 2 
   and tipo_valor_id = 6;
   
update regras_tipo_propriedade 
   set where_join = '[ENTIDADE-PAI].RESPONSAVEL = [ENTIDADE-FILHA].USUARIOID(+)' 
 where id = 59;
commit;
/

alter table acao_condicional add TIPO_REGRA_RELEVANTE varchar2(1);
alter table acao_condicional add constraint CHK_ACAO_CONDICIONAL_14 
  check (TIPO_REGRA_RELEVANTE in ('A', 'R'));
 
alter table regras_valid_funcao_item drop constraint CHK_REGRAS_VALID_FUNCAO_IT_01;

-- Create table
create table DESTINO_USUARIO_FISICO (
  DESTINO NUMBER(10)   not null,
  USUARIO VARCHAR2(50) not null,
constraint PK_DESTINO_USUARIO_FISICO primary key (destino, usuario) using index tablespace &CS_TBL_IND
) tablespace &CS_TBL_DAT;

-- Create/Recreate primary, unique and foreign key constraints 
alter table DESTINO_USUARIO_FISICO add constraint FK_DESTINO_USUARIO_FISICO_01 
  foreign key (USUARIO) references USUARIO (USUARIOID) on delete cascade;

-- Create table
create table DESTINO_EQUIPE (
  DESTINO number(10) not null,
  EQUIPE  number(10) not null,
constraint PK_DESTINO_EQUIPE primary key (destino, equipe) using index tablespace &CS_TBL_IND
) tablespace &CS_TBL_DAT;

-- Add comments to the columns 
comment on column DESTINO_EQUIPE.DESTINO
  is 'Destino';
comment on column DESTINO_EQUIPE.EQUIPE
  is 'Equipe';
-- Create/Recreate primary, unique and foreign key constraints 
alter table DESTINO_EQUIPE
  add constraint FK_DESTINO_EQUIPE_01 foreign key (DESTINO)
  references destino (DESTINOID);
alter table DESTINO_EQUIPE
  add constraint fk_destino_equipe_02 foreign key (EQUIPE)
  references equipe (EQUIPE_ID);

insert into destino_usuario_fisico
select  *  from destino_usuario;

drop table destino_usuario;

create or replace view destino_usuario as
select destino, usuario
from destino_usuario_fisico
union 
select destino, ue.usuarioid
from destino_equipe de, usuario_equipe ue
where de.equipe = ue.equipe_id;

begin
  pck_processo.pRecompila;
  commit;
end;
/

------------------------------------------------------------------------------
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
        execute immediate lv_sql;        

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
        close lc_sql;
        return lv_valor;

     else
        lv_sql := ' select ' || lv_coluna ||
                  ' from ' || lv_from;
        if lv_where > ' ' then
           lv_sql := lv_sql || ' where ' || substr(lv_where, 5);
        end if;
        
        lv_sql := lv_sql || ' order by 1';

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



------------------------------------------------------------------------------
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

------------------------------------------------------------------------------


CREATE OR REPLACE PACKAGE PCK_DOCUMENTO AS

type lista_campos is table of t_tipo_campos;

function  f_lista_campos  return lista_campos PIPELINED;
function  f_lista_campos_DOF  return lista_campos PIPELINED;

procedure p_Exporta_Arquivo(ln_ano number,ls_tipo varchar2, ls_projetos varchar2, ln_arquivo in out number);
procedure p_Importa_Arquivo(ln_seq number, ls_diretorio varchar2, ln_retorno in out number);
procedure p_Carrega_Arquivo (ls_diretorio varchar2, ls_arquivo varchar2, ln_seq out number, ln_retorno in out number);
procedure p_Carga_Inicial(ln_seq number, ln_retorno in out number);
procedure p_Importa_Custos(ln_seq number, ln_retorno in out number);
procedure p_Acerto_Carga_Inicial(ln_seq number, ln_retorno in out number);
procedure p_Importa_View_Zeus(ls_diretorio varchar2, ln_retorno in out number);
PROCEDURE p_Exporta_Arquivo_CNI(ls_tipo varchar2, ln_arquivo in out number, ln_retorno in out number);

  
END PCK_DOCUMENTO;
/
CREATE OR REPLACE PACKAGE BODY PCK_DOCUMENTO AS

function  f_lista_campos_DOF  return lista_campos PIPELINED
  as
  begin
     pipe row( t_tipo_campos( 1,'Val_Fixo1'   ,'fixo'  ,1 ,0,'' ,'A'                   ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos( 2,'Val_Fixo2'   ,'fixo'  ,1 ,0,'' ,'I'                   ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos( 3,'Cod_Trace'   ,'fixo'  ,5 ,0,'' ,'TRACE'               ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos( 4,'Val_Fixo4'   ,'fixo'  ,1 ,0,'' ,'1'                   ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos( 5,'Entidade'    ,'char'  ,10,0,'' ,'TRACETRACE'           ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos( 6,'Val_Fixo6'   ,'nulo'  ,0,0 ,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos( 7,'Dt_Liberacao','date'  ,10,0,'' ,'DD/MM/YYYY',       'Y',''                    ,'Data de Vencimento'));
     pipe row( t_tipo_campos( 8,'Valor_Ordem' ,'number',17,2,',','00000000000009D00','Y',''                   ,'Valor da Ordem'));
     pipe row( t_tipo_campos( 9,'Val_Fixo9'   ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(10,'Val_Fixo10'  ,'fixo'  ,1 ,0,'' ,'P'                   ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(11,'Val_Fixo11'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(12,'Dt_Geracao'  ,'date'  ,10,0,'' ,'DD/MM/YYYY',       'Y',''                    ,'Data de Vencimento'));
     pipe row( t_tipo_campos(13,'Dt_Provisao' ,'date'  ,10,0,'' ,'DD/MM/YYYY',       'Y',''                    ,'Data de Provisao'));
     pipe row( t_tipo_campos(14,'Dt_Pagamento','date'  ,10,0,'' ,'DD/MM/YYYY',       'Y',''                    ,'Data de Pagamento'));
     pipe row( t_tipo_campos(15,'Val_Fixo15'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(16,'Val_Fixo16'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(17,'Val_Fixo17'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(18,'Val_Fixo18'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(19,'CTA_Fluxo'   ,'char'  ,10,0,'' ,'X'           ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(20,'CTA_Ctb'     ,'char'  ,10,0,'' ,'X'           ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(21,'MOV_CTB'     ,'fixo'  ,5 ,0,'' ,'UU100'               ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(22,'Val_Fixo22'  ,'nulo'  ,0,0 ,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(23,'Texto'       ,'char'  ,200,0,'' ,'X'           ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(24,'UO'          ,'char'  ,10,0,'' ,'X'           ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(25,'CR'          ,'char'  ,16,0,'' ,'X'           ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(26,'Val_Fixo26'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(27,'Val_Fixo27'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(28,'Val_Fixo28'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(29,'Val_Fixo29'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(30,'Val_Fixo30'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(31,'Val_Fixo31'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(32,'Val_Fixo32'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(33,'Dt_Registro' ,'date'  ,10,0,'' ,'DD/MM/YYYY',       'Y',''                    ,'Data de Vencimento'));

  end;

function  f_lista_campos  return lista_campos PIPELINED
  as
  begin
         pipe row( t_tipo_campos( 1,'Codigo'   ,'char'  ,4 ,0,'' ,'X'                    ,'Y',''                    ,'Código do Sistema que gerou a informação Orçamento (ORC)') );
         pipe row( t_tipo_campos( 2,'tipo'     ,'number',2 ,0,'' ,'99'                   ,'Y','[2],[3],[4],[5],[6]' ,'Tipo de movimento. Este código é criado no sistema do orçamento e determina a informação, que estará trafegando o movimento. (2  Orçado,3  Realizado,4  Transposto,5  Suplementado,6  Retificado)'));
         pipe row( t_tipo_campos( 3,'ano'      ,'number',4 ,0,'' ,'9999'                 ,'Y',''                    ,'Ano do Orçamento'));
         pipe row( t_tipo_campos( 4,'mes'      ,'date'  ,2 ,0,'' ,'MM'                   ,'Y',''                    ,'Mês do Orçamento'));
         pipe row( t_tipo_campos( 5,'cod_empre','number',3 ,0,'' ,'999'                  ,'Y',''                    ,'Código da Empresa do Movimento'));
         pipe row( t_tipo_campos( 6,'Cod_UO'   ,'char'  ,10,0,'' ,'X '                   ,'Y',''                    ,'Código da Unidade Organizacional'));
         pipe row( t_tipo_campos( 7,'Cod_CR'   ,'char'  ,16,0,'' ,'X '                   ,'Y',''                    ,'Código do Centro de Responsabilidade'));
         pipe row( t_tipo_campos( 8,'Cod_CO'   ,'char'  ,16,0,'' ,'X '                   ,'Y',''                    ,'Código do Conta Orçamentária'));
         pipe row( t_tipo_campos( 9,'Qtde_Mov' ,'number',17,4,',','000000000009D0000'    ,'Y',''                    ,'Quantidade do Movimento'));
         pipe row( t_tipo_campos(10,'Val_Mov'  ,'number',17,2,',','00000000000009D00'    ,'Y',''                    ,'Valor do Movimento'));
         pipe row( t_tipo_campos(11,'Val_Fixo' ,'fixo'  ,1 ,0,'' ,'0'                    ,'Y',''                    ,'Valor_Fixo'));
         pipe row( t_tipo_campos(12,'Nome_Arq' ,'char'  ,4 ,0,'' ,'X '                   ,'Y',''                    ,'Nome do arquivo do movimento orçamentário'));
         pipe row( t_tipo_campos(13,'Ano_PC'   ,'date'  ,4 ,0,'' ,'YYYY'                 ,'Y',''                    ,'Ano do Plano de Contas'));
         pipe row( t_tipo_campos(14,'Cod_CC'   ,'char'  ,16,0,'' ,'X '                   ,'Y',''                    ,'Código do Conta Contábil'));
         pipe row( t_tipo_campos(15,'Cod_Mov'  ,'char'  ,1 ,0,'' ,'X'                    ,'Y','[A],[M]'             ,'Determina a forma da entrada do movimento do orçamento. Todos os movimentos atuais são automáticos M  Manual A - Automático'));
         pipe row( t_tipo_campos(16,'Dt_Mov'   ,'date'  ,19,0,'' ,'DD/MM/YYYY HH24:MI:SS','Y',''                    ,'Data de Atualização do Movimento'));

  end;

PROCEDURE p_Exporta_Arquivo(ln_ano number,
                            ls_tipo varchar2, 
                            ls_projetos varchar2, 
                            ln_arquivo in out number) AS

 ls_campo              VARCHAR2(2000);
 ln_campo              number;
 ld_campo              date;
 ls_seperador_campo    varchar2(5);
 ls_seperador_registro varchar2(5);
 ln_qtde_campos        integer;
 l_colcnt              integer;
 reg                   lista_campos;
 ln_doc                int;
 ln_doc_cont           int;
 blob_edit             BLOB; 
 ls_linha              varchar2(32767);
 b_int                 binary_integer;
 c                     INTEGER;
 fdbk                  integer;
 ln_tamanho            number;
 primeiro_registro     boolean:=true;
 ls_query              varchar2(32000);
begin

/*
--Para Testes:

ls_query:='
select ''ORC'',
        1, -- Orçado
        cl.data,
        cl.data,
        level, --number Empresa 
        ''A'', --UO
        ''CR'', --C responsa
        ''11'', --Cta Orçamentaria
        nvl(cl.quantidade,0),
        cl.valor,
        ''0'', --fixo
        ''Teste.txt'',
        sysdate,
        nvl(td.conta_contabil,''0''),
        ''M'',
        sysdate
from custo_entidade ce, custo_lancamento cl, tipodespesa td
where cl.custo_entidade_id = ce.id and
      td.id = ce.tipo_despesa_id CONNECT BY level <= 100 ';
*/

 ls_query:='
 select ''ORC'',
        case ''' || ls_tipo || '''
          when ''Planejamento'' then 2 
          when ''Realizado'' then 3
          when ''Transposição'' then 4
          when ''Suplementação'' then 5
          when ''Retificação'' then 6 END Tipo,
        '|| to_char(ln_ano) ||' Ano, --ln_ano
        cl.data Mes,
        case substr(u.titulo,5,2) 
          when ''01'' then 100 
          when ''02'' then 200
          when ''03'' then 300
          when ''04'' then 400
          when ''05'' then 500 
          else 0 end Empresa ,
        substr(u.titulo,5,instr(u.titulo,''-'')-6) UO,
        nvl((select substr(cia.Titulo,6,instr(cia.Titulo,''-'')-6) 
                from atributoentidadevalor aev, categoria_item_atributo cia
                   where aev.identidade = b.projeto_id and 
                         aev.tipoentidade=''P'' and 
                         aev.atributoid=2 and
                         cia.atributo_id=2 and
                         aev.categoria_item_atributo_id = cia.categoria_item_id
                         ),''0000000000'') ||
        nvl((select 
                lpad(trim(to_char(trunc(aev.ValorNumerico))),  trunc((length(trim(to_char(trunc(aev.ValorNumerico))))+1)/2)*2   ,''0'')        
                from atributoentidadevalor aev 
                   where aev.identidade = b.projeto_id and 
                         aev.tipoentidade=''P'' and 
                         aev.atributoid=1),''000000'') CentroResponsabilidadeSEQ, 
        substr(cr.titulo,6,instr(cr.titulo,''-'')-7) Cta_Orc, 
        nvl(cl.quantidade,0) Qtde,
        cl.valor Valor,
        ''0'' Fixo, 
        ''' || ls_tipo || '-'||to_char(ln_ano)||'.TXT'' Arquivo,
        sysdate Ano_Plano_Contas,
        ''0'' Cta_contabil,
        ''A'' Automatico,
        sysdate Dt_Atualizacao
     from baseline b, 
          baseline_custo_entidade ce, 
          baseline_custo_lancamento cl, 
          custo_receita cr,
          projeto p, 
          uo u
     where b.titulo =  '''|| ls_tipo|| '-' || to_char(ln_ano) || ''' and
           b.projeto_id in ('|| replace(ls_projetos,'-',',')||')   and
           b.baseline_id = ce.baseline_id and
           b.baseline_id = cl.baseline_id and
           ce.id = cl.baseline_custo_entidade_id and
           ce.custo_receita_id = cr.id  and
           b.projeto_id = p.id and
           cl.situacao = ''V'' and
           p.uo_id = u.id and
           cl.tipo =''P''';


  DBMS_LOB.CREATETEMPORARY(blob_edit,TRUE);
   
  ls_seperador_campo:=chr(9);
  ls_seperador_registro:=chr(13)||chr(10);
  c := DBMS_SQL.OPEN_CURSOR;

  DBMS_SQL.PARSE (c, ls_query, DBMS_SQL.NATIVE);

  select count(*) into ln_qtde_campos  from table(f_lista_campos);

  FOR i IN 1 .. ln_qtde_campos
    LOOP

     select t_tipo_campos(sec,nome,tipo,tamanho,decimais,separador,formato,obrigatorio,opcoes,descricao)
     BULK COLLECT INTO reg     from table(f_lista_campos) where sec=i;

      BEGIN
        if reg(1).tipo='char' or reg(1).tipo='fixo' then
           DBMS_SQL.define_column(c, i, ls_campo, 2000);
        end if;
        if reg(1).tipo='number' then
           DBMS_SQL.define_column(c, i, ln_campo);
        end if;
        if reg(1).tipo='date' then
           DBMS_SQL.define_column(c, i, ld_campo);
        end if;        

        l_colcnt := i;
      EXCEPTION
        WHEN OTHERS THEN
          IF (SQLCODE = -1007)
          THEN
            EXIT;
          ELSE
            RAISE;
          END IF;
      END;
    END LOOP; 
   DBMS_SQL.define_column(c, 1, ls_campo, 2000);
   fdbk:= DBMS_SQL.EXECUTE (c); 

 LOOP
  EXIT WHEN(DBMS_SQL.fetch_rows(c) <= 0); 

  ls_linha:='';


  FOR i IN 1 .. ln_qtde_campos
      LOOP
     select t_tipo_campos(sec,nome,tipo,tamanho,decimais,separador,formato,obrigatorio,opcoes,descricao)
     BULK COLLECT INTO reg     from table(f_lista_campos) where sec=i;

     if reg(1).tipo='char' then
        DBMS_SQL.COLUMN_VALUE(c, i, ls_campo);
        if reg(1).formato='X' THEN
           ls_linha := ls_linha || substr(ls_campo,1,reg(1).tamanho);
        end if;
        if reg(1).formato='X ' THEN
           ls_linha := ls_linha || rpad(substr(ls_campo,1,reg(1).tamanho),reg(1).tamanho,' ');
        end if;
        if reg(1).formato=' X' THEN
           ls_linha := ls_linha || lpad(substr(ls_campo,1,reg(1).tamanho),reg(1).tamanho,' ');
        end if;
        end if;
     if reg(1).tipo='fixo' then
        ls_linha := ls_linha || reg(1).formato;
     end if;
     if reg(1).tipo='date' then
        DBMS_SQL.COLUMN_VALUE(c, i, ld_campo);
        ls_linha := ls_linha || to_char(ld_campo,reg(1).formato);
     end if;
     if reg(1).tipo='number' then
        DBMS_SQL.COLUMN_VALUE(c, i, ln_campo);
        ls_linha := ls_linha || to_char(ln_campo,reg(1).formato);
     end if;

     if i <> ln_qtde_campos then
        ls_linha :=ls_linha || ls_seperador_campo;
     else
        ls_linha :=ls_linha || ls_seperador_registro;
     end if;
        
      END LOOP;    

    b_int:=utl_raw.length (utl_raw.cast_to_raw(ls_linha));
    
    if (primeiro_registro) then
      dbms_lob.write(blob_edit, b_int, 1, utl_raw.cast_to_raw(ls_linha));
      primeiro_registro:=false;
    else
      dbms_lob.writeappend(blob_edit, b_int , utl_raw.cast_to_raw(ls_linha));
    end if;

 END LOOP;

 select documento_seq.nextval into ln_doc from dual;
 select documento_conteudo_seq.nextval into ln_doc_cont from dual;

 Insert into DOCUMENTO (DOCUMENTOID,DESCRICAO, TIPOENTIDADE,IDENTIDADE,
                        AREAGERENCIA,ESTADODOCUMENTO,VERSAOATUAL,TIPODOCUMENTO,
                        RESPONSAVEL,DOCUMENTO_PAI,TIPO_DOCUMENTO_ID,TAMANHO) 
 select ln_doc,trim(ls_tipo)||'-'||to_char(ln_ano)||' Exportado em '||to_char(sysdate,'DD-MM-YYYY HH24-MI-SS'),null,null,
        null,'I',1,'.txt',
        null,null,null,null 
     from dual;

 insert into documento_conteudo (id, documento_id, versao, conteudo)
 values (ln_doc_cont, ln_doc, 1, empty_blob());-- returning conteudo into blob_edit;

 update documento_conteudo
 set conteudo = blob_edit
 where id=ln_doc_cont;

 dbms_lob.FREETEMPORARY(blob_edit);

 DBMS_SQL.CLOSE_CURSOR (c);

 ln_arquivo:=ln_doc;

end p_Exporta_Arquivo;

procedure p_Importa_Arquivo(ln_seq       number, 
                            ls_diretorio varchar2,
                            ln_retorno in out number)
is
 ls_campo              VARCHAR2(1000);
 ln_campo              number;
 ld_campo              date;
 ls_seperador_campo    varchar2(5);
 ls_seperador_registro varchar2(5);
 ln_qtde_campos        integer;
 l_colcnt              integer;
 reg                   lista_campos;
 ln_doc                int;
 ln_doc_cont           int;
 blob_edit             BLOB; 
 ls_linha              varchar2(32767);
 b_int                 binary_integer;
 c                     INTEGER;
 fdbk                  integer;
 ln_tamanho            number;
 primeiro_registro     boolean:=true;
 ls_query              varchar2(2000);
 vtemp                 RAW(32000);
 vend                  NUMBER := 1;
 vlen                  NUMBER := 1;
 vstart                NUMBER := 1;
 vend2                 NUMBER := 1;
 vlen2                 NUMBER := 1;
 vstart2               NUMBER := 1;
 i                     number;
 ln_proj               number:=0;
 bytelen               NUMBER := 32000;
 ultimo_campo          boolean;
 registros             number:=0;     
 ln_ce                 number:=0;
 ln_cl                 number:=0;
 TYPE t_dados IS VARRAY(100) OF varchar2(1000);
 dados t_dados:=t_dados();
 lb_erro boolean:=false;
 ln_categ number;
 ln_uo number;
 -- Modificado <Charles> Ini
 lf_rejeitados SYS.UTL_FILE.file_type;
 lf_log        SYS.UTL_FILE.file_type;
 ln_forma      number := 0;
 ln_tipo       number := 0;
 ln_cr         number := 0;
 ld_lancamento date;
 lv_mensagem   varchar2(4000);
 ld_data_hora  date;
 -- Modificado <Charles> Fim
begin
  
   -- Modificado <Charles> - Ini  
   if ls_diretorio is not null then
     select sysdate into ld_data_hora from dual;
     lf_rejeitados := SYS.UTL_FILE.fopen (ls_diretorio, 'registros_rejeitados_' || 
                                      to_char(ld_data_hora, 'yyyymmddhh24miss') || '.txt', 'w');
     lf_log        := SYS.UTL_FILE.fopen (ls_diretorio, 'resultado_processamento_' || 
                                      to_char(ld_data_hora, 'yyyymmddhh24miss') || '.txt', 'w');
   end if;
   -- Modificado <Charles> - Fim 
   
   ls_seperador_campo:=chr(9);
   ls_seperador_registro:=chr(13)||chr(10);  /* UNIX 10, DOS 13+10 */
  
   select conteudo into blob_edit
   from documento_conteudo
   where documento_id=ln_seq;

   vlen:=dbms_lob.getlength(blob_edit);
   bytelen := 32000;
   vstart := 1;
   
   vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);
   
   if vend=0 then
      dbms_output.put_line('O arquivo não possui um FIM DE LINHA do padrão DOS/WINDOS (char 13 + char 10). Provavelmente é um arquivo no formato UNIX.');
      dbms_output.put_line('O arquivo deve ser convertido.');
   end if;
   
  
   WHILE vstart < vlen 
   LOOP
         vlen2:=vend-vstart+1;

         dbms_lob.read(blob_edit,vlen2,vstart,vtemp);
         ls_linha:=utl_raw.cast_to_varchar2(vtemp);
         registros:=registros+1;
         vend2 := 1;
         vstart2 := 1;
         vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);
         i:=1;     
         ultimo_campo:=false;
         WHILE vstart2 < vlen2 or ultimo_campo
         LOOP
               select t_tipo_campos(sec,nome,tipo,tamanho,decimais,separador,formato,obrigatorio,opcoes,descricao)
               BULK COLLECT INTO reg     from table(f_lista_campos) where sec=i;
               ls_campo:=substr(ls_linha, vstart2, vend2-vstart2);
               dados.extend;
               dados(i):=ls_campo;
               vstart2:=vend2+length(ls_seperador_campo);
               if not ultimo_campo then
                  vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);
               else
                  ultimo_campo:=false;
               end if;
               if vend2 =0 then
                  ultimo_campo:=true;
                  vend2:=vlen2;
               end if;
               i:=i+1;
         END LOOP;

   --------------------------------------
   -- Início do Processamento da Linha --
   --------------------------------------
   -- dbms_output.put_line(dados(1)||dados(2)||dados(3));
   -- Dados prontos para serem trabalhados
   lb_erro:=false;
         if dados(2)='3' then -- Realizado
           
            -- Para identificar o projeto, identificar por 3 valores
            -- 1. Projeto deve ser da UO 
            -- 2. Atributo 2 deve ter 'YYYY XXXXXX' onde YYYY é o ano do orçamento e XXXXXX são os 6 primeiras posicoes do Centro de Resposabilidade 
            -- 3. Atributo 1 deve ter o sequencial posicao a partir da 7 do Centro de Responsabilidade
            dados(3):=trim(dados(3));
            dados(4):=trim(dados(4));
            dados(6):=trim(dados(6));
            dados(7):=trim(dados(7));
            dados(16):=trim(dados(16));
            dados(8):=dados(3)|| ' '|| trim(dados(8));

            if instr(dados(16),' ')>0 then
               dados(16):=substr(dados(16),1,instr(dados(16),' '));
            end if;
            if to_number(dados(9))=0 then
              dados(9):='1';
            end if;

            begin
             select ci.categoria_item_id into ln_categ
                    from categoria_item_atributo ci
                    where ci.titulo like dados(3)|| ' ' || substr(dados(7),1,9) ||'-%' and
                          ci.atributo_id=2;

              exception when no_data_found then
                ln_categ:=0;
                  lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Atributo Centro Responsabilidade não localizado: '||chr(9)||dados(3)||' '|| substr(dados(7),1,9);
                  dbms_output.put_line(lv_mensagem);
                  SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  lb_erro:=true;
                when others then
                ln_categ:=0;
                  lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Atributo Centro Responsabilidade localizou mais de 1 CR: '||chr(9)||dados(3)|| ' ' || substr(dados(7),1,9);
                  dbms_output.put_line(lv_mensagem);
                  SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  lb_erro:=true;
             end; 


            begin
             select u.id into ln_uo from uo u where to_number(substr(u.titulo,5,instr(u.titulo,'-')-6)) = to_number(dados(6));

              exception when no_data_found then
                ln_uo:=0;
                  lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' UO não localizado: '||chr(9)||dados(3)|| ' ' || dados(6);
                  dbms_output.put_line(lv_mensagem);
                  SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  lb_erro:=true;
                when others then
                ln_uo:=0;
                  lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Localizou mais de 1 UO: '||chr(9)||dados(3)|| ' ' || dados(6);
                  dbms_output.put_line(lv_mensagem);
                  SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  lb_erro:=true;
             end; 

            begin
--dbms_output.put_line(dados(7)||'-'||ln_categ||'-'||ln_uo);
            select id into ln_proj from projeto p
            where p.uo_id = ln_uo  and
                  exists (select *
                from atributoentidadevalor aev--, categoria_item_atributo cia
                   where aev.identidade = p.id and 
                         aev.tipoentidade='P' and 
                         aev.atributoid=2 and
                         aev.categoria_item_atributo_id = ln_categ
                         --cia.atributo_id=2 and
                         --substr(cia.Titulo,6,instr(cia.Titulo,'-')-6) = dados(3)|| ' ' || substr(dados(7),1,9) and
                         --aev.categoria_item_atributo_id = cia.categoria_item_id
                         ) and
                   exists (select *
                from atributoentidadevalor aev 
                   where aev.identidade = p.id and 
                         aev.tipoentidade='P' and 
                         nvl(aev.Valor, aev.ValorNumerico)= to_number(substr(dados(7),10)) and
                         aev.atributoid=1);
            exception when no_data_found then
                lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Não foi localizado Projeto com Atributo Centro Responsabilidade: '||chr(9)||dados(3)|| ' ' || substr(dados(7),1,9) ||chr(9)|| ' Atributo_SEQ:'||chr(9)|| substr(dados(7),10)||chr(9) || ' UO: '||chr(9)||dados(6)||chr(9)|| ' COD_CR:'||chr(9)||ln_categ || chr(9)||' COD_UO:'||chr(9)||ln_uo;
                dbms_output.put_line(lv_mensagem);
                SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                lb_erro:=true;
              when others then
                lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Existe mais de um Projeto com Atributo Centro Responsabilidade: '||chr(9)||dados(3)|| ' ' || substr(dados(7),1,9) ||chr(9)|| ' Atributo_SEQ:'||chr(9)|| substr(dados(7),10)||chr(9) || ' UO: '||chr(9)||dados(6)||chr(9)|| ' COD_CR:'||chr(9)||ln_categ ||chr(9)|| ' COD_UO:'||chr(9)||ln_uo;
                dbms_output.put_line(lv_mensagem);
                SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                lb_erro:=true;
           end; 
              
           if (not lb_erro) then

            select nvl(min(ce.id),0) into ln_ce from custo_entidade ce, custo_receita cr
            where ce.tipo_entidade = 'P' and
                  ce.custo_receita_id = cr.id and
                  ce.entidade_id = ln_proj and
                  cr.titulo like dados(8)||'%'; -- conta contabil
            
            -- Modificado <Charles> Ini
            if ln_ce = 0 then   
                        
              select max(id)
                into ln_cr
                from custo_receita
               where titulo like dados(8)||' %'; -- conta contabil 
               
              if ln_cr > 0 then  
           
                select min(forma_id)
                  into ln_forma
                  from (select *
                          from custo_receita_forma 
                         where custo_receita_id = ln_cr
                         order by decode(vigente, 'Y', 1, 2), decode (valor_default,'Y', 1, 2))
                 where rownum = 1;
                 
                select min(tipo_id)
                  into ln_tipo
                  from (select *
                          from custo_receita_tipo
                         where custo_receita_id = ln_cr
                         order by decode(vigente, 'Y', 1, 2), decode (valor_default,'Y', 1, 2))
                 where rownum = 1; 
               
                select custo_entidade_seq.nextval into ln_ce from dual;
                
                insert into custo_entidade (id, tipo_entidade, entidade_id, custo_receita_id, titulo, 
                                            tipo_despesa_id, forma_aquisicao_id)
                       values (ln_ce, 'P', ln_proj, ln_cr, dados(8), ln_tipo, ln_forma);
              end if;
            end if;
            -- Modificado <Charles> Fim
            
            if ln_ce > 0 then
                                          
                  -- Modificado <Charles> Ini
                  ld_lancamento := to_date(dados(16),'DD/MM/YYYY');
                  begin
                    ld_lancamento := to_date('01'||trim(to_char(to_number(dados(4)),'00'))||dados(3), 'ddmmyyyy');
                    -- Coloca no último dia do mês
                    ld_lancamento := add_months(ld_lancamento, 1) - 1;
                  exception
                    when others then
                      ld_lancamento := null;
                  end;
                  --dbms_output.put_line('DEBUG: ' || to_char(ld_lancamento, 'dd/mm/yyyy'));
                  -- Modificado <Charles> Fim
                  
                  select nvl(max(id),0) into ln_cl from custo_lancamento 
                  where custo_entidade_id = ln_ce and
                        tipo = 'R' and
                        situacao = 'V' and
                        trunc(data) = trunc(ld_lancamento);

                  if ln_cl=0 then
                      begin
                        select custo_lancamento_seq.nextval into ln_cl from dual;
                        insert into custo_lancamento (ID, CUSTO_ENTIDADE_ID, TIPO, SITUACAO,
                                                      DATA, 
                                                      VALOR,
                                                      QUANTIDADE, 
                                                      VALOR_UNITARIO, 
                                                      USUARIO_ID, DATA_ALTERACAO)
                            values (ln_cl, ln_ce, 'R', 'V',
                                    ld_lancamento,
                                    to_number(dados(10)), -- valor
                                    to_number(dados(9)), -- quantidade
                                    to_number(dados(10))/to_number(dados(9)), -- valor unitario,
                                    '310', 
                                    sysdate);  -- 
                       lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' OK - Registro Inserido - Conta:'||dados(8);
                       dbms_output.put_line(lv_mensagem);
                       SYS.UTL_FILE.put_line(lf_log, lv_mensagem); 
                     exception
                       when others then
                         lv_mensagem := 'Linha:'||chr(9)||' Erro ao incluir: [' || sqlerrm || ']';
                         dbms_output.put_line(lv_mensagem);
                         SYS.UTL_FILE.put_line(lf_log, lv_mensagem); 
                     end;           
                  else
                  -- dbms_output.put_line('Já existe Custo Lançamento para Lançamento para Conta:'||dados(14)||' Projeto:'|| '???' ||' Data:'||substr(dados(16),1,10)|| ' Linha não importada:'||registros);
                  -- se ja existe, acrescenta
                  begin
                    update custo_lancamento
                       set VALOR=VALOR+to_number(dados(10)),
                           QUANTIDADE=QUANTIDADE+to_number(dados(9)), 
                           VALOR_UNITARIO=(VALOR+to_number(dados(10)))/(QUANTIDADE+to_number(dados(9))), 
                           USUARIO_ID='310',
                           DATA_ALTERACAO=sysdate
                    where custo_entidade_id = ln_ce and
                          tipo = 'R' and
                          situacao = 'V' and
                          trunc(data) = trunc(ld_lancamento);

                       lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' OK - Registro Atualizado - Conta:'||dados(8);
                       dbms_output.put_line(lv_mensagem);
                       SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  exception
                    when others then
                      lv_mensagem := 'Linha:'||chr(9)||' Erro ao atualizar: [' || sqlerrm || ']';
                      dbms_output.put_line(lv_mensagem);
                      SYS.UTL_FILE.put_line(lf_log, lv_mensagem); 
                  end;
                  end if;
            else
               -- Modificado <Charles>
               lb_erro:=true;
               
               lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||'Não foi localizado Custo Entidade para Conta:'||chr(9)||dados(8)||chr(9)||' Projeto:'||chr(9)||ln_proj;
               dbms_output.put_line(lv_mensagem);
               SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
            end if;
            end if;
         end if;
   
   -- Modificado <Charles> - Ini
   -- Grava registro nao processado no arquivo de output
   if lb_erro then
     SYS.UTL_FILE.put_line(lf_rejeitados, ls_linha);
   end if;
   -- Modificado <Charles> - Fim
   
   --------------------------------------
   -- FIM do Processamento da Linha --
   --------------------------------------
   vstart:=vend+length(ls_seperador_registro);
   vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);

   -- tratamento para linha sem fim de linha
     if vend>vlen or vend=0 then
        vend:=vlen;
     end if;
     
     
   dados:=t_dados();
   END LOOP;
   
 -- Modificado <Charles>
 lv_mensagem := 'Linha: '|| registros;
 dbms_output.put_line(lv_mensagem);
 SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
 
 SYS.UTL_FILE.fclose(lf_rejeitados);
 SYS.UTL_FILE.fclose(lf_log);
 ln_retorno:=registros;

end p_Importa_Arquivo;

procedure p_Carrega_Arquivo (ls_diretorio varchar2, ls_arquivo varchar2, ln_seq out number, ln_retorno in out number)
AS
 
     v_bfile bfile;
     v_blob blob;
     ln_doc int;
     ln_doc_cont int;
     
    begin

      v_bfile := bfilename(ls_diretorio,ls_arquivo);
      dbms_lob.fileopen(v_bfile, dbms_lob.file_readonly);

select documento_seq.nextval into ln_doc from dual;
select documento_conteudo_seq.nextval into ln_doc_cont from dual;

Insert into DOCUMENTO (DOCUMENTOID,DESCRICAO,
      TIPOENTIDADE,IDENTIDADE,AREAGERENCIA,ESTADODOCUMENTO,VERSAOATUAL,TIPODOCUMENTO,RESPONSAVEL,DOCUMENTO_PAI,TIPO_DOCUMENTO_ID,TAMANHO) 
select ln_doc,ls_diretorio||'-'||ls_arquivo||'- Carregado em '||to_char(sysdate,'DD-MM-YYYY HH24-MI-SS'),
       null,null,null,'I',1,'.txt',null,null,null,null from dual;

insert into documento_conteudo (id, documento_id, versao, conteudo)
values (ln_doc_cont, ln_doc, 1, empty_blob());-- returning conteudo into blob_edit;

DBMS_LOB.CREATETEMPORARY(v_blob,TRUE);

/*      insert into tab_imagem (id,nome,imagem)
      values (1,p_nome_arquivo,empty_blob())
      return imagem into v_blob;*/
      
      dbms_lob.loadfromfile(v_blob,v_bfile,dbms_lob.getlength(v_bfile));
      dbms_lob.fileclose(v_bfile);

update documento_conteudo
set conteudo = v_blob
where id=ln_doc_cont;

      
  commit;
  ln_retorno:=1;
  ln_seq:=ln_doc;
  
 EXCEPTION
  WHEN UTL_FILE.access_denied THEN
   ln_retorno:=-1;
   dbms_output.put_line('Problema de acesso ao arquivo. Abortado');
   return;

  WHEN UTL_FILE.invalid_path THEN
   ln_retorno:=-1;
   dbms_output.put_line('Diretório Inválido. Abortado');
   return;

  WHEN NO_DATA_FOUND THEN
   ln_retorno:=-1;
   dbms_output.put_line('No Data Found. Abortado');
   return;

  WHEN UTL_FILE.READ_ERROR THEN
   ln_retorno:=-1;
   dbms_output.put_line('Falha na Leitura. Abortado');
   return;

  WHEN UTL_FILE.invalid_filename THEN
   ln_retorno:=-1;
   dbms_output.put_line('Nome de Arquivo inválido. Abortado');
   return;

  WHEN UTL_FILE.invalid_filehandle THEN
   ln_retorno:=-1;
   dbms_output.put_line('Nome de Arquivo inválido. Abortado');
   return;

  WHEN others THEN
   ln_retorno:=-1;
   dbms_output.put_line('Erro inesperado. Abortado');
   return;

end p_Carrega_Arquivo;

procedure p_Carga_Inicial_Script(ln_seq number, ln_retorno in out number)
-----------------------------------------
-- ESTA PROC NÂO ESTA SENDO UTILIZADA  --
-----------------------------------------

is
ls_campo VARCHAR2(32000);
 ln_campo number;
 ld_campo date;
 ls_seperador_campo varchar2(5);
 ls_seperador_registro varchar2(5);
 ln_qtde_campos integer;
 l_colcnt integer;
 reg lista_campos;
 ln_doc int;
 ln_doc_cont int;
 blob_edit   BLOB; 
 ls_linha varchar2(32767);
 b_int binary_integer;
 c INTEGER;
 fdbk integer;
 ln_tamanho number;
 primeiro_registro boolean:=true;
 ls_query varchar2(2000);
 vtemp RAW(32000);
vend NUMBER := 1;
vlen NUMBER := 1;
vstart NUMBER := 1;

vend2 NUMBER := 1;
vlen2 NUMBER := 1;
vstart2 NUMBER := 1;
i number;
bytelen NUMBER := 32000;
ultimo_campo boolean;
registros number:=0;     
diretorio varchar2(250) :='IMPORTACAO_TRACEGP';
arquivo varchar2(250) :='SCRIPT_GERADO_CARGA_INICIAL.sql' ;

blob_edit1             BLOB; 
blob_edit2             BLOB; 
blob_edit3             BLOB; 
blob_edit4             BLOB; 
blob_edit5             BLOB; 
blob_edit6             BLOB; 

TYPE t_dados IS VARRAY(100) OF varchar2(32000);
dados t_dados:=t_dados();

type    Array1D is table of Number;
type    Array2D is table of Array1D;
array   Array2D;
vFILE_SAIDA    SYS.UTL_FILE.FILE_TYPE;

begin
vFILE_SAIDA  := SYS.UTL_FILE.FOPEN( diretorio, arquivo, 'w',32767 );

ls_seperador_campo:=chr(9);  -- TAB
ls_seperador_campo:=chr(35); -- #
ls_seperador_registro:=chr(13)||chr(10);
  
select conteudo into blob_edit
from documento_conteudo
where documento_id=ln_seq;

vlen:=dbms_lob.getlength(blob_edit);
bytelen := 32000;
vstart := 1;
vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);


--vlen:=100;
WHILE vstart < vlen 
LOOP
--dbms_output.put_line('newline:'||vstart);
--dbms_output.put_line('newline:'||vend);
vlen2:=vend-vstart+1;
   dbms_lob.read(blob_edit,vlen2,vstart,vtemp);
   ls_linha:=utl_raw.cast_to_varchar2(vtemp);
    registros:=registros+1;
    
vend2 := 1;
--vlen2 := length(ls_linha);
--dbms_output.put_line('Linha text:'||ls_linha);
vstart2 := 1;
vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);

i:=1;     
ultimo_campo:=false;
WHILE vstart2 < vlen2 or ultimo_campo
LOOP
--dbms_output.put_line('len2:'||vlen2);
--dbms_output.put_line('start2:'||vstart2);
--dbms_output.put_line('vend2:'||vend2);

     select t_tipo_campos(sec,nome,tipo,tamanho,decimais,separador,formato,obrigatorio,opcoes,descricao)
     BULK COLLECT INTO reg     from table(f_lista_campos) where sec=i;

   ls_campo:=substr(ls_linha, vstart2, vend2-vstart2);
--   dbms_output.put_line('Campo:'||reg(1).sec||':'||reg(1).nome||' Tipo:'||reg(1).tipo||' Valor:'||ls_campo);
   dados.extend;
   dados(i):=replace(ls_campo,'''','''''');
   vstart2:=vend2+length(ls_seperador_campo);
  if not ultimo_campo then
     vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);
  else
     ultimo_campo:=false;
  end if;


  if vend2 =0 then
    ultimo_campo:=true;
    vend2:=vlen2;
  end if;
i:=i+1;
END LOOP;
array := new Array2D(
                                  Array1D(5,43),
                                  Array1D(6,16),
                                  Array1D(7,17),
                                  Array1D(9,15),
                                  Array1D(15,70),
                                  Array1D(18,71),
                                  Array1D(19,72),
                                  Array1D(20,73),
                                  Array1D(21,74),
                                  Array1D(22,75),
                                  Array1D(23,76)
                                  
                     );   

   DBMS_LOB.CREATETEMPORARY(blob_edit1,TRUE);
   DBMS_LOB.CREATETEMPORARY(blob_edit2,TRUE);
   DBMS_LOB.CREATETEMPORARY(blob_edit3,TRUE);
   DBMS_LOB.CREATETEMPORARY(blob_edit4,TRUE);
   DBMS_LOB.CREATETEMPORARY(blob_edit5,TRUE);
   DBMS_LOB.CREATETEMPORARY(blob_edit6,TRUE);

   --------------------------------------
   -- Inicio do Processamento da Linha --
   --------------------------------------
--if registros < 1000 then

   if dados(1)='10' then -- PROJETOS
     if registros=1 then
          SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'declare');
          SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   ln_id_proj number;');              
          SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   ln_id_atr  number;');              
          SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'begin');
    end if;
--     dbms_output.put_line(dados(21));
     SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,' ');
     SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   SELECT projeto_seq.nextval INTO ln_id_proj FROM dual;');
     SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   INSERT INTO PROJETO (ID,TITULO,DESCRICAO,HORASPREVISTAS,HORASREALIZADAS,PRAZOPREVISTO,PRAZOREALIZADO,SITUACAO,SISTEMA,ORDEM,DATAINICIO,DATAFIMORCAMENTO,PORCENTAGEMCONCLUIDA,PERMITETEMPLATE,TIPOPROJETOID,INICIOREALIZADO,DURACAO,TIPORESTRICAO,DATARESTRICAO,ATUALIZARHORASPREVISTAS,CPI_MONETARIO,SPI_MONETARIO,ENTIDADE_PAI,CONSIDERAR_CUSTO,ALTERAR_PERC_CONCLUIDO,PERMITE_CUSTO_APENAS_TAREFA,EDICAO_EXCLUSIVA,MODIFICADOR,MOTIVO,DASHBOARD_ID,UO_ID,PROJETO_TEMPLATE_ID)');
     SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'      SELECT ln_id_proj,'''|| dados(2)|| ' - ' || dados(3)|| ''',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,''A'',''N'',''Y'',null,''310'',null,null,null,null FROM dual;');

     SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   INSERT INTO RESPONSAVELENTIDADE (TIPOENTIDADE, RESPONSAVEL, IDENTIDADE)');
     SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'      select ''P'', nvl((select u.usuarioid from usuario u where upper(nome) = upper('''|| dados(4)|| ''')),''310''), ln_id_proj from dual;');

         for x in 1..array.Count
         loop
             if array(x)(2) in(73) then  -- DATA
                 if (nvl(trim(dados(array(x)(1))),'-1') <> '-1') then
                   SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   SELECT atributoentidadevalor_seq.nextval INTO ln_id_atr FROM dual;');
                   SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   INSERT INTO ATRIBUTOENTIDADEVALOR (ATRIBUTOENTIDADEID,TIPOENTIDADE,IDENTIDADE,ATRIBUTOID,VALORDATA)');
                   ls_campo:='      SELECT ln_id_atr, ''P'', ln_id_proj, ' || array(x)(2) ||',to_date('''|| dados(array(x)(1)) || ''',''DD/MM/YYYY'') FROM dual;';
                   SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,ls_campo);
                 end if;
             else -- TEXTO
             if (nvl(trim(dados(array(x)(1))),'-1') <> '-1') then
               SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   SELECT atributoentidadevalor_seq.nextval INTO ln_id_atr FROM dual;');
               SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   INSERT INTO ATRIBUTOENTIDADEVALOR (ATRIBUTOENTIDADEID,TIPOENTIDADE,IDENTIDADE,ATRIBUTOID,VALOR)');
               ls_campo:='      SELECT ln_id_atr, ''P'', ln_id_proj, ' || array(x)(2) ||','''|| trim(dados(array(x)(1))) || ''' FROM dual;';
               SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,ls_campo);
             end if;
             end if;
         end loop;
     SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   -- Escopo');
     SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   INSERT INTO RESPONSAVELENTIDADE (TIPOENTIDADE, RESPONSAVEL, IDENTIDADE)');
--     SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   INSERT INTO ESCOPO (Projeto) values (' || ln_id_proj || ');');

--   if (nvl(trim(dados(8)),'-1') <> '-1') then
--   end if;

/*
    b_int:=utl_raw.length (utl_raw.cast_to_raw(dados(8)));
    
    if (primeiro_registro) then
      dbms_lob.write(blob_edit, b_int, 1, utl_raw.cast_to_raw(ls_linha));
      primeiro_registro:=false;
    else
      dbms_lob.writeappend(blob_edit, b_int , utl_raw.cast_to_raw(ls_linha));
    end if;

 END LOOP;

 select documento_seq.nextval into ln_doc from dual;
 select documento_conteudo_seq.nextval into ln_doc_cont from dual;

 Insert into DOCUMENTO (DOCUMENTOID,DESCRICAO, TIPOENTIDADE,IDENTIDADE,
                        AREAGERENCIA,ESTADODOCUMENTO,VERSAOATUAL,TIPODOCUMENTO,
                        RESPONSAVEL,DOCUMENTO_PAI,TIPO_DOCUMENTO_ID,TAMANHO) 
 select ln_doc,trim(ls_tipo)||'-'||to_char(ln_ano)||' Exportado em '||to_char(sysdate,'DD-MM-YYYY HH24-MI-SS'),null,null,
        null,'I',1,'.txt',
        null,null,null,null 
     from dual;

 insert into documento_conteudo (id, documento_id, versao, conteudo)
 values (ln_doc_cont, ln_doc, 1, empty_blob());-- returning conteudo into blob_edit;

 update documento_conteudo
 set conteudo = blob_edit
 where id=ln_doc_cont;

 dbms_lob.FREETEMPORARY(blob_edit);

*/
   end if;
--end if;
   --------------------------------------
   -- FIM do Processamento da Linha    --
   --------------------------------------

   vstart:=vend+length(ls_seperador_registro);
   vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);
   dados:=t_dados();
END LOOP;
SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'end;');
SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'--Linha:'||registros);
SYS.UTL_FILE.FFLUSH(vFILE_SAIDA);
SYS.UTL_FILE.FCLOSE(vFILE_SAIDA);

ln_retorno:=registros;

end p_Carga_Inicial_Script;

procedure p_Carga_Inicial(ln_seq number, ln_retorno in out number)
is
ls_campo VARCHAR2(32000);
 ln_campo number;
 ld_campo date;
 ls_seperador_campo varchar2(5);
 ls_seperador_registro varchar2(5);
 ln_qtde_campos integer;
 l_colcnt integer;
 reg lista_campos;
 ln_doc int;
 ln_doc_cont int;
 blob_edit   BLOB; 
 ls_linha varchar2(32767);
 b_int binary_integer;
 c INTEGER;
 fdbk integer;
 ln_tamanho number;
 primeiro_registro1 boolean:=true;
 primeiro_registro2 boolean:=true;
 primeiro_registro3 boolean:=true;
 primeiro_registro4 boolean:=true;
 primeiro_registro5 boolean:=true;
 primeiro_registro6 boolean:=true;
 primeiro_registro7 boolean:=true;
 primeiro_registro8 boolean:=true;

 ls_query varchar2(2000);
 vtemp RAW(32000);
vend NUMBER := 1;
vlen NUMBER := 1;
vstart NUMBER := 1;

vend2 NUMBER := 1;
vlen2 NUMBER := 1;
vstart2 NUMBER := 1;
i number;
bytelen NUMBER := 32000;
ultimo_campo boolean;
registros number:=0;     
ln_id_proj number:=0;              
ln_id_ativ number:=0;              
ln_id_tar number:=0;              
ln_tipo  number:=0;
ln_id_atr  number:=0;              
ln_categ number:=0;
ls_tipo varchar2(1);
lb_erro boolean:=false;
blob_edit1             CLOB; 
blob_edit2             CLOB; 
blob_edit3             CLOB; 
blob_edit4             CLOB; 
blob_edit5             CLOB; 
blob_edit6             CLOB; 

TYPE t_dados IS VARRAY(100) OF varchar2(32000);
dados t_dados:=t_dados();

type    Array1D is table of Number;
type    Array2D is table of Array1D;
array   Array2D;
array2   Array2D;

begin

ls_seperador_campo:=chr(9);  -- TAB
ls_seperador_campo:=chr(35); -- #
ls_seperador_registro:=chr(13)||chr(10);
  
select conteudo into blob_edit
from documento_conteudo
where documento_id=ln_seq;

vlen:=dbms_lob.getlength(blob_edit);
bytelen := 32000;
vstart := 1;
vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);

begin
--vlen:=100;
WHILE vstart < vlen 
LOOP
--dbms_output.put_line('newline:'||vstart);
--dbms_output.put_line('newline:'||vend);
vlen2:=vend-vstart+1;
   dbms_lob.read(blob_edit,vlen2,vstart,vtemp);
   ls_linha:=utl_raw.cast_to_varchar2(vtemp);
    registros:=registros+1;
    
vend2 := 1;
--vlen2 := length(ls_linha);
--dbms_output.put_line('Linha text:'||ls_linha);
vstart2 := 1;
vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);

i:=1;     
ultimo_campo:=false;
WHILE vstart2 < vlen2 or ultimo_campo
LOOP
--dbms_output.put_line('len2:'||vlen2);
--dbms_output.put_line('start2:'||vstart2);
--dbms_output.put_line('vend2:'||vend2);

     select t_tipo_campos(sec,nome,tipo,tamanho,decimais,separador,formato,obrigatorio,opcoes,descricao)
     BULK COLLECT INTO reg     from table(f_lista_campos) where sec=i;

   ls_campo:=substr(ls_linha, vstart2, vend2-vstart2);
--   dbms_output.put_line('Campo:'||reg(1).sec||':'||reg(1).nome||' Tipo:'||reg(1).tipo||' Valor:'||ls_campo);
   dados.extend;
   dados(i):=replace(ls_campo,'''','''''');
   vstart2:=vend2+length(ls_seperador_campo);
  if not ultimo_campo then
     vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);
  else
     ultimo_campo:=false;
  end if;


  if vend2 =0 then
    ultimo_campo:=true;
    vend2:=vlen2;
  end if;
i:=i+1;
END LOOP;


array := new Array2D(                  -- ordem , atributo
                                  Array1D(5,43),
                                  Array1D(6,16),
                                  Array1D(7,17),
                                  Array1D(9,15),
                                  Array1D(15,70),
                                  Array1D(18,71),
                                  Array1D(19,72),
                                  Array1D(20,73),
                                  Array1D(21,74),
                                  Array1D(22,75),
                                  Array1D(23,76),
                                  Array1D(17,80),
                                  Array1D(10,11),
                                  Array1D(11,2)
                                  
                     );   

array2 := new Array2D(                  -- ordem , atributo
                                  Array1D(2,7),
                                  Array1D(3,8),
                                  Array1D(4,9)
                                  
                     );   

   --------------------------------------
   -- Inicio do Processamento da Linha --
   --------------------------------------
--if registros < 1000 then

   if dados(1)='10' then -- PROJETOS

       
       SELECT projeto_seq.nextval INTO ln_id_proj FROM dual;
       IF primeiro_registro1 THEN
         dbms_output.put_line('SELECT * FROM PROJETO WHERE ID >= '||ln_id_proj);
         dbms_output.put_line('SELECT * FROM RESPONSAVELENTIDADE WHERE IDENTIDADE >= '||ln_id_proj);
         dbms_output.put_line('SELECT * FROM ATRIBUTOENTIDADEVALOR WHERE IDENTIDADE >= '||ln_id_proj);
         dbms_output.put_line('SELECT * FROM ESCOPO WHERE PROJETO >= '||ln_id_proj);
         dbms_output.put_line('SELECT * FROM PRODUTOENTREGAVEL WHERE PROJETO >= '||ln_id_proj);
         dbms_output.put_line('SELECT * FROM PREMISSA WHERE PROJETO >= '||ln_id_proj);
         dbms_output.put_line('SELECT * FROM RESTRICAO WHERE PROJETO >= '||ln_id_proj);
         dbms_output.put_line('SELECT * FROM OCORRENCIA_ENTIDADE WHERE ENTIDADE_ID >= '||ln_id_proj);
         
         primeiro_registro1:=FALSE;
       END IF;

       INSERT INTO PROJETO (ID,TITULO,DESCRICAO,HORASPREVISTAS,HORASREALIZADAS,PRAZOPREVISTO,PRAZOREALIZADO,SITUACAO,SISTEMA,ORDEM,DATAINICIO,DATAFIMORCAMENTO,PORCENTAGEMCONCLUIDA,PERMITETEMPLATE,TIPOPROJETOID,INICIOREALIZADO,DURACAO,TIPORESTRICAO,DATARESTRICAO,ATUALIZARHORASPREVISTAS,CPI_MONETARIO,SPI_MONETARIO,ENTIDADE_PAI,CONSIDERAR_CUSTO,ALTERAR_PERC_CONCLUIDO,PERMITE_CUSTO_APENAS_TAREFA,EDICAO_EXCLUSIVA,MODIFICADOR,MOTIVO,DASHBOARD_ID,UO_ID,PROJETO_TEMPLATE_ID)
             SELECT ln_id_proj, dados(2)|| ' - ' || dados(3),dados(12),null,null,null,null,1,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,'A','N','Y',null,'310',null,null,null,null FROM dual;

       INSERT INTO RESPONSAVELENTIDADE (TIPOENTIDADE, RESPONSAVEL, IDENTIDADE)
              select 'P', nvl((select u.usuarioid from usuario u where upper(nome) = upper(dados(4))),'310'), ln_id_proj from dual;

       if (nvl(trim(dados(16)),'-1') <> '-1') then

            if length(trim(dados(16)))>4000 then
              dbms_output.put_line('Trunc Ocorrencia Proj:'||ln_id_proj||'  (4000) - Tamanho:' || length(trim(dados(16))));
              dados(16) := substr(trim(dados(16)),1,3997) || '...' ;
            end if;

          SELECT ocorrencia_entidade_seq.nextval INTO ln_id_atr FROM dual;
          INSERT INTO OCORRENCIA_ENTIDADE (ASSUNTO,DATA,ENTIDADE_ID,
                                           NOTIFICAR,OCORRENCIA_ID,USUARIO,
                                           BASE_CONHECIMENTO_ID,TIPO_ENTIDADE,TIPO_OCORRENCIA_ID)
                 select dados(16),null,ln_id_proj,
                        null,ln_id_atr,null,
                        null,'P',null  
                      from dual;
        
       end if;

/*
       if (nvl(trim(dados(17)),'-1') <> '-1') then
          dbms_output.put_line('EQUIPE:'||trim(dados(17)));
       end if;
       if (nvl(trim(dados(11)),'-1') <> '-1') then
          dbms_output.put_line('CR:'||trim(dados(11)));
       end if;*/

         for x in 1..array.Count
         loop
             if array(x)(2) in(73) then  -- DATA
                 if (nvl(trim(dados(array(x)(1))),'-1') <> '-1') then
                   SELECT atributoentidadevalor_seq.nextval INTO ln_id_atr FROM dual;
                   INSERT INTO ATRIBUTOENTIDADEVALOR (ATRIBUTOENTIDADEID,TIPOENTIDADE,IDENTIDADE,ATRIBUTOID,VALORDATA)
                     SELECT ln_id_atr, 'P', ln_id_proj, array(x)(2) ,to_date(dados(array(x)(1)) ,'DD/MM/YYYY') FROM dual;
                 end if;
             elsif  array(x)(2) in(2) then  -- Centro de Responsabilidade
                ln_categ:=0;
                begin
                select categoria_item_id into ln_categ from categoria_item_atributo where titulo like '2010%'||dados(array(x)(1))||'-%' and atributo_id=array(x)(2);

                   SELECT atributoentidadevalor_seq.nextval INTO ln_id_atr FROM dual;
                   INSERT INTO ATRIBUTOENTIDADEVALOR (ATRIBUTOENTIDADEID,TIPOENTIDADE,IDENTIDADE,ATRIBUTOID,Categoria_Item_Atributo_Id)
                     SELECT ln_id_atr, 'P', ln_id_proj, array(x)(2), ln_categ FROM dual;

                exception when no_data_found then
                  ln_categ:=0;
                    dbms_output.put_line('Projeto:'||ln_id_proj||'  Atributo Centro Responsabilidade não localizado: '||dados(array(x)(1)) );
                  when others then
                  ln_categ:=0;
                    dbms_output.put_line('Projeto:'||ln_id_proj||'  Atributo Centro Responsabilidade localizou mais de 1 CR: '||dados(array(x)(1)) );
                end; 
               
             
             else -- TEXTO
                 if (nvl(trim(dados(array(x)(1))),'-1') <> '-1') then
                      if length(trim(dados(array(x)(1))))>4000 then
                        dbms_output.put_line('Trunc Projeto:'||ln_id_proj||'  Atributo (4000) '||array(x)(2) || ' - Tamanho:' || length(trim(dados(array(x)(1)))));
                        dados(array(x)(1)) := substr(trim(dados(array(x)(1))),1,3997) || '...' ;
                      end if;
                      SELECT atributoentidadevalor_seq.nextval INTO ln_id_atr FROM dual;
                      INSERT INTO ATRIBUTOENTIDADEVALOR (ATRIBUTOENTIDADEID,TIPOENTIDADE,IDENTIDADE,ATRIBUTOID,VALOR)
                          SELECT ln_id_atr, 'P', ln_id_proj, array(x)(2), trim(dados(array(x)(1))) FROM dual;
                 end if;
             end if;
         end loop;

      if (nvl(trim(dados(8)),'-1') <> '-1') then

          select max(id)+1 into ln_id_atr from produtoentregavel;
          insert into produtoentregavel (ID, Projeto, descricao)
          values (ln_id_atr,ln_id_proj,dados(8));  
          
      end if;
   end if;
   if dados(1)='20' then -- Escopo

      INSERT INTO ESCOPO (PROJETO, FECHADO, DESCPRODUTO,JUSTIFICATIVAPROJETO,OBJETIVOSPROJETO,LIMITESPROJETO,LISTAFATORESESSENCIAIS) 
         select ln_id_proj, 'S', empty_clob(), empty_clob(), empty_clob(), empty_clob(), empty_clob() from dual;

      if (nvl(trim(dados(2)),'-1') <> '-1') then
          DBMS_LOB.CREATETEMPORARY(blob_edit1,TRUE);
          b_int:=length(dados(2));
          dbms_lob.write(blob_edit1, b_int, 1, dados(2));
          update escopo 
            set DESCPRODUTO=blob_edit1 
            where projeto = ln_id_proj;
          dbms_lob.FREETEMPORARY(blob_edit1);
      end if;
      if (nvl(trim(dados(3)),'-1') <> '-1') then
          DBMS_LOB.CREATETEMPORARY(blob_edit1,TRUE);
          b_int:=length(dados(3));
          dbms_lob.write(blob_edit1, b_int, 1, dados(3));
          update escopo 
            set JUSTIFICATIVAPROJETO=blob_edit1 
            where projeto = ln_id_proj;
          dbms_lob.FREETEMPORARY(blob_edit1);
      end if;
      if (nvl(trim(dados(4)),'-1') <> '-1') then
          DBMS_LOB.CREATETEMPORARY(blob_edit1,TRUE);
          b_int:=length(dados(4));
          dbms_lob.write(blob_edit1, b_int, 1, dados(4));
          update escopo 
            set OBJETIVOSPROJETO=blob_edit1 
            where projeto = ln_id_proj;
          dbms_lob.FREETEMPORARY(blob_edit1);
      end if;
      if (nvl(trim(dados(5)),'-1') <> '-1') then
          DBMS_LOB.CREATETEMPORARY(blob_edit1,TRUE);
          b_int:=length(dados(5));
          dbms_lob.write(blob_edit1, b_int, 1, dados(5));
          update escopo 
            set LIMITESPROJETO=blob_edit1 
            where projeto = ln_id_proj;
          dbms_lob.FREETEMPORARY(blob_edit1);
      end if;

      if (nvl(trim(dados(6)),'-1') <> '-1') then

          select max(id)+1 into ln_id_atr from premissa;

          insert into premissa (ID, Projeto, descricao)
          values (ln_id_atr,ln_id_proj,dados(6));

      end if;

      if (nvl(trim(dados(7)),'-1') <> '-1') then

          select max(id)+1 into ln_id_atr from restricao;

          insert into restricao (ID, Projeto, descricao)
          values (ln_id_atr,ln_id_proj,dados(7));

      end if;
   end if;

   if dados(1)='30' then -- INICIO Atividades

      SELECT atividade_seq.nextval INTO ln_id_ativ FROM dual;
       IF primeiro_registro2 THEN
         dbms_output.put_line('SELECT * FROM ATIVIDADE WHERE ID >= '||ln_id_ativ);
         primeiro_registro2:=FALSE;
       END IF;
/*
      dbms_output.put_line('D5:'||trim(dados(5)));
      dbms_output.put_line('D6:'||trim(dados(6)));
      dbms_output.put_line('D7:'||trim(dados(7)));
      dbms_output.put_line('D8:'||trim(dados(8)));
*/
      if length(trim(dados(2)))>150 then
        dbms_output.put_line('Trunc Atividade:'||ln_id_ativ||'  Titulo (150) - Tamanho:' || length(trim(dados(2))));
        dados(2) := substr(trim(dados(2)),1,147) || '...' ;
      end if;

      INSERT INTO ATIVIDADE (ID, TITULO, MODIFICADOR, 
                  DESCRICAO,
                  datainicio,
                  prazoprevisto,		
                  iniciorealizado,		
                  prazorealizado,
                  Situacao, Projeto)
             select ln_id_ativ,  dados(2), nvl((select u.usuarioid from usuario u where upper(nome) = upper(dados(3))),'310'), 
                    dados(4),
                    trunc(to_date(trim(dados(5)) ,'DD/MM/YYYY HH24:MI:SS')),
                    trunc(to_date(trim(dados(6)) ,'DD/MM/YYYY HH24:MI:SS')),
                    trunc(to_date(trim(dados(7)) ,'DD/MM/YYYY HH24:MI:SS')),
                    trunc(to_date(trim(dados(8)) ,'DD/MM/YYYY HH24:MI:SS')),
                    1,ln_id_proj
                     from dual;

       INSERT INTO RESPONSAVELENTIDADE (TIPOENTIDADE, RESPONSAVEL, IDENTIDADE)
              select 'A', nvl((select u.usuarioid from usuario u where upper(nome) = upper(dados(3))),'310'), ln_id_ativ from dual;

       if (nvl(trim(dados(15)),'-1') <> '-1') then  -- Atributo Resultados de Atividades
            if length(trim(dados(15)))>4000 then
              dbms_output.put_line('Trunc Atividade:'||ln_id_ativ||'  Atributo (4000) 77 - Tamanho:' || length(trim(dados(15))));
              dados(15) := substr(trim(dados(15)),1,3997) || '...' ;
            end if;
            SELECT atributoentidadevalor_seq.nextval INTO ln_id_atr FROM dual;
            INSERT INTO ATRIBUTOENTIDADEVALOR (ATRIBUTOENTIDADEID,TIPOENTIDADE,IDENTIDADE,ATRIBUTOID,VALOR)
                SELECT ln_id_atr, 'A', ln_id_ativ, 77, trim(dados(15)) FROM dual;
       end if;

       if (nvl(trim(dados(16)),'-1') <> '-1') then

            if length(trim(dados(16)))>4000 then
              dbms_output.put_line('Trunc Ocorrencia Ativ:'||ln_id_ativ||'  (4000) - Tamanho:' || length(trim(dados(16))));
              dados(16) := substr(trim(dados(16)),1,3997) || '...' ;
            end if;

          SELECT ocorrencia_entidade_seq.nextval INTO ln_id_atr FROM dual;
          INSERT INTO OCORRENCIA_ENTIDADE (ASSUNTO,DATA,ENTIDADE_ID,
                                           NOTIFICAR,OCORRENCIA_ID,USUARIO,
                                           BASE_CONHECIMENTO_ID,TIPO_ENTIDADE,TIPO_OCORRENCIA_ID)
                 select dados(16),null,ln_id_proj,
                        null,ln_id_atr,null,
                        null,'P',null  
                      from dual;
        
       end if;

       if (nvl(trim(dados(17)),'-1') <> '-1') then  -- Atributo Recomendações
            if length(trim(dados(17)))>4000 then
              dbms_output.put_line('Trunc Atividade:'||ln_id_ativ||'  Atributo (4000) 78 - Tamanho:' || length(trim(dados(17))));
              dados(17) := substr(trim(dados(17)),1,3997) || '...' ;
            end if;
            SELECT atributoentidadevalor_seq.nextval INTO ln_id_atr FROM dual;
            INSERT INTO ATRIBUTOENTIDADEVALOR (ATRIBUTOENTIDADEID,TIPOENTIDADE,IDENTIDADE,ATRIBUTOID,VALOR)
                SELECT ln_id_atr, 'A', ln_id_ativ, 78, trim(dados(17)) FROM dual;
       end if;

       if (nvl(trim(dados(12)),'-1') <> '-1') then
          dbms_output.put_line('TIPO:'||trim(dados(12)));
       end if;
       if (nvl(trim(dados(13)),'-1') <> '-1') then
          dbms_output.put_line('PREDECES:'||trim(dados(13)));
       end if;

   end if;  -- FIM Atividades

   if dados(1)='40' then -- INICIO Tarefas

      SELECT tarefa_seq.nextval INTO ln_id_tar FROM dual;
       IF primeiro_registro3 THEN
         dbms_output.put_line('SELECT * FROM TAREFA WHERE ID >= '||ln_id_tar);
         primeiro_registro3:=FALSE;
       END IF;

--      dbms_output.put_line('Tit ini hor:'||dados(2) ||'-' || trim(dados(6))||'-' || trim(dados(10)));

      
      if length(trim(dados(2)))>150 then
        dbms_output.put_line('Trunc TAREFA:'||ln_id_tar||'  Titulo (150) - Tamanho:' || length(trim(dados(2))));
        dados(2) := substr(trim(dados(2)),1,147) || '...' ;
      end if;

      INSERT INTO TAREFA (ID, TITULO, MODIFICADOR, 
                  DESCRICAO,
                  datainicio,
                  prazoprevisto,		
                  iniciorealizado,		
                  prazorealizado,
                  Atividade,
                  horasprevistas,
                  horasrealizadas,
                  situacao, projeto)
             select ln_id_tar,  dados(2), nvl((select u.usuarioid from usuario u where upper(nome) = upper(dados(4))),'310'), 
                    dados(5),
                    trunc(to_date(trim(dados(6)) ,'DD/MM/YYYY HH24:MI:SS')),
                    trunc(to_date(trim(dados(7)) ,'DD/MM/YYYY HH24:MI:SS')),
                    trunc(to_date(trim(dados(8)) ,'DD/MM/YYYY HH24:MI:SS')),
                    trunc(to_date(trim(dados(9)) ,'DD/MM/YYYY HH24:MI:SS')),
                    ln_id_ativ,
                    trim(dados(10)),
                    trim(dados(11)),
                    1,ln_id_proj
                from dual;

       INSERT INTO RESPONSAVELENTIDADE (TIPOENTIDADE, RESPONSAVEL, IDENTIDADE)
              select 'T', nvl((select u.usuarioid from usuario u where upper(nome) = upper(dados(4))),'310'), ln_id_tar from dual;

   end if;  -- FIM Tarefas

   if dados(1)='50' then -- INICIO Metas

      ls_campo:='Descrição:' || nvl(trim(dados(2)),' ');
      ls_campo:=ls_campo||'Indicador:'|| nvl(trim(dados(3)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'Tarefa ou Atividade Vinculada:'|| nvl(trim(dados(4)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'Critério (Status ou Acumulado):'|| nvl(trim(dados(5)),' ')  || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'Unidade de medida:'|| nvl(trim(dados(6)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'Ano:'|| nvl(trim(dados(7)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'mês limite:'|| nvl(trim(dados(8)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'Previsto:'|| nvl(trim(dados(9)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'Retificado:'|| nvl(trim(dados(10)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'Revisado:'|| nvl(trim(dados(11)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'Realizado:'|| nvl(trim(dados(12)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'Observações:'|| nvl(trim(dados(13)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'% de desempenho:'|| nvl(trim(dados(14)),' ') || CHR(13) || CHR(10);

      if length(ls_campo)>4000 then
        dbms_output.put_line('Trunc Metas do Projeto:'||ln_id_proj||'  Atributo (4000) 79 - Tamanho:' || length(ls_campo));
        ls_campo := substr(trim(ls_campo),1,3997) || '...' ;
      end if;
      SELECT atributoentidadevalor_seq.nextval INTO ln_id_atr FROM dual;
      INSERT INTO ATRIBUTOENTIDADEVALOR (ATRIBUTOENTIDADEID,TIPOENTIDADE,IDENTIDADE,ATRIBUTOID,VALOR)
          SELECT ln_id_atr, 'P', ln_id_proj, 79, trim(ls_campo) FROM dual;

   end if;  -- FIM Metas

   if dados(1) in ('60','90') then -- INICIO Despesas / Receitas
      ln_categ:=0;
      lb_erro:=false;
      
      if dados(1)='60' then 
         ls_tipo:='C';
      else
         ls_tipo:='R';
      end if;
      begin
        
         select ID into ln_categ
           from custo_receita where trim(Titulo) like trim(dados(2)) || ' %' || trim(dados(3))|| '% - %' and tipo=ls_tipo;-- and vigente = 'Y';
      exception
         when no_data_found then
         dbms_output.put_line('Projeto:'||ln_id_proj ||' Não localizou na Árvore de custos:'||trim(dados(2)) || ' - ' || trim(dados(3))|| ' Tipo:'||ls_tipo);
         lb_erro:=true;
         when others then
         dbms_output.put_line('Projeto:'||ln_id_proj ||' Árvore de custos com mais de 1 registro para:'||trim(dados(2)) || ' - ' || trim(dados(3))|| ' Tipo:'||ls_tipo);
         lb_erro:=true;
      end;
      
      if not lb_erro then

      -- inclui permissoes automaticas para inclusão de lançamento
      ln_id_atr:=0;
       select count(1) 
         into       ln_id_atr
         from custo_receita_forma crf
        where crf.forma_id         = case ls_tipo when 'C' then 7 else 8 end
          and crf.vigente          = 'Y'
          and crf.custo_receita_id = ln_categ;

      if ln_id_atr=0 then

         SELECT custo_receita_forma_seq.nextval INTO ln_tipo FROM dual;

         IF primeiro_registro6 THEN
           dbms_output.put_line('SELECT * FROM CUSTO_RECEITA_FORMA WHERE ID >= '||ln_tipo);
           primeiro_registro6:=FALSE;
         END IF;

         insert into custo_receita_forma (ID,CUSTO_RECEITA_ID,FORMA_ID,VIGENCIA,VIGENTE,VALOR_DEFAULT)
         select ln_tipo, ln_categ, case ls_tipo when 'C' then 7 else 8 end, sysdate, 'Y' ,'N'
         from dual;  

      end if;

      ln_id_atr:=0;
       select count(1) 
         into       ln_id_atr
         from custo_receita_tipo crt
        where crt.tipo_id          = case ls_tipo when 'C' then 3 else 4 end
          and crt.vigente          = 'Y'
          and crt.custo_receita_id = ln_categ;

      if ln_id_atr=0 then

         SELECT custo_receita_tipo_seq.nextval INTO ln_tipo FROM dual;

         IF primeiro_registro7 THEN
           dbms_output.put_line('SELECT * FROM CUSTO_RECEITA_TIPO WHERE ID >= '||ln_tipo);
           primeiro_registro7:=FALSE;
         END IF;

         insert into custo_receita_tipo (ID,CUSTO_RECEITA_ID,TIPO_ID,VIGENCIA,VIGENTE,VALOR_DEFAULT)
         select ln_tipo, ln_categ, case ls_tipo when 'C' then 3 else 4 end, sysdate, 'Y' ,'N'
         from dual;  

      end if;
        
      ln_id_atr:=0;
        
      select nvl(min(id),0) into ln_id_atr
      from custo_entidade 
        where TIPO_ENTIDADE='P' and
              ENTIDADE_ID=ln_id_proj and
              CUSTO_RECEITA_ID=ln_categ;


      if ln_id_atr=0 then

        SELECT custo_entidade_seq.nextval INTO ln_id_atr FROM dual;

         IF primeiro_registro4 THEN
           dbms_output.put_line('SELECT * FROM CUSTO_ENTIDADE WHERE ID >= '||ln_id_atr);
           primeiro_registro4:=FALSE;
         END IF;

        insert into custo_entidade (ID,TIPO_ENTIDADE,ENTIDADE_ID,CUSTO_RECEITA_ID,
                                    TITULO,TIPO_DESPESA_ID,FORMA_AQUISICAO_ID,
                                    UNIDADE,MOTIVO)
           select ln_id_atr,'P',ln_id_proj,ln_categ,
                  trim(dados(3)), case ls_tipo when 'C' then 3 else 4 end, case ls_tipo when 'C' then 7 else 8 end,
                  null, null
                  from dual;

      end if;
      

 
      -- R Realizado
      if (nvl(trim(dados(8)),'-1') <> '-1') and to_number(dados(8))>0 then

         SELECT custo_lancamento_seq.nextval INTO ln_id_tar FROM dual;
         IF primeiro_registro5 THEN
           dbms_output.put_line('SELECT * FROM CUSTO_LANCAMENTO WHERE ID >= '||ln_id_tar);
           primeiro_registro5:=FALSE;
         END IF;

         insert into custo_lancamento  (ID,CUSTO_ENTIDADE_ID,TIPO,SITUACAO,
                                        DATA,VALOR_UNITARIO,QUANTIDADE,VALOR,
                                        USUARIO_ID,DATA_ALTERACAO)
           select ln_id_tar,ln_id_atr,'R','V',  -- realizado, válido
                  trunc(to_date(trim(dados(4)) ,'DD/MM/YYYY HH24:MI:SS')),
                  to_number(dados(8)),1,to_number(dados(8)),'310',
                  trunc(to_date(trim(dados(4)) ,'DD/MM/YYYY HH24:MI:SS'))
           from dual;
           
      end if;

      -- P Planejado
      if (nvl(trim(dados(5)),'-1') <> '-1') and to_number(dados(5))>0 then
         SELECT custo_lancamento_seq.nextval INTO ln_id_tar FROM dual;
         IF primeiro_registro5 THEN
           dbms_output.put_line('SELECT * FROM CUSTO_LANCAMENTO WHERE ID >= '||ln_id_atr);
           primeiro_registro5:=FALSE;
         END IF;
         insert into custo_lancamento  (ID,CUSTO_ENTIDADE_ID,TIPO,SITUACAO,
                                        DATA,VALOR_UNITARIO,QUANTIDADE,VALOR,
                                        USUARIO_ID,DATA_ALTERACAO)
           select ln_id_tar,ln_id_atr,'P','V',  -- realizado, válido
                  trunc(to_date(trim(dados(4)) ,'DD/MM/YYYY HH24:MI:SS')),
                  to_number(dados(5)),1,to_number(dados(5)),'310',
                  trunc(to_date(trim(dados(4)) ,'DD/MM/YYYY HH24:MI:SS'))
           from dual;
           
      end if;

      -- P Retificado
      if (nvl(trim(dados(6)),'-1') <> '-1') and to_number(dados(6))>0 then
        update custo_entidade
        set Motivo = nvl(Motivo,' ') || ' Refificado:' ||trim(dados(6))
        where id=ln_id_atr;
      end if;

      -- P Revisado
      if (nvl(trim(dados(7)),'-1') <> '-1') and to_number(dados(7))>0 then
        update custo_entidade
        set Motivo = nvl(Motivo,' ') || ' Revisado:' ||trim(dados(7))
        where id=ln_id_atr;
      end if;


      end if;
   end if;  -- FIM Despesas
 
   if dados(1) in ('80') then -- Origem dos recursos

         for x in 1..array2.Count
         loop
                 if (nvl(trim(dados(array2(x)(1))),'-1') <> '-1') then
                      if length(trim(dados(array2(x)(1))))>4000 then
                        dbms_output.put_line('Trunc Projeto:'||ln_id_proj||'  Atributo (4000) '||array2(x)(2) || ' - Tamanho:' || length(trim(dados(array2(x)(1)))));
                        dados(array2(x)(1)) := substr(trim(dados(array2(x)(1))),1,3997) || '...' ;
                      end if;
                      SELECT atributoentidadevalor_seq.nextval INTO ln_id_atr FROM dual;
                      INSERT INTO ATRIBUTOENTIDADEVALOR (ATRIBUTOENTIDADEID,TIPOENTIDADE,IDENTIDADE,ATRIBUTOID,VALOR)
                          SELECT ln_id_atr, 'P', ln_id_proj, array2(x)(2), trim(dados(array2(x)(1))) FROM dual;
                 end if;
         end loop;
   end if; -- FIM Origem dos recursos

  delete contadores where nometabela in ('RESTRICAO', 'PREMISSA', 'PRODUTOENTREGAVEL');
--end if;
   --------------------------------------
   -- FIM do Processamento da Linha    --
   --------------------------------------

   vstart:=vend+length(ls_seperador_registro);
   vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);
   dados:=t_dados();
END LOOP;

exception when others then
dbms_output.put_line('Erro linha:'||registros|| '  ' || sqlerrm);  
end;

ln_retorno:=registros;
--rollback;
end p_Carga_Inicial;          

procedure p_Importa_Custos(ln_seq number, ln_retorno in out number)
is
ls_campo VARCHAR2(32000);
 ln_campo number;
 ld_campo date;
 ls_seperador_campo varchar2(5);
 ls_seperador_registro varchar2(5);
 ln_qtde_campos integer;
 l_colcnt integer;
 reg lista_campos;
 ln_doc int;
 ln_doc_cont int;
 blob_edit   BLOB; 
 ls_linha varchar2(32767);
 b_int binary_integer;
 c INTEGER;
 fdbk integer;
 ln_tamanho number;
 primeiro_registro1 boolean:=true;
 primeiro_registro2 boolean:=true;
 primeiro_registro3 boolean:=true;
 primeiro_registro4 boolean:=true;
 primeiro_registro5 boolean:=true;
 primeiro_registro6 boolean:=true;
 primeiro_registro7 boolean:=true;
 primeiro_registro8 boolean:=true;

 ls_query varchar2(2000);
 vtemp RAW(32000);
vend NUMBER := 1;
vlen NUMBER := 1;
vstart NUMBER := 1;

vend2 NUMBER := 1;
vlen2 NUMBER := 1;
vstart2 NUMBER := 1;
i number;
bytelen NUMBER := 32000;
ultimo_campo boolean;
registros number:=0;     
ln_id_proj number:=0;              
ln_id_ativ number:=0;              
ln_id_ativc number:=0;
ln_id_tar number:=0;              
ln_id_tarc number:=0;              
ln_tipo  number:=0;
ln_id_atr  number:=0;              
ln_categ number:=0;
ls_tipo varchar2(1);
lb_erro boolean:=false;
blob_edit1             CLOB; 
blob_edit2             CLOB; 
blob_edit3             CLOB; 
blob_edit4             CLOB; 
blob_edit5             CLOB; 
blob_edit6             CLOB; 

TYPE t_dados IS VARRAY(100) OF varchar2(32000);
dados t_dados:=t_dados();

type    Array1D is table of Number;
type    Array2D is table of Array1D;
array   Array2D;
array2   Array2D;

begin

ls_seperador_campo:=chr(9);  -- TAB
--ls_seperador_campo:=chr(35); -- #
ls_seperador_registro:=chr(13)||chr(10);
  
select conteudo into blob_edit
from documento_conteudo
where documento_id=ln_seq;

vlen:=dbms_lob.getlength(blob_edit);
bytelen := 32000;
vstart := 1;
vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);

begin
--vlen:=100;
WHILE vstart < vlen 
LOOP
--dbms_output.put_line('newline:'||vstart);
--dbms_output.put_line('newline:'||vend);
vlen2:=vend-vstart+1;
   dbms_lob.read(blob_edit,vlen2,vstart,vtemp);
   ls_linha:=utl_raw.cast_to_varchar2(vtemp);
    registros:=registros+1;
    
vend2 := 1;
--vlen2 := length(ls_linha);
--dbms_output.put_line('Linha text:'||ls_linha);
vstart2 := 1;
vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);

i:=1;     
ultimo_campo:=false;
WHILE vstart2 < vlen2 or ultimo_campo
LOOP
--dbms_output.put_line('len2:'||vlen2);
--dbms_output.put_line('start2:'||vstart2);
--dbms_output.put_line('vend2:'||vend2);

     select t_tipo_campos(sec,nome,tipo,tamanho,decimais,separador,formato,obrigatorio,opcoes,descricao)
     BULK COLLECT INTO reg     from table(f_lista_campos) where sec=i;

   ls_campo:=substr(ls_linha, vstart2, vend2-vstart2);
--   dbms_output.put_line('Campo:'||reg(1).sec||':'||reg(1).nome||' Tipo:'||reg(1).tipo||' Valor:'||ls_campo);
   dados.extend;
   dados(i):=replace(ls_campo,'''','''''');
   vstart2:=vend2+length(ls_seperador_campo);
  if not ultimo_campo then
     vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);
  else
     ultimo_campo:=false;
  end if;


  if vend2 =0 then
    ultimo_campo:=true;
    vend2:=vlen2;
  end if;
i:=i+1;
END LOOP;


array := new Array2D(                  -- ordem , atributo
                                  Array1D(5,43),
                                  Array1D(6,16),
                                  Array1D(7,17),
                                  Array1D(9,15),
                                  Array1D(15,70),
                                  Array1D(18,71),
                                  Array1D(19,72),
                                  Array1D(20,73),
                                  Array1D(21,74),
                                  Array1D(22,75),
                                  Array1D(23,76),
                                  Array1D(17,80),
                                  Array1D(10,11),
                                  Array1D(11,2)
                                  
                     );   

array2 := new Array2D(                  -- ordem , atributo
                                  Array1D(2,7),
                                  Array1D(3,8),
                                  Array1D(4,9)
                                  
                     );   

   --------------------------------------
   -- Inicio do Processamento da Linha --
   --------------------------------------
--if registros < 1000 then

    lb_erro:=false;
    ln_id_proj:=0;
    ls_tipo:='C';

--dados(4):='2010 390010101';

     begin       
      
     dados(1):='2010 '||dados(1);
--     dados(1):='2010 1900101043504';

     select ci.categoria_item_id into ln_categ
            from categoria_item_atributo ci
            where ci.titulo like dados(1)||'%';

      exception when no_data_found then
        ln_categ:=0;
          dbms_output.put_line('Linha:'||registros||' Atributo Centro Responsabilidade não localizado: '||dados(1) );
          lb_erro:=true;
        when others then
        ln_categ:=0;
          dbms_output.put_line('Linha:'||registros||' Atributo Centro Responsabilidade localizou mais de 1 CR: '||dados(1) );
          lb_erro:=true;
     end; 
            
     
    if not lb_erro then
     begin
     select Identidade into ln_id_proj 
          from ATRIBUTOENTIDADEVALOR 
              where      TIPOENTIDADE='P' and
                         ATRIBUTOID = 2 and 
                         Categoria_Item_Atributo_Id = ln_categ;
      exception when no_data_found then
        ln_categ:=0;
          dbms_output.put_line('Linha:'||registros||' Não foi localizado Projeto com Atributo Centro Responsabilidade: '||dados(1) );
          lb_erro:=true;
        when others then
        ln_categ:=0;
          dbms_output.put_line('Linha:'||registros||' Existe mais de um Projeto com Atributo Centro Responsabilidade: '||dados(1) );
          lb_erro:=true;
     end; 
    end if;
    if not lb_erro then
--        dbms_output.put_line('Custo:'|| trim(dados(4))||' Proj:'|| ln_id_proj);
        ln_categ:=0;
        begin
           select ID into ln_categ
             from custo_receita where trim(Titulo) like trim(dados(4))|| '% - %' and tipo=ls_tipo;-- and vigente = 'Y';
        exception
           when no_data_found then
           dbms_output.put_line('Linha:'||registros||' Projeto:'||ln_id_proj ||' Não localizou na Árvore de custos:'|| trim(dados(4))|| ' Tipo:'||ls_tipo);
           lb_erro:=true;
           when others then
           dbms_output.put_line('Linha:'||registros||' Projeto:'||ln_id_proj ||' Árvore de custos com mais de 1 registro para:'|| trim(dados(4))|| ' Tipo:'||ls_tipo);
           lb_erro:=true;
        end;

      if not lb_erro then
      -- inclui permissoes automaticas para inclusão de lançamento
      ln_id_atr:=0;
       select count(1) 
         into       ln_id_atr
         from custo_receita_forma crf
        where crf.forma_id         = case ls_tipo when 'C' then 7 else 8 end
          and crf.vigente          = 'Y'
          and crf.custo_receita_id = ln_categ;

      if ln_id_atr=0 then

         SELECT custo_receita_forma_seq.nextval INTO ln_tipo FROM dual;

         IF primeiro_registro6 THEN
           dbms_output.put_line('SELECT * FROM CUSTO_RECEITA_FORMA WHERE ID >= '||ln_tipo);
           primeiro_registro6:=FALSE;
         END IF;

         insert into custo_receita_forma (ID,CUSTO_RECEITA_ID,FORMA_ID,VIGENCIA,VIGENTE,VALOR_DEFAULT)
         select ln_tipo, ln_categ, case ls_tipo when 'C' then 7 else 8 end, sysdate, 'Y' ,'N'
         from dual;  

      end if;

      ln_id_atr:=0;
       select count(1) 
         into       ln_id_atr
         from custo_receita_tipo crt
        where crt.tipo_id          = case ls_tipo when 'C' then 3 else 4 end
          and crt.vigente          = 'Y'
          and crt.custo_receita_id = ln_categ;

      if ln_id_atr=0 then

         SELECT custo_receita_tipo_seq.nextval INTO ln_tipo FROM dual;

         IF primeiro_registro7 THEN
           dbms_output.put_line('SELECT * FROM CUSTO_RECEITA_TIPO WHERE ID >= '||ln_tipo);
           primeiro_registro7:=FALSE;
         END IF;

         insert into custo_receita_tipo (ID,CUSTO_RECEITA_ID,TIPO_ID,VIGENCIA,VIGENTE,VALOR_DEFAULT)
         select ln_tipo, ln_categ, case ls_tipo when 'C' then 3 else 4 end, sysdate, 'Y' ,'N'
         from dual;  

      end if;

      ln_id_tarc:=0;
      begin
        select id into ln_id_tarc
        from tarefa
          where projeto=ln_id_proj and
                trim(tarefa.titulo)=trim(dados(3));
--           dbms_output.put_line('Achou Tarefa');
        exception
           when no_data_found then
           dbms_output.put_line('Linha:'||registros||' Projeto:'||ln_id_proj ||' Não Achou Tarefa:'||trim(dados(3)));
           ln_id_tarc:=0;
           lb_erro:=true;
           when others then
           dbms_output.put_line('Linha:'||registros||' Projeto:'||ln_id_proj ||'Achou Mais de uma Tarefa:'||trim(dados(3)));
           ln_id_tarc:=0;
           lb_erro:=true;
      end;
      ln_id_ativc:=0;

      if ln_id_tarc=0 then
      begin
        select id into ln_id_ativc
        from atividade
          where projeto=ln_id_proj and
                trim(titulo)=trim(dados(3));
           dbms_output.put_line('Achou Atividade');
        exception
           when no_data_found then
           dbms_output.put_line('Linha:'||registros||' Projeto:'||ln_id_proj ||' Não Achou Atividade:'||trim(dados(3)));
           ln_id_ativc:=0;
           lb_erro:=true;
           when others then
           dbms_output.put_line('Linha:'||registros||' Projeto:'||ln_id_proj ||'Achou Mais de uma Atividade:'||trim(dados(3)));
           ln_id_ativc:=0;
           lb_erro:=true;
      end;
        
      
      end if;
              
      ln_id_atr:=0;

      if ln_id_tarc>0 then

          select nvl(min(id),0) into ln_id_atr
          from custo_entidade 
            where TIPO_ENTIDADE='T' and
                  ENTIDADE_ID=ln_id_tarc and
                  CUSTO_RECEITA_ID=ln_categ;

      elsif ln_id_ativc>0 then

          select nvl(min(id),0) into ln_id_atr
          from custo_entidade 
            where TIPO_ENTIDADE='A' and
                  ENTIDADE_ID=ln_id_ativc and
                  CUSTO_RECEITA_ID=ln_categ;

      else
          select nvl(min(id),0) into ln_id_atr
          from custo_entidade 
            where TIPO_ENTIDADE='P' and
                  ENTIDADE_ID=ln_id_proj and
                  CUSTO_RECEITA_ID=ln_categ;
      end if;


      if ln_id_atr=0 then

        SELECT custo_entidade_seq.nextval INTO ln_id_atr FROM dual;

         IF primeiro_registro4 THEN
           dbms_output.put_line('SELECT * FROM CUSTO_ENTIDADE WHERE ID >= '||ln_id_atr);
           primeiro_registro4:=FALSE;
         END IF;

      if ln_id_tarc>0 then
        insert into custo_entidade (ID,TIPO_ENTIDADE,ENTIDADE_ID,CUSTO_RECEITA_ID,
                                    TITULO,TIPO_DESPESA_ID,FORMA_AQUISICAO_ID,
                                    UNIDADE,MOTIVO)
           select ln_id_atr,'T',ln_id_tarc,ln_categ,
                  trim(dados(5)), case ls_tipo when 'C' then 3 else 4 end, case ls_tipo when 'C' then 7 else 8 end,
                  null, null
                  from dual;
      elsif ln_id_ativc>0 then
        insert into custo_entidade (ID,TIPO_ENTIDADE,ENTIDADE_ID,CUSTO_RECEITA_ID,
                                    TITULO,TIPO_DESPESA_ID,FORMA_AQUISICAO_ID,
                                    UNIDADE,MOTIVO)
           select ln_id_atr,'A',ln_id_ativc,ln_categ,
                  trim(dados(5)), case ls_tipo when 'C' then 3 else 4 end, case ls_tipo when 'C' then 7 else 8 end,
                  null, null
                  from dual;
      
      else
        insert into custo_entidade (ID,TIPO_ENTIDADE,ENTIDADE_ID,CUSTO_RECEITA_ID,
                                    TITULO,TIPO_DESPESA_ID,FORMA_AQUISICAO_ID,
                                    UNIDADE,MOTIVO)
           select ln_id_atr,'P',ln_id_proj,ln_categ,
                  trim(dados(5)), case ls_tipo when 'C' then 3 else 4 end, case ls_tipo when 'C' then 7 else 8 end,
                  null, null
                  from dual;
        
      end if;

      end if;
      
      -- P Planejado
      if (nvl(trim(dados(7)),'-1') <> '-1') and to_number(dados(7))>0 then
         SELECT custo_lancamento_seq.nextval INTO ln_id_tar FROM dual;
         IF primeiro_registro5 THEN
           dbms_output.put_line('SELECT * FROM CUSTO_LANCAMENTO WHERE ID >= '||ln_id_tar);
           primeiro_registro5:=FALSE;
         END IF;
         insert into custo_lancamento  (ID,CUSTO_ENTIDADE_ID,TIPO,SITUACAO,
                                        DATA,VALOR_UNITARIO,QUANTIDADE,VALOR,
                                        USUARIO_ID,DATA_ALTERACAO)
           select ln_id_tar,ln_id_atr,'P','V',  -- planejado, válido
                  trunc(to_date(trim(dados(6)) ,'DD/MM/YYYY HH24:MI:SS')),
                  to_number(dados(7)),1,to_number(dados(7)),'310',sysdate
--                  trunc(to_date(trim(dados(6)) ,'DD/MM/YYYY HH24:MI:SS'))
           from dual;
      end if;
      end if;

        
    end if;



 
   --------------------------------------
   -- FIM do Processamento da Linha    --
   --------------------------------------

   vstart:=vend+length(ls_seperador_registro);
   vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);
   dados:=t_dados();
END LOOP;

exception when others then
dbms_output.put_line('Erro linha:'||registros|| '  ' || sqlerrm);  
end;

ln_retorno:=registros;
--rollback;
end p_Importa_Custos;

procedure p_Acerto_Carga_Inicial(ln_seq number, ln_retorno in out number)
is
ls_campo VARCHAR2(32000);
 ln_campo number;
 ld_campo date;
 ls_seperador_campo varchar2(5);
 ls_seperador_registro varchar2(5);
 ln_qtde_campos integer;
 l_colcnt integer;
 reg lista_campos;
 ln_doc int;
 ln_doc_cont int;
 blob_edit   BLOB; 
 ls_linha varchar2(32767);
 b_int binary_integer;
 c INTEGER;
 fdbk integer;
 ln_tamanho number;
 primeiro_registro1 boolean:=true;
 primeiro_registro2 boolean:=true;
 primeiro_registro3 boolean:=true;
 primeiro_registro4 boolean:=true;
 primeiro_registro5 boolean:=true;
 primeiro_registro6 boolean:=true;
 primeiro_registro7 boolean:=true;
 primeiro_registro8 boolean:=true;

 ls_query varchar2(2000);
 vtemp RAW(32000);
vend NUMBER := 1;
vlen NUMBER := 1;
vstart NUMBER := 1;

vend2 NUMBER := 1;
vlen2 NUMBER := 1;
vstart2 NUMBER := 1;
i number;
bytelen NUMBER := 32000;
ultimo_campo boolean;
registros number:=0;     
ln_id_proj number:=0;              
ln_id_ativ number:=0;              
ln_id_tar number:=0;              
ln_tipo  number:=0;
ln_id_atr  number:=0;              
ln_categ number:=0;
ls_tipo varchar2(1);
lb_erro boolean:=false;
lb_erro_ativ  boolean:=false;
blob_edit1             CLOB; 
blob_edit2             CLOB; 
blob_edit3             CLOB; 
blob_edit4             CLOB; 
blob_edit5             CLOB; 
blob_edit6             CLOB; 

TYPE t_dados IS VARRAY(100) OF varchar2(32000);
dados t_dados:=t_dados();

type    Array1D is table of Number;
type    Array2D is table of Array1D;
array   Array2D;
array2   Array2D;

begin

ls_seperador_campo:=chr(9);  -- TAB
ls_seperador_campo:=chr(35); -- #
ls_seperador_registro:=chr(13)||chr(10);
  
select conteudo into blob_edit
from documento_conteudo
where documento_id=ln_seq;

vlen:=dbms_lob.getlength(blob_edit);
bytelen := 32000;
vstart := 1;
vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);

begin
--vlen:=100;
WHILE vstart < vlen 
LOOP
--dbms_output.put_line('newline:'||vstart);
--dbms_output.put_line('newline:'||vend);
vlen2:=vend-vstart+1;
   dbms_lob.read(blob_edit,vlen2,vstart,vtemp);
   ls_linha:=utl_raw.cast_to_varchar2(vtemp);
    registros:=registros+1;
    
vend2 := 1;
--vlen2 := length(ls_linha);
--dbms_output.put_line('Linha text:'||ls_linha);
vstart2 := 1;
vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);

i:=1;     
ultimo_campo:=false;
WHILE vstart2 < vlen2 or ultimo_campo
LOOP
--dbms_output.put_line('len2:'||vlen2);
--dbms_output.put_line('start2:'||vstart2);
--dbms_output.put_line('vend2:'||vend2);

     select t_tipo_campos(sec,nome,tipo,tamanho,decimais,separador,formato,obrigatorio,opcoes,descricao)
     BULK COLLECT INTO reg     from table(f_lista_campos) where sec=i;

   ls_campo:=substr(ls_linha, vstart2, vend2-vstart2);
--   dbms_output.put_line('Campo:'||reg(1).sec||':'||reg(1).nome||' Tipo:'||reg(1).tipo||' Valor:'||ls_campo);
   dados.extend;
   dados(i):=replace(ls_campo,'''','''''');
   vstart2:=vend2+length(ls_seperador_campo);
  if not ultimo_campo then
     vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);
  else
     ultimo_campo:=false;
  end if;


  if vend2 =0 then
    ultimo_campo:=true;
    vend2:=vlen2;
  end if;
i:=i+1;
END LOOP;


array := new Array2D(                  -- ordem , atributo
                                  Array1D(5,43),
                                  Array1D(6,16),
                                  Array1D(7,17),
                                  Array1D(9,15),
                                  Array1D(15,70),
                                  Array1D(18,71),
                                  Array1D(19,72),
                                  Array1D(20,73),
                                  Array1D(21,74),
                                  Array1D(22,75),
                                  Array1D(23,76),
                                  Array1D(17,80),
                                  Array1D(10,11),
                                  Array1D(11,2)
                                  
                     );   

array2 := new Array2D(                  -- ordem , atributo
                                  Array1D(2,7),
                                  Array1D(3,8),
                                  Array1D(4,9)
                                  
                     );   

   --------------------------------------
   -- Inicio do Processamento da Linha --
   --------------------------------------
--if registros < 1000 then

   if dados(1)='10' then -- PROJETOS

      lb_erro:=false;
      lb_erro_ativ:=false;
      
      begin

      select id into ln_id_proj from projeto
      where Titulo = dados(2)|| ' - ' || dados(3) and
           id >= (select id from projeto where titulo in ('PJ-NAC 1011 - Programa SENAI de Ações Inclusivas')) and
           id <= (select id from projeto where titulo in ('PJ-NAC 1028 - Apoio a estruturação de programa de capacitação de RH em normalização - 2010')) and
           exists (select * from ATRIBUTOENTIDADEVALOR a, categoria_item_atributo c
                      where c.atributo_id = 2 and
                            a.identidade = projeto.id and
                            a.tipoentidade = 'P' and
                            a.atributoid = 2 and
                            c.titulo like '2010%'||dados(11)||'-%' and
                            c.categoria_item_id = a.categoria_item_atributo_id);
                            
      dbms_output.put_line('   Projeto:'||ln_id_proj||' ('||dados(2)|| ' - ' || dados(3)||')');

      exception when no_data_found then
        ln_categ:=0;
          dbms_output.put_line('ERRO Linha:'||registros||' Não localizou projeto: '||dados(2)|| ' - ' || dados(3) || ' CR:'||dados(11));
          lb_erro:=true;
          ln_id_proj:=0;
        when others then
        ln_categ:=0;
          dbms_output.put_line('ERRO Linha:'||registros||' Localizou mais de um projeto: '||dados(2)|| ' - ' || dados(3)  || ' CR:'||dados(11));
          lb_erro:=true;
          ln_id_proj:=0;
     end; 

   end if;

   if (dados(1)='30' and not lb_erro and ln_id_proj>0 ) then -- INICIO Ativ
      lb_erro_ativ:=false;
      if length(trim(dados(2)))>150 then
        dados(2) := substr(trim(dados(2)),1,147) || '...' ;
      end if;
      begin
      ln_id_ativ:=0;
      select id into ln_id_ativ from atividade
      where Titulo like trim(dados(2))||'%' and
            projeto =ln_id_proj;
      exception when no_data_found then
      ln_id_ativ:=0;
          dbms_output.put_line('ERRO Linha:'||registros||' Não localizou Atividade: '||dados(2)|| ' - ' || dados(3) || ' CR:'||dados(11));
          lb_erro_ativ:=true;
          ln_id_proj:=0;
        when others then
          ln_id_ativ:=0;
          dbms_output.put_line('ERRO Linha:'||registros||' Localizou mais de uma Atividade: '||dados(2)|| ' - ' || dados(3)  || ' CR:'||dados(11));
          lb_erro_ativ:=true;
          ln_id_proj:=0;
     end; 
   
   end if;

   if (dados(1)='40' and not lb_erro and not lb_erro_ativ and ln_id_proj>0 ) then -- INICIO Tarefas

      
      if length(trim(dados(2)))>150 then
        dados(2) := substr(trim(dados(2)),1,147) || '...' ;
      end if;

      begin

      select id into ln_id_tar from tarefa
      where Titulo = dados(2) and
            tarefa.atividade = ln_id_ativ and
            projeto =ln_id_proj;

      update tarefa set
         datainicio=trunc(to_date(trim(dados(6)) ,'DD/MM/YYYY HH24:MI:SS')),
         prazoprevisto=trunc(to_date(trim(dados(7)) ,'DD/MM/YYYY HH24:MI:SS')),
         iniciorealizado=trunc(to_date(trim(dados(8)) ,'DD/MM/YYYY HH24:MI:SS')),
         prazorealizado=trunc(to_date(trim(dados(9)) ,'DD/MM/YYYY HH24:MI:SS')),
         tiporestricao=2, 
         datarestricao=trunc(to_date(trim(dados(6)) ,'DD/MM/YYYY HH24:MI:SS'))
      where id=ln_id_tar;

      dbms_output.put_line('      Tarefa:'||ln_id_tar|| ' (' ||dados(2) ||') Atualizada!'  );

      exception when no_data_found then
        ln_categ:=0;
          dbms_output.put_line('ERRO Linha:'||registros||' Não localizou tarefa: '||dados(2) );
        when others then
        ln_categ:=0;
          
          dbms_output.put_line('ERRO Linha:'||registros||' Localizou mais de uma tarefa: '||dados(2) ||' msg: '|| sqlerrm);
     end; 

   end if;  -- FIM Tarefas

 
--end if;
   --------------------------------------
   -- FIM do Processamento da Linha    --
   --------------------------------------

   vstart:=vend+length(ls_seperador_registro);
   vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);
   dados:=t_dados();
END LOOP;

exception when others then
dbms_output.put_line('Erro linha:'||registros|| '  ' || sqlerrm);  
end;

ln_retorno:=registros;
--rollback;
end p_Acerto_Carga_Inicial;          

procedure p_Importa_View_Zeus(ls_diretorio varchar2, ln_retorno in out number)
is
 ls_campo              VARCHAR2(1000);
 ln_campo              number;
 ld_campo              date;
 ls_seperador_campo    varchar2(5);
 ls_seperador_registro varchar2(5);
 ln_qtde_campos        integer;
 l_colcnt              integer;
 reg                   lista_campos;
 ln_doc                int;
 ln_doc_cont           int;
 blob_edit             BLOB; 
 ls_linha              varchar2(32767);
 b_int                 binary_integer;
 c                     INTEGER;
 fdbk                  integer;
 ln_tamanho            number;
 primeiro_registro     boolean:=true;
 ls_query              varchar2(2000);
 vtemp                 RAW(32000);
 vend                  NUMBER := 1;
 vlen                  NUMBER := 1;
 vstart                NUMBER := 1;
 vend2                 NUMBER := 1;
 vlen2                 NUMBER := 1;
 vstart2               NUMBER := 1;
 i                     number;
 ln_proj               number:=0;
 bytelen               NUMBER := 32000;
 ultimo_campo          boolean;
 registros             number:=0;     
 ln_ce                 number:=0;
 ln_cl                 number:=0;
 TYPE t_dados IS VARRAY(100) OF varchar2(32000);
 dados t_dados:=t_dados();
 lb_erro boolean:=false;
 ln_categ number;
 ln_uo number;
 -- Modificado <Charles> Ini
 lf_rejeitados SYS.UTL_FILE.file_type;
 lf_log        SYS.UTL_FILE.file_type;
 ln_forma      number := 0;
 ln_tipo       number := 0;
 ln_cr         number := 0;
 ld_lancamento date;
 lv_mensagem   varchar2(4000);
 ld_data_hora  date;
 -- Modificado <Charles> Fim
 v_blob blob;
 ln_inseridos number:=0;
 ln_sinal number:=1;
ls_temp varchar2(10); 
begin
   dbms_output.put_line('Horário: ' || to_char(sysdate, 'hh24:mi:ss dd/mm/yyyy'));
  
   -- Modificado <Charles> - Ini  
   if ls_diretorio is not null then
     select sysdate into ld_data_hora from dual;
     lf_rejeitados := SYS.UTL_FILE.fopen (ls_diretorio, 'registros_rejeitados_' || 
                                      to_char(ld_data_hora, 'yyyymmddhh24miss') || '.txt', 'w');
     lf_log        := SYS.UTL_FILE.fopen (ls_diretorio, 'resultado_processamento_' || 
                                      to_char(ld_data_hora, 'yyyymmddhh24miss') || '.txt', 'w');
   end if;
   -- Modificado <Charles> - Fim 
   
   ls_seperador_campo:=chr(9);
   ls_seperador_registro:=chr(13)||chr(10);

   for c in (
        select 
        UNIDADE_COD,  MIN(ANO) ANO, MIN(DATA_FECHTO) DATA_FECHTO
        from VW_ZEUS d
/*        where exists
          (select p.id from projeto p, atributoentidadevalor aev, categoria_item_atributo cia, atributoentidadevalor aev2, uo u
                   where aev.identidade = p.id and 
                         aev.tipoentidade='P' and 
                         aev.atributoid=2 and
                         aev.categoria_item_atributo_id = cia.categoria_item_id and
                         cia.titulo like trim(to_char(d.ano))||' '||trim(substr(cr_cod,1,9))||'-%' and
                         
                         p.uo_id=u.id and
                         u.titulo like trim(to_char(d.ano))||trim(d.unidade_cod)||'%' and

                         aev2.identidade = p.id and 
                         aev2.tipoentidade='P' and 
                         aev2.atributoid=1 and
                         aev2.valornumerico=to_number(substr(cr_cod,10)))
  */      
        group by UNIDADE_COD
        )
   loop

----------------------------------------------------------
-- falta                                                --
----------------------------------------------------------
--falta filtrar o UO
--falta ver a questado do > ou >=  DT_FECHAMENTO
--falta analisar a questao do Débito - Credito
--falta descricao do lançamento (ficará em campo novo)
----------------------------------------------------------
--                                                      --
----------------------------------------------------------

        delete from baseline_custo_lancamento cl
        where cl.custo_lancamento_id in
        (select cl2.id from custo_lancamento cl2
         where cl2.tipo = 'R'
           and data > c.DATA_FECHTO
           and exists (select 1
                         from custo_entidade ce, projeto p, uo u
                        where ce.id = cl2.custo_entidade_id
                          and p.id = ce.entidade_id
                          and ce.tipo_entidade = 'P'
                          and p.uo_id = u.id and
                          u.titulo like trim(to_char(c.ano))||trim(c.unidade_cod)||'%'));
                          
        delete from custo_lancamento cl
         where cl.tipo = 'R'
           and data > c.DATA_FECHTO
           and exists (select 1
                         from custo_entidade ce, projeto p, uo u
                        where ce.id = cl.custo_entidade_id
                          and p.id = ce.entidade_id
                          and ce.tipo_entidade = 'P'
                          and p.uo_id = u.id and
                          u.titulo like trim(to_char(c.ano))||trim(c.unidade_cod)||'%');

        delete from baseline_custo_entidade ce
         where not exists (select 1 
                             from baseline_custo_lancamento cl
                            where cl.baseline_custo_entidade_id = ce.id);
         
        delete from custo_entidade ce
         where not exists (select 1 
                             from custo_lancamento cl
                            where cl.custo_entidade_id = ce.id);
   end loop;

   dbms_output.put_line('Horário: ' || to_char(sysdate, 'hh24:mi:ss dd/mm/yyyy'));

   -- SALVA DADOS da VIEW em BLOB --

  select documento_seq.nextval into ln_doc from dual;
  select documento_conteudo_seq.nextval into ln_doc_cont from dual;

  Insert into DOCUMENTO (DOCUMENTOID,DESCRICAO,
        TIPOENTIDADE,IDENTIDADE,AREAGERENCIA,ESTADODOCUMENTO,VERSAOATUAL,TIPODOCUMENTO,RESPONSAVEL,DOCUMENTO_PAI,TIPO_DOCUMENTO_ID,TAMANHO) 
  select ln_doc,'View Carregada em '||to_char(sysdate,'DD-MM-YYYY HH24-MI-SS'),
         null,null,null,'I',1,'.txt',null,null,null,null from dual;

  insert into documento_conteudo (id, documento_id, versao, conteudo)
  values (ln_doc_cont, ln_doc, 1, empty_blob());-- returning conteudo into blob_edit;

  DBMS_LOB.CREATETEMPORARY(v_blob,TRUE);


  ls_linha:='DATA_LANCTO'||  ls_seperador_campo ||'ANO'||  ls_seperador_campo ||'UNIDADE_COD'||  ls_seperador_campo ||'CR_COD'||  ls_seperador_campo ||'CONTA_COD'||  ls_seperador_campo ||'VALOR'||  ls_seperador_campo ||'DESCRICAO'||  ls_seperador_campo ||'DEB_CRED'||  ls_seperador_campo ||'DATA_FECHTO'||ls_seperador_registro;
  b_int:=utl_raw.length (utl_raw.cast_to_raw(ls_linha));
  dbms_lob.write(v_blob, b_int, 1, utl_raw.cast_to_raw(ls_linha));

  dbms_output.put_line('Horário: ' || to_char(sysdate, 'hh24:mi:ss dd/mm/yyyy'));

   for c in (
       select 
        DATA_LANCTO, ANO, MES, EMPRESA_COD, UNIDADE_COD, 
        CR_COD,	CONTA_COD, CONTA_COD_CTB,	VALOR,	
        DESCRICAO, DEB_CRED, DATA_FECHTO
        from VW_ZEUS d
/*        where exists
          (select p.id from projeto p, atributoentidadevalor aev, categoria_item_atributo cia, atributoentidadevalor aev2, uo u
                   where aev.identidade = p.id and 
                         aev.tipoentidade='P' and 
                         aev.atributoid=2 and
                         aev.categoria_item_atributo_id = cia.categoria_item_id and
                         cia.titulo like trim(to_char(d.ano))||' '||trim(substr(cr_cod,1,9))||'-%' and
                         
                         p.uo_id=u.id and
                         u.titulo like trim(to_char(d.ano))||trim(d.unidade_cod)||'%' and

                         aev2.identidade = p.id and 
                         aev2.tipoentidade='P' and 
                         aev2.atributoid=1 and
                         aev2.valornumerico=to_number(substr(cr_cod,10)))
*/

/* dados de teste
       select 
        sysdate+level DATA_LANCTO, 2010	ANO, 6	MES, 3	EMPRESA_COD, '100'	UNIDADE_COD, 
        '10102010102'	CR_COD,	'31010314' CONTA_COD, '31010314'	CONTA_COD_CTB,	17.74*level VALOR,	
        'Importado do Sistema de Almoxarifado' DESCRICAO, case when level<10 then 'C' else 'D' end DEB_CRED, sysdate-1 	DATA_FECHTO
        from dual CONNECT BY level <= 20 */
     )
   loop

    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados(2):='3';
    dados(3):=to_char(c.ano);
    dados(6):=trim(to_char(c.ano))||trim(c.unidade_cod);
    dados(7):=trim(c.cr_cod);
    dados(8):=trim(c.conta_cod);
    dados(9):='1';
    dados(10):=trim(c.valor);
    dados(16):=to_char(c.DATA_LANCTO,'DD/MM/YYYY');
    dados(12):=trim(c.DESCRICAO);
    dados(17):=trim(c.DEB_CRED);
    dados(18):=to_char(c.DATA_FECHTO,'DD/MM/YYYY');

    ls_linha:= dados(16) || ls_seperador_campo || 
            dados(3) ||  ls_seperador_campo ||
            dados(6) ||  ls_seperador_campo ||
            dados(7) ||  ls_seperador_campo ||
            dados(8) ||  ls_seperador_campo ||
            dados(10) || ls_seperador_campo ||
            dados(12) || ls_seperador_campo ||
            dados(17) || ls_seperador_campo ||
            dados(18) || ls_seperador_registro;

   registros:=registros+1;
   --------------------------------------
   -- Início do Processamento da Linha --
   --------------------------------------
   -- dbms_output.put_line(dados(1)||dados(2)||dados(3));
   -- Dados prontos para serem trabalhados
   lb_erro:=false;
         if dados(2)='3' then -- Realizado
           
            -- Para identificar o projeto, identificar por 3 valores
            -- 1. Projeto deve ser da UO 
            -- 2. Atributo 2 deve ter 'YYYY XXXXXX' onde YYYY é o ano do orçamento e XXXXXX são os 6 primeiras posicoes do Centro de Resposabilidade 
            -- 3. Atributo 1 deve ter o sequencial posicao a partir da 7 do Centro de Responsabilidade

            dados(3):=trim(dados(3));
            dados(4):=trim(dados(4));
            dados(6):=trim(dados(6));
            dados(7):=trim(dados(7));
            dados(16):=trim(dados(16));
            dados(8):=dados(3)|| ' '|| trim(dados(8));

            if to_number(dados(9))=0 then
              dados(9):='1';
            end if;

            begin
             select ci.categoria_item_id into ln_categ
                    from categoria_item_atributo ci
                    where ci.titulo like dados(3)|| ' ' || substr(dados(7),1,9) ||'-%' and
                          ci.atributo_id=2;

              exception when no_data_found then
                ln_categ:=0;
                  lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Atributo Centro Responsabilidade não localizado: '||chr(9)||dados(3)||' '|| substr(dados(7),1,9);
                  dbms_output.put_line(lv_mensagem);
                  SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  lb_erro:=true;
                when others then
                ln_categ:=0;
                  lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Atributo Centro Responsabilidade localizou mais de 1 CR: '||chr(9)||dados(3)|| ' ' || substr(dados(7),1,9);
                  dbms_output.put_line(lv_mensagem);
                  SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  lb_erro:=true;
             end; 


            begin
             select u.id into ln_uo from uo u where u.titulo like dados(6)||'%';

              exception when no_data_found then
                ln_uo:=0;
                  lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' UO não localizado: '||chr(9)||dados(6);
                  dbms_output.put_line(lv_mensagem);
                  SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  lb_erro:=true;
                when others then
                ln_uo:=0;
                  lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Localizou mais de 1 UO: '||chr(9)||dados(3)|| ' ' || dados(6);
                  dbms_output.put_line(lv_mensagem);
                  SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  lb_erro:=true;
             end; 

           if (not lb_erro) then
            begin
--dbms_output.put_line(dados(7)||'-'||ln_categ||'-'||ln_uo);
            select id into ln_proj from projeto p
            where p.uo_id = ln_uo  and
                  exists (select *
                from atributoentidadevalor aev--, categoria_item_atributo cia
                   where aev.identidade = p.id and 
                         aev.tipoentidade='P' and 
                         aev.atributoid=2 and
                         aev.categoria_item_atributo_id = ln_categ
                         --cia.atributo_id=2 and
                         --substr(cia.Titulo,6,instr(cia.Titulo,'-')-6) = dados(3)|| ' ' || substr(dados(7),1,9) and
                         --aev.categoria_item_atributo_id = cia.categoria_item_id
                         ) and
                   exists (select *
                from atributoentidadevalor aev 
                   where aev.identidade = p.id and 
                         aev.tipoentidade='P' and 
                         nvl(aev.Valor, aev.ValorNumerico)= to_number(substr(dados(7),10)) and
                         aev.atributoid=1);
            exception when no_data_found then
                lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Não foi localizado Projeto com Atributo Centro Responsabilidade: '||chr(9)||dados(3)|| ' ' || substr(dados(7),1,9) ||chr(9)|| ' Atributo_SEQ:'||chr(9)|| substr(dados(7),10)||chr(9) || ' UO: '||chr(9)||dados(6)||chr(9)|| ' COD_CR:'||chr(9)||ln_categ || chr(9)||' COD_UO:'||chr(9)||ln_uo;
                dbms_output.put_line(lv_mensagem);
                SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                lb_erro:=true;
              when others then
                lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Existe mais de um Projeto com Atributo Centro Responsabilidade: '||chr(9)||dados(3)|| ' ' || substr(dados(7),1,9) ||chr(9)|| ' Atributo_SEQ:'||chr(9)|| substr(dados(7),10)||chr(9) || ' UO: '||chr(9)||dados(6)||chr(9)|| ' COD_CR:'||chr(9)||ln_categ ||chr(9)|| ' COD_UO:'||chr(9)||ln_uo;
                dbms_output.put_line(lv_mensagem);
                SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                lb_erro:=true;
           end; 
           end if;
           
           if (not lb_erro) then

            select nvl(min(ce.id),0) into ln_ce from custo_entidade ce, custo_receita cr
            where ce.tipo_entidade = 'P' and
                  ce.custo_receita_id = cr.id and
                  ce.entidade_id = ln_proj and
                  cr.titulo = 'Realizado Zeus'; -- Realizado Zeus
                        
             begin
              select case when tipo='C' and dados(17)='C' then -1
                                    when tipo='R' and dados(17)='D' then -1
                                    else 1 end
                into ln_sinal
                from custo_receita
               where titulo like dados(8)||' %'; -- conta contabil 

            exception when no_data_found then
                lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Não foi localizado Conta Custo Receita: '||chr(9)||dados(8);
                dbms_output.put_line(lv_mensagem);
                SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                lb_erro:=true;
              when others then
                lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Erro. A Conta Custo Receita deve ser única: '||chr(9)||dados(8);
                dbms_output.put_line(lv_mensagem);
                SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                lb_erro:=true;
             end;

            -- Modificado <Charles> Ini
            if ln_ce = 0 and not lb_erro then   

/*
Se DEB_CRED = D e conta de despesa (3) = sinal POSITIVO antes do valor 
Se DEB_CRED = C e conta de despesa (3) = sinal NEGATIVO antes do valor 
Se DEB_CRED = D e conta de receita (4) = sinal NEGATIVO antes do valor 
Se DEB_CRED = C e conta de receita (4) = sinal POSITIVO antes do valor 
*/

                       
             begin
              select id
                into ln_cr
                from custo_receita
               where titulo like dados(8)||' %'; -- conta contabil 


            exception when no_data_found then
                lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Não foi localizado Conta Custo Receita: '||chr(9)||dados(8);
                dbms_output.put_line(lv_mensagem);
                SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                lb_erro:=true;
              when others then
                lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Erro. A Conta Custo Receita deve ser única: '||chr(9)||dados(8);
                dbms_output.put_line(lv_mensagem);
                SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                lb_erro:=true;
             end;
               
              if ln_cr > 0 and not lb_erro then  
           
                select min(forma_id)
                  into ln_forma
                  from (select *
                          from custo_receita_forma 
                         where custo_receita_id = ln_cr
                         order by decode(vigente, 'Y', 1, 2), decode (valor_default,'Y', 1, 2))
                 where rownum = 1;
                 
                select min(tipo_id)
                  into ln_tipo
                  from (select *
                          from custo_receita_tipo
                         where custo_receita_id = ln_cr
                         order by decode(vigente, 'Y', 1, 2), decode (valor_default,'Y', 1, 2))
                 where rownum = 1; 
               
                select custo_entidade_seq.nextval into ln_ce from dual;
                
                insert into custo_entidade (id, tipo_entidade, entidade_id, custo_receita_id, titulo, 
                                            tipo_despesa_id, forma_aquisicao_id)
                       values (ln_ce, 'P', ln_proj, ln_cr, 'Realizado Zeus', ln_tipo, ln_forma);
              end if;
            end if;
            -- Modificado <Charles> Fim
            
            if ln_ce > 0 and not lb_erro then
                                          
                  -- Modificado <Charles> Ini
                  ld_lancamento := to_date(dados(16),'DD/MM/YYYY');
/*                  begin
                    ld_lancamento := to_date('01'||trim(to_char(to_number(dados(4)),'00'))||dados(3), 'ddmmyyyy');
                    -- Coloca no último dia do mês
                    ld_lancamento := add_months(ld_lancamento, 1) - 1;
                  exception
                    when others then
                      ld_lancamento := null;
                  end;*/
                  --dbms_output.put_line('DEBUG: ' || to_char(ld_lancamento, 'dd/mm/yyyy'));
                  -- Modificado <Charles> Fim
/*                  
                  select nvl(max(id),0) into ln_cl from custo_lancamento 
                  where custo_entidade_id = ln_ce and
                        tipo = 'R' and
                        situacao = 'V' and
                        trunc(data) = trunc(ld_lancamento);

                  if ln_cl=0 then*/
                      begin
                        select custo_lancamento_seq.nextval into ln_cl from dual;
                        insert into custo_lancamento (ID, CUSTO_ENTIDADE_ID, TIPO, SITUACAO,
                                                      DATA, 
                                                      VALOR,
                                                      QUANTIDADE, 
                                                      VALOR_UNITARIO, 
                                                      USUARIO_ID, DATA_ALTERACAO, DESCRICAO)
                            values (ln_cl, ln_ce, 'R', 'V',
                                    ld_lancamento,
                                    to_number(dados(10))*ln_sinal, -- valor
                                    to_number(dados(9)), -- quantidade
                                    (to_number(dados(10))*ln_sinal)/to_number(dados(9)), -- valor unitario,
                                    '310', 
                                    sysdate,
                                    trim(dados(12)));  -- 
                       lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' OK - Registro Inserido - Conta:'||dados(8);
                       dbms_output.put_line(lv_mensagem);
                       ln_inseridos:=ln_inseridos+1;
                       SYS.UTL_FILE.put_line(lf_log, lv_mensagem); 
                     exception
                       when others then
                         lv_mensagem := 'Linha:'||chr(9)||' Erro ao incluir: [' || sqlerrm || ']';
                         dbms_output.put_line(lv_mensagem);
                         SYS.UTL_FILE.put_line(lf_log, lv_mensagem); 
                     end;           
/*
                  else
                  -- dbms_output.put_line('Já existe Custo Lançamento para Lançamento para Conta:'||dados(14)||' Projeto:'|| '???' ||' Data:'||substr(dados(16),1,10)|| ' Linha não importada:'||registros);
                  -- se ja existe, acrescenta
                  begin
                    update custo_lancamento
                       set VALOR=VALOR+to_number(dados(10)),
                           QUANTIDADE=QUANTIDADE+to_number(dados(9)), 
                           VALOR_UNITARIO=(VALOR+to_number(dados(10)))/(QUANTIDADE+to_number(dados(9))), 
                           USUARIO_ID='310',
                           DATA_ALTERACAO=sysdate
                    where custo_entidade_id = ln_ce and
                          tipo = 'R' and
                          situacao = 'V' and
                          trunc(data) = trunc(ld_lancamento);

                       lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' OK - Registro Atualizado - Conta:'||dados(8);
                       dbms_output.put_line(lv_mensagem);
                       SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  exception
                    when others then
                      lv_mensagem := 'Linha:'||chr(9)||' Erro ao atualizar: [' || sqlerrm || ']';
                      dbms_output.put_line(lv_mensagem);
                      SYS.UTL_FILE.put_line(lf_log, lv_mensagem); 
                  end;
                  end if;*/
            elsif not lb_erro then
               -- Modificado <Charles>
               lb_erro:=true;
               
               lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||'Não foi localizado Custo Entidade para Conta:'||chr(9)||dados(8)||chr(9)||' Projeto:'||chr(9)||ln_proj;
               dbms_output.put_line(lv_mensagem);
               SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
            end if;
            end if;
         end if;
   
   -- Modificado <Charles> - Ini
   -- Grava registro nao processado no arquivo de output
   if lb_erro then
     SYS.UTL_FILE.put_line(lf_rejeitados, ls_linha);
   end if;
   -- Modificado <Charles> - Fim
   
   --------------------------------------
   -- FIM do Processamento da Linha --
   --------------------------------------

   -- SALVA linha de dados da VIEW em BLOB --
    b_int:=utl_raw.length (utl_raw.cast_to_raw(ls_linha));
    dbms_lob.writeappend(v_blob, b_int , utl_raw.cast_to_raw(ls_linha));

    if mod(registros,10)= 0 then
     commit;
    end if;
     
   dados:=t_dados();
   END LOOP;

  -- salva CLOB no documento
  update documento_conteudo
  set conteudo = v_blob
  where id=ln_doc_cont;
   
 -- Modificado <Charles>
 lv_mensagem := 'Registros Processados: '|| registros;
 dbms_output.put_line(lv_mensagem);
 SYS.UTL_FILE.put_line(lf_log, lv_mensagem);

 lv_mensagem := 'Registros Inseridos: '|| ln_inseridos;
 dbms_output.put_line(lv_mensagem);
 SYS.UTL_FILE.put_line(lf_log, lv_mensagem);

 
 SYS.UTL_FILE.fclose(lf_rejeitados);
 SYS.UTL_FILE.fclose(lf_log);
 ln_retorno:=registros;
 dbms_output.put_line('Horário: ' || to_char(sysdate, 'hh24:mi:ss dd/mm/yyyy'));

end p_Importa_View_Zeus;

PROCEDURE p_Exporta_Arquivo_CNI(ls_tipo varchar2, ln_arquivo in out number, ln_retorno in out number) AS

 ls_diretorio  varchar2(100):='IMPORTACAO_TRACEGP';
 ls_campo              VARCHAR2(2000);
 ln_campo              number;
 ld_campo              date;
 ls_seperador_campo    varchar2(5);
 ls_seperador_registro varchar2(5);
 ln_qtde_campos        integer;
 l_colcnt              integer;
 reg                   lista_campos;
 ln_doc                int;
 ln_doc_cont           int;
 blob_edit             BLOB; 
 ls_linha              varchar2(32767);
 b_int                 binary_integer;
 c                     INTEGER;
 fdbk                  integer;
 ln_tamanho            number;
 primeiro_registro     boolean:=true;
 ls_query              varchar2(32000);
 ld_data_hora          date;
 ln_registros          number:=0;
 
    v_buffer       RAW(32767);
    v_buffer_size  BINARY_INTEGER;
    v_amount       BINARY_INTEGER;
    v_offset       NUMBER(38) := 1;
    v_chunksize    INTEGER;
    v_out_file     UTL_FILE.FILE_TYPE;

begin

--ls_tipo = 'CTB' ou 'DOF'

/*

x=atributo do valor
y1=estado atual
y2=estado novo
z=formulario
w=DATA_PAGAMENTO
v=DATA_Liberacao/vencimento/provisao
a=conta fluxo
b=conta contabil
c=lista de estados: Liberado, gerado, pago

select 'A','I','TRACE','1','Trace',null,
            -- Atributo da Demanda
            (select av.valordata from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--v
            ) Data,
            -- Atributo da Demanda
            (select av.valornumerico from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--x
            ) Valor ,
            null,null,null,
            sysdate,
            (select av.valordata from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--v
            ) Data2,
            null,null,null,null,null,
            (select av.valor from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--a
            ) Cta_Fluxo ,
            (select av.valor from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--b
            ) Cta_Contabil ,
            'UU100',null,
           (select trim(max(u2.titulo)) || ' - '||p.titulo || ' - '|| to_char(sum(case when situacao in (1,2,3) -- c lista de estados: Liberado, gerado, pago
            then 1 else 0 end))||'/'||to_char(sum(1)) 
             from demanda d2, solicitacaoentidade se2, uo u2
                 where se2.solicitacao = d2.demanda_id 
                   and se2.projeto = se.projeto 
                   and u2.id = p.uo_id
                   and d2.formulario_id = 1), --z),
            (select uo.titulo from uo where uo.id = p.uo_id) UO,
            (select cia.titulo
                from atributoentidadevalor aev, categoria_item_atributo cia
                   where aev.identidade = p.id and 
                         aev.tipoentidade='P' and 
                         aev.atributoid=2 and
                         aev.categoria_item_atributo_id = cia.categoria_item_id) CR,
            null,null,null,null,null,null,null,sysdate
from demanda d, solicitacaoentidade se, projeto p
where  se.solicitacao = d.demanda_id 
  and se.projeto = p.id 
  and d.situacao = 1 --y1
  and d.formulario_id = 1 --z

*/

  select count(*) INTO c 
      from estado_regra_condicional where estado_id = 1--y2 
                                    and formulario_id =1;-- z;
                                    
  if c>0 then
--   ls_erro:='Erro. Foi configurado alguma regra condicional para os Estado. Abortado';
   ln_retorno:=-1;
   return;
  end if;

 ls_query:='
      select ''A'',''I'',''TRACE'',''1'',''Trace'',null,
            -- Atributo da Demanda
            (select av.valordata from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--v
            ) Data,
            -- Atributo da Demanda
            (select av.valornumerico from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--x
            ) Valor ,
            null,null,null,
            sysdate,
            (select av.valordata from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--v
            ) Data2,
            null,null,null,null,null,
            (select av.valor from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--a
            ) Cta_Fluxo ,
            (select av.valor from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--b
            ) Cta_Contabil ,
            ''UU100'',null,
           (select trim(max(u2.titulo)) || '' - ''||p.titulo || '' - ''|| to_char(sum(case when situacao in (1,2,3) -- c lista de estados: Liberado, gerado, pago
            then 1 else 0 end))||''/''||to_char(sum(1)) 
             from demanda d2, solicitacaoentidade se2, uo u2
                 where se2.solicitacao = d2.demanda_id 
                   and se2.projeto = se.projeto 
                   and u2.id = p.uo_id
                   and d2.formulario_id = 1), --z)
            (select uo.titulo from uo where uo.id = p.uo_id) UO,
            (select cia.titulo
                from atributoentidadevalor aev, categoria_item_atributo cia
                   where aev.identidade = p.id and 
                         aev.tipoentidade=''P'' and 
                         aev.atributoid=2 and
                         aev.categoria_item_atributo_id = cia.categoria_item_id) CR,
            null,null,null,null,null,null,null,sysdate
      from demanda d, solicitacaoentidade se, projeto p
      where  se.solicitacao = d.demanda_id 
         and se.projeto = p.id ';
--         and d.situacao = 1 --y1
--         and d.formulario_id = 1 --z';

--if 1>2 then PULA TUDO

  DBMS_LOB.CREATETEMPORARY(blob_edit,TRUE);
   
  ls_seperador_campo:=chr(9);
  ls_seperador_registro:=chr(13)||chr(10);
  c := DBMS_SQL.OPEN_CURSOR;

  DBMS_SQL.PARSE (c, ls_query, DBMS_SQL.NATIVE);

  select count(*) into ln_qtde_campos  from table(f_lista_campos_DOF);

  FOR i IN 1 .. ln_qtde_campos
    LOOP

     select t_tipo_campos(sec,nome,tipo,tamanho,decimais,separador,formato,obrigatorio,opcoes,descricao)
     BULK COLLECT INTO reg     from table(f_lista_campos_DOF) where sec=i;

      BEGIN
        if reg(1).tipo='char' or reg(1).tipo='fixo' then
           DBMS_SQL.define_column(c, i, ls_campo, 2000);
        end if;
        if reg(1).tipo='number' then
           DBMS_SQL.define_column(c, i, ln_campo);
        end if;
        if reg(1).tipo='date' then
           DBMS_SQL.define_column(c, i, ld_campo);
        end if;        

        l_colcnt := i;
      EXCEPTION
        WHEN OTHERS THEN
          IF (SQLCODE = -1007)
          THEN
            EXIT;
          ELSE
            RAISE;
          END IF;
      END;
    END LOOP; 
   DBMS_SQL.define_column(c, 1, ls_campo, 2000);
   fdbk:= DBMS_SQL.EXECUTE (c); 

 LOOP
  EXIT WHEN(DBMS_SQL.fetch_rows(c) <= 0); 

  ls_linha:='';


  FOR i IN 1 .. ln_qtde_campos
      LOOP
     select t_tipo_campos(sec,nome,tipo,tamanho,decimais,separador,formato,obrigatorio,opcoes,descricao)
     BULK COLLECT INTO reg     from table(f_lista_campos_DOF) where sec=i;

     if reg(1).tipo='char' then
        DBMS_SQL.COLUMN_VALUE(c, i, ls_campo);
        if reg(1).formato='X' THEN
           ls_linha := ls_linha || substr(ls_campo,1,reg(1).tamanho);
        end if;
        if reg(1).formato='X ' THEN
           ls_linha := ls_linha || rpad(substr(ls_campo,1,reg(1).tamanho),reg(1).tamanho,' ');
        end if;
        if reg(1).formato=' X' THEN
           ls_linha := ls_linha || lpad(substr(ls_campo,1,reg(1).tamanho),reg(1).tamanho,' ');
        end if;
        end if;
     if reg(1).tipo='fixo' then
        ls_linha := ls_linha || reg(1).formato;
     end if;
     if reg(1).tipo='date' then
        DBMS_SQL.COLUMN_VALUE(c, i, ld_campo);
        ls_linha := ls_linha || to_char(ld_campo,reg(1).formato);
     end if;
     if reg(1).tipo='number' then
        DBMS_SQL.COLUMN_VALUE(c, i, ln_campo);
        ls_linha := ls_linha || to_char(ln_campo,reg(1).formato);
     end if;

     if i <> ln_qtde_campos then
        ls_linha :=ls_linha || ls_seperador_campo;
     else
        ls_linha :=ls_linha || ls_seperador_registro;
     end if;
        
      END LOOP;    

    b_int:=utl_raw.length (utl_raw.cast_to_raw(ls_linha));

    ln_registros:=ln_registros+1;
    
    if (primeiro_registro) then
      dbms_lob.write(blob_edit, b_int, 1, utl_raw.cast_to_raw(ls_linha));
      primeiro_registro:=false;
    else
      dbms_lob.writeappend(blob_edit, b_int , utl_raw.cast_to_raw(ls_linha));
    end if;

 END LOOP;

  update demanda
  set situacao = 1--y2
  where situacao = 1--y1 
    and formulario_id = -1; --z';

 select documento_seq.nextval into ln_doc from dual;
 select documento_conteudo_seq.nextval into ln_doc_cont from dual;

 Insert into DOCUMENTO (DOCUMENTOID,DESCRICAO, TIPOENTIDADE,IDENTIDADE,
                        AREAGERENCIA,ESTADODOCUMENTO,VERSAOATUAL,TIPODOCUMENTO,
                        RESPONSAVEL,DOCUMENTO_PAI,TIPO_DOCUMENTO_ID,TAMANHO) 
 select ln_doc,'DOF Exportado em '||to_char(sysdate,'DD-MM-YYYY HH24-MI-SS'),null,null,
        null,'I',1,'.txt',
        null,null,null,null 
     from dual;

 insert into documento_conteudo (id, documento_id, versao, conteudo)
 values (ln_doc_cont, ln_doc, 1, empty_blob());-- returning conteudo into blob_edit;

 update documento_conteudo
 set conteudo = blob_edit
 where id=ln_doc_cont;

-- Salva em Arquivo Inicio

  select sysdate into ld_data_hora from dual;
  v_chunksize := DBMS_LOB.GETCHUNKSIZE(blob_edit);

    IF (v_chunksize < 32767) THEN
        v_buffer_size := v_chunksize;
    ELSE
        v_buffer_size := 32767;
    END IF;

    v_amount := v_buffer_size;

--    DBMS_LOB.OPEN(v_lob_loc, DBMS_LOB.LOB_READONLY);

    v_out_file := UTL_FILE.FOPEN(
        location      => ls_diretorio, 
        filename      => ls_tipo || '_Trace_para_Zeus_' || to_char(ld_data_hora, 'yyyymmddhh24miss') || '.txt', 
        open_mode     => 'w',
        max_linesize  => 32767);

    WHILE v_amount >= v_buffer_size
    LOOP

      DBMS_LOB.READ(
          lob_loc    => blob_edit,
          amount     => v_amount,
          offset     => v_offset,
          buffer     => v_buffer);

      v_offset := v_offset + v_amount;

      UTL_FILE.PUT_RAW (
          file      => v_out_file,
          buffer    => v_buffer,
          autoflush => true);

      UTL_FILE.FFLUSH(file => v_out_file);


    END LOOP;

    UTL_FILE.FFLUSH(file => v_out_file);

    UTL_FILE.FCLOSE(v_out_file);

    -- +-------------------------------------------------------------+
    -- | CLOSING THE LOB IS MANDATORY IF YOU HAVE OPENED IT          |
    -- +-------------------------------------------------------------+
--    DBMS_LOB.CLOSE(blob_edit);

-- Salva em Arquivo Fim


 dbms_lob.FREETEMPORARY(blob_edit);

 DBMS_SQL.CLOSE_CURSOR (c);
 ln_arquivo:=ln_doc;

--end if; PULA TUDO
-- ln_arquivo:=1000;
 ln_retorno:=ln_registros;
-- raise_application_error(-20001, 'Erro indefinido para testes');

end p_Exporta_Arquivo_CNI;

END PCK_DOCUMENTO;
/

-------------------------------------------------------------------------------
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
  procedure pPublicaIndicador (pn_apuracao_id mapa_indicador_apuracao.id%type, pv_usuario varchar2 );
  procedure pPublicaObjetivo  (pn_apuracao_id mapa_objetivo_apuracao.id%type, pv_usuario varchar2 );

  procedure p_Copiar_Objetivo (pn_objetivo_id mapa_objetivo.id%type, 
                               pn_objetivo_id_pai mapa_objetivo.id%type, 
                               pn_perpectiva_destino mapa_perspectiva.id%type, 
                               pv_novo_usuario usuario.usuarioid%type, 
                               pb_filhos int,
                               pn_ret in out number, 
                               pv_ret_msg in out varchar2);
  procedure p_Copiar_Indicador (pn_indicador_id mapa_indicador.id%type,
                                pn_objetivo_id_destino mapa_perspectiva.id%type, 
                                pv_novo_usuario usuario.usuarioid%type, 
                                pn_ret in out number, 
                                pv_ret_msg in out varchar2);
  procedure p_Copiar_Questao (pn_questao_id mapa_indicador_questao.id%type,
                                pn_categoria_pai_id_destino mapa_indicador_categoria.id%type, 
                                pn_resposta_pai_id_destino mapa_indicador_resposta.id%type, 
                                pn_ret in out number, 
                                pv_ret_msg in out varchar2);
  procedure p_Copiar_ObjetivoDesenho(pn_objetivo_id mapa_objetivo.id%type, 
                                     pn_objetivo_id_pai mapa_objetivo.id%type, 
                                     pn_perpectiva_destino mapa_perspectiva.id%type, 
                                     pv_novo_usuario usuario.usuarioid%type, 
                                     pn_novo_objetivo_id mapa_objetivo.id%type, 
                                     pn_ret in out number, 
                                     pv_ret_msg in out varchar2);

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
                    and   v.indicador_id = ln_indicador_id
                    order by a.data_atualizacao desc) loop
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
  FUNCTION clob_to_blob( c IN CLOB ) RETURN BLOB
  -- typecasts CLOB to BLOB (binary conversion)
  IS
  pos PLS_INTEGER := 1;
  buffer RAW( 32767 );
  res BLOB;
  lob_len PLS_INTEGER := DBMS_LOB.getLength( c );
  BEGIN
  DBMS_LOB.createTemporary( res, TRUE );
  DBMS_LOB.OPEN( res, DBMS_LOB.LOB_ReadWrite );

  LOOP
  buffer := UTL_RAW.cast_to_raw( DBMS_LOB.SUBSTR( c, 16000, pos ) );

  IF UTL_RAW.LENGTH( buffer ) > 0 THEN
  DBMS_LOB.writeAppend( res, UTL_RAW.LENGTH( buffer ), buffer );
  END IF;

  pos := pos + 16000;
  EXIT WHEN pos > lob_len;
  END LOOP;

  RETURN res; -- res is OPEN here
  END clob_to_blob;

   FUNCTION blob_to_clob (blob_in IN BLOB)
    RETURN CLOB
    AS
      v_clob    CLOB;
      v_varchar VARCHAR2(32767);
      v_start	 PLS_INTEGER := 1;
      v_buffer  PLS_INTEGER := 32767;
    BEGIN
      DBMS_LOB.CREATETEMPORARY(v_clob, TRUE);
    	
      FOR i IN 1..CEIL(DBMS_LOB.GETLENGTH(blob_in) / v_buffer)
      LOOP
    		
         v_varchar := UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(blob_in, v_buffer, v_start));
     
               DBMS_LOB.WRITEAPPEND(v_clob, LENGTH(v_varchar), v_varchar);
     
        v_start := v_start + v_buffer;
      END LOOP;
    	
       RETURN v_clob;
      
   END blob_to_clob;

  procedure p_Copiar_ObjetivoDesenho(pn_objetivo_id mapa_objetivo.id%type, 
                                     pn_objetivo_id_pai mapa_objetivo.id%type, 
                                     pn_perpectiva_destino mapa_perspectiva.id%type, 
                                     pv_novo_usuario usuario.usuarioid%type, 
                                     pn_novo_objetivo_id mapa_objetivo.id%type, 
                                     pn_ret in out number, 
                                     pv_ret_msg in out varchar2) is
     blob_edit_orig       BLOB; 
     clob_edit_orig       CLOB; 
     blob_edit_dest       BLOB; 
     clob_edit_dest       CLOB; 
     
     xml_orig              xmltype;
     xml_dest              xmltype;
     xml_nodo              XMLType;
     ls_perspectiva_ori    varchar2(100);
     ln_objetivo_pai       number;
     ls_pai_origem         varchar2(10);
     ls_x                  varchar2(10);
     ls_y                  varchar2(10);
     ls_desloc_x           varchar2(10);
     ls_desloc_y           varchar2(10);
  begin
  
  -- captura desenho do mapa estratétigo Origem
  select e.desenho,trim(to_char(p.id)),nvl(o.objetivo_pai,0) 
    into blob_edit_orig,ls_perspectiva_ori,ln_objetivo_pai 
    from mapa_objetivo o,   mapa_perspectiva p,   mapa_estrategico e 
  where o.tipo_entidade = 'E' and 
        o.perspectiva_id = p.id and 
        p.mapa_id=e.id and
        o.id = pn_objetivo_id;

  -- captura desenho do mapa estratétigo Destino
  select e.desenho into blob_edit_dest from mapa_perspectiva p,   mapa_estrategico e 
  where p.mapa_id=e.id and
        p.id = pn_perpectiva_destino;
        
  -- conversão de lobs Binario para Caracter
  clob_edit_orig:=blob_to_clob(blob_edit_orig);
  clob_edit_dest:=blob_to_clob(blob_edit_dest);
  
  -- converte CLOB em XML
  select XMLType.createXML(clob_edit_orig) into xml_orig from dual;
  select XMLType.createXML(clob_edit_dest) into xml_dest from dual;
/*
  dbms_output.put_line(ls_perspectiva_ori);
 dbms_output.put_line(pn_objetivo_id);
 dbms_output.put_line(ln_objetivo_pai);
 dbms_output.put_line('Origem');
   dbms_output.put_line(DBMS_LOB.SUBSTR( clob_edit_orig, 1000, 1 ));
  dbms_output.put_line(DBMS_LOB.SUBSTR( clob_edit_orig, 1000, 1001 ));
  dbms_output.put_line(DBMS_LOB.SUBSTR( clob_edit_orig, 1000, 2001 ));
  dbms_output.put_line(DBMS_LOB.SUBSTR( clob_edit_orig, 1000, 3001 ));
 */

  -- busca objetivo Origem vinculado
  SELECT extract(xml_orig, 
              '//Objetivo[@idTGP="'||to_char(pn_objetivo_id)||'"]') into xml_nodo from dual;
   
--  end if;

  -- deleta filhos     
--  select updateXML(xml_nodo,'/Objetivo/Objetivo',null) into xml_nodo from dual;
 select deleteXML(xml_nodo,'/Objetivo/Objetivo') into xml_nodo from dual;

  -- atualiza dados do bloco copiado
    select updateXML(xml_nodo,
             '/Objetivo/@idTGP',
             trim(to_char(pn_novo_objetivo_id))) into xml_nodo from dual;

    select updateXML(xml_nodo,
         '/Objetivo/@perspectivaId',
         trim(to_char(pn_perpectiva_destino))) into xml_nodo from dual;


   -- Tratamento do posicionamento
   -- Pai fica no canto esquerdo alto, filhos com os deslocamentos da origem
   ls_desloc_x:='0';
   ls_desloc_y:='0';

  if pn_objetivo_id_pai<>0 then

   select extractValue(value(vv), '/Objetivo/@parentIdTGP')
     into ls_pai_origem 
     from table(XMLSequence(extract(xml_orig, 
                '//Objetivo[@idTGP="'||to_char(pn_objetivo_id)||'"]'))) vv;

   select extractValue(value(vv), '/Objetivo/@x'), extractValue(value(vv), '/Objetivo/@y'), extractValue(value(vv), '/Objetivo/@parentIdTGP')
     into ls_desloc_x,ls_desloc_y, ls_pai_origem 
     from table(XMLSequence(extract(xml_orig, 
                '//Objetivo[@idTGP="'||ls_pai_origem||'"]'))) vv;

--  dbms_output.put_line('POS PAI ORI x: '||ls_desloc_x);
--  dbms_output.put_line('POS PAI ORI Y: '||ls_desloc_y);

   select extractValue(value(vv), '/Objetivo/@x'), extractValue(value(vv), '/Objetivo/@y')
     into ls_x, ls_y
     from table(XMLSequence(extract(xml_orig, 
                '//Objetivo[@idTGP="'||to_char(pn_objetivo_id)||'"]'))) vv;

--  dbms_output.put_line('POS FI ORI x: '||ls_x);
--  dbms_output.put_line('POS FI ORI Y: '||ls_y);
           
     ls_desloc_x:=trim(to_char(to_number(ls_x)-to_number(ls_desloc_x)));
     ls_desloc_y:=trim(to_char(to_number(ls_y)-to_number(ls_desloc_y)));

--  dbms_output.put_line('Desloc x: '||ls_desloc_x);
--  dbms_output.put_line('Desloc Y: '||ls_desloc_y);

  end if;

   select extractValue(value(vv), '/Perspectiva/@x'), extractValue(value(vv), '/Perspectiva/@y')
     into ls_x, ls_y
     from table(XMLSequence(extract(xml_dest, 
                '/form/Perspectiva[@idTGP="'||pn_perpectiva_destino||'"]'))) vv;

   select updateXML(xml_nodo,
         '/Objetivo/@x',
         trim(to_char(to_number(ls_desloc_x)+to_number(ls_x)+20))) into xml_nodo from dual;

   select updateXML(xml_nodo,
         '/Objetivo/@y',
         trim(to_char(to_number(ls_desloc_y)+to_number(ls_y)+20))) into xml_nodo from dual;

--  dbms_output.put_line('Pai no desenho'||ln_objetivo_pai);
 
  if pn_objetivo_id_pai<>0 then
       select updateXML(xml_nodo,
             '/Objetivo/@parentIdTGP',
             trim(to_char(pn_objetivo_id_pai))) into xml_nodo from dual;
       select updateXML(xml_nodo,
             '/Objetivo/@parentType',
             'Objetivo') into xml_nodo from dual;
    else
       
       select updateXML(xml_nodo,
             '/Objetivo/@parentIdTGP',
             trim(to_char(pn_perpectiva_destino))) into xml_nodo from dual;
       select updateXML(xml_nodo,
             '/Objetivo/@parentType',
             'Perspectiva') into xml_nodo from dual;
    end if;


--  dbms_output.put_line(xml_nodo.GetStringVal());

  -- insere bloco novo
  if pn_objetivo_id_pai<>0 then
    select  insertChildXML(xml_dest, 
                         '//Objetivo[@idTGP="'||pn_objetivo_id_pai||'"]', 
                         'Objetivo', 
                         xml_nodo) into xml_dest from dual;
  else
    select  insertChildXML(xml_dest, 
                         '/form/Perspectiva[@idTGP="'||pn_perpectiva_destino||'"]', 
                         'Objetivo', 
                         xml_nodo) into xml_dest from dual;
  
  end if;
  -- convert XMLType para CLOB
  select xml_dest.getClobVal() into clob_edit_dest from dual; 
    
  -- convert CLOB para BLOB
  blob_edit_dest:=clob_to_blob(clob_edit_dest);

  -- atualiza desenho do mapa estratétigo Destino
  update mapa_estrategico
  set desenho=blob_edit_dest
  where id= (select p.mapa_id from mapa_perspectiva p where p.id = pn_perpectiva_destino);
/*
  dbms_output.put_line('Origem');
  dbms_output.put_line(DBMS_LOB.SUBSTR( clob_edit_orig, 1000, 1 ));
  dbms_output.put_line(DBMS_LOB.SUBSTR( clob_edit_orig, 1000, 1001 ));
  dbms_output.put_line(DBMS_LOB.SUBSTR( clob_edit_orig, 1000, 2001 ));
  dbms_output.put_line(DBMS_LOB.SUBSTR( clob_edit_orig, 1000, 3001 ));
  
  dbms_output.put_line(xml_nodo.GetStringVal());
  dbms_output.put_line('Destino');
  dbms_output.put_line(DBMS_LOB.SUBSTR( clob_edit_dest, 1000, 1 ));
  dbms_output.put_line(DBMS_LOB.SUBSTR( clob_edit_dest, 1000, 1001 ));
  dbms_output.put_line(DBMS_LOB.SUBSTR( clob_edit_dest, 1000, 2001 ));
  dbms_output.put_line(DBMS_LOB.SUBSTR( clob_edit_dest, 1000, 3001 ));
  */
  pn_ret:=1;
  pv_ret_msg:='';
  return;
  end;

  procedure p_atualiza_Formula_Objetivo(pn_objetivo_id_pai mapa_objetivo.id%type, 
                                        pn_velho_objetivo_id mapa_objetivo.id%type, 
                                        pn_novo_objetivo_id mapa_objetivo.id%type, 
                                        pn_ret in out number, 
                                        pv_ret_msg in out varchar2) is

        ln_objetivo_id_pai mapa_objetivo.id%type;
        ln_velho_objetivo_id mapa_objetivo.id%type; 
        ln_novo_objetivo_id mapa_objetivo.id%type;

  begin

    -- Atualiza fórmula do Objetivo Pai com o novo ID do Indicador
    -- 1.delimita todos operadores por '!'
    -- 2.substitui
    -- 3. retira os '!z'
    update mapa_objetivo
    set formula=
                  trim(
                  replace(
                  replace(             
                  '!'||replace(replace(replace(replace(replace(replace(replace(formula,'+','!+!'),'-','!-!'),'*','!*!'),'/','!/!'),')','!)!'),'(','!(!'),' ')||'!'  
                  ,'!O_'||to_char(pn_velho_objetivo_id)||'!','!O_'||to_char(pn_novo_objetivo_id)||'!')
                  ,'!',' ')
                  )
    where id=pn_objetivo_id_pai and formula is not null;

    
    select  objetivo_pai into ln_novo_objetivo_id
       from mapa_objetivo where id=pn_novo_objetivo_id;

    select  objetivo_pai into ln_velho_objetivo_id
       from mapa_objetivo where id=pn_velho_objetivo_id;

    select  objetivo_pai into ln_objetivo_id_pai
       from mapa_objetivo where id=ln_novo_objetivo_id;


    if (ln_objetivo_id_pai is not null) then
      p_atualiza_Formula_Objetivo(ln_objetivo_id_pai, 
                                  ln_velho_objetivo_id, 
                                  ln_novo_objetivo_id,
                                  pn_ret, 
                                  pv_ret_msg);

       if pn_ret<> 1 then
         rollback;
         return;
       end if;
    end if;

  
  pn_ret:=1;
  pv_ret_msg:='';
  return;
  end;

  procedure p_Copiar_Objetivo (pn_objetivo_id mapa_objetivo.id%type, 
                               pn_objetivo_id_pai mapa_objetivo.id%type, 
                               pn_perpectiva_destino mapa_perspectiva.id%type, 
                               pv_novo_usuario usuario.usuarioid%type, 
                               pb_filhos int,
                               pn_ret in out number, 
                               pv_ret_msg in out varchar2) is
    ln_id_obj  number;
    ln_id_temp  number;
    ln_id_temp2  number;
    ln_mapa_destino  number;
    ln_mapa_origem  number;
    
  begin

  select mp.mapa_id into ln_mapa_destino from mapa_perspectiva mp where mp.id=pn_perpectiva_destino;
  select entidade_id into ln_mapa_origem from mapa_objetivo where id=pn_objetivo_id;
  
    ---------------------------
    -- mapa_objetivo         --
    ---------------------------
    select mapa_objetivo_seq.nextval into ln_id_obj from dual;
    begin
    insert into mapa_objetivo (id,objetivo_pai,titulo,descricao,tipo,validade,mnemonico,
                               unidade,tipo_entidade,entidade_id,desc_meta,periodo_apuracao,
                               previsao_apuracao,frequencia_apuracao,formula,desc_formula,
                               inicio_apuracao,data_criacao,data_atualizacao,vigente,visivel,
                               usuario_criacao_id,usuario_atualizacao_id,perspectiva_id,responsavel)
    select                     ln_id_obj,pn_objetivo_id_pai,titulo,descricao,tipo,validade,mnemonico,
                               unidade,tipo_entidade,
                               ln_mapa_destino,desc_meta,periodo_apuracao,
                               previsao_apuracao,frequencia_apuracao,formula,desc_formula,
                               inicio_apuracao,sysdate,sysdate,vigente,visivel,
                               pv_novo_usuario,pv_novo_usuario,pn_perpectiva_destino,pv_novo_usuario
       from mapa_objetivo where id=pn_objetivo_id;
                 
    exception when others then
       pn_ret  := -1;
       pv_ret_msg := 'Erro ao inserir na tabela:mapa_objetivo.'||sqlerrm;
       rollback;
       return;
    end;

    -- atualiza recursivamente as fórmulas dos objetivos pais
    if (pn_objetivo_id_pai is not null) then
      p_atualiza_Formula_Objetivo(pn_objetivo_id_pai, 
                                  pn_objetivo_id, 
                                  ln_id_obj,
                                  pn_ret, 
                                  pv_ret_msg);

       if pn_ret<> 1 then
         rollback;
         return;
       end if;
    end if;

-- dbms_output.put_line('Vai desenhar Orig:'||pn_objetivo_id||' Novo:'||ln_id_obj||' Pai:'||nvl(pn_objetivo_id_pai,0));
/* dbms_output.put_line('Pai:'||nvl(pn_objetivo_id_pai,0));
 dbms_output.put_line('Pers Dest:'||pn_perpectiva_destino);
 dbms_output.put_line('Novo Obj:'||ln_id_obj);
 */
    p_Copiar_ObjetivoDesenho(pn_objetivo_id, 
                             nvl(pn_objetivo_id_pai,0), 
                             pn_perpectiva_destino, 
                             pv_novo_usuario, 
                             ln_id_obj, 
                             pn_ret, 
                             pv_ret_msg);

     if pn_ret<> 1 then
       rollback;
       return;
     end if;
    
    ---------------------------
    -- mapa_objetivo_faixa   --
    ---------------------------
    for cs in (select id,objetivo_id,percentual_meta,cor,assunto,introducao,
                      data_criacao,data_atualizacao,usuario_criacao_id,usuario_atualizacao_id
                from mapa_objetivo_faixa where objetivo_id=pn_objetivo_id)
    loop 

      select mapa_objetivo_faixa_seq.nextval into ln_id_temp from dual;
      begin
      insert into mapa_objetivo_faixa (id,objetivo_id,percentual_meta,cor,assunto,introducao,
                                 data_criacao,data_atualizacao,usuario_criacao_id,usuario_atualizacao_id)
              values (ln_id_temp,ln_id_obj,cs.percentual_meta,cs.cor,cs.assunto,cs.introducao,
                                 sysdate, sysdate,pv_novo_usuario,pv_novo_usuario);
      exception when others then
         pn_ret  := -1;
         pv_ret_msg := 'Erro ao inserir na tabela:mapa_objetivo_faixa.';
         rollback;
         return;
      end;
      

        ------------------------------
        -- mapa_objetivo_faixa_dest --
        ------------------------------
        for cs2 in (select ID,FAIXA_ID,USUARIO_ID,NOME_USUARIO,EMAIL,DATA_CRIACAO,
                          DATA_ATUALIZACAO,USUARIO_CRIACAO_ID,USUARIO_ATUALIZACAO_ID
                    from mapa_objetivo_faixa_dest where faixa_id=cs.id)
        loop 

          select mapa_objetivo_faixa_seq.nextval into ln_id_temp2 from dual;
          begin
          insert into mapa_objetivo_faixa_dest (ID,FAIXA_ID,USUARIO_ID,NOME_USUARIO,EMAIL,DATA_CRIACAO,
                          DATA_ATUALIZACAO,USUARIO_CRIACAO_ID,USUARIO_ATUALIZACAO_ID)
                  values (ln_id_temp2,cs.id,cs2.USUARIO_ID,cs2.NOME_USUARIO,cs2.EMAIL,sysdate,
                          sysdate,pv_novo_usuario,pv_novo_usuario);
          exception when others then
             pn_ret  := -1;
             pv_ret_msg := 'Erro ao inserir na tabela:mapa_objetivo_faixa_dest.';
             rollback;
             return;
          end;
          
        end loop;

    end loop;

    ------------------------------
    -- mapa_objetivo_meta       --
    ------------------------------
    for cs in (select ID,OBJETIVO_ID,DATA_LIMITE,VALOR,COMENTARIO,DATA_CRIACAO,
                       DATA_ATUALIZACAO,USUARIO_CRIACAO_ID,USUARIO_ATUALIZACAO_ID
                from mapa_objetivo_meta where OBJETIVO_ID=pn_objetivo_id)
    loop 

      select mapa_objetivo_meta_seq.nextval into ln_id_temp from dual;
      begin
      insert into mapa_objetivo_meta (ID,OBJETIVO_ID,DATA_LIMITE,VALOR,COMENTARIO,DATA_CRIACAO,
                       DATA_ATUALIZACAO,USUARIO_CRIACAO_ID,USUARIO_ATUALIZACAO_ID)
              values (ln_id_temp,ln_id_obj,cs.DATA_LIMITE,cs.VALOR,cs.COMENTARIO,sysdate,
                       sysdate,pv_novo_usuario,pv_novo_usuario);
      exception when others then
         pn_ret  := -1;
         pv_ret_msg := 'Erro ao inserir na tabela:mapa_objetivo_meta.';
         rollback;
         return;
      end;
          
    end loop;

    ------------------------------
    -- mapa_indicador  FILHOS   --
    ------------------------------
    for cs in (select id
                from mapa_indicador where objetivo_pai=pn_objetivo_id)
    loop 
       PCK_INDICADOR.p_Copiar_Indicador(cs.id, ln_id_obj, pv_novo_usuario, pn_ret,pv_ret_msg);
       if pn_ret<> 1 then
         rollback;
         return;
       end if;
    end loop;


    if (pb_filhos=1) then

        ------------------------------
        -- mapa_objetivo   FILHOS   --
        ------------------------------
        for cs in (select id
                    from mapa_objetivo where objetivo_pai=pn_objetivo_id)
        loop 
           PCK_INDICADOR.p_Copiar_Objetivo(cs.id, ln_id_obj, pn_perpectiva_destino, pv_novo_usuario, 
                                           pb_filhos,pn_ret,pv_ret_msg);
              
           if pn_ret not in (1,2) then
             rollback;
             return;
           end if;
        end loop;
      
    end if;
    -- se for o mesmo mapa, necessita refresh na tela, retornar 2
    if ln_mapa_origem=ln_mapa_destino then
       pn_ret:=2;
    else
       pn_ret:=1;
    end if;
    pv_ret_msg:='';
    return;
  end;

  procedure p_Copiar_Indicador (pn_indicador_id mapa_indicador.id%type,
                                pn_objetivo_id_destino mapa_perspectiva.id%type, 
                                pv_novo_usuario usuario.usuarioid%type, 
                                pn_ret in out number, 
                                pv_ret_msg in out varchar2) is
    ln_id_ind  number;
    ln_id_temp  number;
    ln_id_temp2  number;
    ln_id_temp_quebra number;
  begin


    select mapa_indicador_seq.nextval into ln_id_ind from dual;

    begin
    insert into mapa_indicador (ID,OBJETIVO_PAI,TITULO,DESCRICAO,TIPO,SUBTIPO,VALIDADE,MNEMONICO,UNIDADE,INDICADOR_ORIGEM_ID,FONTE,
                                TIPO_ENTIDADE,ENTIDADE_ID,DESC_META,INDICADOR_APURACAO,PREVISAO_APURACAO,TIPO_ENTIDADE_APURACAO,ENTIDADE_APURACAO_ID,
                                ESTADO_APURACAO_ID,SITUACAO_PRJ_APURACAO_ID,INICIO_APURACAO,INDICADOR_NOVA_APURACAO,PERIODO_APURACAO,FREQUENCIA_APURACAO,
                                PRAZO_APURACAO,DETALHAMENTO,CALCULO_DETALHAMENTO,PESO,TIPO_QUESTIONARIO_ID,FORMULA,DESC_FORMULA,FILTRO_ID,ROTINA_ID,
                                CONSULTASQL,DATA_CRIACAO,DATA_ATUALIZACAO,USUARIO_CRIACAO_ID,USUARIO_ATUALIZACAO_ID,INDICADOR_TEMPLATE,TEMPLATE_ID,RESPONSAVEL)
       SELECT ln_id_ind,pn_objetivo_id_destino,TITULO,DESCRICAO,TIPO,SUBTIPO,VALIDADE,MNEMONICO,UNIDADE,NULL,FONTE,
              TIPO_ENTIDADE,ENTIDADE_ID,DESC_META,INDICADOR_APURACAO,PREVISAO_APURACAO,TIPO_ENTIDADE_APURACAO,ENTIDADE_APURACAO_ID,
              ESTADO_APURACAO_ID,SITUACAO_PRJ_APURACAO_ID,TRUNC(SYSDATE+1),INDICADOR_NOVA_APURACAO,PERIODO_APURACAO,FREQUENCIA_APURACAO,
              PRAZO_APURACAO,DETALHAMENTO,CALCULO_DETALHAMENTO,PESO,TIPO_QUESTIONARIO_ID,FORMULA,DESC_FORMULA,FILTRO_ID,ROTINA_ID,
              CONSULTASQL,SYSDATE, SYSDATE,pv_novo_usuario,pv_novo_usuario,INDICADOR_TEMPLATE,TEMPLATE_ID,pv_novo_usuario
         FROM mapa_indicador WHERE ID=pn_indicador_id;
    exception when others then
       pn_ret  := -1;
       pv_ret_msg := 'Erro ao inserir na tabela:mapa_indicador.';
       rollback;
       return;
    end;

    -- Atualiza fórmula do Objetivo Pai com o novo ID do Indicador
    -- 1.delimita todos operadores por '!'
    -- 2.substitui
    -- 3. retira os '!z'
    update mapa_objetivo
    set formula=
                  trim(
                  replace(
                  replace(             
                  '!'||replace(replace(replace(replace(replace(replace(replace(formula,'+','!+!'),'-','!-!'),'*','!*!'),'/','!/!'),')','!)!'),'(','!(!'),' ')||'!'  
                  ,'!I_'||to_char(pn_indicador_id)||'!','!I_'||to_char(ln_id_ind)||'!')
                  ,'!',' ')
                  )
    where id=pn_objetivo_id_destino and formula is not null;

    ------------------------------
    -- mapa_indicador_variavel --
    ------------------------------

    for cs in (select ID,INDICADOR_ID,NOME,MNEMONICO,INDICADOR_DOMINIO,DATA_CRIACAO,
                      DATA_ATUALIZACAO,USUARIO_CRIACAO_ID,USUARIO_ATUALIZACAO_ID
                from mapa_indicador_variavel where INDICADOR_ID=pn_indicador_id)
    loop 

      select mapa_indicador_variavel_seq.nextval into ln_id_temp from dual;
      begin
      insert into mapa_indicador_variavel (ID,INDICADOR_ID,NOME,MNEMONICO,INDICADOR_DOMINIO,DATA_CRIACAO,
                                           DATA_ATUALIZACAO,USUARIO_CRIACAO_ID,USUARIO_ATUALIZACAO_ID)
              values (ln_id_temp,ln_id_ind,cs.NOME,cs.MNEMONICO,cs.INDICADOR_DOMINIO,sysdate,
                                           sysdate,pv_novo_usuario,pv_novo_usuario);
      exception when others then
         pn_ret  := -1;
         pv_ret_msg := 'Erro ao inserir na tabela:mapa_indicador_variavel.';
         rollback;
         return;
      end;

      ------------------------------
      -- mapa_indicador_dom_var --
      ------------------------------
      for cs2 in (select id,variavel_id,descricao,vigente,valor,data_criacao,
                        data_atualizacao,usuario_criacao_id,usuario_atualizacao_id
                  from mapa_indicador_dom_var where VARIAVEL_ID=ln_id_temp)
      loop 

        select mapa_indicador_dom_var_seq.nextval into ln_id_temp2 from dual;
        begin
        insert into mapa_indicador_dom_var (id,variavel_id,descricao,vigente,valor,data_criacao,
                                              data_atualizacao,usuario_criacao_id,usuario_atualizacao_id)
                values (ln_id_temp2,ln_id_temp,cs2.descricao,cs2.vigente,cs2.valor,sysdate,
                                              sysdate,pv_novo_usuario,pv_novo_usuario);
        exception when others then
           pn_ret  := -1;
           pv_ret_msg := 'Erro ao inserir na tabela:mapa_indicador_dom_var.';
           rollback;
           return;
        end;
                
      end loop;


    end loop;
    
    ------------------------------
    -- mapa_indicador_quebra    --
    ------------------------------
    for cs in (select ID,INDICADOR_ID,ITEM_ID,PESO,VISIVEL,DATA_CRIACAO,DATA_ATUALIZACAO,USUARIO_CRIACAO_ID,USUARIO_ATUALIZACAO_ID
                from mapa_indicador_quebra where indicador_ID=pn_indicador_id)
    loop 

      select mapa_indicador_quebra_seq.nextval into ln_id_temp_quebra from dual;
      begin
      insert into mapa_indicador_quebra (ID,INDICADOR_ID,ITEM_ID,PESO,VISIVEL,DATA_CRIACAO,DATA_ATUALIZACAO,USUARIO_CRIACAO_ID,USUARIO_ATUALIZACAO_ID)
              values (ln_id_temp,ln_id_ind,cs.ITEM_ID,cs.PESO,cs.VISIVEL,sysdate,sysdate,pv_novo_usuario,pv_novo_usuario);
      exception when others then
         pn_ret  := -1;
         pv_ret_msg := 'Erro ao inserir na tabela:mapa_indicador_quebra.';
         rollback;
         return;
      end;
          
    end loop;
    

    ------------------------------
    -- mapa_consulta_params    --
    ------------------------------
    for cs in (select ID,INDICADOR_ID,NOME,VALOR,DATA_CRIACAO,DATA_ATUALIZACAO,USUARIO_CRIACAO_ID,USUARIO_ATUALIZACAO_ID
                from mapa_consulta_params where indicador_ID=pn_indicador_id)
    loop 

      select mapa_consulta_params_seq.nextval into ln_id_temp from dual;
      begin
      insert into mapa_consulta_params (ID,INDICADOR_ID,NOME,VALOR,DATA_CRIACAO,DATA_ATUALIZACAO,USUARIO_CRIACAO_ID,USUARIO_ATUALIZACAO_ID)
              values (ln_id_temp,ln_id_ind,cs.NOME,cs.VALOR,sysdate,sysdate,pv_novo_usuario,pv_novo_usuario);
      exception when others then
         pn_ret  := -1;
         pv_ret_msg := 'Erro ao inserir na tabela:mapa_consulta_params.';
         rollback;
         return;
      end;
          
    end loop;

    ------------------------------
    -- mapa_meta                --
    ------------------------------
    for cs in (select ID,INDICADOR_ID,QUEBRA_ID,DATA_LIMITE,VALOR,COMENTARIO,DATA_CRIACAO,DATA_ATUALIZACAO,USUARIO_CRIACAO_ID,USUARIO_ATUALIZACAO_ID
                from mapa_meta where indicador_ID=pn_indicador_id)
    loop 

      select mapa_meta_seq.nextval into ln_id_temp from dual;
      begin
      insert into mapa_meta (ID,INDICADOR_ID,QUEBRA_ID,DATA_LIMITE,VALOR,COMENTARIO,DATA_CRIACAO,DATA_ATUALIZACAO,USUARIO_CRIACAO_ID,USUARIO_ATUALIZACAO_ID)
              values (ln_id_temp,ln_id_ind,ln_id_temp_quebra,cs.DATA_LIMITE,cs.VALOR,cs.COMENTARIO,sysdate,sysdate,pv_novo_usuario,pv_novo_usuario);
      exception when others then
         pn_ret  := -1;
         pv_ret_msg := 'Erro ao inserir na tabela:mapa_meta.';
         rollback;
         return;
      end;
          
    end loop;

    ---------------------------
    -- mapa_meta_faixa   --
    ---------------------------
    for cs in (select ID,INDICADOR_ID,PERCENTUAL_META,COR,ASSUNTO,INTRODUCAO,DATA_CRIACAO,DATA_ATUALIZACAO,USUARIO_CRIACAO_ID,USUARIO_ATUALIZACAO_ID
                from mapa_meta_faixa where indicador_ID=pn_indicador_id)
    loop 

      select mapa_meta_faixa_seq.nextval into ln_id_temp from dual;
      begin
      insert into mapa_meta_faixa (ID,INDICADOR_ID,PERCENTUAL_META,COR,ASSUNTO,INTRODUCAO,DATA_CRIACAO,DATA_ATUALIZACAO,USUARIO_CRIACAO_ID,USUARIO_ATUALIZACAO_ID)
              values (ln_id_temp,ln_id_ind,cs.PERCENTUAL_META,cs.COR,cs.ASSUNTO,cs.INTRODUCAO,
                                 sysdate, sysdate,pv_novo_usuario,pv_novo_usuario);
      
      exception when others then
         pn_ret  := -1;
         pv_ret_msg := 'Erro ao inserir na tabela:mapa_meta_faixa.';
         rollback;
         return;
      end;

        ------------------------------
        -- mapa_objetivo_faixa_dest --
        ------------------------------
        for cs2 in (select ID,FAIXA_ID,USUARIO_ID,EMAIL,DATA_CRIACAO,DATA_ATUALIZACAO,USUARIO_CRIACAO_ID,USUARIO_ATUALIZACAO_ID,NOME
                    from mapa_meta_faixa_dest where faixa_id=cs.id)
        loop 

          select mapa_meta_faixa_dest_seq.nextval into ln_id_temp2 from dual;
          begin
          insert into mapa_meta_faixa_dest (ID,FAIXA_ID,USUARIO_ID,EMAIL,DATA_CRIACAO,DATA_ATUALIZACAO,USUARIO_CRIACAO_ID,USUARIO_ATUALIZACAO_ID,NOME)
                  values (ln_id_temp2,cs.id,cs2.USUARIO_ID,cs2.EMAIL,sysdate,
                          sysdate,pv_novo_usuario,pv_novo_usuario,cs2.nome);
          exception when others then
             pn_ret  := -1;
             pv_ret_msg := 'Erro ao inserir na tabela:mapa_meta_faixa_dest.';
             rollback;
             return;
          end;
          
        end loop;

    end loop;
    
    ------------------------------
    -- mapa_indicador_categoria --
    ------------------------------
    for cs in (select ID,INDICADOR_ID,PESO,TITULO,DESCRICAO
                from mapa_indicador_categoria where indicador_ID=pn_indicador_id)
    loop 

      select mapa_indicador_categoria_seq.nextval into ln_id_temp from dual;
      begin
      insert into mapa_indicador_categoria (ID,INDICADOR_ID,PESO,TITULO,DESCRICAO)
              values (ln_id_temp,ln_id_ind,cs.PESO,cs.TITULO,cs.DESCRICAO);
      exception when others then
         pn_ret  := -1;
         pv_ret_msg := 'Erro ao inserir na tabela:mapa_indicador_categoria.';
         rollback;
         return;
      end;

      ---------------------
      -- Questoes filhos --
      ---------------------
      for cs2 in (select ID,categoria_pai, resposta_pai
                  from mapa_indicador_questao where categoria_pai = cs.id)
      loop 
         PCK_INDICADOR.p_Copiar_Questao( cs2.ID, cs2.categoria_pai, cs2.resposta_pai,pn_ret, pv_ret_msg);
         if pn_ret<> 1 then
           rollback;
           return;
         end if;
      end loop;
          
    end loop;

    pn_ret:=1;
    pv_ret_msg:='';
    return;
    end;

  procedure p_Copiar_Questao (pn_questao_id mapa_indicador_questao.id%type,
                                pn_categoria_pai_id_destino mapa_indicador_categoria.id%type, 
                                pn_resposta_pai_id_destino mapa_indicador_resposta.id%type, 
                                pn_ret in out number, 
                                pv_ret_msg in out varchar2) is

    ln_id_questao  number;
    ln_id_temp  number;
    begin
    select mapa_indicador_questao_seq.nextval into ln_id_questao from dual;

    begin
    insert into mapa_indicador_questao (ID,PESO,TITULO,CATEGORIA_PAI,RESPOSTA_PAI,ORDEM,OBRIGATORIA,FORMATO)
       SELECT ln_id_questao,PESO,TITULO,pn_categoria_pai_id_destino,pn_resposta_pai_id_destino,ORDEM,OBRIGATORIA,FORMATO
         FROM mapa_indicador_questao WHERE ID=pn_questao_id;
    exception when others then
       pn_ret  := -1;
       pv_ret_msg := 'Erro ao inserir na tabela:mapa_indicador_questao.';
       rollback;
       return;
    end;

      ------------------------------
      -- mapa_indicador_resposta --
      ------------------------------
      for cs in (select ID,VALOR,TITULO,QUESTAO_PAI,PADRAO
                  from mapa_indicador_resposta where questao_pai=pn_questao_id)
      loop 
        
       select mapa_indicador_resposta_seq.nextval into ln_id_temp from dual;
       begin
       insert into mapa_indicador_resposta (ID,VALOR,TITULO,QUESTAO_PAI,PADRAO)
       SELECT ln_id_temp,cs.VALOR,cs.TITULO,ln_id_questao,cs.PADRAO
         FROM mapa_indicador_resposta WHERE ID=cs.id;
        exception when others then
           pn_ret  := -1;
           pv_ret_msg := 'Erro ao inserir na tabela:mapa_indicador_resposta.';
           rollback;
           return;
        end;

        ---------------------
        -- Questoes filhos --
        ---------------------
        for cs2 in (select ID,categoria_pai, resposta_pai
                    from mapa_indicador_questao where resposta_pai = cs.id)
        loop 
           PCK_INDICADOR.p_Copiar_Questao( cs2.ID, cs2.categoria_pai, cs2.resposta_pai,pn_ret, pv_ret_msg);
           if pn_ret<> 1 then
             rollback;
             return;
           end if;
        end loop;

      end loop;

    pn_ret:=1;
    pv_ret_msg:='';
    return;
    end;
   
end pck_indicador;
/



create or replace view v_dados_crono_desembolso as
select /*+ full(cl) full(ce) full(cr) full(fa) full(td) full(p) full(cce) full(cc)
           use_hash(cl) use_hash(ce) use_hash(cr) use_hash(fa) use_hash(td) use_hash(p) use_hash(cce) use_hash(cc) */
        -- Dados tabela CUSTO_LANCAMENTO
        cl.data CUSTO_LANCAMENTO_DATA, cl.id CUSTO_LANCAMENTO_ID,
        cl.situacao CUSTO_LANCAMENTO_SITUACAO, cl.tipo CUSTO_LANCAMENTO_TIPO,
        cl.usuario_id CUSTO_LANCAMENTO_USUARIO_ID,
        -- Detalhar valor por CPV, CRV, RPV, RRV, CPE, CRE, RPE, RRE
        nvl(cce.influencia,100)/100 * decode(cr.tipo, 'C', decode(cl.tipo, 'P', decode(cl.situacao, 'V', cl.valor, 0), 0), 0) CPV,
        nvl(cce.influencia,100)/100 * decode(cr.tipo, 'C', decode(cl.tipo, 'P', decode(cl.situacao, 'E', cl.valor, 0), 0), 0) CPE,
        nvl(cce.influencia,100)/100 * decode(cr.tipo, 'C', decode(cl.tipo, 'R', decode(cl.situacao, 'V', cl.valor, 0), 0), 0) CRV,
        nvl(cce.influencia,100)/100 * decode(cr.tipo, 'C', decode(cl.tipo, 'R', decode(cl.situacao, 'E', cl.valor, 0), 0), 0) CRE,
        nvl(cce.influencia,100)/100 * decode(cr.tipo, 'R', decode(cl.tipo, 'P', decode(cl.situacao, 'V', cl.valor, 0), 0), 0) RPV,
        nvl(cce.influencia,100)/100 * decode(cr.tipo, 'R', decode(cl.tipo, 'P', decode(cl.situacao, 'E', cl.valor, 0), 0), 0) RPE,
        nvl(cce.influencia,100)/100 * decode(cr.tipo, 'R', decode(cl.tipo, 'R', decode(cl.situacao, 'V', cl.valor, 0), 0), 0) RRV,
        nvl(cce.influencia,100)/100 * decode(cr.tipo, 'R', decode(cl.tipo, 'R', decode(cl.situacao, 'E', cl.valor, 0), 0), 0) RRE,
        -- Dados tabela CUSTO_ENTIDADE
        ce.id CUSTO_ENTIDADE_ID, ce.titulo CUSTO_ENTIDADE_TITULO,
        -- Dados tabela CUSTO_RECEITA
        cr.id CUSTO_RECEITA_ID, cr.id_pai CUSTO_RECEITA_ID_PAI,
        cr.tipo CUSTO_RECEITA_TIPO, cr.titulo CUSTO_RECEITA_TITULO,
        cr.vigente CUSTO_RECEITA_VIGENTE,
        -- Dados tabela FORMAAQUISICAO
        fa.id FORMA_AQUISICAO_ID, fa.tipo FORMA_AQUISICAO_TIPO,
        fa.titulo FORMA_AQUISICAO_TITULO, fa.vigente FORMA_AQUISICAO_VIGENTE,
        -- Dados tabela TIPODESPESA
        td.id TIPO_DESPESA_ID, td.tipo TIPO_DESPESA_TIPO,
        td.descricao TIPO_DESPESA_DESCRICAO, td.vigente TIPO_DESPESA_VIGENTE,
        td.conta_contabil TD_CONTA_CONTABIL,
        -- Dados tabela PROJETO
        'P' TIPO_ENTIDADE, p.id ENTIDADE_ID, p.tipoprojetoid TIPO_PROJETO,
        null TIPO_ATIVIDADE, null TIPO_TAREFA, p.id PROJETO_ID,
        -- Dados tabela CENTRO_CUSTO_ENTIDADE
        cce.influencia CC_ENTIDADE_INFLUENCIA,
        -- Dados tabela CENTRO_CUSTO
        cc.id CENTRO_CUSTO_ID, cc.titulo CENTRO_CUSTO_TITULO,
        cc.parent_id CENTRO_CUSTO_PAI, cc.vigente CENTRO_CUSTO_VIGENTE,
        cc.tipo CENTRO_CUSTO_TIPO,
        cl.data_alteracao CUSTO_LANCAMENTO_ALTERACAO,
        cl.valor CUSTO_LANCAMENTO_VALOR,
        cl.valor_unitario CL_VALOR_UNITARIO,
        cl.quantidade CUSTO_LANCAMENTO_QUANTIDADE,
        ce.motivo MOTIVO,
        ce.unidade UNIDADE,
        p.titulo TITULO_ENTIDADE,
        cl.descricao CUSTO_LANCAMENTO_DESCRICAO
   from custo_lancamento cl,
        custo_entidade   ce,
        custo_receita    cr,
        formaaquisicao   fa,
        tipodespesa      td,
        projeto          p,
        centro_custo_entidade cce,
        centro_custo     cc
  where cc.id(+) = cce.centrocustoid
    and fa.id = ce.forma_aquisicao_id
    and td.id = ce.tipo_despesa_id
    and cr.id = ce.custo_receita_id
    and cce.tipoentidade(+) = 'P'
    and cce.identidade(+) = p.id
    and p.id  = ce.entidade_id
    and ce.tipo_entidade = 'P'
    and ce.id = cl.custo_entidade_id
union
select /*+ full(cl) full(ce) full(cr) full(fa) full(td) full(a) full(cce) full(cc)
           use_hash(cl) use_hash(ce) use_hash(cr) use_hash(fa) use_hash(td) use_hash(a) use_hash(cce) use_hash(cc) */
        -- Dados tabela CUSTO_LANCAMENTO
        cl.data CUSTO_LANCAMENTO_DATA, cl.id CUSTO_LANCAMENTO_ID,
        cl.situacao CUSTO_LANCAMENTO_SITUACAO, cl.tipo CUSTO_LANCAMENTO_TIPO,
        cl.usuario_id CUSTO_LANCAMENTO_USUARIO_ID,
        -- Detalhar valor por CPV, CRV, RPV, RRV, CPE, CRE, RPE, RRE
        nvl(cce.influencia,100)/100 * decode(cr.tipo, 'C', decode(cl.tipo, 'P', decode(cl.situacao, 'V', cl.valor, 0), 0), 0) CPV,
        nvl(cce.influencia,100)/100 * decode(cr.tipo, 'C', decode(cl.tipo, 'P', decode(cl.situacao, 'E', cl.valor, 0), 0), 0) CPE,
        nvl(cce.influencia,100)/100 * decode(cr.tipo, 'C', decode(cl.tipo, 'R', decode(cl.situacao, 'V', cl.valor, 0), 0), 0) CRV,
        nvl(cce.influencia,100)/100 * decode(cr.tipo, 'C', decode(cl.tipo, 'R', decode(cl.situacao, 'E', cl.valor, 0), 0), 0) CRE,
        nvl(cce.influencia,100)/100 * decode(cr.tipo, 'R', decode(cl.tipo, 'P', decode(cl.situacao, 'V', cl.valor, 0), 0), 0) RPV,
        nvl(cce.influencia,100)/100 * decode(cr.tipo, 'R', decode(cl.tipo, 'P', decode(cl.situacao, 'E', cl.valor, 0), 0), 0) RPE,
        nvl(cce.influencia,100)/100 * decode(cr.tipo, 'R', decode(cl.tipo, 'R', decode(cl.situacao, 'V', cl.valor, 0), 0), 0) RRV,
        nvl(cce.influencia,100)/100 * decode(cr.tipo, 'R', decode(cl.tipo, 'R', decode(cl.situacao, 'E', cl.valor, 0), 0), 0) RRE,
        -- Dados tabela CUSTO_ENTIDADE
        ce.id CUSTO_ENTIDADE_ID, ce.titulo CUSTO_ENTIDADE_TITULO,
        -- Dados tabela CUSTO_RECEITA
        cr.id CUSTO_RECEITA_ID, cr.id_pai CUSTO_RECEITA_ID_PAI,
        cr.tipo CUSTO_RECEITA_TIPO, cr.titulo CUSTO_RECEITA_TITULO,
        cr.vigente CUSTO_RECEITA_VIGENTE,
        -- Dados tabela FORMAAQUISICAO
        fa.id FORMA_AQUISICAO_ID, fa.tipo FORMA_AQUISICAO_TIPO,
        fa.titulo FORMA_AQUISICAO_TITULO, fa.vigente FORMA_AQUISICAO_VIGENTE,
        -- Dados tabela TIPODESPESA
        td.id TIPO_DESPESA_ID, td.tipo TIPO_DESPESA_TIPO,
        td.descricao TIPO_DESPESA_DESCRICAO, td.vigente TIPO_DESPESA_VIGENTE,
        td.conta_contabil TD_CONTA_CONTABIL,
        -- Dados tabela ATIVIDADE
        'A' TIPO_ENTIDADE, a.id ENTIDADE_ID, null TIPO_PROJETO,
        a.tipo TIPO_ATIVIDADE, null TIPO_TAREFA, a.projeto PROJETO_ID,
        -- Dados tabela CENTRO_CUSTO_ENTIDADE
        cce.influencia CC_ENTIDADE_INFLUENCIA,
        -- Dados tabela CENTRO_CUSTO
        cc.id CENTRO_CUSTO_ID, cc.titulo CENTRO_CUSTO_TITULO,
        cc.parent_id CENTRO_CUSTO_PAI, cc.vigente CENTRO_CUSTO_VIGENTE,
        cc.tipo CENTRO_CUSTO_TIPO,
        cl.data_alteracao CUSTO_LANCAMENTO_ALTERACAO,
        cl.valor CUSTO_LANCAMENTO_VALOR,
        cl.valor_unitario CL_VALOR_UNITARIO,
        cl.quantidade CUSTO_LANCAMENTO_QUANTIDADE,
        ce.motivo MOTIVO,
        ce.unidade UNIDADE,
        a.titulo TITULO_ENTIDADE,
         cl.descricao CUSTO_LANCAMENTO_DESCRICAO
   from custo_lancamento cl,
        custo_entidade   ce,
        custo_receita    cr,
        formaaquisicao   fa,
        tipodespesa      td,
        atividade        a,
        centro_custo_entidade cce,
        centro_custo     cc
  where cc.id(+) = cce.centrocustoid
    and fa.id = ce.forma_aquisicao_id
    and td.id = ce.tipo_despesa_id
    and cr.id = ce.custo_receita_id
    and cce.tipoentidade(+) = 'A'
    and cce.identidade(+) = a.id
    and a.id  = ce.entidade_id
    and ce.tipo_entidade = 'A'
    and ce.id = cl.custo_entidade_id
union
select /*+ full(cl) full(ce) full(cr) full(fa) full(td) full(t) full(cce) full(cc)
           use_hash(cl) use_hash(ce) use_hash(cr) use_hash(fa) use_hash(td) use_hash(t) use_hash(cce) use_hash(cc) */
        -- Dados tabela CUSTO_LANCAMENTO
        cl.data CUSTO_LANCAMENTO_DATA, cl.id CUSTO_LANCAMENTO_ID,
        cl.situacao CUSTO_LANCAMENTO_SITUACAO, cl.tipo CUSTO_LANCAMENTO_TIPO,
        cl.usuario_id CUSTO_LANCAMENTO_USUARIO_ID,
        -- Detalhar valor por CPV, CRV, RPV, RRV, CPE, CRE, RPE, RRE
        nvl(cce.influencia,100)/100 * decode(cr.tipo, 'C', decode(cl.tipo, 'P', decode(cl.situacao, 'V', cl.valor, 0), 0), 0) CPV,
        nvl(cce.influencia,100)/100 * decode(cr.tipo, 'C', decode(cl.tipo, 'P', decode(cl.situacao, 'E', cl.valor, 0), 0), 0) CPE,
        nvl(cce.influencia,100)/100 * decode(cr.tipo, 'C', decode(cl.tipo, 'R', decode(cl.situacao, 'V', cl.valor, 0), 0), 0) CRV,
        nvl(cce.influencia,100)/100 * decode(cr.tipo, 'C', decode(cl.tipo, 'R', decode(cl.situacao, 'E', cl.valor, 0), 0), 0) CRE,
        nvl(cce.influencia,100)/100 * decode(cr.tipo, 'R', decode(cl.tipo, 'P', decode(cl.situacao, 'V', cl.valor, 0), 0), 0) RPV,
        nvl(cce.influencia,100)/100 * decode(cr.tipo, 'R', decode(cl.tipo, 'P', decode(cl.situacao, 'E', cl.valor, 0), 0), 0) RPE,
        nvl(cce.influencia,100)/100 * decode(cr.tipo, 'R', decode(cl.tipo, 'R', decode(cl.situacao, 'V', cl.valor, 0), 0), 0) RRV,
        nvl(cce.influencia,100)/100 * decode(cr.tipo, 'R', decode(cl.tipo, 'R', decode(cl.situacao, 'E', cl.valor, 0), 0), 0) RRE,
        -- Dados tabela CUSTO_ENTIDADE
        ce.id CUSTO_ENTIDADE_ID, ce.titulo CUSTO_ENTIDADE_TITULO,
        -- Dados tabela CUSTO_RECEITA
        cr.id CUSTO_RECEITA_ID, cr.id_pai CUSTO_RECEITA_ID_PAI,
        cr.tipo CUSTO_RECEITA_TIPO, cr.titulo CUSTO_RECEITA_TITULO,
        cr.vigente CUSTO_RECEITA_VIGENTE,
        -- Dados tabela FORMAAQUISICAO
        fa.id FORMA_AQUISICAO_ID, fa.tipo FORMA_AQUISICAO_TIPO,
        fa.titulo FORMA_AQUISICAO_TITULO, fa.vigente FORMA_AQUISICAO_VIGENTE,
        -- Dados tabela TIPODESPESA
        td.id TIPO_DESPESA_ID, td.tipo TIPO_DESPESA_TIPO,
        td.descricao TIPO_DESPESA_DESCRICAO, td.vigente TIPO_DESPESA_VIGENTE,
        td.conta_contabil TD_CONTA_CONTABIL,
        -- Dados tabela ATIVIDADE
        'T' TIPO_ENTIDADE, t.id ENTIDADE_ID, null TIPO_PROJETO,
        null TIPO_ATIVIDADE, t.tipo TIPO_TAREFA, t.projeto PROJETO_ID,
        -- Dados tabela CENTRO_CUSTO_ENTIDADE
        cce.influencia CC_ENTIDADE_INFLUENCIA,
        -- Dados tabela CENTRO_CUSTO
        cc.id CENTRO_CUSTO_ID, cc.titulo CENTRO_CUSTO_TITULO,
        cc.parent_id CENTRO_CUSTO_PAI, cc.vigente CENTRO_CUSTO_VIGENTE,
        cc.tipo CENTRO_CUSTO_TIPO,
        cl.data_alteracao CUSTO_LANCAMENTO_ALTERACAO,
        cl.valor CUSTO_LANCAMENTO_VALOR,
        cl.valor_unitario CL_VALOR_UNITARIO,
        cl.quantidade CUSTO_LANCAMENTO_QUANTIDADE,
        ce.motivo MOTIVO,
        ce.unidade UNIDADE,
        t.titulo TITULO_ENTIDADE,
         cl.descricao CUSTO_LANCAMENTO_DESCRICAO
   from custo_lancamento cl,
        custo_entidade   ce,
        custo_receita    cr,
        formaaquisicao   fa,
        tipodespesa      td,
        tarefa           t,
        centro_custo_entidade cce,
        centro_custo     cc
  where cc.id(+) = cce.centrocustoid
    and fa.id = ce.forma_aquisicao_id
    and td.id = ce.tipo_despesa_id
    and cr.id = ce.custo_receita_id
    and cce.tipoentidade(+) = 'T'
    and cce.identidade(+) = t.id
    and t.id  = ce.entidade_id
    and ce.tipo_entidade = 'T'
    and ce.id = cl.custo_entidade_id;
/


CREATE OR REPLACE PACKAGE PCK_DOCUMENTO AS

type lista_campos is table of t_tipo_campos;

function  f_lista_campos  return lista_campos PIPELINED;
function  f_lista_campos_DOF  return lista_campos PIPELINED;

procedure p_Exporta_Arquivo(ln_ano number,ls_tipo varchar2, ls_projetos varchar2, ln_arquivo in out number);
procedure p_Importa_Arquivo(ln_seq number, ls_diretorio varchar2, ln_retorno in out number);
procedure p_Carrega_Arquivo (ls_diretorio varchar2, ls_arquivo varchar2, ln_seq out number, ln_retorno in out number);
procedure p_Carga_Inicial(ln_seq number, ln_retorno in out number);
procedure p_Importa_Custos(ln_seq number, ln_retorno in out number);
procedure p_Acerto_Carga_Inicial(ln_seq number, ln_retorno in out number);
procedure p_Importa_View_Zeus(ls_diretorio varchar2, ln_retorno in out number);
PROCEDURE p_Exporta_Arquivo_CNI(ls_tipo varchar2, ln_arquivo in out number, ln_retorno in out number);

  
END PCK_DOCUMENTO;
/
CREATE OR REPLACE PACKAGE BODY PCK_DOCUMENTO AS

function  f_lista_campos_DOF  return lista_campos PIPELINED
  as
  begin
     pipe row( t_tipo_campos( 1,'Val_Fixo1'   ,'fixo'  ,1 ,0,'' ,'A'                   ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos( 2,'Val_Fixo2'   ,'fixo'  ,1 ,0,'' ,'I'                   ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos( 3,'Cod_Trace'   ,'fixo'  ,5 ,0,'' ,'TRACE'               ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos( 4,'Val_Fixo4'   ,'fixo'  ,1 ,0,'' ,'1'                   ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos( 5,'Entidade'    ,'char'  ,10,0,'' ,'TRACETRACE'           ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos( 6,'Val_Fixo6'   ,'nulo'  ,0,0 ,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos( 7,'Dt_Liberacao','date'  ,10,0,'' ,'DD/MM/YYYY',       'Y',''                    ,'Data de Vencimento'));
     pipe row( t_tipo_campos( 8,'Valor_Ordem' ,'number',17,2,',','00000000000009D00','Y',''                   ,'Valor da Ordem'));
     pipe row( t_tipo_campos( 9,'Val_Fixo9'   ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(10,'Val_Fixo10'  ,'fixo'  ,1 ,0,'' ,'P'                   ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(11,'Val_Fixo11'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(12,'Dt_Geracao'  ,'date'  ,10,0,'' ,'DD/MM/YYYY',       'Y',''                    ,'Data de Vencimento'));
     pipe row( t_tipo_campos(13,'Dt_Provisao' ,'date'  ,10,0,'' ,'DD/MM/YYYY',       'Y',''                    ,'Data de Provisao'));
     pipe row( t_tipo_campos(14,'Dt_Pagamento','date'  ,10,0,'' ,'DD/MM/YYYY',       'Y',''                    ,'Data de Pagamento'));
     pipe row( t_tipo_campos(15,'Val_Fixo15'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(16,'Val_Fixo16'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(17,'Val_Fixo17'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(18,'Val_Fixo18'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(19,'CTA_Fluxo'   ,'char'  ,10,0,'' ,'X'           ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(20,'CTA_Ctb'     ,'char'  ,10,0,'' ,'X'           ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(21,'MOV_CTB'     ,'fixo'  ,5 ,0,'' ,'UU100'               ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(22,'Val_Fixo22'  ,'nulo'  ,0,0 ,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(23,'Texto'       ,'char'  ,200,0,'' ,'X'           ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(24,'UO'          ,'char'  ,10,0,'' ,'X'           ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(25,'CR'          ,'char'  ,16,0,'' ,'X'           ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(26,'Val_Fixo26'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(27,'Val_Fixo27'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(28,'Val_Fixo28'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(29,'Val_Fixo29'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(30,'Val_Fixo30'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(31,'Val_Fixo31'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(32,'Val_Fixo32'  ,'nulo'  ,0,0,'' ,' '                    ,'Y',''                    ,'Valor_Fixo'));
     pipe row( t_tipo_campos(33,'Dt_Registro' ,'date'  ,10,0,'' ,'DD/MM/YYYY',       'Y',''                    ,'Data de Vencimento'));

  end;

function  f_lista_campos  return lista_campos PIPELINED
  as
  begin
         pipe row( t_tipo_campos( 1,'Codigo'   ,'char'  ,4 ,0,'' ,'X'                    ,'Y',''                    ,'Código do Sistema que gerou a informação Orçamento (ORC)') );
         pipe row( t_tipo_campos( 2,'tipo'     ,'number',2 ,0,'' ,'99'                   ,'Y','[2],[3],[4],[5],[6]' ,'Tipo de movimento. Este código é criado no sistema do orçamento e determina a informação, que estará trafegando o movimento. (2  Orçado,3  Realizado,4  Transposto,5  Suplementado,6  Retificado)'));
         pipe row( t_tipo_campos( 3,'ano'      ,'number',4 ,0,'' ,'9999'                 ,'Y',''                    ,'Ano do Orçamento'));
         pipe row( t_tipo_campos( 4,'mes'      ,'date'  ,2 ,0,'' ,'MM'                   ,'Y',''                    ,'Mês do Orçamento'));
         pipe row( t_tipo_campos( 5,'cod_empre','number',3 ,0,'' ,'999'                  ,'Y',''                    ,'Código da Empresa do Movimento'));
         pipe row( t_tipo_campos( 6,'Cod_UO'   ,'char'  ,10,0,'' ,'X '                   ,'Y',''                    ,'Código da Unidade Organizacional'));
         pipe row( t_tipo_campos( 7,'Cod_CR'   ,'char'  ,16,0,'' ,'X '                   ,'Y',''                    ,'Código do Centro de Responsabilidade'));
         pipe row( t_tipo_campos( 8,'Cod_CO'   ,'char'  ,16,0,'' ,'X '                   ,'Y',''                    ,'Código do Conta Orçamentária'));
         pipe row( t_tipo_campos( 9,'Qtde_Mov' ,'number',17,4,',','000000000009D0000'    ,'Y',''                    ,'Quantidade do Movimento'));
         pipe row( t_tipo_campos(10,'Val_Mov'  ,'number',17,2,',','00000000000009D00'    ,'Y',''                    ,'Valor do Movimento'));
         pipe row( t_tipo_campos(11,'Val_Fixo' ,'fixo'  ,1 ,0,'' ,'0'                    ,'Y',''                    ,'Valor_Fixo'));
         pipe row( t_tipo_campos(12,'Nome_Arq' ,'char'  ,4 ,0,'' ,'X '                   ,'Y',''                    ,'Nome do arquivo do movimento orçamentário'));
         pipe row( t_tipo_campos(13,'Ano_PC'   ,'date'  ,4 ,0,'' ,'YYYY'                 ,'Y',''                    ,'Ano do Plano de Contas'));
         pipe row( t_tipo_campos(14,'Cod_CC'   ,'char'  ,16,0,'' ,'X '                   ,'Y',''                    ,'Código do Conta Contábil'));
         pipe row( t_tipo_campos(15,'Cod_Mov'  ,'char'  ,1 ,0,'' ,'X'                    ,'Y','[A],[M]'             ,'Determina a forma da entrada do movimento do orçamento. Todos os movimentos atuais são automáticos M  Manual A - Automático'));
         pipe row( t_tipo_campos(16,'Dt_Mov'   ,'date'  ,19,0,'' ,'DD/MM/YYYY HH24:MI:SS','Y',''                    ,'Data de Atualização do Movimento'));

  end;

PROCEDURE p_Exporta_Arquivo(ln_ano number,
                            ls_tipo varchar2, 
                            ls_projetos varchar2, 
                            ln_arquivo in out number) AS

 ls_campo              VARCHAR2(2000);
 ln_campo              number;
 ld_campo              date;
 ls_seperador_campo    varchar2(5);
 ls_seperador_registro varchar2(5);
 ln_qtde_campos        integer;
 l_colcnt              integer;
 reg                   lista_campos;
 ln_doc                int;
 ln_doc_cont           int;
 blob_edit             BLOB; 
 ls_linha              varchar2(32767);
 b_int                 binary_integer;
 c                     INTEGER;
 fdbk                  integer;
 ln_tamanho            number;
 primeiro_registro     boolean:=true;
 ls_query              varchar2(32000);
begin

/*
--Para Testes:

ls_query:='
select ''ORC'',
        1, -- Orçado
        cl.data,
        cl.data,
        level, --number Empresa 
        ''A'', --UO
        ''CR'', --C responsa
        ''11'', --Cta Orçamentaria
        nvl(cl.quantidade,0),
        cl.valor,
        ''0'', --fixo
        ''Teste.txt'',
        sysdate,
        nvl(td.conta_contabil,''0''),
        ''M'',
        sysdate
from custo_entidade ce, custo_lancamento cl, tipodespesa td
where cl.custo_entidade_id = ce.id and
      td.id = ce.tipo_despesa_id CONNECT BY level <= 100 ';
      
      Substituída essa linha do ano
      '|| to_char(ln_ano) ||' Ano, --ln_ano
*/

 ls_query:='
 select ''ORC'',
        case ''' || ls_tipo || '''
          when ''Planejamento'' then 2 
          when ''Realizado'' then 3
          when ''Transposição'' then 4
          when ''Suplementação'' then 5
          when ''Retificação'' then 6 END Tipo,
        to_number(to_char(cl.data,''yyyy'')) Ano,  
        cl.data Mes,
        case substr(u.titulo,5,2) 
          when ''01'' then 100 
          when ''02'' then 200
          when ''03'' then 300
          when ''04'' then 400
          when ''05'' then 500 
          else 0 end Empresa ,
        substr(u.titulo,5,instr(u.titulo,''-'')-6) UO,
        nvl((select substr(cia.Titulo,6,instr(cia.Titulo,''-'')-6) 
                from atributoentidadevalor aev, categoria_item_atributo cia
                   where aev.identidade = b.projeto_id and 
                         aev.tipoentidade=''P'' and 
                         aev.atributoid=2 and
                         cia.atributo_id=2 and
                         aev.categoria_item_atributo_id = cia.categoria_item_id
                         ),''0000000000'') ||
        nvl((select 
                lpad(trim(to_char(trunc(aev.ValorNumerico))),  trunc((length(trim(to_char(trunc(aev.ValorNumerico))))+1)/2)*2   ,''0'')        
                from atributoentidadevalor aev 
                   where aev.identidade = b.projeto_id and 
                         aev.tipoentidade=''P'' and 
                         aev.atributoid=1),''000000'') CentroResponsabilidadeSEQ, 
        substr(cr.titulo,6,instr(cr.titulo,''-'')-7) Cta_Orc, 
        nvl(cl.quantidade,0) Qtde,
        cl.valor Valor,
        ''0'' Fixo, 
        ''' || ls_tipo || '-'||to_char(ln_ano)||'.TXT'' Arquivo,
        sysdate Ano_Plano_Contas,
        ''0'' Cta_contabil,
        ''A'' Automatico,
        sysdate Dt_Atualizacao
     from baseline b, 
          baseline_custo_entidade ce, 
          baseline_custo_lancamento cl, 
          custo_receita cr,
          projeto p, 
          uo u
     where b.titulo =  '''|| ls_tipo|| '-' || to_char(ln_ano) || ''' and
           b.projeto_id in ('|| replace(ls_projetos,'-',',')||')   and
           b.baseline_id = ce.baseline_id and
           b.baseline_id = cl.baseline_id and
           ce.id = cl.baseline_custo_entidade_id and
           ce.custo_receita_id = cr.id  and
           b.projeto_id = p.id and
           cl.situacao = ''V'' and
           p.uo_id = u.id and
           cl.tipo =''P'' and 
           to_number(to_char(cl.data,''yyyy'')) = ' || ln_ano;


  DBMS_LOB.CREATETEMPORARY(blob_edit,TRUE);
   
  ls_seperador_campo:=chr(9);
  ls_seperador_registro:=chr(13)||chr(10);
  c := DBMS_SQL.OPEN_CURSOR;

  DBMS_SQL.PARSE (c, ls_query, DBMS_SQL.NATIVE);

  select count(*) into ln_qtde_campos  from table(f_lista_campos);

  FOR i IN 1 .. ln_qtde_campos
    LOOP

     select t_tipo_campos(sec,nome,tipo,tamanho,decimais,separador,formato,obrigatorio,opcoes,descricao)
     BULK COLLECT INTO reg     from table(f_lista_campos) where sec=i;

      BEGIN
        if reg(1).tipo='char' or reg(1).tipo='fixo' then
           DBMS_SQL.define_column(c, i, ls_campo, 2000);
        end if;
        if reg(1).tipo='number' then
           DBMS_SQL.define_column(c, i, ln_campo);
        end if;
        if reg(1).tipo='date' then
           DBMS_SQL.define_column(c, i, ld_campo);
        end if;        

        l_colcnt := i;
      EXCEPTION
        WHEN OTHERS THEN
          IF (SQLCODE = -1007)
          THEN
            EXIT;
          ELSE
            RAISE;
          END IF;
      END;
    END LOOP; 
   DBMS_SQL.define_column(c, 1, ls_campo, 2000);
   fdbk:= DBMS_SQL.EXECUTE (c); 

 LOOP
  EXIT WHEN(DBMS_SQL.fetch_rows(c) <= 0); 

  ls_linha:='';


  FOR i IN 1 .. ln_qtde_campos
      LOOP
     select t_tipo_campos(sec,nome,tipo,tamanho,decimais,separador,formato,obrigatorio,opcoes,descricao)
     BULK COLLECT INTO reg     from table(f_lista_campos) where sec=i;

     if reg(1).tipo='char' then
        DBMS_SQL.COLUMN_VALUE(c, i, ls_campo);
        if reg(1).formato='X' THEN
           ls_linha := ls_linha || substr(ls_campo,1,reg(1).tamanho);
        end if;
        if reg(1).formato='X ' THEN
           ls_linha := ls_linha || rpad(substr(ls_campo,1,reg(1).tamanho),reg(1).tamanho,' ');
        end if;
        if reg(1).formato=' X' THEN
           ls_linha := ls_linha || lpad(substr(ls_campo,1,reg(1).tamanho),reg(1).tamanho,' ');
        end if;
        end if;
     if reg(1).tipo='fixo' then
        ls_linha := ls_linha || reg(1).formato;
     end if;
     if reg(1).tipo='date' then
        DBMS_SQL.COLUMN_VALUE(c, i, ld_campo);
        ls_linha := ls_linha || to_char(ld_campo,reg(1).formato);
     end if;
     if reg(1).tipo='number' then
        DBMS_SQL.COLUMN_VALUE(c, i, ln_campo);
        ls_linha := ls_linha || to_char(ln_campo,reg(1).formato);
     end if;

     if i <> ln_qtde_campos then
        ls_linha :=ls_linha || ls_seperador_campo;
     else
        ls_linha :=ls_linha || ls_seperador_registro;
     end if;
        
      END LOOP;    

    b_int:=utl_raw.length (utl_raw.cast_to_raw(ls_linha));
    
    if (primeiro_registro) then
      dbms_lob.write(blob_edit, b_int, 1, utl_raw.cast_to_raw(ls_linha));
      primeiro_registro:=false;
    else
      dbms_lob.writeappend(blob_edit, b_int , utl_raw.cast_to_raw(ls_linha));
    end if;

 END LOOP;

 select documento_seq.nextval into ln_doc from dual;
 select documento_conteudo_seq.nextval into ln_doc_cont from dual;

 Insert into DOCUMENTO (DOCUMENTOID,DESCRICAO, TIPOENTIDADE,IDENTIDADE,
                        AREAGERENCIA,ESTADODOCUMENTO,VERSAOATUAL,TIPODOCUMENTO,
                        RESPONSAVEL,DOCUMENTO_PAI,TIPO_DOCUMENTO_ID,TAMANHO) 
 select ln_doc,trim(ls_tipo)||'-'||to_char(ln_ano)||' Exportado em '||to_char(sysdate,'DD-MM-YYYY HH24-MI-SS'),null,null,
        null,'I',1,'.txt',
        null,null,null,null 
     from dual;

 insert into documento_conteudo (id, documento_id, versao, conteudo)
 values (ln_doc_cont, ln_doc, 1, empty_blob());-- returning conteudo into blob_edit;

 update documento_conteudo
 set conteudo = blob_edit
 where id=ln_doc_cont;

 dbms_lob.FREETEMPORARY(blob_edit);

 DBMS_SQL.CLOSE_CURSOR (c);

 ln_arquivo:=ln_doc;

end p_Exporta_Arquivo;

procedure p_Importa_Arquivo(ln_seq       number, 
                            ls_diretorio varchar2,
                            ln_retorno in out number)
is
 ls_campo              VARCHAR2(1000);
 ln_campo              number;
 ld_campo              date;
 ls_seperador_campo    varchar2(5);
 ls_seperador_registro varchar2(5);
 ln_qtde_campos        integer;
 l_colcnt              integer;
 reg                   lista_campos;
 ln_doc                int;
 ln_doc_cont           int;
 blob_edit             BLOB; 
 ls_linha              varchar2(32767);
 b_int                 binary_integer;
 c                     INTEGER;
 fdbk                  integer;
 ln_tamanho            number;
 primeiro_registro     boolean:=true;
 ls_query              varchar2(2000);
 vtemp                 RAW(32000);
 vend                  NUMBER := 1;
 vlen                  NUMBER := 1;
 vstart                NUMBER := 1;
 vend2                 NUMBER := 1;
 vlen2                 NUMBER := 1;
 vstart2               NUMBER := 1;
 i                     number;
 ln_proj               number:=0;
 bytelen               NUMBER := 32000;
 ultimo_campo          boolean;
 registros             number:=0;     
 ln_ce                 number:=0;
 ln_cl                 number:=0;
 TYPE t_dados IS VARRAY(100) OF varchar2(1000);
 dados t_dados:=t_dados();
 lb_erro boolean:=false;
 ln_categ number;
 ln_uo number;
 -- Modificado <Charles> Ini
 lf_rejeitados SYS.UTL_FILE.file_type;
 lf_log        SYS.UTL_FILE.file_type;
 ln_forma      number := 0;
 ln_tipo       number := 0;
 ln_cr         number := 0;
 ld_lancamento date;
 lv_mensagem   varchar2(4000);
 ld_data_hora  date;
 -- Modificado <Charles> Fim
begin
  
   -- Modificado <Charles> - Ini  
   if ls_diretorio is not null then
     select sysdate into ld_data_hora from dual;
     lf_rejeitados := SYS.UTL_FILE.fopen (ls_diretorio, 'registros_rejeitados_' || 
                                      to_char(ld_data_hora, 'yyyymmddhh24miss') || '.txt', 'w');
     lf_log        := SYS.UTL_FILE.fopen (ls_diretorio, 'resultado_processamento_' || 
                                      to_char(ld_data_hora, 'yyyymmddhh24miss') || '.txt', 'w');
   end if;
   -- Modificado <Charles> - Fim 
   
   ls_seperador_campo:=chr(9);
   ls_seperador_registro:=chr(13)||chr(10);  /* UNIX 10, DOS 13+10 */
  
   select conteudo into blob_edit
   from documento_conteudo
   where documento_id=ln_seq;

   vlen:=dbms_lob.getlength(blob_edit);
   bytelen := 32000;
   vstart := 1;
   
   vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);
   
   if vend=0 then
      dbms_output.put_line('O arquivo não possui um FIM DE LINHA do padrão DOS/WINDOS (char 13 + char 10). Provavelmente é um arquivo no formato UNIX.');
      dbms_output.put_line('O arquivo deve ser convertido.');
   end if;
   
  
   WHILE vstart < vlen 
   LOOP
         vlen2:=vend-vstart+1;

         dbms_lob.read(blob_edit,vlen2,vstart,vtemp);
         ls_linha:=utl_raw.cast_to_varchar2(vtemp);
         registros:=registros+1;
         vend2 := 1;
         vstart2 := 1;
         vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);
         i:=1;     
         ultimo_campo:=false;
         WHILE vstart2 < vlen2 or ultimo_campo
         LOOP
               select t_tipo_campos(sec,nome,tipo,tamanho,decimais,separador,formato,obrigatorio,opcoes,descricao)
               BULK COLLECT INTO reg     from table(f_lista_campos) where sec=i;
               ls_campo:=substr(ls_linha, vstart2, vend2-vstart2);
               dados.extend;
               dados(i):=ls_campo;
               vstart2:=vend2+length(ls_seperador_campo);
               if not ultimo_campo then
                  vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);
               else
                  ultimo_campo:=false;
               end if;
               if vend2 =0 then
                  ultimo_campo:=true;
                  vend2:=vlen2;
               end if;
               i:=i+1;
         END LOOP;

   --------------------------------------
   -- Início do Processamento da Linha --
   --------------------------------------
   -- dbms_output.put_line(dados(1)||dados(2)||dados(3));
   -- Dados prontos para serem trabalhados
   lb_erro:=false;
         if dados(2)='3' then -- Realizado
           
            -- Para identificar o projeto, identificar por 3 valores
            -- 1. Projeto deve ser da UO 
            -- 2. Atributo 2 deve ter 'YYYY XXXXXX' onde YYYY é o ano do orçamento e XXXXXX são os 6 primeiras posicoes do Centro de Resposabilidade 
            -- 3. Atributo 1 deve ter o sequencial posicao a partir da 7 do Centro de Responsabilidade
            dados(3):=trim(dados(3));
            dados(4):=trim(dados(4));
            dados(6):=trim(dados(6));
            dados(7):=trim(dados(7));
            dados(16):=trim(dados(16));
            dados(8):=dados(3)|| ' '|| trim(dados(8));

            if instr(dados(16),' ')>0 then
               dados(16):=substr(dados(16),1,instr(dados(16),' '));
            end if;
            if to_number(dados(9))=0 then
              dados(9):='1';
            end if;

            begin
             select ci.categoria_item_id into ln_categ
                    from categoria_item_atributo ci
                    where ci.titulo like dados(3)|| ' ' || substr(dados(7),1,9) ||'-%' and
                          ci.atributo_id=2;

              exception when no_data_found then
                ln_categ:=0;
                  lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Atributo Centro Responsabilidade não localizado: '||chr(9)||dados(3)||' '|| substr(dados(7),1,9);
                  dbms_output.put_line(lv_mensagem);
                  SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  lb_erro:=true;
                when others then
                ln_categ:=0;
                  lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Atributo Centro Responsabilidade localizou mais de 1 CR: '||chr(9)||dados(3)|| ' ' || substr(dados(7),1,9);
                  dbms_output.put_line(lv_mensagem);
                  SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  lb_erro:=true;
             end; 


            begin
             select u.id into ln_uo from uo u where to_number(substr(u.titulo,5,instr(u.titulo,'-')-6)) = to_number(dados(6));

              exception when no_data_found then
                ln_uo:=0;
                  lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' UO não localizado: '||chr(9)||dados(3)|| ' ' || dados(6);
                  dbms_output.put_line(lv_mensagem);
                  SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  lb_erro:=true;
                when others then
                ln_uo:=0;
                  lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Localizou mais de 1 UO: '||chr(9)||dados(3)|| ' ' || dados(6);
                  dbms_output.put_line(lv_mensagem);
                  SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  lb_erro:=true;
             end; 

            begin
--dbms_output.put_line(dados(7)||'-'||ln_categ||'-'||ln_uo);
            select id into ln_proj from projeto p
            where p.uo_id = ln_uo  and
                  exists (select *
                from atributoentidadevalor aev--, categoria_item_atributo cia
                   where aev.identidade = p.id and 
                         aev.tipoentidade='P' and 
                         aev.atributoid=2 and
                         aev.categoria_item_atributo_id = ln_categ
                         --cia.atributo_id=2 and
                         --substr(cia.Titulo,6,instr(cia.Titulo,'-')-6) = dados(3)|| ' ' || substr(dados(7),1,9) and
                         --aev.categoria_item_atributo_id = cia.categoria_item_id
                         ) and
                   exists (select *
                from atributoentidadevalor aev 
                   where aev.identidade = p.id and 
                         aev.tipoentidade='P' and 
                         nvl(aev.Valor, aev.ValorNumerico)= to_number(substr(dados(7),10)) and
                         aev.atributoid=1);
            exception when no_data_found then
                lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Não foi localizado Projeto com Atributo Centro Responsabilidade: '||chr(9)||dados(3)|| ' ' || substr(dados(7),1,9) ||chr(9)|| ' Atributo_SEQ:'||chr(9)|| substr(dados(7),10)||chr(9) || ' UO: '||chr(9)||dados(6)||chr(9)|| ' COD_CR:'||chr(9)||ln_categ || chr(9)||' COD_UO:'||chr(9)||ln_uo;
                dbms_output.put_line(lv_mensagem);
                SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                lb_erro:=true;
              when others then
                lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Existe mais de um Projeto com Atributo Centro Responsabilidade: '||chr(9)||dados(3)|| ' ' || substr(dados(7),1,9) ||chr(9)|| ' Atributo_SEQ:'||chr(9)|| substr(dados(7),10)||chr(9) || ' UO: '||chr(9)||dados(6)||chr(9)|| ' COD_CR:'||chr(9)||ln_categ ||chr(9)|| ' COD_UO:'||chr(9)||ln_uo;
                dbms_output.put_line(lv_mensagem);
                SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                lb_erro:=true;
           end; 
              
           if (not lb_erro) then

            select nvl(min(ce.id),0) into ln_ce from custo_entidade ce, custo_receita cr
            where ce.tipo_entidade = 'P' and
                  ce.custo_receita_id = cr.id and
                  ce.entidade_id = ln_proj and
                  cr.titulo like dados(8)||'%'; -- conta contabil
            
            -- Modificado <Charles> Ini
            if ln_ce = 0 then   
                        
              select max(id)
                into ln_cr
                from custo_receita
               where titulo like dados(8)||' %'; -- conta contabil 
               
              if ln_cr > 0 then  
           
                select min(forma_id)
                  into ln_forma
                  from (select *
                          from custo_receita_forma 
                         where custo_receita_id = ln_cr
                         order by decode(vigente, 'Y', 1, 2), decode (valor_default,'Y', 1, 2))
                 where rownum = 1;
                 
                select min(tipo_id)
                  into ln_tipo
                  from (select *
                          from custo_receita_tipo
                         where custo_receita_id = ln_cr
                         order by decode(vigente, 'Y', 1, 2), decode (valor_default,'Y', 1, 2))
                 where rownum = 1; 
               
                select custo_entidade_seq.nextval into ln_ce from dual;
                
                insert into custo_entidade (id, tipo_entidade, entidade_id, custo_receita_id, titulo, 
                                            tipo_despesa_id, forma_aquisicao_id)
                       values (ln_ce, 'P', ln_proj, ln_cr, dados(8), ln_tipo, ln_forma);
              end if;
            end if;
            -- Modificado <Charles> Fim
            
            if ln_ce > 0 then
                                          
                  -- Modificado <Charles> Ini
                  ld_lancamento := to_date(dados(16),'DD/MM/YYYY');
                  begin
                    ld_lancamento := to_date('01'||trim(to_char(to_number(dados(4)),'00'))||dados(3), 'ddmmyyyy');
                    -- Coloca no último dia do mês
                    ld_lancamento := add_months(ld_lancamento, 1) - 1;
                  exception
                    when others then
                      ld_lancamento := null;
                  end;
                  --dbms_output.put_line('DEBUG: ' || to_char(ld_lancamento, 'dd/mm/yyyy'));
                  -- Modificado <Charles> Fim
                  
                  select nvl(max(id),0) into ln_cl from custo_lancamento 
                  where custo_entidade_id = ln_ce and
                        tipo = 'R' and
                        situacao = 'V' and
                        trunc(data) = trunc(ld_lancamento);

                  if ln_cl=0 then
                      begin
                        select custo_lancamento_seq.nextval into ln_cl from dual;
                        insert into custo_lancamento (ID, CUSTO_ENTIDADE_ID, TIPO, SITUACAO,
                                                      DATA, 
                                                      VALOR,
                                                      QUANTIDADE, 
                                                      VALOR_UNITARIO, 
                                                      USUARIO_ID, DATA_ALTERACAO)
                            values (ln_cl, ln_ce, 'R', 'V',
                                    ld_lancamento,
                                    to_number(dados(10)), -- valor
                                    to_number(dados(9)), -- quantidade
                                    to_number(dados(10))/to_number(dados(9)), -- valor unitario,
                                    '310', 
                                    sysdate);  -- 
                       lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' OK - Registro Inserido - Conta:'||dados(8);
                       dbms_output.put_line(lv_mensagem);
                       SYS.UTL_FILE.put_line(lf_log, lv_mensagem); 
                     exception
                       when others then
                         lv_mensagem := 'Linha:'||chr(9)||' Erro ao incluir: [' || sqlerrm || ']';
                         dbms_output.put_line(lv_mensagem);
                         SYS.UTL_FILE.put_line(lf_log, lv_mensagem); 
                     end;           
                  else
                  -- dbms_output.put_line('Já existe Custo Lançamento para Lançamento para Conta:'||dados(14)||' Projeto:'|| '???' ||' Data:'||substr(dados(16),1,10)|| ' Linha não importada:'||registros);
                  -- se ja existe, acrescenta
                  begin
                    update custo_lancamento
                       set VALOR=VALOR+to_number(dados(10)),
                           QUANTIDADE=QUANTIDADE+to_number(dados(9)), 
                           VALOR_UNITARIO=(VALOR+to_number(dados(10)))/(QUANTIDADE+to_number(dados(9))), 
                           USUARIO_ID='310',
                           DATA_ALTERACAO=sysdate
                    where custo_entidade_id = ln_ce and
                          tipo = 'R' and
                          situacao = 'V' and
                          trunc(data) = trunc(ld_lancamento);

                       lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' OK - Registro Atualizado - Conta:'||dados(8);
                       dbms_output.put_line(lv_mensagem);
                       SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  exception
                    when others then
                      lv_mensagem := 'Linha:'||chr(9)||' Erro ao atualizar: [' || sqlerrm || ']';
                      dbms_output.put_line(lv_mensagem);
                      SYS.UTL_FILE.put_line(lf_log, lv_mensagem); 
                  end;
                  end if;
            else
               -- Modificado <Charles>
               lb_erro:=true;
               
               lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||'Não foi localizado Custo Entidade para Conta:'||chr(9)||dados(8)||chr(9)||' Projeto:'||chr(9)||ln_proj;
               dbms_output.put_line(lv_mensagem);
               SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
            end if;
            end if;
         end if;
   
   -- Modificado <Charles> - Ini
   -- Grava registro nao processado no arquivo de output
   if lb_erro then
     SYS.UTL_FILE.put_line(lf_rejeitados, ls_linha);
   end if;
   -- Modificado <Charles> - Fim
   
   --------------------------------------
   -- FIM do Processamento da Linha --
   --------------------------------------
   vstart:=vend+length(ls_seperador_registro);
   vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);

   -- tratamento para linha sem fim de linha
     if vend>vlen or vend=0 then
        vend:=vlen;
     end if;
     
     
   dados:=t_dados();
   END LOOP;
   
 -- Modificado <Charles>
 lv_mensagem := 'Linha: '|| registros;
 dbms_output.put_line(lv_mensagem);
 SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
 
 SYS.UTL_FILE.fclose(lf_rejeitados);
 SYS.UTL_FILE.fclose(lf_log);
 ln_retorno:=registros;

end p_Importa_Arquivo;

procedure p_Carrega_Arquivo (ls_diretorio varchar2, ls_arquivo varchar2, ln_seq out number, ln_retorno in out number)
AS
 
     v_bfile bfile;
     v_blob blob;
     ln_doc int;
     ln_doc_cont int;
     
    begin

      v_bfile := bfilename(ls_diretorio,ls_arquivo);
      dbms_lob.fileopen(v_bfile, dbms_lob.file_readonly);

select documento_seq.nextval into ln_doc from dual;
select documento_conteudo_seq.nextval into ln_doc_cont from dual;

Insert into DOCUMENTO (DOCUMENTOID,DESCRICAO,
      TIPOENTIDADE,IDENTIDADE,AREAGERENCIA,ESTADODOCUMENTO,VERSAOATUAL,TIPODOCUMENTO,RESPONSAVEL,DOCUMENTO_PAI,TIPO_DOCUMENTO_ID,TAMANHO) 
select ln_doc,ls_diretorio||'-'||ls_arquivo||'- Carregado em '||to_char(sysdate,'DD-MM-YYYY HH24-MI-SS'),
       null,null,null,'I',1,'.txt',null,null,null,null from dual;

insert into documento_conteudo (id, documento_id, versao, conteudo)
values (ln_doc_cont, ln_doc, 1, empty_blob());-- returning conteudo into blob_edit;

DBMS_LOB.CREATETEMPORARY(v_blob,TRUE);

/*      insert into tab_imagem (id,nome,imagem)
      values (1,p_nome_arquivo,empty_blob())
      return imagem into v_blob;*/
      
      dbms_lob.loadfromfile(v_blob,v_bfile,dbms_lob.getlength(v_bfile));
      dbms_lob.fileclose(v_bfile);

update documento_conteudo
set conteudo = v_blob
where id=ln_doc_cont;

      
  commit;
  ln_retorno:=1;
  ln_seq:=ln_doc;
  
 EXCEPTION
  WHEN UTL_FILE.access_denied THEN
   ln_retorno:=-1;
   dbms_output.put_line('Problema de acesso ao arquivo. Abortado');
   return;

  WHEN UTL_FILE.invalid_path THEN
   ln_retorno:=-1;
   dbms_output.put_line('Diretório Inválido. Abortado');
   return;

  WHEN NO_DATA_FOUND THEN
   ln_retorno:=-1;
   dbms_output.put_line('No Data Found. Abortado');
   return;

  WHEN UTL_FILE.READ_ERROR THEN
   ln_retorno:=-1;
   dbms_output.put_line('Falha na Leitura. Abortado');
   return;

  WHEN UTL_FILE.invalid_filename THEN
   ln_retorno:=-1;
   dbms_output.put_line('Nome de Arquivo inválido. Abortado');
   return;

  WHEN UTL_FILE.invalid_filehandle THEN
   ln_retorno:=-1;
   dbms_output.put_line('Nome de Arquivo inválido. Abortado');
   return;

  WHEN others THEN
   ln_retorno:=-1;
   dbms_output.put_line('Erro inesperado. Abortado');
   return;

end p_Carrega_Arquivo;

procedure p_Carga_Inicial_Script(ln_seq number, ln_retorno in out number)
-----------------------------------------
-- ESTA PROC NÂO ESTA SENDO UTILIZADA  --
-----------------------------------------

is
ls_campo VARCHAR2(32000);
 ln_campo number;
 ld_campo date;
 ls_seperador_campo varchar2(5);
 ls_seperador_registro varchar2(5);
 ln_qtde_campos integer;
 l_colcnt integer;
 reg lista_campos;
 ln_doc int;
 ln_doc_cont int;
 blob_edit   BLOB; 
 ls_linha varchar2(32767);
 b_int binary_integer;
 c INTEGER;
 fdbk integer;
 ln_tamanho number;
 primeiro_registro boolean:=true;
 ls_query varchar2(2000);
 vtemp RAW(32000);
vend NUMBER := 1;
vlen NUMBER := 1;
vstart NUMBER := 1;

vend2 NUMBER := 1;
vlen2 NUMBER := 1;
vstart2 NUMBER := 1;
i number;
bytelen NUMBER := 32000;
ultimo_campo boolean;
registros number:=0;     
diretorio varchar2(250) :='IMPORTACAO_TRACEGP';
arquivo varchar2(250) :='SCRIPT_GERADO_CARGA_INICIAL.sql' ;

blob_edit1             BLOB; 
blob_edit2             BLOB; 
blob_edit3             BLOB; 
blob_edit4             BLOB; 
blob_edit5             BLOB; 
blob_edit6             BLOB; 

TYPE t_dados IS VARRAY(100) OF varchar2(32000);
dados t_dados:=t_dados();

type    Array1D is table of Number;
type    Array2D is table of Array1D;
array   Array2D;
vFILE_SAIDA    SYS.UTL_FILE.FILE_TYPE;

begin
vFILE_SAIDA  := SYS.UTL_FILE.FOPEN( diretorio, arquivo, 'w',32767 );

ls_seperador_campo:=chr(9);  -- TAB
ls_seperador_campo:=chr(35); -- #
ls_seperador_registro:=chr(13)||chr(10);
  
select conteudo into blob_edit
from documento_conteudo
where documento_id=ln_seq;

vlen:=dbms_lob.getlength(blob_edit);
bytelen := 32000;
vstart := 1;
vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);


--vlen:=100;
WHILE vstart < vlen 
LOOP
--dbms_output.put_line('newline:'||vstart);
--dbms_output.put_line('newline:'||vend);
vlen2:=vend-vstart+1;
   dbms_lob.read(blob_edit,vlen2,vstart,vtemp);
   ls_linha:=utl_raw.cast_to_varchar2(vtemp);
    registros:=registros+1;
    
vend2 := 1;
--vlen2 := length(ls_linha);
--dbms_output.put_line('Linha text:'||ls_linha);
vstart2 := 1;
vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);

i:=1;     
ultimo_campo:=false;
WHILE vstart2 < vlen2 or ultimo_campo
LOOP
--dbms_output.put_line('len2:'||vlen2);
--dbms_output.put_line('start2:'||vstart2);
--dbms_output.put_line('vend2:'||vend2);

     select t_tipo_campos(sec,nome,tipo,tamanho,decimais,separador,formato,obrigatorio,opcoes,descricao)
     BULK COLLECT INTO reg     from table(f_lista_campos) where sec=i;

   ls_campo:=substr(ls_linha, vstart2, vend2-vstart2);
--   dbms_output.put_line('Campo:'||reg(1).sec||':'||reg(1).nome||' Tipo:'||reg(1).tipo||' Valor:'||ls_campo);
   dados.extend;
   dados(i):=replace(ls_campo,'''','''''');
   vstart2:=vend2+length(ls_seperador_campo);
  if not ultimo_campo then
     vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);
  else
     ultimo_campo:=false;
  end if;


  if vend2 =0 then
    ultimo_campo:=true;
    vend2:=vlen2;
  end if;
i:=i+1;
END LOOP;
array := new Array2D(
                                  Array1D(5,43),
                                  Array1D(6,16),
                                  Array1D(7,17),
                                  Array1D(9,15),
                                  Array1D(15,70),
                                  Array1D(18,71),
                                  Array1D(19,72),
                                  Array1D(20,73),
                                  Array1D(21,74),
                                  Array1D(22,75),
                                  Array1D(23,76)
                                  
                     );   

   DBMS_LOB.CREATETEMPORARY(blob_edit1,TRUE);
   DBMS_LOB.CREATETEMPORARY(blob_edit2,TRUE);
   DBMS_LOB.CREATETEMPORARY(blob_edit3,TRUE);
   DBMS_LOB.CREATETEMPORARY(blob_edit4,TRUE);
   DBMS_LOB.CREATETEMPORARY(blob_edit5,TRUE);
   DBMS_LOB.CREATETEMPORARY(blob_edit6,TRUE);

   --------------------------------------
   -- Inicio do Processamento da Linha --
   --------------------------------------
--if registros < 1000 then

   if dados(1)='10' then -- PROJETOS
     if registros=1 then
          SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'declare');
          SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   ln_id_proj number;');              
          SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   ln_id_atr  number;');              
          SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'begin');
    end if;
--     dbms_output.put_line(dados(21));
     SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,' ');
     SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   SELECT projeto_seq.nextval INTO ln_id_proj FROM dual;');
     SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   INSERT INTO PROJETO (ID,TITULO,DESCRICAO,HORASPREVISTAS,HORASREALIZADAS,PRAZOPREVISTO,PRAZOREALIZADO,SITUACAO,SISTEMA,ORDEM,DATAINICIO,DATAFIMORCAMENTO,PORCENTAGEMCONCLUIDA,PERMITETEMPLATE,TIPOPROJETOID,INICIOREALIZADO,DURACAO,TIPORESTRICAO,DATARESTRICAO,ATUALIZARHORASPREVISTAS,CPI_MONETARIO,SPI_MONETARIO,ENTIDADE_PAI,CONSIDERAR_CUSTO,ALTERAR_PERC_CONCLUIDO,PERMITE_CUSTO_APENAS_TAREFA,EDICAO_EXCLUSIVA,MODIFICADOR,MOTIVO,DASHBOARD_ID,UO_ID,PROJETO_TEMPLATE_ID)');
     SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'      SELECT ln_id_proj,'''|| dados(2)|| ' - ' || dados(3)|| ''',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,''A'',''N'',''Y'',null,''310'',null,null,null,null FROM dual;');

     SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   INSERT INTO RESPONSAVELENTIDADE (TIPOENTIDADE, RESPONSAVEL, IDENTIDADE)');
     SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'      select ''P'', nvl((select u.usuarioid from usuario u where upper(nome) = upper('''|| dados(4)|| ''')),''310''), ln_id_proj from dual;');

         for x in 1..array.Count
         loop
             if array(x)(2) in(73) then  -- DATA
                 if (nvl(trim(dados(array(x)(1))),'-1') <> '-1') then
                   SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   SELECT atributoentidadevalor_seq.nextval INTO ln_id_atr FROM dual;');
                   SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   INSERT INTO ATRIBUTOENTIDADEVALOR (ATRIBUTOENTIDADEID,TIPOENTIDADE,IDENTIDADE,ATRIBUTOID,VALORDATA)');
                   ls_campo:='      SELECT ln_id_atr, ''P'', ln_id_proj, ' || array(x)(2) ||',to_date('''|| dados(array(x)(1)) || ''',''DD/MM/YYYY'') FROM dual;';
                   SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,ls_campo);
                 end if;
             else -- TEXTO
             if (nvl(trim(dados(array(x)(1))),'-1') <> '-1') then
               SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   SELECT atributoentidadevalor_seq.nextval INTO ln_id_atr FROM dual;');
               SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   INSERT INTO ATRIBUTOENTIDADEVALOR (ATRIBUTOENTIDADEID,TIPOENTIDADE,IDENTIDADE,ATRIBUTOID,VALOR)');
               ls_campo:='      SELECT ln_id_atr, ''P'', ln_id_proj, ' || array(x)(2) ||','''|| trim(dados(array(x)(1))) || ''' FROM dual;';
               SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,ls_campo);
             end if;
             end if;
         end loop;
     SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   -- Escopo');
     SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   INSERT INTO RESPONSAVELENTIDADE (TIPOENTIDADE, RESPONSAVEL, IDENTIDADE)');
--     SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'   INSERT INTO ESCOPO (Projeto) values (' || ln_id_proj || ');');

--   if (nvl(trim(dados(8)),'-1') <> '-1') then
--   end if;

/*
    b_int:=utl_raw.length (utl_raw.cast_to_raw(dados(8)));
    
    if (primeiro_registro) then
      dbms_lob.write(blob_edit, b_int, 1, utl_raw.cast_to_raw(ls_linha));
      primeiro_registro:=false;
    else
      dbms_lob.writeappend(blob_edit, b_int , utl_raw.cast_to_raw(ls_linha));
    end if;

 END LOOP;

 select documento_seq.nextval into ln_doc from dual;
 select documento_conteudo_seq.nextval into ln_doc_cont from dual;

 Insert into DOCUMENTO (DOCUMENTOID,DESCRICAO, TIPOENTIDADE,IDENTIDADE,
                        AREAGERENCIA,ESTADODOCUMENTO,VERSAOATUAL,TIPODOCUMENTO,
                        RESPONSAVEL,DOCUMENTO_PAI,TIPO_DOCUMENTO_ID,TAMANHO) 
 select ln_doc,trim(ls_tipo)||'-'||to_char(ln_ano)||' Exportado em '||to_char(sysdate,'DD-MM-YYYY HH24-MI-SS'),null,null,
        null,'I',1,'.txt',
        null,null,null,null 
     from dual;

 insert into documento_conteudo (id, documento_id, versao, conteudo)
 values (ln_doc_cont, ln_doc, 1, empty_blob());-- returning conteudo into blob_edit;

 update documento_conteudo
 set conteudo = blob_edit
 where id=ln_doc_cont;

 dbms_lob.FREETEMPORARY(blob_edit);

*/
   end if;
--end if;
   --------------------------------------
   -- FIM do Processamento da Linha    --
   --------------------------------------

   vstart:=vend+length(ls_seperador_registro);
   vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);
   dados:=t_dados();
END LOOP;
SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'end;');
SYS.UTL_FILE.PUT_LINE( vFILE_SAIDA,'--Linha:'||registros);
SYS.UTL_FILE.FFLUSH(vFILE_SAIDA);
SYS.UTL_FILE.FCLOSE(vFILE_SAIDA);

ln_retorno:=registros;

end p_Carga_Inicial_Script;

procedure p_Carga_Inicial(ln_seq number, ln_retorno in out number)
is
ls_campo VARCHAR2(32000);
 ln_campo number;
 ld_campo date;
 ls_seperador_campo varchar2(5);
 ls_seperador_registro varchar2(5);
 ln_qtde_campos integer;
 l_colcnt integer;
 reg lista_campos;
 ln_doc int;
 ln_doc_cont int;
 blob_edit   BLOB; 
 ls_linha varchar2(32767);
 b_int binary_integer;
 c INTEGER;
 fdbk integer;
 ln_tamanho number;
 primeiro_registro1 boolean:=true;
 primeiro_registro2 boolean:=true;
 primeiro_registro3 boolean:=true;
 primeiro_registro4 boolean:=true;
 primeiro_registro5 boolean:=true;
 primeiro_registro6 boolean:=true;
 primeiro_registro7 boolean:=true;
 primeiro_registro8 boolean:=true;

 ls_query varchar2(2000);
 vtemp RAW(32000);
vend NUMBER := 1;
vlen NUMBER := 1;
vstart NUMBER := 1;

vend2 NUMBER := 1;
vlen2 NUMBER := 1;
vstart2 NUMBER := 1;
i number;
bytelen NUMBER := 32000;
ultimo_campo boolean;
registros number:=0;     
ln_id_proj number:=0;              
ln_id_ativ number:=0;              
ln_id_tar number:=0;              
ln_tipo  number:=0;
ln_id_atr  number:=0;              
ln_categ number:=0;
ls_tipo varchar2(1);
lb_erro boolean:=false;
blob_edit1             CLOB; 
blob_edit2             CLOB; 
blob_edit3             CLOB; 
blob_edit4             CLOB; 
blob_edit5             CLOB; 
blob_edit6             CLOB; 

TYPE t_dados IS VARRAY(100) OF varchar2(32000);
dados t_dados:=t_dados();

type    Array1D is table of Number;
type    Array2D is table of Array1D;
array   Array2D;
array2   Array2D;

begin

ls_seperador_campo:=chr(9);  -- TAB
ls_seperador_campo:=chr(35); -- #
ls_seperador_registro:=chr(13)||chr(10);
  
select conteudo into blob_edit
from documento_conteudo
where documento_id=ln_seq;

vlen:=dbms_lob.getlength(blob_edit);
bytelen := 32000;
vstart := 1;
vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);

begin
--vlen:=100;
WHILE vstart < vlen 
LOOP
--dbms_output.put_line('newline:'||vstart);
--dbms_output.put_line('newline:'||vend);
vlen2:=vend-vstart+1;
   dbms_lob.read(blob_edit,vlen2,vstart,vtemp);
   ls_linha:=utl_raw.cast_to_varchar2(vtemp);
    registros:=registros+1;
    
vend2 := 1;
--vlen2 := length(ls_linha);
--dbms_output.put_line('Linha text:'||ls_linha);
vstart2 := 1;
vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);

i:=1;     
ultimo_campo:=false;
WHILE vstart2 < vlen2 or ultimo_campo
LOOP
--dbms_output.put_line('len2:'||vlen2);
--dbms_output.put_line('start2:'||vstart2);
--dbms_output.put_line('vend2:'||vend2);

     select t_tipo_campos(sec,nome,tipo,tamanho,decimais,separador,formato,obrigatorio,opcoes,descricao)
     BULK COLLECT INTO reg     from table(f_lista_campos) where sec=i;

   ls_campo:=substr(ls_linha, vstart2, vend2-vstart2);
--   dbms_output.put_line('Campo:'||reg(1).sec||':'||reg(1).nome||' Tipo:'||reg(1).tipo||' Valor:'||ls_campo);
   dados.extend;
   dados(i):=replace(ls_campo,'''','''''');
   vstart2:=vend2+length(ls_seperador_campo);
  if not ultimo_campo then
     vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);
  else
     ultimo_campo:=false;
  end if;


  if vend2 =0 then
    ultimo_campo:=true;
    vend2:=vlen2;
  end if;
i:=i+1;
END LOOP;


array := new Array2D(                  -- ordem , atributo
                                  Array1D(5,43),
                                  Array1D(6,16),
                                  Array1D(7,17),
                                  Array1D(9,15),
                                  Array1D(15,70),
                                  Array1D(18,71),
                                  Array1D(19,72),
                                  Array1D(20,73),
                                  Array1D(21,74),
                                  Array1D(22,75),
                                  Array1D(23,76),
                                  Array1D(17,80),
                                  Array1D(10,11),
                                  Array1D(11,2)
                                  
                     );   

array2 := new Array2D(                  -- ordem , atributo
                                  Array1D(2,7),
                                  Array1D(3,8),
                                  Array1D(4,9)
                                  
                     );   

   --------------------------------------
   -- Inicio do Processamento da Linha --
   --------------------------------------
--if registros < 1000 then

   if dados(1)='10' then -- PROJETOS

       
       SELECT projeto_seq.nextval INTO ln_id_proj FROM dual;
       IF primeiro_registro1 THEN
         dbms_output.put_line('SELECT * FROM PROJETO WHERE ID >= '||ln_id_proj);
         dbms_output.put_line('SELECT * FROM RESPONSAVELENTIDADE WHERE IDENTIDADE >= '||ln_id_proj);
         dbms_output.put_line('SELECT * FROM ATRIBUTOENTIDADEVALOR WHERE IDENTIDADE >= '||ln_id_proj);
         dbms_output.put_line('SELECT * FROM ESCOPO WHERE PROJETO >= '||ln_id_proj);
         dbms_output.put_line('SELECT * FROM PRODUTOENTREGAVEL WHERE PROJETO >= '||ln_id_proj);
         dbms_output.put_line('SELECT * FROM PREMISSA WHERE PROJETO >= '||ln_id_proj);
         dbms_output.put_line('SELECT * FROM RESTRICAO WHERE PROJETO >= '||ln_id_proj);
         dbms_output.put_line('SELECT * FROM OCORRENCIA_ENTIDADE WHERE ENTIDADE_ID >= '||ln_id_proj);
         
         primeiro_registro1:=FALSE;
       END IF;

       INSERT INTO PROJETO (ID,TITULO,DESCRICAO,HORASPREVISTAS,HORASREALIZADAS,PRAZOPREVISTO,PRAZOREALIZADO,SITUACAO,SISTEMA,ORDEM,DATAINICIO,DATAFIMORCAMENTO,PORCENTAGEMCONCLUIDA,PERMITETEMPLATE,TIPOPROJETOID,INICIOREALIZADO,DURACAO,TIPORESTRICAO,DATARESTRICAO,ATUALIZARHORASPREVISTAS,CPI_MONETARIO,SPI_MONETARIO,ENTIDADE_PAI,CONSIDERAR_CUSTO,ALTERAR_PERC_CONCLUIDO,PERMITE_CUSTO_APENAS_TAREFA,EDICAO_EXCLUSIVA,MODIFICADOR,MOTIVO,DASHBOARD_ID,UO_ID,PROJETO_TEMPLATE_ID)
             SELECT ln_id_proj, dados(2)|| ' - ' || dados(3),dados(12),null,null,null,null,1,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,'A','N','Y',null,'310',null,null,null,null FROM dual;

       INSERT INTO RESPONSAVELENTIDADE (TIPOENTIDADE, RESPONSAVEL, IDENTIDADE)
              select 'P', nvl((select u.usuarioid from usuario u where upper(nome) = upper(dados(4))),'310'), ln_id_proj from dual;

       if (nvl(trim(dados(16)),'-1') <> '-1') then

            if length(trim(dados(16)))>4000 then
              dbms_output.put_line('Trunc Ocorrencia Proj:'||ln_id_proj||'  (4000) - Tamanho:' || length(trim(dados(16))));
              dados(16) := substr(trim(dados(16)),1,3997) || '...' ;
            end if;

          SELECT ocorrencia_entidade_seq.nextval INTO ln_id_atr FROM dual;
          INSERT INTO OCORRENCIA_ENTIDADE (ASSUNTO,DATA,ENTIDADE_ID,
                                           NOTIFICAR,OCORRENCIA_ID,USUARIO,
                                           BASE_CONHECIMENTO_ID,TIPO_ENTIDADE,TIPO_OCORRENCIA_ID)
                 select dados(16),null,ln_id_proj,
                        null,ln_id_atr,null,
                        null,'P',null  
                      from dual;
        
       end if;

/*
       if (nvl(trim(dados(17)),'-1') <> '-1') then
          dbms_output.put_line('EQUIPE:'||trim(dados(17)));
       end if;
       if (nvl(trim(dados(11)),'-1') <> '-1') then
          dbms_output.put_line('CR:'||trim(dados(11)));
       end if;*/

         for x in 1..array.Count
         loop
             if array(x)(2) in(73) then  -- DATA
                 if (nvl(trim(dados(array(x)(1))),'-1') <> '-1') then
                   SELECT atributoentidadevalor_seq.nextval INTO ln_id_atr FROM dual;
                   INSERT INTO ATRIBUTOENTIDADEVALOR (ATRIBUTOENTIDADEID,TIPOENTIDADE,IDENTIDADE,ATRIBUTOID,VALORDATA)
                     SELECT ln_id_atr, 'P', ln_id_proj, array(x)(2) ,to_date(dados(array(x)(1)) ,'DD/MM/YYYY') FROM dual;
                 end if;
             elsif  array(x)(2) in(2) then  -- Centro de Responsabilidade
                ln_categ:=0;
                begin
                select categoria_item_id into ln_categ from categoria_item_atributo where titulo like '2010%'||dados(array(x)(1))||'-%' and atributo_id=array(x)(2);

                   SELECT atributoentidadevalor_seq.nextval INTO ln_id_atr FROM dual;
                   INSERT INTO ATRIBUTOENTIDADEVALOR (ATRIBUTOENTIDADEID,TIPOENTIDADE,IDENTIDADE,ATRIBUTOID,Categoria_Item_Atributo_Id)
                     SELECT ln_id_atr, 'P', ln_id_proj, array(x)(2), ln_categ FROM dual;

                exception when no_data_found then
                  ln_categ:=0;
                    dbms_output.put_line('Projeto:'||ln_id_proj||'  Atributo Centro Responsabilidade não localizado: '||dados(array(x)(1)) );
                  when others then
                  ln_categ:=0;
                    dbms_output.put_line('Projeto:'||ln_id_proj||'  Atributo Centro Responsabilidade localizou mais de 1 CR: '||dados(array(x)(1)) );
                end; 
               
             
             else -- TEXTO
                 if (nvl(trim(dados(array(x)(1))),'-1') <> '-1') then
                      if length(trim(dados(array(x)(1))))>4000 then
                        dbms_output.put_line('Trunc Projeto:'||ln_id_proj||'  Atributo (4000) '||array(x)(2) || ' - Tamanho:' || length(trim(dados(array(x)(1)))));
                        dados(array(x)(1)) := substr(trim(dados(array(x)(1))),1,3997) || '...' ;
                      end if;
                      SELECT atributoentidadevalor_seq.nextval INTO ln_id_atr FROM dual;
                      INSERT INTO ATRIBUTOENTIDADEVALOR (ATRIBUTOENTIDADEID,TIPOENTIDADE,IDENTIDADE,ATRIBUTOID,VALOR)
                          SELECT ln_id_atr, 'P', ln_id_proj, array(x)(2), trim(dados(array(x)(1))) FROM dual;
                 end if;
             end if;
         end loop;

      if (nvl(trim(dados(8)),'-1') <> '-1') then

          select max(id)+1 into ln_id_atr from produtoentregavel;
          insert into produtoentregavel (ID, Projeto, descricao)
          values (ln_id_atr,ln_id_proj,dados(8));  
          
      end if;
   end if;
   if dados(1)='20' then -- Escopo

      INSERT INTO ESCOPO (PROJETO, FECHADO, DESCPRODUTO,JUSTIFICATIVAPROJETO,OBJETIVOSPROJETO,LIMITESPROJETO,LISTAFATORESESSENCIAIS) 
         select ln_id_proj, 'S', empty_clob(), empty_clob(), empty_clob(), empty_clob(), empty_clob() from dual;

      if (nvl(trim(dados(2)),'-1') <> '-1') then
          DBMS_LOB.CREATETEMPORARY(blob_edit1,TRUE);
          b_int:=length(dados(2));
          dbms_lob.write(blob_edit1, b_int, 1, dados(2));
          update escopo 
            set DESCPRODUTO=blob_edit1 
            where projeto = ln_id_proj;
          dbms_lob.FREETEMPORARY(blob_edit1);
      end if;
      if (nvl(trim(dados(3)),'-1') <> '-1') then
          DBMS_LOB.CREATETEMPORARY(blob_edit1,TRUE);
          b_int:=length(dados(3));
          dbms_lob.write(blob_edit1, b_int, 1, dados(3));
          update escopo 
            set JUSTIFICATIVAPROJETO=blob_edit1 
            where projeto = ln_id_proj;
          dbms_lob.FREETEMPORARY(blob_edit1);
      end if;
      if (nvl(trim(dados(4)),'-1') <> '-1') then
          DBMS_LOB.CREATETEMPORARY(blob_edit1,TRUE);
          b_int:=length(dados(4));
          dbms_lob.write(blob_edit1, b_int, 1, dados(4));
          update escopo 
            set OBJETIVOSPROJETO=blob_edit1 
            where projeto = ln_id_proj;
          dbms_lob.FREETEMPORARY(blob_edit1);
      end if;
      if (nvl(trim(dados(5)),'-1') <> '-1') then
          DBMS_LOB.CREATETEMPORARY(blob_edit1,TRUE);
          b_int:=length(dados(5));
          dbms_lob.write(blob_edit1, b_int, 1, dados(5));
          update escopo 
            set LIMITESPROJETO=blob_edit1 
            where projeto = ln_id_proj;
          dbms_lob.FREETEMPORARY(blob_edit1);
      end if;

      if (nvl(trim(dados(6)),'-1') <> '-1') then

          select max(id)+1 into ln_id_atr from premissa;

          insert into premissa (ID, Projeto, descricao)
          values (ln_id_atr,ln_id_proj,dados(6));

      end if;

      if (nvl(trim(dados(7)),'-1') <> '-1') then

          select max(id)+1 into ln_id_atr from restricao;

          insert into restricao (ID, Projeto, descricao)
          values (ln_id_atr,ln_id_proj,dados(7));

      end if;
   end if;

   if dados(1)='30' then -- INICIO Atividades

      SELECT atividade_seq.nextval INTO ln_id_ativ FROM dual;
       IF primeiro_registro2 THEN
         dbms_output.put_line('SELECT * FROM ATIVIDADE WHERE ID >= '||ln_id_ativ);
         primeiro_registro2:=FALSE;
       END IF;
/*
      dbms_output.put_line('D5:'||trim(dados(5)));
      dbms_output.put_line('D6:'||trim(dados(6)));
      dbms_output.put_line('D7:'||trim(dados(7)));
      dbms_output.put_line('D8:'||trim(dados(8)));
*/
      if length(trim(dados(2)))>150 then
        dbms_output.put_line('Trunc Atividade:'||ln_id_ativ||'  Titulo (150) - Tamanho:' || length(trim(dados(2))));
        dados(2) := substr(trim(dados(2)),1,147) || '...' ;
      end if;

      INSERT INTO ATIVIDADE (ID, TITULO, MODIFICADOR, 
                  DESCRICAO,
                  datainicio,
                  prazoprevisto,		
                  iniciorealizado,		
                  prazorealizado,
                  Situacao, Projeto)
             select ln_id_ativ,  dados(2), nvl((select u.usuarioid from usuario u where upper(nome) = upper(dados(3))),'310'), 
                    dados(4),
                    trunc(to_date(trim(dados(5)) ,'DD/MM/YYYY HH24:MI:SS')),
                    trunc(to_date(trim(dados(6)) ,'DD/MM/YYYY HH24:MI:SS')),
                    trunc(to_date(trim(dados(7)) ,'DD/MM/YYYY HH24:MI:SS')),
                    trunc(to_date(trim(dados(8)) ,'DD/MM/YYYY HH24:MI:SS')),
                    1,ln_id_proj
                     from dual;

       INSERT INTO RESPONSAVELENTIDADE (TIPOENTIDADE, RESPONSAVEL, IDENTIDADE)
              select 'A', nvl((select u.usuarioid from usuario u where upper(nome) = upper(dados(3))),'310'), ln_id_ativ from dual;

       if (nvl(trim(dados(15)),'-1') <> '-1') then  -- Atributo Resultados de Atividades
            if length(trim(dados(15)))>4000 then
              dbms_output.put_line('Trunc Atividade:'||ln_id_ativ||'  Atributo (4000) 77 - Tamanho:' || length(trim(dados(15))));
              dados(15) := substr(trim(dados(15)),1,3997) || '...' ;
            end if;
            SELECT atributoentidadevalor_seq.nextval INTO ln_id_atr FROM dual;
            INSERT INTO ATRIBUTOENTIDADEVALOR (ATRIBUTOENTIDADEID,TIPOENTIDADE,IDENTIDADE,ATRIBUTOID,VALOR)
                SELECT ln_id_atr, 'A', ln_id_ativ, 77, trim(dados(15)) FROM dual;
       end if;

       if (nvl(trim(dados(16)),'-1') <> '-1') then

            if length(trim(dados(16)))>4000 then
              dbms_output.put_line('Trunc Ocorrencia Ativ:'||ln_id_ativ||'  (4000) - Tamanho:' || length(trim(dados(16))));
              dados(16) := substr(trim(dados(16)),1,3997) || '...' ;
            end if;

          SELECT ocorrencia_entidade_seq.nextval INTO ln_id_atr FROM dual;
          INSERT INTO OCORRENCIA_ENTIDADE (ASSUNTO,DATA,ENTIDADE_ID,
                                           NOTIFICAR,OCORRENCIA_ID,USUARIO,
                                           BASE_CONHECIMENTO_ID,TIPO_ENTIDADE,TIPO_OCORRENCIA_ID)
                 select dados(16),null,ln_id_proj,
                        null,ln_id_atr,null,
                        null,'P',null  
                      from dual;
        
       end if;

       if (nvl(trim(dados(17)),'-1') <> '-1') then  -- Atributo Recomendações
            if length(trim(dados(17)))>4000 then
              dbms_output.put_line('Trunc Atividade:'||ln_id_ativ||'  Atributo (4000) 78 - Tamanho:' || length(trim(dados(17))));
              dados(17) := substr(trim(dados(17)),1,3997) || '...' ;
            end if;
            SELECT atributoentidadevalor_seq.nextval INTO ln_id_atr FROM dual;
            INSERT INTO ATRIBUTOENTIDADEVALOR (ATRIBUTOENTIDADEID,TIPOENTIDADE,IDENTIDADE,ATRIBUTOID,VALOR)
                SELECT ln_id_atr, 'A', ln_id_ativ, 78, trim(dados(17)) FROM dual;
       end if;

       if (nvl(trim(dados(12)),'-1') <> '-1') then
          dbms_output.put_line('TIPO:'||trim(dados(12)));
       end if;
       if (nvl(trim(dados(13)),'-1') <> '-1') then
          dbms_output.put_line('PREDECES:'||trim(dados(13)));
       end if;

   end if;  -- FIM Atividades

   if dados(1)='40' then -- INICIO Tarefas

      SELECT tarefa_seq.nextval INTO ln_id_tar FROM dual;
       IF primeiro_registro3 THEN
         dbms_output.put_line('SELECT * FROM TAREFA WHERE ID >= '||ln_id_tar);
         primeiro_registro3:=FALSE;
       END IF;

--      dbms_output.put_line('Tit ini hor:'||dados(2) ||'-' || trim(dados(6))||'-' || trim(dados(10)));

      
      if length(trim(dados(2)))>150 then
        dbms_output.put_line('Trunc TAREFA:'||ln_id_tar||'  Titulo (150) - Tamanho:' || length(trim(dados(2))));
        dados(2) := substr(trim(dados(2)),1,147) || '...' ;
      end if;

      INSERT INTO TAREFA (ID, TITULO, MODIFICADOR, 
                  DESCRICAO,
                  datainicio,
                  prazoprevisto,		
                  iniciorealizado,		
                  prazorealizado,
                  Atividade,
                  horasprevistas,
                  horasrealizadas,
                  situacao, projeto)
             select ln_id_tar,  dados(2), nvl((select u.usuarioid from usuario u where upper(nome) = upper(dados(4))),'310'), 
                    dados(5),
                    trunc(to_date(trim(dados(6)) ,'DD/MM/YYYY HH24:MI:SS')),
                    trunc(to_date(trim(dados(7)) ,'DD/MM/YYYY HH24:MI:SS')),
                    trunc(to_date(trim(dados(8)) ,'DD/MM/YYYY HH24:MI:SS')),
                    trunc(to_date(trim(dados(9)) ,'DD/MM/YYYY HH24:MI:SS')),
                    ln_id_ativ,
                    trim(dados(10)),
                    trim(dados(11)),
                    1,ln_id_proj
                from dual;

       INSERT INTO RESPONSAVELENTIDADE (TIPOENTIDADE, RESPONSAVEL, IDENTIDADE)
              select 'T', nvl((select u.usuarioid from usuario u where upper(nome) = upper(dados(4))),'310'), ln_id_tar from dual;

   end if;  -- FIM Tarefas

   if dados(1)='50' then -- INICIO Metas

      ls_campo:='Descrição:' || nvl(trim(dados(2)),' ');
      ls_campo:=ls_campo||'Indicador:'|| nvl(trim(dados(3)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'Tarefa ou Atividade Vinculada:'|| nvl(trim(dados(4)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'Critério (Status ou Acumulado):'|| nvl(trim(dados(5)),' ')  || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'Unidade de medida:'|| nvl(trim(dados(6)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'Ano:'|| nvl(trim(dados(7)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'mês limite:'|| nvl(trim(dados(8)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'Previsto:'|| nvl(trim(dados(9)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'Retificado:'|| nvl(trim(dados(10)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'Revisado:'|| nvl(trim(dados(11)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'Realizado:'|| nvl(trim(dados(12)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'Observações:'|| nvl(trim(dados(13)),' ') || CHR(13) || CHR(10);
      ls_campo:=ls_campo||'% de desempenho:'|| nvl(trim(dados(14)),' ') || CHR(13) || CHR(10);

      if length(ls_campo)>4000 then
        dbms_output.put_line('Trunc Metas do Projeto:'||ln_id_proj||'  Atributo (4000) 79 - Tamanho:' || length(ls_campo));
        ls_campo := substr(trim(ls_campo),1,3997) || '...' ;
      end if;
      SELECT atributoentidadevalor_seq.nextval INTO ln_id_atr FROM dual;
      INSERT INTO ATRIBUTOENTIDADEVALOR (ATRIBUTOENTIDADEID,TIPOENTIDADE,IDENTIDADE,ATRIBUTOID,VALOR)
          SELECT ln_id_atr, 'P', ln_id_proj, 79, trim(ls_campo) FROM dual;

   end if;  -- FIM Metas

   if dados(1) in ('60','90') then -- INICIO Despesas / Receitas
      ln_categ:=0;
      lb_erro:=false;
      
      if dados(1)='60' then 
         ls_tipo:='C';
      else
         ls_tipo:='R';
      end if;
      begin
        
         select ID into ln_categ
           from custo_receita where trim(Titulo) like trim(dados(2)) || ' %' || trim(dados(3))|| '% - %' and tipo=ls_tipo;-- and vigente = 'Y';
      exception
         when no_data_found then
         dbms_output.put_line('Projeto:'||ln_id_proj ||' Não localizou na Árvore de custos:'||trim(dados(2)) || ' - ' || trim(dados(3))|| ' Tipo:'||ls_tipo);
         lb_erro:=true;
         when others then
         dbms_output.put_line('Projeto:'||ln_id_proj ||' Árvore de custos com mais de 1 registro para:'||trim(dados(2)) || ' - ' || trim(dados(3))|| ' Tipo:'||ls_tipo);
         lb_erro:=true;
      end;
      
      if not lb_erro then

      -- inclui permissoes automaticas para inclusão de lançamento
      ln_id_atr:=0;
       select count(1) 
         into       ln_id_atr
         from custo_receita_forma crf
        where crf.forma_id         = case ls_tipo when 'C' then 7 else 8 end
          and crf.vigente          = 'Y'
          and crf.custo_receita_id = ln_categ;

      if ln_id_atr=0 then

         SELECT custo_receita_forma_seq.nextval INTO ln_tipo FROM dual;

         IF primeiro_registro6 THEN
           dbms_output.put_line('SELECT * FROM CUSTO_RECEITA_FORMA WHERE ID >= '||ln_tipo);
           primeiro_registro6:=FALSE;
         END IF;

         insert into custo_receita_forma (ID,CUSTO_RECEITA_ID,FORMA_ID,VIGENCIA,VIGENTE,VALOR_DEFAULT)
         select ln_tipo, ln_categ, case ls_tipo when 'C' then 7 else 8 end, sysdate, 'Y' ,'N'
         from dual;  

      end if;

      ln_id_atr:=0;
       select count(1) 
         into       ln_id_atr
         from custo_receita_tipo crt
        where crt.tipo_id          = case ls_tipo when 'C' then 3 else 4 end
          and crt.vigente          = 'Y'
          and crt.custo_receita_id = ln_categ;

      if ln_id_atr=0 then

         SELECT custo_receita_tipo_seq.nextval INTO ln_tipo FROM dual;

         IF primeiro_registro7 THEN
           dbms_output.put_line('SELECT * FROM CUSTO_RECEITA_TIPO WHERE ID >= '||ln_tipo);
           primeiro_registro7:=FALSE;
         END IF;

         insert into custo_receita_tipo (ID,CUSTO_RECEITA_ID,TIPO_ID,VIGENCIA,VIGENTE,VALOR_DEFAULT)
         select ln_tipo, ln_categ, case ls_tipo when 'C' then 3 else 4 end, sysdate, 'Y' ,'N'
         from dual;  

      end if;
        
      ln_id_atr:=0;
        
      select nvl(min(id),0) into ln_id_atr
      from custo_entidade 
        where TIPO_ENTIDADE='P' and
              ENTIDADE_ID=ln_id_proj and
              CUSTO_RECEITA_ID=ln_categ;


      if ln_id_atr=0 then

        SELECT custo_entidade_seq.nextval INTO ln_id_atr FROM dual;

         IF primeiro_registro4 THEN
           dbms_output.put_line('SELECT * FROM CUSTO_ENTIDADE WHERE ID >= '||ln_id_atr);
           primeiro_registro4:=FALSE;
         END IF;

        insert into custo_entidade (ID,TIPO_ENTIDADE,ENTIDADE_ID,CUSTO_RECEITA_ID,
                                    TITULO,TIPO_DESPESA_ID,FORMA_AQUISICAO_ID,
                                    UNIDADE,MOTIVO)
           select ln_id_atr,'P',ln_id_proj,ln_categ,
                  trim(dados(3)), case ls_tipo when 'C' then 3 else 4 end, case ls_tipo when 'C' then 7 else 8 end,
                  null, null
                  from dual;

      end if;
      

 
      -- R Realizado
      if (nvl(trim(dados(8)),'-1') <> '-1') and to_number(dados(8))>0 then

         SELECT custo_lancamento_seq.nextval INTO ln_id_tar FROM dual;
         IF primeiro_registro5 THEN
           dbms_output.put_line('SELECT * FROM CUSTO_LANCAMENTO WHERE ID >= '||ln_id_tar);
           primeiro_registro5:=FALSE;
         END IF;

         insert into custo_lancamento  (ID,CUSTO_ENTIDADE_ID,TIPO,SITUACAO,
                                        DATA,VALOR_UNITARIO,QUANTIDADE,VALOR,
                                        USUARIO_ID,DATA_ALTERACAO)
           select ln_id_tar,ln_id_atr,'R','V',  -- realizado, válido
                  trunc(to_date(trim(dados(4)) ,'DD/MM/YYYY HH24:MI:SS')),
                  to_number(dados(8)),1,to_number(dados(8)),'310',
                  trunc(to_date(trim(dados(4)) ,'DD/MM/YYYY HH24:MI:SS'))
           from dual;
           
      end if;

      -- P Planejado
      if (nvl(trim(dados(5)),'-1') <> '-1') and to_number(dados(5))>0 then
         SELECT custo_lancamento_seq.nextval INTO ln_id_tar FROM dual;
         IF primeiro_registro5 THEN
           dbms_output.put_line('SELECT * FROM CUSTO_LANCAMENTO WHERE ID >= '||ln_id_atr);
           primeiro_registro5:=FALSE;
         END IF;
         insert into custo_lancamento  (ID,CUSTO_ENTIDADE_ID,TIPO,SITUACAO,
                                        DATA,VALOR_UNITARIO,QUANTIDADE,VALOR,
                                        USUARIO_ID,DATA_ALTERACAO)
           select ln_id_tar,ln_id_atr,'P','V',  -- realizado, válido
                  trunc(to_date(trim(dados(4)) ,'DD/MM/YYYY HH24:MI:SS')),
                  to_number(dados(5)),1,to_number(dados(5)),'310',
                  trunc(to_date(trim(dados(4)) ,'DD/MM/YYYY HH24:MI:SS'))
           from dual;
           
      end if;

      -- P Retificado
      if (nvl(trim(dados(6)),'-1') <> '-1') and to_number(dados(6))>0 then
        update custo_entidade
        set Motivo = nvl(Motivo,' ') || ' Refificado:' ||trim(dados(6))
        where id=ln_id_atr;
      end if;

      -- P Revisado
      if (nvl(trim(dados(7)),'-1') <> '-1') and to_number(dados(7))>0 then
        update custo_entidade
        set Motivo = nvl(Motivo,' ') || ' Revisado:' ||trim(dados(7))
        where id=ln_id_atr;
      end if;


      end if;
   end if;  -- FIM Despesas
 
   if dados(1) in ('80') then -- Origem dos recursos

         for x in 1..array2.Count
         loop
                 if (nvl(trim(dados(array2(x)(1))),'-1') <> '-1') then
                      if length(trim(dados(array2(x)(1))))>4000 then
                        dbms_output.put_line('Trunc Projeto:'||ln_id_proj||'  Atributo (4000) '||array2(x)(2) || ' - Tamanho:' || length(trim(dados(array2(x)(1)))));
                        dados(array2(x)(1)) := substr(trim(dados(array2(x)(1))),1,3997) || '...' ;
                      end if;
                      SELECT atributoentidadevalor_seq.nextval INTO ln_id_atr FROM dual;
                      INSERT INTO ATRIBUTOENTIDADEVALOR (ATRIBUTOENTIDADEID,TIPOENTIDADE,IDENTIDADE,ATRIBUTOID,VALOR)
                          SELECT ln_id_atr, 'P', ln_id_proj, array2(x)(2), trim(dados(array2(x)(1))) FROM dual;
                 end if;
         end loop;
   end if; -- FIM Origem dos recursos

  delete contadores where nometabela in ('RESTRICAO', 'PREMISSA', 'PRODUTOENTREGAVEL');
--end if;
   --------------------------------------
   -- FIM do Processamento da Linha    --
   --------------------------------------

   vstart:=vend+length(ls_seperador_registro);
   vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);
   dados:=t_dados();
END LOOP;

exception when others then
dbms_output.put_line('Erro linha:'||registros|| '  ' || sqlerrm);  
end;

ln_retorno:=registros;
--rollback;
end p_Carga_Inicial;          

procedure p_Importa_Custos(ln_seq number, ln_retorno in out number)
is
ls_campo VARCHAR2(32000);
 ln_campo number;
 ld_campo date;
 ls_seperador_campo varchar2(5);
 ls_seperador_registro varchar2(5);
 ln_qtde_campos integer;
 l_colcnt integer;
 reg lista_campos;
 ln_doc int;
 ln_doc_cont int;
 blob_edit   BLOB; 
 ls_linha varchar2(32767);
 b_int binary_integer;
 c INTEGER;
 fdbk integer;
 ln_tamanho number;
 primeiro_registro1 boolean:=true;
 primeiro_registro2 boolean:=true;
 primeiro_registro3 boolean:=true;
 primeiro_registro4 boolean:=true;
 primeiro_registro5 boolean:=true;
 primeiro_registro6 boolean:=true;
 primeiro_registro7 boolean:=true;
 primeiro_registro8 boolean:=true;

 ls_query varchar2(2000);
 vtemp RAW(32000);
vend NUMBER := 1;
vlen NUMBER := 1;
vstart NUMBER := 1;

vend2 NUMBER := 1;
vlen2 NUMBER := 1;
vstart2 NUMBER := 1;
i number;
bytelen NUMBER := 32000;
ultimo_campo boolean;
registros number:=0;     
ln_id_proj number:=0;              
ln_id_ativ number:=0;              
ln_id_ativc number:=0;
ln_id_tar number:=0;              
ln_id_tarc number:=0;              
ln_tipo  number:=0;
ln_id_atr  number:=0;              
ln_categ number:=0;
ls_tipo varchar2(1);
lb_erro boolean:=false;
blob_edit1             CLOB; 
blob_edit2             CLOB; 
blob_edit3             CLOB; 
blob_edit4             CLOB; 
blob_edit5             CLOB; 
blob_edit6             CLOB; 

TYPE t_dados IS VARRAY(100) OF varchar2(32000);
dados t_dados:=t_dados();

type    Array1D is table of Number;
type    Array2D is table of Array1D;
array   Array2D;
array2   Array2D;

begin

ls_seperador_campo:=chr(9);  -- TAB
--ls_seperador_campo:=chr(35); -- #
ls_seperador_registro:=chr(13)||chr(10);
  
select conteudo into blob_edit
from documento_conteudo
where documento_id=ln_seq;

vlen:=dbms_lob.getlength(blob_edit);
bytelen := 32000;
vstart := 1;
vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);

begin
--vlen:=100;
WHILE vstart < vlen 
LOOP
--dbms_output.put_line('newline:'||vstart);
--dbms_output.put_line('newline:'||vend);
vlen2:=vend-vstart+1;
   dbms_lob.read(blob_edit,vlen2,vstart,vtemp);
   ls_linha:=utl_raw.cast_to_varchar2(vtemp);
    registros:=registros+1;
    
vend2 := 1;
--vlen2 := length(ls_linha);
--dbms_output.put_line('Linha text:'||ls_linha);
vstart2 := 1;
vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);

i:=1;     
ultimo_campo:=false;
WHILE vstart2 < vlen2 or ultimo_campo
LOOP
--dbms_output.put_line('len2:'||vlen2);
--dbms_output.put_line('start2:'||vstart2);
--dbms_output.put_line('vend2:'||vend2);

     select t_tipo_campos(sec,nome,tipo,tamanho,decimais,separador,formato,obrigatorio,opcoes,descricao)
     BULK COLLECT INTO reg     from table(f_lista_campos) where sec=i;

   ls_campo:=substr(ls_linha, vstart2, vend2-vstart2);
--   dbms_output.put_line('Campo:'||reg(1).sec||':'||reg(1).nome||' Tipo:'||reg(1).tipo||' Valor:'||ls_campo);
   dados.extend;
   dados(i):=replace(ls_campo,'''','''''');
   vstart2:=vend2+length(ls_seperador_campo);
  if not ultimo_campo then
     vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);
  else
     ultimo_campo:=false;
  end if;


  if vend2 =0 then
    ultimo_campo:=true;
    vend2:=vlen2;
  end if;
i:=i+1;
END LOOP;


array := new Array2D(                  -- ordem , atributo
                                  Array1D(5,43),
                                  Array1D(6,16),
                                  Array1D(7,17),
                                  Array1D(9,15),
                                  Array1D(15,70),
                                  Array1D(18,71),
                                  Array1D(19,72),
                                  Array1D(20,73),
                                  Array1D(21,74),
                                  Array1D(22,75),
                                  Array1D(23,76),
                                  Array1D(17,80),
                                  Array1D(10,11),
                                  Array1D(11,2)
                                  
                     );   

array2 := new Array2D(                  -- ordem , atributo
                                  Array1D(2,7),
                                  Array1D(3,8),
                                  Array1D(4,9)
                                  
                     );   

   --------------------------------------
   -- Inicio do Processamento da Linha --
   --------------------------------------
--if registros < 1000 then

    lb_erro:=false;
    ln_id_proj:=0;
    ls_tipo:='C';

--dados(4):='2010 390010101';

     begin       
      
     dados(1):='2010 '||dados(1);
--     dados(1):='2010 1900101043504';

     select ci.categoria_item_id into ln_categ
            from categoria_item_atributo ci
            where ci.titulo like dados(1)||'%';

      exception when no_data_found then
        ln_categ:=0;
          dbms_output.put_line('Linha:'||registros||' Atributo Centro Responsabilidade não localizado: '||dados(1) );
          lb_erro:=true;
        when others then
        ln_categ:=0;
          dbms_output.put_line('Linha:'||registros||' Atributo Centro Responsabilidade localizou mais de 1 CR: '||dados(1) );
          lb_erro:=true;
     end; 
            
     
    if not lb_erro then
     begin
     select Identidade into ln_id_proj 
          from ATRIBUTOENTIDADEVALOR 
              where      TIPOENTIDADE='P' and
                         ATRIBUTOID = 2 and 
                         Categoria_Item_Atributo_Id = ln_categ;
      exception when no_data_found then
        ln_categ:=0;
          dbms_output.put_line('Linha:'||registros||' Não foi localizado Projeto com Atributo Centro Responsabilidade: '||dados(1) );
          lb_erro:=true;
        when others then
        ln_categ:=0;
          dbms_output.put_line('Linha:'||registros||' Existe mais de um Projeto com Atributo Centro Responsabilidade: '||dados(1) );
          lb_erro:=true;
     end; 
    end if;
    if not lb_erro then
--        dbms_output.put_line('Custo:'|| trim(dados(4))||' Proj:'|| ln_id_proj);
        ln_categ:=0;
        begin
           select ID into ln_categ
             from custo_receita where trim(Titulo) like trim(dados(4))|| '% - %' and tipo=ls_tipo;-- and vigente = 'Y';
        exception
           when no_data_found then
           dbms_output.put_line('Linha:'||registros||' Projeto:'||ln_id_proj ||' Não localizou na Árvore de custos:'|| trim(dados(4))|| ' Tipo:'||ls_tipo);
           lb_erro:=true;
           when others then
           dbms_output.put_line('Linha:'||registros||' Projeto:'||ln_id_proj ||' Árvore de custos com mais de 1 registro para:'|| trim(dados(4))|| ' Tipo:'||ls_tipo);
           lb_erro:=true;
        end;

      if not lb_erro then
      -- inclui permissoes automaticas para inclusão de lançamento
      ln_id_atr:=0;
       select count(1) 
         into       ln_id_atr
         from custo_receita_forma crf
        where crf.forma_id         = case ls_tipo when 'C' then 7 else 8 end
          and crf.vigente          = 'Y'
          and crf.custo_receita_id = ln_categ;

      if ln_id_atr=0 then

         SELECT custo_receita_forma_seq.nextval INTO ln_tipo FROM dual;

         IF primeiro_registro6 THEN
           dbms_output.put_line('SELECT * FROM CUSTO_RECEITA_FORMA WHERE ID >= '||ln_tipo);
           primeiro_registro6:=FALSE;
         END IF;

         insert into custo_receita_forma (ID,CUSTO_RECEITA_ID,FORMA_ID,VIGENCIA,VIGENTE,VALOR_DEFAULT)
         select ln_tipo, ln_categ, case ls_tipo when 'C' then 7 else 8 end, sysdate, 'Y' ,'N'
         from dual;  

      end if;

      ln_id_atr:=0;
       select count(1) 
         into       ln_id_atr
         from custo_receita_tipo crt
        where crt.tipo_id          = case ls_tipo when 'C' then 3 else 4 end
          and crt.vigente          = 'Y'
          and crt.custo_receita_id = ln_categ;

      if ln_id_atr=0 then

         SELECT custo_receita_tipo_seq.nextval INTO ln_tipo FROM dual;

         IF primeiro_registro7 THEN
           dbms_output.put_line('SELECT * FROM CUSTO_RECEITA_TIPO WHERE ID >= '||ln_tipo);
           primeiro_registro7:=FALSE;
         END IF;

         insert into custo_receita_tipo (ID,CUSTO_RECEITA_ID,TIPO_ID,VIGENCIA,VIGENTE,VALOR_DEFAULT)
         select ln_tipo, ln_categ, case ls_tipo when 'C' then 3 else 4 end, sysdate, 'Y' ,'N'
         from dual;  

      end if;

      ln_id_tarc:=0;
      begin
        select id into ln_id_tarc
        from tarefa
          where projeto=ln_id_proj and
                trim(tarefa.titulo)=trim(dados(3));
--           dbms_output.put_line('Achou Tarefa');
        exception
           when no_data_found then
           dbms_output.put_line('Linha:'||registros||' Projeto:'||ln_id_proj ||' Não Achou Tarefa:'||trim(dados(3)));
           ln_id_tarc:=0;
           lb_erro:=true;
           when others then
           dbms_output.put_line('Linha:'||registros||' Projeto:'||ln_id_proj ||'Achou Mais de uma Tarefa:'||trim(dados(3)));
           ln_id_tarc:=0;
           lb_erro:=true;
      end;
      ln_id_ativc:=0;

      if ln_id_tarc=0 then
      begin
        select id into ln_id_ativc
        from atividade
          where projeto=ln_id_proj and
                trim(titulo)=trim(dados(3));
           dbms_output.put_line('Achou Atividade');
        exception
           when no_data_found then
           dbms_output.put_line('Linha:'||registros||' Projeto:'||ln_id_proj ||' Não Achou Atividade:'||trim(dados(3)));
           ln_id_ativc:=0;
           lb_erro:=true;
           when others then
           dbms_output.put_line('Linha:'||registros||' Projeto:'||ln_id_proj ||'Achou Mais de uma Atividade:'||trim(dados(3)));
           ln_id_ativc:=0;
           lb_erro:=true;
      end;
        
      
      end if;
              
      ln_id_atr:=0;

      if ln_id_tarc>0 then

          select nvl(min(id),0) into ln_id_atr
          from custo_entidade 
            where TIPO_ENTIDADE='T' and
                  ENTIDADE_ID=ln_id_tarc and
                  CUSTO_RECEITA_ID=ln_categ;

      elsif ln_id_ativc>0 then

          select nvl(min(id),0) into ln_id_atr
          from custo_entidade 
            where TIPO_ENTIDADE='A' and
                  ENTIDADE_ID=ln_id_ativc and
                  CUSTO_RECEITA_ID=ln_categ;

      else
          select nvl(min(id),0) into ln_id_atr
          from custo_entidade 
            where TIPO_ENTIDADE='P' and
                  ENTIDADE_ID=ln_id_proj and
                  CUSTO_RECEITA_ID=ln_categ;
      end if;


      if ln_id_atr=0 then

        SELECT custo_entidade_seq.nextval INTO ln_id_atr FROM dual;

         IF primeiro_registro4 THEN
           dbms_output.put_line('SELECT * FROM CUSTO_ENTIDADE WHERE ID >= '||ln_id_atr);
           primeiro_registro4:=FALSE;
         END IF;

      if ln_id_tarc>0 then
        insert into custo_entidade (ID,TIPO_ENTIDADE,ENTIDADE_ID,CUSTO_RECEITA_ID,
                                    TITULO,TIPO_DESPESA_ID,FORMA_AQUISICAO_ID,
                                    UNIDADE,MOTIVO)
           select ln_id_atr,'T',ln_id_tarc,ln_categ,
                  trim(dados(5)), case ls_tipo when 'C' then 3 else 4 end, case ls_tipo when 'C' then 7 else 8 end,
                  null, null
                  from dual;
      elsif ln_id_ativc>0 then
        insert into custo_entidade (ID,TIPO_ENTIDADE,ENTIDADE_ID,CUSTO_RECEITA_ID,
                                    TITULO,TIPO_DESPESA_ID,FORMA_AQUISICAO_ID,
                                    UNIDADE,MOTIVO)
           select ln_id_atr,'A',ln_id_ativc,ln_categ,
                  trim(dados(5)), case ls_tipo when 'C' then 3 else 4 end, case ls_tipo when 'C' then 7 else 8 end,
                  null, null
                  from dual;
      
      else
        insert into custo_entidade (ID,TIPO_ENTIDADE,ENTIDADE_ID,CUSTO_RECEITA_ID,
                                    TITULO,TIPO_DESPESA_ID,FORMA_AQUISICAO_ID,
                                    UNIDADE,MOTIVO)
           select ln_id_atr,'P',ln_id_proj,ln_categ,
                  trim(dados(5)), case ls_tipo when 'C' then 3 else 4 end, case ls_tipo when 'C' then 7 else 8 end,
                  null, null
                  from dual;
        
      end if;

      end if;
      
      -- P Planejado
      if (nvl(trim(dados(7)),'-1') <> '-1') and to_number(dados(7))>0 then
         SELECT custo_lancamento_seq.nextval INTO ln_id_tar FROM dual;
         IF primeiro_registro5 THEN
           dbms_output.put_line('SELECT * FROM CUSTO_LANCAMENTO WHERE ID >= '||ln_id_tar);
           primeiro_registro5:=FALSE;
         END IF;
         insert into custo_lancamento  (ID,CUSTO_ENTIDADE_ID,TIPO,SITUACAO,
                                        DATA,VALOR_UNITARIO,QUANTIDADE,VALOR,
                                        USUARIO_ID,DATA_ALTERACAO)
           select ln_id_tar,ln_id_atr,'P','V',  -- planejado, válido
                  trunc(to_date(trim(dados(6)) ,'DD/MM/YYYY HH24:MI:SS')),
                  to_number(dados(7)),1,to_number(dados(7)),'310',sysdate
--                  trunc(to_date(trim(dados(6)) ,'DD/MM/YYYY HH24:MI:SS'))
           from dual;
      end if;
      end if;

        
    end if;



 
   --------------------------------------
   -- FIM do Processamento da Linha    --
   --------------------------------------

   vstart:=vend+length(ls_seperador_registro);
   vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);
   dados:=t_dados();
END LOOP;

exception when others then
dbms_output.put_line('Erro linha:'||registros|| '  ' || sqlerrm);  
end;

ln_retorno:=registros;
--rollback;
end p_Importa_Custos;

procedure p_Acerto_Carga_Inicial(ln_seq number, ln_retorno in out number)
is
ls_campo VARCHAR2(32000);
 ln_campo number;
 ld_campo date;
 ls_seperador_campo varchar2(5);
 ls_seperador_registro varchar2(5);
 ln_qtde_campos integer;
 l_colcnt integer;
 reg lista_campos;
 ln_doc int;
 ln_doc_cont int;
 blob_edit   BLOB; 
 ls_linha varchar2(32767);
 b_int binary_integer;
 c INTEGER;
 fdbk integer;
 ln_tamanho number;
 primeiro_registro1 boolean:=true;
 primeiro_registro2 boolean:=true;
 primeiro_registro3 boolean:=true;
 primeiro_registro4 boolean:=true;
 primeiro_registro5 boolean:=true;
 primeiro_registro6 boolean:=true;
 primeiro_registro7 boolean:=true;
 primeiro_registro8 boolean:=true;

 ls_query varchar2(2000);
 vtemp RAW(32000);
vend NUMBER := 1;
vlen NUMBER := 1;
vstart NUMBER := 1;

vend2 NUMBER := 1;
vlen2 NUMBER := 1;
vstart2 NUMBER := 1;
i number;
bytelen NUMBER := 32000;
ultimo_campo boolean;
registros number:=0;     
ln_id_proj number:=0;              
ln_id_ativ number:=0;              
ln_id_tar number:=0;              
ln_tipo  number:=0;
ln_id_atr  number:=0;              
ln_categ number:=0;
ls_tipo varchar2(1);
lb_erro boolean:=false;
lb_erro_ativ  boolean:=false;
blob_edit1             CLOB; 
blob_edit2             CLOB; 
blob_edit3             CLOB; 
blob_edit4             CLOB; 
blob_edit5             CLOB; 
blob_edit6             CLOB; 

TYPE t_dados IS VARRAY(100) OF varchar2(32000);
dados t_dados:=t_dados();

type    Array1D is table of Number;
type    Array2D is table of Array1D;
array   Array2D;
array2   Array2D;

begin

ls_seperador_campo:=chr(9);  -- TAB
ls_seperador_campo:=chr(35); -- #
ls_seperador_registro:=chr(13)||chr(10);
  
select conteudo into blob_edit
from documento_conteudo
where documento_id=ln_seq;

vlen:=dbms_lob.getlength(blob_edit);
bytelen := 32000;
vstart := 1;
vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);

begin
--vlen:=100;
WHILE vstart < vlen 
LOOP
--dbms_output.put_line('newline:'||vstart);
--dbms_output.put_line('newline:'||vend);
vlen2:=vend-vstart+1;
   dbms_lob.read(blob_edit,vlen2,vstart,vtemp);
   ls_linha:=utl_raw.cast_to_varchar2(vtemp);
    registros:=registros+1;
    
vend2 := 1;
--vlen2 := length(ls_linha);
--dbms_output.put_line('Linha text:'||ls_linha);
vstart2 := 1;
vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);

i:=1;     
ultimo_campo:=false;
WHILE vstart2 < vlen2 or ultimo_campo
LOOP
--dbms_output.put_line('len2:'||vlen2);
--dbms_output.put_line('start2:'||vstart2);
--dbms_output.put_line('vend2:'||vend2);

     select t_tipo_campos(sec,nome,tipo,tamanho,decimais,separador,formato,obrigatorio,opcoes,descricao)
     BULK COLLECT INTO reg     from table(f_lista_campos) where sec=i;

   ls_campo:=substr(ls_linha, vstart2, vend2-vstart2);
--   dbms_output.put_line('Campo:'||reg(1).sec||':'||reg(1).nome||' Tipo:'||reg(1).tipo||' Valor:'||ls_campo);
   dados.extend;
   dados(i):=replace(ls_campo,'''','''''');
   vstart2:=vend2+length(ls_seperador_campo);
  if not ultimo_campo then
     vend2 := nvl(instr(ls_linha, ls_seperador_campo,vstart2), vlen2);
  else
     ultimo_campo:=false;
  end if;


  if vend2 =0 then
    ultimo_campo:=true;
    vend2:=vlen2;
  end if;
i:=i+1;
END LOOP;


array := new Array2D(                  -- ordem , atributo
                                  Array1D(5,43),
                                  Array1D(6,16),
                                  Array1D(7,17),
                                  Array1D(9,15),
                                  Array1D(15,70),
                                  Array1D(18,71),
                                  Array1D(19,72),
                                  Array1D(20,73),
                                  Array1D(21,74),
                                  Array1D(22,75),
                                  Array1D(23,76),
                                  Array1D(17,80),
                                  Array1D(10,11),
                                  Array1D(11,2)
                                  
                     );   

array2 := new Array2D(                  -- ordem , atributo
                                  Array1D(2,7),
                                  Array1D(3,8),
                                  Array1D(4,9)
                                  
                     );   

   --------------------------------------
   -- Inicio do Processamento da Linha --
   --------------------------------------
--if registros < 1000 then

   if dados(1)='10' then -- PROJETOS

      lb_erro:=false;
      lb_erro_ativ:=false;
      
      begin

      select id into ln_id_proj from projeto
      where Titulo = dados(2)|| ' - ' || dados(3) and
           id >= (select id from projeto where titulo in ('PJ-NAC 1011 - Programa SENAI de Ações Inclusivas')) and
           id <= (select id from projeto where titulo in ('PJ-NAC 1028 - Apoio a estruturação de programa de capacitação de RH em normalização - 2010')) and
           exists (select * from ATRIBUTOENTIDADEVALOR a, categoria_item_atributo c
                      where c.atributo_id = 2 and
                            a.identidade = projeto.id and
                            a.tipoentidade = 'P' and
                            a.atributoid = 2 and
                            c.titulo like '2010%'||dados(11)||'-%' and
                            c.categoria_item_id = a.categoria_item_atributo_id);
                            
      dbms_output.put_line('   Projeto:'||ln_id_proj||' ('||dados(2)|| ' - ' || dados(3)||')');

      exception when no_data_found then
        ln_categ:=0;
          dbms_output.put_line('ERRO Linha:'||registros||' Não localizou projeto: '||dados(2)|| ' - ' || dados(3) || ' CR:'||dados(11));
          lb_erro:=true;
          ln_id_proj:=0;
        when others then
        ln_categ:=0;
          dbms_output.put_line('ERRO Linha:'||registros||' Localizou mais de um projeto: '||dados(2)|| ' - ' || dados(3)  || ' CR:'||dados(11));
          lb_erro:=true;
          ln_id_proj:=0;
     end; 

   end if;

   if (dados(1)='30' and not lb_erro and ln_id_proj>0 ) then -- INICIO Ativ
      lb_erro_ativ:=false;
      if length(trim(dados(2)))>150 then
        dados(2) := substr(trim(dados(2)),1,147) || '...' ;
      end if;
      begin
      ln_id_ativ:=0;
      select id into ln_id_ativ from atividade
      where Titulo like trim(dados(2))||'%' and
            projeto =ln_id_proj;
      exception when no_data_found then
      ln_id_ativ:=0;
          dbms_output.put_line('ERRO Linha:'||registros||' Não localizou Atividade: '||dados(2)|| ' - ' || dados(3) || ' CR:'||dados(11));
          lb_erro_ativ:=true;
          ln_id_proj:=0;
        when others then
          ln_id_ativ:=0;
          dbms_output.put_line('ERRO Linha:'||registros||' Localizou mais de uma Atividade: '||dados(2)|| ' - ' || dados(3)  || ' CR:'||dados(11));
          lb_erro_ativ:=true;
          ln_id_proj:=0;
     end; 
   
   end if;

   if (dados(1)='40' and not lb_erro and not lb_erro_ativ and ln_id_proj>0 ) then -- INICIO Tarefas

      
      if length(trim(dados(2)))>150 then
        dados(2) := substr(trim(dados(2)),1,147) || '...' ;
      end if;

      begin

      select id into ln_id_tar from tarefa
      where Titulo = dados(2) and
            tarefa.atividade = ln_id_ativ and
            projeto =ln_id_proj;

      update tarefa set
         datainicio=trunc(to_date(trim(dados(6)) ,'DD/MM/YYYY HH24:MI:SS')),
         prazoprevisto=trunc(to_date(trim(dados(7)) ,'DD/MM/YYYY HH24:MI:SS')),
         iniciorealizado=trunc(to_date(trim(dados(8)) ,'DD/MM/YYYY HH24:MI:SS')),
         prazorealizado=trunc(to_date(trim(dados(9)) ,'DD/MM/YYYY HH24:MI:SS')),
         tiporestricao=2, 
         datarestricao=trunc(to_date(trim(dados(6)) ,'DD/MM/YYYY HH24:MI:SS'))
      where id=ln_id_tar;

      dbms_output.put_line('      Tarefa:'||ln_id_tar|| ' (' ||dados(2) ||') Atualizada!'  );

      exception when no_data_found then
        ln_categ:=0;
          dbms_output.put_line('ERRO Linha:'||registros||' Não localizou tarefa: '||dados(2) );
        when others then
        ln_categ:=0;
          
          dbms_output.put_line('ERRO Linha:'||registros||' Localizou mais de uma tarefa: '||dados(2) ||' msg: '|| sqlerrm);
     end; 

   end if;  -- FIM Tarefas

 
--end if;
   --------------------------------------
   -- FIM do Processamento da Linha    --
   --------------------------------------

   vstart:=vend+length(ls_seperador_registro);
   vend:=nvl(DBMS_LOB.INSTR(blob_edit, utl_raw.cast_to_raw(ls_seperador_registro),vstart),vlen);
   dados:=t_dados();
END LOOP;

exception when others then
dbms_output.put_line('Erro linha:'||registros|| '  ' || sqlerrm);  
end;

ln_retorno:=registros;
--rollback;
end p_Acerto_Carga_Inicial;          

procedure p_Importa_View_Zeus(ls_diretorio varchar2, ln_retorno in out number)
is
 ls_campo              VARCHAR2(1000);
 ln_campo              number;
 ld_campo              date;
 ls_seperador_campo    varchar2(5);
 ls_seperador_registro varchar2(5);
 ln_qtde_campos        integer;
 l_colcnt              integer;
 reg                   lista_campos;
 ln_doc                int;
 ln_doc_cont           int;
 blob_edit             BLOB; 
 ls_linha              varchar2(32767);
 b_int                 binary_integer;
 c                     INTEGER;
 fdbk                  integer;
 ln_tamanho            number;
 primeiro_registro     boolean:=true;
 ls_query              varchar2(2000);
 vtemp                 RAW(32000);
 vend                  NUMBER := 1;
 vlen                  NUMBER := 1;
 vstart                NUMBER := 1;
 vend2                 NUMBER := 1;
 vlen2                 NUMBER := 1;
 vstart2               NUMBER := 1;
 i                     number;
 ln_proj               number:=0;
 bytelen               NUMBER := 32000;
 ultimo_campo          boolean;
 registros             number:=0;     
 ln_ce                 number:=0;
 ln_cl                 number:=0;
 TYPE t_dados IS VARRAY(100) OF varchar2(32000);
 dados t_dados:=t_dados();
 lb_erro boolean:=false;
 ln_categ number;
 ln_uo number;
 -- Modificado <Charles> Ini
 lf_rejeitados SYS.UTL_FILE.file_type;
 lf_log        SYS.UTL_FILE.file_type;
 ln_forma      number := 0;
 ln_tipo       number := 0;
 ln_cr         number := 0;
 ld_lancamento date;
 lv_mensagem   varchar2(4000);
 ld_data_hora  date;
 -- Modificado <Charles> Fim
 v_blob blob;
 ln_inseridos number:=0;
 ln_sinal number:=1;
ls_temp varchar2(10); 
begin
   dbms_output.put_line('Horário: ' || to_char(sysdate, 'hh24:mi:ss dd/mm/yyyy'));
  
   -- Modificado <Charles> - Ini  
   if ls_diretorio is not null then
     select sysdate into ld_data_hora from dual;
     lf_rejeitados := SYS.UTL_FILE.fopen (ls_diretorio, 'registros_rejeitados_' || 
                                      to_char(ld_data_hora, 'yyyymmddhh24miss') || '.txt', 'w');
     lf_log        := SYS.UTL_FILE.fopen (ls_diretorio, 'resultado_processamento_' || 
                                      to_char(ld_data_hora, 'yyyymmddhh24miss') || '.txt', 'w');
   end if;
   -- Modificado <Charles> - Fim 
   
   ls_seperador_campo:=chr(9);
   ls_seperador_registro:=chr(13)||chr(10);

   for c in (
        select 
        UNIDADE_COD,  MIN(ANO) ANO, MIN(DATA_FECHTO) DATA_FECHTO
        from VW_ZEUS d
/*        where exists
          (select p.id from projeto p, atributoentidadevalor aev, categoria_item_atributo cia, atributoentidadevalor aev2, uo u
                   where aev.identidade = p.id and 
                         aev.tipoentidade='P' and 
                         aev.atributoid=2 and
                         aev.categoria_item_atributo_id = cia.categoria_item_id and
                         cia.titulo like trim(to_char(d.ano))||' '||trim(substr(cr_cod,1,9))||'-%' and
                         
                         p.uo_id=u.id and
                         u.titulo like trim(to_char(d.ano))||trim(d.unidade_cod)||'%' and

                         aev2.identidade = p.id and 
                         aev2.tipoentidade='P' and 
                         aev2.atributoid=1 and
                         aev2.valornumerico=to_number(substr(cr_cod,10)))
  */      
        group by UNIDADE_COD
        )
   loop

----------------------------------------------------------
-- falta                                                --
----------------------------------------------------------
--falta filtrar o UO
--falta ver a questado do > ou >=  DT_FECHAMENTO
--falta analisar a questao do Débito - Credito
--falta descricao do lançamento (ficará em campo novo)
----------------------------------------------------------
--                                                      --
----------------------------------------------------------

        delete from baseline_custo_lancamento cl
        where cl.custo_lancamento_id in
        (select cl2.id from custo_lancamento cl2
         where cl2.tipo = 'R'
           and data > c.DATA_FECHTO
           and exists (select 1
                         from custo_entidade ce, projeto p, uo u
                        where ce.id = cl2.custo_entidade_id
                          and p.id = ce.entidade_id
                          and ce.tipo_entidade = 'P'
                          and p.uo_id = u.id and
                          u.titulo like trim(to_char(c.ano))||trim(c.unidade_cod)||'%'));
                          
        delete from custo_lancamento cl
         where cl.tipo = 'R'
           and data > c.DATA_FECHTO
           and exists (select 1
                         from custo_entidade ce, projeto p, uo u
                        where ce.id = cl.custo_entidade_id
                          and p.id = ce.entidade_id
                          and ce.tipo_entidade = 'P'
                          and p.uo_id = u.id and
                          u.titulo like trim(to_char(c.ano))||trim(c.unidade_cod)||'%');

        delete from baseline_custo_entidade ce
         where not exists (select 1 
                             from baseline_custo_lancamento cl
                            where cl.baseline_custo_entidade_id = ce.id);
         
        delete from custo_entidade ce
         where not exists (select 1 
                             from custo_lancamento cl
                            where cl.custo_entidade_id = ce.id);
   end loop;

   dbms_output.put_line('Horário: ' || to_char(sysdate, 'hh24:mi:ss dd/mm/yyyy'));

   -- SALVA DADOS da VIEW em BLOB --

  select documento_seq.nextval into ln_doc from dual;
  select documento_conteudo_seq.nextval into ln_doc_cont from dual;

  Insert into DOCUMENTO (DOCUMENTOID,DESCRICAO,
        TIPOENTIDADE,IDENTIDADE,AREAGERENCIA,ESTADODOCUMENTO,VERSAOATUAL,TIPODOCUMENTO,RESPONSAVEL,DOCUMENTO_PAI,TIPO_DOCUMENTO_ID,TAMANHO) 
  select ln_doc,'View Carregada em '||to_char(sysdate,'DD-MM-YYYY HH24-MI-SS'),
         null,null,null,'I',1,'.txt',null,null,null,null from dual;

  insert into documento_conteudo (id, documento_id, versao, conteudo)
  values (ln_doc_cont, ln_doc, 1, empty_blob());-- returning conteudo into blob_edit;

  DBMS_LOB.CREATETEMPORARY(v_blob,TRUE);


  ls_linha:='DATA_LANCTO'||  ls_seperador_campo ||'ANO'||  ls_seperador_campo ||'UNIDADE_COD'||  ls_seperador_campo ||'CR_COD'||  ls_seperador_campo ||'CONTA_COD'||  ls_seperador_campo ||'VALOR'||  ls_seperador_campo ||'DESCRICAO'||  ls_seperador_campo ||'DEB_CRED'||  ls_seperador_campo ||'DATA_FECHTO'||ls_seperador_registro;
  b_int:=utl_raw.length (utl_raw.cast_to_raw(ls_linha));
  dbms_lob.write(v_blob, b_int, 1, utl_raw.cast_to_raw(ls_linha));

  dbms_output.put_line('Horário: ' || to_char(sysdate, 'hh24:mi:ss dd/mm/yyyy'));

   for c in (
       select 
        DATA_LANCTO, ANO, MES, EMPRESA_COD, UNIDADE_COD, 
        CR_COD,	CONTA_COD, CONTA_COD_CTB,	VALOR,	
        DESCRICAO, DEB_CRED, DATA_FECHTO
        from VW_ZEUS d
/*        where exists
          (select p.id from projeto p, atributoentidadevalor aev, categoria_item_atributo cia, atributoentidadevalor aev2, uo u
                   where aev.identidade = p.id and 
                         aev.tipoentidade='P' and 
                         aev.atributoid=2 and
                         aev.categoria_item_atributo_id = cia.categoria_item_id and
                         cia.titulo like trim(to_char(d.ano))||' '||trim(substr(cr_cod,1,9))||'-%' and
                         
                         p.uo_id=u.id and
                         u.titulo like trim(to_char(d.ano))||trim(d.unidade_cod)||'%' and

                         aev2.identidade = p.id and 
                         aev2.tipoentidade='P' and 
                         aev2.atributoid=1 and
                         aev2.valornumerico=to_number(substr(cr_cod,10)))
*/

/* dados de teste
       select 
        sysdate+level DATA_LANCTO, 2010	ANO, 6	MES, 3	EMPRESA_COD, '100'	UNIDADE_COD, 
        '10102010102'	CR_COD,	'31010314' CONTA_COD, '31010314'	CONTA_COD_CTB,	17.74*level VALOR,	
        'Importado do Sistema de Almoxarifado' DESCRICAO, case when level<10 then 'C' else 'D' end DEB_CRED, sysdate-1 	DATA_FECHTO
        from dual CONNECT BY level <= 20 */
     )
   loop

    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados.extend;
    dados(2):='3';
    dados(3):=to_char(c.ano);
    dados(6):=trim(to_char(c.ano))||trim(c.unidade_cod);
    dados(7):=trim(c.cr_cod);
    dados(8):=trim(c.conta_cod);
    dados(9):='1';
    dados(10):=trim(c.valor);
    dados(16):=to_char(c.DATA_LANCTO,'DD/MM/YYYY');
    dados(12):=trim(c.DESCRICAO);
    dados(17):=trim(c.DEB_CRED);
    dados(18):=to_char(c.DATA_FECHTO,'DD/MM/YYYY');

    ls_linha:= dados(16) || ls_seperador_campo || 
            dados(3) ||  ls_seperador_campo ||
            dados(6) ||  ls_seperador_campo ||
            dados(7) ||  ls_seperador_campo ||
            dados(8) ||  ls_seperador_campo ||
            dados(10) || ls_seperador_campo ||
            dados(12) || ls_seperador_campo ||
            dados(17) || ls_seperador_campo ||
            dados(18) || ls_seperador_registro;

   registros:=registros+1;
   --------------------------------------
   -- Início do Processamento da Linha --
   --------------------------------------
   -- dbms_output.put_line(dados(1)||dados(2)||dados(3));
   -- Dados prontos para serem trabalhados
   lb_erro:=false;
         if dados(2)='3' then -- Realizado
           
            -- Para identificar o projeto, identificar por 3 valores
            -- 1. Projeto deve ser da UO 
            -- 2. Atributo 2 deve ter 'YYYY XXXXXX' onde YYYY é o ano do orçamento e XXXXXX são os 6 primeiras posicoes do Centro de Resposabilidade 
            -- 3. Atributo 1 deve ter o sequencial posicao a partir da 7 do Centro de Responsabilidade

            dados(3):=trim(dados(3));
            dados(4):=trim(dados(4));
            dados(6):=trim(dados(6));
            dados(7):=trim(dados(7));
            dados(16):=trim(dados(16));
            dados(8):=dados(3)|| ' '|| trim(dados(8));

            if to_number(dados(9))=0 then
              dados(9):='1';
            end if;

            begin
             select ci.categoria_item_id into ln_categ
                    from categoria_item_atributo ci
                    where ci.titulo like dados(3)|| ' ' || substr(dados(7),1,9) ||'-%' and
                          ci.atributo_id=2;

              exception when no_data_found then
                ln_categ:=0;
                  lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Atributo Centro Responsabilidade não localizado: '||chr(9)||dados(3)||' '|| substr(dados(7),1,9);
                  dbms_output.put_line(lv_mensagem);
                  SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  lb_erro:=true;
                when others then
                ln_categ:=0;
                  lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Atributo Centro Responsabilidade localizou mais de 1 CR: '||chr(9)||dados(3)|| ' ' || substr(dados(7),1,9);
                  dbms_output.put_line(lv_mensagem);
                  SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  lb_erro:=true;
             end; 


            begin
             select u.id into ln_uo from uo u where u.titulo like dados(6)||'%';

              exception when no_data_found then
                ln_uo:=0;
                  lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' UO não localizado: '||chr(9)||dados(6);
                  dbms_output.put_line(lv_mensagem);
                  SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  lb_erro:=true;
                when others then
                ln_uo:=0;
                  lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Localizou mais de 1 UO: '||chr(9)||dados(3)|| ' ' || dados(6);
                  dbms_output.put_line(lv_mensagem);
                  SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  lb_erro:=true;
             end; 

           if (not lb_erro) then
            begin
--dbms_output.put_line(dados(7)||'-'||ln_categ||'-'||ln_uo);
            select id into ln_proj from projeto p
            where p.uo_id = ln_uo  and
                  exists (select *
                from atributoentidadevalor aev--, categoria_item_atributo cia
                   where aev.identidade = p.id and 
                         aev.tipoentidade='P' and 
                         aev.atributoid=2 and
                         aev.categoria_item_atributo_id = ln_categ
                         --cia.atributo_id=2 and
                         --substr(cia.Titulo,6,instr(cia.Titulo,'-')-6) = dados(3)|| ' ' || substr(dados(7),1,9) and
                         --aev.categoria_item_atributo_id = cia.categoria_item_id
                         ) and
                   exists (select *
                from atributoentidadevalor aev 
                   where aev.identidade = p.id and 
                         aev.tipoentidade='P' and 
                         nvl(aev.Valor, aev.ValorNumerico)= to_number(substr(dados(7),10)) and
                         aev.atributoid=1);
            exception when no_data_found then
                lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Não foi localizado Projeto com Atributo Centro Responsabilidade: '||chr(9)||dados(3)|| ' ' || substr(dados(7),1,9) ||chr(9)|| ' Atributo_SEQ:'||chr(9)|| substr(dados(7),10)||chr(9) || ' UO: '||chr(9)||dados(6)||chr(9)|| ' COD_CR:'||chr(9)||ln_categ || chr(9)||' COD_UO:'||chr(9)||ln_uo;
                dbms_output.put_line(lv_mensagem);
                SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                lb_erro:=true;
              when others then
                lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Existe mais de um Projeto com Atributo Centro Responsabilidade: '||chr(9)||dados(3)|| ' ' || substr(dados(7),1,9) ||chr(9)|| ' Atributo_SEQ:'||chr(9)|| substr(dados(7),10)||chr(9) || ' UO: '||chr(9)||dados(6)||chr(9)|| ' COD_CR:'||chr(9)||ln_categ ||chr(9)|| ' COD_UO:'||chr(9)||ln_uo;
                dbms_output.put_line(lv_mensagem);
                SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                lb_erro:=true;
           end; 
           end if;
           
           if (not lb_erro) then

            select nvl(min(ce.id),0) into ln_ce from custo_entidade ce, custo_receita cr
            where ce.tipo_entidade = 'P' and
                  ce.custo_receita_id = cr.id and
                  ce.entidade_id = ln_proj and
                  cr.titulo = 'Realizado Zeus'; -- Realizado Zeus
                        
             begin
              select case when tipo='C' and dados(17)='C' then -1
                                    when tipo='R' and dados(17)='D' then -1
                                    else 1 end
                into ln_sinal
                from custo_receita
               where titulo like dados(8)||' %'; -- conta contabil 

            exception when no_data_found then
                lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Não foi localizado Conta Custo Receita: '||chr(9)||dados(8);
                dbms_output.put_line(lv_mensagem);
                SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                lb_erro:=true;
              when others then
                lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Erro. A Conta Custo Receita deve ser única: '||chr(9)||dados(8);
                dbms_output.put_line(lv_mensagem);
                SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                lb_erro:=true;
             end;

            -- Modificado <Charles> Ini
            if ln_ce = 0 and not lb_erro then   

/*
Se DEB_CRED = D e conta de despesa (3) = sinal POSITIVO antes do valor 
Se DEB_CRED = C e conta de despesa (3) = sinal NEGATIVO antes do valor 
Se DEB_CRED = D e conta de receita (4) = sinal NEGATIVO antes do valor 
Se DEB_CRED = C e conta de receita (4) = sinal POSITIVO antes do valor 
*/

                       
             begin
              select id
                into ln_cr
                from custo_receita
               where titulo like dados(8)||' %'; -- conta contabil 


            exception when no_data_found then
                lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Não foi localizado Conta Custo Receita: '||chr(9)||dados(8);
                dbms_output.put_line(lv_mensagem);
                SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                lb_erro:=true;
              when others then
                lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' Erro. A Conta Custo Receita deve ser única: '||chr(9)||dados(8);
                dbms_output.put_line(lv_mensagem);
                SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                lb_erro:=true;
             end;
               
              if ln_cr > 0 and not lb_erro then  
           
                select min(forma_id)
                  into ln_forma
                  from (select *
                          from custo_receita_forma 
                         where custo_receita_id = ln_cr
                         order by decode(vigente, 'Y', 1, 2), decode (valor_default,'Y', 1, 2))
                 where rownum = 1;
                 
                select min(tipo_id)
                  into ln_tipo
                  from (select *
                          from custo_receita_tipo
                         where custo_receita_id = ln_cr
                         order by decode(vigente, 'Y', 1, 2), decode (valor_default,'Y', 1, 2))
                 where rownum = 1; 
               
                select custo_entidade_seq.nextval into ln_ce from dual;
                
                insert into custo_entidade (id, tipo_entidade, entidade_id, custo_receita_id, titulo, 
                                            tipo_despesa_id, forma_aquisicao_id)
                       values (ln_ce, 'P', ln_proj, ln_cr, 'Realizado Zeus', ln_tipo, ln_forma);
              end if;
            end if;
            -- Modificado <Charles> Fim
            
            if ln_ce > 0 and not lb_erro then
                                          
                  -- Modificado <Charles> Ini
                  ld_lancamento := to_date(dados(16),'DD/MM/YYYY');
/*                  begin
                    ld_lancamento := to_date('01'||trim(to_char(to_number(dados(4)),'00'))||dados(3), 'ddmmyyyy');
                    -- Coloca no último dia do mês
                    ld_lancamento := add_months(ld_lancamento, 1) - 1;
                  exception
                    when others then
                      ld_lancamento := null;
                  end;*/
                  --dbms_output.put_line('DEBUG: ' || to_char(ld_lancamento, 'dd/mm/yyyy'));
                  -- Modificado <Charles> Fim
/*                  
                  select nvl(max(id),0) into ln_cl from custo_lancamento 
                  where custo_entidade_id = ln_ce and
                        tipo = 'R' and
                        situacao = 'V' and
                        trunc(data) = trunc(ld_lancamento);

                  if ln_cl=0 then*/
                      begin
                        select custo_lancamento_seq.nextval into ln_cl from dual;
                        insert into custo_lancamento (ID, CUSTO_ENTIDADE_ID, TIPO, SITUACAO,
                                                      DATA, 
                                                      VALOR,
                                                      QUANTIDADE, 
                                                      VALOR_UNITARIO, 
                                                      USUARIO_ID, DATA_ALTERACAO, DESCRICAO)
                            values (ln_cl, ln_ce, 'R', 'V',
                                    ld_lancamento,
                                    to_number(dados(10))*ln_sinal, -- valor
                                    to_number(dados(9)), -- quantidade
                                    (to_number(dados(10))*ln_sinal)/to_number(dados(9)), -- valor unitario,
                                    '310', 
                                    sysdate,
                                    trim(dados(12)));  -- 
                       lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' OK - Registro Inserido - Conta:'||dados(8);
                       dbms_output.put_line(lv_mensagem);
                       ln_inseridos:=ln_inseridos+1;
                       SYS.UTL_FILE.put_line(lf_log, lv_mensagem); 
                     exception
                       when others then
                         lv_mensagem := 'Linha:'||chr(9)||' Erro ao incluir: [' || sqlerrm || ']';
                         dbms_output.put_line(lv_mensagem);
                         SYS.UTL_FILE.put_line(lf_log, lv_mensagem); 
                     end;           
/*
                  else
                  -- dbms_output.put_line('Já existe Custo Lançamento para Lançamento para Conta:'||dados(14)||' Projeto:'|| '???' ||' Data:'||substr(dados(16),1,10)|| ' Linha não importada:'||registros);
                  -- se ja existe, acrescenta
                  begin
                    update custo_lancamento
                       set VALOR=VALOR+to_number(dados(10)),
                           QUANTIDADE=QUANTIDADE+to_number(dados(9)), 
                           VALOR_UNITARIO=(VALOR+to_number(dados(10)))/(QUANTIDADE+to_number(dados(9))), 
                           USUARIO_ID='310',
                           DATA_ALTERACAO=sysdate
                    where custo_entidade_id = ln_ce and
                          tipo = 'R' and
                          situacao = 'V' and
                          trunc(data) = trunc(ld_lancamento);

                       lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||' OK - Registro Atualizado - Conta:'||dados(8);
                       dbms_output.put_line(lv_mensagem);
                       SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
                  exception
                    when others then
                      lv_mensagem := 'Linha:'||chr(9)||' Erro ao atualizar: [' || sqlerrm || ']';
                      dbms_output.put_line(lv_mensagem);
                      SYS.UTL_FILE.put_line(lf_log, lv_mensagem); 
                  end;
                  end if;*/
            elsif not lb_erro then
               -- Modificado <Charles>
               lb_erro:=true;
               
               lv_mensagem := 'Linha:'||chr(9)||registros||chr(9)||'Não foi localizado Custo Entidade para Conta:'||chr(9)||dados(8)||chr(9)||' Projeto:'||chr(9)||ln_proj;
               dbms_output.put_line(lv_mensagem);
               SYS.UTL_FILE.put_line(lf_log, lv_mensagem);
            end if;
            end if;
         end if;
   
   -- Modificado <Charles> - Ini
   -- Grava registro nao processado no arquivo de output
   if lb_erro then
     SYS.UTL_FILE.put_line(lf_rejeitados, ls_linha);
   end if;
   -- Modificado <Charles> - Fim
   
   --------------------------------------
   -- FIM do Processamento da Linha --
   --------------------------------------

   -- SALVA linha de dados da VIEW em BLOB --
    b_int:=utl_raw.length (utl_raw.cast_to_raw(ls_linha));
    dbms_lob.writeappend(v_blob, b_int , utl_raw.cast_to_raw(ls_linha));

    if mod(registros,10)= 0 then
     commit;
    end if;
     
   dados:=t_dados();
   END LOOP;

  -- salva CLOB no documento
  update documento_conteudo
  set conteudo = v_blob
  where id=ln_doc_cont;
   
 -- Modificado <Charles>
 lv_mensagem := 'Registros Processados: '|| registros;
 dbms_output.put_line(lv_mensagem);
 SYS.UTL_FILE.put_line(lf_log, lv_mensagem);

 lv_mensagem := 'Registros Inseridos: '|| ln_inseridos;
 dbms_output.put_line(lv_mensagem);
 SYS.UTL_FILE.put_line(lf_log, lv_mensagem);

 
 SYS.UTL_FILE.fclose(lf_rejeitados);
 SYS.UTL_FILE.fclose(lf_log);
 ln_retorno:=registros;
 dbms_output.put_line('Horário: ' || to_char(sysdate, 'hh24:mi:ss dd/mm/yyyy'));

end p_Importa_View_Zeus;

PROCEDURE p_Exporta_Arquivo_CNI(ls_tipo varchar2, ln_arquivo in out number, ln_retorno in out number) AS

 ls_diretorio  varchar2(100):='IMPORTACAO_TRACEGP';
 ls_campo              VARCHAR2(2000);
 ln_campo              number;
 ld_campo              date;
 ls_seperador_campo    varchar2(5);
 ls_seperador_registro varchar2(5);
 ln_qtde_campos        integer;
 l_colcnt              integer;
 reg                   lista_campos;
 ln_doc                int;
 ln_doc_cont           int;
 blob_edit             BLOB; 
 ls_linha              varchar2(32767);
 b_int                 binary_integer;
 c                     INTEGER;
 fdbk                  integer;
 ln_tamanho            number;
 primeiro_registro     boolean:=true;
 ls_query              varchar2(32000);
 ld_data_hora          date;
 ln_registros          number:=0;
 
    v_buffer       RAW(32767);
    v_buffer_size  BINARY_INTEGER;
    v_amount       BINARY_INTEGER;
    v_offset       NUMBER(38) := 1;
    v_chunksize    INTEGER;
    v_out_file     UTL_FILE.FILE_TYPE;

begin

--ls_tipo = 'CTB' ou 'DOF'

/*

x=atributo do valor
y1=estado atual
y2=estado novo
z=formulario
w=DATA_PAGAMENTO
v=DATA_Liberacao/vencimento/provisao
a=conta fluxo
b=conta contabil
c=lista de estados: Liberado, gerado, pago

select 'A','I','TRACE','1','Trace',null,
            -- Atributo da Demanda
            (select av.valordata from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--v
            ) Data,
            -- Atributo da Demanda
            (select av.valornumerico from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--x
            ) Valor ,
            null,null,null,
            sysdate,
            (select av.valordata from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--v
            ) Data2,
            null,null,null,null,null,
            (select av.valor from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--a
            ) Cta_Fluxo ,
            (select av.valor from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--b
            ) Cta_Contabil ,
            'UU100',null,
           (select trim(max(u2.titulo)) || ' - '||p.titulo || ' - '|| to_char(sum(case when situacao in (1,2,3) -- c lista de estados: Liberado, gerado, pago
            then 1 else 0 end))||'/'||to_char(sum(1)) 
             from demanda d2, solicitacaoentidade se2, uo u2
                 where se2.solicitacao = d2.demanda_id 
                   and se2.projeto = se.projeto 
                   and u2.id = p.uo_id
                   and d2.formulario_id = 1), --z),
            (select uo.titulo from uo where uo.id = p.uo_id) UO,
            (select cia.titulo
                from atributoentidadevalor aev, categoria_item_atributo cia
                   where aev.identidade = p.id and 
                         aev.tipoentidade='P' and 
                         aev.atributoid=2 and
                         aev.categoria_item_atributo_id = cia.categoria_item_id) CR,
            null,null,null,null,null,null,null,sysdate
from demanda d, solicitacaoentidade se, projeto p
where  se.solicitacao = d.demanda_id 
  and se.projeto = p.id 
  and d.situacao = 1 --y1
  and d.formulario_id = 1 --z

*/

  select count(*) INTO c 
      from estado_regra_condicional where estado_id = 1--y2 
                                    and formulario_id =1;-- z;
                                    
  if c>0 then
--   ls_erro:='Erro. Foi configurado alguma regra condicional para os Estado. Abortado';
   ln_retorno:=-1;
   return;
  end if;

 ls_query:='
      select ''A'',''I'',''TRACE'',''1'',''Trace'',null,
            -- Atributo da Demanda
            (select av.valordata from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--v
            ) Data,
            -- Atributo da Demanda
            (select av.valornumerico from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--x
            ) Valor ,
            null,null,null,
            sysdate,
            (select av.valordata from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--v
            ) Data2,
            null,null,null,null,null,
            (select av.valor from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--a
            ) Cta_Fluxo ,
            (select av.valor from atributo_valor av where av.demanda_id=d.demanda_id and av.atributo_id=1--b
            ) Cta_Contabil ,
            ''UU100'',null,
           (select trim(max(u2.titulo)) || '' - ''||p.titulo || '' - ''|| to_char(sum(case when situacao in (1,2,3) -- c lista de estados: Liberado, gerado, pago
            then 1 else 0 end))||''/''||to_char(sum(1)) 
             from demanda d2, solicitacaoentidade se2, uo u2
                 where se2.solicitacao = d2.demanda_id 
                   and se2.projeto = se.projeto 
                   and u2.id = p.uo_id
                   and d2.formulario_id = 1), --z)
            (select uo.titulo from uo where uo.id = p.uo_id) UO,
            (select cia.titulo
                from atributoentidadevalor aev, categoria_item_atributo cia
                   where aev.identidade = p.id and 
                         aev.tipoentidade=''P'' and 
                         aev.atributoid=2 and
                         aev.categoria_item_atributo_id = cia.categoria_item_id) CR,
            null,null,null,null,null,null,null,sysdate
      from demanda d, solicitacaoentidade se, projeto p
      where  se.solicitacao = d.demanda_id 
         and se.projeto = p.id ';
--         and d.situacao = 1 --y1
--         and d.formulario_id = 1 --z';

--if 1>2 then PULA TUDO

  DBMS_LOB.CREATETEMPORARY(blob_edit,TRUE);
   
  ls_seperador_campo:=chr(9);
  ls_seperador_registro:=chr(13)||chr(10);
  c := DBMS_SQL.OPEN_CURSOR;

  DBMS_SQL.PARSE (c, ls_query, DBMS_SQL.NATIVE);

  select count(*) into ln_qtde_campos  from table(f_lista_campos_DOF);

  FOR i IN 1 .. ln_qtde_campos
    LOOP

     select t_tipo_campos(sec,nome,tipo,tamanho,decimais,separador,formato,obrigatorio,opcoes,descricao)
     BULK COLLECT INTO reg     from table(f_lista_campos_DOF) where sec=i;

      BEGIN
        if reg(1).tipo='char' or reg(1).tipo='fixo' then
           DBMS_SQL.define_column(c, i, ls_campo, 2000);
        end if;
        if reg(1).tipo='number' then
           DBMS_SQL.define_column(c, i, ln_campo);
        end if;
        if reg(1).tipo='date' then
           DBMS_SQL.define_column(c, i, ld_campo);
        end if;        

        l_colcnt := i;
      EXCEPTION
        WHEN OTHERS THEN
          IF (SQLCODE = -1007)
          THEN
            EXIT;
          ELSE
            RAISE;
          END IF;
      END;
    END LOOP; 
   DBMS_SQL.define_column(c, 1, ls_campo, 2000);
   fdbk:= DBMS_SQL.EXECUTE (c); 

 LOOP
  EXIT WHEN(DBMS_SQL.fetch_rows(c) <= 0); 

  ls_linha:='';


  FOR i IN 1 .. ln_qtde_campos
      LOOP
     select t_tipo_campos(sec,nome,tipo,tamanho,decimais,separador,formato,obrigatorio,opcoes,descricao)
     BULK COLLECT INTO reg     from table(f_lista_campos_DOF) where sec=i;

     if reg(1).tipo='char' then
        DBMS_SQL.COLUMN_VALUE(c, i, ls_campo);
        if reg(1).formato='X' THEN
           ls_linha := ls_linha || substr(ls_campo,1,reg(1).tamanho);
        end if;
        if reg(1).formato='X ' THEN
           ls_linha := ls_linha || rpad(substr(ls_campo,1,reg(1).tamanho),reg(1).tamanho,' ');
        end if;
        if reg(1).formato=' X' THEN
           ls_linha := ls_linha || lpad(substr(ls_campo,1,reg(1).tamanho),reg(1).tamanho,' ');
        end if;
        end if;
     if reg(1).tipo='fixo' then
        ls_linha := ls_linha || reg(1).formato;
     end if;
     if reg(1).tipo='date' then
        DBMS_SQL.COLUMN_VALUE(c, i, ld_campo);
        ls_linha := ls_linha || to_char(ld_campo,reg(1).formato);
     end if;
     if reg(1).tipo='number' then
        DBMS_SQL.COLUMN_VALUE(c, i, ln_campo);
        ls_linha := ls_linha || to_char(ln_campo,reg(1).formato);
     end if;

     if i <> ln_qtde_campos then
        ls_linha :=ls_linha || ls_seperador_campo;
     else
        ls_linha :=ls_linha || ls_seperador_registro;
     end if;
        
      END LOOP;    

    b_int:=utl_raw.length (utl_raw.cast_to_raw(ls_linha));

    ln_registros:=ln_registros+1;
    
    if (primeiro_registro) then
      dbms_lob.write(blob_edit, b_int, 1, utl_raw.cast_to_raw(ls_linha));
      primeiro_registro:=false;
    else
      dbms_lob.writeappend(blob_edit, b_int , utl_raw.cast_to_raw(ls_linha));
    end if;

 END LOOP;

  update demanda
  set situacao = 1--y2
  where situacao = 1--y1 
    and formulario_id = -1; --z';

 select documento_seq.nextval into ln_doc from dual;
 select documento_conteudo_seq.nextval into ln_doc_cont from dual;

 Insert into DOCUMENTO (DOCUMENTOID,DESCRICAO, TIPOENTIDADE,IDENTIDADE,
                        AREAGERENCIA,ESTADODOCUMENTO,VERSAOATUAL,TIPODOCUMENTO,
                        RESPONSAVEL,DOCUMENTO_PAI,TIPO_DOCUMENTO_ID,TAMANHO) 
 select ln_doc,'DOF Exportado em '||to_char(sysdate,'DD-MM-YYYY HH24-MI-SS'),null,null,
        null,'I',1,'.txt',
        null,null,null,null 
     from dual;

 insert into documento_conteudo (id, documento_id, versao, conteudo)
 values (ln_doc_cont, ln_doc, 1, empty_blob());-- returning conteudo into blob_edit;

 update documento_conteudo
 set conteudo = blob_edit
 where id=ln_doc_cont;

-- Salva em Arquivo Inicio

  select sysdate into ld_data_hora from dual;
  v_chunksize := DBMS_LOB.GETCHUNKSIZE(blob_edit);

    IF (v_chunksize < 32767) THEN
        v_buffer_size := v_chunksize;
    ELSE
        v_buffer_size := 32767;
    END IF;

    v_amount := v_buffer_size;

--    DBMS_LOB.OPEN(v_lob_loc, DBMS_LOB.LOB_READONLY);

    v_out_file := UTL_FILE.FOPEN(
        location      => ls_diretorio, 
        filename      => ls_tipo || '_Trace_para_Zeus_' || to_char(ld_data_hora, 'yyyymmddhh24miss') || '.txt', 
        open_mode     => 'w',
        max_linesize  => 32767);

    WHILE v_amount >= v_buffer_size
    LOOP

      DBMS_LOB.READ(
          lob_loc    => blob_edit,
          amount     => v_amount,
          offset     => v_offset,
          buffer     => v_buffer);

      v_offset := v_offset + v_amount;

      UTL_FILE.PUT_RAW (
          file      => v_out_file,
          buffer    => v_buffer,
          autoflush => true);

      UTL_FILE.FFLUSH(file => v_out_file);


    END LOOP;

    UTL_FILE.FFLUSH(file => v_out_file);

    UTL_FILE.FCLOSE(v_out_file);

    -- +-------------------------------------------------------------+
    -- | CLOSING THE LOB IS MANDATORY IF YOU HAVE OPENED IT          |
    -- +-------------------------------------------------------------+
--    DBMS_LOB.CLOSE(blob_edit);

-- Salva em Arquivo Fim


 dbms_lob.FREETEMPORARY(blob_edit);

 DBMS_SQL.CLOSE_CURSOR (c);
 ln_arquivo:=ln_doc;

--end if; PULA TUDO
-- ln_arquivo:=1000;
 ln_retorno:=ln_registros;
-- raise_application_error(-20001, 'Erro indefinido para testes');

end p_Exporta_Arquivo_CNI;

END PCK_DOCUMENTO;
/

--
declare
  ln_tela  number;
  ln_conta number;

begin
  select count(1)
    into ln_conta
    from tela
   where codigo = 'GERENCIAMENTO_RECURSO';
   
  if ln_conta = 0 then
    select max(telaid)+1 into ln_tela from tela;
    insert into tela (telaid,nome,url,visivel,grupoid,ordem,codigo,subgrupo,atalho)
	       values (ln_tela,'bd.tela.gerenciamentoRecurso','GerenciamentoRecurso.do?command=defaultAction',
                 'S',6,10,'GERENCIAMENTO_RECURSO','PRIMEIRO','N'); 
  end if;
  
  commit;
end;
/

CREATE OR REPLACE PACKAGE PCK_VALIDA_DEMANDA AS
       procedure executa(p_usuario varchar2, p_demanda_id varchar2, p_proximo_estado varchar2, ret in out varchar2);
       function F_VERIFICA_PERM_EDICAO_DEMANDA(pusuario_id varchar2, pdemanda_id varchar2, vpossuiPermissao in out varchar2, pregra_id number) return varchar2;
       function F_VERIFICA_ITENS_TRANSICAO_DEM (pdemanda_id varchar2, pestado_destino varchar2) return varchar2;
       function F_VERIFICA_PERM_CAMPOS_DEMANDA(pusuario_id varchar2, pdemanda_id varchar2) return varchar2;
       function F_VERIFICA_PERM_ATR_DEMANDA(pusuario_id varchar2, pdemanda_id varchar2) return varchar2;
       procedure p_verifica_campos_e_atributos(pusuario_id varchar2, pdemanda_id varchar2, pagendamento_id varchar2, ret in out varchar2);

end PCK_VALIDA_DEMANDA;
/

CREATE OR REPLACE PACKAGE BODY "PCK_VALIDA_DEMANDA" as

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
             select count(*) into contador2
             from demanda de, destino_usuario du
             where demanda_id = dom.demanda_id
             and de.destino_id = du.destino
             and du.usuario = pusuario_id;
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

             select count(*) into contador
              from atributo_valor av
              where av.atributo_id = dom.atributoid
              and demanda_id = dom.demanda_id;

              dbms_output.put_line('atributo ::::::::::::: '|| dom.atributoid);

             if dom.regra_id is not null and pusuario_id is not null then
                 v_retorno_qualquer := f_verifica_perm_edicao_demanda(pusuario_id, dom.demanda_id, v_permissao_campo, dom.regra_id);
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

-- Create table
create table AGENDA_PERFIL (
  ID        NUMBER(10)  not null,
  PERFIL_ID NUMBER(10)  not null,
  ABA_ID    VARCHAR2(1) not null,
  VISIVEL   VARCHAR2(1) default 'Y',
constraint PK_AGENDA_PERFIL primary key (id) using index tablespace &CS_TBL_IND
)tablespace &CS_TBL_DAT;

create sequence AGENDA_PERFIL_SEQ
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache;
       
create table AGENDA_USUARIO (
  ID         NUMBER(10) not null,
  USUARIO_ID VARCHAR2(50) not null,
  ABA_ID     VARCHAR2(1) not null,
  VISIVEL    VARCHAR2(1) default 'Y',
constraint PK_AGENDA_USUARIO primary key (ID) using index tablespace &CS_TBL_IND
)tablespace &CS_TBL_DAT;

create sequence AGENDA_USUARIO_SEQ
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache;
       
update configuracoes
   set aloc_automatica_tarefa_avulsa = 'Y',
       regra_aloc_tarefa_avulsa = 6;
commit;
/  


-------------------------------------------------------------------------------
-- Finalização
-------------------------------------------------------------------------------

insert into versao(id, titulo, patch, versao_tgp_id, comentario)
       values (versao_seq.nextval, '6.0.0', '11', 3, 'Aplicação de patch');
commit;
/

begin
  pck_processo.precompila;
  commit;
end;
/
                      
select * from v_versao;
/
