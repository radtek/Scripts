/******************************************************************************\
* TraceGP 5.2.0.29                                                             *
\******************************************************************************/

CREATE OR REPLACE FORCE VIEW V_EVOLUCAO_HISTORICA AS
  SELECT x.id PROJETO_ID,
    x.data,
    SUM(NVL(minutos_ate_data,0)) PREVISTO,
    SUM(NVL(minutos_totais,0)) PREVISTO_TOTAL,
    SUM(NVL(x.minutos_realizados,0)) REALIZADO,
    CASE
      WHEN SUM(NVL(minutos_totais,0)) > 0
      THEN (SUM(NVL(minutos_ate_data,0)) / SUM(NVL(minutos_totais,0))) * 100
      ELSE 0
    END PERCENTUAL_PREVISTO,
    MAX(NVL(x.percentual_concluido,0)) PERCENTUAL_CONCLUIDO
  FROM
    (
    -- PLANEJADO
    SELECT p.id ID,
      vdf.dia data,
      CASE
        WHEN vdf.dia >= t.datainicio
        THEN (least(vdf.dia, t.prazoprevisto) - t.datainicio) + 1
        ELSE 0      
      END * (CASE WHEN ((t.prazoprevisto - t.datainicio)+1) > 0 THEN (t.horasprevistas / ((t.prazoprevisto - t.datainicio)+1)) ELSE 0 END)  MINUTOS_ATE_DATA,
      t.horasprevistas MINUTOS_TOTAIS,
      to_number('0', '0.')MINUTOS_REALIZADOS,
      to_number('0', '0.00') PERCENTUAL_CONCLUIDO
    FROM v_dias_futuro vdf,
      tarefa t,
      projeto p
    WHERE vdf.dia BETWEEN least(NVL(p.iniciorealizado, to_date('31129999', 'ddmmyyyy')), NVL(p.datainicio, to_date('31129999', 'ddmmyyyy'))) AND greatest(NVL(p.prazorealizado, to_date('01011900', 'ddmmyyyy')), NVL(p.prazoprevisto, to_date('01011900', 'ddmmyyyy')))
    AND t.projeto = p.id
    UNION ALL
    -- REALIZADO
    SELECT p.id,
      vdf.dia,
      0,
      0,
      ht.minutos,
      0.00
    FROM v_dias_futuro vdf,
      horatrabalhada ht,
      tarefa t,
      projeto p
    WHERE vdf.dia BETWEEN least(NVL(p.iniciorealizado, to_date('31129999', 'ddmmyyyy')), NVL(p.datainicio, to_date('31129999', 'ddmmyyyy'))) AND greatest(NVL(p.prazorealizado, to_date('01011900', 'ddmmyyyy')), NVL(p.prazoprevisto, to_date('01011900', 'ddmmyyyy')))
    AND ht.datatrabalho <= vdf.dia
    AND ht.tarefa        = t.id
    AND t.projeto        = p.id
    UNION ALL
    -- PERCENTUAL_CONCLUÍDO
    SELECT p.id,
      vdf.dia,
      0,
      0,
      0,
      pc.perc_concluido
    FROM percentual_concluido pc,
      v_dias_futuro vdf,
      projeto p
    WHERE vdf.dia BETWEEN least(NVL(p.iniciorealizado, to_date('31129999', 'ddmmyyyy')), NVL(p.datainicio, to_date('31129999', 'ddmmyyyy'))) AND greatest(NVL(p.prazorealizado, to_date('01011900', 'ddmmyyyy')), NVL(p.prazoprevisto, to_date('01011900', 'ddmmyyyy')))
    AND pc.data =
      (SELECT MAX(pc2.data)
      FROM percentual_concluido pc2
      WHERE pc2.tipo_entidade = pc.tipo_entidade
      AND pc2.entidade_id     = pc.entidade_id
      AND pc2.data           <= vdf.dia
      )
    AND pc.tipo_entidade = 'P'
    AND pc.entidade_id   = p.id
    ) x
  GROUP BY x.id,
    x.data ;
/


-------------------------------------------------------------------------------
-- Finalização
-------------------------------------------------------------------------------
insert into versao(id, titulo, patch, versao_tgp_id, comentario)
       values (versao_seq.nextval, '5.2.0', '29', 2, 'Aplicação de patch');
commit;
/
                    
select * from v_versao;
/
      
       



