/*****************************************************************************\ 
 * TraceGP 5.2.0.40                                                          *
\*****************************************************************************/

declare
  ln_conta number;
begin
  select count(1)
    into ln_conta
    from permissao_item
   where codigo = 'R_DEM_INTERESSADOS';
   
  if ln_conta = 0 then
    insert into permissao_item (permissao_item_id, titulo, codigo, permissao_categoria_id, 
                                tipo_permissao, mostrar_acesso_total, mostrar_somente_leitura)
         values ( (select max(permissao_item_id)+1 from permissao_item), 
                'permissao.relacionamento.solicitacao.interessados', 'R_DEM_INTERESSADOS', 3, 'R', 'S', 'N');
  end if;
  commit;
end;
/

-------------------------------------------------------------------------------
-- Finalização
-------------------------------------------------------------------------------

insert into versao(id, titulo, patch, versao_tgp_id, comentario)
       values (versao_seq.nextval, '5.2.0', '40', 2, 'Aplicação de patch');
commit;
/
                    
select * from v_versao;
/
