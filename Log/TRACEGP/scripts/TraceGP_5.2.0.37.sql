/*****************************************************************************\ 
 * TraceGP 5.2.0.37                                                          *
\*****************************************************************************/

alter table PADRAOHORARIO add FECHAR_PONTO_FINAL_DIA VARCHAR2(1);

update PADRAOHORARIO 
   set FECHAR_PONTO_FINAL_DIA = 'S';
commit;
/

alter table CONFIGURACOES add PERMITSOLICAJUSTEPONTO VARCHAR2(1) DEFAULT 'H';

-------------------------------------------------------------------------------
-- Finalização
-------------------------------------------------------------------------------

insert into versao(id, titulo, patch, versao_tgp_id, comentario)
       values (versao_seq.nextval, '5.2.0', '37', 2, 'Aplicação de patch');
commit;
/

begin
  pck_processo.precompila;
  commit;
end;
/
                      
select * from v_versao;
/
