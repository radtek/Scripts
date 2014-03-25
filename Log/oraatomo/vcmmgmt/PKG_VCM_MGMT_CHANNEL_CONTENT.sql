CREATE OR REPLACE PACKAGE PKG_VCM_MGMT_CHANNEL_CONTENT AS

/*
Objetivo: Package com a finalidade de possuir procedures e functions,
          para manipulação de content nas tabelas geradas para controle
          da arvore de canais.

Histórico de alterações:
28/04/2009 - CB - Criação da Package
*/

FUNCTION fn_Create_Channel_Tree(p_cIdVcmChannelTree IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL_TREE%TYPE,
                                p_cIdVcmChannelTreeParent IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL_TREE_PARENT%TYPE,
                                p_vName IN VCM_CHANNEL_TREE.NAME%TYPE,
                                p_vDescription IN VCM_CHANNEL_TREE.DESCRIPTION%TYPE,
                                p_nIsActive IN VCM_CHANNEL_TREE.IS_ACTIVE%TYPE,
                                p_nOrderAssibling IN VCM_CHANNEL_TREE.ORDER_ASSIBLING%TYPE,
                                p_cIdPage IN VCM_CHANNEL_TREE.ID_PAGE%TYPE,
                                p_cIdSite IN VCM_CHANNEL_TREE.ID_SITE%TYPE
                               ) RETURN NUMBER;


FUNCTION fn_Update_Channel_Tree(p_cIdVcmChannelTree IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL_TREE%TYPE,
                                p_cIdVcmChannelTreeParent_old IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL_TREE_PARENT%TYPE,
                                p_cIdVcmChannelTreeParent_new IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL_TREE_PARENT%TYPE,
                                p_vNameNew IN VCM_CHANNEL_TREE.NAME%TYPE,
                                p_vNameOld IN VCM_CHANNEL_TREE.NAME%TYPE,
                                p_vDescription IN VCM_CHANNEL_TREE.DESCRIPTION%TYPE,
                                p_nIsActive IN VCM_CHANNEL_TREE.IS_ACTIVE%TYPE,
                                p_nOrderAssibling IN VCM_CHANNEL_TREE.ORDER_ASSIBLING%TYPE,
                                p_cIdPage IN VCM_CHANNEL_TREE.ID_PAGE%TYPE,
                                p_cIdSite IN VCM_CHANNEL_TREE.ID_SITE%TYPE
                               ) RETURN NUMBER;


FUNCTION fn_Delete_Channel_Tree(p_cIdVcmChannelTree IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL_TREE%TYPE
                               ) RETURN NUMBER;


FUNCTION fn_Set_Id_Channel_Tree(p_cIdChannel IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL%TYPE,
                                p_cIdVcmChannelTree IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL_TREE%TYPE
                                ) RETURN NUMBER;

FUNCTION fn_Create_Content(p_cIdVcmContent IN VCM_CONTENT.ID_VCM_CONTENT%TYPE,
                           p_cIdVcmObjectType IN VCM_CONTENT.ID_VCM_OBJECT_TYPE%TYPE,
                           p_cIdVcmContentShift IN VCM_CONTENT.ID_VCM_CONTENT_SHIFT%TYPE,
                           p_vName IN VCM_CONTENT.NAME%TYPE,
                           p_vStatus IN VCM_CONTENT.STATUS%TYPE,
                           p_vIsModified IN VCM_CONTENT.IS_MODIFIED%TYPE,
                           p_vLogicalPath IN VCM_CONTENT.LOGICAL_PATH%TYPE,
                           p_nModCount IN VCM_CONTENT.MOD_COUNT%TYPE
                        ) RETURN NUMBER;

FUNCTION fn_Update_Content(p_cIdVcmContent IN VCM_CONTENT.ID_VCM_CONTENT%TYPE,
                           p_cIdVcmObjectType IN VCM_CONTENT.ID_VCM_OBJECT_TYPE%TYPE,
                           p_cIdVcmContentShift IN VCM_CONTENT.ID_VCM_CONTENT_SHIFT%TYPE,
                           p_vName IN VCM_CONTENT.NAME%TYPE,
                           p_vStatus IN VCM_CONTENT.STATUS%TYPE,
                           p_vIsModified IN VCM_CONTENT.IS_MODIFIED%TYPE,
                           p_vLogicalPath IN VCM_CONTENT.LOGICAL_PATH%TYPE,
                           p_nModCount IN VCM_CONTENT.MOD_COUNT%TYPE
                        ) RETURN NUMBER;

FUNCTION fn_Delete_Content(p_cIdVcmContent IN VCM_CONTENT.ID_VCM_CONTENT%TYPE,
                           p_cIdVcmObjectType IN VCM_CONTENT.ID_VCM_OBJECT_TYPE%TYPE
                        ) RETURN NUMBER;

FUNCTION fn_Create_Channel_Tree_Content(p_cIdVcmChannelTree IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CHANNEL_TREE%TYPE,
                                        p_cIdVcmContent IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CONTENT%TYPE,
                                        p_cIdVcmContentShift IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CONTENT_SHIFT%TYPE,
                                        p_cVcmObjectType IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_OBJECT_TYPE%TYPE
                                     ) RETURN NUMBER;

FUNCTION fn_Update_Date_Published(p_cIdVcmContentShift IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CONTENT_SHIFT%TYPE,
                                  p_vStatus IN VARCHAR2,
                                  p_dDatePublished IN VCM_CHANNEL_TREE_CONTENT.DATE_PUBLISHED%TYPE
                                 ) RETURN NUMBER;


FUNCTION fn_Delete_Channel_Tree_Content(p_cIdVcmChannelTree IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CHANNEL_TREE%TYPE,
                                        p_cIdVcmContent IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CONTENT%TYPE
                                       ) RETURN NUMBER;

PROCEDURE pr_List_Last_News_Corrections(p_crCursor OUT PKG_VCMCONT_UTIL.cRefCursor,
                                        p_vIdVcmChannel IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL%TYPE,
                                        p_vRecursiveChannels IN varchar2,
                                        p_nLimitFrom in number,
                                        p_nLimitTo in number,
                                        p_ExibitionDate in varchar2 default 'Y');

PROCEDURE pr_List_Last_Galleries(p_crCursor OUT PKG_VCMCONT_UTIL.cRefCursor,
                                 p_vIdVcmChannel IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL%TYPE,
                                 p_vRecursiveChannels IN varchar2,
                                 p_nLimitFrom in number,
                                 p_nLimitTo in number,
                                 p_Extended_Photos in varchar2 default 'Y');

PROCEDURE pr_List_Sources(p_cRefCursor OUT PKG_VCMCONT_UTIL.cRefCursor);

PROCEDURE pr_List_Auto_Highlights(p_cRefCursor OUT PKG_VCMCONT_UTIL.cRefCursor,
                                  p_vIdVcmChannel IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL%TYPE,
                                  p_nTotal in number,
                                  p_vRecursiveChannels IN varchar2 default 'Y');

PROCEDURE pr_Get_Full_Path(p_cRefCursor OUT PKG_VCMCONT_UTIL.cRefCursor,
                          p_vIdVcmChannel IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL%TYPE);

PROCEDURE pr_Get_ChannelId(p_cRefCursor OUT PKG_VCMCONT_UTIL.cRefCursor,
                          p_fullPath IN VCM_CHANNEL_TREE.PATH%TYPE );

END PKG_VCM_MGMT_CHANNEL_CONTENT;
/
CREATE OR REPLACE PACKAGE BODY pkg_vcm_mgmt_channel_content AS

/*
Objetivo: Package com a finalidade de possuir procedures e functions,
          para manipulação de content nas tabelas geradas para controle
          da arvore de canais.

Histórico de alterações:
01/10/2009 - CB - Ajustes em diversas procedures e functions, para geração XML de integração V7 com outros publicadores.
28/04/2009 - CB - Criação da Package
16/03/2010 - FF - Removido variáveis globais.
				  Alterado obtenção do próximo Account Plan.
				  Removido obrigação do idSite na função fn_Create_Channel_Tree.
				  Alterado update do Channel Tree para contemplar canais mestres.
*/

--OK CONSTANT NUMBER(1) := 1;
--NOK CONSTANT NUMBER(1) := 0;

/* Definidas estruturas de dados próprias da package, para evitar ao máximo
   que a mesma compartilhe referências de outros objetos e fique inválida.
*/
TYPE cRefCursor IS REF CURSOR;

TYPE recordFields IS RECORD (
  DateTime DATE,
  IdLanguage VARCHAR2(2)
  );
TYPE ListRecordFields IS TABLE OF recordFields;

--==============================================================================

FUNCTION fn_Get_Data(p_cIdVcmContentShift IN VCM_CONTENT.ID_VCM_CONTENT_SHIFT%TYPE,
                      p_cVcmObjectType IN VCM_CONTENT.ID_VCM_OBJECT_TYPE%TYPE) RETURN ListRecordFields AS

    vQuery VARCHAR2(200);
    crCursor cRefCursor;
    listRecords ListRecordFields;
BEGIN


    SELECT 'SELECT '||(CASE WHEN INSTR(VOBJ.NAME, 'DSX-MEDIA', 1, 1) > 0
                   THEN 'CREATEDON, ''XX'' FK_ATOMO_VGN_LANGUAGE_ID_LANG '
                   ELSE 'DATE_CREATED, '||DECODE((SELECT 1 FROM VCMSYS.VGNASATTRDEF VD, VCMSYS.VGNASRELATION VR WHERE VR.PARENTOBJECTTYPEID = VOBJ.ID AND VR.ID = VD.PARENTRELATIONID AND UPPER(VD.NAME) = 'LANGUAGE-ID'), NULL, ' ''XX'' FK_ATOMO_VGN_LANGUAGE_ID_LANG ', 'UPPER(FK_ATOMO_VGN_LANGUAGE_ID_LANG) FK_ATOMO_VGN_LANGUAGE_ID_LANG ')
                   END)||
           ' FROM '||SUBSTR(VD.COLUMNSOURCE, 1, INSTR(VD.COLUMNSOURCE, '.', 1, 1)-1)||' WHERE '||SUBSTR(VD.COLUMNSOURCE, INSTR(VD.COLUMNSOURCE, '.', 1, 1)+1, LENGTH(VD.COLUMNSOURCE))||' = '
    INTO vQuery
    FROM VCMSYS.VGNASRELATION VR,
         VCMSYS.VGNASATTRDEF VD,
         VCMSYS.VGNASOBJECTTYPE VOBJ
    WHERE VR.PARENTRELATIONID IS NULL
    AND VR.ID = VD.PARENTRELATIONID
    AND VD.KEYFIELD = 'T'
    AND VR.PARENTOBJECTTYPEID = VOBJ.ID
    AND VOBJ.ID = p_cVcmObjectType
    AND UPPER(DATASOURCELABEL) = 'ATOMO RESOURCE'
    AND ROWNUM = 1;

    OPEN crCursor FOR vQuery||''''||p_cIdVcmContentShift||'''';

    FETCH crCursor BULK COLLECT INTO listRecords;

    CLOSE crCursor;

    RETURN listRecords;

    EXCEPTION
      WHEN OTHERS THEN
        IF(crCursor%ISOPEN)THEN
           CLOSE crCursor;
        END IF;
        RETURN NULL;

END fn_Get_Data;

--==============================================================================

FUNCTION fn_Get_Concat_Text_Data(p_cIdVcmContentShift IN VCM_CONTENT.ID_VCM_CONTENT_SHIFT%TYPE,
                                 p_cVcmObjectType IN VCM_CONTENT.ID_VCM_OBJECT_TYPE%TYPE) RETURN clob AS
	  lv_concat_text clob;
BEGIN

   case p_cVcmObjectType
     when 'ca4a4e75b5419110VgnVCM1000005801010a____' then
        SELECT '<NAME>'||N.TITLE || '</NAME>'||
               '<CONCAT_TEXT>'||N.KEYWORDS||' '||N.SUBTITLE ||' '|| N.BODY||'</CONCAT_TEXT>'
          INTO lv_concat_text
          FROM ATOMO_VGN_NEWS N
         WHERE N.ID_NEWS = p_cIdVcmContentShift;

     when '98e44e75b5419110VgnVCM1000005801010a____' then
        SELECT '<NAME>'||G.TITLE || '</NAME>'||
               '<CONCAT_TEXT>'||G.KEYWORDS||' '||G.SUBTITLE ||' '|| G.SUMMARY ||' '|| G.TEXT_BODY||'</CONCAT_TEXT>'
          INTO lv_concat_text
          FROM ATOMO_VGN_GALLERY G
         WHERE G.ID_GALLERY = p_cIdVcmContentShift;

     when '5a124e75b5419110VgnVCM1000005801010a____' then
        SELECT '<NAME>'||CO.TITLE || '</NAME>'||
               '<CONCAT_TEXT>'||CO.KEYWORDS||' '||CO.SUBTITLE ||' '|| CO.BODY||'</CONCAT_TEXT>'
          INTO lv_concat_text
          FROM ATOMO_VGN_CORRECTION CO
         WHERE CO.ID_CORRECTION = p_cIdVcmContentShift;

     when 'bb044e75b5419110VgnVCM1000005801010a____' then
        SELECT '<NAME>'||FC.TITLE || '</NAME>'||
               '<CONCAT_TEXT>'||FC.KEYWORDS||'</CONCAT_TEXT>'
          INTO lv_concat_text
          FROM ATOMO_VGN_FREE_CONTENT FC
         WHERE FC.ID_FREE_CONTENT = p_cIdVcmContentShift;

     when 'a2594e75b5419110VgnVCM1000005801010a____' then
        SELECT '<NAME>'||L.TITLE || '</NAME>'||
               '<CONCAT_TEXT>'||L.KEYWORDS||' '||L.HEADLINE||' '||L.TEASER||' '||L.EXTERNAL_URL||'</CONCAT_TEXT>'
          INTO lv_concat_text
          FROM ATOMO_VGN_LINK L
         WHERE L.ID_LINK = p_cIdVcmContentShift;

     when '63880a61a5089110VgnVCM100000421f49c9____' then
        SELECT '<NAME>'||V.TITLE || '</NAME>'||
               '<CONCAT_TEXT>'|| V.KEYWORDS ||' '|| V.RESUMEN || '</CONCAT_TEXT>'
          INTO lv_concat_text
          FROM ATOMO_VGN_AUDIO_VIDEO V
         WHERE V.ID_AUDIO_VIDEO = p_cIdVcmContentShift;

     when '7a8897708eb2a110VgnVCM100000a61d31c9____' then
        SELECT '<NAME>'||H.TITLE || '</NAME>'||
               '<CONCAT_TEXT>'|| H.TEXT || '</CONCAT_TEXT>'
          INTO lv_concat_text
          FROM ATOMO_VGN_HEADLINE H
         WHERE H.ID_HEADLINE = p_cIdVcmContentShift;

     when 'c3e9ddb96d425110VgnVCM100000150f480a____' then
        SELECT '<NAME>' || DMC.TITLE || ' '|| DMC.CAPTION || '</NAME>' || '<PUBLISHER>' || DMC.PUBLISHER || '</PUBLISHER>'||
               '<COPYRIGHT>' || DMC.COPYRIGHT || '</COPYRIGHT>'||'<CREATEDBY>'|| DMC.CREATEDBY ||'</CREATEDBY>'
          INTO lv_concat_text
          FROM DSX_MEDIA_COMMON DMC
         WHERE DMC.MEDIAID = p_cIdVcmContentShift;

     when '1fb9ddb96d425110VgnVCM100000150f480a____' then
        SELECT '<NAME>' || DMC.TITLE || ' '|| DMC.CAPTION || '</NAME>' || '<PUBLISHER>' || DMC.PUBLISHER || '</PUBLISHER>'||
               '<COPYRIGHT>' || DMC.COPYRIGHT || '</COPYRIGHT>'||'<CREATEDBY>'|| DMC.CREATEDBY ||'</CREATEDBY>'
          INTO lv_concat_text
          FROM DSX_MEDIA_COMMON DMC
         WHERE DMC.MEDIAID = p_cIdVcmContentShift;

     end case;

     return lv_concat_text;

    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;

END fn_Get_Concat_Text_Data;

--==============================================================================

FUNCTION fn_Get_PathChannel(p_cIdVcmChannelTreeParent IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL_TREE_PARENT%TYPE) RETURN VARCHAR2 AS

    vPathChannel VCM_CHANNEL_TREE.PATH%TYPE;
BEGIN

    SELECT PATH
    INTO vPathChannel
    FROM VCM_CHANNEL_TREE
    WHERE ID_VCM_CHANNEL_TREE = p_cIdVcmChannelTreeParent;

    RETURN vPathChannel;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
          RETURN NULL;

END fn_Get_PathChannel;

--==============================================================================


FUNCTION fn_Get_Plan_Accounts(p_cIdVcmChannelTree IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL_TREE%TYPE,
                              p_cIdVcmChannelTreeParent IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL_TREE_PARENT%TYPE) RETURN VARCHAR2 AS

    vAccountPlan VCM_CHANNEL_TREE.ACCOUNT_PLAN%TYPE;
    nTotal NUMBER(10);
    nNodes NUMBER(38);
BEGIN

    /* nodo raiz (qualquer canal Home pertencente a um site)*/
    IF(p_cIdVcmChannelTreeParent IS NULL) THEN

        SELECT
           NVL(MAX(SUBSTR(ACCOUNT_PLAN, 1,  INSTR(ACCOUNT_PLAN, '.', 1, 1)-1)+1),1)||'.'
        INTO vAccountPlan
        FROM VCM_CHANNEL_TREE
        WHERE ID_VCM_CHANNEL_TREE_PARENT IS NULL;

    /* nodo filho (qualquer canal abaixo do canal Home) */
    ELSE

        /* verifica quantidade de nodos filhos, para o canal pai */
        SELECT COUNT(ID_VCM_CHANNEL_TREE)
        INTO nNodes
        FROM VCM_CHANNEL_TREE
        WHERE ID_VCM_CHANNEL_TREE_PARENT = p_cIdVcmChannelTreeParent;

        /* se canal pai possui nodos filhos */
        IF(nNodes > 0)THEN

            SELECT X.ACCOUNT_PLAN,
                   MAX(TO_NUMBER(REPLACE(SUBSTR(VCT.ACCOUNT_PLAN,TO_NUMBER(X.LENGTH_ACCOUNT_PLAN)+1,LENGTH(VCT.ACCOUNT_PLAN)),'.','') )) + 1
            INTO vAccountPlan, nTotal
            FROM VCM_CHANNEL_TREE VCT,
                 (SELECT ID_VCM_CHANNEL_TREE, LENGTH(ACCOUNT_PLAN) LENGTH_ACCOUNT_PLAN, ACCOUNT_PLAN
                  FROM VCM_CHANNEL_TREE
                  WHERE ID_VCM_CHANNEL_TREE = p_cIdVcmChannelTreeParent
                 ) X
            WHERE VCT.ID_VCM_CHANNEL_TREE_PARENT = X.ID_VCM_CHANNEL_TREE
            AND VCT.ID_VCM_CHANNEL_TREE_PARENT = p_cIdVcmChannelTreeParent
            GROUP BY X.ACCOUNT_PLAN;

            vAccountPlan := vAccountPlan||nTotal||'.';

        ELSE

            /* primeiro filho do canal pai */
            SELECT ACCOUNT_PLAN
            INTO vAccountPlan
            FROM VCM_CHANNEL_TREE
            WHERE ID_VCM_CHANNEL_TREE = p_cIdVcmChannelTreeParent;

            vAccountPlan := vAccountPlan||'1.';

        END IF;

    END IF;

    RETURN vAccountPlan;


END fn_Get_Plan_Accounts;

--==============================================================================

FUNCTION fn_Get_Plan_Accounts_Update(p_cIdVcmChannelTree IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL_TREE%TYPE,
                                     p_cIdVcmChannelTreeParent IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL_TREE_PARENT%TYPE) RETURN VARCHAR2 AS

    vAccountPlan VCM_CHANNEL_TREE.ACCOUNT_PLAN%TYPE;
    nTotal NUMBER(10);
    nNodes NUMBER(38);
BEGIN

    /* nodo raiz (qualquer canal Home pertencente a um site)*/
    IF(p_cIdVcmChannelTreeParent IS NULL) THEN

        SELECT
           NVL(MAX(SUBSTR(ACCOUNT_PLAN, 1,  INSTR(ACCOUNT_PLAN, '.', 1, 1)-1)+1),1)||'.'
        INTO vAccountPlan
        FROM VCM_CHANNEL_TREE
        WHERE ID_VCM_CHANNEL_TREE_PARENT IS NULL;

    /* nodo filho (qualquer canal abaixo do canal Home) */
    ELSE

        /* verifica quantidade de nodos filhos, para o canal pai, sem considerar o canal atual */
        SELECT COUNT(ID_VCM_CHANNEL_TREE)
        INTO nNodes
        FROM VCM_CHANNEL_TREE
        WHERE ID_VCM_CHANNEL_TREE_PARENT = p_cIdVcmChannelTreeParent
          AND ID_VCM_CHANNEL_TREE != p_cIdVcmChannelTree;

        /* se canal pai possui nodos filhos */
        IF(nNodes > 0)THEN

            SELECT X.ACCOUNT_PLAN,
                   MAX(TO_NUMBER(REPLACE(SUBSTR(VCT.ACCOUNT_PLAN,TO_NUMBER(X.LENGTH_ACCOUNT_PLAN)+1,LENGTH(VCT.ACCOUNT_PLAN)),'.','') )) + 1
            INTO vAccountPlan, nTotal
            FROM VCM_CHANNEL_TREE VCT,
                 (SELECT ID_VCM_CHANNEL_TREE, LENGTH(ACCOUNT_PLAN) LENGTH_ACCOUNT_PLAN, ACCOUNT_PLAN
                  FROM VCM_CHANNEL_TREE
                  WHERE ID_VCM_CHANNEL_TREE = p_cIdVcmChannelTreeParent
                 ) X
            WHERE VCT.ID_VCM_CHANNEL_TREE_PARENT = X.ID_VCM_CHANNEL_TREE
            AND VCT.ID_VCM_CHANNEL_TREE_PARENT = p_cIdVcmChannelTreeParent
            AND VCT.ID_VCM_CHANNEL_TREE != p_cIdVcmChannelTree -- sem considerar o canal atual
            GROUP BY X.ACCOUNT_PLAN;

            vAccountPlan := vAccountPlan||nTotal||'.';

        ELSE

            /* primeiro filho do canal pai */
            SELECT ACCOUNT_PLAN
            INTO vAccountPlan
            FROM VCM_CHANNEL_TREE
            WHERE ID_VCM_CHANNEL_TREE = p_cIdVcmChannelTreeParent;

            vAccountPlan := vAccountPlan||'1.';

        END IF;

    END IF;

    RETURN vAccountPlan;


END fn_Get_Plan_Accounts_Update;

--==============================================================================

FUNCTION fn_Create_Channel_Tree(p_cIdVcmChannelTree IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL_TREE%TYPE,
                                p_cIdVcmChannelTreeParent IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL_TREE_PARENT%TYPE,
                                p_vName IN VCM_CHANNEL_TREE.NAME%TYPE,
                                p_vDescription IN VCM_CHANNEL_TREE.DESCRIPTION%TYPE,
                                p_nIsActive IN VCM_CHANNEL_TREE.IS_ACTIVE%TYPE,
                                p_nOrderAssibling IN VCM_CHANNEL_TREE.ORDER_ASSIBLING%TYPE,
                                p_cIdPage IN VCM_CHANNEL_TREE.ID_PAGE%TYPE,
                                p_cIdSite IN VCM_CHANNEL_TREE.ID_SITE%TYPE
                             ) RETURN NUMBER AS

    eNullParamenter EXCEPTION;
    vAccountPlan VCM_CHANNEL_TREE.ACCOUNT_PLAN%TYPE;
    vAccountPlanAux  VCM_CHANNEL_TREE.ACCOUNT_PLAN%TYPE;
    vPathChannel VCM_CHANNEL_TREE.PATH%TYPE;
    lLevel PKG_VCMCONT_UTIL.tListElements;
    nLevel NUMBER(10);
BEGIN

    IF(p_cIdVcmChannelTree IS NULL OR
       p_vName IS NULL) THEN

       RAISE eNullParamenter;

    END IF;

    vPathChannel := fn_Get_PathChannel(p_cIdVcmChannelTreeParent);

    vAccountPlan := fn_Get_Plan_Accounts(p_cIdVcmChannelTree, p_cIdVcmChannelTreeParent);

    --armazena valor na veriavel auxiliar pois a procedure abaixo, manipula o valor vAccountPlanAux
    vAccountPlanAux := vAccountPlan;

    lLevel := PKG_VCMCONT_UTIL.fn_To_Break_String(vAccountPlanAux, '.', lLevel);

    nLevel := lLevel.COUNT;

    INSERT INTO VCM_CHANNEL_TREE
          (id_vcm_channel_tree,
           id_vcm_channel_tree_parent,
           account_plan,
           name,
           description,
           is_active,
           order_assibling,
           id_page,
           id_site,
           date_created,
           date_updated,
           path,
           "LEVEL",
           id_vcm_channel,
           furl_channel
          )
    VALUES(p_cIdVcmChannelTree,
           p_cIdVcmChannelTreeParent,
           vAccountPlan,
           p_vName,
           p_vDescription,
           p_nIsActive,
           p_nOrderAssibling,
           p_cIdPage,
           p_cIdSite,
           CURRENT_DATE,
           NULL,
           vPathChannel||'/'||p_vName,
           nLevel,
           NULL,
           NULL);

    lLevel.DELETE;

    RETURN 1; -- OK

    EXCEPTION
      WHEN eNullParamenter THEN
        RETURN 0; -- NOT OK
      WHEN DUP_VAL_ON_INDEX THEN
        RETURN fn_Create_Channel_Tree(p_cIdVcmChannelTree,
                                    p_cIdVcmChannelTreeParent,
                                    p_vName,
                                    p_vDescription,
                                    p_nIsActive,
                                    p_nOrderAssibling,
                                    p_cIdPage,
                                    p_cIdSite);
      WHEN OTHERS THEN
        RETURN SQLCODE;

END fn_Create_Channel_Tree;


--==============================================================================

FUNCTION fn_Update_Channel_Tree(p_cIdVcmChannelTree IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL_TREE%TYPE,
                                p_cIdVcmChannelTreeParent_old IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL_TREE_PARENT%TYPE,
                                p_cIdVcmChannelTreeParent_new IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL_TREE_PARENT%TYPE,
                                p_vNameNew IN VCM_CHANNEL_TREE.NAME%TYPE,
                                p_vNameOld IN VCM_CHANNEL_TREE.NAME%TYPE,
                                p_vDescription IN VCM_CHANNEL_TREE.DESCRIPTION%TYPE,
                                p_nIsActive IN VCM_CHANNEL_TREE.IS_ACTIVE%TYPE,
                                p_nOrderAssibling IN VCM_CHANNEL_TREE.ORDER_ASSIBLING%TYPE,
                                p_cIdPage IN VCM_CHANNEL_TREE.ID_PAGE%TYPE,
                                p_cIdSite IN VCM_CHANNEL_TREE.ID_SITE%TYPE
                               ) RETURN NUMBER AS

    eNullParamenter EXCEPTION;
    vNewAccountPlan VCM_CHANNEL_TREE.ACCOUNT_PLAN%TYPE;
    vNewLevel VCM_CHANNEL_TREE."LEVEL"%TYPE;
BEGIN

    IF(p_cIdVcmChannelTree IS NULL OR
       p_vNameNew IS NULL OR
       p_vNameOld IS NULL OR
       p_cIdSite IS NULL) THEN

       RAISE eNullParamenter;

    END IF;

    UPDATE VCM_CHANNEL_TREE
    SET NAME = p_vNameNew
    , ID_VCM_CHANNEL_TREE_PARENT = p_cIdVcmChannelTreeParent_new
    , DESCRIPTION = p_vDescription
    , IS_ACTIVE = p_nIsActive
    , ORDER_ASSIBLING = p_nOrderAssibling
    , ID_PAGE = p_cIdPage
    , ID_SITE = p_cIdSite
    , DATE_UPDATED = CURRENT_DATE
    WHERE ID_VCM_CHANNEL_TREE = p_cIdVcmChannelTree;

    -- atualizacao do path
    IF(p_vNameNew != p_vNameOld) or (p_cIdVcmChannelTreeParent_old != p_cIdVcmChannelTreeParent_new) THEN

        -- se mudou canal pai
        IF (p_cIdVcmChannelTreeParent_old != p_cIdVcmChannelTreeParent_new) THEN
           -- obtem novo account plan
           vNewAccountPlan := fn_Get_Plan_Accounts_Update(p_cIdVcmChannelTree, p_cIdVcmChannelTreeParent_new);
           -- atualiza o canal para o level do novo pai + 1
           SELECT "LEVEL" + 1
             INTO vNewLevel
             FROM VCM_CHANNEL_TREE
            WHERE ID_VCM_CHANNEL_TREE = p_cIdVcmChannelTreeParent_new;

           UPDATE VCM_CHANNEL_TREE
              SET "LEVEL" = vNewLevel
            WHERE ID_VCM_CHANNEL_TREE = p_cIdVcmChannelTree;
        END IF;

        FOR x IN (SELECT ID_VCM_CHANNEL_TREE,
                         ID_VCM_CHANNEL_TREE_PARENT,
                         --SUBSTR(VCT.PATH, 0, INSTR(VCT.PATH, '/', 1, X.nivel))||p_vNameNew||SUBSTR(VCT.PATH, INSTR(VCT.PATH, '/', 1, X.nivel)+LENGTH(p_vNameOld)+1) PATH_REPLACE,
                         Y.caminho||SYS_CONNECT_BY_PATH( vct.name, '/' ) PATH_REPLACE, -- novo path = path do pai || nome do filho (s)
                         (X.nivel + level - 1) NEW_LEVEL, -- novo nivel = nivel do pai (recem atualizado) + 1 para cada nivel abaixo
                         vNewAccountPlan||substr(VCT.ACCOUNT_PLAN,instr(VCT.ACCOUNT_PLAN,X.ACCOUNT_PLAN)+LENGTH(X.ACCOUNT_PLAN),LENGTH(VCT.account_plan)) NEW_ACCOUNTPLAN -- novo account plan = novo account plan do canal principal || final do account plan dos filhos
                  FROM VCM_CHANNEL_TREE VCT,
                       (SELECT "LEVEL" as nivel, ACCOUNT_PLAN FROM VCM_CHANNEL_TREE WHERE ID_VCM_CHANNEL_TREE = p_cIdVcmChannelTree) X,
                       (SELECT "PATH" as caminho FROM VCM_CHANNEL_TREE WHERE ID_VCM_CHANNEL_TREE = p_cIdVcmChannelTreeParent_new ) Y
                  START WITH VCT.ID_VCM_CHANNEL_TREE = p_cIdVcmChannelTree
                  CONNECT BY PRIOR VCT.ID_VCM_CHANNEL_TREE = VCT.ID_VCM_CHANNEL_TREE_PARENT
                  ) LOOP

                  IF(p_vNameNew != p_vNameOld) THEN -- se mudou o nome, altera somente o  path
                    UPDATE VCM_CHANNEL_TREE
                    SET PATH = x.PATH_REPLACE
                    WHERE ID_VCM_CHANNEL_TREE = x.ID_VCM_CHANNEL_TREE;
                  END IF;

                  IF (p_cIdVcmChannelTreeParent_old != p_cIdVcmChannelTreeParent_new) THEN
                    -- se mudou o canal pai, altera o path, o level e account plan dos canais abaixo
                    UPDATE VCM_CHANNEL_TREE
                       SET "PATH" = x.PATH_REPLACE,
                           "LEVEL" = x.NEW_LEVEL,
                           ACCOUNT_PLAN = x.NEW_ACCOUNTPLAN
                     WHERE ID_VCM_CHANNEL_TREE = x.ID_VCM_CHANNEL_TREE;
                     -- e altera o account plan dos conteudos
                     UPDATE VCM_CHANNEL_TREE_CONTENT
                        SET ACCOUNT_PLAN = vNewAccountPlan
                      WHERE ID_VCM_CHANNEL_TREE = x.ID_VCM_CHANNEL_TREE;
                  END IF;

        END LOOP;

    END IF;

    RETURN 1; -- OK

    EXCEPTION
      WHEN eNullParamenter THEN
        RETURN 0; -- NOT OK
      WHEN OTHERS THEN
        RETURN SQLCODE;

END fn_Update_Channel_Tree;

--==============================================================================

FUNCTION fn_Delete_Channel_Tree(p_cIdVcmChannelTree IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL_TREE%TYPE
                               ) RETURN NUMBER AS

    eNullParamenter EXCEPTION;
BEGIN

    IF(p_cIdVcmChannelTree IS NULL) THEN

       RAISE eNullParamenter;

    END IF;

    DELETE FROM VCM_CHANNEL_TREE
    WHERE ID_VCM_CHANNEL_TREE = p_cIdVcmChannelTree;

    RETURN 1; -- OK

    EXCEPTION
      WHEN eNullParamenter THEN
        RETURN 0; -- NOT OK
      WHEN OTHERS THEN
        RETURN SQLCODE;

END fn_Delete_Channel_Tree;


--==============================================================================


FUNCTION fn_Set_Id_Channel_Tree(p_cIdChannel IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL%TYPE,
                                p_cIdVcmChannelTree IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL_TREE%TYPE
                                ) RETURN NUMBER AS

    eNullParamenter EXCEPTION;
BEGIN

    IF(p_cIdChannel IS NULL OR p_cIdVcmChannelTree IS NULL) THEN

       RAISE eNullParamenter;

    END IF;

    UPDATE VCM_CHANNEL_TREE
    SET ID_VCM_CHANNEL = p_cIdChannel
    WHERE ID_VCM_CHANNEL_TREE = p_cIdVcmChannelTree;

    RETURN 1; -- OK

    EXCEPTION
      WHEN eNullParamenter THEN
        RETURN 0; -- NOT OK
      WHEN OTHERS THEN
        RETURN SQLCODE;

END fn_Set_Id_Channel_Tree;

--==============================================================================

FUNCTION fn_Create_Content(p_cIdVcmContent IN VCM_CONTENT.ID_VCM_CONTENT%TYPE,
                           p_cIdVcmObjectType IN VCM_CONTENT.ID_VCM_OBJECT_TYPE%TYPE,
                           p_cIdVcmContentShift IN VCM_CONTENT.ID_VCM_CONTENT_SHIFT%TYPE,
                           p_vName IN VCM_CONTENT.NAME%TYPE,
                           p_vStatus IN VCM_CONTENT.STATUS%TYPE,
                           p_vIsModified IN VCM_CONTENT.IS_MODIFIED%TYPE,
                           p_vLogicalPath IN VCM_CONTENT.LOGICAL_PATH%TYPE,
                           p_nModCount IN VCM_CONTENT.MOD_COUNT%TYPE
                        ) RETURN NUMBER AS

    eNullParamenter EXCEPTION;
    lRecords ListRecordFields;
    rFields recordFields;
    lv_concat_text clob;
BEGIN

    IF(p_cIdVcmContent IS NULL OR
       p_cIdVcmObjectType IS NULL OR
       p_cIdVcmContentShift IS NULL OR
       p_vName IS NULL) THEN

       RAISE eNullParamenter;

    END IF;

    lRecords := fn_Get_Data(p_cIdVcmContentShift, p_cIdVcmObjectType);
    lv_concat_text := fn_Get_Concat_Text_Data(p_cIdVcmContentShift,p_cIdVcmObjectType);

    IF(lRecords.EXISTS(1) = TRUE) THEN

        rFields := lRecords(lRecords.FIRST);

        INSERT INTO VCM_CONTENT
              (id_vcm_content,
               id_vcm_object_type,
               id_vcm_content_shift,
               name,
               status,
               is_modified,
               logical_path,
               mod_count,
               date_created,
               date_updated,
               id_language,
               concat_text)
        VALUES(p_cIdVcmContent,
               p_cIdVcmObjectType,
               p_cIdVcmContentShift,
               p_vName,
               p_vStatus,
               p_vIsModified,
               p_vLogicalPath,
               p_nModCount,
               rFields.DateTime,
               NULL,
               rFields.IdLanguage,
               lv_concat_text);

        lRecords.DELETE;

    END IF;

    RETURN 1; -- OK


    EXCEPTION
      WHEN eNullParamenter THEN
        RETURN 0; -- NOT OK
      WHEN OTHERS THEN
        RETURN SQLCODE;

END fn_Create_Content;

--==============================================================================

FUNCTION fn_Update_Content(p_cIdVcmContent IN VCM_CONTENT.ID_VCM_CONTENT%TYPE,
                           p_cIdVcmObjectType IN VCM_CONTENT.ID_VCM_OBJECT_TYPE%TYPE,
                           p_cIdVcmContentShift IN VCM_CONTENT.ID_VCM_CONTENT_SHIFT%TYPE,
                           p_vName IN VCM_CONTENT.NAME%TYPE,
                           p_vStatus IN VCM_CONTENT.STATUS%TYPE,
                           p_vIsModified IN VCM_CONTENT.IS_MODIFIED%TYPE,
                           p_vLogicalPath IN VCM_CONTENT.LOGICAL_PATH%TYPE,
                           p_nModCount IN VCM_CONTENT.MOD_COUNT%TYPE
                        ) RETURN NUMBER AS

    eNullParamenter EXCEPTION;
    lRecords ListRecordFields;
    rFields recordFields;
    lv_concat_text clob;
BEGIN

    IF(p_cIdVcmContent IS NULL OR
       p_cIdVcmObjectType IS NULL OR
       p_vName IS NULL) THEN

       RAISE eNullParamenter;

    END IF;

    lRecords := fn_Get_Data(p_cIdVcmContentShift, p_cIdVcmObjectType);
    lv_concat_text := fn_Get_Concat_Text_Data(p_cIdVcmContentShift,p_cIdVcmObjectType);

    IF(lRecords.EXISTS(1) = TRUE) THEN

        rFields := lRecords(lRecords.FIRST);

        UPDATE VCM_CONTENT
        SET NAME = p_vName
        , STATUS = p_vStatus
        , IS_MODIFIED = p_vIsModified
        , LOGICAL_PATH = p_vLogicalPath
        , MOD_COUNT = p_nModCount
        , DATE_UPDATED = CURRENT_DATE
        , ID_LANGUAGE = rFields.IdLanguage
        , CONCAT_TEXT = lv_concat_text
        WHERE ID_VCM_CONTENT = p_cIdVcmContent
        AND ID_VCM_OBJECT_TYPE = p_cIdVcmObjectType;

        UPDATE VCM_CHANNEL_TREE_CONTENT
        SET NAME = p_vName
        , ID_LANGUAGE = rFields.IdLanguage
        , FURL_CONTENT_TITLE = f_url_escape(p_vName)
        , STATUS = case when DATE_PUBLISHED is null or STATUS = 'U' then 'U' else 'W' end
        WHERE ID_VCM_CONTENT = p_cIdVcmContent
        AND ID_VCM_OBJECT_TYPE = p_cIdVcmObjectType;

        lRecords.DELETE;

    END IF;

    RETURN 1; -- OK

    EXCEPTION
      WHEN eNullParamenter THEN
        RETURN 0; -- NOT OK
      WHEN OTHERS THEN
        RETURN SQLCODE;

END fn_Update_Content;

--==============================================================================

FUNCTION fn_Delete_Content(p_cIdVcmContent IN VCM_CONTENT.ID_VCM_CONTENT%TYPE,
                           p_cIdVcmObjectType IN VCM_CONTENT.ID_VCM_OBJECT_TYPE%TYPE
                        ) RETURN NUMBER AS

    eNullParamenter EXCEPTION;
BEGIN

    IF(p_cIdVcmContent IS NULL OR p_cIdVcmObjectType IS NULL) THEN

       RAISE eNullParamenter;

    END IF;

    DELETE FROM VCM_CONTENT
    WHERE ID_VCM_CONTENT = p_cIdVcmContent
    AND ID_VCM_OBJECT_TYPE = p_cIdVcmObjectType;

    RETURN 1; -- OK

    EXCEPTION
      WHEN eNullParamenter THEN
        RETURN 0; -- NOT OK
      WHEN OTHERS THEN
        RETURN SQLCODE;

END fn_Delete_Content;

--==============================================================================

FUNCTION fn_Create_Channel_Tree_Content(p_cIdVcmChannelTree IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CHANNEL_TREE%TYPE,
                                        p_cIdVcmContent IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CONTENT%TYPE,
                                        p_cIdVcmContentShift IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CONTENT_SHIFT%TYPE,
                                        p_cVcmObjectType IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_OBJECT_TYPE%TYPE
                                     ) RETURN NUMBER AS
    eNullParamenter EXCEPTION;
    vIdObjectType CHAR(40);
    vName VCM_CHANNEL_TREE_CONTENT.NAME%TYPE;
    lvContDatePub VCM_CONTENT.DATE_PUBLISHED%TYPE;
    lRecords ListRecordFields;
    rFields recordFields;
BEGIN

    IF(p_cIdVcmChannelTree IS NULL OR
       p_cIdVcmContent IS NULL OR
       p_cIdVcmContentShift IS NULL) THEN

       RAISE eNullParamenter;

    END IF;

    SELECT ID_VCM_OBJECT_TYPE, NAME, DATE_PUBLISHED
    INTO vIdObjectType, vName, lvContDatePub
    FROM VCM_CONTENT
    WHERE ID_VCM_CONTENT = p_cIdVcmContent;

    lRecords := fn_Get_Data(p_cIdVcmContentShift, vIdObjectType);

    IF(lRecords.EXISTS(1) = TRUE) THEN

        rFields := lRecords(lRecords.FIRST);

        INSERT INTO VCM_CHANNEL_TREE_CONTENT
              (id_vcm_channel_tree,
               id_vcm_content,
               id_vcm_content_shift,
               account_plan,
               id_vcm_object_type,
               date_created,
               name,
               id_language,
               status,
               date_published,
               furl_content_title )
        VALUES(p_cIdVcmChannelTree,
               p_cIdVcmContent,
               p_cIdVcmContentShift,
               (SELECT ACCOUNT_PLAN FROM VCM_CHANNEL_TREE WHERE ID_VCM_CHANNEL_TREE = p_cIdVcmChannelTree),
               vIdObjectType,
               rFields.DateTime,
               vName,
               rFields.IdLanguage,
               DECODE( lvContDatePub, null, 'U', 'W'), -- se o conteudo ja estiver publicado, fica stale
               lvContDatePub,
               f_url_escape(vName));

        lRecords.DELETE;

    END IF;

    RETURN 1; -- OK

    EXCEPTION
      WHEN eNullParamenter THEN
        RETURN 0; -- NOT OK
      WHEN OTHERS THEN
        RETURN SQLCODE;

END fn_Create_Channel_Tree_Content;


--==============================================================================

FUNCTION fn_Update_Date_Published(p_cIdVcmContentShift IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CONTENT_SHIFT%TYPE,
                                  p_vStatus IN VARCHAR2,
                                  p_dDatePublished IN VCM_CHANNEL_TREE_CONTENT.DATE_PUBLISHED%TYPE
                                  ) RETURN NUMBER AS
    eNullParamenter EXCEPTION;
BEGIN

    IF(p_cIdVcmContentShift IS NULL OR
       p_vStatus IS NULL OR
       p_dDatePublished IS NULL) THEN

       RAISE eNullParamenter;

    END IF;



   UPDATE VCM_CHANNEL_TREE_CONTENT
   SET STATUS = DECODE(p_vStatus, 'PUBLISHED', 'P', 'U')
   , DATE_PUBLISHED = p_dDatePublished
   WHERE ID_VCM_CONTENT_SHIFT = p_cIdVcmContentShift;

   UPDATE VCM_CONTENT C
      SET DATE_PUBLISHED = p_dDatePublished
    WHERE ID_VCM_CONTENT_SHIFT = p_cIdVcmContentShift;

    RETURN 1; -- OK

    EXCEPTION
      WHEN eNullParamenter THEN
        RETURN 0; -- NOT OK
      WHEN OTHERS THEN
        RETURN SQLCODE;

END fn_Update_Date_Published;

--==============================================================================

FUNCTION fn_Delete_Channel_Tree_Content(p_cIdVcmChannelTree IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CHANNEL_TREE%TYPE,
                                        p_cIdVcmContent IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CONTENT%TYPE
                                     ) RETURN NUMBER AS
    eNullParamenter EXCEPTION;
BEGIN

    IF(p_cIdVcmChannelTree IS NULL OR p_cIdVcmContent IS NULL) THEN

       RAISE eNullParamenter;

    END IF;

    DELETE FROM VCM_CHANNEL_TREE_CONTENT
    WHERE ID_VCM_CHANNEL_TREE = p_cIdVcmChannelTree
    AND ID_VCM_CONTENT = p_cIdVcmContent;

    RETURN 1; -- OK

    EXCEPTION
      WHEN eNullParamenter THEN
        RETURN 0; -- NOT OK
      WHEN OTHERS THEN
        RETURN SQLCODE;

END fn_Delete_Channel_Tree_Content;

--==============================================================================

PROCEDURE pr_List_Last_News_Corrections(p_crCursor OUT PKG_VCMCONT_UTIL.cRefCursor,
                                        p_vIdVcmChannel IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL%TYPE,
                                        p_vRecursiveChannels IN varchar2,
                                        p_nLimitFrom in number,
                                        p_nLimitTo in number,
                                        p_ExibitionDate in varchar2 default 'Y') IS
   lv_account_plan   vcm_channel_tree.account_plan%type;
   lv_level          vcm_channel_tree.level%type;
   ln_LimitTo        number default p_nLimitTo;
   vNlsSortOld       VARCHAR2(40);
BEGIN

  SELECT VALUE
    INTO vNlsSortOld
    FROM NLS_SESSION_PARAMETERS
   WHERE PARAMETER = 'NLS_SORT';

  IF (vNlsSortOld <> 'BINARY') THEN
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_SORT = ''BINARY'' ';
  END IF;

  -- valida intervalo (limite maximo 4000)
  IF ( ln_LimitTo >= 4001 ) THEN
    ln_LimitTo := 4000;
  END IF;

  IF (p_vRecursiveChannels != 'Y') THEN -- apenas canal informado

      if (p_ExibitionDate = 'Y') then
        open p_crCursor for
          select d.id_vcm_content, d.name, d.date_published, d.type from (
            select ROWNUM rnum, c.*
              from (Select distinct a.*
                      from (select /*+ First_rows(1000)  */
                                   ctc.id_vcm_content, ctc.name, ctc.date_published, decode(ctc.id_vcm_object_type,'5a124e75b5419110VgnVCM1000005801010a____','C','N') type
                              from vcm_channel_tree_content ctc
                             where ctc.id_vcm_channel_tree = p_vIdVcmChannel
                               and ((ctc.id_vcm_object_type = '5a124e75b5419110VgnVCM1000005801010a____')
                                     or (ctc.id_vcm_object_type = 'ca4a4e75b5419110VgnVCM1000005801010a____'
                                          and exists (Select 1 from atomo_vgn_news news where news.exibition_date = 'Y' and ctc.id_vcm_content_shift = news.id_news))) -- e a noticia tem exibition date = Y
                               and date_published between current_date - 150 and current_date
                             order by ctc.id_vcm_channel_tree, date_published desc
                           ) a
                     where rownum <= ln_LimitTo*3
                     order by date_published desc) c
            )d
            where d.rnum <= ln_LimitTo and d.rnum >= p_nLimitFrom;
      else
        open p_crCursor for
          select d.id_vcm_content, d.name, d.date_published, d.type from (
            select ROWNUM rnum, c.*
              from (Select distinct a.*
                      from (select /*+ First_rows(1000)  */
                                   ctc.id_vcm_content, ctc.name, ctc.date_published, decode(ctc.id_vcm_object_type,'5a124e75b5419110VgnVCM1000005801010a____','C','N') type
                              from vcm_channel_tree_content ctc
                             where ctc.id_vcm_channel_tree = p_vIdVcmChannel
                               and ((ctc.id_vcm_object_type = 'ca4a4e75b5419110VgnVCM1000005801010a____'
                                          and exists (Select 1 from atomo_vgn_news news where (news.exibition_date = 'N' or news.exibition_date is null) and ctc.id_vcm_content_shift = news.id_news))) -- e a noticia tem exibition date = N ou nulo
                               and date_published between current_date - 150 and current_date
                             order by ctc.id_vcm_channel_tree, date_published desc
                           ) a
                     where rownum <= ln_LimitTo*3
                     order by date_published desc) c
            )d
            where d.rnum <= ln_LimitTo and d.rnum >= p_nLimitFrom;
      end if;
  ELSE -- Canal informado + filhos (recursivo)
    -- obtem o account plan do canal
    select account_plan, "LEVEL"
      into lv_account_plan, lv_level
      from vcm_channel_tree
     where id_vcm_channel_tree = p_vIdVcmChannel;

      if (p_ExibitionDate = 'Y') then
        open p_crCursor for
          select d.id_vcm_content, d.name, d.date_published, d.type from (
            select ROWNUM rnum, c.*
              from (Select distinct a.*
                      from (select /*+ First_rows(1000)  */
                                   ctc.id_vcm_content, ctc.name, ctc.date_published, decode(ctc.id_vcm_object_type,'5a124e75b5419110VgnVCM1000005801010a____','C','N') type
                              from vcm_channel_tree_content ctc
                             where SUBSTR(F_VCMCONT_ACCOUNT_PLAN(CTC.ACCOUNT_PLAN,lv_level),1,50) = lv_account_plan
                               and ((ctc.id_vcm_object_type = '5a124e75b5419110VgnVCM1000005801010a____')
                                     or (ctc.id_vcm_object_type = 'ca4a4e75b5419110VgnVCM1000005801010a____'
                                          and exists (Select 1 from atomo_vgn_news news where news.exibition_date = 'Y' and ctc.id_vcm_content_shift = news.id_news)))
                               and date_published between current_date - 150 and current_date
                             --order by SUBSTR(F_VCMCONT_ACCOUNT_PLAN(CTC.ACCOUNT_PLAN,lv_level),1,50),date_published DESC
                            ) a
                     where rownum <= ln_LimitTo*3
                     order by date_published desc) c
            )d
            where d.rnum <= ln_LimitTo and d.rnum >= p_nLimitFrom;
      else
        open p_crCursor for
          select d.id_vcm_content, d.name, d.date_published, d.type from (
            select ROWNUM rnum, c.*
              from (Select distinct a.*
                      from (select /*+ First_rows(1000)  */
                                   ctc.id_vcm_content, ctc.name, ctc.date_published, decode(ctc.id_vcm_object_type,'5a124e75b5419110VgnVCM1000005801010a____','C','N') type
                              from vcm_channel_tree_content ctc
                             where SUBSTR(F_VCMCONT_ACCOUNT_PLAN(CTC.ACCOUNT_PLAN,lv_level),1,50) = lv_account_plan
                               and ((ctc.id_vcm_object_type = 'ca4a4e75b5419110VgnVCM1000005801010a____'
                                          and exists (Select 1 from atomo_vgn_news news where (news.exibition_date = 'N' or news.exibition_date is null) and ctc.id_vcm_content_shift = news.id_news)))
                               and date_published between current_date - 150 and current_date
                             --order by SUBSTR(F_VCMCONT_ACCOUNT_PLAN(CTC.ACCOUNT_PLAN,lv_level),1,50),date_published DESC
                           ) a
                     where rownum <= ln_LimitTo*3
                     order by date_published desc) c
            )d
            where d.rnum <= ln_LimitTo and d.rnum >= p_nLimitFrom;
      end if;

  END IF;

  IF (vNlsSortOld <> 'BINARY') THEN
    EXECUTE IMMEDIATE
    'ALTER SESSION SET NLS_SORT = ''' || vNlsSortOld || '''';
  END IF;

    EXCEPTION
          WHEN OTHERS THEN
              IF (vNlsSortOld <> 'BINARY') THEN
                EXECUTE IMMEDIATE
                'ALTER SESSION SET NLS_SORT = ''' || vNlsSortOld || '''';
              END IF;
END pr_list_last_news_corrections;

--==============================================================================

PROCEDURE pr_List_Last_Galleries(p_crCursor OUT PKG_VCMCONT_UTIL.cRefCursor,
                                 p_vIdVcmChannel IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL%TYPE,
                                 p_vRecursiveChannels IN varchar2,
                                 p_nLimitFrom in number,
                                 p_nLimitTo in number,
                                 p_Extended_Photos in varchar2 default 'Y') IS
   lv_account_plan   vcm_channel_tree.account_plan%type;
   lv_level          vcm_channel_tree.level%type;
   ln_LimitTo        number default p_nLimitTo;
   lv_sql            varchar2(6000);
   vNlsSortOld       VARCHAR2(40);
BEGIN

  SELECT VALUE
    INTO vNlsSortOld
    FROM NLS_SESSION_PARAMETERS
   WHERE PARAMETER = 'NLS_SORT';

  IF (vNlsSortOld <> 'BINARY') THEN
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_SORT = ''BINARY'' ';
  END IF;

  IF (p_vRecursiveChannels = 'Y') THEN
    -- obtem o account plan do canal
    select account_plan, "LEVEL"
      into lv_account_plan, lv_level
      from vcm_channel_tree
     where id_vcm_channel_tree = p_vIdVcmChannel;
  END IF;

  lv_sql := ' select d.id_vcm_content, d.id_vcm_content_shift, d.name, d.date_published from (
                select ROWNUM rnum, c.*
                  from (Select distinct a.*
                          from (select /*+ First_rows(1000)  */
                                       ctc.id_vcm_content, ctc.id_vcm_content_shift, ctc.name, ctc.date_published
                                  from vcm_channel_tree_content ctc
                                 where ';

  IF (p_vRecursiveChannels = 'Y') THEN
     lv_sql := lv_sql || ' SUBSTR(F_VCMCONT_ACCOUNT_PLAN(CTC.ACCOUNT_PLAN,'|| lv_level ||'),1,50) = '''|| lv_account_plan ||'''';
  ELSE
     lv_sql := lv_sql || ' ctc.id_vcm_channel_tree = '''||p_vIdVcmChannel|| '''';
  END IF;

  lv_sql := lv_sql ||'  and ctc.id_vcm_object_type = ''98e44e75b5419110VgnVCM1000005801010a____'' ' ;

  IF (p_Extended_Photos = 'Y') THEN
     lv_sql := lv_sql || ' and exists ( select 1 from atomo_vgn_gallery gal where gal.id_gallery = ctc.id_vcm_content_shift and gal.expanded_photos = ''Y'' ) ';
  END IF;

  IF (p_vRecursiveChannels = 'Y') THEN
    lv_sql := lv_sql || ' order by SUBSTR(F_VCMCONT_ACCOUNT_PLAN(CTC.ACCOUNT_PLAN,'|| lv_level ||'),1,50),date_published DESC, ctc.id_vcm_object_type ';
  ELSE
    lv_sql := lv_sql || ' order by date_published desc ';
  END IF;

  lv_sql := lv_sql || '  ) a
                     where rownum <= :limit_to *5
                     order by date_published desc) c
            )d
            where d.rnum <= :limit_to and d.rnum >= :limit_from ';

  open p_crCursor for lv_sql using ln_LimitTo, ln_LimitTo, p_nLimitFrom;


  IF (vNlsSortOld <> 'BINARY') THEN
    EXECUTE IMMEDIATE
    'ALTER SESSION SET NLS_SORT = ''' || vNlsSortOld || '''';
  END IF;

    EXCEPTION
          WHEN OTHERS THEN
              IF (vNlsSortOld <> 'BINARY') THEN
                EXECUTE IMMEDIATE
                'ALTER SESSION SET NLS_SORT = ''' || vNlsSortOld || '''';
              END IF;
END pr_List_Last_Galleries;

--==============================================================================

PROCEDURE pr_List_Sources(p_cRefCursor OUT PKG_VCMCONT_UTIL.cRefCursor) IS

    vError VARCHAR2(100);

BEGIN

    OPEN p_cRefCursor FOR
        SELECT VGMAP.RECORDID ID_SOURCE, AVS.NAME
        FROM ATOMO_VGN_SOURCE AVS,
             VCMSYS.VGNASMOMAP VGMAP
        WHERE AVS.ID_SOURCE = VGMAP.KEYSTRING1
        ORDER BY AVS.NAME;

EXCEPTION

    WHEN OTHERS THEN

        IF(p_cRefCursor % ISOPEN) THEN
          CLOSE p_cRefCursor;
        END IF;
        vError := SQLERRM;
        RAISE_APPLICATION_ERROR(-20002, vError);

END pr_List_Sources;

--==============================================================================

PROCEDURE pr_List_Auto_Highlights(p_cRefCursor OUT PKG_VCMCONT_UTIL.cRefCursor,
                                  p_vIdVcmChannel IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL%TYPE,
                                  p_nTotal in number,
                                  p_vRecursiveChannels IN varchar2 default 'Y') IS
   vError   VARCHAR2(100);
   lv_level vcm_channel_tree.level%type;
   lv_account_plan   vcm_channel_tree.account_plan%type;
   lv_sql   varchar2(4000);
BEGIN

  if p_vRecursiveChannels != 'Y' then
    OPEN p_cRefCursor FOR
        select a.id_vcm_content
          from (
            select ctc.id_vcm_content
              from vcm_channel_tree_content ctc
             where ctc.id_vcm_channel_tree = p_vIdVcmChannel
               and ctc.id_vcm_object_type  = 'ca4a4e75b5419110VgnVCM1000005801010a____'
               and exists ( select 1 from atomo_vgn_news_media vnm where vnm.fk_atomo_vgn_news_id_news = ctc.id_vcm_content_shift )
               and exists (Select 1
                             from atomo_vgn_news news
                            where news.exibition_date = 'Y'
                              and ctc.id_vcm_content_shift = news.id_news)
            order by ctc.date_published desc
            )a
         where rownum <= p_nTotal;
  else -- Canal informado + filhos (recursivo)
    -- obtem o account plan do canal
    select account_plan, "LEVEL"
      into lv_account_plan, lv_level
      from vcm_channel_tree
     where id_vcm_channel_tree = p_vIdVcmChannel;

     lv_sql := 'select d.id_vcm_content
                  from (select ROWNUM rnum, c.*
                          from (select distinct a.*
                                  from (
                                        select /*+ First_rows(1000)  */
                                         ctc.id_vcm_content, ctc.date_published
                                          from vcm_channel_tree_content ctc
                                         where SUBSTR(F_VCMCONT_ACCOUNT_PLAN(CTC.ACCOUNT_PLAN,'|| lv_level ||'),1,50) = :lv_account_plan
                                           and ctc.id_vcm_object_type =''ca4a4e75b5419110VgnVCM1000005801010a____''
                                           and date_published between current_date - 150 and current_date
                                           and exists (select 1
                                                        from atomo_vgn_news_media vnm
                                                       where vnm.fk_atomo_vgn_news_id_news =
                                                             ctc.id_vcm_content_shift)
                                           and exists (Select 1
                                                          from atomo_vgn_news news
                                                         where news.exibition_date = ''Y''
                                                           and ctc.id_vcm_content_shift = news.id_news)) a
                                 where rownum <= :p_nTotal * 3
                                 order by date_published desc) c) d
                 where rnum <= :p_nTotal ';

    OPEN p_cRefCursor FOR lv_sql using lv_account_plan, p_nTotal, p_nTotal;

  end if;

EXCEPTION

    WHEN OTHERS THEN

        IF(p_cRefCursor % ISOPEN) THEN
          CLOSE p_cRefCursor;
        END IF;
        vError := SQLERRM;
        RAISE_APPLICATION_ERROR(-20002, vError);

END pr_List_Auto_Highlights;

--==============================================================================

PROCEDURE pr_Get_Full_Path(p_cRefCursor OUT PKG_VCMCONT_UTIL.cRefCursor,
                          p_vIdVcmChannel IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL%TYPE) IS
    vError VARCHAR2(100);

BEGIN

    open p_cRefCursor for
      select '/'||site.name||vct.path
        from vcm_channel_tree vct,
             vcmsys.vgnassite site
       where vct.id_vcm_channel = p_vIdVcmChannel
         and vct.id_site = site.id;

EXCEPTION

    WHEN OTHERS THEN

        IF(p_cRefCursor % ISOPEN) THEN
          CLOSE p_cRefCursor;
        END IF;
        vError := SQLERRM;
        RAISE_APPLICATION_ERROR(-20002, vError);

END pr_Get_Full_Path;

--==============================================================================

PROCEDURE pr_Get_ChannelId(p_cRefCursor OUT PKG_VCMCONT_UTIL.cRefCursor,
                          p_fullPath IN VCM_CHANNEL_TREE.PATH%TYPE ) IS
    vError VARCHAR2(100);
    lv_path_aux      vcm_channel_tree.path%type;
    lv_path_channel  vcm_channel_tree.path%type;
    lv_site_name     vcmsys.vgnassite.name%type;
BEGIN

    -- pega o nome do site
    lv_path_aux := substr(p_fullPath,2, length(p_fullPath));
    lv_site_name := substr(lv_path_aux, 1, instr(lv_path_aux,'/')-1);

    -- pega o path do canal
    lv_path_channel := substr(lv_path_aux, instr(lv_path_aux,'/'), length(lv_path_aux));

    open p_cRefCursor for
      select vct.id_vcm_channel
        from vcm_channel_tree vct,
             vcmsys.vgnassite site
       where vct.id_site = site.id
         and vct.path = lv_path_channel
         and site.name = lv_site_name;

EXCEPTION

    WHEN OTHERS THEN

        IF(p_cRefCursor % ISOPEN) THEN
          CLOSE p_cRefCursor;
        END IF;
        vError := SQLERRM;
        RAISE_APPLICATION_ERROR(-20002, vError);

END pr_Get_ChannelId;

END PKG_VCM_MGMT_CHANNEL_CONTENT;
/
