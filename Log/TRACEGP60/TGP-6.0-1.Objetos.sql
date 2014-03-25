/******************************************************************************\
* Roteiro para migração à versão de calendário (5.3.0.0)                       *
* Parte I - Criação de Objetos                                                 *
* Autor: Charles Falcão                     Data de Publicação:   /   /2009    *
\******************************************************************************/

--------------------------------------------------------------------------------
--
-- Define nome dos tablespaces.
--
--------------------------------------------------------------------------------
define CS_TBL_DAT = &TABLESPACE_DADOS;
define CS_TBL_IND = &TABLESPACE_INDICES;
define CS_TBL_DOC = &TABLESPACE_DOCUMENTOS;

--------------------------------------------------------------------------------
--
--
--
--------------------------------------------------------------------------------
create index idx_pontoelet_01 
  on pontoeletronico(usuario,horasaida,dataponto) tablespace &CS_TBL_IND;

create index IDX_RESPONSAVELENTIDADE_03 
  on responsavelentidade(identidade,tipoentidade) tablespace &CS_TBL_IND;
  
CREATE INDEX IDX_ATRIBUTO_VALOR_01
  ON ATRIBUTO_VALOR(atributo_id) tablespace &CS_TBL_IND;
  
create index IDK_DIA_02
  on dia(trunc(data)) tablespace &CS_TBL_IND;
  

--------------------------------------------------------------------------------
--
-- Alterações em estruturas já existentes
--
--------------------------------------------------------------------------------

-- ATIVIDADE
alter table atividade add es number(10, 2);
alter table atividade add ef number(10, 2);
alter table atividade add ls number(10,2);
alter table atividade add lf number(10,2); 
alter table atividade add usado_fim  number(2, 1);
alter table atividade add itemwbs_id number(10);
alter table atividade add INICIO_ATRASADO date;
alter table atividade add FIM_ATRASADO date;
alter table atividade add CRITICO VARCHAR2(1) default 'N';
alter table atividade add FOLGA_TOTAL number(10, 2);
alter table ATIVIDADE rename column USADO_FIM to FOLGA_LIVRE;
alter table ATIVIDADE modify (FOLGA_LIVRE number (10, 2));

COMMENT ON COLUMN ATIVIDADE.CRITICO
        IS 'Indica se a entidade faz parte do caminho critico';
comment ON COLUMN atividade.ES
        IS 'Menor dia útil para o inicio do projeto';
COMMENT ON COLUMN atividade.EF 
        IS 'Menor dia util de fim do projeto';
comment on column atividade.ls
        is 'Maior dia útil para início da atividade';
comment on column atividade.lf
        is 'Maior dia útil para término da atividade'; 
COMMENT ON COLUMN atividade.FOLGA_LIVRE 
        IS 'Controle de quanto foi usado por uma entidade do seu ultimo dia. Util para agilizar os calculos do cronograma';

-- BASELINE
alter table baseline modify titulo varchar2(4000);
alter table baseline modify descricao varchar2(4000);

-- BASELINE_ENTIDADE
alter table baseline_entidade add externa varchar2(1) default 'N';

-- BASELINE_CUSTO_ENTIDADE
alter table baseline_custo_entidade modify (custo_entidade_id null);

-- BASELINE_CUSTO_LANCAMENTO
alter table baseline_custo_lancamento modify (custo_lancamento_id null);

-- CONFIGURACOES
alter table CONFIGURACOES add ALOC_AUTOMATICA_TAREFA_AVULSA varchar2(1) default 'Y' NOT NULL;
alter table CONFIGURACOES add REGRA_ALOC_TAREFA_AVULSA      number(1,0) default '6' NOT NULL;
alter table CONFIGURACOES add HORAS_REGRA_TAREFA_AVULSA     number(10,0);
alter table CONFIGURACOES add ALOC_AUTOMATICA_PROJETO       varchar2(1) default 'Y' NOT NULL;
alter table CONFIGURACOES add REGRA_ALOC_PROJETO            number(1,0) default '2' NOT NULL;
alter table CONFIGURACOES add HORAS_REGRA_PROJETO           number(10,0);

comment on column CONFIGURACOES.ALOC_AUTOMATICA_TAREFA_AVULSA 
        is 'Y se a opcao de alocacao automatica for para vir marcada na criacao de tarefas avulsas.';
comment on column CONFIGURACOES.REGRA_ALOC_TAREFA_AVULSA 
        is 'Regra de alocacao default para tarefas avulsas.';
comment on column CONFIGURACOES.HORAS_REGRA_TAREFA_AVULSA 
        is 'Quantidade de minutos utilizados na regra default de alocacao da tarefa avulsa de horas por dia.';
comment on column CONFIGURACOES.ALOC_AUTOMATICA_PROJETO 
        is 'Y se a opcao de alocacao automatica for para vir marcada na criacao de projetos.';
comment on column CONFIGURACOES.REGRA_ALOC_PROJETO 
        is 'Regra de alocacao default para projetos.';
comment on column CONFIGURACOES.HORAS_REGRA_PROJETO 
        is 'Quantidade de minutos utilizados na regra default de alocacao do projeto de horas por dia.';

-- CONHECIMENTOPAPEL
alter table conhecimentopapel rename column nivelrequerido to nivel;
alter table conhecimentopapel drop column niveldesejado;

-- CONHECIMENTO_USUARIO
alter table conhecimento_usuario drop primary key;
alter table conhecimento_usuario drop constraint FK_CONH_USUARIO_02;
alter table conhecimento_usuario add id number(10);
alter table conhecimento_usuario add constraint UK_CONHECIMENTO_USUARIO_01
      unique (usuario_id, conhecimento_id) using index tablespace &CS_TBL_IND;
      
create sequence conhecimento_usuario_seq
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache; 
      
comment on table conhecimento_usuario
        is 'Mantém o vínculo entre conhecimento e usuários, registra somente conhecimentos aprovados';
comment on column conhecimento_usuario.id 
        is 'Id sequencial do conhecimento de usuários (PK)';
comment on column conhecimento_usuario.conhecimento_id
        is 'Chave de Ligação com a tabela de Conhecimento (FK)';
comment on column conhecimento_usuario.usuario_id 
        is 'Chave de Ligação com a tabela de Usuário (FK)';
comment on column conhecimento_usuario.nivel_id 
        is 'Determina o nível do conhecimento para o usuário, chave de Ligação com a tabela NIVELCONHECIMENTO (FK)';
      
-- CONFIGURACOES
alter table configuracoes add situacao_aval_projeto varchar2(1);
alter table configuracoes add situacao_avaliacao    varchar2(1);

-- DEPENDENCIAATIVIDADETAREFA
ALTER TABLE DEPENDENCIAATIVIDADETAREFA ADD PROJETO_PREDECESSORA NUMBER(10);

COMMENT ON COLUMN DEPENDENCIAATIVIDADETAREFA.PROJETO_PREDECESSORA
        IS 'Campo que indica o projeto da predecessora';
        

-- ESTADO_FORMULARIO
alter table estado_formulario add estado_desenho_id varchar2(50); 

comment on column estado_formulario.estado_desenho_id 
        is 'Identificador do elemento no desenho de fluxo.'; 
        
-- FILTRO
alter table filtro add marca_uso_indicador varchar2(1) default 'N' not null;

comment on column filtro.marca_uso_indicador
        is 'Indica se é utilizado como filtro ou como método de atualização de indicador.';

-- FORMULARIO
alter table formulario add data_atualizacao_estados date; 

comment on column formulario.data_atualizacao_estados 
        is 'Data na qual a ultima informacao de estados do formulario foi alterada. Dado utilizado no desenho do fluxo de estados.'; 

-- H_USUARIO
alter table h_usuario add login              varchar2(50);
alter table h_usuario add gerente_recurso    varchar2(50);
alter table h_usuario add calendario_base_id number(10);
alter table h_usuario add modificador        varchar2(50);

comment on column h_usuario.login
        is 'Login do usuário';
comment on column h_usuario.gerente_recurso
        is 'Gerente de recurso responsável pelo usuário';  
comment on column h_usuario.calendario_base_id
        is 'Calendário base do usuário';
comment on column h_usuario.modificador
        is 'Último usuário que realizou alteração no registro';
        
-- ITEMWBS
alter table itemwbs add atividade_id number(10);

alter table itemwbs add constraint FK_ITEMWBS_01
  foreign key (atividade_id) references atividade(id) on delete set null;
          
-- LOG_VALOR_HORA_USUARIO
create sequence log_valor_hora_usuario_seq
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache; 
       
-- MAPA_INDICADOR_QUESTAO
alter table mapa_indicador_questao add formato varchar2(1) default 'L' not null;
alter table mapa_indicador_questao add constraint CHK_MAPA_INDICADOR_QUESTAO_03
  check (formato in ('C', 'L'));
comment on column mapa_indicador_questao.formato
     is 'Define como serão apresentadas as opções de respostas da pergunta: (C)ombobox ou (L)ista';
      
-- MAPA_INDICADOR_QUEBRA
alter table mapa_indicador_quebra drop column vigente;

-- MAPA_OBJETIVO
alter table mapa_objetivo add perspectiva_id number(10);

alter table mapa_objetivo add constraint CHK_MAPA_OBJETIVO_05
  check ((tipo_entidade = 'E' and perspectiva_id is not null) or perspectiva_id is null);
  
alter table mapa_objetivo drop constraint CHK_MAPA_OBJETIVO_02;
alter table mapa_objetivo add  constraint CHK_MAPA_OBJETIVO_02
  check (frequencia_apuracao in ('D', 'S', 'M', 'A', 'L', 'U'));
  
-- MAPA_ROTINA
alter table mapa_rotina add descricao varchar2(4000);
alter table mapa_rotina drop column usuario_criacao_id;
alter table mapa_rotina drop column usuario_atualizacao_id;

-- PAPELPROJETO
alter table papelprojeto add valor_hora number(21,2);

create sequence papelprojeto_seq
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache; 

comment on column papelprojeto.valor_hora
        is 'Armazena o valor hora do papel';
        
       
-- PROJETO
alter table projeto add calendario_base_id     number(10);
alter table projeto add regra_alocacao         number(1);
alter table projeto add alocar_automaticamente varchar2(1) default 'N' not null;
alter table projeto add regra_alocacao_horas   number(5);
alter table projeto add es                     number(10,2);
alter table projeto add ef                     number(10,2);
alter table projeto add ls                     number(10,2);
alter table projeto add lf                     number(10,2);
alter table projeto add usado_fim              number(2,1);
alter table projeto add INICIO_ATRASADO        date;
alter table projeto add FIM_ATRASADO           date;
alter table projeto add CRITICO                varchar2(1) default 'N';
alter table projeto add FOLGA_TOTAL            number(10, 2);
alter table projeto add ATUALIZACAO_PENDENTE   varchar2(1) default 'N' not null;
alter table projeto rename column USADO_FIM to FOLGA_LIVRE;
alter table projeto modify (FOLGA_LIVRE number(10, 2));

COMMENT ON COLUMN PROJETO.CRITICO 
        IS 'Indica se a entidade faz parte do caminho critico';

alter table projeto add constraint CHK_PROJETO_05
  check (alocar_automaticamente in ('N', 'Y'));
alter table projeto add constraint CHK_PROJETO_06
  check (ATUALIZACAO_PENDENTE in ('N', 'Y'));

create index IDX_PROJETO_05
       on projeto (calendario_base_id) tablespace &CS_TBL_IND;
       
comment on column projeto.calendario_base_id
        is 'Calendário base do projeto (Não é o calendário do projeto)';
comment on column projeto.regra_alocacao
        is 'Regra de alocação de recursos padrão do projeto';
comment on column projeto.alocar_automaticamente
        is 'Indica se o projeto vai alocar automaticamente as suas tarefas';
comment on column projeto.regra_alocacao_horas
        is 'Quantidade de horas usada na regra de alocação';
COMMENT ON COLUMN PROJETO.ES
        IS 'Menor dia útil para o inicio do projeto';
COMMENT ON COLUMN PROJETO.EF 
        IS 'Menor dia util de fim do projeto';
comment on column projeto.ls
        is 'Maior dia útil para início do projeto';
comment on column projeto.lf
        is 'Maior dia útil para término do projeto';  
COMMENT ON COLUMN PROJETO.FOLGA_LIVRE 
        IS 'Controle de quanto foi usado por uma entidade do seu ultimo dia. Util para agilizar os calculos do cronograma';
COMMENT ON COLUMN PROJETO.ATUALIZACAO_PENDENTE 
        IS 'Indicao se o projeto deve ser atualizado por causa da alteração de datas de alguma entidade externa.';


-- RESPONSABILIDADE
create sequence responsabilidade_seq
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache; 
       
-- TAREFA
alter table tarefa add papelprojeto_id number(10);
alter table tarefa add regra_alocacao         number(1);
alter table tarefa add regra_alocacao_horas   number(5);
alter table tarefa add alocar_automaticamente varchar2(1) default 'N' not null;
alter table tarefa add es                     number(10, 2);
alter table tarefa add ef                     number(10, 2);
alter table tarefa add ls                     number(10,2);
alter table tarefa add lf                     number(10,2);
alter table tarefa add usado_fim              number(2, 1);
alter table tarefa add INICIO_ATRASADO        date;
alter table tarefa add FIM_ATRASADO           date;
alter table tarefa add CRITICO                varchar2(1) default 'N';
alter table TAREFA add FOLGA_TOTAL            number (10, 2);
alter table TAREFA rename column USADO_FIM to FOLGA_LIVRE;
alter table TAREFA modify (FOLGA_LIVRE number (10, 2));

COMMENT ON COLUMN TAREFA.CRITICO 
        is 'Indica se a entidade faz parte do caminho critico';

alter table tarefa add constraint chk_tarefa_02
  check (alocar_automaticamente in ('N', 'Y'));

create index IDX_TAREFA_05
       on tarefa (papelprojeto_id) tablespace &cs_tbl_ind;
       
comment on column tarefa.papelprojeto_id
        is 'Papel relacionado a tarefa';
comment on column tarefa.alocar_automaticamente
        is 'Indica se a tarefa vai realizar alocação automática (utilizado apenas em tarefa avulsa)';
comment on column tarefa.es
        IS 'Menor dia útil para o inicio do projeto';
comment on column tarefa.ef 
        IS 'Menor dia util de fim do projeto';
comment on column tarefa.ls
        is 'Maior dia útil para início da tarefa';
comment on column tarefa.lf
        is 'Maior dia útil para término da tarefa';  
comment on column tarefa.FOLGA_LIVRE 
        IS 'Controle de quanto foi usado por uma entidade do seu ultimo dia. Util para agilizar os calculos do cronograma';
    
-- TIPO_DOCUMENTO
alter table tipo_documento add plano_acao varchar2(1) default 'N';

-- TRANSICAO_ESTADO
alter table transicao_estado add transicao_desenho_id varchar2(50); 

comment on column transicao_estado.transicao_desenho_id
        is 'Identificador da transicao no desenho de fluxo.'; 
      
-- USUARIO
alter table usuario add gerente_recurso     varchar2(50);
alter table usuario add calendario_base_id  number(10);
alter table usuario add modificador         varchar2(50);
alter table usuario add agenda_aba_padrao   varchar2(1) default 'C';
alter table usuario add agenda_visao_padrao varchar2(1) default 'M';

alter table usuario add constraint CHK_USUARIO_06
  check (agenda_aba_padrao in ('C', 'P', 'A', 'D'));

alter table usuario add constraint CHK_USUARIO_07
  check (agenda_visao_padrao in ('M', 'S', 'D'));

create index IDX_USUARIO_06
       on usuario (gerente_recurso) tablespace &CS_TBL_IND;
create index IDX_USUARIO_07
       on usuario (calendario_base_id) tablespace &CS_TBL_IND; 
       
comment on column usuario.login
        is 'Login do usuário';
comment on column usuario.gerente_recurso
        is 'Gerente de recurso responsável pelo usuário';  
comment on column usuario.calendario_base_id
        is 'Calendário base do usuário';
comment on column usuario.modificador
        is 'Último usuário que realizou alteração no registro';

--------------------------------------------------------------------------------
--
-- Criação da estrutura de TABLES, CONSTRAINTS (exceto FKs), INDEXES e SEQUENCES
--
--------------------------------------------------------------------------------

-- CALENDARIO [INI]
create table calendario (
  id            number(10)    not null,
  titulo        varchar2(250) not null,
  pai_id        number(10)    null,
  projeto_id    number(10)    null,
  vigente       varchar2(1)   default 'Y' not null,
  carga_horaria number(10)    null,
  tipo          varchar2(1)   not null,
  constraint PK_CALENDARIO primary key (id) using index tablespace &CS_TBL_IND,
  constraint CHK_CALENDARIO_01 check (vigente in ('Y', 'N')),
  constraint CHK_CALENDARIO_02 check (tipo in ('B', 'P')),
  constraint CHK_CALENDARIO_03 check (pai_id is not null or (pai_id is null and carga_horaria is not null))
) tablespace &CS_TBL_DAT;

create index IDX_CALENDARIO_01
       on calendario (pai_id) tablespace &CS_TBL_IND;
create index IDX_CALENDARIO_02
       on calendario (projeto_id) tablespace &CS_TBL_IND;

create sequence calendario_seq
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache; 
       
comment on table calendario
        is 'Tabela de calendários (base e projeto)';
comment on column calendario.id
        is 'Identificador único do calendário (PK)';
comment on column calendario.pai_id
        is 'Identificador do calendário pai'; 
comment on column calendario.projeto_id
        is 'Projeto ao qual pertence o calendário';  
comment on column calendario.vigente
        is 'Indicador de calendário vigente';  
comment on column calendario.carga_horaria
        is 'Carga horária padrão do calendário para dias entre segunda e sexta';  
comment on column calendario.carga_horaria
        is 'Tipo de calendário (B)ase ou de (P)rojeto';         
-- CALENDARIO [FIM]

-- CONHECIMENTO_PROFISSIONAL [INI]
create table conhecimento_profissional (
  id            number(10)    not null,
  id_pai        number(10)    null,
  titulo        varchar2(150) not null,
  descricao     varchar2(250) null,
  vigente       varchar2(1)   default 'N' not null,
  nivel_default number(10)    null,
  tipo          varchar2(1)   not null,
  constraint PK_CONHECIMENTO_PROFISSIONAL primary key (id) using index tablespace &CS_TBL_IND,
  constraint CHK_CONHECIMENTO_PROF_01 check (tipo in ('C', 'G')),
  constraint CHK_CONHECIMENTO_PROF_02 check (vigente in ('Y', 'N'))
) tablespace &CS_TBL_DAT;
  
create sequence conhecimento_profissional_seq
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache; 
       
comment on table conhecimento_profissional
        is 'Cadastro conhecimentos de profissionais, mantém uma estrutura em árvore dos conhecimentos';
comment on column conhecimento_profissional.id
        is 'Id do conhecimento (PK)';
comment on column conhecimento_profissional.id_pai
        is 'Id do conhecimento pai utilizado para montar a estrutura em árvore';
comment on column conhecimento_profissional.titulo 
        is 'Título do Conhecimento Profissional';
comment on column conhecimento_profissional.descricao
        is 'Descrição do Conhecimento Profissional';
comment on column conhecimento_profissional.vigente
        is 'Determina a vigência do conhecimento profissional';
comment on column conhecimento_profissional.tipo
        is 'Determina se o registro é um (G)rupo ou um (C)onhecimento';
-- CONHECIMENTO_PROFISSIONAL [FIM]

-- CONHEC_USUARIO_AVAL [INI]
create table conhec_usuario_aval(
  id                   number(10)    not null,
  conhecimento_id      number(10)    not null,
  usuario_id           varchar2(50)  not null,
  nivel_id             number(10)    not null,
  usuario_avaliador_id varchar2(50)  null,
  data_avaliacao       date          null,
  usuario_aprovador_id varchar2(50)  null,
  data_aprovacao       date          null,
  projeto_id           number(10)    null,
  situacao             varchar2(1)   null,
  motivo               varchar2(250) null,
  justificativa        varchar2(250) null,
  constraint PK_CONHEC_USUARIO_AVAL primary key (id) using index tablespace &CS_TBL_IND,
  constraint CHK_CONHEC_USUARIO_AVAL_01 check (situacao in ('P', 'A', 'R', 'E'))
) tablespace &CS_TBL_DAT;

create sequence conhec_usuario_aval_seq
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache; 
       
comment on table conhec_usuario_aval
        is  'Mantém os registros de solicitação de vinculo entre conhecimento e usuário. Esse registro passa pela aprovação do Gerente de Recurso';
comment on column conhec_usuario_aval.id
        is 'Id sequencial da tabela(PK)';
comment on column conhec_usuario_aval.conhecimento_id 
        is 'Chave de Ligação com a tabela de Conhecimento (FK)';
comment on column conhec_usuario_aval.usuario_id
        is 'Chave de Ligação com a tabela de Usuário (FK)';
comment on column conhec_usuario_aval.usuario_avaliador_id
        is 'Usuário que vinculou o conhecimento a um usuário.';
comment on column conhec_usuario_aval.data_avaliacao
        is 'Data em que o usuario avaliador vinculou o conhecimento a um usuário.';
comment on column conhec_usuario_aval.usuario_aprovador_id
        is 'Usuário que aprovou o vínculo de conhecimento ao usuário.';
comment on column conhec_usuario_aval.data_avaliacao 
        is 'Data em que o usuario aprovador aprovou o vínculo de conhecimento a um usuário.';
comment on column conhec_usuario_aval.projeto_id
        is 'Chave de Ligação com o projeto em que foi solicitado vinculo de conhecimento a um usuário. Não é obrigatório';
comment on column conhec_usuario_aval.situacao
        is 'Situação em que o registro se encontra P=(Pendente), A=(Aprovado, R=(Reprovado), E=Excluído)';
comment on column conhec_usuario_aval.motivo
        is 'Motivo da troca de situação';
comment on column conhec_usuario_aval.justificativa 
        is 'Motivo da inclusão de uma avaliação de conhecimento criado pelo gerente de projetos';
-- CONHEC_USUARIO_AVAL [FIM]

-- DIAGRAMA_NODO_ENTIDADE [INI]
create table diagrama_nodo_entidade(
  id     number(10)    not null,
  titulo varchar2(150) not null,
constraint pk_diagrama_nodo_entidade primary key (id) using index tablespace &cs_tbl_ind,
constraint uk_diagrama_nodo_entidade_01 unique (titulo) using index tablespace &cs_tbl_ind
)tablespace &cs_tbl_dat;

create sequence diagrama_nodo_entidade_seq
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache; 

comment on table diagrama_nodo_entidade
        is 'Tabela contendo as opções de visualização no nodo do diagrama';
comment on column diagrama_nodo_entidade.id
        is 'Chave Primária da Tabela';
comment on column diagrama_nodo_entidade.titulo 
        is 'Corresponde a uma informação da tarefa';
-- DIAGRAMA_NODO_ENTIDADE [FIM]

-- DIAGRAMA_REDE_VISAO [INI]
create table diagrama_rede_visao(
  id                       number(10)     not null,
  projeto_id               number(10)     null,
  titulo                   varchar2(150)  not null, 
  descricao                varchar2(4000) null,
  vigente                  varchar2(1)    default 'Y' not null,
  publico                  varchar2(1)    default 'N' not null,
  cores_estado             varchar2(1)    default 'N' not null,
  ls_visivel               varchar2(1)    default 'N' not null,
  lf_visivel               varchar2(1)    default 'N' not null,
  es_visivel               varchar2(1)    default 'N' not null,
  ef_visivel               varchar2(1)    default 'N' not null,
  folga_visivel            varchar2(1)    default 'N' not null,
  formato                  varchar2(1)    default 'H' not null,
  data_criacao             date           default sysdate not null,
  data_atualizacao         date           default sysdate not null,
  usuario_criacao_id       varchar2(50)   null,
  usuario_atualizacao_id   varchar2(50)   null,
constraint PK_DIAGRAMA_VISAO primary key (id) using index tablespace &cs_tbl_ind,
constraint CHK_DIAGRAMA_VISAO_01 check (vigente in ('Y', 'N')),
constraint CHK_DIAGRAMA_VISAO_02 check (publico in ('Y', 'N')),
constraint CHK_DIAGRAMA_VISAO_03 check (ls_visivel in ('Y', 'N')),
constraint CHK_DIAGRAMA_VISAO_04 check (lf_visivel in ('Y', 'N')),
constraint CHK_DIAGRAMA_VISAO_05 check (es_visivel in ('Y', 'N')),
constraint CHK_DIAGRAMA_VISAO_06 check (ef_visivel in ('Y', 'N')),
constraint CHK_DIAGRAMA_VISAO_07 check (formato in ('H', 'L'))
) tablespace &cs_tbl_dat;

create sequence diagrama_rede_visao_seq
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache; 

comment on table diagrama_rede_visao
        is 'Tabela contendo as visões do diagrama de rede';
comment on column diagrama_rede_visao.id
        is 'Chave Primária da Tabela';
comment on column diagrama_rede_visao.projeto_id 
        is 'Id do projeto em que está vinculado. Se estiver em branco significa que é a visão padrão dos projetos iniciais';
comment on column diagrama_rede_visao.descricao
        is 'Descrição da visão';
comment on column diagrama_rede_visao.vigente
        is 'Vigência da visão';
comment on column diagrama_rede_visao.publico
        is 'Se a visão poderá ser visualizada pelos demais usuários em outros projetos';
comment on column diagrama_rede_visao.cores_estado
        is 'Se o diagrama apresenta os nodos(tarefas)com cores diferentes de acordo com sua situação';
comment on column diagrama_rede_visao.ls_visivel
        is 'Se a informação LS (late start) aparecerá no diagrama em cada nodo.Significa a data limite para a tarefa começar sem atrasar o cronograma';
comment on column diagrama_rede_visao.lf_visivel
        is 'Se a informação LF (late finish) aparecerá no diagrama em cada nodo.Significa a data limite para a tarefa terminar sem atrasar o cronograma ';
comment on column diagrama_rede_visao.es_visivel
        is 'Se a informação ES (early start) aparecerá no diagrama em cada nodo.Significa a data mais cedo que a tarefa pode começar';
comment on column diagrama_rede_visao.ef_visivel
        is 'Se a informação EF (early finish) aparecerá no diagrama em cada nodo .Significa a data mais cedo que a tarefa pode terminar';
comment on column diagrama_rede_visao.folga_visivel
        is 'Se a informação de folga aparecerá no diagrama em cada nodo';
comment on column diagrama_rede_visao.formato
        is 'Se a o formato das informações calculadas (ES,EF,LS,LF) serão visualizadas em formato de hint ou nas laterais de cada nodo ';      
-- DIAGRAMA_REDE_VISAO [FIM]

-- DIAGRAMA_VISAO_NODOS [INI]
create table diagrama_visao_nodos(
  id                       number(10)     not null,
  visao_id                 number(10)     not null,
  visao_nodo_id            number(10)     not null,
  visivel                  varchar2(1)    default 'Y' not null,
  data_criacao             date           default sysdate not null,
  data_atualizacao         date           default sysdate not null,
  usuario_criacao_id       varchar2(50)   null,
  usuario_atualizacao_id   varchar2(50)   null,
constraint PK_DIAGRAMA_VISAO_NODO primary key (id) using index tablespace &cs_tbl_ind
)tablespace &cs_tbl_dat;

create sequence diagrama_visao_nodo_seq
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache; 
       
comment on table diagrama_visao_nodos
        is 'Tabela que guarda as informações de visualização dos nodos';
comment on column diagrama_visao_nodos.id
        is 'Chave Primária da Tabela';
comment on column diagrama_visao_nodos.visao_id
        is 'Id da visão';
comment on column diagrama_visao_nodos.visao_nodo_id
        is 'Id da informação do nodo do diagrama na visão ';
comment on column diagrama_visao_nodos.visivel
        is 'Se a informação do nodo estará visivel no diagrama nesta visão.';
-- DIAGRAMA_VISAO_NODOS [FIM]

-- DIAGRAMA_VISAO_PROJETO_PADRAO [INI]
create table diagrama_visao_projeto_padrao( 
  id          number(10)     not null,
  visao_id    number(10)     not null,
  projeto_id  number(10)     not null,
  usuario_id  varchar2(50)   not null,
constraint PK_DIAG_VISAO_PROJ_PADRAO primary key (id) using index tablespace &cs_tbl_ind,
constraint UK_DIAG_VISAO_PROJ_PADRAO_01 unique (visao_id,projeto_id,usuario_id) using index tablespace &cs_tbl_ind
) tablespace &cs_tbl_dat;
  
comment on table diagrama_visao_projeto_padrao
        is 'Tabela que guarda as informações das visões padrão para o usuário em determinado projeto';
comment on column diagrama_visao_projeto_padrao.visao_id
        is 'Id da visao';
comment on column diagrama_visao_projeto_padrao.projeto_id
        is 'Id do projeto';
comment on column diagrama_visao_projeto_padrao.usuario_id
        is 'Id do usuario';
--

-- FORMULARIO_FLUXO_DESENHO [INI]
create table formulario_fluxo_desenho ( 
  formulario_id number(10) not null, 
  desenho       blob, 
  data          date
) tablespace &CS_TBL_DAT;

comment on column formulario_fluxo_desenho.formulario_id 
        is 'Formulario que esta ligado ao desenho de fluxo de estados'; 
comment on column formulario_fluxo_desenho.desenho      
        is 'Desenho do fluxo de estados do formulario'; 
comment on column formulario_fluxo_desenho.data
        is 'Data na qual o desenho foi salvo.'; 
-- FORMULARIO_FLUXO_DESENHO [FIM]

-- HORA_ALOCADA [INI]
create table hora_alocada (
  id              number(10)     not null,
  tarefa_id       number(10)     not null,
  data            date           not null,
  minutos         number(10)     not null,
  constraint PK_HORA_ALOCADA primary key (id) using index tablespace &CS_TBL_IND,
  constraint uk_hora_alocada unique (tarefa_id, data) using index tablespace &cs_tbl_ind,
  constraint chk_hora_alocada_02 check (data = trunc(data))  
) tablespace &CS_TBL_DAT;

create index IDX_HORA_ALOCADA_01
       on hora_alocada(tarefa_id, trunc(data)) tablespace &CS_TBL_IND;

create sequence hora_alocada_seq
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache; 
       
comment on table hora_alocada
        is 'Tabela com alocação de horas para as tarefas';
comment on column hora_alocada.id
        is 'Identificador único (PK)';
comment on column hora_alocada.tarefa_id
        is 'Tarefa a qual refere-se a alocação';
comment on column hora_alocada.data
        is 'Data a qual refere-se a alocação';        
comment on column hora_alocada.minutos
        is 'Quantidade de minutos alocada';
-- HORA_ALOCADA [FIM]

-- FORMULARIO_FLUXO_DESENHO [INI]
create table FORMULARIO_FLUXO_DESENHO(
  formulario_id   number(10) not null, 
  desenho         blob,
  data            date,
  constraint PK_FORMULARIO_FLUXO_DESENHO primary key (formulario_id) using index tablespace &CS_TBL_IND
) tablespace &CS_TBL_DAT;
-- FORMULARIO_FLUCO_DESENHO [FIM]

-- LOG_TRACEGP [INI]
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
-- LOG_TRACEGP [FIM]

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
) tablespace gptrace_dat;

create sequence mapa_consulta_params_seq
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache; 
-- MAPA_CONSULTA_PARAMS [FIM]

-- MAPA_ESTRATEGICO [INI]
create table mapa_estrategico (
  id                      number(10)     not null, 
  codigo                  varchar2(8)    not null, 
  titulo                  varchar2(250)  not null, 
  descricao               varchar2(4000) null, 
  missao                  varchar2(4000) null, 
  visao                   varchar2(4000) null, 
  tipo                    varchar2(1)    not null, 
  criador                 varchar2(50)   not null, 
  data_inicio             date           default trunc(sysdate) not null, 
  data_fim                date           not null, 
  visualizar_aba_objetivo varchar2(1) 	 default 'I', 
  visualizar_causa_efeito varchar2(1)    default 'N', 
  visualizar_dependencia  varchar2(1) 	 default 'N', 
  visualizar_missao 	    varchar2(1)    default 'N', 
  visualizar_visao        varchar2(1) 	 default 'N', 
  visualizar_escore 	    varchar2(1) 	 default 'N', 
  data_criacao      		  date           default sysdate not null,
  data_atualizacao  	    date           default sysdate not null,
  usuario_atualizacao_id  varchar2(50)   not null,
  desenho                 blob           null,
constraint PK_MAPA_ESTRATEGICO primary key (id) using index tablespace &CS_TBL_IND,
constraint CHK_MAPA_ESTRATEGICO_01 check (tipo in ('N', 'B')), 
constraint CHK_MAPA_ESTRATEGICO_02 check (visualizar_aba_objetivo in ('I', 'F', 'G', 'E', 'A', 'M', 'P', 'H')), 
constraint CHK_MAPA_ESTRATEGICO_03 check (visualizar_causa_efeito in ('Y','N')), 
constraint CHK_MAPA_ESTRATEGICO_04 check (visualizar_dependencia in ('Y','N')), 
constraint CHK_MAPA_ESTRATEGICO_05 check (visualizar_missao in ('Y','N')), 
constraint CHK_MAPA_ESTRATEGICO_06 check (visualizar_visao in ('Y','N')), 
constraint CHK_MAPA_ESTRATEGICO_07 check (visualizar_escore in ('Y','N')) 
) tablespace &CS_TBL_DAT;

create sequence mapa_estrategico_seq
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache; 
       
create index IDX_MAPA_ESTRATEGICO_01
       on mapa_estrategico(codigo) tablespace &CS_TBL_IND;
create index IDX_MAPA_ESTRATEGICO_02
       on mapa_estrategico(criador) tablespace &CS_TBL_IND;       
       
comment on column mapa_estrategico.id  
        is 'Identificador do Registro'; 
comment on column mapa_estrategico.codigo  
        is 'Código do Mapa Estratégico'; 
comment on column mapa_estrategico.titulo  
        is 'Título do Mapa Estratégico'; 
comment on column mapa_estrategico.descricao  
        is 'Descrição do Mapa Estratégico'; 
comment on column mapa_estrategico.tipo 
        is 'B-BSC, N-Não BSC'; 
comment on column mapa_estrategico.data_inicio 
        is 'Data Início de vigência'; 
comment on column mapa_estrategico.data_fim  
        is 'Data Fim de vigência'; 
comment on column mapa_estrategico.criador  
        is 'Usuário criador do mapa';
comment on column MAPA_ESTRATEGICO.VISUALIZAR_ABA_OBJETIVO 
        is 'Indica qual aba da tela de informacoes sera mostrada ao se selecionar um objetivo. Os valores podem ser: C (cadastro geral), A (agrupadores), I (indicadores), E (escore), M (meta), F (faixas), P (plano de acao), H (historico).';
comment on column MAPA_ESTRATEGICO.VISUALIZAR_CAUSA_EFEITO 
        is 'Indica se as relacoes de causa e efeito serao visiveis no desenho ou nao.';
comment on column MAPA_ESTRATEGICO.VISUALIZAR_DEPENDENCIA 
        is 'Indica se as relacoes de dependencia serao visiveis no desenho ou nao.';
comment on column MAPA_ESTRATEGICO.VISUALIZAR_MISSAO 
        is 'Indica se a missao sera exibida no desenho ou nao.';
comment on column MAPA_ESTRATEGICO.VISUALIZAR_VISAO 
        is 'Indica se a visao sera exibida no desenho ou nao.';
comment on column MAPA_ESTRATEGICO.VISUALIZAR_ESCORE
        is 'Indica se o score do objetivo sera mostrado visualmente no desenho ou nao.';
comment on column MAPA_ESTRATEGICO.DESENHO 
        is 'Conteudo do desenho do mapa.';
-- MAPA_ESTRATEGICO [FIM]

-- MAPA_OBJETIVO_PL_ACAO [INI]
create table mapa_objetivo_pl_acao (
  id                       number(10)     not null,
  objetivo_id              number(10)     not null,
  descricao                varchar2(4000) null,
  justificativa            varchar2(4000) null,
  responsavel_id           varchar2(50)   null,
  data_criacao             date           default sysdate not null,
  data_atualizacao         date           default sysdate not null,
  usuario_criacao_id       varchar2(50)   not null,
  usuario_atualizacao_id   varchar2(50)   not null,
constraint PK_MAPA_OBJETIVO_PL_ACAO primary key (id) using index tablespace &cs_tbl_ind
)tablespace &cs_tbl_dat;

create sequence mapa_objetivo_pl_acao_seq
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache;
-- MAPA_OBJETIVO_PL_ACAO [FIM]

-- MAPA_OBJETIVO_PL_ACAO_INIC [INI]
create table mapa_objetivo_pl_acao_inic(
  id                       number(10)     not null,
  pl_acao_id               number(10)     not null,
  entidade_id              number(10)     null,
  tipo_entidade            varchar2(1)    null, 
  titulo                   varchar2(150)  null,
  descricao                varchar2(4000) null,
  data_criacao             date           default sysdate not null,
  data_atualizacao         date           default sysdate not null,
  usuario_criacao_id       varchar2(50)   not null,
  usuario_atualizacao_id   varchar2(50)   not null,
constraint PK_MAPA_OBJETIVO_PL_ACAO_INIC primary key (id) using index tablespace &cs_tbl_ind
)tablespace &cs_tbl_dat;

create sequence mapa_objetivo_pl_acao_inic_seq
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache;
-- MAPA_OBJETIVO_PL_ACAO_INIC [FIM]

-- MAPA_PERSPECTIVA [INI]
CREATE TABLE MAPA_PERSPECTIVA (
  ID 				NUMBER(10) 		 NOT NULL , 
  MAPA_ID 	NUMBER(10) 		 NOT NULL , 
  TITULO 		VARCHAR2(150)  NOT NULL , 
  ORDEM 		NUMBER(10) 		 NOT NULL , 
CONSTRAINT PK_MAPA_PERSPECTIVA PRIMARY KEY (ID) USING INDEX  TABLESPACE &cs_tbl_ind
) TABLESPACE &cs_tbl_dat ;

create sequence mapa_perspectiva_seq
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache;
-- MAPA_PERSPECTIVA [FIM]

-- MAPA_RELACAO [INI]
CREATE TABLE MAPA_RELACAO (
  ID 				   NUMBER(10,0) 	NOT NULL , 
  MAPA_ID 		 NUMBER(10,0) 	NOT NULL , 
  ORIGEM_ID  	 NUMBER(10,0) 	NOT NULL ,
  TIPO_ORIGEM  VARCHAR2(1)		NOT NULL ,
  DESTINO_ID 	 NUMBER(10,0) 	NOT NULL ,
  TIPO_DESTINO VARCHAR2(1)		NOT NULL ,
  TIPO_RELACAO VARCHAR2(1)		NOT NULL ,
CONSTRAINT PK_MAPA_RELACAO PRIMARY KEY (ID) USING INDEX  TABLESPACE &cs_tbl_ind,
CONSTRAINT CHK_MAPA_RELACAO_1 CHECK (TIPO_ORIGEM IN ('M','P','O')),
CONSTRAINT CHK_MAPA_RELACAO_2 CHECK (TIPO_DESTINO IN ('M','P','O')),
CONSTRAINT CHK_MAPA_RELACAO_3 CHECK (TIPO_RELACAO IN ('C','D'))
) TABLESPACE &cs_tbl_dat ;

create sequence mapa_relacao_seq
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache;
-- MAPA_RELACAO [FIM]

-- MAPA_VISAO [INI]
create table MAPA_VISAO (
  ID            NUMBER(10)   not null,
  TITULO        VARCHAR2(50) not null,
  TIPO_ENTIDADE VARCHAR2(1)  not null,
constraint PK_MAPA_VISAO primary key (id) using index tablespace &CS_TBL_IND,
constraint CHK_MAPA_VISAO_01 check (tipo_entidade in ('M', 'O', 'I', 'N'))
)tablespace &CS_TBL_DAT;

comment on table MAPA_VISAO
  is 'Visao de uma entidade dos tipos Mapa/Objetivo/Indicador/Iniciativa';
comment on column MAPA_VISAO.TIPO_ENTIDADE
  is '(M)apa, (O)bjetivo, (I)ndicador, I(N)iciativa';
  
create sequence mapa_visao_seq
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache; 
-- MAPA_VISAO [FIM]

-- MAPA_VISAO_COMPONENTE [INI]
create table MAPA_VISAO_COMPONENTE (
  ID                  NUMBER(10)   not null,
  VISAO_ID            NUMBER(10)   not null,
  TAG_COMPONENTE      VARCHAR2(80) not null,
  ORDEM               NUMBER(4)    not null,
  POS_X               NUMBER       default 0 not null,
  LARGURA             NUMBER       not null,
  ALTURA              NUMBER       not null,
  Y_AUTO              VARCHAR2(1)  default 'N' not null,
  ALTURA_AUTO         VARCHAR2(1)  default 'N' not null,
  TIPO                VARCHAR2(1)  not null,
  TEXTO               VARCHAR2(4000),
  TIPO_GRAFICO        VARCHAR2(1)  default 'N' not null,
  FLAG_EXPANDIDO      VARCHAR2(1)  default 'Y' not null,
  VISAO_COMPONENTE_ID NUMBER(1),
  TIPO_POS_X          VARCHAR2(1)  default 'P' not null,
  TIPO_POS_Y          VARCHAR2(1)  default 'P' not null,
  TIPO_LARGURA        VARCHAR2(1)  default 'P' not null,
  TIPO_ALTURA         VARCHAR2(1)  default 'P' not null,
  POS_Y               NUMBER       default 0 not null,
  NEGRITO             VARCHAR2(1),
  ITALICO             VARCHAR2(1),
  FONTSIZE            NUMBER(2),
  COLOR               VARCHAR2(6),
  TEXTDECORATION      VARCHAR2(40),
  TEXTALIGN           VARCHAR2(10),
  BORDER              VARCHAR2(1),
  BACKGROUNDCOLOR     VARCHAR2(6),
  FORMATO             varchar2(50),
constraint PK_MAPA_VISAO_COMPONENTE primary key (id) using index tablespace &CS_TBL_IND,
constraint CHK_MAPA_VISAO_COMPONENTE_01 check (Y_AUTO in ('Y','N')),
constraint CHK_MAPA_VISAO_COMPONENTE_02 check (altura_auto in ('Y','N')),
constraint CHK_MAPA_VISAO_COMPONENTE_03 check (tipo in ('T','C','L','G','V','A','R','H')),
constraint CHK_MAPA_VISAO_COMPONENTE_04 check (tipo_grafico in ('N', 'B','H','L','P','G','T','R')),
constraint CHK_MAPA_VISAO_COMPONENTE_05 check (FLAG_EXPANDIDO in ('Y','N'))
) tablespace &CS_TBL_DAT;


comment on table MAPA_VISAO_COMPONENTE
  is 'Componentes das visoes que podem ser textos, campos, listagens, graficos ou outras visoes';
comment on column MAPA_VISAO_COMPONENTE.VISAO_ID
  is 'visao a qual pertence o componente';
comment on column MAPA_VISAO_COMPONENTE.TAG_COMPONENTE
  is 'identificador da informacao dentro do objeto';
comment on column MAPA_VISAO_COMPONENTE.ORDEM
  is 'ordem de apresentacao do componente';
comment on column MAPA_VISAO_COMPONENTE.Y_AUTO
  is 'Y/N - indica que a posicao vertical e automatica, fica abaixo dos componentes de ordem anterior';
comment on column MAPA_VISAO_COMPONENTE.ALTURA_AUTO
  is 'Y/N - indica que a altura e automatica, deve comportar o conteudo';
comment on column MAPA_VISAO_COMPONENTE.TIPO
  is 'Tipo de componente: (T)exto, (C)ampo, (L)istagem, (G)rafico, (V)isao, campo (A)rea, texto a(R)ea';
comment on column MAPA_VISAO_COMPONENTE.TEXTO
  is 'Texto para componentes texto';
comment on column MAPA_VISAO_COMPONENTE.TIPO_GRAFICO
  is '(N)ao, (B)arras, Barras (H)orizontais, (L)inhas, (P)izza, (G)auge, (T)ermometro, (R)adar';
comment on column MAPA_VISAO_COMPONENTE.FLAG_EXPANDIDO
  is 'Indica se o componente deve iniciar expandido';
comment on column MAPA_VISAO_COMPONENTE.VISAO_COMPONENTE_ID
  is 'Indica qual visao deve ser usada para o componente';
comment on column MAPA_VISAO_COMPONENTE.TIPO_POS_X
  is '(P)ercentual/(F)ixo';
comment on column MAPA_VISAO_COMPONENTE.TIPO_POS_Y
  is '(P)ercentual/(F)ixo';
comment on column MAPA_VISAO_COMPONENTE.TIPO_LARGURA
  is '(P)ercentual/(F)ixo';
comment on column MAPA_VISAO_COMPONENTE.TIPO_ALTURA
  is '(P)ercentual/(F)ixo';
  
create sequence mapa_visao_componente_seq
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache;
-- MAPA_VISAO_COMPONENTE [FIM]

-- MAPA_VISAO_COMP_CAMPOS_LIST [INI]
create table MAPA_VISAO_COMP_CAMPOS_LIST (
  ID                  NUMBER(10)   not null,
  VISAO_COMPONENTE_ID NUMBER(10)   not null,
  ORDEM               NUMBER(2)    not null,
  LARGURA             NUMBER(4)    not null,
  TAG_CAMPO           VARCHAR2(80) not null,
  FORMATO_DATA        varchar2(30),
constraint PK_MAPA_VISAO_CAMPOS_LIST primary key (id) using index tablespace &CS_TBL_IND
) tablespace &CS_TBL_DAT;

comment on column MAPA_VISAO_COMP_CAMPOS_LIST.formato_data
  is 'formato para campos data';

comment on column MAPA_VISAO_COMP_CAMPOS_LIST.LARGURA
  is 'Em percentual';
comment on column MAPA_VISAO_COMP_CAMPOS_LIST.TAG_CAMPO
  is 'Identificador do campo no objeto';
comment on column MAPA_VISAO_COMPONENTE.POS_Y
  is 'Posicao Y do componente';
comment on column MAPA_VISAO_COMPONENTE.COLOR
  is 'cor da fonte da letra';
comment on column MAPA_VISAO_COMPONENTE.TEXTDECORATION
  is 'se e subinhado';
comment on column MAPA_VISAO_COMPONENTE.formato
  is 'formato usado para o componente';
  
create sequence mapa_visao_campos_list_seq
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache;
-- MAPA_VISAO_COMP_CAMPOS_LIST [FIM]

-- REGRA_CALENDARIO [INI]
create table regra_calendario (
  id                  number(10)    not null,
  calendario_id       number(10)    null,
  projeto_id          number(10)    null,
  usuario_id          varchar2(50)  null,
  titulo              varchar2(250) not null,
  descricao           varchar2(250) null,
  periodo             varchar2(1)   not null,
  tipo_periodo_n_util number(10)    null,
  carga_horaria       number(10)    null,
  frequencia          varchar2(1)   not null,
  frequencia_data     date          null,
  frequencia_numero   number(2)     null,
  freq_domingo        varchar2(1)   default 'Y' not null,
  freq_segunda        varchar2(1)   default 'Y' not null,
  freq_terca          varchar2(1)   default 'Y' not null,
  freq_quarta         varchar2(1)   default 'Y' not null,
  freq_quinta         varchar2(1)   default 'Y' not null,
  freq_sexta          varchar2(1)   default 'Y' not null,
  freq_sabado         varchar2(1)   default 'Y' not null,
  vigencia_inicial    date          not null,
  vigencia_final      date          not null,
  constraint PK_REGRA_CALENDARIA primary key (id) using index tablespace &CS_TBL_IND,
  constraint CHK_REGRA_CALENDARIO_01 check (frequencia   in ('C', 'U', 'A', 'M', 'S')),
  constraint CHK_REGRA_CALENDARIO_02 check (frequencia_numero between 1 and 32),
  constraint CHK_REGRA_CALENDARIO_03 check (periodo      in ('U', 'N')),
  constraint CHK_REGRA_CALENDARIO_04 check (freq_domingo in ('Y', 'N')),
  constraint CHK_REGRA_CALENDARIO_05 check (freq_segunda in ('Y', 'N')),   
  constraint CHK_REGRA_CALENDARIO_06 check (freq_terca   in ('Y', 'N')), 
  constraint CHK_REGRA_CALENDARIO_07 check (freq_quarta  in ('Y', 'N')),
  constraint CHK_REGRA_CALENDARIO_08 check (freq_quinta  in ('Y', 'N')), 
  constraint CHK_REGRA_CALENDARIO_09 check (freq_sexta   in ('Y', 'N')), 
  constraint CHK_REGRA_CALENDARIO_10 check (freq_sabado  in ('Y', 'N'))   
) tablespace &CS_TBL_DAT;

create index IDX_REGRA_CALENDARIO_01
       on regra_calendario (calendario_id) tablespace &CS_TBL_IND;
create index IDX_REGRA_CALENDARIO_02
       on regra_calendario (projeto_id) tablespace &CS_TBL_IND;
create index IDX_REGRA_CALENDARIO_03
       on regra_calendario (usuario_id) tablespace &CS_TBL_IND;
create index IDX_REGRA_CALENDARIO_04
       on regra_calendario (tipo_periodo_n_util) tablespace &CS_TBL_IND;
create index IDX_REGRA_CALENDARIO_05
       on regra_calendario (projeto_id,usuario_id) tablespace &CS_TBL_IND;
create index IDX_REGRA_CALENDARIO_06
       on regra_calendario(vigencia_inicial) tablespace &CS_TBL_IND;
create index IDX_REGRA_CALENDARIO_07
       on regra_calendario(vigencia_final) tablespace &CS_TBL_IND;   
       
create sequence regra_calendario_seq
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache; 
       
comment on table regra_calendario
        is 'Tabela com as regras relacionadas a um calendário';    
comment on column regra_calendario.id
        is 'Identificador único (PK)';
comment on column regra_calendario.calendario_id
        is 'Calendário ao qual estão amarradas as regras';      
comment on column regra_calendario.projeto_id
        is 'Projeto do recurso ao qual estão amarradas as regras';  
comment on column regra_calendario.usuario_id
        is 'Usuário/Recurso ao qual estão amarradas as regras';
comment on column regra_calendario.descricao
        is 'Descrição da regra';        
comment on column regra_calendario.tipo_periodo_n_util
        is 'Tipo de período não útil associado a regra'; 
comment on column regra_calendario.periodo
        is 'Tipo de período que a regra define (Ú)til ou (N)ão útil';        
comment on column regra_calendario.carga_horaria
        is 'Carga horária associada a regra'; 
comment on column regra_calendario.frequencia
        is 'Freqüência de repetição da regra: (Ú)nica, (A)nual, (M)ensal, (S)emanal ou (C)arga horária'; 
comment on column regra_calendario.frequencia_data
        is 'Dia e mês relacionado a uma regra anual';
comment on column regra_calendario.frequencia_numero
        is 'Dia relacionado a uma regra mensal. O dia 32 indica último dia do mês';  
comment on column regra_calendario.freq_domingo
        is 'Indicador se a regra é aplicada se o dia for um domingo';
comment on column regra_calendario.freq_segunda
        is 'Indicador se a regra é aplicada se o dia for uma segunda';        
comment on column regra_calendario.freq_terca
        is 'Indicador se a regra é aplicada se o dia for uma terca'; 
comment on column regra_calendario.freq_quarta
        is 'Indicador se a regra é aplicada se o dia for uma quarta'; 
comment on column regra_calendario.freq_quinta
        is 'Indicador se a regra é aplicada se o dia for uma quinta'; 
comment on column regra_calendario.freq_sexta
        is 'Indicador se a regra é aplicada se o dia for uma sexta'; 
comment on column regra_calendario.freq_sabado
        is 'Indicador se a regra é aplicada se o dia for um sabado'; 
comment on column regra_calendario.vigencia_inicial
        is 'Data de início da vigência da regra'; 
comment on column regra_calendario.vigencia_final
        is 'Data de fim da vigência da regra'; 
-- REGRA_CALENDARIO [FIM]

-- TIPO_PERIODO_NAO_UTIL [INI]
create table tipo_periodo_nao_util (
  id        number(10)    not null,
  descricao varchar2(250) not null,
  vigente   varchar2(1)   not null,
  constraint PK_TIPO_PERIODO_NAO_UTIL primary key (id) using index tablespace &CS_TBL_IND,
  constraint CHK_TIPO_PERIODO_NAO_UTIL_01 check (vigente in ('Y', 'N'))
) tablespace &CS_TBL_IND;

create sequence tipo_periodo_nao_util_seq
       increment by 1      start with 1
       maxvalue 9999999999 minvalue 1 nocache; 
       
comment on table tipo_periodo_nao_util
        is 'Cadastro de tipos de dias não úteis que será utilizado na transação de calendário';
comment on column tipo_periodo_nao_util.id
        is 'Id do tipo de dia não útil (PK)';
comment on column tipo_periodo_nao_util.descricao
        is 'Descrição do tipo de dia não útil';
comment on column tipo_periodo_nao_util.descricao
        is 'Determina a vigência do tipo de dia não útil';
-- TIPO_PERIODO_NAO_UTIL [FIM]

----------------------------------------------------------------------------------------------------
--
-- Criação de relacionamentos (constraints FK)
--
----------------------------------------------------------------------------------------------------
  
-- BASELINE_CUSTO_ENTIDADE
alter table baseline_custo_entidade drop constraint FK_BASELINE_CUSTO_ENTIDADE_06;
alter table baseline_custo_entidade add constraint FK_BASELINE_CUSTO_ENTIDADE_06
  foreign key (custo_entidade_id) references custo_entidade(id) on delete set null;
-- BASELINE_CUSTO_LANCAMENTO
alter table baseline_custo_lancamento drop constraint FK_BASELINE_CUSTO_LANC_04;
alter table baseline_custo_lancamento add constraint FK_BASELINE_CUSTO_LANC_04
  foreign key (custo_lancamento_id) references custo_lancamento(id) on delete set null;
-- CALENDARIO
alter table calendario add constraint FK_CALENDARIO_01
  foreign key (pai_id) references calendario (id);
alter table calendario add constraint FK_CALENDARIO_02
  foreign key (projeto_id) references projeto (id) on delete cascade;
-- CONHEC_USUARIO_AVAL
alter table conhec_usuario_aval add constraint FK_CONHEC_USUARIO_AVAL_01
  foreign key (usuario_id) references usuario (usuarioid);
alter table conhec_usuario_aval add constraint FK_CONHEC_USUARIO_AVAL_02
  foreign key (usuario_avaliador_id) references usuario (usuarioid);
alter table conhec_usuario_aval add constraint FK_CONHEC_USUARIO_AVAL_03
  foreign key (usuario_aprovador_id) references usuario (usuarioid);
alter table conhec_usuario_aval add constraint FK_CONHEC_USUARIO_AVAL_04
  foreign key (conhecimento_id) references conhecimento_profissional (id);  
alter table conhec_usuario_aval add constraint FK_CONHEC_USUARIO_AVAL_05
  foreign key (projeto_id) references projeto (id);
alter table conhec_usuario_aval add constraint FK_CONHEC_USUARIO_AVAL_06
  foreign key (nivel_id) references nivelconhecimento (nivelid);
-- CONHECIMENTO_USUARIO
alter table conhecimento_usuario add constraint FK_CONHECIMENTO_USUARIO_01
  foreign key (conhecimento_id) references conhecimento_profissional (id);
-- CONHECIMENTO_PROFISSIONAL
alter table conhecimento_profissional add constraint FK_CONHECIMENTO_PROF_01
  foreign key (id_pai) references conhecimento_profissional (id) on delete cascade;
alter table conhecimento_profissional add constraint FK_CONHECIMENTO_PROF_02
  foreign key (nivel_default) references nivelconhecimento (nivelid);
-- DIAGRAMA_REDE_VISAO
alter table diagrama_rede_visao add constraint FK_DIAGRAMA_REDE_VISAO_01
  foreign key (projeto_id) references projeto(id);
alter table diagrama_rede_visao add constraint FK_DIAGRAMA_REDE_VISAO_02
  foreign key (usuario_criacao_id) references usuario(usuarioid);
alter table diagrama_rede_visao add constraint FK_DIAGRAMA_REDE_VISAO_03
  foreign key (usuario_atualizacao_id) references usuario(usuarioid);
-- DIAGRAMA_VISAO_NODOS
alter table diagrama_visao_nodos add constraint FK_DIAGRAMA_VISAO_NODOS_01
  foreign key (visao_id) references diagrama_rede_visao(id);
alter table diagrama_visao_nodos add constraint FK_DIAGRAMA_VISAO_NODOS_02
  foreign key (visao_nodo_id) references diagrama_nodo_entidade(id);
alter table diagrama_visao_nodos add constraint FK_DIAGRAMA_VISAO_NODOS_03
  foreign key (usuario_criacao_id) references usuario(usuarioid);
alter table diagrama_visao_nodos add constraint FK_DIAGRAMA_VISAO_NODOS_04
  foreign key (usuario_atualizacao_id) references usuario(usuarioid);
-- DIAGRAMA_VISAO_PROJETO_PADRAO
alter table diagrama_visao_projeto_padrao add constraint FK_DIAGRAMA_VISAO_PP_01
  foreign key (visao_id) references diagrama_rede_visao(id);
alter table diagrama_visao_projeto_padrao add constraint FK_DIAGRAMA_VISAO_PP_02
  foreign key (projeto_id) references projeto(id);
alter table diagrama_visao_projeto_padrao add constraint FK_DIAGRAMA_VISAO_PP_03
  foreign key (usuario_id) references usuario(usuarioid);  
-- H_USUARIO
alter table h_usuario add constraint FK_H_USUARIO_05
  foreign key (gerente_recurso) references usuario (usuarioid);
alter table h_usuario add constraint FK_H_USUARIO_06
  foreign key (calendario_base_id) references calendario (id);
alter table h_usuario add constraint FK_H_USUARIO_07
  foreign key (modificador) references usuario(usuarioid);
-- FORMULARIO_FLUXO_DESENHO
alter table formulario_fluxo_desenho add constraint FK_FORMULARIO_FLUXO_DESENHO_01 
  foreign key (formulario_id) references formulario(formulario_id); 
-- HORA_ALOCADA
alter table hora_alocada add constraint fk_hora_alocada_01
  foreign key (tarefa_id) references tarefa(id) on delete cascade;
-- MAPA_ESTRATEGICO
alter table mapa_estrategico add constraint FK_MAPA_ESTRATEGICO_01
  foreign key (criador) references usuario(usuarioid);
-- MAPA_INDICADOR
alter table mapa_indicador drop constraint FK_MAPA_INDICADOR_09;  
alter table mapa_indicador add constraint FK_MAPA_INDICADOR_09
  foreign key (objetivo_pai) references mapa_objetivo(id) on delete cascade;
-- MAPA_OBJETIVO
alter table mapa_objetivo add constraint FK_MAPA_OBJETIVO_04
  foreign key (perspectiva_id) references mapa_perspectiva(id) on delete cascade;
alter table mapa_objetivo drop constraint FK_MAPA_OBJETIVO_01;
alter table mapa_objetivo add constraint FK_MAPA_OBJETIVO_01
  foreign key (objetivo_pai) references mapa_objetivo(id) on delete cascade;
-- MAPA_OBJETIVO_PL_ACAO
alter table mapa_objetivo_pl_acao add constraint FK_MAPA_OBJETIVO_PL_ACAO_01
  foreign key (responsavel_id) references usuario(usuarioid);
alter table mapa_objetivo_pl_acao add constraint FK_MAPA_OBJETIVO_PL_ACAO_02
  foreign key (usuario_criacao_id) references usuario(usuarioid);
alter table mapa_objetivo_pl_acao add constraint FK_MAPA_OBJETIVO_PL_ACAO_03
  foreign key (usuario_atualizacao_id) references usuario(usuarioid);
alter table mapa_objetivo_pl_acao add constraint FK_MAPA_OBJETIVO_PL_ACAO_04
  foreign key (objetivo_id) references mapa_objetivo(id) on delete cascade;
-- MAPA_OBJETIVO_PL_ACAO_INIC
alter table mapa_objetivo_pl_acao_inic add constraint FK_MAPA_OBJETIVO_INIC_01
  foreign key (usuario_criacao_id) references usuario(usuarioid);
alter table mapa_objetivo_pl_acao_inic add constraint FK_MAPA_OBJETIVO_INIC_02
  foreign key (usuario_atualizacao_id) references usuario(usuarioid);
alter table mapa_objetivo_pl_acao_inic add constraint FK_MAPA_OBJETIVO_INIC_03
  foreign key (pl_acao_id) references mapa_objetivo_pl_acao(id) on delete cascade;
-- MAPA_PERSPECTIVA
alter table mapa_perspectiva add constraint FK_MAPA_PERSPECTIVA_01
  foreign key (mapa_id) references mapa_estrategico(id) ;
-- MAPA_RELACAO
alter table mapa_relacao add constraint FK_MAPA_RELACAO_01
  foreign key (mapa_id) references mapa_estrategico(id) ;
-- MAPA_VISAO_COMPONENTE
alter table MAPA_VISAO_COMPONENTE add constraint FK_MAPA_VISAO_COMPONENTE_01 
  foreign key (VISAO_ID) references MAPA_VISAO (ID);
alter table MAPA_VISAO_COMPONENTE add constraint FK_MAPA_VISAO_COMPONENTE_02 
  foreign key (VISAO_COMPONENTE_ID) references MAPA_VISAO (ID);
-- MAPA_VISAO_COMP_CAMPOS_LIST
alter table MAPA_VISAO_COMP_CAMPOS_LIST  add constraint FK_MAPA_VISAO_CAMPOS_LIST_01 
  foreign key (VISAO_COMPONENTE_ID) references MAPA_VISAO_COMPONENTE (ID);
-- PAPELPROJETORECURSO
alter table papelprojetorecurso add constraint FK_PAPELPROJETORECURSO_01
 foreign key (projetoid) references PROJETO (id) on delete cascade;
-- PROJETO
alter table projeto add constraint FK_PROJETO_08
  foreign key (calendario_base_id) references calendario(id);
-- REGRA_CALENDARIO
alter table regra_calendario add constraint FK_REGRA_CALENDARIO_01
  foreign key (calendario_id) references calendario (id) on delete cascade;
alter table regra_calendario add constraint FK_REGRA_CALENDARIO_02
  foreign key (projeto_id) references projeto (id) on delete cascade;
alter table regra_calendario add constraint FK_REGRA_CALENDARIO_03
  foreign key (usuario_id) references usuario (usuarioid);
alter table regra_calendario add constraint FK_REGRA_CALENDARIO_04
  foreign key (tipo_periodo_n_util) references tipo_periodo_nao_util (id);
-- TAREFA
alter table tarefa add constraint FK_TAREFA_03
  foreign key (papelprojeto_id) references papelprojeto (papelprojetoid);
-- USUARIO
alter table usuario add constraint FK_USUARIO_05
  foreign key (gerente_recurso) references usuario (usuarioid);
alter table usuario add constraint FK_USUARIO_06
  foreign key (calendario_base_id) references calendario (id);
alter table usuario add constraint FK_USUARIO_07
  foreign key (modificador) references usuario(usuarioid);
