/******************************************************************************\
* Roteiro para migra��o � vers�o de calend�rio (5.3.0.0)                       *
* Parte II - Inclus�o/Altera��o de dados b�sicos do TraceGP                    *
* Autor: Charles Falc�o                     Data de Publica��o:   /   /2009    *
\******************************************************************************/


-- Dependencias entre projetos
update dependenciaatividadetarefa set projeto_predecessora = projeto;
commit;
/

-- Tabela TELA
delete tela where telaid = 442;
commit;
/

update tela set ordem=ordem+2 where grupoid=6 and ordem>8;
update tela set ordem=7 where codigo='ATIVIDADE_FORCA_TRABALHO';
update tela set ordem=8 where codigo='PENDENCIAS_GERENTE';
update tela set ordem=9 where codigo='AGENDA_GERENTE';

update tela set url = 'ConhecimentoProfissional.do?command=defaultAction' where telaid = 305;

insert into tela (telaid,nome,url,visivel,grupoid,ordem,codigo,subgrupo,atalho)
       values (462, 'bd.tela.templatePapeis', 'TemplatePapel.do?command=defaultAction',
               'S', 7, 23, 'TEMPLATE_PAPEIS', 'PRIMEIRO', 'N');

insert into tela(telaid, nome, url, visivel, grupoid, ordem, codigo, subgrupo, atalho)
       values (463, 'bd.tela.tiposPeriodoNaoUtil', null, 
               'S', 7, null, 'TIPOS_PERIODO_NAO_UTIL', null, 'N');
 
update tela set ordem = ordem + 1 where ordem > 2 and grupoid = 7;                
insert into tela (telaid, nome, url, visivel, grupoid, ordem, codigo, subgrupo, atalho)
       values (464, 'bd.tela.calendario', 'Calendario.do?command=defaultAction',
               'S', 7, 3, 'CALENDARIO', 'PRIMEIRO', 'N');
               
insert into GRUPO (GRUPOID,DESCRICAO,PERSPECTIVA,ORDEM) 
       values (28,'bd.grupo.mapaestrategico',1,6); 

insert into TELA (TELAID,NOME,URL,VISIVEL,GRUPOID,ORDEM,CODIGO,SUBGRUPO,ATALHO) 
       values (466,'label.prompt.mapaEstrategico','MapaEstrategico.do?command=defaultAction',
               'S',28,1,'MAPA_ESTRATEGICO','PRIMEIRO','N');
               
insert into tela (telaid,nome,url,visivel,grupoid,ordem,codigo,subgrupo,atalho)
	     values (470,'bd.tela.gerenciamentoRecurso','GerenciamentoRecurso.do?command=defaultAction',
               'S',6,10,'GERENCIAMENTO_RECURSO','PRIMEIRO','N'); 
               
commit;
/        
 
-- Modifica��es de Agenda
---------------------------------------------------------------------- 
---- AP_247 � Aloca��o em tarefas 
-- Atualizar e corrigir a ordem das abas 
-- Tarefa avulsa (Minha Vis�o) / 
update ABA set ORDEM=3 where ABAID=2; 
update ABA set ORDEM=4 where ABAID=3; 
update ABA set ORDEM=5 where ABAID=4; 
update ABA set ORDEM=6 where ABAID=5; 
update ABA set ORDEM=7 where ABAID=8; 
update ABA set ORDEM=8 where ABAID=37; 
update ABA set ORDEM=9 where ABAID=52; 
update ABA set ORDEM=10 where ABAID=77; 
update ABA set ORDEM=11 where ABAID=88; 
update ABA set ORDEM=12 where ABAID=86; 

-- Tarefa avulsa (For�a de Trabalho) 
update ABA set ORDEM=3 where ABAID=63; 
update ABA set ORDEM=4 where ABAID=64; 
update ABA set ORDEM=5 where ABAID=65; 
update ABA set ORDEM=6 where ABAID=66; 
update ABA set ORDEM=7 where ABAID=69; 
update ABA set ORDEM=8 where ABAID=70; 
update ABA set ORDEM=9 where ABAID=71; 
update ABA set ORDEM=10 where ABAID=79; 
update ABA set ORDEM=11 where ABAID=89; 
update ABA set ORDEM=12 where ABAID=87; 

-- Tarefa de projeto 
update ABA set ORDEM=3 where ABAID=27; 
update ABA set ORDEM=4 where ABAID=28; 
update ABA set ORDEM=5 where ABAID=29; 
update ABA set ORDEM=6 where ABAID=30; 
update ABA set ORDEM=7 where ABAID=33; 
update ABA set ORDEM=8 where ABAID=36; 
update ABA set ORDEM=9 where ABAID=40; 
update ABA set ORDEM=10 where ABAID=55; 
update ABA set ORDEM=11 where ABAID=78; 
update ABA set ORDEM=12 where ABAID=81; 


---------------------------------------------------------------------- 
---- AP_247 � Aloca��o em tarefas 
-- Inclus�o de abas 
-- Aba 'Plano de Aloca��o' na tarefa avulsa (Minha Vis�o) (painelabaid = 1) 
INSERT INTO ABA (ABAID, NOME, PAINELABAID, OCULTAR, SRC, VALIDARTROCAABA, SCRIPTVALIDACAOCUSTOM, ORDEM) VALUES (90, 'bd.aba.aba90', 1, 'S', 'PlanoAlocacao.do?command=defaultAction'||CHR(38)||'idEntidade=<request.attribute.idEntidade/>','N', NULL, 2); 

-- Aba 'Plano de Aloca��o' na tarefa avulsa (For�a de Trabalho) (painelabaid = 9) 
INSERT INTO ABA (ABAID, NOME, PAINELABAID, OCULTAR, SRC, VALIDARTROCAABA, SCRIPTVALIDACAOCUSTOM, ORDEM) VALUES (91, 'bd.aba.aba90', 9, 'S', 'PlanoAlocacao.do?command=defaultAction'||CHR(38)||'idEntidade=<request.attribute.idEntidade/>','N', NULL, 2); 

-- Aba 'Plano de Aloca��o' na tarefa projeto (painelabaid = 4) 
INSERT INTO ABA (ABAID, NOME, PAINELABAID, OCULTAR, SRC, VALIDARTROCAABA, SCRIPTVALIDACAOCUSTOM, ORDEM) VALUES (92, 'bd.aba.aba90', 4, 'S', 'PlanoAlocacao.do?command=defaultAction'||CHR(38)||'idEntidade=<form.TarefaProjetoForm.tarefaId/>','N', NULL, 2); 

delete from aba where abaid in (90,91,92);

---------------------------------------------------------------------- 
---- AP_247 � Aloca��o em tarefas 
-- Inclus�o da tela "Agenda" 
-- Menu Minha Vis�o 
update tela set ordem=ordem+1 where grupoid=2 and ordem >4; 

insert into tela (telaid,nome,url,visivel,grupoid,ordem,codigo,subgrupo) values (441,'bd.tela.agenda','AgendaUsuario.do?command=defaultUsuarioAction','S',2,5,'AGENDA_USUARIO','PRIMEIRO'); 

-- Menu For�a de Trabalho 
update tela set ordem=ordem+1 where grupoid=6 and ordem >6; 

insert into tela (telaid,nome,url,visivel,grupoid,ordem,codigo,subgrupo) values (442,'bd.tela.agenda','AgendaGerente.do?command=defaultGerenteAction','S',6,7,'AGENDA_GERENTE','PRIMEIRO');

insert into permissao_item 
  ( permissao_item_id, 
    titulo, 
    codigo, 
    permissao_categoria_id, 
    tipo_permissao, 
    mostrar_acesso_total, 
    mostrar_somente_leitura )
values 
  ( 100,
    'label.prompt.alocacao',
    'I_TAR_PROJ_ALOCACAO',
    2,
    'I',
    'S', 
    'S');
    

-----------------------------------------------------------------------------
----------- Inser��o da aba (projeto) -------------------------------------------------
insert into aba
  ( abaid, nome, painelabaid, ocultar, src, validartrocaaba, ordem)
values
  ( 106, 'label.prompt.alocacao', 4, 'S', 'AlocacaoTarefa.do?command=defaultAction' || Chr(38) || 'idTarefa=<form.TarefaProjetoForm.tarefaId/>', 'N', 13 );

----------- Inser��o da aba (avulsa) -------------------------------------------------
insert into aba
  ( abaid, nome, painelabaid, ocultar, src, validartrocaaba, ordem)
values
  ( 102, 'label.prompt.alocacao', 1, 'S', 'AlocacaoTarefa.do?command=defaultAction' || Chr(38) || 'idTarefa=<form.TarefaProjetoForm.tarefaId/>', 'N', 13 );

insert into aba
  ( abaid, nome, painelabaid, ocultar, src, validartrocaaba, ordem)
values
  ( 103, 'label.prompt.alocacao', 9, 'S', 'AlocacaoTarefa.do?command=defaultAction' || Chr(38) || 'idTarefa=<form.TarefaProjetoForm.tarefaId/>', 'N', 13 );

insert into permissaoaba (abaid, projetoid)
values (102, -1);

insert into permissaoaba (abaid, projetoid)
values (103, -1);
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
update aba set ocultar = 'N' where abaid = 98;
commit;
/

INSERT INTO aba 
           (abaid, 
            nome, 
            painelabaid, 
            ocultar, 
            src, 
            validartrocaaba, 
            ordem) 
VALUES     (104, 
            'bd.aba.calendario', 
            2, 
            'S', 
            'Calendario.do?command=abaCalendarioProjetoAction' 
            ||Chr(38) 
            ||'projeto_quadro_avisos=<form.DadosProjetoForm.idProjeto/>', 
            'N', 
            12);
commit;
/

insert into aba(abaid, nome, painelabaid, ocultar, src, validartrocaaba, ordem)
       values(105, 'label.prompt.referenciasExternas', 2, 'N', 'DadosProjeto.do?projeto_quadro_avisos=<form.DadosProjetoForm.idProjeto/>' || CHR ( 38 ) || 'command=referenciasExternas', 'N', 14);
 
insert into permissaoaba(abaid, projetoid) 
select distinct 105 as abaid, projetoid from permissaoaba;
commit;
/

-- Tabela Relat�rio
insert into relatorio (ID, TITULO, TIPO, DESCRICAO, ASSUNTO, URL)
       values (13, 'label.title.relatorioVisaoEstrategica', 'X', 
               'label.prompt.relatorioVisaoEstrategica', 'label.prompt.mapaEstrategico', 
               'v5/bsc/relatorioVisaoEstrategica.js');
commit;
/

-- Tabela diagrama_nodo_entidade
insert into diagrama_nodo_entidade (id,titulo) values (diagrama_nodo_entidade_seq.nextval, 'Id da Entidade');
insert into diagrama_nodo_entidade (id,titulo) values (diagrama_nodo_entidade_seq.nextval, 'T�tulo da Entidade');
insert into diagrama_nodo_entidade (id,titulo) values (diagrama_nodo_entidade_seq.nextval, 'Respons�vel');
insert into diagrama_nodo_entidade (id,titulo) values (diagrama_nodo_entidade_seq.nextval, 'Situa��o');
insert into diagrama_nodo_entidade (id,titulo) values (diagrama_nodo_entidade_seq.nextval, 'In�cio Previsto');
insert into diagrama_nodo_entidade (id,titulo) values (diagrama_nodo_entidade_seq.nextval, 'Fim Previsto');
insert into diagrama_nodo_entidade (id,titulo) values (diagrama_nodo_entidade_seq.nextval, 'Dura��o Prevista (dias �teis)');
insert into diagrama_nodo_entidade (id,titulo) values (diagrama_nodo_entidade_seq.nextval, 'Dura��o Prevista (dias corridos)');
insert into diagrama_nodo_entidade (id,titulo) values (diagrama_nodo_entidade_seq.nextval, 'Tipo Restri��o');
insert into diagrama_nodo_entidade (id,titulo) values (diagrama_nodo_entidade_seq.nextval, 'Dura��o Prevista (horas)');
insert into diagrama_nodo_entidade (id,titulo) values (diagrama_nodo_entidade_seq.nextval, 'In�cio Realizado');
insert into diagrama_nodo_entidade (id,titulo) values (diagrama_nodo_entidade_seq.nextval, 'Fim Realizado');
insert into diagrama_nodo_entidade (id,titulo) values (diagrama_nodo_entidade_seq.nextval, 'Dura��o Realizada (horas)');
insert into diagrama_nodo_entidade (id,titulo) values (diagrama_nodo_entidade_seq.nextval, 'Percentual Conclu�do');
insert into diagrama_nodo_entidade (id,titulo) values (diagrama_nodo_entidade_seq.nextval, 'Custo Total Planejado');
insert into diagrama_nodo_entidade (id,titulo) values (diagrama_nodo_entidade_seq.nextval, 'Custo Total Realizado');
commit;
/
insert into diagrama_rede_visao
(id,projeto_id,titulo,descricao,vigente,publico,cores_estado,ls_visivel,lf_visivel,es_visivel,ef_visivel,folga_visivel,
 formato,data_criacao,data_atualizacao,usuario_criacao_id,usuario_atualizacao_id)
values
(diagrama_rede_visao_seq.nextval,null,'Normal','Vis�o padrao da ferramenta','Y','Y','Y','Y','Y','Y','Y','Y','H',
 sysdate,sysdate,null,null);
commit;
/
insert into diagrama_visao_nodos
(id,visao_id,visao_nodo_id,visivel,data_criacao,data_atualizacao,usuario_criacao_id,usuario_atualizacao_id)
values (diagrama_visao_nodo_seq.nextval,1,1,'Y',sysdate,sysdate,null,null);
insert into diagrama_visao_nodos
(id, visao_id,visao_nodo_id,visivel,data_criacao,data_atualizacao,usuario_criacao_id,usuario_atualizacao_id)
values (diagrama_visao_nodo_seq.nextval,1,2,'Y',sysdate,sysdate,null,null);
insert into diagrama_visao_nodos
(id, visao_id,visao_nodo_id,visivel,data_criacao,data_atualizacao,usuario_criacao_id,usuario_atualizacao_id)
values (diagrama_visao_nodo_seq.nextval,1,3,'Y',sysdate,sysdate,null,null);
insert into diagrama_visao_nodos
(id, visao_id,visao_nodo_id,visivel,data_criacao,data_atualizacao,usuario_criacao_id,usuario_atualizacao_id)
values (diagrama_visao_nodo_seq.nextval,1,5,'Y',sysdate,sysdate,null,null);
insert into diagrama_visao_nodos
(id, visao_id,visao_nodo_id,visivel,data_criacao,data_atualizacao,usuario_criacao_id,usuario_atualizacao_id)
values (diagrama_visao_nodo_seq.nextval,1,6,'Y',sysdate,sysdate,null,null);
commit;
/

-- MAPA_ROTINA
insert into mapa_rotina (id, titulo, descricao, indicador_quebra, tipo_objeto_bd, package, nome, versao, data_criacao, data_atualizacao)
       values (1, 'Quantidade de projetos abertos', 'Busca quantidade total de projetos que n�o est�o nos estados cancelado ou conclu�do.',
                  'N', 'F', 'PCK_IND_ROTINA', 'F_PROJETOS_ABERTOS', '1.0', sysdate, sysdate);
insert into mapa_rotina (id, titulo, descricao, indicador_quebra, tipo_objeto_bd, package, nome, versao, data_criacao, data_atualizacao)
       values (2, 'Quantidade de projetos criados no m�s', 'Retorna a quantidade de projetos que foram criados no �ltimo m�s encerrado',
                  'N', 'F', 'PCK_IND_ROTINA', 'F_PROJETOS_CRIADOS_MES', '1.0', sysdate, sysdate);
-- PARAMETROS MAPA_ROTINA

commit;
/

--------------------------------------------------------------------------------
-- Informa��es da vers�o
--------------------------------------------------------------------------------
insert into versao_tgp (id, nome, data_lancamento) 
       values(3, '6.0.0.0 - Vers�o Calend�rio', to_date('04/05/2009', 'dd/mm/yyyy'));
insert into versao(id, titulo, patch, versao_tgp_id, comentario)
       values (versao_seq.nextval, '6.0.0', '0', 3, 'Atualiza��o de Vers�o');
commit;
/
