/**************************************************************************************************\
* Roteiro para migração à versão de custos (5.2.0.0) - Parte VII - Controle de Versão de BD        *
* Autor: Charles Falcão                     Data de Publicação: 18/Mai/2009                        *
\**************************************************************************************************/

--> Se desejar limpar todos dados das tabelas utilizadas para verificação da versão, descomente o
--  trecho de código a seguir

delete from versao_objeto;
delete from versao_sequencia;
commit;
/

-----------------------------------
-- OBJETOS DE VERSÕES ANTERIORES --
-----------------------------------
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'FUNCTION', 'GERAR_CHAVE_PRIMARIA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'FUNCTION', 'GET_COR_IDP_IDC');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'FUNCTION', 'GET_SITUACOES_ATRASADAS');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'FUNCTION', 'HORAMIN');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'FUNCTION', 'MINHORA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'FUNCTION', 'RECOMPILE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'FUNCTION', 'REGISTRO_PONTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'FUNCTION', 'VALOR_ATRIBUTO_MULTI_LISTA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'ANEXO_MODELO_DOC_PK');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'ATRENTVAL_TIPOENT_ATRID_IDX');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'BASE_CONHECIMENTO_PK');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'BIOPONTO_MAPEAMENTO_USUAR_PK');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'CATEGORIA_CONHECIMENTO_PK');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'CATEGORIA_FORMULARIO_PK');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'CENTRO_CUSTO_PK');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'CONHECIMENTO_USUARIO_PK');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'DESTINO_USUARIO_PK');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'DETALHE_DISPONIVEL_ATRIBUTO_PK');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_DIA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'FILTRO_FAVORITO_PK');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'FILTRO_PK');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'H_BASE_CONHECIMENTO_PK');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDIOMA_IDX');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_ATRIBUTO_FORM_ESTADO_FID');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_ATRIBUTO_VALOR_03');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_CAMPO_FORMULARIO_ESTAD_FID');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_CAMPO_FORMULARIO_FID');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_CATEGORIA_CONHEC_FORM_FID');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_DEMANDA_FID');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_DEMANDA_01');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_DEMANDA_02');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_DEST_INICIAL_USUARIO_FID');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_DESTINO_FORM_USUARIO_FID');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_ESTADO_FORMULARIO_FID');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_ESTADO_FORMULARIO_02');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_ESTADO_SLA_FORMULARIO_FID');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_ESTADO_01');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_FORMULARIO_DESTINO_FID');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_FORMULARIO_PERFIL_FID');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_H_DEMANDA_FID');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_H_DEMANDA_01');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_H_DEMANDA_02');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_H_DEMANDA_03');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_H_DEMANDA_07');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_HINT_FORMULARIO_FID');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_INDICADOR_FORMULARIO_FID');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_INDICADOR_POSSIVEL_FOR_FID');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_MODELO_DEMANDA_FID');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_NOTIFICACAO_FID');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_PAPELPROJETORECURSO_01');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_PAPELPROJETORECURSO_02');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_PERMISSAO_CATEGORIA_PAP_01');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_PERMISSAO_ITEM_01');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_PRIORIDADE_FORMULARIO_FID');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_PROXIMO_ESTADO_FID');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_REGRA_DESTINO_FID');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_REGRA_FORMULARIO_FID');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_SECAO_FID');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_SLA_DEM_FINALIZADA_01');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_TIPO_FORMULARIO_FID');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_UO_01');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_USUARIO_01');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_USUARIO_02');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_USUARIO_03');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'IDX_USUARIO_04');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'INDICE_DATAPERMISSAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'INDICEDATATRABALHO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'INTEGRACAO_PONTO_VALOR_PK');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'LOG_BATCH_PK');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'MEN_CONSTRAINT2');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'MODELO_REL_PORTFOLIO_PK');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'ORIGEMID');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PARTICIPANTE_REL_PORTFOLIO_PK');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ABA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ABERTURA_VIA_EMAIL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ACAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_AGENDAMENTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_AJUSTE_PTO_EXCED_CRONOMETR');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ALOCACAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ALTERACAOESCOPO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ALT_ESCOPO_SOLICIT');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_APROVADORENTIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_APROVADORESCOPO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_AREAAFETADA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ATALHOS_PESSOAIS');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ATIVIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ATOR');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ATRIBUTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ATRIBUTOENTIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ATRIBUTOENTIDADEVALOR');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ATRIBUTO_FORM_ESTADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ATRIBUTO_VALOR_01');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_AVALIACAOCONHECIMENTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_AVALIACAOITEMQUALIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_AVALIACAOQUALIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_BASELINE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_BASELINE_DEPENDENCIAS');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_BASELINE_ENTIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_BASELINE_RESPONSAVEL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_BASELINE_VH_USUARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_BENEFICIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_CAMPO_FORMULARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_CAMPO_FORMULARIO_ESTADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_CAMPO_NOTIFICACAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_CAMPOS_MAPEAMENTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_CASODEUSO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_CATEGORIA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_CATEGORIA_ASSOCIADA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_CATEGORIA_CONHEC_FORM');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_CATEGORIA_DESPESA_DEMANDA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_CENTRO_CUSTO_ENTIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_CENTROCUSTO_ENTIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_CHECKLIST');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_CHECKLIST_CATEGORIA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_CHECKLIST_ITEM');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_CHECKLIST_TIPO_TAREFA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_COMPONENTE_INVENTARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_COMUNICACAO_DASHBOARD');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_COMUNICACAO_PORTLET');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_CONFIGURACOES');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_CONHECIMENTOPAPEL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_CONHECIMENTOPROFISSIONAL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_CONTADORES');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_CONTROLE_LEITURA_DOC');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_CONTROLE_SCHEDULER');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_DASHBOARD');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_DASHBOARD_COLUNA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_DASHBOARD_PORTLET');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_DEMANDA_ENTIDADE_ESTADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_DEMANDA_INVENTARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_DEMANDA_RELACIONAMENTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_DEMANDA_01');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_DEPENDENCIA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_DEPENDENCIAATIVIDADETAREFA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_DEPENDENCIAETAPA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_DEST_INICIAL_USUARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_DESTINO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_DESTINO_FORM_USUA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_DESTINO_POSSIVEL_ESTADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_DESTINO_SOLICITANTE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_DETALHE_DISPONIVEL_INFO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_DETALHE_SELECIONADO_INFO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_DOCUMENTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_DOMINIOAPLICACAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_DOMINIOATRIBUTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_EMAIL_INTERESSADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_EMPRESA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_EQ_SISTUACOES');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_EQUIPE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ESTADO_FORMULARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ESTADO_SLA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ESTADO_SLA_FORMULARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ESTADOSOLICITACAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ETAPA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_EVENTO_APLICACAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_EVENTO_ITEM_PLANO_COMUNICA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_FABRICANTE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_FATORESAJUSTE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_FERIADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_FLUXOPROCESSO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_FONTE_DOCUMENTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_FORMAAQUISICAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_FORMA_NOTIFICACAO_DOC');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_FORMATO_DOC_GERENCIA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_FORMULARIO_DESTINO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_FORMULARIO_PERFIL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_FORMULARIO_01');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_GRUPO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_GRUPO_CADASTRO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_H_COMPONENTE_INVENTARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_H_DEMANDA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_HIERARQUIACONGELADA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_HINTS_FORMULARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_HIST_APROVACAO_ESCOPO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_HISTORICOACEITEPROJETO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_HISTORICOACEITEUSUARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_HISTORICOAPROVACAOENTIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_HISTORICO_DISTRIBUICAO_DOC');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_HISTORICODOCUMENTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_HISTORICO_PRAZOS');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_HISTORICORESPENTIDADEID');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_HISTORICORISCO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_HISTORICOUSUARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_HISTORICOVISTORIAENTIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_HISTPAPELPROJRECURSO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_HIST_SOLICITACOES_ESCOPO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_H_ITEM_INVENTARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_HORA_EXCEDENTE_CRONOMETRO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_HORAEXTRA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_HORATRABALHADA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_HORA_TRABALHADA_TAXIMETRO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_H_SOL_AJUSTE_PONTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_H_USUARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ICONE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_IMPACTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_INDICADOR');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_INDICADOR_ASSOCIADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_INDICADOR_CONFIGURACAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_INDICADOR_CONFIGURACAO_SOL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_INDICADOR_FORMULARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_INDICADOR_HISTORICO_SIT');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_INDICADOR_HISTORICO_SITUAC');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_INDICADOR_POSSIVEL_FORMULAR');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_INFORMACAO_DISPONIVEL_DOC');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_INFORMACAO_SELECIONADA_DOC');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_INVENTARIO_CAMPO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ITEM_INVENTARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ITEMMATRIZRESPONSABILIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ITEMORGANOGRAMA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ITEM_PLANO_COMUNICACAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ITEMQUALIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ITEMWBS');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ITENS_QUALIDADE_AVALIACAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_LINK');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_LOG_EXCLUSAO_PROJETO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_LOG_MODELO_DOC');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_LOG_VALOR_HORA_USUARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_MAP_DEST_TRANS_ESTADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_MAPEAMENTO_ENTIDADE_ESTADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_MARCO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_MATRIZRESPONSABILIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_MENSAGEM');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_MODELO_DEMANDA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_MODELO_DOC');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_MODELO_DOC_GERENCIA_PROJ');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_MODULO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_MODULOPROJETO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_NIVELCONHECIMENTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_NOTAITEMQUALIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_NOTIFCACAO_ESTADO_ENTIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_NOTIFICACAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_NOTIFICACAO_PENDENTE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_OCORRENCIA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_OCORRENCIARISCO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ORCAMENTOGERALCONGELADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_ORCAMENTOPESSOALCONGELADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PADRAOHORARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PAINELDEABAS');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PAPELPROJETO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PAPELPROJETORECURSO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PARAMETROSESTIMATIVA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PARTE_INTERESSADA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PARTICIPANTE_MSG_PAPEL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PARTICIPANTE_MSG_STAKEHOLD');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PARTICIPANTE_MSG_USUARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PARTICIPANTE_PC_PAPEL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PARTICIPANTE_PC_RECURSO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PARTICIPANTE_PC_STAKEHOLDE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PERFIL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PERMISSAOABA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PERMISSAO_CATEGORIA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PERMISSAO_CATEGORIA_PAPEL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PERMISSAO_CATEGORIA_PERFIL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PERMISSAO_ITEM');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PERMISSAO_ITEM_PAPEL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PERMISSAO_ITEM_PERFIL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PERSPECTIVA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PONTOELETRONICO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PONTOELETRONICOREAL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PORTLET_CUSTOMIZACAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PORTLET_INFORMACAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PREMISSA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PRIORIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PRIORIDADE_FORMULARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PRIORIZACAO_FORMULARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PRODUTOENTREGAVEL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PROJECAOCUSTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PROJECAOCUSTOUSUARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PROJETO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_PROXIMO_ESTADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_QUESTAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_QUESTAO_ASSOCIADA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_REGRA_DESTINO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_REGRA_FORMULARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_REGRA_FORMULARIO_EQUIPE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_REGRA_FORMULARIO_TIPO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_RESPONSABILIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_RESPONSAVELENTIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_RESPOSTA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_RESPOSTA_ASSOCIADA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_RESPOSTA_QUESTAO_HIST');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_RESPOSTA_QUESTAO_HISTORICO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_RESTRICAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_RISCO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_SECAO_ATRIBUTO_01');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_SECAO_MODELO_DOC');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_SECAO_01');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_SISTEMA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_SLA_DEM_FINALIZADA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_SOLICITACAO_AJUSTE_PONTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_SOLICITACAO_AREA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_SOLICITACAOATENDIDAESCOPO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_SOLICITACAOENTIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_STAKEHOLDER');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_TAREFA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_TECNOLOGIA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_TECNOLOGIAENTIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_TELA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_TELAPAERFIL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_TELAPAPEL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_TELAPROCESSO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_TERMO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_TIPOATIVIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_TIPODESPESA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_TIPOFERIADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_TIPO_FORMULARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_TIPO_INDICADOR');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_TIPO_MENSAGEM');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_TIPOOCORRENCIA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_TIPOPROFISSIONAL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_TIPOPROJETO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_TIPOSOLICITACAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_TIPOTAREFA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_TIPOTECNOLOGIA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_TRADUCAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_TRANSICAO_ESTADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_UO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_USR_HISTORICO_DISTRIB_DOC');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_USUARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_USUARIOACEITEPROJETO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_USUARIODIVISAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_USUARIO_EQUIPE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_USUARIO_PERFIL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_VALOR_HORA_USUARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_VERSAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_VERSAO_DOC_GERENCIA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_VERSAO_DOC_GERENCIA_PERM_I');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PK_VISTORIADORATIVIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'PRIMARYKEY');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'RELATORIO_PK');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'RELATORIO_PORTFOLIO__IDX');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'RELATORIO_PORTFOLIO_PK');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'RISCO_ENTIDADE_PK');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'SOLICITACAO_AREA_PK');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'TEL_CONSTRAINT2');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'TIPO_INVENTARIO_CAMPO_PK');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'TIPO_INVENTARIO_CP_UN');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'TIPO_INVENTARIO_PK');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'TIPOQUALIDADE_PK');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'TITULO_TERMO_ID_IDX');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'INDEX', 'USUPERFIL_PK');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'PACKAGE', 'ATUALIZAPREVISTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'PACKAGE BODY', 'ATUALIZAPREVISTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'PACKAGE BODY', 'CALC_PORCENTAGEM');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'PACKAGE BODY', 'DURACAOENTIDADES');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'PACKAGE BODY', 'PCK_AGENDAMENTOS');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'PACKAGE BODY', 'PCK_ATUALIZA_REALIZADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'PACKAGE BODY', 'PCK_CONVERTE_DATAS');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'PACKAGE BODY', 'PCK_DEMANDAS');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'PACKAGE BODY', 'PCK_MACRO_SUBSTITUICAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'PACKAGE', 'CALC_PORCENTAGEM');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'PACKAGE', 'DURACAOENTIDADES');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'PACKAGE', 'PCK_AGENDAMENTOS');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'PACKAGE', 'PCK_ATUALIZA_REALIZADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'PACKAGE', 'PCK_CONVERTE_DATAS');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'PACKAGE', 'PCK_DEMANDAS');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'PACKAGE', 'PCK_MACRO_SUBSTITUICAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'PROCEDURE', 'AJUSTA_CONSTRAINTS');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'PROCEDURE', 'ENVIAR_SOL_EM_DISCUSSAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'PROCEDURE', 'FAXINA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'PROCEDURE', 'FAXINA10G');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'PROCEDURE', 'PRD_FECHAMENTO_PONTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ABA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ABERTURA_VIA_EMAIL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ACAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'AGENDAMENTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'AGENDAMENTO_DETALHE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'AJUSTE_PTO_EXCED_CRONOMETRO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ALOCACAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ALTERACAOESCOPO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ALTERACAOESCOPOSOLICITACAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ANEXO_MODELO_DOC');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'APROVADORENTIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'APROVADORESCOPO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'AREAAFETADA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ATALHOS_PESSOAIS');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ATIVIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ATOR');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ATRIBUTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ATRIBUTOENTIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ATRIBUTOENTIDADEVALOR');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ATRIBUTO_FORM_ESTADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ATRIBUTO_VALOR');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'AVALIACAOCONHECIMENTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'AVALIACAOITEMQUALIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'AVALIACAOQUALIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'BASE_CONHECIMENTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'BASELINE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'BASELINE_DEPENDENCIAS');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'BASELINE_ENTIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'BASELINE_RESPONSAVEL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'BASELINE_VH_USUARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'BENEFICIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'BIOPONTO_MAPEAMENTO_USUARIOS');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'CAMPO_FORMULARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'CAMPO_FORMULARIO_ESTADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'CAMPO_MAPEAMENTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'CAMPO_NOTIFICACAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'CASODEUSO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'CATEGORIA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'CATEGORIA_ASSOCIADA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'CATEGORIA_CONHEC_FORM');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'CATEGORIA_CONHECIMENTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'CATEGORIA_DESPESA_ENTIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'CATEGORIA_FORMULARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'CENTRO_CUSTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'CENTRO_CUSTO_ENTIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'CHECKLIST');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'CHECKLIST_CATEGORIA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'CHECKLIST_ITEM');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'CHECKLIST_TIPO_TAREFA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'COMPONENTE_INVENTARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'COMUNICACAO_DASHBOARD');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'COMUNICACAO_PORTLET');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'CONFIGURACOES');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'CONHECIMENTOPAPEL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'CONHECIMENTOPROFISSIONAL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'CONHECIMENTO_USUARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'CONTADORES');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'CONTROLE_LEITURA_DOC');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'CONTROLE_SCHEDULER');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'DASHBOARD');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'DASHBOARD_COLUNA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'DASHBOARD_FAVORITO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'DASHBOARD_PORTLET');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'DEMANDA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'DEMANDA_ENTIDADE_ESTADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'DEMANDA_INVENTARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'DEMANDA_RELACIONAMENTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'DEPENDENCIA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'DEPENDENCIAATIVIDADETAREFA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'DEPENDENCIAETAPA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'DEST_INICIAL_USUARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'DESTINO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'DESTINO_FORM_USUARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'DESTINO_POSSIVEL_ESTADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'DESTINO_SOLICITANTE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'DESTINO_USUARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'DETALHE_DISPONIVEL_INFO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'DETALHE_SELECIONADO_ATRIBUTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'DETALHE_SELECIONADO_INFO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'DIA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'DOCUMENTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'DOMINIOAPLICACAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'DOMINIOATRIBUTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'EMAIL_INTERESSADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'EMPRESA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'EQUIPE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'EQUIVALENCIASSITUACOES');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ESCOPO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ESTADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ESTADO_FORMULARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ESTADO_SLA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ESTADO_SLA_FORMULARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ESTADOSOLICITACAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ETAPA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'EVENTO_APLICACAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'EVENTO_ITEM_PLANO_COMUNICACAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'FABRICANTE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'FATORESAJUSTE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'FERIADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'FILTRO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'FILTRO_FAVORITO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'FLUXOPROCESSO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'FONTE_DOCUMENTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'FORMAAQUISICAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'FORMA_NOTIFICACAO_DOC');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'FORMATO_DOC_GERENCIA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'FORMULARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'FORMULARIO_DESTINO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'FORMULARIO_PERFIL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'GRUPO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'GRUPO_CADASTRO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'H_ATRIBUTO_VALOR');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'H_BASE_CONHECIMENTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'H_BENEFICIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'H_COMPONENTE_INVENTARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'H_DEMANDA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'HIERARQUIACONGELADA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'H_INDICADOR_ASSOCIADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'HINT_FORMULARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'HISTORICOACEITEPROJETO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'HISTORICOACEITEUSUARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'HISTORICOAPROVACAOENTIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'HISTORICOAPROVACAOESCOPO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'HISTORICO_DISTRIBUICAO_DOC');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'HISTORICODOCUMENTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'HISTORICOPAPELPROJETORECURSO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'HISTORICO_PRAZOS');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'HISTORICORESPONSAVELENTIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'HISTORICORISCO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'HISTORICOSOLICITACOESESCOPO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'HISTORICOUSUARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'HISTORICOVISTORIAENTIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'H_ITEM_INVENTARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'HORA_EXCEDENTE_CRONOMETRO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'HORAEXTRA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'HORATRABALHADA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'HORA_TRABALHADA_TAXIMETRO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'H_SOLICITACAO_AJUSTE_PONTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'H_USUARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ICONE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'IMPACTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'INDICADOR');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'INDICADOR_ASSOCIADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'INDICADOR_CONFIGURACAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'INDICADOR_CONFIGURACAO_SOL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'INDICADOR_FORMULARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'INDICADOR_HISTORICO_SITUACOES');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'INDICADOR_POSSIVEL_FORMULARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'INFORMACAO_DISPONIVEL_DOC');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'INFORMACAO_SELECIONADA_DOC');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'INTEGRACAO_PONTO_VALOR');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'INVENTARIO_CAMPO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ITEM_INVENTARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ITEMMATRIZRESPONSABILIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ITEMORGANOGRAMA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ITEM_PLANO_COMUNICACAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ITEMQUALIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ITEMWBS');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ITENS_QUALIDADE_AVALIACAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'LINK');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'LOG_BATCH');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'LOG_EXCLUSAO_PROJETO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'LOG_MODELO_DOC');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'LOG_VALOR_HORA_USUARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'MAP_DEST_TRANS_ESTADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'MAPEAMENTO_ENTIDADE_ESTADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'MARCO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'MATRIZRESPONSABILIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'MENSAGEM');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'MODELO_DEMANDA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'MODELO_DOC');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'MODELO_DOC_GERENCIA_PROJ');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'MODELO_REL_PORTFOLIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'MODULO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'MODULOPROJETO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'NIVELCONHECIMENTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'NOTAITEMQUALIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'NOTIFICACAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'NOTIFICACAO_ESTADO_ENTIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'NOTIFICACAO_PENDENTE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'OCORRENCIA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'OCORRENCIARISCO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ORCAMENTOGERALCONGELADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ORCAMENTOPESSOALCONGELADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'ORIGEM');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PADRAOHORARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PAINELDEABAS');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PAPELPROJETO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PAPELPROJETORECURSO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PARAMETROSESTIMATIVA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PARTE_INTERESSADA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PARTICIPANTE_MSG_PAPEL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PARTICIPANTE_MSG_STAKEHOLDER');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PARTICIPANTE_MSG_USUARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PARTICIPANTE_PC_PAPEL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PARTICIPANTE_PC_RECURSO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PARTICIPANTE_PC_STAKEHOLDER');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PARTICIPANTE_REL_PORTFOLIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PERFIL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PERMISSAOABA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PERMISSAO_CATEGORIA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PERMISSAO_CATEGORIA_PAPEL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PERMISSAO_CATEGORIA_PERFIL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PERMISSAO_ITEM');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PERMISSAO_ITEM_PAPEL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PERMISSAO_ITEM_PERFIL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PERSPECTIVA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PLAN_TABLE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PONTOELETRONICO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PONTOELETRONICOREAL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PONTO_REAL_TEMP');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PORTLET');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PORTLET_CUSTOMIZACAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PORTLET_INFORMACAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PREMISSA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PRIORIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PRIORIDADE_FORMULARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PRIORIZACAO_FORMULARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PRODUTOENTREGAVEL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PROJECAOCUSTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PROJECAOCUSTOUSUARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PROJETO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'PROXIMO_ESTADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'QUESTAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'QUESTAO_ASSOCIADA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'REGRA_DESTINO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'REGRA_FORMULARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'REGRA_FORMULARIO_EQUIPE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'REGRA_FORMULARIO_TIPO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'RELATORIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'RELATORIO_PERFIL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'RELATORIO_PORTFOLIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'RESPONSABILIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'RESPONSAVELENTIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'RESPOSTA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'RESPOSTA_ASSOCIADA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'RESPOSTA_QUESTAO_HISTORICO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'RESTRICAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'RISCO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'RISCO_ENTIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'SECAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'SECAO_ATRIBUTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'SECAO_MODELO_DOC');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'SISTEMA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'SLA_DEM_FINALIZADA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'SOLICITACAO_AJUSTE_PONTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'SOLICITACAO_AREA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'SOLICITACAOATENDIDAESCOPO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'SOLICITACAOENTIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'STAKEHOLDER');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'TAREFA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'TECNOLOGIA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'TECNOLOGIAENTIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'TELA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'TELAPAPEL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'TELAPERFIL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'TELAPROCESSO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'TERMO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'TIPOATIVIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'TIPODESPESA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'TIPOFERIADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'TIPO_FORMULARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'TIPO_INDICADOR');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'TIPO_INVENTARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'TIPO_INVENTARIO_CAMPO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'TIPO_MENSAGEM');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'TIPOOCORRENCIA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'TIPOPROFISSIONAL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'TIPOPROJETO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'TIPOQUALIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'TIPOSOLICITACAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'TIPOTAREFA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'TIPOTECNOLOGIA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'TRADUCAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'TRANSICAO_ESTADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'UO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'USR_HISTORICO_DISTRIB_DOC');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'USUARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'USUARIOACEITEPROJETO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'USUARIODIVISAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'USUARIO_EQUIPE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'USUARIO_PERFIL');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'VALOR_HORA_USUARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'VERSAO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'VERSAO_DOC_GERENCIA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'VERSAO_DOC_GERENCIA_PERM_INFO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TABLE', 'VISTORIADORENTIDADE');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TRIGGER', 'TRG_AGENDAMENTO_PROXDT_IU_BR');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TRIGGER', 'TRG_AGEND_DET_PROXDT_I_AR');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TRIGGER', 'TRG_AGEND_DET_PROXDT_I_AS');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TRIGGER', 'TRG_AGEND_DET_PROXDT_I_BS');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TRIGGER', 'TRG_ATIVIDADE_BR0008_UD_AR');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TRIGGER', 'TRG_DEMANDA_BR0008_IUD_AR');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TRIGGER', 'TRG_DEMANDA_BR0008_IUD_AS');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TRIGGER', 'TRG_DEMANDA_BR0008_IUD_BS');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TRIGGER', 'TRG_DEMANDA_BR0008_U_BR');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TRIGGER', 'TRG_H_ATRIBUTO_VALOR');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TRIGGER', 'TRG_H_BENEFICIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TRIGGER', 'TRG_H_COMPONENTE_INVENTARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TRIGGER', 'TRG_H_DEMANDA');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TRIGGER', 'TRG_H_INDICADOR_ASSOCIADO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TRIGGER', 'TRG_H_ITEM_INVENTARIO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TRIGGER', 'TRG_H_SOL_AJUSTE_PONTO_UD_AR');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TRIGGER', 'TRG_PROJETO_BR0008_UD_AR');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TRIGGER', 'TRG_SOLICITACAOE_BR0008_IUD_AR');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TRIGGER', 'TRG_TAREFA_BR0008_UD_AR');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TRIGGER', 'TRG_USUARIO_IU_AR');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'TRIGGER', 'TRIG_H_BASE_CONHECIMENTO');
insert into versao_objeto (id, versao_tgp_id, tipo_objeto, nome_objeto) 
       values (versao_objeto_seq.nextval, 1, 'VIEW', 'V_H_DEMANDA');
commit;
/

--------------------------------------
-- SEQUENCIAS DE VERSÕES ANTERIORES --
--------------------------------------
declare
       -- tipos de dados
       TYPE TableDescType IS RECORD (nome_tabela varchar2(30), nome_coluna varchar2(30), nome_sequence varchar2(30) );
       TYPE TableDescTable IS TABLE OF TableDescType INDEX BY BINARY_INTEGER;
       TYPE tpCursor is REF CURSOR;
       -- variaveis de controle
       tabelas TableDescTable;
       cont integer;
       nomeSeq varchar2(2000);
       vCursor tpCursor;
       vChave integer;
       max_projeto_id number;
       max_projeto_log_id number;
begin
    
    -- \/ Especial para projeto.
    begin 
        select max(id) into max_projeto_id from projeto;
        select max(projeto_id) into max_projeto_log_id from log_exclusao_projeto;
        if max_projeto_log_id > max_projeto_id then
            max_projeto_id := max_projeto_log_id;
        end if;
        if(max_projeto_id is null) then
            max_projeto_id := 1;
        end if;
        -- da um drop nela pra garantir
        begin
            execute immediate 'DROP SEQUENCE PROJETO_SEQ';
        exception
            -- não faz nada, ignora o erro quando a sequence não existe
            when others then null;
        end;
        execute immediate 'CREATE SEQUENCE PROJETO_SEQ INCREMENT BY 1 START WITH ' || max_projeto_id || ' NOCACHE' ;
    exception
        when others then
            dbms_output.put_line ('>>>ERRO<<< ao criar sequence de projetos. Verificar!');
    end;
    -- /\ Especial para projeto.

      --populas as sequences que tem nome diferente do padrão.
      tabelas(tabelas.count+1).nome_tabela := 'CATEGORIA_DESPESA_ENTIDADE';
      tabelas(tabelas.count).nome_coluna := 'ID';
      tabelas(tabelas.count).nome_sequence := 'CAT_DESP_ENT_SEQ';
          
      -- popula os itens para criar a sequence
      tabelas(tabelas.count+1).nome_tabela := 'ATIVIDADE';
      tabelas(tabelas.count).nome_coluna := 'ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'BASELINE';
      tabelas(tabelas.count).nome_coluna := 'BASELINE_ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'BASELINE_DEPENDENCIAS';
      tabelas(tabelas.count).nome_coluna := 'BASELINE_DEPENDENCIAS_ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'BASELINE_ENTIDADE';
      tabelas(tabelas.count).nome_coluna := 'BASELINE_ENTIDADE_ID';
           
      tabelas(tabelas.count+1).nome_tabela := 'BASELINE_RESPONSAVEL';
      tabelas(tabelas.count).nome_coluna := 'BASELINE_RESPONSAVEL_ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'BASELINE_VH_USUARIO';
      tabelas(tabelas.count).nome_coluna := 'BASELINE_VH_USUARIO_ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'CHECKLIST';
      tabelas(tabelas.count).nome_coluna := 'CHECKLIST_ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'CHECKLIST_CATEGORIA';
      tabelas(tabelas.count).nome_coluna := 'CHECKLIST_CATEGORIA_ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'CHECKLIST_ITEM';
      tabelas(tabelas.count).nome_coluna := 'CHECKLIST_ITEM_ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'DEPENDENCIA';
      tabelas(tabelas.count).nome_coluna := 'ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'DEPENDENCIAATIVIDADETAREFA';
      tabelas(tabelas.count).nome_coluna := 'DEPENDENCIAATIVIDADETAREFAID';
      
      tabelas(tabelas.count+1).nome_tabela := 'DESTINO';
      tabelas(tabelas.count).nome_coluna := 'DESTINOID';
      
      tabelas(tabelas.count+1).nome_tabela := 'ESCOPO';
      tabelas(tabelas.count).nome_coluna := 'PROJETO';
      
      tabelas(tabelas.count+1).nome_tabela := 'HISTORICOACEITEPROJETO';
      tabelas(tabelas.count).nome_coluna := 'ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'HISTORICOACEITEUSUARIO';
      tabelas(tabelas.count).nome_coluna := 'ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'HISTORICOAPROVACAOENTIDADE';
      tabelas(tabelas.count).nome_coluna := 'ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'HISTORICOAPROVACAOESCOPO';
      tabelas(tabelas.count).nome_coluna := 'ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'HISTORICO_DISTRIBUICAO_DOC';
      tabelas(tabelas.count).nome_coluna := 'HISTORICO_DISTRIBUICAO_DOC_ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'HISTORICOPAPELPROJETORECURSO';
      tabelas(tabelas.count).nome_coluna := 'HISTORICOID';
           
      tabelas(tabelas.count+1).nome_tabela := 'HISTORICORESPONSAVELENTIDADE';
      tabelas(tabelas.count).nome_coluna := 'ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'HISTORICORISCO';
      tabelas(tabelas.count).nome_coluna := 'HISTORICORISCOID';
      
      tabelas(tabelas.count+1).nome_tabela := 'HISTORICODOCUMENTO';
      tabelas(tabelas.count).nome_coluna := 'HISTORICODOCUMENTOID';
           
      tabelas(tabelas.count+1).nome_tabela := 'HISTORICOSOLICITACOESESCOPO';
      tabelas(tabelas.count).nome_coluna := 'ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'HISTORICOUSUARIO';
      tabelas(tabelas.count).nome_coluna := 'ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'HISTORICOVISTORIAENTIDADE';
      tabelas(tabelas.count).nome_coluna := 'ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'PAPELPROJETO';
      tabelas(tabelas.count).nome_coluna := 'PAPELPROJETOID';
      
      tabelas(tabelas.count+1).nome_tabela := 'PONTOELETRONICO';
      tabelas(tabelas.count).nome_coluna := 'ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'PONTOELETRONICOREAL';
      tabelas(tabelas.count).nome_coluna := 'ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'RISCO';
      tabelas(tabelas.count).nome_coluna := 'RISCOID';
      
      tabelas(tabelas.count+1).nome_tabela := 'TAREFA';
      tabelas(tabelas.count).nome_coluna := 'ID';

-- A PARTIR DA 5.0
      -- popula os itens para criar a sequence
      tabelas(tabelas.count+1).nome_tabela := 'RESPOSTA_ASSOCIADA';
      tabelas(tabelas.count).nome_coluna := 'resposta_associada_id';

      tabelas(tabelas.count+1).nome_tabela := 'QUESTAO_ASSOCIADA';
      tabelas(tabelas.count).nome_coluna := 'questao_associada_id';

      tabelas(tabelas.count+1).nome_tabela := 'resposta_questao_historico';
      tabelas(tabelas.count).nome_coluna := 'resposta_questao_historico_id';

      tabelas(tabelas.count+1).nome_tabela := 'tipo_indicador';
      tabelas(tabelas.count).nome_coluna := 'tipo_indicador_ID';

      tabelas(tabelas.count+1).nome_tabela := 'indicador_historico_situacoes';
      tabelas(tabelas.count).nome_coluna := 'indicador_historico_sit_id';

      tabelas(tabelas.count+1).nome_tabela := 'ATRIBUTO_VALOR';
      tabelas(tabelas.count).nome_coluna := 'ATRIBUTO_VALOR_id';

      tabelas(tabelas.count+1).nome_tabela := 'h_demanda';
      tabelas(tabelas.count).nome_coluna := 'id';

      tabelas(tabelas.count+1).nome_tabela := 'NOTIFICACAO';
      tabelas(tabelas.count).nome_coluna := 'NOTIFICACAO_id';

      tabelas(tabelas.count+1).nome_tabela := 'campo_notificacao';
      tabelas(tabelas.count).nome_coluna := 'campo_notificacao_id';

      tabelas(tabelas.count+1).nome_tabela := 'NOTIFICACAO';
      tabelas(tabelas.count).nome_coluna := 'NOTIFICACAO_id';

      tabelas(tabelas.count+1).nome_tabela := 'notificacao_pendente';
      tabelas(tabelas.count).nome_coluna := 'notificacao_pendente_id';

      tabelas(tabelas.count+1).nome_tabela := 'FORMULARIO';
      tabelas(tabelas.count).nome_coluna := 'FORMULARIO_ID';

      tabelas(tabelas.count+1).nome_tabela := 'TERMO';
      tabelas(tabelas.count).nome_coluna := 'TERMO_ID';

      tabelas(tabelas.count+1).nome_tabela := 'GRUPO_CADASTRO';
      tabelas(tabelas.count).nome_coluna := 'ID';

      tabelas(tabelas.count+1).nome_tabela := 'DEMANDA';
      tabelas(tabelas.count).nome_coluna := 'DEMANDA_ID';

      tabelas(tabelas.count+1).nome_tabela := 'DESTINO';
      tabelas(tabelas.count).nome_coluna := 'DESTINOID';

      tabelas(tabelas.count+1).nome_tabela := 'BENEFICIO';
      tabelas(tabelas.count).nome_coluna := 'BENEFICIOID';

      tabelas(tabelas.count+1).nome_tabela := 'PRIORIDADE';
      tabelas(tabelas.count).nome_coluna := 'PRIORIDADEID';

      tabelas(tabelas.count+1).nome_tabela := 'TIPOSOLICITACAO';
      tabelas(tabelas.count).nome_coluna := 'TIPOSOLICITACAOID';

      tabelas(tabelas.count+1).nome_tabela := 'ESTADO';
      tabelas(tabelas.count).nome_coluna := 'ESTADO_ID';

      tabelas(tabelas.count+1).nome_tabela := 'INDICADOR';
      tabelas(tabelas.count).nome_coluna := 'INDICADOR_ID';

      tabelas(tabelas.count+1).nome_tabela := 'SECAO';
      tabelas(tabelas.count).nome_coluna := 'SECAO_ID';

      tabelas(tabelas.count+1).nome_tabela := 'SECAO_ATRIBUTO';
      tabelas(tabelas.count).nome_coluna := 'SECAO_ATRIBUTO_ID';

      tabelas(tabelas.count+1).nome_tabela := 'INDICADOR_ASSOCIADO';
      tabelas(tabelas.count).nome_coluna := 'INDICADOR_ASSOCIADO_ID';

      tabelas(tabelas.count+1).nome_tabela := 'DOCUMENTO';
      tabelas(tabelas.count).nome_coluna := 'DOCUMENTOID';

      tabelas(tabelas.count+1).nome_tabela := 'LINK';
      tabelas(tabelas.count).nome_coluna := 'LINK_ID';

      tabelas(tabelas.count+1).nome_tabela := 'EMPRESA';
      tabelas(tabelas.count).nome_coluna := 'ID';

      tabelas(tabelas.count+1).nome_tabela := 'TRADUCAO';
      tabelas(tabelas.count).nome_coluna := 'TRADUCAO_ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'FILTRO_FAVORITO';
      tabelas(tabelas.count).nome_coluna := 'FILTRO_FAVORITO_ID';

      tabelas(tabelas.count+1).nome_tabela := 'categoria_formulario';
      tabelas(tabelas.count).nome_coluna := 'categoria_formulario_ID';

      tabelas(tabelas.count+1).nome_tabela := 'FILTRO';
      tabelas(tabelas.count).nome_coluna := 'ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'RESPOSTA_ASSOCIADA';
      tabelas(tabelas.count).nome_coluna := 'resposta_associada_id';

      tabelas(tabelas.count+1).nome_tabela := 'QUESTAO_ASSOCIADA';
      tabelas(tabelas.count).nome_coluna := 'questao_associada_id';

      tabelas(tabelas.count+1).nome_tabela := 'resposta_questao_historico';
      tabelas(tabelas.count).nome_coluna := 'resposta_questao_historico_id';

      tabelas(tabelas.count+1).nome_tabela := 'tipo_indicador';
      tabelas(tabelas.count).nome_coluna := 'tipo_indicador_ID';

      tabelas(tabelas.count+1).nome_tabela := 'indicador_historico_situacoes';
      tabelas(tabelas.count).nome_coluna := 'indicador_historico_sit_id';

      tabelas(tabelas.count+1).nome_tabela := 'ATRIBUTO_VALOR';
      tabelas(tabelas.count).nome_coluna := 'ATRIBUTO_VALOR_id';

      tabelas(tabelas.count+1).nome_tabela := 'h_demanda';
      tabelas(tabelas.count).nome_coluna := 'id';

      tabelas(tabelas.count+1).nome_tabela := 'NOTIFICACAO';
      tabelas(tabelas.count).nome_coluna := 'NOTIFICACAO_id';

      tabelas(tabelas.count+1).nome_tabela := 'campo_notificacao';
      tabelas(tabelas.count).nome_coluna := 'campo_notificacao_id';

      tabelas(tabelas.count+1).nome_tabela := 'NOTIFICACAO';
      tabelas(tabelas.count).nome_coluna := 'NOTIFICACAO_id';

      tabelas(tabelas.count+1).nome_tabela := 'notificacao_pendente';
      tabelas(tabelas.count).nome_coluna := 'notificacao_pendente_id';

      tabelas(tabelas.count+1).nome_tabela := 'FORMULARIO';
      tabelas(tabelas.count).nome_coluna := 'FORMULARIO_ID';

      tabelas(tabelas.count+1).nome_tabela := 'TERMO';
      tabelas(tabelas.count).nome_coluna := 'TERMO_ID';

      tabelas(tabelas.count+1).nome_tabela := 'GRUPO_CADASTRO';
      tabelas(tabelas.count).nome_coluna := 'ID';

      tabelas(tabelas.count+1).nome_tabela := 'DEMANDA';
      tabelas(tabelas.count).nome_coluna := 'DEMANDA_ID';

      tabelas(tabelas.count+1).nome_tabela := 'BENEFICIO';
      tabelas(tabelas.count).nome_coluna := 'BENEFICIOID';

      tabelas(tabelas.count+1).nome_tabela := 'PRIORIDADE';
      tabelas(tabelas.count).nome_coluna := 'PRIORIDADEID';

      tabelas(tabelas.count+1).nome_tabela := 'TIPOSOLICITACAO';
      tabelas(tabelas.count).nome_coluna := 'TIPOSOLICITACAOID';

      tabelas(tabelas.count+1).nome_tabela := 'ESTADO';
      tabelas(tabelas.count).nome_coluna := 'ESTADO_ID';

      tabelas(tabelas.count+1).nome_tabela := 'INDICADOR';
      tabelas(tabelas.count).nome_coluna := 'INDICADOR_ID';

      tabelas(tabelas.count+1).nome_tabela := 'SECAO';
      tabelas(tabelas.count).nome_coluna := 'SECAO_ID';

      tabelas(tabelas.count+1).nome_tabela := 'INDICADOR_ASSOCIADO';
      tabelas(tabelas.count).nome_coluna := 'INDICADOR_ASSOCIADO_ID';

      tabelas(tabelas.count+1).nome_tabela := 'DOCUMENTO';
      tabelas(tabelas.count).nome_coluna := 'DOCUMENTOID';

      tabelas(tabelas.count+1).nome_tabela := 'LINK';
      tabelas(tabelas.count).nome_coluna := 'LINK_ID';

      tabelas(tabelas.count+1).nome_tabela := 'EMPRESA';
      tabelas(tabelas.count).nome_coluna := 'ID';

      tabelas(tabelas.count+1).nome_tabela := 'TRADUCAO';
      tabelas(tabelas.count).nome_coluna := 'TRADUCAO_ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'FILTRO_FAVORITO';
      tabelas(tabelas.count).nome_coluna := 'FILTRO_FAVORITO_ID';
        
      tabelas(tabelas.count+1).nome_tabela := 'categoria_formulario';
      tabelas(tabelas.count).nome_coluna := 'categoria_formulario_ID';
        
      tabelas(tabelas.count+1).nome_tabela := 'FILTRO';
      tabelas(tabelas.count).nome_coluna := 'ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'CATEGORIA_CONHECIMENTO';
      tabelas(tabelas.count).nome_coluna := 'ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'BASE_CONHECIMENTO';
      tabelas(tabelas.count).nome_coluna := 'ID';
        
      tabelas(tabelas.count+1).nome_tabela := 'H_BASE_CONHECIMENTO';
      tabelas(tabelas.count).nome_coluna := 'ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'ESTADO_SLA';
      tabelas(tabelas.count).nome_coluna := 'ESTADO_SLA_ID';
        
      tabelas(tabelas.count+1).nome_tabela := 'ESTADO_SLA_FORMULARIO';
      tabelas(tabelas.count).nome_coluna := 'ESTADO_SLA_FORM_ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'MODELO_DEMANDA';
      tabelas(tabelas.count).nome_coluna := 'MODELO_DEMANDA_ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'UO';
      tabelas(tabelas.count).nome_coluna := 'ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'CENTRO_CUSTO';
      tabelas(tabelas.count).nome_coluna := 'ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'ITEM_INVENTARIO';
      tabelas(tabelas.count).nome_coluna := 'ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'H_ITEM_INVENTARIO';
      tabelas(tabelas.count).nome_coluna := 'ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'COMPONENTE_INVENTARIO';
      tabelas(tabelas.count).nome_coluna := 'ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'H_COMPONENTE_INVENTARIO';
      tabelas(tabelas.count).nome_coluna := 'ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'TIPO_INVENTARIO';
      tabelas(tabelas.count).nome_coluna := 'TIPO_INVENTARIO_ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'INVENTARIO_CAMPO';
      tabelas(tabelas.count).nome_coluna := 'ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'DEMANDA_INVENTARIO';
      tabelas(tabelas.count).nome_coluna := 'ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'USUARIODIVISAO';
      tabelas(tabelas.count).nome_coluna := 'ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'CATEGORIA_ASSOCIADA';
      tabelas(tabelas.count).nome_coluna := 'CATEGORIA_ASSOCIADA_ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'PARTE_INTERESSADA';
      tabelas(tabelas.count).nome_coluna := 'PARTE_INTERESSADA_ID';
        
      tabelas(tabelas.count+1).nome_tabela := 'ATRIBUTOENTIDADEVALOR';
      tabelas(tabelas.count).nome_coluna := 'ATRIBUTOENTIDADEID';
     
      tabelas(tabelas.count+1).nome_tabela := 'CATEGORIA_CONHEC_FORM';
      tabelas(tabelas.count).nome_coluna := 'ID';
            
      tabelas(tabelas.count+1).nome_tabela := 'HISTORICOUSUARIO';
      tabelas(tabelas.count).nome_coluna := 'ID';
           
      tabelas(tabelas.count+1).nome_tabela := 'TIPO_INVENTARIO_CAMPO';
      tabelas(tabelas.count).nome_coluna := 'TIPO_INVENTARIO_CAMPO_ID';
      
      tabelas(tabelas.count+1).nome_tabela := 'EQUIPE';
      tabelas(tabelas.count).nome_coluna := 'EQUIPE_ID';

      tabelas(tabelas.count+1).nome_tabela := 'ATRIBUTO';
      tabelas(tabelas.count).nome_coluna := 'ATRIBUTOID';

    --Sequences da 5.0.1
       
    tabelas(tabelas.count+1).nome_tabela := 'MAP_DEST_TRANS_ESTADO';
    tabelas(tabelas.count).nome_coluna := 'MAPEAMENTO_ID';

    tabelas(tabelas.count+1).nome_tabela := 'TRANSICAO_ESTADO';
    tabelas(tabelas.count).nome_coluna := 'TRANSICAO_ESTADO_ID';
 
    tabelas(tabelas.count+1).nome_tabela := 'categoria';
    tabelas(tabelas.count).nome_coluna := 'CATEGORIA_ID';

    tabelas(tabelas.count+1).nome_tabela := 'QUESTAO';
    tabelas(tabelas.count).nome_coluna := 'QUESTAO_ID';

    tabelas(tabelas.count+1).nome_tabela := 'RESPOSTA';
    tabelas(tabelas.count).nome_coluna := 'RESPOSTA_ID';
    
    -- 5.0.1.2
    tabelas(tabelas.count+1).nome_tabela := 'PRIORIZACAO_FORMULARIO';
    tabelas(tabelas.count).nome_coluna := 'PRIORIZACAO_ID';
 
	-- 5.1
	tabelas(tabelas.count+1).nome_tabela := 'DASHBOARD';
    tabelas(tabelas.count).nome_coluna := 'ID';
	
	tabelas(tabelas.count+1).nome_tabela := 'DASHBOARD_COLUNA';
    tabelas(tabelas.count).nome_coluna := 'ID';
	
	tabelas(tabelas.count+1).nome_tabela := 'DASHBOARD_PORTLET';
    tabelas(tabelas.count).nome_coluna := 'ID';
	
	tabelas(tabelas.count+1).nome_tabela := 'PORTLET';
    tabelas(tabelas.count).nome_coluna := 'ID';
	
	tabelas(tabelas.count+1).nome_tabela := 'PORTLET_INFORMACAO';
    tabelas(tabelas.count).nome_coluna := 'ID';
	
	tabelas(tabelas.count+1).nome_tabela := 'PORTLET_CUSTOMIZACAO';
    tabelas(tabelas.count).nome_coluna := 'ID';
	
	tabelas(tabelas.count+1).nome_tabela := 'COMUNICACAO_DASHBOARD';
    tabelas(tabelas.count).nome_coluna := 'ID';
	
	tabelas(tabelas.count+1).nome_tabela := 'EMAIL_INTERESSADO';
    tabelas(tabelas.count).nome_coluna := 'ID';
	
	tabelas(tabelas.count+1).nome_tabela := 'DASHBOARD_FAVORITO';
    tabelas(tabelas.count).nome_coluna := 'ID';
	
	tabelas(tabelas.count+1).nome_tabela := 'ATALHOS_PESSOAIS';
    tabelas(tabelas.count).nome_coluna := 'ID';
	
	tabelas(tabelas.count+1).nome_tabela := 'AGENDAMENTO';
    tabelas(tabelas.count).nome_coluna := 'ID';
	
  tabelas(tabelas.count+1).nome_tabela := 'ABERTURA_VIA_EMAIL';
    tabelas(tabelas.count).nome_coluna := 'ABERTURA_VIA_EMAIL_ID';
    
  
      -- inclui os dados em VERSAO_SEQUENCIA
      for cont in tabelas.first..tabelas.last loop
          if length(tabelas(cont).nome_tabela) > 26 then
             -- Garante o tamanho do nome da sequence
             nomeSeq := Substr(tabelas(cont).nome_tabela,0, 26) || '_SEQ';
          else 
               nomeSeq := tabelas(cont).nome_tabela || '_SEQ';
          end if;
          if tabelas(cont).nome_sequence is not null then
            nomeSeq := tabelas(cont).nome_sequence; --Nome de sequence especial
          end if;
          
          insert into versao_sequencia(id, versao_tgp_id, nome_sequencia, tabela, coluna)
                 values (versao_sequencia_seq.nextval, 1, lower(nomeSeq), 
                         lower(tabelas(cont).nome_tabela), lower(tabelas(cont).nome_coluna));       
      end loop; 
      commit;
end;
/
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- OBJETOS DA VERSÃO 5.2.0.0 (CUSTOS) --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_TIPO_INVENTARIO');                                                                                                                             
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_TIPO_INVENTARIO_CAMPO');                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'TIPO_OCORRENCIA');                                                                                                                                
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_TIPO_OCORRENCIA');                                                                                                                             
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_TIPOQUALIDADE');                                                                                                                               
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'TRACEGP_CONFIG');                                                                                                                                 
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_TRACEGP_CONFIG');                                                                                                                              
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_TRADUCAO_01');                                                                                                                                
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'UK_USUARIO_01');                                                                                                                                  
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_VALOR_HORA_USUARIO_01');                                                                                                                      
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_VALOR_HORA_USUARIO_02');                                                                                                                      
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_VERSAO_DOC_GER_PERM_INFO');                                                                                                                    
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'VERSAO_LOG');                                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_VERSAO_LOG');                                                                                                                                  
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'VERSAO_OBJETO');                                                                                                                                  
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_VERSAO_OBJETO');                                                                                                                               
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_VERSAO_OBJETO_01');                                                                                                                           
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'VERSAO_SEQUENCIA');                                                                                                                               
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_VERSAO_SEQUENCIA');                                                                                                                            
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_VERSAO_SEQUENCIA_01');                                                                                                                        
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'VERSAO_TGP');                                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_VERSAO_TGP');                                                                                                                                  
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_VISTORIADORENTIDADE');                                                                                                                         
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'MLOG$_CUSTO_LANCAMENTO');                                                                                                                         
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'RUPD$_CUSTO_LANCAMENTO');                                                                                                                         
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'MLOG$_CUSTO_ENTIDADE');                                                                                                                           
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'RUPD$_CUSTO_ENTIDADE');                                                                                                                           
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'MLOG$_CUSTO_RECEITA');                                                                                                                            
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'RUPD$_CUSTO_RECEITA');                                                                                                                            
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'MV_CUSTO_LANCAMENTO');                                                                                                                            
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'MATERIALIZED VIEW', 'MV_CUSTO_LANCAMENTO');                                                                                                                
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_MV_CUSTO_LANCAMENTO_01');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_MV_CUSTO_LANCAMENTO_02');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_MV_CUSTO_LANCAMENTO_03');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_MV_CUSTO_LANCAMENTO_04');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_VALOR_HORA_SIMPLIFICADA');                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_VALOR_HORA');                                                                                                                                    
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_CUSTO_HORA_TRABALHADA');                                                                                                                         
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_CUSTO_TAREFA');                                                                                                                                  
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_CUSTO_RESPONSAVEL');                                                                                                                             
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_DIAS');                                                                                                                                          
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_DIAS_FUTURO');                                                                                                                                   
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_CRONOGRAMA_HIERARQUIA');                                                                                                                         
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_ENTIDADE_DEPENDENTES');                                                                                                                          
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_DEMANDA_DEPENDENTES');                                                                                                                           
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_DEMANDA_ENTIDADES');                                                                                                                             
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_DEMANDA_ENTIDADES_DEP');                                                                                                                         
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_CUSTO_ENTIDADE');                                                                                                                                
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_RESUMO_CUSTOS');                                                                                                                                 
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_RESUMO_CUSTOS_DEM');                                                                                                                             
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_CUSTOS_CRONOGRAMA');                                                                                                                             
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_ARVORE_CUSTOS_DEPENDENTES');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_RESUMO_CUSTOS_ARVORE');                                                                                                                          
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_CUSTOS_ARVORE_ANALITICO');                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_CUSTOS_ARVORE_ANALITICO_DEM');                                                                                                                   
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_CUSTOS_ARVORE_SINTETICO');                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_CUSTOS_ARVORE_SINTETICO_DEM');                                                                                                                   
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_CUSTOS_ARVORE_COMPLETA');                                                                                                                        
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_CUSTOS_ARVORE_COMPLETA_DEM');                                                                                                                    
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_EVA_IPG');                                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_VARIAVEIS_EVA');                                                                                                                                 
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_EVA_PERCENTUAL_DADOS');                                                                                                                          
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_EVA_CALCULO_DADOS');                                                                                                                             
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_EVA_CALCULO_DADOS_TEMPO');                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_EVA');                                                                                                                                           
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_EVA_TEMPO');                                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_BASELINE_VARIAVEIS_EVA');                                                                                                                        
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_BASELINE_EVA_PERC_DADOS');                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_BASELINE_EVA_DADOS');                                                                                                                            
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_BASELINE_EVA_DADOS_TEMPO');                                                                                                                      
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_BASELINE_EVA');                                                                                                                                  
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_BASELINE_EVA_TEMPO');                                                                                                                            
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_ARVORE_CUSTOS_DEP_CAMINHO');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_CENTROS_CUSTOS_DEPENDENTES');                                                                                                                    
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_CENTRO_CUSTOS_DEP_CAMINHO');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_DADOS_CRONO_DESEMBOLSO');                                                                                                                        
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_DADOS_CRONO_RH');                                                                                                                                
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_ENTIDADE_DEP_CAMINHO');                                                                                                                          
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_BASELINE_DEPENDENTES');                                                                                                                          
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_BASELINE_HIERARQUIA');                                                                                                                           
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_BASELINE_VH_SIMPLIFICADA');                                                                                                                      
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'JOB', 'JOB_PROCESSO_NOTURNO_TRACEGP');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'PACKAGE', 'PCK_AJUSTE_CC');                                                                                                                                
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'PACKAGE', 'PCK_VERSAO');                                                                                                                                   
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'PACKAGE', 'PCK_GERAL');                                                                                                                                    
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_ATIVIDADE_01');                                                                                                                               
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_ATIVIDADE_02');                                                                                                                               
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_ATRIBUTO_CATEGORIA');                                                                                                                          
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'ATRIBUTO_CATEGORIA_DESTINO');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_ATRIBUTO_CATEGORIA_DESTINO');                                                                                                                  
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_ATRIBUTO_FORM_ESTADO_01');                                                                                                                    
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_ATRIBUTO_VALOR');                                                                                                                              
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_ATRIBUTO_VALOR_01');                                                                                                                          
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_BASE_CONHECIMENTO');                                                                                                                           
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_01');                                                                                                                                
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_02');                                                                                                                                
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'BASELINE_CUSTO_ENTIDADE');                                                                                                                        
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_BASELINE_CUSTO_ENTIDADE');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_CUSTO_ENTIDADE_01');                                                                                                                 
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_CUSTO_ENTIDADE_02');                                                                                                                 
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_CUSTO_ENTIDADE_03');                                                                                                                 
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_CUSTO_ENTIDADE_04');                                                                                                                 
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'BASELINE_CUSTO_LANCAMENTO');                                                                                                                      
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_BASELINE_CUSTO_LANC');                                                                                                                         
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_CUSTO_LANC_01');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_CUSTO_LANC_02');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_CUSTO_LANC_03');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_CUSTO_LANC_04');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_DEPENDENCIAS_01');                                                                                                                   
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_DEPENDENCIAS_02');                                                                                                                   
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_DEPENDENCIAS_03');                                                                                                                   
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_ENTIDADE_01');                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_ENTIDADE_02');                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_ENTIDADE_03');                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_ENTIDADE_04');                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_ENTIDADE_05');                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_ENTIDADE_06');                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'BASELINE_EVA');                                                                                                                                   
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_BASELINE_EVA');                                                                                                                                
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'UK_BASELINE_EVA');                                                                                                                                
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_EVA_01');                                                                                                                            
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'BASELINE_EVA_TEMPO');                                                                                                                             
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_BASELINE_EVA_TEMPO');                                                                                                                          
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'UK_BASELINE_EVA_TEMPO_01');                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_EVA_TEMPO_01');                                                                                                                      
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'BASELINE_HORATRABALHADA');                                                                                                                        
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_BASELINE_HORATRABALHADA');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_HORATRABALHADA_01');                                                                                                                 
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_HORATRABALHADA_02');                                                                                                                 
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_HORATRABALHADA_03');                                                                                                                 
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_CUSTO_LANCAMENTO_01');                                                                                                                        
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_CUSTO_LANCAMENTO_02');                                                                                                                        
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_CUSTO_LANCAMENTO_03');                                                                                                                        
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'CUSTO_RECEITA');                                                                                                                                  
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_CUSTO_RECEITA');                                                                                                                               
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_CUSTO_RECEITA_01');                                                                                                                           
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'CUSTO_RECEITA_FORMA');                                                                                                                            
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_CUSTO_RECEITA_FORMA');                                                                                                                         
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_CUSTO_RECEITA_FORMA_01');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_CUSTO_RECEITA_FORMA_02');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'CUSTO_RECEITA_TIPO');                                                                                                                             
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_CUSTO_RECEITA_TIPO');                                                                                                                          
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_CUSTO_RECEITA_TIPO_01');                                                                                                                      
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_CUSTO_RECEITA_TIPO_02');                                                                                                                      
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_DASHBOARD_FAVORITO');                                                                                                                          
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_DEMANDA');                                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_DEMANDA_03');                                                                                                                                 
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_DEST_FORM_USUARIO');                                                                                                                           
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_DESTINO_FORM_USUARIO_01');                                                                                                                    
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_DEST_INICIAL_USUARIO_01');                                                                                                                    
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_DESTINO_USUARIO');                                                                                                                             
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_DETALHE_DISPONIVEL_ATRIBUTO');                                                                                                                 
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'DOCUMENTO_CONTEUDO');                                                                                                                             
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_DOCUMENTO_CONTEUDO');                                                                                                                          
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'UK_DOCUMENTO_CONTEUDO_01');                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'ENTIDADE');                                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_ENTIDADE');                                                                                                                                    
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_ENTIDADE_01');                                                                                                                                
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_EQUIVALENCIASSITUACOES');                                                                                                                      
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_ESCOPO');                                                                                                                                      
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'BASELINE_PERC_CONCLUIDO');                                                                                                                        
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_BASELINE_PERC_CONCLUIDO');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'UK_BASELINE_PERC_CONCLUIDO_01');                                                                                                                  
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_PERC_CONCLUIDO_01');                                                                                                                 
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_RESPONSAVEL_01');                                                                                                                    
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_RESPONSAVEL_02');                                                                                                                    
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_VH_USUARIO_01');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_VH_USUARIO_02');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_BASELINE_VH_USUARIO_03');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'CAMPO_CONDICIONAL_SE');                                                                                                                           
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_CAMPO_CONDICIONAL_SE');                                                                                                                        
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_CAMPO_FORMULARIO_01');                                                                                                                        
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_CAMPO_MAPEAMENTO');                                                                                                                            
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_CATEGORIA_CONHEC_FORM_01');                                                                                                                   
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_CATEGORIA_CONHECIMENTO');                                                                                                                      
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_CATEGORIA_FORMULARIO');                                                                                                                        
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'CATEGORIA_ITEM_ATRIBUTO');                                                                                                                        
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_CATEGORIA_ITEM_ATRIBUTO');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_CENTRO_CUSTO');                                                                                                                                
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'COMP_MODELO_IMPRESSAO');                                                                                                                          
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_COMP_MODELO_IMPRESSAO');                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'CONDICIONAL_SE_SENAO');                                                                                                                           
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_CONDICIONAL_SE_SENAO');                                                                                                                        
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_CONHECIMENTO_USUARIO');                                                                                                                        
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'CUSTO_ENTIDADE');                                                                                                                                 
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_CUSTO_ENTIDADE');                                                                                                                              
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_CUSTO_ENTIDADE_01');                                                                                                                          
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_CUSTO_ENTIDADE_02');                                                                                                                          
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_CUSTO_ENTIDADE_03');                                                                                                                          
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_CUSTO_ENTIDADE_04');                                                                                                                          
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'CUSTO_LANCAMENTO');                                                                                                                               
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_CUSTO_LANCAMENTO');                                                                                                                            
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_ESTADO');                                                                                                                                      
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_ESTADO_FORMULARIO_01');                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'ESTADO_REGRA_CONDICIONAL');                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_ESTADO_REGRA_CONDICIONAL');                                                                                                                    
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_ESTADO_SLA_FORMULARIO_01');                                                                                                                   
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'EVA');                                                                                                                                            
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_EVA');                                                                                                                                         
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'UK_EVA_01');                                                                                                                                      
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_EVA_01');                                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'EVA_IPG');                                                                                                                                        
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_EVA_IPG');                                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_EVA_IPG_01');                                                                                                                                 
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'EVA_TEMPO');                                                                                                                                      
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_EVA_TEMPO');                                                                                                                                   
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'UK_EVA_TEMPO_01');                                                                                                                                
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_EVENTO_ITEM_PL_COMUNIC');                                                                                                                      
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_FILTRO');                                                                                                                                      
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_FILTRO_FAVORITO');                                                                                                                             
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_FORMULARIO');                                                                                                                                  
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_FORMULARIO_01');                                                                                                                              
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'FORMULARIO_ADMIN');                                                                                                                               
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_FORMULARIO_ADMIN');                                                                                                                            
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_FORMULARIO_ADMIN_01');                                                                                                                        
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_FORMULARIO_ADMIN_02');                                                                                                                        
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_FORMULARIO_DESTINO_01');                                                                                                                      
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_FORMULARIO_PERFIL');                                                                                                                          
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'H_ATIVIDADE');                                                                                                                                    
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_H_ATIVIDADE');                                                                                                                                 
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_H_ATIVIDADE_01');                                                                                                                             
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_H_BASE_CONHECIMENTO');                                                                                                                         
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_H_DEMANDA_04');                                                                                                                               
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_H_DEMANDA_05');                                                                                                                               
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_H_INDICADOR_ASSOCIADO');                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'H_PROJETO');                                                                                                                                      
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_H_PROJETO');                                                                                                                                   
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_H_PROJETO_01');                                                                                                                               
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'H_TAREFA');                                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_H_TAREFA');                                                                                                                                    
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_H_TAREFA_01');                                                                                                                                
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_H_TAREFA_02');                                                                                                                                
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_HINT_FORMULARIO');                                                                                                                             
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_HINT_FORMULARIO_01');                                                                                                                         
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_HISTORICORESPONSAVELENT');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_HORATRABALHADA_01');                                                                                                                          
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_HORATRABALHADA_02');                                                                                                                          
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_HORATRABALHADA_03');                                                                                                                          
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'UK_HORA_TRABALHADA_TAXI_01');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_INDICADOR_FORMULARIO_01');                                                                                                                    
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_IND_POSSIVEL_FORM_01');                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'UK_INFORMACAO_DISP_DOC_01');                                                                                                                      
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_LOG_BATCH');                                                                                                                                   
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PARTICIPANTE_PC_STAKEHOLDER');                                                                                                                    
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_PARTICIPANTE_REL_PORTFOLIO');                                                                                                                  
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'PERCENTUAL_CONCLUIDO');                                                                                                                           
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_PERCENTUAL_CONCLUIDO');                                                                                                                        
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'UK_PERCENTUAL_CONCLUIDO_01');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_PORTLET');                                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_PRIORIDADE_FORMULARIO_01');                                                                                                                   
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_PROXIMO_ESTADO_01');                                                                                                                          
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_BASELINE_VALOR_HORA');                                                                                                                           
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_CUSTO_BASELINE_HT');                                                                                                                             
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_CUSTO_BASELINE_ENTIDADE');                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_DADOS_BASELINE_RH');                                                                                                                             
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_ENT_DEPENDENTES_BASELINE');                                                                                                                      
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_ENT_DEP_CAMINHO_BASELINE');                                                                                                                      
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'VIEW', 'V_EVOLUCAO_HISTORICA');                                                                                                                            
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'PACKAGE BODY', 'PCK_AJUSTE_CC');                                                                                                                           
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'PACKAGE BODY', 'PCK_GERAL');                                                                                                                               
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'PACKAGE BODY', 'PCK_VERSAO');                                                                                                                              
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'PACKAGE BODY', 'PCK_EVA');                                                                                                                                 
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'PACKAGE BODY', 'PCK_PROCESSO');                                                                                                                            
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'PACKAGE BODY', 'PCK_PROJETO');                                                                                                                             
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TRIGGER', 'TRG_USUARIO_EVA_IUD_AR');                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TRIGGER', 'TRG_TIPOPROFISS_EVA_IUD_AR');                                                                                                                   
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TRIGGER', 'TRG_VH_USUARIO_EVA_IUD_AR');                                                                                                                    
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TRIGGER', 'TRG_HORATRABALHADA_EVA_IUD_AR');                                                                                                                
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TRIGGER', 'TRG_RESPONSAVELENT_EVA_IUD_AR');                                                                                                                
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TRIGGER', 'TRG_CUSTO_ENTID_EVA_IUD_AR');                                                                                                                   
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TRIGGER', 'TRG_CUSTO_LANC_EVA_IUD_AR');                                                                                                                    
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TRIGGER', 'TRG_PERC_CONCLUIDO_IUD_BS');                                                                                                                    
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TRIGGER', 'TRG_PERC_CONCLUIDO_IUD_AR');                                                                                                                    
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TRIGGER', 'TRG_PERC_CONCLUIDO_IUD_AS');                                                                                                                    
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TRIGGER', 'TRG_TAREFA_PERC_CONC_IUD_BS');                                                                                                                  
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TRIGGER', 'TRG_TAREFA_PERC_CONC_IUD_AR');                                                                                                                  
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TRIGGER', 'TRG_TAREFA_PERC_CONC_IUD_AS');                                                                                                                  
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TRIGGER', 'TRG_ATIVIDADE_PERC_CONC_IU_BS');                                                                                                                
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TRIGGER', 'TRG_ATIVIDADE_PERC_CONC_IU_AR');                                                                                                                
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TRIGGER', 'TRG_ATIVIDADE_PERC_CONC_IU_AS');                                                                                                                
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TRIGGER', 'TRG_PROJETO_PERC_CONC_IU_BS');                                                                                                                  
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TRIGGER', 'TRG_PROJETO_PERC_CONC_IU_AR');                                                                                                                  
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TRIGGER', 'TRG_PROJETO_PERC_CONC_IU_AS');                                                                                                                  
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TRIGGER', 'TRG_CUSTO_ENTIDADE_CHK_IU_AR');                                                                                                                 
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TRIGGER', 'TRG_PROJETO_HIST_IU_AR');                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TRIGGER', 'TRG_ATIVIDADE_HIST_IU_AR');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TRIGGER', 'TRG_TAREFA_HIST_IU_AR');                                                                                                                        
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TRIGGER', 'TRG_RESPENT_HIST_IU_AR');                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TRIGGER', 'TRG_CUSTO_RECEITA_FORMA_IU_AS');                                                                                                                
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TRIGGER', 'TRG_CUSTO_RECEITA_TIPO_IU_AS');                                                                                                                 
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_MODELO_DEMANDA_01');                                                                                                                          
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'MODELO_IMPRESSAO_FORM');                                                                                                                          
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_MODELO_IMPRESSAO_FORM');                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_MODELO_IMPRESSAO_FORM_01');                                                                                                                   
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_MODELO_IMPRESSAO_FORM_02');                                                                                                                   
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_MODELO_REL_PORTFOLIO');                                                                                                                        
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_NOTIFICACAO_01');                                                                                                                             
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'OBJETO');                                                                                                                                         
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_OBJETO');                                                                                                                                      
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'OBJETO_CAMPO');                                                                                                                                   
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_OBJETO_CAMPO');                                                                                                                                
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'OBJETO_CAMPO_FORM_ESTADO');                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_OBJETO_CAMPO_FORM_ESTADO');                                                                                                                    
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'UK_OBJETO_CAMPO_FORM_EST_01');                                                                                                                    
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'OCORRENCIA_ENTIDADE');                                                                                                                            
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_OCORRENCIA_ENTIDADE');                                                                                                                         
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_ORIGEM');                                                                                                                                      
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_PAPELPROJETORECURSO_03');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_PARTICIPANTE_MSG_STAKEH');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'REGRA_CONDICIONAL');                                                                                                                              
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_REGRA_CONDICIONAL');                                                                                                                           
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_REGRA_DESTINO_01');                                                                                                                           
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_REGRA_FORMULARIO_01');                                                                                                                        
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'REGRA_FORMULARIO_PERFIL');                                                                                                                        
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_REGRA_FORMULARIO_PERFIL');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_RELATORIO');                                                                                                                                   
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_RELATORIO_PORTFOLIO');                                                                                                                         
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_RESPONSAVELENTIDADE_01');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_RISCO_ENTIDADE');                                                                                                                              
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_SECAO');                                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_SECAO_01');                                                                                                                                   
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_SECAO_ATRIBUTO');                                                                                                                              
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'SECAO_ATRIBUTO_OBJETO');                                                                                                                          
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_SECAO_ATRIBUTO_OBJETO');                                                                                                                       
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'UK_SLA_DEM_FINALIZADA');                                                                                                                          
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_SOLICITACAOENTIDADE_01');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_SOLICITACAOENTIDADE_02');                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_TAREFA_01');                                                                                                                                  
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_TAREFA_02');                                                                                                                                  
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_TAREFA_03');                                                                                                                                  
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_TAREFA_04');                                                                                                                                  
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'UK_TELA');                                                                                                                                        
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'TIPO_DOCUMENTO');                                                                                                                                 
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_TIPO_DOCUMENTO');                                                                                                                              
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_TIPO_FORMULARIO_01');                                                                                                                         
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_ABA_01');                                                                                                                                     
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_ABERTURA_VIA_EMAIL_01');                                                                                                                      
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_ABERTURA_VIA_EMAIL_02');                                                                                                                      
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_ABERTURA_VIA_EMAIL_03');                                                                                                                      
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_ABERTURA_VIA_EMAIL_04');                                                                                                                      
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'TABLE', 'ACAO_CONDICIONAL');                                                                                                                               
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_ACAO_CONDICIONAL');                                                                                                                            
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_ACAO_CONDICIONAL_01');                                                                                                                        
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_ACAO_CONDICIONAL_02');                                                                                                                        
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_ACAO_CONDICIONAL_03');                                                                                                                        
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_AGENDAMENTO_DETALHE');                                                                                                                         
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_AJUSTE_PTO_EXCED_CRONOMETRO');                                                                                                                 
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_ALOCACAO_01');                                                                                                                                
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_ALOCACAO_02');                                                                                                                                
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'IDX_ALTERACAOESCOPO_01');                                                                                                                         
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'INDEX', 'PK_ANEXO_MODELO_DOC');                                                                                                                            
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'PACKAGE', 'PCK_EVA');                                                                                                                                      
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'PACKAGE', 'PCK_PROCESSO');                                                                                                                                 
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 2, 'PACKAGE', 'PCK_PROJETO');                                                                                                                                  

insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'CATEGORIA_ITEM_ATRIBUTO_SEQ', 'CATEGORIA_ITEM_ATRIBUTO', 'CATEGORIA_ITEM_ID');                                                                                                      
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'COMP_MODELO_IMPRESSAO_SEQ', 'COMP_MODELO_IMPRESSAO', 'id');                                                                                                        
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'CONDICIONAL_SE_SENAO_SEQ', 'CONDICIONAL_SE_SENAO', 'id');                                                                                                         
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'CUSTO_ENTIDADE_SEQ', 'CUSTO_ENTIDADE', 'id');                                                                                                               
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'CUSTO_LANCAMENTO_SEQ', 'CUSTO_LANCAMENTO', 'id');                                                                                                             
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'CUSTO_RECEITA_SEQ', 'CUSTO_RECEITA', 'id');                                                                                                                
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'CUSTO_RECEITA_FORMA_SEQ', 'CUSTO_RECEITA_FORMA', 'id');                                                                                                          
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'CUSTO_RECEITA_TIPO_SEQ', 'CUSTO_RECEITA_TIPO', 'id');                                                                                                           
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'DOCUMENTO_CONTEUDO_SEQ', 'DOCUMENTO_CONTEUDO', 'id');                                                                                                           
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'DOMINIOAPLICACAO_SEQ', 'DOMINIOAPLICACAO', 'DOMINIOID');                                                                                                             
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'DOMINIOATRIBUTO_SEQ', 'DOMINIOATRIBUTO', 'DOMINIOATRIBUTOID');                                                                                                              
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'ENTIDADE_SEQ', 'ENTIDADE', 'id');                                                                                                                     
--insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'ESTADO_FORMULARIO_SEQ', 'ESTADO_FORMULARIO', 'ID');                                                                                                            
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'ESTADO_REGRA_CONDIC_SEQ', 'ESTADO_REGRA_CONDICIONAL', 'id');                                                                                                          
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'EVA_SEQ', 'EVA', 'id');                                                                                                                          
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'EVA_TEMPO_SEQ', 'EVA_TEMPO', 'id');                                                                                                                    
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'FORMULARIO_ADMIN_SEQ', 'FORMULARIO_ADMIN', 'id');                                                                                                             
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'H_ATIVIDADE_SEQ', 'H_ATIVIDADE', 'id');                                                                                                                  
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'H_PROJETO_SEQ', 'H_PROJETO', 'id');                                                                                                                    
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'H_TAREFA_SEQ', 'H_TAREFA', 'id');                                                                                                                     
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'H_USUARIO_SEQ', 'H_USUARIO', 'id');                                                                                                                    
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'HORA_TRABALHADA_TAXIMETRO_SEQ', 'HORA_TRABALHADA_TAXIMETRO', 'HORA_TRABALHADA_TAXIMETRO_ID');                                                                                                    
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'MAPEAMENTO_ENTIDADE_ESTADO_SEQ', 'MAPEAMENTO_ENTIDADE_ESTADO', 'MAP_ID');                                                                                                   
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'MODELO_IMPRESSAO_FORM_SEQ', 'MODELO_IMPRESSAO_FORM', 'id');                                                                                                        
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'NOTIFICACAO_ESTADO_ENTIDAD_SEQ', 'NOTIFICACAO_ESTADO_ENTIDADE', 'NOTIFICACAOID');                                                                                                   
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'OBJETO_SEQ', 'OBJETO', 'id');                                                                                                                       
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'OBJETO_CAMPO_SEQ', 'OBJETO_CAMPO', 'id');                                                                                                                 
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'OBJETO_CAMPO_FORM_ESTADO_SEQ', 'OBJETO_CAMPO_FORM_ESTADO', 'id');                                                                                                     
--insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'OCORRENCIA_ENTIDADE_SEQ', 'OCORRENCIA_ENTIDADE', 'ID');                                                                                                          
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'ORIGEM_SEQ', 'ORIGEM', 'ORIGEMID');                                                                                                                       
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'PERCENTUAL_CONCLUIDO_SEQ', 'PERCENTUAL_CONCLUIDO', 'id');                                                                                                         
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'PROJETO_SEQ', 'PROJETO', 'id');                                                                                                                      
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'REGRA_CONDICIONAL_SEQ', 'REGRA_CONDICIONAL', 'id');                                                                                                            
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'SECAO_ATRIBUTO_OBJETO_SEQ', 'SECAO_ATRIBUTO_OBJETO', 'id');                                                                                                        
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'TIPO_DOCUMENTO_SEQ', 'TIPO_DOCUMENTO', 'id');                                                                                                               
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'TIPO_OCORRENCIA_SEQ', 'TIPO_OCORRENCIA', 'id');                                                                                                              
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'TIPODESPESA_SEQ', 'TIPODESPESA', 'id');                                                                                                                  
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'TIPOTAREFA_SEQ', 'TIPOTAREFA', 'id');                                                                                                                   
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'USUARIO_SEQ', 'USUARIO', 'USUARIOID');                                                                                                                      
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'VERSAO_SEQ', 'VERSAO', 'id');                                                                                                                       
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'VERSAO_LOG_SEQ', 'VERSAO_LOG', 'id');                                                                                                                   
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'VERSAO_OBJETO_SEQ', 'VERSAO_OBJETO', 'id');                                                                                                                
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'VERSAO_SEQUENCIA_SEQ', 'VERSAO_SEQUENCIA', 'id');                                                                                                             
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'BASELINE_CUSTO_LANCAMENTO_SEQ', 'BASELINE_CUSTO_LANCAMENTO', 'id');                                                                                                    
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'BASELINE_EVA_SEQ', 'BASELINE_EVA', 'id');                                                                                                                 
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'BASELINE_EVA_TEMPO_SEQ', 'BASELINE_EVA_TEMPO', 'id');                                                                                                           
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'BASELINE_HORATRABALHADA_SEQ', 'BASELINE_HORATRABALHADA', 'id');                                                                                                      
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'BASELINE_PERC_CONCLUIDO_SEQ', 'BASELINE_PERC_CONCLUIDO', 'id');                                                                                                      
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'CAMPO_CONDICIONAL_SE_SEQ', 'CAMPO_CONDICIONAL_SE', 'id');                                                                                                         
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'SLA_DEM_FINALIZADA_SEQ', 'SLA_DEM_FINALIZADA', 'id');                                                                                                           
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'H_SOLICITACAO_AJUSTE_PONTO_SEQ', 'H_SOLICITACAO_AJUSTE_PONTO', 'id');                                                                                                   
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'ACAO_CONDICIONAL_SEQ', 'ACAO_CONDICIONAL', 'id');                                                                                                             
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'BASELINE_CUSTO_ENTIDADE_SEQ', 'BASELINE_CUSTO_ENTIDADE', 'id');                                                                                                      
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'TIPOPROJETO_SEQ', 'TIPOPROJETO', 'TIPOPROJETOID');                                                                                                                  
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'INV_SOFTWARE_SEQ', 'INV_SOFTWARE', 'ID'); 
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'FABRICANTE_SEQ', 'FABRICANTE', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'ATRIBUTO_COLUNA_SEQ', 'ATRIBUTO_COLUNA', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'DOMINIO_ATRIBUTO_COLUNA_SEQ', 'DOMINIO_ATRIBUTO_COLUNA', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'SLA_SEQ', 'SLA', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 2, 'SLA_NIVEL_SEQ', 'SLA_NIVEL', 'ID');

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- OBJETOS DA VERSÃO 5.3.0.0 (CALENDÁRIO) --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'ATRIBUTO_COLUNA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'DOMINIO_ATRIBUTO_COLUNA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'INV_SOFTWARE');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'SLA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'SLA_NIVEL');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'FILTRO_CAMPO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'DEMANDA_FAIXAS_SLA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'DEMANDA_SLA_FINAL');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'SLA_ATIVO_DEMANDA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'ESTADO_FORMULARIO_FORMULARIO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'ESTADO_FORMULARIO_TEMPLATE_PRJ');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'ESTADO_MENSAGENS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'ESTADO_MENSAGENS_ITENS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'OLD_INFO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'OLD_DET');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'PROJETO_FORMULARIO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_INDICADOR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_INDICADOR_APURACAO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_INDICADOR_APURACAO_VAR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_INDICADOR_CATEGORIA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_INDICADOR_DOM_VAR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_INDICADOR_FORMULA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_INDICADOR_QUEBRA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_INDICADOR_QUESTAO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_INDICADOR_QUESTAO_RESP');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_INDICADOR_RESPOSTA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_INDICADOR_VARIAVEL');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_META');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_META_FAIXA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_META_FAIXA_DEST');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_OBJETIVO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_OBJETIVO_AGRUPADOR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_OBJETIVO_APURACAO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_OBJETIVO_META');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_OBJETIVO_FAIXA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_OBJETIVO_FAIXA_DEST');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_ROTINA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_ROTINA_PARAMS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_ROTINA_PARAMS_VALOR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'CONFIGURACOES_TEMPLATE');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_BASELINE_ORCAMENTO_GERAL');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_OCORRENCIA_ENTIDADE_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_PROJETO_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_PROJETO_03');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_USUARIO_05');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'DIA_PK');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_FORMULARIO_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_ESTADO_FORMULARIO_03');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_INVENTARIO_CAMPO_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_ATRIBUTO_COLUNA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_DOMINIO_ATRIBUTO_COLUNA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_DOMINIO_ATRIBUTO_COLUNA_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_DOMINIO_ATRIBUTO_COLUNA_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_DOMINIO_ATRIBUTO_COLUNA_03');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_DOMINIO_ATRIBUTO_COLUNA_04');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_INV_SOFTWARE');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_INV_SOFTWARE_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_INV_SOFTWARE_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_INV_SOFTWARE_03');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_SLA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_SLA_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_SLA_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_SLA_03');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_SLA_NIVEL');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'SLA_NIVEL_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'SLA_NIVEL_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_H_ATRIBUTO_VALOR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_FILTRO_CAMPO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_DEMANDA_FAIXAS_SLA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_DEMANDA_FAIXAS_SLA_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_DEMANDA_SLA_FINAL');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_DEMANDA_SLA_FINAL_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_DEMANDA_SLA_FINAL_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_DEMANDA_SLA_FINAL_03');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_DEMANDA_SLA_FINAL_04');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_SLA_ATIVO_DEMANDA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_SLA_ATIVO_DEMANDA_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_SLA_ATIVO_DEMANDA_03');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_SLA_ATIVO_DEMANDA_04');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_ESTADO_FORMULARIO_FORMU');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_ESTADO_FORM_TEMPLATE_PRJ');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_ESTADO_MENSAGENS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_ESTADO_MENSAGENS_ITENS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PROJETO_FORMULARIO_PK');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_INDICADOR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_03');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_04');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'FUNCTION', 'F_DIAS_UTEIS_ENTRE');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_05');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_06');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_07');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_08');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_09');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_10');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_11');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_12');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_13');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_14');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_15');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_INDICADOR_APURACAO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'UK_MAPA_INDICADOR_APURACAO_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_APURACAO_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_APURACAO_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_APURACAO_03');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_APURACAO_04');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_APURACAO_05');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_APURACAO_06');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_IND_APURACAO_VAR_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_IND_APURACAO_VAR_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_IND_APURACAO_VAR_03');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_IND_APURACAO_VAR_04');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_IND_APURACAO_VAR_05');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_IND_APURACAO_VAR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_IND_CATEGORIA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_IND_CATEGORIA_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_IND_DOM_VAR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_IND_DOM_VAR_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_IND_DOM_VAR_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_IND_DOM_VAR_03');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_IND_DOM_VAR_04');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_INDICADOR_FORMULA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'UK_MAPA_INDICADOR_FORMULA_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_FORMULA_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_FORMULA_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_FORMULA_03');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_FORMULA_04');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_FORMULA_05');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_FORMULA_06');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_QUEBRA_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_INDICADOR_QUEBRA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_QUEBRA_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_QUEBRA_03');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_QUEBRA_04');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_QUEBRA_05');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_INDICADOR_QUESTAO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_QUESTAO_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_QUESTAO_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_IND_QUESTAO_RESP_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_IND_QUESTAO_RESP');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_IND_QUESTAO_RESP_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_INDICADOR_RESPOSTA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_RESPOSTA_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_INDICADOR_VARIAVEL');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'UK_MAPA_INDICADOR_VARIAVEL_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'UK_MAPA_INDICADOR_VARIAVEL_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_VARIAVEL_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_VARIAVEL_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_VARIAVEL_03');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_VARIAVEL_04');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_INDICADOR_VARIAVEL_05');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_META');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_META_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_META_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_META_03');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_META_04');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_META_05');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_META_06');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_META_FAIXA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'UK_MAPA_META_FAIXA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_META_FAIXA_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_META_FAIXA_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_META_FAIXA_03');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_META_FAIXA_04');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_META_FAIXA_DEST');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_META_FAIXA_DEST_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_META_FAIXA_DEST_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_META_FAIXA_DEST_03');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_META_FAIXA_DEST_04');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_META_FAIXA_DEST_05');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_OBJETIVO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_OBJETIVO_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_OBJETIVO_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_OBJETIVO_03');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_OBJETIVO_AGRUPADOR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_OBJETIVO_AGRUPADOR_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_OBJETIVO_AGRUPADOR_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_OBJETIVO_APURACAO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'UK_MAPA_OBJETIVO_APURACAO_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_OBJETIVO_APURACAO_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_OBJETIVO_APURACAO_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_OBJETIVO_APURACAO_03');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_OBJETIVO_APURACAO_04');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_OBJETIVO_APURACAO_05');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_OBJETIVO_META');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_OBJETIVO_META_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_OBJETIVOS_META_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_OBJETIVO_META_03');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_OBJETIVO_META_04');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_OBJETIVO_META_05');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_OBJETIVO_FAIXA_04');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_OBJETIVO_FAIXA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'UK_MAPA_OBJETIVO_FAIXA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_OBJETIVO_FAIXA_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_OBJETIVO_FAIXA_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_OBJETIVO_FAIXA_03');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_OBJ_FAIXA_DEST_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_OBJ_FAIXA_DEST_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_OBJ_FAIXA_DEST_03');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_OBJ_FAIXA_DEST_04');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_OBJ_FAIXA_DEST_05');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_OBJETIVO_META_FAIXA_DEST');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_ROTINA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'UK_MAPA_ROTINA_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_ROTINA_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_ROTINA_PARAMS_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_ROTINA_PARAMS_03');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_ROTINA_PARAMS_04');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_ROTINA_PARAMS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'UK_MAPA_ROTINA_PARAMS_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'UK_MAPA_ROTINA_PARAMS_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_ROTINA_PARAMS_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_ROTINA_PARAMS_VALOR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'UK_MAPA_ROTINA_PARAMS_VALOR_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_ROTINA_PARAMS_VAL_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_ROTINA_PARAMS_VAL_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_ROTINA_PARAMS_VAL_03');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_ROTINA_PARAMS_VAL_04');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_ROTINA_PARAMS_VAL_05');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_CONFIGURACAO_TEMPLATE');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_CONFIGURACAO_TEMPLATE_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_PROJETO_STAKEHOLDER');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_PROJETO_ATRIBUTO_ARVORE');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_PROJETO_ATRIBUTO_EMPRESA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_PROJETO_ATRIBUTO_LISTA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_PROJETO_ATRIBUTO_PROJETO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_PROJETO_ATRIBUTO_USUARIO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_PROJETO_CENTRO_CUSTO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_EVA_CALCULO_DIVERSO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_VERSAO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_OBJETIVOS_INDICADORES_RESUMO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_OBJETIVOS_SUBORDINADOS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'PACKAGE BODY', 'PCK_SLA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'PACKAGE BODY', 'PCK_ATRIBUTO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'PACKAGE BODY', 'PCK_PROXIMO_ESTADO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'PACKAGE BODY', 'PCK_SLA_NIVEL');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'PACKAGE BODY', 'PCK_SLA_ATIVO_DEMANDA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'PACKAGE BODY', 'PCK_ESTADO_FORMULARIO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'PACKAGE BODY', 'PCK_DOCUMENTO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'PACKAGE BODY', 'PCK_REL_ACOMPANHAMENTO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'PACKAGE BODY', 'PCK_CONDICIONAL');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'PACKAGE BODY', 'PCK_INDICADOR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_AJUSTE_FILTRO_CAMPO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_ATRIBUTO_SLA_IUD_AR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_ATRIBUTO_SLA_IUD_AS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_ATRIBUTO_SLA_IUD_BS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_DEMANDA_SLA_IUD_AR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_DEMANDA_SLA_IUD_AS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_DEMANDA_SLA_IUD_BS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_ESTADO_FORMULARIO_IUD_AR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_ESTADO_FORMULARIO_IUD_AS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_ESTADO_FORMULARIO_IUD_BS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_PERC_CONCLUIDO_CHK_IU_AR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_PROXIMO_ESTADO_IUD_AR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_PROXIMO_ESTADO_IUD_AS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_PROXIMO_ESTADO_IUD_BS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_SLA_ATIVO_DEMANDA_IUD_AR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_SLA_ATIVO_DEMANDA_IUD_AS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_SLA_ATIVO_DEMANDA_IUD_BS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_SLA_IUD_AR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_SLA_IUD_AS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_SLA_IUD_BS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_SLA_NIVEL_IUD_AR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_SLA_NIVEL_IUD_AS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_SLA_NIVEL_IUD_BS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MLOG$_USUARIO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'RUPD$_USUARIO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MLOG$_VALOR_HORA_USUARIO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'RUPD$_VALOR_HORA_USUARIO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MLOG$_TIPOPROFISSIONAL');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'RUPD$_TIPOPROFISSIONAL');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MV_VALOR_HORA_SIMPLIFICADA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'MATERIALIZED VIEW', 'MV_VALOR_HORA_SIMPLIFICADA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MV_VALOR_HORA_SIMPL_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MV_VALOR_HORA_SIMPL_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MV_VALOR_HORA_SIMPL_03');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_PONTOELET_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_RESPONSAVELENTIDADE_03');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDK_DIA_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'UK_CONHECIMENTO_USUARIO_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_PROJETO_05');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_TAREFA_05');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_USUARIO_06');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_USUARIO_07');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'CALENDARIO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_CALENDARIO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_CALENDARIO_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_CALENDARIO_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'CONHECIMENTO_PROFISSIONAL');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_CONHECIMENTO_PROFISSIONAL');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'CONHEC_USUARIO_AVAL');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_CONHEC_USUARIO_AVAL');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'DIAGRAMA_NODO_ENTIDADE');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_DIAGRAMA_NODO_ENTIDADE');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'UK_DIAGRAMA_NODO_ENTIDADE_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'DIAGRAMA_REDE_VISAO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_DIAGRAMA_VISAO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'DIAGRAMA_VISAO_NODOS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_DIAGRAMA_VISAO_NODO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'DIAGRAMA_VISAO_PROJETO_PADRAO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_DIAG_VISAO_PROJ_PADRAO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'UK_DIAG_VISAO_PROJ_PADRAO_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'FORMULARIO_FLUXO_DESENHO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'HORA_ALOCADA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_HORA_ALOCADA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'UK_HORA_ALOCADA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_HORA_ALOCADA_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_CONSULTA_PARAMS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_CONSULTA_PARAMS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_ESTRATEGICO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_ESTRATEGICO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_ESTRATEGICO_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_MAPA_ESTRATEGICO_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_OBJETIVO_PL_ACAO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_OBJETIVO_PL_ACAO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'PACKAGE', 'PCK_INDICADOR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TYPE', 'T_TIPO_CAMPOS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'PACKAGE', 'PCK_DOCUMENTO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'PACKAGE', 'PCK_ATRIBUTO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'PACKAGE', 'PCK_PROXIMO_ESTADO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'PACKAGE', 'PCK_SLA_NIVEL');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'PACKAGE', 'PCK_SLA_ATIVO_DEMANDA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'PACKAGE', 'PCK_ESTADO_FORMULARIO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'PACKAGE', 'PCK_CONDICIONAL');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'PACKAGE', 'PCK_SLA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'FUNCTION', 'F_GET_PERIODO_DATA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'PACKAGE', 'PCK_REL_ACOMPANHAMENTO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_OBJETIVO_PL_ACAO_INIC');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_OBJETIVO_PL_ACAO_INIC');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_PERSPECTIVA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_PERSPECTIVA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_RELACAO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_RELACAO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_VISAO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_VISAO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_VISAO_COMPONENTE');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_VISAO_COMPONENTE');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'MAPA_VISAO_COMP_CAMPOS_LIST');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_MAPA_VISAO_CAMPOS_LIST');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'REGRA_CALENDARIO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_REGRA_CALENDARIA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_REGRA_CALENDARIO_01');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_REGRA_CALENDARIO_02');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_REGRA_CALENDARIO_03');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_REGRA_CALENDARIO_04');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_REGRA_CALENDARIO_05');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_REGRA_CALENDARIO_06');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'IDX_REGRA_CALENDARIO_07');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TABLE', 'TIPO_PERIODO_NAO_UTIL');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'INDEX', 'PK_TIPO_PERIODO_NAO_UTIL');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_DIAS_FUTUROS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_DIRETORIO_EQUIPE');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_TIPO_PROFISSIONAL_VIGENTE');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_CALENDARIO_DEPENDENTE');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_REGRA_CALENDARIO_DETALHE');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_REGRA_CALENDARIO_BASE');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_REGRA_CALENDARIO_USUARIO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_REGRA_CALENDARIO_PROJETO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_REGRA_CALENDARIO_RECURSO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_REGRA_CAL_RECURSO_DIR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_CALENDARIO_BASE_SR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_CALENDARIO_BASE');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_CALENDARIO_USUARIO_SR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_CALENDARIO_USUARIO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_CALENDARIO_PROJETO_SR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_CALENDARIO_PROJETO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_CALENDARIO_RECURSO_SR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_CALENDARIO_RECURSO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_CARGA_HORARIA_PADRAO_USUARIO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_CARGA_HORARIA_PADRAO_RECURSO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_ALOCACAO_TAREFA_RESUMO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_ALOCACAO_TAREFA');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_ALOCACAO_USUARIO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_ALOCACAO_PROJETO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_DISTRIBUICAO_USUARIO_PRJ');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_DISTRIBUICAO_USUARIO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_DEPENDENCIA_PROJETOS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_RESP_ADM_DETALHE');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_RESP_ADM');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_RESP_PROJETOS_DETALHE_ALL');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_RESP_PROJETOS_DETALHE');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_RESP_PROJETOS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'VIEW', 'V_RESPONSABILIDADE');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_REGRA_CALENDARIO_IU_BR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_HORA_ALOCADA_IU_BR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_ESTADO_FORM_SINCDES_IUD_AR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_PROX_ESTADO_SINCDES_IUD_AR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_TRAN_ESTADO_SINCDES_IUD_AR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_FORMULARIO_SINCDES_IU_BR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_FORM_FLUXO_DESENHO_IU_BR');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_MAPA_OBJETIVO_D_AS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'PACKAGE', 'PCK_CALENDARIO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'PACKAGE BODY', 'PCK_CALENDARIO');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_MAPA_PERSPECTIVA_D_AS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_MAPA_ESTRATEGICO_D_AS');
insert into versao_objeto(id, versao_tgp_id, tipo_objeto, nome_objeto) values (versao_objeto_seq.nextval, 3, 'TRIGGER', 'TRG_MAPA_INDICADOR_D_AS');


insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'CONHECIMENTO_PROFISSIONAL_SEQ', 'CONHECIMENTO_PROFISSIONAL', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'CONHECIMENTO_USUARIO_SEQ', 'CONHECIMENTO_USUARIO', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'CONHEC_USUARIO_AVAL_SEQ', 'CONHEC_USUARIO_AVAL', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'TIPO_PERIODO_NAO_UTIL_SEQ', 'TIPO_PERIODO_NAO_UTIL', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'VALOR_HORA_USUARIO_SEQ', 'VALOR_HORA_USUARIO', 'VALOR_HORA_USUARIO_ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_ESTRATEGICO_SEQ', 'MAPA_ESTRATEGICO', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'HORA_ALOCADA_SEQ', 'HORA_ALOCADA', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'RESPONSABILIDADE_SEQ', 'RESPONSABILIDADE', 'RESPONSABILIDADEID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'LOG_VALOR_HORA_USUARIO_SEQ', 'LOG_VALOR_HORA_USUARIO', 'LOG_VALOR_HORA_USUARIO_ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_INDICADOR_APURACAO_SEQ', 'MAPA_INDICADOR_APURACAO', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_INDICADOR_CATEGORIA_SEQ', 'MAPA_INDICADOR_CATEGORIA', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_INDICADOR_DOM_VAR_SEQ', 'MAPA_INDICADOR_DOM_VAR', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_INDICADOR_QUEBRA_SEQ', 'MAPA_INDICADOR_QUEBRA', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_INDICADOR_QUESTAO_SEQ', 'MAPA_INDICADOR_QUESTAO', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_INDICADOR_RESPOSTA_SEQ', 'MAPA_INDICADOR_RESPOSTA', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_INDICADOR_SEQ', 'MAPA_INDICADOR', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_INDICADOR_VARIAVEL_SEQ', 'MAPA_INDICADOR_VARIAVEL', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_IND_APURACAO_VAR_SEQ', 'MAPA_INDICADOR_APURACAO_VAR', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_IND_QUESTAO_RESP_SEQ', 'MAPA_INDICADOR_QUESTAO_RESP', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_META_FAIXA_DEST_SEQ', 'MAPA_META_FAIXA_DEST', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_META_FAIXA_SEQ', 'MAPA_META_FAIXA', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_META_SEQ', 'MAPA_META', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_OBJETIVO_APURACAO_SEQ', 'MAPA_OBJETIVO_APURACAO', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_OBJETIVO_FAIXA_DEST_SEQ', 'MAPA_OBJETIVO_FAIXA_DEST', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_OBJETIVO_FAIXA_SEQ', 'MAPA_OBJETIVO_FAIXA', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_OBJETIVO_META_SEQ', 'MAPA_OBJETIVO_META', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_OBJETIVO_SEQ', 'MAPA_OBJETIVO', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_ROTINA_PARAMS_SEQ', 'MAPA_ROTINA_PARAMS', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_ROTINA_PARAMS_VALOR_SEQ', 'MAPA_ROTINA_PARAMS_VALOR', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_ROTINA_SEQ', 'MAPA_ROTINA', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'FILTRO_CAMPO_SEQ', 'FILTRO_CAMPO', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'CALENDARIO_SEQ', 'CALENDARIO', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'DIAGRAMA_NODO_ENTIDADE_SEQ', 'DIAGRAMA_NODO_ENTIDADE', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'DIAGRAMA_REDE_VISAO_SEQ', 'DIAGRAMA_REDE_VISAO', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'DIAGRAMA_VISAO_NODO_SEQ', 'DIAGRAMA_VISAO_NODOS', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_CONSULTA_PARAMS_SEQ', 'MAPA_CONSULTA_PARAMS', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_OBJETIVO_PL_ACAO_SEQ', 'MAPA_OBJETIVO_PL_ACAO', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'DEMANDA_SLA_FINAL_SEQ', 'DEMANDA_SLA_FINAL', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_OBJETIVO_PL_ACAO_INIC_SEQ', 'MAPA_OBJETIVO_PL_ACAO_INIC', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_PERSPECTIVA_SEQ', 'MAPA_PERSPECTIVA', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_RELACAO_SEQ', 'MAPA_RELACAO', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_VISAO_SEQ', 'MAPA_VISAO', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_VISAO_COMPONENTE_SEQ', 'MAPA_VISAO_COMPONENTE', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'MAPA_VISAO_CAMPOS_LIST_SEQ', 'MAPA_VISAO_COMP_CAMPOS_LIST', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'REGRA_CALENDARIO_SEQ', 'REGRA_CALENDARIO', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'ESTADO_MENSAGENS_ITENS_SEQ', 'ESTADO_MENSAGENS_ITENS', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'ESTADO_MENSAGENS_SEQ', 'ESTADO_MENSAGENS', 'ID');
insert into versao_sequencia (id, versao_tgp_id, nome_sequencia, tabela, coluna) values (versao_sequencia_seq.nextval, 3, 'LOG_TRACEGP_SEQ', 'LOG_TRACEGP', 'ID');

commit;
/
