/******************************************************************************\
* Roteiro para migra��o � vers�o de calend�rio (5.3.0.0)                       *
* Parte IV - Ajustes finais em Objetos                                         *
* Autor: Charles Falc�o                     Data de Publica��o:   /   /2009    *
\******************************************************************************/

--------------------------------------------------------------------------------
--
-- Define nome dos tablespaces.
--
--------------------------------------------------------------------------------
--define CS_TBL_DAT = &TABLESPACE_DADOS;
define CS_TBL_IND = &TABLESPACE_INDICES;
--define CS_TBL_DOC = &TABLESPACE_DOCUMENTOS;

-- Cria PK para conhecimento_usuario

alter table conhecimento_usuario drop constraint PK_CONHECIMENTO_USUARIO;
drop index PK_CONHECIMENTO_USUARIO;

alter table conhecimento_usuario add constraint PK_CONHECIMENTO_USUARIO
  primary key (id) using index tablespace &CS_TBL_IND;
  
-- 
ALTER TABLE DEPENDENCIAATIVIDADETAREFA MODIFY (PROJETO_PREDECESSORA NOT NULL);
  



