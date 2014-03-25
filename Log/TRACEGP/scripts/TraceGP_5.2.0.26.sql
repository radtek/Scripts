/******************************************************************************\
* TraceGP 5.2.0.26                                                             *
\******************************************************************************/

insert into permissao_item(permissao_item_id, permissao_categoria_id, titulo, codigo, 
                           tipo_permissao, mostrar_acesso_total, mostrar_somente_leitura)
       values (101 ,3, 'permissao.relacionamento.solicitacao.interessados', 
               'R_DEM_INTERESSADOS', 'R', 'S', 'N');
commit;
/

-------------------------------------------------------------------------------
-- Finalização
-------------------------------------------------------------------------------

insert into versao(id, titulo, patch, versao_tgp_id, comentario)
       values (versao_seq.nextval, '5.2.0', '26', 2, 'Aplicação de patch');
commit;
/
                    
select * from v_versao;
/
