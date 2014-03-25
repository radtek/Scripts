/******************************************************************************\
* TraceGP 5.2.0.24                                                             *
\******************************************************************************/


define CS_TBL_DAT = &TABLESPACE_DADOS;
define CS_TBL_IND = &TABLESPACE_INDICES;

-- Patch 25
create or replace view v_valor_hora as 
select usuario, nvl(data_inicio,to_date('01/01/1900', 'dd/mm/yyyy')) INICIO, 
       valor_hora, min(data_fim) FIM
  from (select vvhs.usuario_id USUARIO, vvhs.valor_hora VALOR_HORA, 
               vvhs.data_inicio DATA_INICIO,
               nvl(prior vvhs.data_inicio,to_date('01/01/9999', 'dd/mm/yyyy')) - 1 DATA_FIM
          from (select u_rowid, vhu_rowid, tp_rowid, usuario_id, data_inicio, valor_hora, tipo_profissional
                  from mv_valor_hora_simplificada
                 where tp_vigente = 'S'
                 union
                select null, null, null, u.usuarioid, to_date('01/01/1900', 'dd/mm/yyyy'), t.valorhora, t.id
                  from usuario u,
                       tipoprofissional t
                 where t.id = u.tipo_profissional_id) vvhs
         connect by vvhs.usuario_id  = prior vvhs.usuario_id
                and vvhs.data_inicio < prior vvhs.data_inicio )   
group by usuario, data_inicio, valor_hora;

CREATE TABLE RESPONSAVEL_EQUIPE ( 
  EQUIPE_ID NUMBER(10) NOT NULL,
  USUARIO_ID VARCHAR2(50) NULL,
  constraint PK_RESPONSAVEL_EQUIPE primary key (EQUIPE_ID, USUARIO_ID) using index tablespace &CS_TBL_IND
) tablespace &CS_TBL_DAT;


ALTER TABLE RESPONSAVEL_EQUIPE ADD CONSTRAINT FK_RESPONSAVEL_EQUIPE_01 
	FOREIGN KEY (EQUIPE_ID) REFERENCES EQUIPE (EQUIPE_ID)
ON DELETE CASCADE;

ALTER TABLE RESPONSAVEL_EQUIPE ADD CONSTRAINT FK_RESPONSAVEL_EQUIPE_02 
	FOREIGN KEY (USUARIO_ID) REFERENCES USUARIO(USUARIOID)
ON DELETE CASCADE;

insert into tela (telaid, nome, visivel, grupoid, ordem, codigo, subgrupo, atalho)
values((select max(telaid)+1 from tela), 'bd.prompt.utilizarPermissaoEquipe', 'S', 26, 7, 'UTILIZA_PERM_EQUIPE', null, 'N');

commit;
/

-- MAPA_CONSULTA_PARAMS [INI]
create table mapa_consulta_params (
  id                     number(10)     not null,
  indicador_id           number(10)     not null,
  nome                   varchar2(150)  not null,
  valor                  varchar2(4000) null,
  data_criacao           date           default sysdate not null,
  data_atualizacao       date           default sysdate not null, 
  usuario_criacao_id     varchar2(50)   not null,
  usuario_atualizacao_id varchar2(50)   not null,
constraint PK_MAPA_CONSULTA_PARAMS primary key (id) using index tablespace GPTRACE_IND  
) tablespace &CS_TBL_DAT;

create sequence mapa_consulta_params_seq
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache; 
-- MAPA_CONSULTA_PARAMS [FIM]

create or replace package pck_condicional is
      rodando           boolean:=false;
      procedure p_ExecutarRegrasCondicionaisP (pn_demanda_id demanda.demanda_id%type, 
                                              pn_prox_estado number, 
                                              pv_usuario usuario.usuarioid%type, 
                                              pn_ret in out number, 
                                              pn_estado_id in out number, 
                                              pn_estado_mensagem_id in out estado_mensagens.id%type, 
                                              pn_enviar_email in out number, 
                                              pn_gerar_baseline in out number);
      procedure p_ExecRegrasFormulario (pn_formulario_id formulario.formulario_id%type);
      procedure p_ExecutarRegrasCondicionais (pn_demanda_id demanda.demanda_id%type, pv_usuario usuario.usuarioid%type, pn_ret out number);
      procedure p_NomeBaseline(pn_demanda_id demanda.demanda_id%type, pn_estado_id demanda.situacao%type, pn_projeto_id projeto.id%type, pn_acao_id acao_condicional.id%type, pv_nome out varchar2 );
end;
/
create or replace package body pck_condicional is

   type tab_projeto is table of projeto%rowtype index by binary_integer;
   
   type tr_SeSenao is table of condicional_se_senao%rowtype index by binary_integer;
   
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

   procedure p_ExecutaAcaoCondicional (rec_demanda in out nocopy demanda%rowtype, pprojetos in out nocopy tab_projeto, acao acao_condicional%rowtype, pv_usuario varchar2, pn_estado_id in out number, pn_estado_mensagem_id in out number, pn_enviar_email in out number, pn_gerar_baseline in out number) is
   rec_secao_atributo secao_atributo%rowtype;
   rec_atributo atributo%rowtype;
   tab_val pck_geral.t_varchar_array;
   lv_formula varchar2(4000);
   lv_valor varchar2(4000);
   lv_select varchar2(4000);
   lv_valor_troca acao_condicional.valor_troca%type;
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
        elsif 'PO' = upper(acao.acao) or 'PF' = upper(acao.acao) then
           if 'PF' = upper(acao.acao) then
              lv_formula := acao.valor_troca;
           
              lv_valor := f_valorcomparacao('DURACAO', rec_demanda, null, null);
           
              lv_formula := replace(lv_formula, '[duracao]', lv_valor);
           
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
dbms_output.put_line(lv_select);            
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
          if acao.secao_atr_obj_id is not null then
           
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

   function f_AlteraDemandaPorCondicional ( rec_demanda in out demanda%rowtype, pprojetos in out nocopy tab_projeto, se condicional_se_senao%rowtype, senao condicional_se_senao%rowtype, pv_usuario usuario.usuarioid%type, pn_estado_id in out number, pn_estado_mensagem_id in out number, pn_enviar_email in out number, pn_gerar_baseline in out number) return boolean is
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
                       
                      lb_alterou := f_AlteraDemandaPorCondicional ( rec_demanda, pprojetos, cond_Se, cond_Senao, pv_usuario, pn_estado_id, pn_estado_mensagem_id, pn_enviar_email, pn_gerar_baseline );
                       
                      if not lb_ocorreu_alteracao then
                         lb_ocorreu_alteracao := lb_alterou;
                      end if;
                      
                      if pn_estado_id > 0 then
                         return lb_ocorreu_alteracao;
                      end if;
                   end if;  
               end if;
               if tab_acao(ln_contador).id >=0 then
                  p_ExecutaAcaoCondicional(rec_demanda, pprojetos, tab_acao(ln_contador), pv_usuario, pn_estado_id, pn_estado_mensagem_id, pn_enviar_email, pn_gerar_baseline);
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
                       
                      lb_alterou := f_AlteraDemandaPorCondicional ( rec_demanda, pprojetos, cond_Se, cond_Senao, pv_usuario, pn_estado_id, pn_estado_mensagem_id, pn_enviar_email, pn_gerar_baseline );
                       
                      if not lb_ocorreu_alteracao then
                         lb_ocorreu_alteracao := lb_alterou;
                      end if;
                      
                      if pn_estado_id > 0 then
                         return lb_ocorreu_alteracao;
                      end if;
                   end if;
               end if;

               if tab_acao(ln_contador).id >= 0 then
                  p_ExecutaAcaoCondicional(rec_demanda, pprojetos, tab_acao(ln_contador), pv_usuario, pn_estado_id, pn_estado_mensagem_id, pn_enviar_email, pn_gerar_baseline);
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
   begin
     p_ExecutarRegrasCondicionaisP (pn_demanda_id, null, pv_usuario, pn_ret, ln_estado_id, ln_estado_mensagem_id, ln_enviar_email, ln_gerar_baseline);
   end;
   
   procedure p_ExecutarRegrasCondicionaisP (pn_demanda_id demanda.demanda_id%type, 
                                            pn_prox_estado number, 
                                            pv_usuario usuario.usuarioid%type, 
                                            pn_ret in out number, 
                                            pn_estado_id in out number, 
                                            pn_estado_mensagem_id in out estado_mensagens.id%type, 
                                            pn_enviar_email in out number, 
                                            pn_gerar_baseline in out number) is
   
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
               
               lb_alterou := f_AlteraDemandaPorCondicional ( rec_demanda, projetos, cond_Se, cond_Senao, pv_usuario, pn_estado_id, pn_estado_mensagem_id, pn_enviar_email, pn_gerar_baseline);
               
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

insert into versao(id, titulo, patch, versao_tgp_id, comentario)
       values (versao_seq.nextval, '5.2.0', '25', 2, 'Aplicação de Patch');
commit;
/

begin
  pck_processo.precompila;
  commit;
end;
/
                      
select * from v_versao;
/




