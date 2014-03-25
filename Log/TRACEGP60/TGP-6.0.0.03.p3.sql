create or replace view v_custo_entidade_outros as
select mvcl.CUSTO_RECEITA_ID, mvcl.CUSTO_RECEITA_TIPO, mvcl.CUSTO_RECEITA_TITULO,
       mvcl.TIPO_ENTIDADE, mvcl.ENTIDADE_ID, mvcl.CUSTO_ENTIDADE_ID, 
       mvcl.TIPO_LANCAMENTO_ID, mvcl.DESP_TITULO, mvcl.SITUACAO, 
       mvcl.CUSTO_ENTIDADE_ID || mvcl.SITUACAO ID_UNICO,
       sum(nvl(mvcl.VALOR, 0)) as VALOR 
  from mv_custo_lancamento mvcl
 where mvcl.tipo_lancamento = 'O'
group by mvcl.CUSTO_RECEITA_ID, mvcl.CUSTO_RECEITA_TIPO, mvcl.CUSTO_RECEITA_TITULO,
         mvcl.TIPO_ENTIDADE, mvcl.ENTIDADE_ID, mvcl.CUSTO_ENTIDADE_ID, 
         mvcl.TIPO_LANCAMENTO_ID, mvcl.DESP_TITULO, mvcl.SITUACAO; 
/

-- AGRUPADOR

insert into regras_tipo_agrupador (ID, CODIGO, TITULO)
values (1, 'soma', 'label.prompt.soma');

insert into regras_tipo_agrupador (ID, CODIGO, TITULO)
values (2, 'concatena', 'label.prompt.concatena');

insert into regras_tipo_agrupador (ID, CODIGO, TITULO)
values (3, 'media', 'label.prompt.media');

insert into regras_tipo_agrupador (ID, CODIGO, TITULO)
values (4, 'menor', 'label.prompt.menor');

insert into regras_tipo_agrupador (ID, CODIGO, TITULO)
values (5, 'maior', 'label.prompt.maior');

insert into regras_tipo_agrupador (ID, CODIGO, TITULO)
values (6, 'lista', 'label.prompt.lista');

insert into regras_tipo_agrupador (ID, CODIGO, TITULO)
values (7, 'contar', 'label.prompt.contar');

insert into regras_tipo_agrupador (ID, CODIGO, TITULO)
values (8, 'somaNvlZero', 'label.prompt.somaNivelZero');

insert into regras_tipo_agrupador (ID, CODIGO, TITULO)
values (9, 'semValor', 'label.prompt.semValor');


-- Entidade

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Demanda', 'DEMANDA', 'DEMANDA_ID', 1, '', 'D');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Projeto', 'PROJETO', 'ID', 2, '', 'P');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Usuário', 'USUARIO', 'USUARIOID', 3, '', '');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Mapa Estratégico', 'MAPA_ESTRATEGICO', 'ID', 4, '', '');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Atributo - Demanda', 'ATRIBUTO_VALOR', 'ATRIBUTO_VALOR_ID', 5, 'atributo_id', '');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Destino', 'DESTINO', 'DESTINOID', 6, '', '');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Atividade', 'ATIVIDADE', 'ID', 7, '', 'A');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Centro de Custo', 'V_CENTRO_CUSTO_ENTIDADE', 'CENTROCUSTOID', 8, '', '');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Objetivo', 'V_OBJETIVOS_RESUMO', 'ID', 9, '', '');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Dominios', 'DOMINIOATRIBUTO', 'DOMINIOATRIBUTOID', 10, '', '');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Atributo - Entidade', 'ATRIBUTOENTIDADEVALOR', 'ATRIBUTOENTIDADEID', 11, 'atributoid', '');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Árvore de Custo', 'CUSTO_ENTIDADE', 'ID', 12, '', '');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Lançamento', 'CUSTO_LANCAMENTO', 'ID', 13, '', '');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Unidade Organizacional', 'UO', 'ID', 14, '', '');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Estado', 'ESTADO', 'ESTADO_ID', 15, '', '');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Prioridade', 'PRIORIDADE', 'PRIORIDADEID', 16, '', '');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Tarefa', 'TAREFA', 'ID', 17, '', 'T');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Indicador', 'V_INDICADORES_RESUMO', 'ID', 18, '', '');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Forma de Aquisição', 'FORMAAQUISICAO', 'ID', 19, '', '');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Tipo de Despesa', 'TIPODESPESA', 'ID', 20, '', '');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Documento', 'DOCUMENTO', 'DOCUMENTOID', 21, '', '');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Faixa SLA', 'ESTADO_SLA', 'ESTADO_SLA_ID', 22, '', '');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('SLA Atual', 'V_SLA_ATUAL', 'ID', 23, '', '');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('EVA', 'V_EVA', 'ID', 24, '', '');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Diretório de Equipe', 'PAPELPROJETORECURSO', 'ID', 25, '', '');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Papel', 'PAPELPROJETO', 'PAPELPROJETOID', 26, '', '');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Empresa', 'EMPRESA', 'ID', 27, '', '');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Escopo', 'V_ESCOPO', 'PROJETO', 28, '', '');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Premissa', 'PREMISSA', 'ID', 29, '', '');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Restrição', 'RESTRICAO', 'ID', 30, '', '');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('SubProduto', 'PRODUTOENTREGAVEL', 'ID', 31, '', '');

insert into regras_tipo_entidade (TITULO, NOME_TABELA, COLUNA_PK, ID, COLUNA_ATRIBUTO_ID, TIPO_ENTIDADE)
values ('Diretório de Equipe', 'PAPELPROJETORECURSO', 'PAPELID', 32, '', '');

-- Escopo
insert into regras_tipo_escopo (ID, CODIGO, TITULO, TIPO_ENTIDADE_ID)
values (1, 'demandaCorrente', 'Demanda Corrente', 1);

insert into regras_tipo_escopo (ID, CODIGO, TITULO, TIPO_ENTIDADE_ID)
values (2, 'demandas', 'Demandas', 1);

insert into regras_tipo_escopo (ID, CODIGO, TITULO, TIPO_ENTIDADE_ID)
values (3, 'projetos', 'Projetos', 2);

insert into regras_tipo_escopo (ID, CODIGO, TITULO, TIPO_ENTIDADE_ID)
values (4, 'usuarios', 'Usuários', 3);

insert into regras_tipo_escopo (ID, CODIGO, TITULO, TIPO_ENTIDADE_ID)
values (5, 'demandasFilhas', 'Demandas filhas da demanda corrente', 1);

insert into regras_tipo_escopo (ID, CODIGO, TITULO, TIPO_ENTIDADE_ID)
values (6, 'demandasIrmas', 'Demandas filhas da demanda pai da demanda corrente', 1);

insert into regras_tipo_escopo (ID, CODIGO, TITULO, TIPO_ENTIDADE_ID)
values (7, 'projetosAssociados', 'Projetos associados a demanda corrente', 2);

insert into regras_tipo_escopo (ID, CODIGO, TITULO, TIPO_ENTIDADE_ID)
values (8, 'usuarioLogado', 'Usuário Logado', 3);

insert into regras_tipo_escopo (ID, CODIGO, TITULO, TIPO_ENTIDADE_ID)
values (9, 'demandasProjetosAssociados', 'Demandas associadas aos projetos associados a demanda corrente', 1);

insert into regras_tipo_escopo (ID, CODIGO, TITULO, TIPO_ENTIDADE_ID)
values (10, 'demandasIrmasMaisCorrente', 'Demandas filhas da demanda pai da demanda corrente (Incluindo a Corrente)', 1);

insert into regras_tipo_escopo (ID, CODIGO, TITULO, TIPO_ENTIDADE_ID)
values (11, 'demandasProjetosAssociadosMaisCorrente', 'Demandas associadas aos projetos associados a demanda corrente (Incluindo a Corrente)', 1);

insert into regras_tipo_escopo (ID, CODIGO, TITULO, TIPO_ENTIDADE_ID)
values (12, 'mapasEstrategicos', 'Mapas Estratégicos', 4);

insert into regras_tipo_escopo (ID, CODIGO, TITULO, TIPO_ENTIDADE_ID)
values (13, 'dominios', 'Domínios', 10);

insert into regras_tipo_escopo (ID, CODIGO, TITULO, TIPO_ENTIDADE_ID)
values (14, 'projetosDemandasFilhas', 'Projetos associados as demandas filhas da demanda corrente ', 2);

insert into regras_tipo_escopo (ID, CODIGO, TITULO, TIPO_ENTIDADE_ID)
values (15, 'projetosDemandaPai', 'Projetos associados a demanda pai da demanda corrente', 2);

insert into regras_tipo_escopo (ID, CODIGO, TITULO, TIPO_ENTIDADE_ID)
values (18, 'atividades', 'Atividades', 7);

insert into regras_tipo_escopo (ID, CODIGO, TITULO, TIPO_ENTIDADE_ID)
values (19, 'tarefas', 'Tarefas', 17);

insert into regras_tipo_escopo (ID, CODIGO, TITULO, TIPO_ENTIDADE_ID)
values (20, 'destinos', 'Destinos', 6);

insert into regras_tipo_escopo (ID, CODIGO, TITULO, TIPO_ENTIDADE_ID)
values (21, 'uo', 'Unidade Organizacional', 14);

insert into regras_tipo_escopo (ID, CODIGO, TITULO, TIPO_ENTIDADE_ID)
values (22, 'objetivos', 'Objetivos', 9);

insert into regras_tipo_escopo (ID, CODIGO, TITULO, TIPO_ENTIDADE_ID)
values (23, 'indicadores', 'Indicadores', 18);

-- Função

insert into regras_tipo_funcao (ID, CODIGO)
values (1, 'soma');

insert into regras_tipo_funcao (ID, CODIGO)
values (2, 'multiplicacao');

insert into regras_tipo_funcao (ID, CODIGO)
values (3, 'concatena');

insert into regras_tipo_funcao (ID, CODIGO)
values (4, 'diasEntre');

insert into regras_tipo_funcao (ID, CODIGO)
values (5, 'mesesEntre');

insert into regras_tipo_funcao (ID, CODIGO)
values (6, 'minimo');

insert into regras_tipo_funcao (ID, CODIGO)
values (7, 'maximo');

insert into regras_tipo_funcao (ID, CODIGO)
values (8, 'contar');

-- Operador

insert into regras_tipo_operador (ID, CODIGO, TITULO)
values (1, '>', ' >');

insert into regras_tipo_operador (ID, CODIGO, TITULO)
values (2, '>=', '>=');

insert into regras_tipo_operador (ID, CODIGO, TITULO)
values (3, '<', '<');

insert into regras_tipo_operador (ID, CODIGO, TITULO)
values (4, '<=', '<=');

insert into regras_tipo_operador (ID, CODIGO, TITULO)
values (5, '=', '=');

insert into regras_tipo_operador (ID, CODIGO, TITULO)
values (6, '<>', '<>');

insert into regras_tipo_operador (ID, CODIGO, TITULO)
values (7, 'estaContido', 'está contido');

insert into regras_tipo_operador (ID, CODIGO, TITULO)
values (8, 'vazia', 'vazia');

insert into regras_tipo_operador (ID, CODIGO, TITULO)
values (9, 'umOuMais', 'um ou mais elementos');

insert into regras_tipo_operador (ID, CODIGO, TITULO)
values (10, 'maisQueUm', 'mais que um elemento');

insert into regras_tipo_operador (ID, CODIGO, TITULO)
values (11, 'algumElemento', 'algum elemento em');

insert into regras_tipo_operador (ID, CODIGO, TITULO)
values (12, 'nenhumElemento', 'nenhum elemento em');

insert into regras_tipo_operador (ID, CODIGO, TITULO)
values (13, 'preenchido', 'preenchido');

insert into regras_tipo_operador (ID, CODIGO, TITULO)
values (14, 'contem', 'Contém');

insert into regras_tipo_operador (ID, CODIGO, TITULO)
values (15, 'naoContem', 'Não Contém');

insert into regras_tipo_operador (ID, CODIGO, TITULO)
values (16, 'pertence', 'Pertence');

insert into regras_tipo_operador (ID, CODIGO, TITULO)
values (17, 'naoPertence', 'Não Pertence');

--Valor
insert into regras_tipo_valor (ID, CODIGO, TITULO)
values (1, 'numero', 'Número');

insert into regras_tipo_valor (ID, CODIGO, TITULO)
values (2, 'string', 'String');

insert into regras_tipo_valor (ID, CODIGO, TITULO)
values (3, 'data', 'Data');

insert into regras_tipo_valor (ID, CODIGO, TITULO)
values (4, 'horas', 'Horas');

insert into regras_tipo_valor (ID, CODIGO, TITULO)
values (5, 'atributo', 'Atributo');

insert into regras_tipo_valor (ID, CODIGO, TITULO)
values (6, 'entidade', 'Entidade');

insert into regras_tipo_valor (ID, CODIGO, TITULO)
values (7, 'lancamento', 'Lançamento');


-- Propriedade

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (1, 'TIPOENTIDADEPAI', 'TIPOENTIDADEPAI', 2, 'N', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (2, 'ENTIDADEPAI', 'ENTIDADEPAI', 1, 'N', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (3, 'APROVADA', 'APROVADA', 2, 'N', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (4, 'VISTORIADA', 'VISTORIADA', 2, 'N', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (5, 'ORDEM', 'ORDEM', 1, 'N', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (6, 'label.prompt.inicioPrevisto', 'DATAINICIO', 3, 'Y', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (7, 'PROJETO', 'PROJETO', 1, 'N', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (8, 'NOTIFICADA', 'NOTIFICADA', 2, 'N', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (9, 'NOTIFICADAAPROVACAO', 'NOTIFICADAAPROVACAO', 2, 'N', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (10, 'label.prompt.percentualConcluido', 'PORCENTAGEMCONCLUIDA', 1, 'Y', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (11, 'INFADICIONAISVISTORIA', 'INFADICIONAISVISTORIA', 2, 'N', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (12, 'label.prompt.inicioRealizado', 'INICIOREALIZADO', 3, 'Y', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (13, 'label.prompt.tempo.duracao', 'DURACAO', 1, 'Y', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (14, 'label.prompt.restricao', 'TIPORESTRICAO', 1, 'Y', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (15, 'DATARESTRICAO', 'DATARESTRICAO', 3, 'N', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (16, 'CPI_MONETARIO', 'CPI_MONETARIO', 1, 'N', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (17, 'SPI_MONETARIO', 'SPI_MONETARIO', 1, 'N', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (18, 'CLASSE', 'CLASSE', 2, 'N', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (19, 'MODIFICADOR', 'MODIFICADOR', 2, 'N', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (20, 'MOTIVO', 'MOTIVO', 2, 'N', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (21, 'ID', 'ID', 1, 'N', '', 7, null, 'Y');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (22, 'label.prompt.horasPrevistas', 'HORASPREVISTAS', 1, 'Y', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (23, 'label.prompt.horasRealizadas', 'HORASREALIZADAS', 1, 'Y', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (24, 'label.prompt.fimPrevisto', 'PRAZOPREVISTO', 3, 'Y', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (25, 'label.prompt.fimRealizado', 'PRAZOREALIZADO', 3, 'Y', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (26, 'label.prompt.situacao', 'SITUACAO', 1, 'Y', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (27, 'label.prompt.nome', 'DESCRICAO', 2, 'Y', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (28, 'label.prompt.titulo', 'TITULO', 2, 'Y', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (29, 'label.prompt.tipo', 'TIPO', 1, 'Y', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (30, 'label.prompt.prioridade', 'PRIORIDADE', 1, 'Y', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (31, 'VALOR', 'VALOR', 2, 'N', '', 5, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (32, 'VALORDATA', 'VALORDATA', 3, 'N', '', 5, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (33, 'VALORNUMERICO', 'VALORNUMERICO', 1, 'N', '', 5, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (34, 'VALOR_HTML', 'VALOR_HTML', null, 'N', '', 5, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (35, 'CATEGORIA_ITEM_ATRIBUTO_ID', 'CATEGORIA_ITEM_ATRIBUTO_ID', 1, 'N', '', 5, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (36, 'ATRIBUTO_ID', 'ATRIBUTO_ID', 1, 'N', '', 5, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (37, 'ATRIBUTO_VALOR_ID', 'ATRIBUTO_VALOR_ID', 1, 'N', '', 5, null, 'Y');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (38, 'label.prompt.idSolicitacao', 'DEMANDA_ID', 1, 'N', '', 5, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (39, 'label.prompt.dataAtualizacao', 'DATE_UPDATE', 3, 'N', '', 5, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (40, 'DOMINIO_ATRIBUTO_ID', 'DOMINIO_ATRIBUTO_ID', 1, 'N', '', 5, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (41, 'label.prompt.modificador', 'USER_UPDATE', 2, 'N', '', 5, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (42, 'label.prompt.idSolicitacao', 'DEMANDA_ID', 1, 'Y', '', 1, null, 'Y');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (43, 'label.prompt.dataFimAtendimento', 'DATA_FIM_ATENDIMENTO', 3, 'Y', '', 1, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (44, 'label.prompt.prazoPrevisto', 'DATA_FIM_PREVISTO', 3, 'Y', '', 1, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (45, 'label.prompt.dataInicioAtendimento', 'DATA_INICIO_ATENDIMENTO', 3, 'Y', '', 1, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (46, 'label.prompt.tempo.inicioPrevisto', 'DATA_INICIO_PREVISTO', 3, 'Y', '', 1, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (47, 'label.prompt.destino', 'DESTINO_ID', 1, 'Y', '', 1, 6, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (48, 'label.prompt.tempo.duracao', 'DURACAO', 1, 'Y', '', 1, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (49, 'label.prompt.duracaoPrevisto', 'DURACAO_PREVISTO', 1, 'Y', '', 1, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (50, 'ESTADO_AUTOMATICO', 'ESTADO_AUTOMATICO', 2, 'N', '', 1, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (51, 'FIXAR_DATAS', 'FIXAR_DATAS', 2, 'N', '', 1, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (52, 'FIXAR_DATAS_PREVISTAS', 'FIXAR_DATAS_PREVISTAS', 2, 'N', '', 1, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (53, 'label.prompt.formulario', 'FORMULARIO_ID', 1, 'Y', '', 1, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (54, 'OUTRO', 'OUTRO', 2, 'N', '', 1, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (55, 'label.prompt.interessados', 'PARTES_INTERESSADAS', 2, 'Y', '', 1, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (56, 'label.prompt.peso', 'PESO', 1, 'Y', '', 1, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (57, 'label.prompt.prioridade', 'PRIORIDADE', 1, 'Y', '', 1, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (58, 'label.prompt.prioridadeAtendimento', 'PRIORIDADE_RESPONSAVEL', 1, 'Y', '', 1, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (59, 'label.prompt.responsavel', 'RESPONSAVEL', 2, 'Y', '', 1, 3, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (60, 'label.prompt.estado', 'SITUACAO', 1, 'Y', '', 1, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (61, 'label.prompt.criador', 'CRIADOR', 2, 'Y', '', 1, 3, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (62, 'label.prompt.solicitante', 'SOLICITANTE', 2, 'Y', '', 1, 3, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (63, 'label.prompt.tipo', 'TIPO', 1, 'Y', '', 1, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (64, 'label.prompt.titulo', 'TITULO', 2, 'Y', '', 1, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (65, 'MOTIVO', 'MOTIVO', 2, 'N', '', 1, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (66, 'label.prompt.modificador', 'USER_UPDATE', 2, 'Y', '', 1, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (67, 'label.prompt.dataAtualizacao', 'DATE_UPDATE', 3, 'Y', '', 1, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (68, 'ATIVO', 'ATIVO', 2, 'N', '', 1, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (69, 'label.prompt.demandaPai', 'DEMANDA_PAI', 6, 'Y', '', 1, 1, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (70, 'label.prompt.unidadeOrganizacional', 'UO_ID', 1, 'Y', '', 1, 14, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (71, 'MODELO', 'MODELO', 2, 'N', '', 1, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (72, 'ENTIDADE_VINC_ESTADO', 'ENTIDADE_VINC_ESTADO', 2, 'N', '', 1, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (73, 'DOCUMENTO_VINC_ESTADO', 'DOCUMENTO_VINC_ESTADO', 2, 'N', '', 1, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (74, 'DATA_INICIO_SLA', 'DATA_INICIO_SLA', 3, 'N', '', 1, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (75, 'DATE_UPDATE_SITUACAO', 'DATE_UPDATE_SITUACAO', 3, 'N', '', 1, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (76, 'label.prompt.dataCriacao', 'DATA_CRIACAO', 3, 'Y', '', 1, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (77, 'label.prompt.destinoId', 'DESTINOID', 1, 'Y', '', 6, null, 'Y');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (78, 'label.prompt.titulo', 'DESCRICAO', 2, 'Y', '', 6, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (79, 'label.prompt.vigente', 'VIGENTE', 2, 'Y', '', 6, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (80, 'label.prompt.destinoPai', 'DESTINOPAI', 1, 'Y', '', 6, 6, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (81, 'RESPOSTARESPONSAVEL', 'RESPOSTARESPONSAVEL', 1, 'N', '', 6, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (82, 'RESPOSTAAUDITOR', 'RESPOSTAAUDITOR', 1, 'N', '', 6, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (83, 'FORMATONOTIFICACAO', 'FORMATONOTIFICACAO', 2, 'N', '', 6, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (84, 'PERIODICIDADE', 'PERIODICIDADE', 1, 'N', '', 6, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (85, 'label.prompt.auditor', 'AUDITOR', 2, 'Y', '', 6, 3, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (86, 'AVISO', 'AVISO', 3, 'N', '', 6, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (87, 'ID', 'ID', 1, 'N', '', 2, null, 'Y');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (88, 'label.prompt.titulo', 'TITULO', 2, 'Y', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (89, 'ORDEM', 'ORDEM', 1, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (90, 'label.prompt.inicioPrevisto', 'DATAINICIO', 3, 'Y', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (91, 'DATAFIMORCAMENTO', 'DATAFIMORCAMENTO', 3, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (92, 'label.prompt.porcentagemConcluida', 'PORCENTAGEMCONCLUIDA', 1, 'Y', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (93, 'PERMITETEMPLATE', 'PERMITETEMPLATE', 2, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (94, 'label.prompt.tipoDeProjeto', 'TIPOPROJETOID', 1, 'Y', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (95, 'label.prompt.inicioRealizado', 'INICIOREALIZADO', 3, 'Y', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (96, 'label.prompt.tempo.duracao', 'DURACAO', 1, 'Y', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (97, 'TIPORESTRICAO', 'TIPORESTRICAO', 1, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (98, 'ATUALIZARHORASPREVISTAS', 'ATUALIZARHORASPREVISTAS', 2, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (99, 'CPI_MONETARIO', 'CPI_MONETARIO', 1, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (100, 'SPI_MONETARIO', 'SPI_MONETARIO', 1, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (101, 'DATARESTRICAO', 'DATARESTRICAO', 3, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (102, 'ENTIDADE_PAI', 'ENTIDADE_PAI', 1, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (103, 'CONSIDERAR_CUSTO', 'CONSIDERAR_CUSTO', 2, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (104, 'ALTERAR_PERC_CONCLUIDO', 'ALTERAR_PERC_CONCLUIDO', 2, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (105, 'PERMITE_CUSTO_APENAS_TAREFA', 'PERMITE_CUSTO_APENAS_TAREFA', 2, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (106, 'EDICAO_EXCLUSIVA', 'EDICAO_EXCLUSIVA', 2, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (107, 'MODIFICADOR', 'MODIFICADOR', 2, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (108, 'MOTIVO', 'MOTIVO', 2, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (109, 'PROJETO_TEMPLATE_ID', 'PROJETO_TEMPLATE_ID', 1, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (110, 'DASHBOARD_ID', 'DASHBOARD_ID', 1, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (111, 'label.prompt.unidadeOrganizacional', 'UO_ID', 1, 'Y', '', 2, 14, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (112, 'label.prompt.formulario', 'FORMULARIO_ID', 1, 'Y', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (113, 'label.prompt.descricao', 'DESCRICAO', 2, 'Y', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (114, 'label.prompt.horasPrevistas', 'HORASPREVISTAS', 1, 'Y', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (115, 'label.prompt.horasRealizadas', 'HORASREALIZADAS', 1, 'Y', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (116, 'label.prompt.prazoPrevisto', 'PRAZOPREVISTO', 3, 'Y', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (117, 'label.prompt.tempo.prazoRealizado', 'PRAZOREALIZADO', 3, 'Y', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (118, 'label.prompt.situacao', 'SITUACAO', 1, 'Y', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (119, 'SISTEMA', 'SISTEMA', 1, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (120, 'label.prompt.usuario', 'USUARIOID', 2, 'Y', '', 3, null, 'Y');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (121, 'label.prompt.nome', 'NOME', 2, 'Y', '', 3, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (122, 'label.prompt.email', 'EMAIL', 2, 'Y', '', 3, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (123, 'label.prompt.padraoHorario', 'PADRAOHORARIO', 1, 'Y', '', 3, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (124, 'VIGENTE', 'VIGENTE', 2, 'N', '', 3, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (125, 'label.prompt.telefone', 'TELEFONE', 2, 'Y', '', 3, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (126, 'label.prompt.celular', 'CELULAR', 2, 'Y', '', 3, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (127, 'label.prompt.empresa', 'EMPRESAID', 1, 'Y', '', 3, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (128, 'NOTIFIC_CONCLUSAO_TAREFA_RESP', 'NOTIFIC_CONCLUSAO_TAREFA_RESP', 2, 'N', '', 3, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (129, 'label.prompt.responsavel', 'RESPONSAVEL_ID', 2, 'Y', '', 3, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (130, 'label.prompt.tipoProfissional', 'TIPO_PROFISSIONAL_ID', 1, 'Y', '', 3, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (131, 'SENHA_CLIENTE', 'SENHA_CLIENTE', 2, 'N', '', 3, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (132, 'PRINCIPAL_CONTATO_CLIENTE', 'PRINCIPAL_CONTATO_CLIENTE', 2, 'N', '', 3, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (133, 'TIPO_USUARIO', 'TIPO_USUARIO', 2, 'N', '', 3, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (134, 'label.prompt.dddCelular', 'DDD_CELULAR', 2, 'Y', '', 3, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (135, 'label.prompt.ddiCelular', 'DDD_TELEFONE', 2, 'Y', '', 3, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (136, 'label.prompt.dddTelefone', 'DDI_CELULAR', 2, 'Y', '', 3, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (137, 'label.prompt.ddiTelefone', 'DDI_TELEFONE', 2, 'Y', '', 3, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (138, 'label.prompt.ramal', 'RAMAL', 2, 'Y', '', 3, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (139, 'FORMULARIO_DEFAULT_ID', 'FORMULARIO_DEFAULT_ID', 1, 'N', '', 3, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (140, 'IDIOMA_PADRAO', 'IDIOMA_PADRAO', 2, 'N', '', 3, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (141, 'label.prompt.unidadeOrganizacional', 'UO_ID', 1, 'Y', '', 3, 14, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (142, 'TELA_PADRAO', 'TELA_PADRAO', 2, 'N', '', 3, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (143, 'label.prompt.login', 'LOGIN', 2, 'Y', '', 3, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (144, 'label.prompt.objetivo', '', 6, 'Y', '[ENTIDADE-PAI].ID = [ENTIDADE-FILHA].ENTIDADE_ID AND [ENTIDADE-FILHA].TIPO_ENTIDADE   = ''P'' ', 2, 9, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (145, 'ES', 'ES', 1, 'N', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (146, 'EF', 'EF', 1, 'N', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (147, 'LS', 'LS', 1, 'N', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (148, 'LF', 'LF', 1, 'N', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (149, 'FOLGA_LIVRE', 'FOLGA_LIVRE', 1, 'N', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (150, 'ITEMWBS_ID', 'ITEMWBS_ID', 1, 'N', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (151, 'INICIO_ATRASADO', 'INICIO_ATRASADO', 3, 'N', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (152, 'FIM_ATRASADO', 'FIM_ATRASADO', 3, 'N', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (153, 'CRITICO', 'CRITICO', 2, 'N', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (154, 'FOLGA_TOTAL', 'FOLGA_TOTAL', 1, 'N', '', 7, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (155, 'ID', 'ID', 1, 'N', '', 4, null, 'Y');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (156, 'CODIGO', 'CODIGO', 2, 'N', '', 4, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (157, 'label.prompt.titulo', 'TITULO', 2, 'Y', '', 4, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (158, 'DESCRICAO', 'DESCRICAO', 2, 'N', '', 4, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (159, 'MISSAO', 'MISSAO', 2, 'N', '', 4, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (160, 'VISAO', 'VISAO', 2, 'N', '', 4, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (161, 'label.prompt.tipo', 'TIPO', 2, 'Y', '', 4, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (162, 'label.prompt.criador', 'CRIADOR', 2, 'Y', '', 4, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (163, 'DATA_INICIO', 'DATA_INICIO', 3, 'N', '', 4, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (164, 'DATA_FIM', 'DATA_FIM', 3, 'N', '', 4, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (165, 'VISUALIZAR_ABA_OBJETIVO', 'VISUALIZAR_ABA_OBJETIVO', 2, 'N', '', 4, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (166, 'VISUALIZAR_CAUSA_EFEITO', 'VISUALIZAR_CAUSA_EFEITO', 2, 'N', '', 4, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (167, 'VISUALIZAR_DEPENDENCIA', 'VISUALIZAR_DEPENDENCIA', 2, 'N', '', 4, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (168, 'VISUALIZAR_MISSAO', 'VISUALIZAR_MISSAO', 2, 'N', '', 4, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (169, 'VISUALIZAR_VISAO', 'VISUALIZAR_VISAO', 2, 'N', '', 4, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (170, 'VISUALIZAR_ESCORE', 'VISUALIZAR_ESCORE', 2, 'N', '', 4, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (171, 'label.prompt.dataCriacao', 'DATA_CRIACAO', 3, 'Y', '', 4, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (172, 'DATA_ATUALIZACAO', 'DATA_ATUALIZACAO', 3, 'N', '', 4, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (173, 'USUARIO_ATUALIZACAO_ID', 'USUARIO_ATUALIZACAO_ID', 2, 'N', '', 4, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (174, 'DESENHO', 'DESENHO', null, 'N', '', 4, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (175, 'PERIODO_APURACAO', 'PERIODO_APURACAO', 1, 'N', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (176, 'label.prompt.dataCriacao', 'DATA_CRIACAO', 3, 'Y', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (177, 'DATA_ATUALIZACAO', 'DATA_ATUALIZACAO', 3, 'N', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (178, 'VIGENTE', 'VIGENTE', 2, 'N', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (179, 'VISIVEL', 'VISIVEL', 2, 'N', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (180, 'USUARIO_CRIACAO_ID', 'USUARIO_CRIACAO_ID', 2, 'N', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (181, 'USUARIO_ATUALIZACAO_ID', 'USUARIO_ATUALIZACAO_ID', 2, 'N', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (182, 'PREVISAO_APURACAO', 'PREVISAO_APURACAO', 3, 'N', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (183, 'FREQUENCIA_APURACAO', 'FREQUENCIA_APURACAO', 2, 'N', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (184, 'FORMULA', 'FORMULA', 2, 'N', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (185, 'DESC_FORMULA', 'DESC_FORMULA', 2, 'N', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (186, 'INICIO_APURACAO', 'INICIO_APURACAO', 3, 'N', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (187, 'label.prompt.perspectiva', 'PERSPECTIVA_ID', 1, 'Y', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (188, 'ID', 'ID', 1, 'N', '', 9, null, 'Y');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (189, 'label.prompt.objetivoPai', 'OBJETIVO_PAI', 1, 'Y', '', 9, 9, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (190, 'label.prompt.titulo', 'TITULO', 2, 'Y', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (191, 'label.prompt.descricao', 'DESCRICAO', 2, 'Y', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (192, 'label.prompt.tipo', 'TIPO', 2, 'Y', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (193, 'label.prompt.validade', 'VALIDADE', 3, 'Y', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (194, 'MNEMONICO', 'MNEMONICO', 2, 'N', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (195, 'UNIDADE', 'UNIDADE', 2, 'N', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (196, 'TIPO_ENTIDADE', 'TIPO_ENTIDADE', 2, 'N', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (197, 'ENTIDADE_ID', 'ENTIDADE_ID', 1, 'N', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (198, 'label.prompt.descricaoMeta', 'DESC_META', 2, 'Y', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (199, 'label.prompt.calendarioBase', 'CALENDARIO_BASE_ID', 1, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (200, 'FOLGA_LIVRE', 'FOLGA_LIVRE', 1, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (201, 'INICIO_ATRASADO', 'INICIO_ATRASADO', 3, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (202, 'FIM_ATRASADO', 'FIM_ATRASADO', 3, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (203, 'CRITICO', 'CRITICO', 2, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (204, 'FOLGA_TOTAL', 'FOLGA_TOTAL', 1, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (205, 'ATUALIZACAO_PENDENTE', 'ATUALIZACAO_PENDENTE', 2, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (206, 'REGRA_ALOCACAO', 'REGRA_ALOCACAO', 1, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (207, 'ALOCAR_AUTOMATICAMENTE', 'ALOCAR_AUTOMATICAMENTE', 2, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (208, 'REGRA_ALOCACAO_HORAS', 'REGRA_ALOCACAO_HORAS', 1, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (209, 'ES', 'ES', 1, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (210, 'EF', 'EF', 1, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (211, 'LS', 'LS', 1, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (212, 'LF', 'LF', 1, 'N', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (213, 'AUTENTICACAO_NATIVA', 'AUTENTICACAO_NATIVA', 2, 'N', '', 3, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (214, 'label.prompt.gerenteRecurso', 'GERENTE_RECURSO', 2, 'Y', '', 3, 3, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (215, 'label.prompt.calendarioBase', 'CALENDARIO_BASE_ID', 1, 'Y', '', 3, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (216, 'MODIFICADOR', 'MODIFICADOR', 2, 'N', '', 3, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (217, 'AGENDA_ABA_PADRAO', 'AGENDA_ABA_PADRAO', 2, 'N', '', 3, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (218, 'AGENDA_VISAO_PADRAO', 'AGENDA_VISAO_PADRAO', 2, 'N', '', 3, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (219, 'label.prompt.objetivoAgrupador', '', 1, 'Y', 'EXISTS (SELECT 1 FROM MAPA_OBJETIVO_AGRUPADOR A WHERE A.OBJETIVO_ID_AGRUPADO = [ENTIDADE-PAI].ID AND A.OBJETIVO_ID_AGRUPADOR = [ENTIDADE-FILHA].ID)', 9, 9, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (221, 'OBJETIVOS', '', 6, 'N', '[ENTIDADE-PAI].ID = [ENTIDADE-FILHA].ENTIDADE_ID   AND [ENTIDADE-FILHA].TIPO_ENTIDADE   = ''E''  ', 4, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (222, 'label.prompt.id', 'DOMINIOATRIBUTOID', 1, 'Y', '', 10, null, 'Y');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (223, 'ATRIBUTOID', 'ATRIBUTOID', 1, 'N', '', 10, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (224, 'label.prompt.titulo', 'TITULO', 2, 'Y', '', 10, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (225, 'ORDEM', 'ORDEM', 1, 'N', '', 10, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (226, 'VIGENTE', 'VIGENTE', 2, 'N', '', 10, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (227, 'label.prompt.atributo', '', 5, 'Y', '[ENTIDADE-PAI].ID = [ENTIDADE-FILHA].IDENTIDADE   AND [ENTIDADE-FILHA].TIPOENTIDADE   = ''P''', 2, 11, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (241, 'DOMINIO_ATRIBUTO_ID', 'DOMINIO_ATRIBUTO_ID', 1, 'N', '', 11, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (242, 'VALOR_HTML', 'VALOR_HTML', null, 'N', '', 11, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (243, 'CATEGORIA_ITEM_ATRIBUTO_ID', 'CATEGORIA_ITEM_ATRIBUTO_ID', 1, 'N', '', 11, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (244, 'VALORNUMERICO', 'VALORNUMERICO', 1, 'N', '', 11, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (245, 'ATRIBUTOENTIDADEID', 'ATRIBUTOENTIDADEID', 1, 'N', '', 11, null, 'Y');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (246, 'TIPOENTIDADE', 'TIPOENTIDADE', 2, 'N', '', 11, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (247, 'IDENTIDADE', 'IDENTIDADE', 1, 'N', '', 11, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (248, 'ATRIBUTOID', 'ATRIBUTOID', 1, 'N', '', 11, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (249, 'VALOR', 'VALOR', 2, 'N', '', 11, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (250, 'VALORDATA', 'VALORDATA', 3, 'N', '', 11, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (251, 'ID', 'ID', 1, 'N', '', 12, null, 'Y');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (252, 'TIPO_ENTIDADE', 'TIPO_ENTIDADE', 2, 'N', '', 12, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (253, 'ENTIDADE_ID', 'ENTIDADE_ID', 1, 'N', '', 12, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (254, 'CUSTO_RECEITA_ID', 'CUSTO_RECEITA_ID', 1, 'N', '', 12, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (255, 'label.prompt.titulo', 'TITULO', 2, 'Y', '', 12, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (256, 'label.prompt.tipoDespesaReceita', 'TIPO_DESPESA_ID', 6, 'Y', '', 12, 20, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (257, 'label.prompt.formaAquisicaoRecebimento', 'FORMA_AQUISICAO_ID', 6, 'Y', '', 12, 19, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (258, 'label.prompt.unidade', 'UNIDADE', 2, 'Y', '', 12, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (259, 'label.prompt.motivo', 'MOTIVO', 2, 'Y', '', 12, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (260, 'ID', 'ID', 1, 'N', '', 13, null, 'Y');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (261, 'CUSTO_ENTIDADE_ID', 'CUSTO_ENTIDADE_ID', 1, 'N', '', 13, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (262, 'label.prompt.tipo', 'TIPO', 2, 'Y', '', 13, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (263, 'label.prompt.estado', 'SITUACAO', 2, 'Y', '', 13, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (264, 'label.prompt.data', 'DATA', 3, 'Y', '', 13, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (265, 'label.prompt.valorUnitario', 'VALOR_UNITARIO', 1, 'Y', '', 13, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (266, 'label.prompt.quantidade', 'QUANTIDADE', 1, 'Y', '', 13, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (267, 'label.prompt.valorTotal', 'VALOR', 1, 'Y', '', 13, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (268, 'USUARIO_ID', 'USUARIO_ID', 2, 'N', '', 13, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (269, 'DATA_ALTERACAO', 'DATA_ALTERACAO', 3, 'N', '', 13, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (270, 'label.prompt.lancamentos', '', 7, 'Y', '[ENTIDADE-PAI].ID = [ENTIDADE-FILHA].CUSTO_ENTIDADE_ID  ', 12, 13, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (271, 'label.prompt.arvoreCustos', '', 7, 'Y', '[ENTIDADE-PAI].ID = [ENTIDADE-FILHA].ENTIDADE_ID   AND ''P'' = [ENTIDADE-FILHA].TIPO_ENTIDADE   ', 2, 12, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (281, 'ESTADO_ID', 'ESTADO_ID', 1, 'N', '', 15, null, 'Y');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (282, 'TITULO_TERMO_ID', 'TITULO_TERMO_ID', 1, 'N', '', 15, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (283, 'ESTADO_ENTIDADE', 'ESTADO_ENTIDADE', 1, 'N', '', 15, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (284, 'SISTEMA', 'SISTEMA', 2, 'N', '', 15, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (285, 'VIGENTE', 'VIGENTE', 2, 'N', '', 15, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (286, 'label.prompt.titulo', 'TITULO', 2, 'Y', '', 19, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (287, 'VIGENTE', 'VIGENTE', 2, 'N', '', 19, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (288, 'ID', 'ID', 1, 'N', '', 19, null, 'Y');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (289, 'label.prompt.tipo', 'TIPO', 2, 'Y', '', 19, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (290, 'label.prompt.objetivoPai', 'OBJETIVO_PAI', 1, 'Y', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (291, 'label.prompt.titulo', 'TITULO', 2, 'Y', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (292, 'label.prompt.descricao', 'DESCRICAO', 2, 'Y', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (293, 'label.prompt.tipo', 'TIPO', 2, 'Y', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (294, 'SUBTIPO', 'SUBTIPO', 2, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (295, 'label.prompt.validade', 'VALIDADE', 3, 'Y', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (296, 'MNEMONICO', 'MNEMONICO', 2, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (297, 'ENTIDADE_APURACAO_ID', 'ENTIDADE_APURACAO_ID', 1, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (298, 'ESTADO_APURACAO_ID', 'ESTADO_APURACAO_ID', 1, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (299, 'SITUACAO_PRJ_APURACAO_ID', 'SITUACAO_PRJ_APURACAO_ID', 1, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (300, 'INICIO_APURACAO', 'INICIO_APURACAO', 3, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (301, 'INDICADOR_NOVA_APURACAO', 'INDICADOR_NOVA_APURACAO', 2, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (302, 'PERIODO_APURACAO', 'PERIODO_APURACAO', 1, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (303, 'FREQUENCIA_APURACAO', 'FREQUENCIA_APURACAO', 2, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (304, 'PRAZO_APURACAO', 'PRAZO_APURACAO', 1, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (305, 'DETALHAMENTO', 'DETALHAMENTO', 2, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (306, 'CALCULO_DETALHAMENTO', 'CALCULO_DETALHAMENTO', 2, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (307, 'label.prompt.peso', 'PESO', 1, 'Y', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (308, 'TIPO_QUESTIONARIO_ID', 'TIPO_QUESTIONARIO_ID', 1, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (309, 'FORMULA', 'FORMULA', 2, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (310, 'DESC_FORMULA', 'DESC_FORMULA', 2, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (311, 'FILTRO_ID', 'FILTRO_ID', 1, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (312, 'ROTINA_ID', 'ROTINA_ID', 1, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (313, 'CONSULTASQL', 'CONSULTASQL', 2, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (314, 'label.prompt.dataCriacao', 'DATA_CRIACAO', 3, 'Y', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (315, 'DATA_ATUALIZACAO', 'DATA_ATUALIZACAO', 3, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (316, 'USUARIO_CRIACAO_ID', 'USUARIO_CRIACAO_ID', 2, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (317, 'USUARIO_ATUALIZACAO_ID', 'USUARIO_ATUALIZACAO_ID', 2, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (318, 'INDICADOR_TEMPLATE', 'INDICADOR_TEMPLATE', 2, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (319, 'TEMPLATE_ID', 'TEMPLATE_ID', 1, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (320, 'ID', 'ID', 1, 'N', '', 18, null, 'Y');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (321, 'UNIDADE', 'UNIDADE', 2, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (322, 'label.prompt.indicadorOrigem', 'INDICADOR_ORIGEM_ID', 1, 'Y', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (323, 'FONTE', 'FONTE', 2, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (324, 'TIPO_ENTIDADE', 'TIPO_ENTIDADE', 2, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (325, 'ENTIDADE_ID', 'ENTIDADE_ID', 1, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (326, 'label.prompt.descricaoMeta', 'DESC_META', 2, 'Y', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (327, 'INDICADOR_APURACAO', 'INDICADOR_APURACAO', 2, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (328, 'PREVISAO_APURACAO', 'PREVISAO_APURACAO', 3, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (329, 'TIPO_ENTIDADE_APURACAO', 'TIPO_ENTIDADE_APURACAO', 2, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (330, 'PRIORIDADEID', 'PRIORIDADEID', 1, 'N', '', 16, null, 'Y');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (331, 'DESCRICAO', 'DESCRICAO', 2, 'N', '', 16, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (332, 'VIGENTE', 'VIGENTE', 2, 'N', '', 16, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (333, 'label.prompt.titulo', 'TITULO', 2, 'Y', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (334, 'label.prompt.tipo', 'TIPO', 1, 'Y', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (335, 'label.prompt.prioridade', 'PRIORIDADE', 1, 'Y', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (336, 'label.prompt.atividade', 'ATIVIDADE', 1, 'Y', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (337, 'SISTEMA', 'SISTEMA', 1, 'N', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (338, 'MODULO', 'MODULO', 1, 'N', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (339, 'ORDEM', 'ORDEM', 1, 'N', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (340, 'label.prompt.inicioPrevisto', 'DATAINICIO', 3, 'Y', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (341, 'PROJETO', 'PROJETO', 1, 'N', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (342, 'label.prompt.responsavel', 'RESPONSAVEL', 2, 'Y', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (343, 'label.prompt.percentualConcluido', 'PORCENTAGEMCONCLUIDA', 1, 'Y', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (344, 'label.prompt.inicioRealizado', 'INICIOREALIZADO', 3, 'Y', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (345, 'label.prompt.tempo.duracao', 'DURACAO', 1, 'Y', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (346, 'label.prompt.restricao', 'TIPORESTRICAO', 1, 'Y', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (347, 'GRUPO', 'GRUPO', 2, 'N', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (348, 'CPI_MONETARIO', 'CPI_MONETARIO', 1, 'N', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (349, 'SPI_MONETARIO', 'SPI_MONETARIO', 1, 'N', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (350, 'DATARESTRICAO', 'DATARESTRICAO', 3, 'N', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (351, 'MODIFICADOR', 'MODIFICADOR', 2, 'N', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (352, 'MOTIVO', 'MOTIVO', 2, 'N', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (353, 'DEMANDA_CRONOMETRO', 'DEMANDA_CRONOMETRO', 2, 'N', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (354, 'PAPELPROJETO_ID', 'PAPELPROJETO_ID', 1, 'N', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (355, 'REGRA_ALOCACAO', 'REGRA_ALOCACAO', 1, 'N', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (356, 'REGRA_ALOCACAO_HORAS', 'REGRA_ALOCACAO_HORAS', 1, 'N', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (357, 'ALOCAR_AUTOMATICAMENTE', 'ALOCAR_AUTOMATICAMENTE', 2, 'N', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (358, 'ES', 'ES', 1, 'N', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (359, 'EF', 'EF', 1, 'N', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (360, 'LS', 'LS', 1, 'N', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (361, 'LF', 'LF', 1, 'N', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (362, 'FOLGA_LIVRE', 'FOLGA_LIVRE', 1, 'N', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (363, 'INICIO_ATRASADO', 'INICIO_ATRASADO', 3, 'N', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (364, 'FIM_ATRASADO', 'FIM_ATRASADO', 3, 'N', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (365, 'CRITICO', 'CRITICO', 2, 'N', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (366, 'FOLGA_TOTAL', 'FOLGA_TOTAL', 1, 'N', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (367, 'ID', 'ID', 1, 'N', '', 17, null, 'Y');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (368, 'label.prompt.horasPrevistas', 'HORASPREVISTAS', 1, 'Y', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (369, 'label.prompt.horasRealizadas', 'HORASREALIZADAS', 1, 'Y', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (370, 'label.prompt.fimPrevisto', 'PRAZOPREVISTO', 3, 'Y', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (371, 'label.prompt.fimRealizado', 'PRAZOREALIZADO', 3, 'Y', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (372, 'label.prompt.situacao', 'SITUACAO', 1, 'Y', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (373, 'DESCRICAO', 'DESCRICAO', 2, 'N', '', 17, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (374, 'ID', 'ID', 1, 'N', '', 20, null, 'Y');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (375, 'DESCRICAO', 'DESCRICAO', 2, 'N', '', 20, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (376, 'VIGENTE', 'VIGENTE', 2, 'N', '', 20, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (377, 'CONTA_CONTABIL', 'CONTA_CONTABIL', 2, 'N', '', 20, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (378, 'label.prompt.tipo', 'TIPO', 2, 'Y', '', 20, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (379, 'ID', 'ID', 1, 'N', '', 14, null, 'Y');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (380, 'label.prompt.titulo', 'TITULO', 2, 'Y', '', 14, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (381, 'PARENT_ID', 'PARENT_ID', 1, 'N', '', 14, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (382, 'label.prompt.responsavel', 'RESPONSAVEL', 2, 'Y', '', 14, 3, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (383, 'VIGENTE', 'VIGENTE', 2, 'N', '', 14, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (384, 'RESPONSAVEL_2', 'RESPONSAVEL_2', 2, 'N', '', 14, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (401, 'COR', 'COR', 2, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (402, 'DATA_APURACAO', 'DATA_APURACAO', 3, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (403, 'ESTADO', 'ESTADO', 2, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (404, 'COMENTARIO', 'COMENTARIO', 2, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (405, 'VALOR_META', 'VALOR_META', 1, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (406, 'ESCORE', 'ESCORE', 1, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (407, 'DIFERENCA', 'DIFERENCA', 1, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (408, 'DIF_PERC', 'DIF_PERC', 1, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (409, 'PERC_META_ATING', 'PERC_META_ATING', 1, 'N', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (410, 'INDICADOR_TEMPLATE', 'INDICADOR_TEMPLATE', 2, 'N', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (411, 'DATA_APURACAO', 'DATA_APURACAO', 3, 'N', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (412, 'ESTADO', 'ESTADO', 2, 'N', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (413, 'COMENTARIO', 'COMENTARIO', 2, 'N', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (414, 'VALOR_META', 'VALOR_META', 1, 'N', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (415, 'ESCORE', 'ESCORE', 1, 'N', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (416, 'DIFERENCA', 'DIFERENCA', 1, 'N', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (417, 'DIF_PERC', 'DIF_PERC', 1, 'N', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (418, 'PERC_META_ATING', 'PERC_META_ATING', 1, 'N', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (419, 'COR', 'COR', 2, 'N', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (420, 'label.prompt.arvoreDeCustos', '', 7, 'Y', '[ENTIDADE-PAI].DEMANDA_ID = [ENTIDADE-FILHA].ENTIDADE_ID   AND ''D'' = [ENTIDADE-FILHA].TIPO_ENTIDADE   ', 1, 12, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (421, 'label.prompt.documentosAnexos', '', 6, 'Y', '[ENTIDADE-PAI].DEMANDA_ID = [ENTIDADE-FILHA].IDENTIDADE   AND ''D'' = [ENTIDADE-FILHA].TIPOENTIDADE   ', 1, 21, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (422, 'label.prompt.projetosAssociados', '', 6, 'Y', '[ENTIDADE-FILHA].ID IN (SELECT IDENTIDADE FROM SOLICITACAOENTIDADE WHERE SOLICITACAO = [ENTIDADE-PAI].DEMANDA_ID AND TIPOENTIDADE = ''P'')', 1, 2, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (423, 'label.prompt.demandasFilhas', '', 6, 'Y', '[ENTIDADE-PAI].DEMANDA_ID = [ENTIDADE-FILHA].DEMANDA_PAI  ', 1, 1, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (424, 'label.prompt.atividadesAssociadas', '', 6, 'Y', '[ENTIDADE-FILHA].ID IN (SELECT IDENTIDADE FROM SOLICITACAOENTIDADE WHERE SOLICITACAO = [ENTIDADE-PAI].DEMANDA_ID AND TIPOENTIDADE = ''A'')', 1, 7, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (425, 'label.prompt.tarefasAssociadas', '', 6, 'Y', '[ENTIDADE-FILHA].ID IN (SELECT IDENTIDADE FROM SOLICITACAOENTIDADE WHERE SOLICITACAO = [ENTIDADE-PAI].DEMANDA_ID AND TIPOENTIDADE = ''T'')', 1, 17, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (426, 'label.prompt.slaDeProcesso', '', 6, 'Y', '[ENTIDADE-PAI].DEMANDA_ID = [ENTIDADE-FILHA].DEMANDA_ID   AND ''P'' = [ENTIDADE-FILHA].TIPO_SLA  ', 1, 23, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (427, 'label.prompt.slaEstadoAtual', '', 6, 'Y', '[ENTIDADE-PAI].DEMANDA_ID = [ENTIDADE-FILHA].DEMANDA_ID   AND ''E'' = [ENTIDADE-FILHA].TIPO_SLA  ', 1, 23, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (428, 'label.prompt.slaTendenciaAtual', '', 6, 'Y', '[ENTIDADE-PAI].DEMANDA_ID = [ENTIDADE-FILHA].DEMANDA_ID   AND ''T'' = [ENTIDADE-FILHA].TIPO_SLA  ', 1, 23, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (429, 'Árvore de Custo', '', 7, 'N', '[ENTIDADE-PAI].ID = [ENTIDADE-FILHA].ENTIDADE_ID   AND ''A'' = [ENTIDADE-FILHA].TIPO_ENTIDADE   ', 7, 12, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (430, 'Árvore de Custo', '', 7, 'N', '[ENTIDADE-PAI].ID = [ENTIDADE-FILHA].ENTIDADE_ID   AND ''T'' = [ENTIDADE-FILHA].TIPO_ENTIDADE   ', 17, 12, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (431, 'label.prompt.centroCusto', '', 6, 'Y', '[ENTIDADE-PAI].ID = [ENTIDADE-FILHA].IDENTIDADE AND ''P''  = [ENTIDADE-FILHA].TIPOENTIDADE', 2, 8, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (432, 'Centros de Custos', '', 6, 'N', '[ENTIDADE-PAI].ID = [ENTIDADE-FILHA].IDENTIDADE AND ''A''  = [ENTIDADE-FILHA].TIPOENTIDADE', 7, 8, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (433, 'Centros de Custos', '', 6, 'N', '[ENTIDADE-PAI].ID = [ENTIDADE-FILHA].IDENTIDADE AND ''T''  = [ENTIDADE-FILHA].TIPOENTIDADE', 17, 17, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (441, 'DOCUMENTOID', 'DOCUMENTOID', 1, 'N', '', 21, null, 'Y');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (442, 'label.prompt.nome', 'DESCRICAO', 2, 'Y', '', 21, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (443, 'TIPOENTIDADE', 'TIPOENTIDADE', 2, 'N', '', 21, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (444, 'IDENTIDADE', 'IDENTIDADE', 1, 'N', '', 21, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (445, 'AREAGERENCIA', 'AREAGERENCIA', 2, 'N', '', 21, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (446, 'ESTADODOCUMENTO', 'ESTADODOCUMENTO', 2, 'N', '', 21, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (447, 'VERSAOATUAL', 'VERSAOATUAL', 1, 'N', '', 21, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (448, 'TIPODOCUMENTO', 'TIPODOCUMENTO', 2, 'N', '', 21, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (449, 'label.prompt.responsavel', 'RESPONSAVEL', 2, 'N', '', 21, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (450, 'DOCUMENTO_PAI', 'DOCUMENTO_PAI', 1, 'N', '', 21, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (451, 'label.prompt.tipoDocumento', 'TIPO_DOCUMENTO_ID', 1, 'Y', '', 21, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (452, 'TAMANHO', 'TAMANHO', 1, 'N', '', 21, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (453, 'ESTADO_SLA_ID', 'ESTADO_SLA_ID', 1, 'N', '', 22, null, 'Y');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (454, 'label.prompt.titulo', 'TITULO', 2, 'Y', '', 22, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (455, 'VIGENTE', 'VIGENTE', 2, 'N', '', 22, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (456, 'label.prompt.idSolicitacao', 'DEMANDA_ID', 1, 'N', '', 23, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (457, 'TIPO_SLA', 'TIPO_SLA', 2, 'N', '', 23, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (458, 'label.prompt.faixa', 'ESTADO_SLA_ID', 1, 'Y', '', 23, 22, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (459, 'label.prompt.objetivoAgrupados', '', 6, 'Y', '[ENTIDADE-PAI].ID = [ENTIDADE-FILHA].OBJETIVO_PAI', 9, 9, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (460, 'label.prompt.objetivo', '', 6, 'Y', '[ENTIDADE-PAI].ID = [ENTIDADE-FILHA].ENTIDADE_ID AND [ENTIDADE-FILHA].TIPO_ENTIDADE   = ''A'' ', 7, 9, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (461, 'label.prompt.objetivo', '', 6, 'Y', '[ENTIDADE-PAI].ID = [ENTIDADE-FILHA].ENTIDADE_ID AND [ENTIDADE-FILHA].TIPO_ENTIDADE   = ''T'' ', 17, 9, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (462, 'label.prompt.indicador', '', 6, 'Y', '[ENTIDADE-PAI].ID = [ENTIDADE-FILHA].OBJETIVO_PAI', 9, 18, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (463, 'label.prompt.indicador', '', 6, 'Y', '[ENTIDADE-PAI].ID = [ENTIDADE-FILHA].ENTIDADE_ID AND [ENTIDADE-FILHA].TIPO_ENTIDADE = ''P''', 2, 18, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (464, 'Indicadores', '', 6, 'N', '[ENTIDADE-PAI].ID = [ENTIDADE-FILHA].ENTIDADE_ID AND [ENTIDADE-FILHA].TIPO_ENTIDADE = ''A''', 7, 18, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (465, 'label.prompt.indicadores', '', 6, 'Y', '[ENTIDADE-PAI].ID = [ENTIDADE-FILHA].ENTIDADE_ID AND [ENTIDADE-FILHA].TIPO_ENTIDADE = ''T''', 17, 18, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (496, 'INFLUENCIA', 'INFLUENCIA', 1, 'N', '', 8, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (497, 'ID', 'ID', 1, 'N', '', 8, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (498, 'label.prompt.titulo', 'TITULO', 2, 'Y', '', 8, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (499, 'PARENT_ID', 'PARENT_ID', 1, 'N', '', 8, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (500, 'VIGENTE', 'VIGENTE', 2, 'N', '', 8, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (501, 'label.prompt.tipo', 'TIPO', 2, 'Y', '', 8, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (502, 'TIPOENTIDADE', 'TIPOENTIDADE', 2, 'N', '', 8, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (503, 'IDENTIDADE', 'IDENTIDADE', 1, 'N', '', 8, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (504, 'label.prompt.titulo', 'TITULO', 2, 'Y', '', 24, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (505, 'label.prompt.valorPrevisto', 'PV', 1, 'Y', '', 24, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (506, 'label.prompt.valorRealizado', 'AC', 1, 'Y', '', 24, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (507, 'label.prompt.orcamentoTotal', 'BAC', 1, 'Y', '', 24, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (508, 'PERC_CONCLUIDO', 'PERC_CONCLUIDO', 1, 'N', '', 24, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (509, 'label.prompt.valorAgregado', 'EV', 1, 'Y', '', 24, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (510, 'CV', 'CV', 1, 'N', '', 24, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (511, 'SV', 'SV', 1, 'N', '', 24, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (512, 'label.prompt.idc', 'CPI', 1, 'Y', '', 24, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (513, 'label.prompt.idp', 'SPI', 1, 'Y', '', 24, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (514, 'TCPI', 'TCPI', 1, 'N', '', 24, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (515, 'ETC', 'ETC', 1, 'N', '', 24, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (516, 'EAC', 'EAC', 1, 'N', '', 24, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (517, 'VAC', 'VAC', 1, 'N', '', 24, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (518, 'PV_ANO', 'PV_ANO', 1, 'N', '', 24, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (519, 'ETC_ANO', 'ETC_ANO', 1, 'N', '', 24, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (520, 'EAC_ANO', 'EAC_ANO', 1, 'N', '', 24, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (521, 'AC_GERAL', 'AC_GERAL', 1, 'N', '', 24, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (522, 'BAC_GERAL', 'BAC_GERAL', 1, 'N', '', 24, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (523, 'AC_PESSOAL', 'AC_PESSOAL', 1, 'N', '', 24, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (524, 'BAC_PESSOAL', 'BAC_PESSOAL', 1, 'N', '', 24, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (525, 'DIA', 'DIA', 3, 'N', '', 24, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (526, 'TIPO_ENTIDADE', 'TIPO_ENTIDADE', 2, 'N', '', 24, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (527, 'ENTIDADE_ID', 'ENTIDADE_ID', 1, 'N', '', 24, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (528, 'PROJETO_ID', 'PROJETO_ID', 1, 'N', '', 24, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (529, 'TIPO_ENTIDADE_PAI', 'TIPO_ENTIDADE_PAI', 2, 'N', '', 24, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (530, 'ENTIDADE_ID_PAI', 'ENTIDADE_ID_PAI', 1, 'N', '', 24, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (531, 'label.prompt.eva', '', 6, 'Y', '[ENTIDADE-PAI].ID = [ENTIDADE-FILHA].ENTIDADE_ID AND [ENTIDADE-FILHA].TIPO_ENTIDADE = ''P'' AND DIA = TRUNC(SYSDATE)', 2, 24, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (532, 'label.prompt.eva', '', 6, 'Y', '[ENTIDADE-PAI].ID = [ENTIDADE-FILHA].ENTIDADE_ID AND [ENTIDADE-FILHA].TIPO_ENTIDADE = ''A'' AND DIA = TRUNC(SYSDATE)', 7, 24, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (533, 'label.prompt.eva', '', 6, 'Y', '[ENTIDADE-PAI].ID = [ENTIDADE-FILHA].ENTIDADE_ID AND [ENTIDADE-FILHA].TIPO_ENTIDADE = ''T'' AND DIA = TRUNC(SYSDATE)', 17, 24, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (541, 'PAPELID', 'PAPELID', 6, 'N', '', 25, 26, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (542, 'label.prompt.usuario', 'USUARIOID', 6, 'Y', '', 25, 3, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (543, 'PROJETOID', 'PROJETOID', 1, 'N', '', 25, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (544, 'ITEMID', 'ITEMID', 1, 'N', '', 25, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (545, 'ENTRADA', 'ENTRADA', 3, 'N', '', 25, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (546, 'SAIDA', 'SAIDA', 3, 'N', '', 25, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (547, 'ESTADO', 'ESTADO', 2, 'N', '', 25, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (548, 'MOTIVOSAIDA', 'MOTIVOSAIDA', 2, 'N', '', 25, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (549, 'Projeto', '', 6, 'N', '', 5, 2, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (550, 'Empresa', '', 6, 'N', '', 5, 27, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (551, 'Usuário', '', 6, 'N', '', 5, 3, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (552, 'Projeto', '', 6, 'N', '', 11, 2, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (553, 'Empresa', '', 6, 'N', '', 11, 27, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (554, 'Usuário', '', 6, 'N', '', 11, 3, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (574, 'ID', 'ID', 1, 'N', '', 27, null, 'Y');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (575, 'label.prompt.nome', 'NOME', 2, 'Y', '', 27, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (576, 'CNPJ', 'CNPJ', 2, 'N', '', 27, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (577, 'ENDERECO', 'ENDERECO', 2, 'N', '', 27, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (578, 'label.prompt.email', 'EMAIL', 2, 'Y', '', 27, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (579, 'label.prompt.telefone', 'TELEFONE', 2, 'Y', '', 27, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (580, 'OBSERVACAO', 'OBSERVACAO', 2, 'N', '', 27, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (581, 'VIGENTE', 'VIGENTE', 2, 'N', '', 27, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (582, 'PAPELPROJETOID', 'PAPELPROJETOID', 1, 'N', '', 26, null, 'Y');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (583, 'label.prompt.titulo', 'TITULO', 2, 'Y', '', 26, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (584, 'DESCRICAO', 'DESCRICAO', 2, 'N', '', 26, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (585, 'PROJETOID', 'PROJETOID', 1, 'N', '', 26, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (586, 'COD', 'COD', 2, 'N', '', 26, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (587, 'DOMINIOID', 'DOMINIOID', 1, 'N', '', 26, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (588, 'VALOR_HORA', 'VALOR_HORA', 1, 'N', '', 26, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (589, 'PROJETO', 'PROJETO', 1, 'N', '', 28, null, 'Y');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (590, 'label.prompt.descricao', 'DESCPRODUTO', 2, 'Y', '', 28, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (591, 'label.prompt.justificativa', 'JUSTIFICATIVAPROJETO', 2, 'Y', '', 28, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (592, 'FECHADO', 'FECHADO', 2, 'N', '', 28, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (593, 'label.prompt.limites', 'LIMITESPROJETO', 2, 'Y', '', 28, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (594, 'label.prompt.fatoresSucesso', 'LISTAFATORESESSENCIAIS', 2, 'Y', '', 28, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (595, 'label.prompt.objetivo', 'OBJETIVOSPROJETO', 2, 'Y', '', 28, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (596, 'label.prompt.escopo', '', 6, 'Y', '[ENTIDADE-PAI].ID = [ENTIDADE-FILHA].PROJETO', 2, 28, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (601, 'label.prompt.premissas', '', 6, 'Y', '[ENTIDADE-PAI].PROJETO = [ENTIDADE-FILHA].PROJETO', 28, 29, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (602, 'label.prompt.restricoes', '', 6, 'Y', '[ENTIDADE-PAI].PROJETO = [ENTIDADE-FILHA].PROJETO', 28, 30, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (603, 'SubProdutos', '', 6, 'N', '[ENTIDADE-PAI].PROJETO = [ENTIDADE-FILHA].PROJETO', 28, 31, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (604, 'ID', 'ID', 1, 'N', '', 29, null, 'Y');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (605, 'PROJETO', 'PROJETO', 1, 'N', '', 29, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (606, 'DESCRICAO', 'DESCRICAO', 2, 'N', '', 29, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (607, 'ID', 'ID', 1, 'N', '', 31, null, 'Y');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (608, 'PROJETO', 'PROJETO', 1, 'N', '', 31, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (609, 'DESCRICAO', 'DESCRICAO', 2, 'N', '', 31, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (610, 'ID', 'ID', 1, 'N', '', 30, null, 'Y');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (611, 'PROJETO', 'PROJETO', 1, 'N', '', 30, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (612, 'DESCRICAO', 'DESCRICAO', 2, 'N', '', 30, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (641, 'label.prompt.atributo', '', 5, 'Y', '[ENTIDADE-PAI].DEMANDA_ID = [ENTIDADE-FILHA].DEMANDA_ID', 1, 5, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (642, 'label.prompt.responsavel', '', 6, 'Y', 'exists(select 1 from destino_usuario where usuario = [ENTIDADE-FILHA].usuarioid and destino = [ENTIDADE-PAI].destinoid)', 6, 3, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (644, 'label.prompt.gerente', '', 6, 'Y', '[ENTIDADE-FILHA].usuarioid in(SELECT RESPONSAVEL FROM RESPONSAVELENTIDADE WHERE TIPOENTIDADE = ''P'' AND IDENTIDADE = [ENTIDADE-PAI].ID)', 2, 3, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (645, 'label.prompt.calendario', '', 6, 'Y', 'select id from calendario where projeto_id = [ENTIDADE].id', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (646, 'label.prompt.baseline', '', 6, 'Y', '', 2, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (647, 'label.prompt.papel', '', 6, 'Y', '', 2, 26, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (648, 'label.title.diretorioEquipe', '', 6, 'Y', '', 2, 32, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (649, 'label.prompt.metaAtual', '', 6, 'Y', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (650, 'label.prompt.prazoDaMetaAtual', '', 6, 'Y', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (651, 'label.prompt.descricaoMetaAtual', '', 6, 'Y', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (652, 'label.prompt.escoreAtual', '', 6, 'Y', '', 9, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (653, 'label.prompt.metaAtual', '', 6, 'Y', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (654, 'label.prompt.prazoDaMetaAtual', '', 6, 'Y', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (655, 'label.prompt.descricaoMetaAtual', '', 6, 'Y', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (656, 'label.prompt.escoreAtual', '', 6, 'Y', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (657, 'label.prompt.indicadoresOriginados', '', 6, 'Y', '', 18, null, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (658, 'label.prompt.usuario', '', 6, 'Y', '', 32, 3, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (659, 'label.prompt.papel', '', 6, 'Y', '', 32, 26, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (661, 'label.prompt.atributo', '', 6, 'Y', '', 12, 11, 'N');

insert into regras_tipo_propriedade (ID, TITULO, COLUNA, TIPO_VALOR_ID, VIGENTE, WHERE_JOIN, TIPO_ENTIDADE_ID, REF_TIPO_ENTIDADE_ID, CHAVE)
values (662, 'label.prompt.atributo', '', 6, 'Y', '', 13, 11, 'N');

commit;
/

-------------------------------------------------------------------------------
-- Finalização
-------------------------------------------------------------------------------

insert into versao(id, titulo, patch, versao_tgp_id, comentario)
       values (versao_seq.nextval, '6.0.0', '03', 3, 'Aplicação de patch (parte 3)');
commit;
/
                    
select * from v_versao;
/
