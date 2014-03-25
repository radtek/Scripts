/******************************************************************************\
* TraceGP 5.2.0.23                                                             *
\******************************************************************************/

alter table baseline modify titulo varchar2(4000);
alter table baseline modify descricao varchar2(4000);

-------------------------------------------------------------------------------
-- Finalização
-------------------------------------------------------------------------------

insert into versao(id, titulo, patch, versao_tgp_id, comentario)
       values (versao_seq.nextval, '5.2.0', '23', 2, 'Aplicação de Patch');
commit;
/

begin
  pck_processo.precompila;
  commit;
end;
/
                      
select * from v_versao;
/
