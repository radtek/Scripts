
break on report

col T_Oracle for 999990.00
col AVG_IT_SEC for 999990.00
col AVG_SEC_IT for 999990.00

compute avg of T_Oracle on report
compute avg of AVG_IT_SEC on report
compute avg of AVG_SEC_IT on report


select /*+ ordered */
              pv.codigo_do_cliente Cliente
             ,pv.dthr_receb_pedido_eletronico DataRec
             ,pv.dthr_de_cadastramento DataE_Oracle
             ,pv.dthr_final_do_pedido DataS_Oracle
             ,(pv.dthr_de_cadastramento - pv.dthr_receb_pedido_eletronico) * 86400 T_Fila
             ,(pv.dthr_final_do_pedido - pv.dthr_de_cadastramento) * 86400 T_Oracle
             ,pv.identificador_do_arquivo_edi IdentEDI
	     ,((pv.dthr_final_do_pedido - pv.dthr_de_cadastramento) * 86400) / NVL(NULLIF(count(ie.codigo_do_item),0),1) as AVG_SEC_IT
	     ,count(ie.codigo_do_item) / NVL(NULLIF(((pv.dthr_final_do_pedido - pv.dthr_de_cadastramento) * 86400),0),1) as AVG_IT_SEC
             ,count(ie.codigo_do_item) QtdItens
             ,pa.nome_do_programa OL
         from pedidos_de_venda pv
             ,itens_dos_pedidos_de_venda ie
             ,pro_programas_administradoras pa
        where pv.dthr_de_cadastramento >= to_date('2610141000','ddmmyyhh24miss')
          and pv.dthr_receb_pedido_eletronico is not null
          --and pv.codigo_do_cliente+0 > 1000
         -- and pv.identificador_do_arquivo_edi in (154107492148601)
        --  and pv.usuario_de_cadastramento = 'CARGAEDI'
          and nvl(pv.pedido_em_processamento,'N') = 'N'
          and pv.tipo_de_pedido||''='EDI'
          and ie.filial_do_pedido_de_venda=pv.filial_do_pedido_de_venda
          and ie.codigo_do_pedido_de_venda=pv.codigo_do_pedido_de_venda
          and pa.codigo_admin_convenios(+)=pv.codigo_admin_convenios
          and pa.sequencia_do_programa(+)=pv.sequencia_do_programa
      group by pv.codigo_do_cliente
              ,pv.dthr_de_cadastramento
              ,pv.dthr_final_do_pedido
              ,pv.dthr_receb_pedido_eletronico
              ,pv.dthr_de_cadastramento-pv.dthr_receb_pedido_eletronico
              ,pv.identificador_do_arquivo_edi
              ,pa.nome_do_programa
order by pv.identificador_do_arquivo_edi,pv.dthr_de_cadastramento
/
