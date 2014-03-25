FATCOB
sqlid:49dfkq8p1arrp

create table tmp_mara_repfatpag_20131216 as

select distinct cont.nr_idperm||'#perm!terra' as ID_PARAM
, t.dt_pagamento
, paco.nm_pacote_comercial as NM_PACOTE_COMERCIAL
, vapac.vl_monetario as vl_monetario_pac
, vapas.vl_monetario as vl_monetario_pacserv
, b.vl_bilhete
, serv.cd_servico || ' - ' || pc.nr_produto as CATEGORIA
, tico.cd_tipo_cobranca
, t.vl_titulo VALOR_TITULO
, t.vl_valorpago VALOR_PAGO_TITULO
from trr_pacote_comercial@oradb1 paco -- 5.6594
	, trr_contrato_servico@oradb1 cose -- 73.635.440
	, trr_conta@oradb1 cont -- 57.080.800
	, trr_valor_pacote_comercial@oradb1 vapac -- 144.215
	, trr_valor_pacote_servico@oradb1 vapas -- 1.024.025
	, trr_pacotecomerc_servico@oradb1 pase -- 435.393
	, trr_linhanegocio_servico@oradb1 lise -- 634
	, trr_servico@oradb1 serv -- 142
	, trr_valor_contrato_servico@oradb1 vacos -- 81.855.475
	, trr_tipo_cobranca@oradb1 tico -- 40
	, trr_classe_pacote@oradb1 clpa -- 24.093
	, trr_titulo t -- 72M filtrado
	, trr_bilhete b -- 378 M
	, trr_produtocomercial pc -- 180
where paco.id_linha_negocio = 6
and paco.id_pacote_comercial = cose.id_pacote_comercial
and cose.id_conta = cont.id_conta
and pase.id_pacote_comercial = paco.id_pacote_comercial
and cont.id_namespace = 1
and pase.tp_conta_recebe_servico = 'D'
and vacos.id_contrato_servico = cose.id_contrato_servico
and vacos.id_valor_pacote_comercial = vapac.id_valor_pacote_comercial
and vapac.id_pacote_comercial = paco.id_pacote_comercial
and vapas.id_valor_pacote_comercial = vapac.id_valor_pacote_comercial
and vapas.id_pacotecomerc_servico = pase.id_pacotecomerc_servico
and lise.id_linhanegocio_servico = pase.id_linhanegocio_servico
and lise.id_linha_negocio = 6
and lise.id_servico = serv.id_servico
and serv.cd_servico = 'NAP' --/*= 'NAP'--*/in ('MUS', 'MUP', 'MUC', 'MUO')--, 'MUA')
and paco.id_classe_pacote = clpa.id_classe_pacote
and clpa.id_tipo_cobranca = tico.id_tipo_cobranca
and vacos.dt_fim is null
and cose.id_contrato_servico = b.id_contrato_servico
and b.id_titulo = t.id_titulo
and t.dt_pagamento between to_date('16/11/2013 00:00:00', 'dd/mm/yyyy hh24:mi:ss') and to_date('15/12/2013 23:59:59', 'dd/mm/yyyy hh24:mi:ss')
and t.dt_emissao >= to_date('01/01/2010', 'dd/mm/yyyy')
and b.id_produtocomercial = pc.id_produtocomercial
and pc.nr_produto in ('NAS', 'NAD') --('MUS', 'MUC', 'MUP', 'S10', 'S25', 'SFA', 'C10', 'C25', 'CFA')
and t.id_contrato = b.id_contrato


PLAN_TABLE_OUTPUT
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID  49dfkq8p1arrp, child number 0
-------------------------------------
create table tmp_mara_repfatpag_20131216 as select distinct cont.nr_idperm||'#perm!terra' as ID_PARAM , t.dt_pagamento , paco.nm_pacote_comercial as NM_PACOTE_COMERCIAL
, vapac.vl_monetario as vl_monetario_pac , vapas.vl_monetario as vl_monetario_pacserv , b.vl_bilhete , serv.cd_servico || ' - ' || pc.nr_produto as CATEGORIA ,
tico.cd_tipo_cobranca , t.vl_titulo VALOR_TITULO , t.vl_valorpago VALOR_PAGO_TITULO from trr_pacote_comercial@oradb1 paco , trr_contrato_servico@oradb1 cose ,
trr_conta@oradb1 cont -- , trr_alias ali -- , tmp_mara_pc_sonora_trrbr_v2@oradb1 tmp , trr_valor_pacote_comercial@oradb1 vapac , trr_valor_pacote_servico@oradb1 vapas ,
trr_pacotecomerc_servico@oradb1 pase , trr_linhanegocio_servico@oradb1 lise , trr_servico@oradb1 serv , trr_valor_contrato_servico@oradb1 vacos ,
trr_tipo_cobranca@oradb1 tico , trr_classe_pacote@oradb1 clpa , trr_titulo t , trr_bilhete b , trr_produtocomercial pc where paco.id_linha_negocio = 6 and
paco.id_pacote_comercial = cose.id_pacote_

Plan hash value: 1984402872

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                               | Name                       | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop | Inst   |IN-OUT|  OMem |  1Mem | Used-Mem |
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
|   1 |  LOAD AS SELECT                         |                            |        |       |            |          |       |       |        |      |   256K|   256K|          |
|   2 |   HASH UNIQUE                           |                            |      1 |   450 |  1722   (1)| 00:00:19 |       |       |        |      |  1041K|  1041K|          |
|   3 |    NESTED LOOPS                         |                            |      1 |   450 |  1721   (1)| 00:00:19 |       |       |        |      |       |       |          |
|   4 |     NESTED LOOPS                        |                            |      1 |   417 |  1720   (1)| 00:00:19 |       |       |        |      |       |       |          |
|   5 |      NESTED LOOPS                       |                            |      1 |   408 |  1719   (1)| 00:00:19 |       |       |        |      |       |       |          |
|   6 |       NESTED LOOPS                      |                            |      1 |   383 |  1701   (1)| 00:00:19 |       |       |        |      |       |       |          |
|   7 |        NESTED LOOPS                     |                            |      1 |   363 |  1700   (1)| 00:00:19 |       |       |        |      |       |       |          |
|   8 |         NESTED LOOPS                    |                            |      1 |   337 |  1699   (1)| 00:00:19 |       |       |        |      |       |       |          |
|   9 |          NESTED LOOPS                   |                            |      1 |   320 |  1698   (1)| 00:00:19 |       |       |        |      |       |       |          |
|  10 |           NESTED LOOPS                  |                            |      1 |   295 |  1697   (1)| 00:00:19 |       |       |        |      |       |       |          |
|  11 |            NESTED LOOPS                 |                            |      1 |   256 |  1696   (1)| 00:00:19 |       |       |        |      |       |       |          |
|  12 |             NESTED LOOPS                |                            |      1 |   165 |  1695   (1)| 00:00:19 |       |       |        |      |       |       |          |
|  13 |              NESTED LOOPS               |                            |   4438 |   593K|   383   (6)| 00:00:05 |       |       |        |      |       |       |          |
|  14 |               NESTED LOOPS              |                            |   1109 |   106K|    35  (18)| 00:00:01 |       |       |        |      |       |       |          |
|  15 |                REMOTE                   |                            |      1 |    20 |     1   (0)| 00:00:01 |       |       | ORADB1 | R->S |       |       |          |
|  16 |                REMOTE                   | TRR_CONTA                  |   1109 | 43251 |    27   (0)| 00:00:01 |       |       | ORADB1 | R->S |       |       |          |
|  17 |               REMOTE                    | TRR_CONTRATO_SERVICO       |      4 |   156 |     1   (0)| 00:00:01 |       |       | ORADB1 | R->S |       |       |          |
|  18 |              REMOTE                     | TRR_VALOR_CONTRATO_SERVICO |      1 |    28 |     1   (0)| 00:00:01 |       |       | ORADB1 | R->S |       |       |          |
|  19 |             REMOTE                      | TRR_PACOTE_COMERCIAL       |      1 |    91 |     1   (0)| 00:00:01 |       |       | ORADB1 | R->S |       |       |          |
|  20 |            REMOTE                       | TRR_VALOR_PACOTE_COMERCIAL |      1 |    39 |     1   (0)| 00:00:01 |       |       | ORADB1 | R->S |       |       |          |
|  21 |           REMOTE                        | TRR_PACOTECOMERC_SERVICO   |      1 |    25 |     1   (0)| 00:00:01 |       |       | ORADB1 | R->S |       |       |          |
|  22 |          REMOTE                         | TRR_VALOR_PACOTE_SERVICO   |      1 |    17 |     1   (0)| 00:00:01 |       |       | ORADB1 | R->S |       |       |          |
|  23 |         REMOTE                          | TRR_CLASSE_PACOTE          |      1 |    26 |     1   (0)| 00:00:01 |       |       | ORADB1 | R->S |       |       |          |
|  24 |        REMOTE                           | TRR_TIPO_COBRANCA          |      1 |    20 |     1   (0)| 00:00:01 |       |       | ORADB1 | R->S |       |       |          |
|  25 |       TABLE ACCESS BY GLOBAL INDEX ROWID| TRR_BILHETE                |      5 |   125 |    18   (0)| 00:00:01 | ROW L | ROW L |        |      |       |       |          |
|* 26 |        INDEX RANGE SCAN                 | IDX_ID_CONTRATO_SERVICO    |     80 |       |     1   (0)| 00:00:01 |       |       |        |      |       |       |          |
|* 27 |      TABLE ACCESS BY INDEX ROWID        | TRR_PRODUTOCOMERCIAL       |      1 |     9 |     1   (0)| 00:00:01 |       |       |        |      |       |       |          |
|* 28 |       INDEX UNIQUE SCAN                 | PK_PRODUTOCOMERCIAL_I      |      1 |       |     1   (0)| 00:00:01 |       |       |        |      |       |       |          |
|* 29 |     TABLE ACCESS BY GLOBAL INDEX ROWID  | TRR_TITULO                 |      1 |    33 |     1   (0)| 00:00:01 | ROW L | ROW L |        |      |       |       |          |
|* 30 |      INDEX UNIQUE SCAN                  | PK_TRR_TITULO              |      1 |       |     1   (0)| 00:00:01 |       |       |        |      |       |       |          |
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
  15 - SEL$1 / SERV@SEL$1
  16 - SEL$1 / CONT@SEL$1
  17 - SEL$1 / COSE@SEL$1
  18 - SEL$1 / VACOS@SEL$1
  19 - SEL$1 / PACO@SEL$1
  20 - SEL$1 / VAPAC@SEL$1
  21 - SEL$1 / PASE@SEL$1
  22 - SEL$1 / VAPAS@SEL$1
  23 - SEL$1 / CLPA@SEL$1
  24 - SEL$1 / TICO@SEL$1
  25 - SEL$1 / B@SEL$1
  26 - SEL$1 / B@SEL$1
  27 - SEL$1 / PC@SEL$1
  28 - SEL$1 / PC@SEL$1
  29 - SEL$1 / T@SEL$1
  30 - SEL$1 / T@SEL$1

Predicate Information (identified by operation id):
---------------------------------------------------

  26 - access("COSE"."ID_CONTRATO_SERVICO"="B"."ID_CONTRATO_SERVICO")
  27 - filter(("PC"."NR_PRODUTO"='NAD' OR "PC"."NR_PRODUTO"='NAS'))
  28 - access("B"."ID_PRODUTOCOMERCIAL"="PC"."ID_PRODUTOCOMERCIAL")
  29 - filter(("T"."DT_PAGAMENTO">=TO_DATE(' 2013-11-16 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND "T"."DT_EMISSAO">=TO_DATE(' 2010-01-01 00:00:00', 'syyyy-mm-dd
              hh24:mi:ss') AND "T"."DT_PAGAMENTO"<=TO_DATE(' 2013-12-15 23:59:59', 'syyyy-mm-dd hh24:mi:ss') AND "T"."ID_CONTRATO"="B"."ID_CONTRATO"))
  30 - access("B"."ID_TITULO"="T"."ID_TITULO")

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - SYSDEF[4], SYSDEF[32720], SYSDEF[1], SYSDEF[76], SYSDEF[32720]
   2 - TO_CHAR("CONT"."NR_IDPERM")||'#perm!terra'[51], "T"."DT_PAGAMENTO"[DATE,7], "PACO"."NM_PACOTE_COMERCIAL"[VARCHAR2,100], "VAPAC"."VL_MONETARIO"[NUMBER,22],
       "VAPAS"."VL_MONETARIO"[NUMBER,22], "B"."VL_BILHETE"[NUMBER,22], "SERV"."CD_SERVICO"||' - '||"PC"."NR_PRODUTO"[18], "TICO"."CD_TIPO_COBRANCA"[VARCHAR2,10],
       "T"."VL_TITULO"[NUMBER,22], "T"."VL_VALORPAGO"[NUMBER,22]
   3 - "SERV"."CD_SERVICO"[VARCHAR2,10], "SERV"."ID_SERVICO"[NUMBER,22], "SERV"."CD_SERVICO"[VARCHAR2,10], "LISE"."ID_LINHANEGOCIO_SERVICO"[NUMBER,22],
       "LISE"."ID_LINHA_NEGOCIO"[NUMBER,22], "LISE"."ID_SERVICO"[NUMBER,22], "CONT"."ID_CONTA"[NUMBER,22], "CONT"."ID_NAMESPACE"[NUMBER,22], "CONT"."NR_IDPERM"[NUMBER,22],
       "COSE"."ID_CONTRATO_SERVICO"[NUMBER,22], "COSE"."ID_CONTA"[NUMBER,22], "COSE"."ID_PACOTE_COMERCIAL"[NUMBER,22], "VACOS"."ID_CONTRATO_SERVICO"[NUMBER,22],
       "VACOS"."ID_VALOR_PACOTE_COMERCIAL"[NUMBER,22], "VACOS"."DT_FIM"[DATE,7], "PACO"."ID_PACOTE_COMERCIAL"[NUMBER,22], "PACO"."ID_CLASSE_PACOTE"[NUMBER,22],
       "PACO"."ID_LINHA_NEGOCIO"[NUMBER,22], "PACO"."NM_PACOTE_COMERCIAL"[VARCHAR2,100], "VAPAC"."ID_VALOR_PACOTE_COMERCIAL"[NUMBER,22],
       "VAPAC"."ID_PACOTE_COMERCIAL"[NUMBER,22], "VAPAC"."VL_MONETARIO"[NUMBER,22], "PASE"."ID_PACOTECOMERC_SERVICO"[NUMBER,22], "PASE"."ID_PACOTE_COMERCIAL"[NUMBER,22],
       "PASE"."ID_LINHANEGOCIO_SERVICO"[NUMBER,22], "PASE"."TP_CONTA_RECEBE_SERVICO"[VARCHAR2,1], "VAPAS"."ID_PACOTECOMERC_SERVICO"[NUMBER,22],
       "VAPAS"."VL_MONETARIO"[NUMBER,22], "VAPAS"."ID_VALOR_PACOTE_COMERCIAL"[NUMBER,22], "CLPA"."ID_CLASSE_PACOTE"[NUMBER,22], "CLPA"."ID_TIPO_COBRANCA"[NUMBER,22],
       "TICO"."ID_TIPO_COBRANCA"[NUMBER,22], "TICO"."CD_TIPO_COBRANCA"[VARCHAR2,10], "B".ROWID[ROWID,10], "B"."ID_CONTRATO"[NUMBER,22], "B"."ID_TITULO"[NUMBER,22],
       "B"."VL_BILHETE"[NUMBER,22], "B"."ID_PRODUTOCOMERCIAL"[NUMBER,22], "B"."ID_CONTRATO_SERVICO"[NUMBER,22], "PC".ROWID[ROWID,10], "PC"."ID_PRODUTOCOMERCIAL"[NUMBER,22],
       "PC"."NR_PRODUTO"[VARCHAR2,5], "T".ROWID[ROWID,10], "T"."ID_TITULO"[NUMBER,22], "T"."ID_CONTRATO"[NUMBER,22], "T"."DT_EMISSAO"[DATE,7], "T"."VL_TITULO"[NUMBER,22],
       "T"."DT_PAGAMENTO"[DATE,7], "T"."VL_VALORPAGO"[NUMBER,22]

PLAN_TABLE_OUTPUT
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   4 - "SERV"."CD_SERVICO"[VARCHAR2,10], "SERV"."ID_SERVICO"[NUMBER,22], "SERV"."CD_SERVICO"[VARCHAR2,10], "LISE"."ID_LINHANEGOCIO_SERVICO"[NUMBER,22],
       "LISE"."ID_LINHA_NEGOCIO"[NUMBER,22], "LISE"."ID_SERVICO"[NUMBER,22], "CONT"."ID_CONTA"[NUMBER,22], "CONT"."ID_NAMESPACE"[NUMBER,22], "CONT"."NR_IDPERM"[NUMBER,22],
       "COSE"."ID_CONTRATO_SERVICO"[NUMBER,22], "COSE"."ID_CONTA"[NUMBER,22], "COSE"."ID_PACOTE_COMERCIAL"[NUMBER,22], "VACOS"."ID_CONTRATO_SERVICO"[NUMBER,22],
       "VACOS"."ID_VALOR_PACOTE_COMERCIAL"[NUMBER,22], "VACOS"."DT_FIM"[DATE,7], "PACO"."ID_PACOTE_COMERCIAL"[NUMBER,22], "PACO"."ID_CLASSE_PACOTE"[NUMBER,22],
       "PACO"."ID_LINHA_NEGOCIO"[NUMBER,22], "PACO"."NM_PACOTE_COMERCIAL"[VARCHAR2,100], "VAPAC"."ID_VALOR_PACOTE_COMERCIAL"[NUMBER,22],
       "VAPAC"."ID_PACOTE_COMERCIAL"[NUMBER,22], "VAPAC"."VL_MONETARIO"[NUMBER,22], "PASE"."ID_PACOTECOMERC_SERVICO"[NUMBER,22], "PASE"."ID_PACOTE_COMERCIAL"[NUMBER,22],
       "PASE"."ID_LINHANEGOCIO_SERVICO"[NUMBER,22], "PASE"."TP_CONTA_RECEBE_SERVICO"[VARCHAR2,1], "VAPAS"."ID_PACOTECOMERC_SERVICO"[NUMBER,22],
       "VAPAS"."VL_MONETARIO"[NUMBER,22], "VAPAS"."ID_VALOR_PACOTE_COMERCIAL"[NUMBER,22], "CLPA"."ID_CLASSE_PACOTE"[NUMBER,22], "CLPA"."ID_TIPO_COBRANCA"[NUMBER,22],
       "TICO"."ID_TIPO_COBRANCA"[NUMBER,22], "TICO"."CD_TIPO_COBRANCA"[VARCHAR2,10], "B".ROWID[ROWID,10], "B"."ID_CONTRATO"[NUMBER,22], "B"."ID_TITULO"[NUMBER,22],
       "B"."VL_BILHETE"[NUMBER,22], "B"."ID_PRODUTOCOMERCIAL"[NUMBER,22], "B"."ID_CONTRATO_SERVICO"[NUMBER,22], "PC".ROWID[ROWID,10], "PC"."ID_PRODUTOCOMERCIAL"[NUMBER,22],
       "PC"."NR_PRODUTO"[VARCHAR2,5]
   5 - "SERV"."CD_SERVICO"[VARCHAR2,10], "SERV"."ID_SERVICO"[NUMBER,22], "SERV"."CD_SERVICO"[VARCHAR2,10], "LISE"."ID_LINHANEGOCIO_SERVICO"[NUMBER,22],
       "LISE"."ID_LINHA_NEGOCIO"[NUMBER,22], "LISE"."ID_SERVICO"[NUMBER,22], "CONT"."ID_CONTA"[NUMBER,22], "CONT"."ID_NAMESPACE"[NUMBER,22], "CONT"."NR_IDPERM"[NUMBER,22],
       "COSE"."ID_CONTRATO_SERVICO"[NUMBER,22], "COSE"."ID_CONTA"[NUMBER,22], "COSE"."ID_PACOTE_COMERCIAL"[NUMBER,22], "VACOS"."ID_CONTRATO_SERVICO"[NUMBER,22],
       "VACOS"."ID_VALOR_PACOTE_COMERCIAL"[NUMBER,22], "VACOS"."DT_FIM"[DATE,7], "PACO"."ID_PACOTE_COMERCIAL"[NUMBER,22], "PACO"."ID_CLASSE_PACOTE"[NUMBER,22],
       "PACO"."ID_LINHA_NEGOCIO"[NUMBER,22], "PACO"."NM_PACOTE_COMERCIAL"[VARCHAR2,100], "VAPAC"."ID_VALOR_PACOTE_COMERCIAL"[NUMBER,22],
       "VAPAC"."ID_PACOTE_COMERCIAL"[NUMBER,22], "VAPAC"."VL_MONETARIO"[NUMBER,22], "PASE"."ID_PACOTECOMERC_SERVICO"[NUMBER,22], "PASE"."ID_PACOTE_COMERCIAL"[NUMBER,22],
       "PASE"."ID_LINHANEGOCIO_SERVICO"[NUMBER,22], "PASE"."TP_CONTA_RECEBE_SERVICO"[VARCHAR2,1], "VAPAS"."ID_PACOTECOMERC_SERVICO"[NUMBER,22],
       "VAPAS"."VL_MONETARIO"[NUMBER,22], "VAPAS"."ID_VALOR_PACOTE_COMERCIAL"[NUMBER,22], "CLPA"."ID_CLASSE_PACOTE"[NUMBER,22], "CLPA"."ID_TIPO_COBRANCA"[NUMBER,22],
       "TICO"."ID_TIPO_COBRANCA"[NUMBER,22], "TICO"."CD_TIPO_COBRANCA"[VARCHAR2,10], "B".ROWID[ROWID,10], "B"."ID_CONTRATO"[NUMBER,22], "B"."ID_TITULO"[NUMBER,22],
       "B"."VL_BILHETE"[NUMBER,22], "B"."ID_PRODUTOCOMERCIAL"[NUMBER,22], "B"."ID_CONTRATO_SERVICO"[NUMBER,22]
   6 - "SERV"."CD_SERVICO"[VARCHAR2,10], "SERV"."ID_SERVICO"[NUMBER,22], "SERV"."CD_SERVICO"[VARCHAR2,10], "LISE"."ID_LINHANEGOCIO_SERVICO"[NUMBER,22],
       "LISE"."ID_LINHA_NEGOCIO"[NUMBER,22], "LISE"."ID_SERVICO"[NUMBER,22], "CONT"."ID_CONTA"[NUMBER,22], "CONT"."ID_NAMESPACE"[NUMBER,22], "CONT"."NR_IDPERM"[NUMBER,22],
       "COSE"."ID_CONTRATO_SERVICO"[NUMBER,22], "COSE"."ID_CONTA"[NUMBER,22], "COSE"."ID_PACOTE_COMERCIAL"[NUMBER,22], "VACOS"."ID_CONTRATO_SERVICO"[NUMBER,22],
       "VACOS"."ID_VALOR_PACOTE_COMERCIAL"[NUMBER,22], "VACOS"."DT_FIM"[DATE,7], "PACO"."ID_PACOTE_COMERCIAL"[NUMBER,22], "PACO"."ID_CLASSE_PACOTE"[NUMBER,22],
       "PACO"."ID_LINHA_NEGOCIO"[NUMBER,22], "PACO"."NM_PACOTE_COMERCIAL"[VARCHAR2,100], "VAPAC"."ID_VALOR_PACOTE_COMERCIAL"[NUMBER,22],
       "VAPAC"."ID_PACOTE_COMERCIAL"[NUMBER,22], "VAPAC"."VL_MONETARIO"[NUMBER,22], "PASE"."ID_PACOTECOMERC_SERVICO"[NUMBER,22], "PASE"."ID_PACOTE_COMERCIAL"[NUMBER,22],
       "PASE"."ID_LINHANEGOCIO_SERVICO"[NUMBER,22], "PASE"."TP_CONTA_RECEBE_SERVICO"[VARCHAR2,1], "VAPAS"."ID_PACOTECOMERC_SERVICO"[NUMBER,22],
       "VAPAS"."VL_MONETARIO"[NUMBER,22], "VAPAS"."ID_VALOR_PACOTE_COMERCIAL"[NUMBER,22], "CLPA"."ID_CLASSE_PACOTE"[NUMBER,22], "CLPA"."ID_TIPO_COBRANCA"[NUMBER,22],
       "TICO"."ID_TIPO_COBRANCA"[NUMBER,22], "TICO"."CD_TIPO_COBRANCA"[VARCHAR2,10]
   7 - "SERV"."CD_SERVICO"[VARCHAR2,10], "SERV"."ID_SERVICO"[NUMBER,22], "SERV"."CD_SERVICO"[VARCHAR2,10], "LISE"."ID_LINHANEGOCIO_SERVICO"[NUMBER,22],
       "LISE"."ID_LINHA_NEGOCIO"[NUMBER,22], "LISE"."ID_SERVICO"[NUMBER,22], "CONT"."ID_CONTA"[NUMBER,22], "CONT"."ID_NAMESPACE"[NUMBER,22], "CONT"."NR_IDPERM"[NUMBER,22],
       "COSE"."ID_CONTRATO_SERVICO"[NUMBER,22], "COSE"."ID_CONTA"[NUMBER,22], "COSE"."ID_PACOTE_COMERCIAL"[NUMBER,22], "VACOS"."ID_CONTRATO_SERVICO"[NUMBER,22],
       "VACOS"."ID_VALOR_PACOTE_COMERCIAL"[NUMBER,22], "VACOS"."DT_FIM"[DATE,7], "PACO"."ID_PACOTE_COMERCIAL"[NUMBER,22], "PACO"."ID_CLASSE_PACOTE"[NUMBER,22],
       "PACO"."ID_LINHA_NEGOCIO"[NUMBER,22], "PACO"."NM_PACOTE_COMERCIAL"[VARCHAR2,100], "VAPAC"."ID_VALOR_PACOTE_COMERCIAL"[NUMBER,22],
       "VAPAC"."ID_PACOTE_COMERCIAL"[NUMBER,22], "VAPAC"."VL_MONETARIO"[NUMBER,22], "PASE"."ID_PACOTECOMERC_SERVICO"[NUMBER,22], "PASE"."ID_PACOTE_COMERCIAL"[NUMBER,22],
       "PASE"."ID_LINHANEGOCIO_SERVICO"[NUMBER,22], "PASE"."TP_CONTA_RECEBE_SERVICO"[VARCHAR2,1], "VAPAS"."ID_PACOTECOMERC_SERVICO"[NUMBER,22],
       "VAPAS"."VL_MONETARIO"[NUMBER,22], "VAPAS"."ID_VALOR_PACOTE_COMERCIAL"[NUMBER,22], "CLPA"."ID_CLASSE_PACOTE"[NUMBER,22], "CLPA"."ID_TIPO_COBRANCA"[NUMBER,22]
   8 - "SERV"."CD_SERVICO"[VARCHAR2,10], "SERV"."ID_SERVICO"[NUMBER,22], "SERV"."CD_SERVICO"[VARCHAR2,10], "LISE"."ID_LINHANEGOCIO_SERVICO"[NUMBER,22],
       "LISE"."ID_LINHA_NEGOCIO"[NUMBER,22], "LISE"."ID_SERVICO"[NUMBER,22], "CONT"."ID_CONTA"[NUMBER,22], "CONT"."ID_NAMESPACE"[NUMBER,22], "CONT"."NR_IDPERM"[NUMBER,22],
       "COSE"."ID_CONTRATO_SERVICO"[NUMBER,22], "COSE"."ID_CONTA"[NUMBER,22], "COSE"."ID_PACOTE_COMERCIAL"[NUMBER,22], "VACOS"."ID_CONTRATO_SERVICO"[NUMBER,22],
       "VACOS"."ID_VALOR_PACOTE_COMERCIAL"[NUMBER,22], "VACOS"."DT_FIM"[DATE,7], "PACO"."ID_PACOTE_COMERCIAL"[NUMBER,22], "PACO"."ID_CLASSE_PACOTE"[NUMBER,22],
       "PACO"."ID_LINHA_NEGOCIO"[NUMBER,22], "PACO"."NM_PACOTE_COMERCIAL"[VARCHAR2,100], "VAPAC"."ID_VALOR_PACOTE_COMERCIAL"[NUMBER,22],
       "VAPAC"."ID_PACOTE_COMERCIAL"[NUMBER,22], "VAPAC"."VL_MONETARIO"[NUMBER,22], "PASE"."ID_PACOTECOMERC_SERVICO"[NUMBER,22], "PASE"."ID_PACOTE_COMERCIAL"[NUMBER,22],
       "PASE"."ID_LINHANEGOCIO_SERVICO"[NUMBER,22], "PASE"."TP_CONTA_RECEBE_SERVICO"[VARCHAR2,1], "VAPAS"."ID_PACOTECOMERC_SERVICO"[NUMBER,22],
       "VAPAS"."VL_MONETARIO"[NUMBER,22], "VAPAS"."ID_VALOR_PACOTE_COMERCIAL"[NUMBER,22]
   9 - "SERV"."CD_SERVICO"[VARCHAR2,10], "SERV"."ID_SERVICO"[NUMBER,22], "SERV"."CD_SERVICO"[VARCHAR2,10], "LISE"."ID_LINHANEGOCIO_SERVICO"[NUMBER,22],
       "LISE"."ID_LINHA_NEGOCIO"[NUMBER,22], "LISE"."ID_SERVICO"[NUMBER,22], "CONT"."ID_CONTA"[NUMBER,22], "CONT"."ID_NAMESPACE"[NUMBER,22], "CONT"."NR_IDPERM"[NUMBER,22],
       "COSE"."ID_CONTRATO_SERVICO"[NUMBER,22], "COSE"."ID_CONTA"[NUMBER,22], "COSE"."ID_PACOTE_COMERCIAL"[NUMBER,22], "VACOS"."ID_CONTRATO_SERVICO"[NUMBER,22],
       "VACOS"."ID_VALOR_PACOTE_COMERCIAL"[NUMBER,22], "VACOS"."DT_FIM"[DATE,7], "PACO"."ID_PACOTE_COMERCIAL"[NUMBER,22], "PACO"."ID_CLASSE_PACOTE"[NUMBER,22],
       "PACO"."ID_LINHA_NEGOCIO"[NUMBER,22], "PACO"."NM_PACOTE_COMERCIAL"[VARCHAR2,100], "VAPAC"."ID_VALOR_PACOTE_COMERCIAL"[NUMBER,22],
       "VAPAC"."ID_PACOTE_COMERCIAL"[NUMBER,22], "VAPAC"."VL_MONETARIO"[NUMBER,22], "PASE"."ID_PACOTECOMERC_SERVICO"[NUMBER,22], "PASE"."ID_PACOTE_COMERCIAL"[NUMBER,22],
       "PASE"."ID_LINHANEGOCIO_SERVICO"[NUMBER,22], "PASE"."TP_CONTA_RECEBE_SERVICO"[VARCHAR2,1]
  10 - "SERV"."CD_SERVICO"[VARCHAR2,10], "SERV"."ID_SERVICO"[NUMBER,22], "SERV"."CD_SERVICO"[VARCHAR2,10], "LISE"."ID_LINHANEGOCIO_SERVICO"[NUMBER,22],
       "LISE"."ID_LINHA_NEGOCIO"[NUMBER,22], "LISE"."ID_SERVICO"[NUMBER,22], "CONT"."ID_CONTA"[NUMBER,22], "CONT"."ID_NAMESPACE"[NUMBER,22], "CONT"."NR_IDPERM"[NUMBER,22],
       "COSE"."ID_CONTRATO_SERVICO"[NUMBER,22], "COSE"."ID_CONTA"[NUMBER,22], "COSE"."ID_PACOTE_COMERCIAL"[NUMBER,22], "VACOS"."ID_CONTRATO_SERVICO"[NUMBER,22],
       "VACOS"."ID_VALOR_PACOTE_COMERCIAL"[NUMBER,22], "VACOS"."DT_FIM"[DATE,7], "PACO"."ID_PACOTE_COMERCIAL"[NUMBER,22], "PACO"."ID_CLASSE_PACOTE"[NUMBER,22],
       "PACO"."ID_LINHA_NEGOCIO"[NUMBER,22], "PACO"."NM_PACOTE_COMERCIAL"[VARCHAR2,100], "VAPAC"."ID_VALOR_PACOTE_COMERCIAL"[NUMBER,22],
       "VAPAC"."ID_PACOTE_COMERCIAL"[NUMBER,22], "VAPAC"."VL_MONETARIO"[NUMBER,22]
  11 - "SERV"."CD_SERVICO"[VARCHAR2,10], "SERV"."ID_SERVICO"[NUMBER,22], "SERV"."CD_SERVICO"[VARCHAR2,10], "LISE"."ID_LINHANEGOCIO_SERVICO"[NUMBER,22],
       "LISE"."ID_LINHA_NEGOCIO"[NUMBER,22], "LISE"."ID_SERVICO"[NUMBER,22], "CONT"."ID_CONTA"[NUMBER,22], "CONT"."ID_NAMESPACE"[NUMBER,22], "CONT"."NR_IDPERM"[NUMBER,22],
       "COSE"."ID_CONTRATO_SERVICO"[NUMBER,22], "COSE"."ID_CONTA"[NUMBER,22], "COSE"."ID_PACOTE_COMERCIAL"[NUMBER,22], "VACOS"."ID_CONTRATO_SERVICO"[NUMBER,22],
       "VACOS"."ID_VALOR_PACOTE_COMERCIAL"[NUMBER,22], "VACOS"."DT_FIM"[DATE,7], "PACO"."ID_PACOTE_COMERCIAL"[NUMBER,22], "PACO"."ID_CLASSE_PACOTE"[NUMBER,22],
       "PACO"."ID_LINHA_NEGOCIO"[NUMBER,22], "PACO"."NM_PACOTE_COMERCIAL"[VARCHAR2,100]
  12 - "SERV"."CD_SERVICO"[VARCHAR2,10], "SERV"."ID_SERVICO"[NUMBER,22], "SERV"."CD_SERVICO"[VARCHAR2,10], "LISE"."ID_LINHANEGOCIO_SERVICO"[NUMBER,22],
       "LISE"."ID_LINHA_NEGOCIO"[NUMBER,22], "LISE"."ID_SERVICO"[NUMBER,22], "CONT"."ID_CONTA"[NUMBER,22], "CONT"."ID_NAMESPACE"[NUMBER,22], "CONT"."NR_IDPERM"[NUMBER,22],
       "COSE"."ID_CONTRATO_SERVICO"[NUMBER,22], "COSE"."ID_CONTA"[NUMBER,22], "COSE"."ID_PACOTE_COMERCIAL"[NUMBER,22], "VACOS"."ID_CONTRATO_SERVICO"[NUMBER,22],
       "VACOS"."ID_VALOR_PACOTE_COMERCIAL"[NUMBER,22], "VACOS"."DT_FIM"[DATE,7]
  13 - "SERV"."CD_SERVICO"[VARCHAR2,10], "SERV"."ID_SERVICO"[NUMBER,22], "SERV"."CD_SERVICO"[VARCHAR2,10], "LISE"."ID_LINHANEGOCIO_SERVICO"[NUMBER,22],
       "LISE"."ID_LINHA_NEGOCIO"[NUMBER,22], "LISE"."ID_SERVICO"[NUMBER,22], "CONT"."ID_CONTA"[NUMBER,22], "CONT"."ID_NAMESPACE"[NUMBER,22], "CONT"."NR_IDPERM"[NUMBER,22],
       "COSE"."ID_CONTRATO_SERVICO"[NUMBER,22], "COSE"."ID_CONTA"[NUMBER,22], "COSE"."ID_PACOTE_COMERCIAL"[NUMBER,22]
  14 - "SERV"."CD_SERVICO"[VARCHAR2,10], "SERV"."ID_SERVICO"[NUMBER,22], "SERV"."CD_SERVICO"[VARCHAR2,10], "LISE"."ID_LINHANEGOCIO_SERVICO"[NUMBER,22],
       "LISE"."ID_LINHA_NEGOCIO"[NUMBER,22], "LISE"."ID_SERVICO"[NUMBER,22], "CONT"."ID_CONTA"[NUMBER,22], "CONT"."ID_NAMESPACE"[NUMBER,22], "CONT"."NR_IDPERM"[NUMBER,22]
  15 - "SERV"."CD_SERVICO"[VARCHAR2,10], "SERV"."ID_SERVICO"[NUMBER,22], "SERV"."CD_SERVICO"[VARCHAR2,10], "LISE"."ID_LINHANEGOCIO_SERVICO"[NUMBER,22],
       "LISE"."ID_LINHA_NEGOCIO"[NUMBER,22], "LISE"."ID_SERVICO"[NUMBER,22]
  16 - "CONT"."ID_CONTA"[NUMBER,22], "CONT"."ID_NAMESPACE"[NUMBER,22], "CONT"."NR_IDPERM"[NUMBER,22]
  17 - "COSE"."ID_CONTRATO_SERVICO"[NUMBER,22], "COSE"."ID_CONTA"[NUMBER,22], "COSE"."ID_PACOTE_COMERCIAL"[NUMBER,22]
  18 - "VACOS"."ID_CONTRATO_SERVICO"[NUMBER,22], "VACOS"."ID_VALOR_PACOTE_COMERCIAL"[NUMBER,22], "VACOS"."DT_FIM"[DATE,7]
  19 - "PACO"."ID_PACOTE_COMERCIAL"[NUMBER,22], "PACO"."ID_CLASSE_PACOTE"[NUMBER,22], "PACO"."ID_LINHA_NEGOCIO"[NUMBER,22], "PACO"."NM_PACOTE_COMERCIAL"[VARCHAR2,100]
  20 - "VAPAC"."ID_VALOR_PACOTE_COMERCIAL"[NUMBER,22], "VAPAC"."ID_PACOTE_COMERCIAL"[NUMBER,22], "VAPAC"."VL_MONETARIO"[NUMBER,22]
  21 - "PASE"."ID_PACOTECOMERC_SERVICO"[NUMBER,22], "PASE"."ID_PACOTE_COMERCIAL"[NUMBER,22], "PASE"."ID_LINHANEGOCIO_SERVICO"[NUMBER,22],
       "PASE"."TP_CONTA_RECEBE_SERVICO"[VARCHAR2,1]
  22 - "VAPAS"."ID_PACOTECOMERC_SERVICO"[NUMBER,22], "VAPAS"."VL_MONETARIO"[NUMBER,22], "VAPAS"."ID_VALOR_PACOTE_COMERCIAL"[NUMBER,22]
  23 - "CLPA"."ID_CLASSE_PACOTE"[NUMBER,22], "CLPA"."ID_TIPO_COBRANCA"[NUMBER,22]
  24 - "TICO"."ID_TIPO_COBRANCA"[NUMBER,22], "TICO"."CD_TIPO_COBRANCA"[VARCHAR2,10]
  25 - "B".ROWID[ROWID,10], "B"."ID_CONTRATO"[NUMBER,22], "B"."ID_TITULO"[NUMBER,22], "B"."VL_BILHETE"[NUMBER,22], "B"."ID_PRODUTOCOMERCIAL"[NUMBER,22],
       "B"."ID_CONTRATO_SERVICO"[NUMBER,22]
  26 - "B".ROWID[ROWID,10], "B"."ID_CONTRATO_SERVICO"[NUMBER,22]
  27 - "PC".ROWID[ROWID,10], "PC"."ID_PRODUTOCOMERCIAL"[NUMBER,22], "PC"."NR_PRODUTO"[VARCHAR2,5]
  28 - "PC".ROWID[ROWID,10], "PC"."ID_PRODUTOCOMERCIAL"[NUMBER,22]
  29 - "T".ROWID[ROWID,10], "T"."ID_TITULO"[NUMBER,22], "T"."ID_CONTRATO"[NUMBER,22], "T"."DT_EMISSAO"[DATE,7], "T"."VL_TITULO"[NUMBER,22], "T"."DT_PAGAMENTO"[DATE,7],
       "T"."VL_VALORPAGO"[NUMBER,22]
  30 - "T".ROWID[ROWID,10], "T"."ID_TITULO"[NUMBER,22]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:

PLAN_TABLE_OUTPUT
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level


197 linhas selecionadas.

09:48:59 financ03-mia>
09:49:07 financ03-mia>
09:49:07 financ03-mia>
09:49:07 financ03-mia>
09:49:07 financ03-mia>spool off
