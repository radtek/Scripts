/*****************************************************************************\ 
 * TraceGP 6.0.1.5                                                           *
\*****************************************************************************/
--define CS_TBL_DAT = &TABLESPACE_DADOS;
--define CS_TBL_IND = &TABLESPACE_INDICES;
-------------------------------------------------------------------------------

CREATE OR REPLACE FORCE VIEW V_USUARIOS_RECURSO  (ID, USUARIO_ID_DEP, USUARIO_ID) AS
  SELECT rownum id, SUBSTR(path, 2, instr(SUBSTR(path, 2), ';')-1) USUARIO_ID_DEP, USUARIO_ID
  FROM
    (SELECT sys_connect_by_path(u.usuarioid, ';') path,
      u.usuarioid USUARIO_ID
    FROM usuario u
      CONNECT BY nocycle u.usuarioid =  prior u.gerente_recurso
    )
  WHERE  path is not null ;

-------------------------------------------------------------------------------
-- Finalização
-------------------------------------------------------------------------------
  
insert into versao(id, titulo, patch, versao_tgp_id, comentario)
       values (versao_seq.nextval, '6.0.1', '6', 4, 'Aplicação de patch');
commit;
/

begin
  pck_processo.precompila;
  commit;
end;
/
                    
select * from v_versao;
/


  
