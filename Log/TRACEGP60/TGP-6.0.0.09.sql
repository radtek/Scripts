/*****************************************************************************\
* TraceGP 6.0.0.09                                                            *
\*****************************************************************************/
define CS_TBL_DAT = &TABLESPACE_DADOS;
define CS_TBL_IND = &TABLESPACE_INDICES;

------------------------------------------------------------------------------
UPDATE REGRAS_TIPO_PROPRIEDADE
SET WHERE_JOIN = '[ENTIDADE-PAI].ID = [ENTIDADE-FILHA].PROJETOID'
WHERE ID = 648;


UPDATE REGRAS_TIPO_PROPRIEDADE
   SET COLUNA = 'USUARIOID'
 WHERE ID = 658;
 
UPDATE REGRAS_TIPO_PROPRIEDADE
   SET COLUNA = 'PAPELID'
 WHERE ID = 659;
 
insert into detalhe_disponivel_info 
       values (210, 'label.prompt.camposSemTabelaHtml', 29, 'S', 'SEM_TABELA_HTML', 1);

update regras_tipo_propriedade set coluna = 'VALOR' where id = 550;
update regras_tipo_propriedade set coluna = 'VALOR' where id = 553;
update regras_tipo_propriedade set coluna = 'VALOR' where id = 549;
update regras_tipo_propriedade set coluna = 'VALOR' where id = 552;
update regras_tipo_propriedade set coluna = 'VALOR' where id = 551;
update regras_tipo_propriedade set coluna = 'VALOR' where id = 554;
update regras_tipo_propriedade set coluna = 'VALOR' where id = 549;
update regras_tipo_propriedade set coluna = 'DOMINIO_ATRIBUTO_ID' where id = 663;
update regras_tipo_propriedade set where_join = '[ENTIDADE-PAI].ID = [ENTIDADE-FILHA].PROJETOID' where id = 647;

insert into PERMISSAO_MAPA_ESTRATEGICO (ID, CODIGO, LABEL, MAPA, PERSPECTIVA, OBJETIVO, INDICADOR, PAPEL)
   values (20, 'EDITAR_AVALIACAO', 'label.prompt.editarAvaliacao', 'N', 'N', 'Y', 'N', 'N');

update regras_tipo_propriedade 
   set where_join = '[ENTIDADE-PAI].ID = [ENTIDADE-FILHA].CUSTO_ENTIDADE_ID (+) ' 
 where id = 270;
update regras_tipo_propriedade 
   set where_join = '[ENTIDADE-PAI].ID = [ENTIDADE-FILHA].IDENTIDADE (+)  AND [ENTIDADE-FILHA].TIPOENTIDADE (+)  = ''C'''
 where id = 662;

commit;
/

------------------------------------------------------------------------------
alter table RELAT_RELATORIO_COMPONENTE add nivel varchar2(4000);
alter table RELAT_RELATORIO_COMPONENTE add data_inicio varchar2(4000);
alter table RELAT_RELATORIO_COMPONENTE add data_fim varchar2(4000);
alter table RELAT_RELATORIO_COMPONENTE add tipo_gantt varchar2(30);
alter table RELAT_RELATORIO_COMPONENTE add cor_gantt varchar2(4000);
alter table RELAT_RELATORIO_COMPONENTE add etapas_gantt varchar2(4000);
alter table RELAT_RELATORIO_COMPONENTE add percentual_gantt varchar2(4000);

alter table agendamento_transicao_estado add atributo number(10);
alter table agendamento_transicao_estado add deslocamento number(10);

alter table AGENDAMENTO_TRANSICAO_EST_LOG drop constraint FK_AGENDAMENTO_TRAN_EST_LOG_01;
alter table AGENDAMENTO_TRANSICAO_EST_LOG add constraint FK_AGENDAMENTO_TRAN_EST_LOG_01
  foreign key (agendamento_id) references AGENDAMENTO_TRANSICAO_ESTADO (id) on delete cascade;

CREATE TABLE MAPA_AVALIACAO  (
  id               number(10,0) not null, 
  OBJETIVO_ID      number(10,0), 
  INDICADOR_ID     number(10,0), 
  DATA             date not null, 
  ANALISE          varchar2(4000), 
  ACOES_REALIZADAS varchar2(4000), 
  RECOMENDACOES    varchar2(4000), 
  DECISOES         varchar2(4000), 
  USUARIO_ID       varchar2(50) not null, 
constraint CHK_MAPA_AVALIACAO_01 CHECK (( NVL(OBJETIVO_ID,0)> 0 OR NVL(INDICADOR_ID,0)>0  ) AND
                                        ( NVL(OBJETIVO_ID,0)= 0 OR NVL(INDICADOR_ID,0)=0  )), 
CONSTRAINT PK_MAPA_AVALIACAO PRIMARY KEY (ID) using index tablespace &CS_TBL_IND
) tablespace &CS_TBL_DAT;
 
COMMENT ON COLUMN MAPA_AVALIACAO.ID IS 'Chave única da tabela';
COMMENT ON COLUMN MAPA_AVALIACAO.OBJETIVO_ID IS 'Objetivo associado';
COMMENT ON COLUMN MAPA_AVALIACAO.INDICADOR_ID IS 'Indicador associado';
COMMENT ON COLUMN MAPA_AVALIACAO.DATA IS 'Data da Avaliação';
COMMENT ON COLUMN MAPA_AVALIACAO.ANALISE IS 'Análise';
COMMENT ON COLUMN MAPA_AVALIACAO.ACOES_REALIZADAS IS 'Ações Realizadas'; 
COMMENT ON COLUMN MAPA_AVALIACAO.RECOMENDACOES IS 'Recomendações';
COMMENT ON COLUMN MAPA_AVALIACAO.DECISOES IS 'Decisões';
COMMENT ON COLUMN MAPA_AVALIACAO.USUARIO_ID IS 'Usuário Avaliador';
   
alter table MAPA_AVALIACAO add CONSTRAINT FK_MAPA_AVALIACAO_01 
  FOREIGN KEY (OBJETIVO_ID) references MAPA_OBJETIVO (ID);
alter table MAPA_AVALIACAO add CONSTRAINT FK_MAPA_AVALIACAO_02 
  FOREIGN KEY (INDICADOR_ID) REFERENCES MAPA_INDICADOR (ID); 
alter table MAPA_AVALIACAO add CONSTRAINT FK_MAPA_AVALIACAO_03   
  FOREIGN KEY (USUARIO_ID) REFERENCES USUARIO (USUARIOID);

create sequence MAPA_AVALIACAO_SEQ start with 1 increment by 1 minvalue 1;


CREATE TABLE REGRAS_RELEVANTES_ACAO ( 
  ID NUMBER(10) NOT NULL,
  ACAO_ID NUMBER(10) ,
  REGRA_RELEVANTE NUMBER(10),
constraint PK_REGRAS_RELEVANTES_ACAO primary key (id) using index tablespace &CS_TBL_IND
) tablespace &CS_TBL_DAT;

ALTER TABLE REGRAS_RELEVANTES_ACAO ADD CONSTRAINT FK_REGRAS_RELEVANTES_ACAO_01 
  FOREIGN KEY (ACAO_ID) REFERENCES ACAO_CONDICIONAL (ID) ON DELETE cascade;
ALTER TABLE REGRAS_RELEVANTES_ACAO ADD CONSTRAINT FK_REGRAS_RELEVANTES_ACAO_02 
  FOREIGN KEY (REGRA_RELEVANTE) REFERENCES REGRAS_VALID_TRANSICAO (ID) ON DELETE cascade;

CREATE SEQUENCE REGRAS_RELEVANTES_ACAO_SEQ  START WITH 1 INCREMENT BY 1 nocache;

------------------------------------------

-- Create table
create global temporary table HASH_MAP
(
  ID  number not null,
  NOME  VARCHAR2(50) not null,
  KEY   VARCHAR2(50),
  VALUE VARCHAR2(4000),
constraint PK_HASH_MAP primary key (id)
) on commit delete rows;
-- Add comments to the table 
comment on table HASH_MAP
  is 'Tabela temporária que server para simular um HashMap do Java';

CREATE SEQUENCE HASH_MAP_SEQ  START WITH 1 INCREMENT BY 1 NOCACHE;

------------------------------------------------------------------------------
create or replace
package pck_geral is

type t_varchar_array is table of varchar2(4000) index by binary_integer;

function f_caminho_uo(pn_id        in uo.id%type, 
                      pv_separador in varchar2 default ' > ') 
                      return varchar2;
                      
function f_caminho_destino(pn_id destino.destinoid%type,
                      pv_separador varchar2 default ' > ') 
                      return varchar2;
         
function f_caminho_custo_receita(pn_id        in custo_receita.id%type, 
                                 pv_separador in varchar2 default ' > ')
                                 return varchar2;
                                 
function f_zero_is_null(pn_numero in number) return number;

function f_sum_lista(pv_lista varchar2, pv_separador varchar2) return number;

function f_split(pv_lista varchar2, pv_separador varchar2) return t_varchar_array;

function f_primeiro_valor(pv_lista varchar2, pv_separador varchar2, pn_minimo number) return number;

function f_insere_zeroIsNull(pv_formula varchar2) return varchar2;

function f_minutos_entre (pd_inicio date, pd_fim date, pn_padrao_horario padraohorario.id%type) return number;

function f_meses_entre ( pd_inicio date, pd_fim date) return number;

procedure p_put_hash_map(pn_name varchar2,pn_key varchar2,pn_value varchar2);
                           
function f_get_hash_map (pn_name varchar2, pn_key varchar2) return number;
                           
end pck_geral;
/
create or replace
package body pck_geral is

function f_caminho_uo(pn_id uo.id%type,
                      pv_separador varchar2 default ' > ') 
                      return varchar2 is
   lv_caminho varchar2(10000);
begin
   select SUBSTR(sys_connect_by_path(titulo, '#@$%&*'), 7) path
     into lv_caminho
     from uo
    where id = pn_id
   connect by parent_id = prior id 
   start with parent_id is null;
   
   return replace(lv_caminho, '#@$%&*', pv_separador);
   /*
   exception
      when OTHERS then
         return null;
         */
end f_caminho_uo;

function f_caminho_destino(pn_id destino.destinoid%type,
                      pv_separador varchar2 default ' > ') 
                      return varchar2 is
   lv_caminho varchar2(10000);
begin
   select SUBSTR(sys_connect_by_path(descricao, '#@$%&*'), 7) path
     into lv_caminho
     from (select 'P' tipo, id, titulo descricao, 'P' tipopai, parent_id 
           from grupo_cadastro
           union all
           select 'D' tipo, destinoid id, descricao, 'P' tipopai, destinopai parent_id
           from destino)
    where id = pn_id
    and   tipo = 'D'
   connect by parent_id = prior id 
          and tipopai = prior tipo
   start with parent_id is null;
   
   return replace(lv_caminho, '#@$%&*', pv_separador);
   /*
   exception
      when OTHERS then
         return null;
         */
end f_caminho_destino;

function f_caminho_custo_receita(pn_id custo_receita.id%type,
                                 pv_separador varchar2 default ' > ') 
                                 return varchar2 is
   lv_caminho varchar2(10000);
begin
   select SUBSTR(sys_connect_by_path(titulo, '#@$%&*'), 7) path
     into lv_caminho
     from custo_receita
    where id = pn_id
   connect by id_pai = prior id 
   start with id_pai is null;
   
   return replace(lv_caminho, '#@$%&*', pv_separador);
   
   exception
      when OTHERS then
         return null;
end f_caminho_custo_receita;

function f_zero_is_null(pn_numero in number) return number is
begin
  if pn_numero = 0 then 
     return null;
  else
     return pn_numero;
  end if;
end;

function f_sum_lista(pv_lista varchar2, pv_separador varchar2) return number is
  ln_total number:=0;
  ln_i number;
  ln_fim number;
  lv_lista VARCHAR2(4000);
begin
   if length(trim(pv_lista)) = 0 then
      return 0;
   end if;
   if substr(pv_lista, 1, length(pv_separador)) = pv_separador then
      lv_lista := pv_lista;
   else
      lv_lista := pv_separador || pv_lista;
   end if;
   ln_i := 1;
   while (ln_i+length(pv_separador) <= length(lv_lista) and ln_i <> 0) loop
      ln_fim := instr(lv_lista,pv_separador, ln_i + 1);
      if ln_fim = 0 then
         ln_total := ln_total + to_number(substr(lv_lista,ln_i+length(pv_separador)));
         ln_i := 0;
      else
         ln_total := ln_total + to_number(substr(lv_lista,ln_i+length(pv_separador),ln_fim - (ln_i+length(pv_separador))));
         ln_i := ln_fim;
      end if;
      
   end loop;
   
   return ln_total;
end;

function f_split(pv_lista varchar2, pv_separador varchar2) return t_varchar_array is
  ln_i number;
  ln_fim number;
  tab_ret t_varchar_array;
  ln_contador binary_integer;
  lv_lista VARCHAR2(4000);
begin
   if length(trim(pv_lista)) = 0 then
      return tab_ret;
   end if;
   if substr(pv_lista, 1, length(pv_separador)) = pv_separador then
      lv_lista := pv_lista;
   else
      lv_lista := pv_separador || pv_lista;
   end if;
   
   ln_i := 1;
   ln_contador := 0;
   while (ln_i+length(pv_separador) <= length(lv_lista) and ln_i <> 0) loop
      ln_fim := instr(lv_lista,pv_separador, ln_i + 1);
      ln_contador := ln_contador + 1;
      if ln_fim = 0 then
         tab_ret(ln_contador) := substr(lv_lista,ln_i+length(pv_separador));
         ln_i := 0;
      else
         tab_ret(ln_contador) := substr(lv_lista,ln_i+length(pv_separador),ln_fim - (ln_i+length(pv_separador)));
         ln_i := ln_fim;
      end if;
      
   end loop;
   
   return tab_ret;
end;

function f_primeiro_valor(pv_lista varchar2, pv_separador varchar2, pn_minimo number) return number is
lt_val t_varchar_array;
ln_i binary_integer;
begin
   lt_val := f_split(pv_lista, pv_separador);
   
   ln_i := 1;
   while (ln_i <= lt_val.count and to_number(lt_val(ln_i)) < nvl(pn_minimo,0)) loop
      ln_i := ln_i + 1;
   end loop;
   return to_number(lt_val(ln_i));
end;

function f_insere_zeroIsNull(pv_formula varchar2) return varchar2 is
   lv_retorno varchar2(4000);
   ln_iniDenom number:=0;
   ln_fimDenom number:=0;
   ln_iniDiv number:=0;
   ln_contPar number:=0;
begin
   lv_retorno := pv_formula;
   ln_iniDiv := instr(lv_retorno,'/');
    
    while (ln_iniDiv > 0) loop
       ln_iniDenom := ln_iniDiv + 1;
       while (substr(lv_retorno,ln_iniDenom,1)= ' ') loop
          ln_iniDenom := ln_iniDenom+1;
       end loop;

       ln_fimDenom := ln_iniDenom + 1;
      
       if (substr(lv_retorno,ln_iniDenom,1) = '(') then
           ln_contPar := 1;
          while (ln_contPar>0) loop
             if (substr(lv_retorno,ln_fimDenom,1)=')') then
                ln_contPar := ln_contPar - 1;
             else 
                if (substr(lv_retorno,ln_fimDenom,1) ='(') then
                   ln_contPar := ln_contPar + 1;
                end if;
             end if;
          
             ln_fimDenom := ln_fimDenom + 1;
          end loop;
       else 
           while (ln_fimDenom <= length(lv_retorno) and
                  substr(lv_retorno,ln_fimDenom,1) <> ' ' and substr(lv_retorno,ln_fimDenom,1) <> ')' and
                 substr(lv_retorno,ln_fimDenom,1) <> '+' and substr(lv_retorno,ln_fimDenom,1) <> '-' and
                 substr(lv_retorno,ln_fimDenom,1) <> '*' and substr(lv_retorno,ln_fimDenom,1) <> '/') loop
             ln_fimDenom := ln_fimDenom + 1;
          end loop;
       end if;
       dbms_output.put_line('fimDenom:'||ln_fimDenom);
       if ln_fimDenom < length(lv_retorno) then
          lv_retorno := substr(lv_retorno,1,ln_iniDenom-1) || 'pck_geral.f_zero_is_null(' || substr(lv_retorno,ln_iniDenom, ln_fimDenom -ln_iniDenom) ||  ')' ||
                        substr(lv_retorno, ln_fimDenom);
       else
          lv_retorno := substr(lv_retorno,1,ln_iniDenom-1) || 'pck_geral.f_zero_is_null(' || substr(lv_retorno,ln_iniDenom) ||  ')';
       end if;
       ln_iniDiv := instr(lv_retorno,'/', ln_iniDiv+1);
    end loop;
    return lv_retorno;
  end;
  
  function f_minutos_entre (pd_inicio date, pd_fim date, pn_padrao_horario padraohorario.id%type) return number is
  ln_inicio_t1 number;
  ln_fim_t1 number;
  ln_inicio_t2 number;
  ln_fim_t2 number;
  ln_minutos number;
  
  ln_min_inicio number;
  ln_min_fim number;
  
  ln_min_di number;
  ln_min_df number;
  ln_min_di_termino number;
  ln_min_df_inicio number;
  
  ln_tempo_t1 number;
  ln_tempo_t2 number;
  
  begin
  
     if pn_padrao_horario is not null then
        select nvl(entrada,-1), nvl(saidaintervalo,-1), nvl(entradaintervalo,-1), nvl(saida,-1)
        into ln_inicio_t1, ln_fim_t1, ln_inicio_t2, ln_fim_t2
        from padraohorario 
        where id = pn_padrao_horario;
     else
       ln_inicio_t1 := 0;
       ln_fim_t1 := 1440;
       ln_inicio_t2 := -1;
       ln_fim_t2 := -1;
     end if;
     
     ln_min_di := trunc((pd_inicio - trunc(pd_inicio))*24*60);
     ln_min_df := trunc((pd_fim - trunc(pd_fim))*24*60);
  
     ln_minutos := 0;
     
     --Calcula hora termino do primeiro dia e hora inicio do ultimo dia 
     if trunc(pd_inicio) = trunc(pd_fim) then
        ln_min_di_termino := ln_min_df;
        ln_min_df_inicio := ln_min_di;
     else
        ln_min_di_termino := 1440;
        ln_min_df_inicio := 0;
     end if;
     
     --Dia inicio
     if ln_min_di <= ln_fim_t1 then
        ln_tempo_t1 := least(ln_fim_t1, ln_min_di_termino) - greatest(ln_inicio_t1,ln_min_di);
     else
        ln_tempo_t1 := 0;
     end if;
     if ln_min_di_termino >= ln_inicio_t2 and ln_min_di <= ln_fim_t2 then
        ln_tempo_t2 := least(ln_fim_t2, ln_min_di_termino) - greatest(ln_inicio_t2,ln_min_di);
     else
        ln_tempo_t2 := 0;
     end if;
     ln_minutos := ln_minutos + (f_dias_uteis_entre(pd_inicio,pd_inicio) * (ln_tempo_t1 + ln_tempo_t2));

     --Dia final
     if trunc(pd_inicio) <> trunc(pd_fim) then
        if ln_min_df_inicio <= ln_fim_t1 then
           ln_tempo_t1 := least(ln_fim_t1, ln_min_df) - greatest(ln_inicio_t1,ln_min_df_inicio);
        else
           ln_tempo_t1 := 0;
        end if;
        if ln_min_df >= ln_inicio_t2 and ln_min_df_inicio <= ln_fim_t2 then
           ln_tempo_t2 := least(ln_fim_t2, ln_min_df) - greatest(ln_inicio_t2,ln_min_df_inicio);
        else
           ln_tempo_t2 := 0;
        end if;
        ln_minutos := ln_minutos + (f_dias_uteis_entre(pd_fim,pd_fim) * (ln_tempo_t1 + ln_tempo_t2));
     end if;

      ln_minutos := ln_minutos + (f_dias_uteis_entre(pd_inicio+1,pd_fim-1) * (ln_fim_t1 - ln_inicio_t1 + ln_fim_t2 - ln_inicio_t2));
      
     return ln_minutos;
  end;
  
  function f_meses_entre ( pd_inicio date, pd_fim date) return number is
  
  begin
     if to_char(pd_inicio, 'yyyy') = to_char(pd_fim, 'yyyy') then
        return to_number(to_char(pd_fim, 'mm')) - to_number(to_char(pd_inicio, 'mm'));
     else
        return 12 - to_number(to_char(pd_inicio, 'mm')) +
               to_number(to_char(pd_fim, 'mm')) +
               (12 * (to_number(to_char(pd_fim, 'yyyy')) - to_number(to_char(pd_inicio, 'yyyy')) -1));
     end if;
    
  end;

  procedure p_put_hash_map(pn_name varchar2,
                           pn_key varchar2,
                           pn_value varchar2) is
  ln_seq number;                           
  begin
    select hash_map_seq.nextval into ln_seq from dual;       
  
    insert into hash_map(id, nome, key, value)
    values(ln_seq, pn_name, pn_key, pn_value);
  end;     
  
  function f_get_hash_map (pn_name varchar2, 
                           pn_key varchar2) return number is
  lv_value varchar2(4000);                                                      
  begin
    lv_value := null;       
    select min(value) into lv_value from hash_map where nome = pn_name and key = pn_key;
    return lv_value;
  end;    
                                     
end pck_geral;
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
      v_start   PLS_INTEGER := 1;
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
       values (versao_seq.nextval, '6.0.0', '09', 3, 'Aplicação de patch');
commit;
/

begin
  pck_processo.precompila;
  commit;
end;
/
                      
select * from v_versao;
/
