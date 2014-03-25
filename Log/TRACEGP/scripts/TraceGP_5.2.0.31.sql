/******************************************************************************\
* TraceGP 5.2.0.31                                                             *
\******************************************************************************/

ALTER TABLE OCORRENCIA MODIFY (DESCRICAO VARCHAR2(4000 BYTE));

-------------------------------------------------------------------------------
-- Finaliza��o
-------------------------------------------------------------------------------

insert into versao(id, titulo, patch, versao_tgp_id, comentario)
       values (versao_seq.nextval, '5.2.0', '31', 2, 'Aplica��o de patch');
commit;
/

begin
  pck_processo.precompila;
  commit;
end;
/
                      
select * from v_versao;
/
