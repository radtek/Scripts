CREATE OR REPLACE PACKAGE PKG_VCM_MGMT_CHANNEL_CONTENT AS

/*
Objetivo: Package com a finalidade de possuir procedures e functions,
          para manipulação de contents e canais publicados.

Histórico de alterações:
06/10/2009 - CB - Criação da Package
*/

FUNCTION fn_Create_Channel_Tree(p_cIdVcmChannelTree IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL_TREE%TYPE) RETURN NUMBER;

FUNCTION fn_Update_Channel_Tree(p_cIdVcmChannelTree IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL_TREE%TYPE) RETURN NUMBER;

FUNCTION fn_Delete_Channel_Tree(p_cIdVcmChannelTree IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL_TREE%TYPE) RETURN NUMBER;

FUNCTION fn_Create_Content(p_cIdVcmContent IN VCM_CONTENT.ID_VCM_CONTENT%TYPE) RETURN NUMBER;

FUNCTION fn_Update_Content(p_cIdVcmContent IN VCM_CONTENT.ID_VCM_CONTENT%TYPE,
                           p_cIdVcmObjectType IN VCM_CONTENT.ID_VCM_OBJECT_TYPE%TYPE
                          ) RETURN NUMBER;

FUNCTION fn_Delete_Content(p_cIdVcmContent IN VCM_CONTENT.ID_VCM_CONTENT%TYPE) RETURN NUMBER;

FUNCTION fn_Create_Channel_Tree_Content(p_cIdVcmChannelTree IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CHANNEL_TREE%TYPE,
                                        p_cIdVcmContent IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CONTENT%TYPE
                                        ) RETURN NUMBER;

FUNCTION fn_Delete_Channel_Tree_Content(p_cIdVcmChannelTree IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CHANNEL_TREE%TYPE,
                                        p_cIdVcmContent IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CONTENT%TYPE
                                       ) RETURN NUMBER;

FUNCTION fn_Get_Channel_Id(p_cIdVcmSite in varchar2,
                          p_cFurlChannel in vcm_channel_tree.furl_channel%type) RETURN VARCHAR2;

PROCEDURE pr_List_Last_News_Corrections(p_crCursor OUT PKG_VCMLIVE_UTIL.cRefCursor,
                                        p_vIdVcmChannel IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL%TYPE,
                                        p_vRecursiveChannels IN varchar2,
                                        p_nLimitFrom in number,
                                        p_nLimitTo in number,
                                        p_ExibitionDate in varchar2 default 'Y');

PROCEDURE pr_List_Last_Galleries(p_crCursor OUT PKG_VCMLIVE_UTIL.cRefCursor,
                                 p_vIdVcmChannel IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL%TYPE,
                                 p_vRecursiveChannels IN varchar2,
                                 p_nLimitFrom in number,
                                 p_nLimitTo in number,
                                 p_Extended_Photos in varchar2 default 'Y');

PROCEDURE pr_List_Auto_Highlights(p_cRefCursor OUT PKG_VCMLIVE_UTIL.cRefCursor,
                                  p_vIdVcmChannel IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL%TYPE,
                                  p_nTotal in number,
                                  p_vRecursiveChannels IN varchar2 default 'Y');

PROCEDURE pr_List_Related_Contents(p_cRefCursor OUT PKG_VCMLIVE_UTIL.cRefCursor,
                                   p_vIdVcmContent IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CONTENT%TYPE,
                                   p_vIdContentType IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_OBJECT_TYPE%TYPE
                                   );
END PKG_VCM_MGMT_CHANNEL_CONTENT;
/
CREATE OR REPLACE PACKAGE BODY PKG_VCM_MGMT_CHANNEL_CONTENT AS

/*
Objetivo: Package com a finalidade de possuir procedures e functions,
          para manipulação de contents e canais publicados.

Histórico de alterações:
06/10/2009 - CB - Criação da Package
*/

OK CONSTANT NUMBER(1) := 1;
NOK CONSTANT NUMBER(1) := 0;

/* Definidas estruturas de dados próprias da package, para evitar ao máximo
   que a mesma compartilhe referências de outros objetos e fique inválida.
*/
TYPE cRefCursor IS REF CURSOR;

TYPE recordFields IS RECORD (
  FirstDatePublished DATE,
  DatePublished DATE
  );

TYPE ListRecordFields IS TABLE OF recordFields;


--==============================================================================
/*
FUNCTION fn_get_Gmt RETURN NUMBER IS
BEGIN

    RETURN  TO_NUMBER(SUBSTR(SESSIONTIMEZONE, 1, 3));

END fn_get_Gmt;
*/

--==============================================================================

FUNCTION fn_Get_Data(p_cIdVcmContentShift IN VCM_CONTENT.ID_VCM_CONTENT_SHIFT%TYPE,
                      p_cVcmObjectType IN VCM_CONTENT.ID_VCM_OBJECT_TYPE%TYPE) RETURN ListRecordFields AS

    vQuery VARCHAR2(200);
    crCursor cRefCursor;
    listRecords ListRecordFields;
BEGIN


    SELECT 'SELECT '||(CASE WHEN INSTR(VOBJ.NAME, 'DSX-MEDIA', 1, 1) > 0
                       THEN 'TO_DATE(''01/01/1900'',''DD/MM/YYYY'') DATE_FIRST_PUBLISHED, '||
                            'TO_DATE(''01/01/1900'',''DD/MM/YYYY'') DATE_PUBLISHED  '
                       ELSE 'DATE_FIRST_PUBLISHED, '||
                            'DATE_PUBLISHED  '
                       END)||
           'FROM '||SUBSTR(VD.COLUMNSOURCE, 1, INSTR(VD.COLUMNSOURCE, '.', 1, 1)-1)||' WHERE '||SUBSTR(VD.COLUMNSOURCE, INSTR(VD.COLUMNSOURCE, '.', 1, 1)+1, LENGTH(VD.COLUMNSOURCE))||' = '
    INTO vQuery
    FROM VGNASRELATION VR,
         VGNASATTRDEF VD,
         VGNASOBJECTTYPE VOBJ
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

FUNCTION fn_Create_Channel_Tree(p_cIdVcmChannelTree IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL_TREE%TYPE) RETURN NUMBER AS
BEGIN

    INSERT INTO VCM_CHANNEL_TREE
    SELECT VCT.*
    FROM VCMMGMT.VCM_CHANNEL_TREE VCT
    WHERE VCT.ID_VCM_CHANNEL_TREE = p_cIdVcmChannelTree;

    RETURN OK;

    EXCEPTION
      WHEN OTHERS THEN
        RETURN NOK;

END fn_Create_Channel_Tree;

--==============================================================================

FUNCTION fn_Update_Channel_Tree(p_cIdVcmChannelTree IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL_TREE%TYPE) RETURN NUMBER AS
BEGIN

    UPDATE VCM_CHANNEL_TREE
    SET (ID_VCM_CHANNEL_TREE_PARENT,
         ACCOUNT_PLAN,
         NAME,
         DESCRIPTION,
         IS_ACTIVE,
         ORDER_ASSIBLING,
         ID_PAGE,
         ID_SITE,
         DATE_UPDATED,
         PATH,
         "LEVEL",
         ID_VCM_CHANNEL,
         FURL_CHANNEL
        ) =
        (SELECT VVCT.ID_VCM_CHANNEL_TREE_PARENT,
                 VVCT.ACCOUNT_PLAN,
                 VVCT.NAME,
                 VVCT.DESCRIPTION,
                 VVCT.IS_ACTIVE,
                 VVCT.ORDER_ASSIBLING,
                 VVCT.ID_PAGE,
                 VVCT.ID_SITE,
                 VVCT.DATE_UPDATED,
                 VVCT.PATH,
                 VVCT."LEVEL",
                 VVCT.ID_VCM_CHANNEL,
                 VVCT.FURL_CHANNEL
         FROM VCMMGMT.VCM_CHANNEL_TREE VVCT
         WHERE VVCT.ID_VCM_CHANNEL_TREE = p_cIdVcmChannelTree
        )
    WHERE ID_VCM_CHANNEL_TREE = p_cIdVcmChannelTree;

    RETURN OK;

    EXCEPTION
      WHEN OTHERS THEN
        RETURN NOK;

END fn_Update_Channel_Tree;

--==============================================================================

FUNCTION fn_Delete_Channel_Tree(p_cIdVcmChannelTree IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL_TREE%TYPE) RETURN NUMBER AS
BEGIN

    DELETE FROM VCM_CHANNEL_TREE
    WHERE ID_VCM_CHANNEL_TREE = p_cIdVcmChannelTree;

    RETURN OK;

    EXCEPTION
      WHEN OTHERS THEN
        RETURN NOK;

END fn_Delete_Channel_Tree;

--==============================================================================

FUNCTION fn_Create_Content(p_cIdVcmContent IN VCM_CONTENT.ID_VCM_CONTENT%TYPE) RETURN NUMBER AS

    lRecords ListRecordFields;
    rFields recordFields;
    cIdVcmContentShift VCM_CONTENT.ID_VCM_CONTENT_SHIFT%TYPE;
    cIdVcmObjectType VCM_CONTENT.ID_VCM_OBJECT_TYPE%TYPE;
   -- nGmt NUMBER(2);
BEGIN

    SELECT ID_VCM_CONTENT_SHIFT,
           ID_VCM_OBJECT_TYPE
    INTO cIdVcmContentShift,
         cIdVcmObjectType
    FROM VCMMGMT.VCM_CONTENT
    WHERE ID_VCM_CONTENT = p_cIdVcmContent;

    lRecords := fn_Get_Data(cIdVcmContentShift, cIdVcmObjectType);

    IF(lRecords IS NOT NULL)THEN

        IF(lRecords.EXISTS(1) = TRUE) THEN

            rFields := lRecords(lRecords.FIRST);

            --nGmt := fn_get_Gmt;

            INSERT INTO VCM_CONTENT
                  (ID_VCM_CONTENT,
                  ID_VCM_OBJECT_TYPE,
                  ID_VCM_CONTENT_SHIFT,
                  NAME,
                  STATUS,
                  IS_MODIFIED,
                  LOGICAL_PATH,
                  MOD_COUNT,
                  DATE_CREATED,
                  DATE_UPDATED,
                  FIRST_DATE_PUBLISHED,
                  ID_LANGUAGE)
            SELECT ID_VCM_CONTENT,
                   ID_VCM_OBJECT_TYPE,
                   ID_VCM_CONTENT_SHIFT,
                   NAME,
                   STATUS,
                   IS_MODIFIED,
                   LOGICAL_PATH,
                   MOD_COUNT,
                   DATE_CREATED,
                   DATE_UPDATED,
                   rFields.FirstDatePublished,
                   ID_LANGUAGE
            FROM VCMMGMT.VCM_CONTENT
            WHERE ID_VCM_CONTENT = p_cIdVcmContent;

        END IF;

    END IF;

    RETURN OK;

    EXCEPTION
      WHEN OTHERS THEN
        RETURN NOK;

END fn_Create_Content;

--==============================================================================

FUNCTION fn_Update_Channel_Tree_Content(p_cIdVcmContent IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CONTENT%TYPE,
                                        p_cIdVcmObjectType IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_OBJECT_TYPE%TYPE,
                                        p_dDatePublished IN VCM_CHANNEL_TREE_CONTENT.DATE_PUBLISHED%TYPE
                                        ) RETURN NUMBER AS

    --nGmt NUMBER(2);
BEGIN

    --nGmt := fn_get_Gmt;

    UPDATE VCM_CHANNEL_TREE_CONTENT
    SET (NAME,
         ID_LANGUAGE,
         FURL_CONTENT_TITLE,
         DATE_PUBLISHED
        ) =
        (SELECT DISTINCT VCTC.NAME,
                VCTC.ID_LANGUAGE,
                VCTC.FURL_CONTENT_TITLE,
                p_dDatePublished
         FROM VCMMGMT.VCM_CHANNEL_TREE_CONTENT VCTC
         WHERE VCTC.ID_VCM_CONTENT = p_cIdVcmContent
         AND VCTC.ID_VCM_OBJECT_TYPE = p_cIdVcmObjectType
        )
    WHERE ID_VCM_CONTENT = p_cIdVcmContent
    AND ID_VCM_OBJECT_TYPE = p_cIdVcmObjectType;

    RETURN OK;

    EXCEPTION
      WHEN OTHERS THEN
        RETURN NOK;

END fn_Update_Channel_Tree_Content;


--==============================================================================

FUNCTION fn_Update_Content(p_cIdVcmContent IN VCM_CONTENT.ID_VCM_CONTENT%TYPE,
                           p_cIdVcmObjectType IN VCM_CONTENT.ID_VCM_OBJECT_TYPE%TYPE
                          ) RETURN NUMBER AS

    lRecords ListRecordFields;
    rFields recordFields;
    cIdVcmContentShift VCM_CHANNEL_TREE_CONTENT.ID_VCM_CONTENT_SHIFT%TYPE;
    nReturn NUMBER(1);
    --nGmt NUMBER(2);
BEGIN

    SELECT ID_VCM_CONTENT_SHIFT
    INTO cIdVcmContentShift
    FROM VCMMGMT.VCM_CONTENT
    WHERE ID_VCM_CONTENT = p_cIdVcmContent;

    lRecords := fn_Get_Data(cIdVcmContentShift, p_cIdVcmObjectType);

    IF(lRecords IS NOT NULL)THEN

        IF(lRecords.EXISTS(1) = TRUE) THEN

            rFields := lRecords(lRecords.FIRST);

            --nGmt := fn_get_Gmt;

            UPDATE VCM_CONTENT
            SET (ID_VCM_OBJECT_TYPE,
                 ID_VCM_CONTENT_SHIFT,
                 NAME,
                 STATUS,
                 IS_MODIFIED,
                 LOGICAL_PATH,
                 MOD_COUNT,
                 DATE_UPDATED,
                 FIRST_DATE_PUBLISHED,
                 ID_LANGUAGE
                ) =
                (SELECT VVC.ID_VCM_OBJECT_TYPE,
                        VVC.ID_VCM_CONTENT_SHIFT,
                        VVC.NAME,
                        VVC.STATUS,
                        VVC.IS_MODIFIED,
                        VVC.LOGICAL_PATH,
                        VVC.MOD_COUNT,
                        VVC.DATE_UPDATED,
                        rFields.FirstDatePublished,
                        VVC.ID_LANGUAGE
                 FROM VCMMGMT.VCM_CONTENT VVC
                 WHERE VVC.ID_VCM_CONTENT = p_cIdVcmContent
                )
            WHERE ID_VCM_CONTENT = p_cIdVcmContent;

            nReturn := fn_Update_Channel_Tree_Content(p_cIdVcmContent, p_cIdVcmObjectType, current_date);

            lRecords.DELETE;

        END IF;

    END IF;

    RETURN OK;

    EXCEPTION
      WHEN OTHERS THEN
        RETURN NOK;

END fn_Update_Content;

--==============================================================================

FUNCTION fn_Delete_Content(p_cIdVcmContent IN VCM_CONTENT.ID_VCM_CONTENT%TYPE) RETURN NUMBER AS
BEGIN

    DELETE FROM VCM_CONTENT
    WHERE ID_VCM_CONTENT = p_cIdVcmContent;

    RETURN OK;

    EXCEPTION
      WHEN OTHERS THEN
        RETURN NOK;

END fn_Delete_Content;

--==============================================================================

FUNCTION fn_Create_Channel_Tree_Content(p_cIdVcmChannelTree IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CHANNEL_TREE%TYPE,
                                        p_cIdVcmContent IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CONTENT%TYPE
                                        ) RETURN NUMBER AS
    lRecords ListRecordFields;
    rFields recordFields;
    cIdVcmContentShift VCM_CHANNEL_TREE_CONTENT.ID_VCM_CONTENT_SHIFT%TYPE;
    cIdVcmObjectType VCM_CHANNEL_TREE_CONTENT.ID_VCM_OBJECT_TYPE%TYPE;
    --nGmt NUMBER(2);
BEGIN

    SELECT ID_VCM_CONTENT_SHIFT,
           ID_VCM_OBJECT_TYPE
    INTO cIdVcmContentShift,
         cIdVcmObjectType
    FROM VCMMGMT.VCM_CHANNEL_TREE_CONTENT
    WHERE ID_VCM_CHANNEL_TREE = p_cIdVcmChannelTree
    AND ID_VCM_CONTENT = p_cIdVcmContent;

    lRecords := fn_Get_Data(cIdVcmContentShift, cIdVcmObjectType);

    IF(lRecords IS NOT NULL)THEN

        IF(lRecords.EXISTS(1) = TRUE) THEN

            rFields := lRecords(lRecords.FIRST);

            --nGmt := fn_get_Gmt;

            INSERT INTO VCM_CHANNEL_TREE_CONTENT
                  (ID_VCM_CHANNEL_TREE,
                   ID_VCM_CONTENT,
                   ID_VCM_CONTENT_SHIFT,
                   ACCOUNT_PLAN,
                   ID_VCM_OBJECT_TYPE,
                   DATE_CREATED,
                   DATE_PUBLISHED,
                   FIRST_DATE_PUBLISHED,
                   NAME,
                   ID_LANGUAGE,
                   FURL_CONTENT_TITLE)
            SELECT ID_VCM_CHANNEL_TREE,
                   ID_VCM_CONTENT,
                   ID_VCM_CONTENT_SHIFT,
                   ACCOUNT_PLAN,
                   ID_VCM_OBJECT_TYPE,
                   DATE_CREATED,
                   current_date, --rFields.DatePublished,
                   rFields.FirstDatePublished,
                   NAME,
                   ID_LANGUAGE,
                   FURL_CONTENT_TITLE
            FROM VCMMGMT.VCM_CHANNEL_TREE_CONTENT
            WHERE ID_VCM_CHANNEL_TREE = p_cIdVcmChannelTree
            AND ID_VCM_CONTENT = p_cIdVcmContent;

            lRecords.DELETE;

        END IF;

    END IF;

    RETURN OK;

    EXCEPTION
      WHEN OTHERS THEN
        RETURN NOK;

END fn_Create_Channel_Tree_Content;

--==============================================================================

FUNCTION fn_Delete_Channel_Tree_Content(p_cIdVcmChannelTree IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CHANNEL_TREE%TYPE,
                                        p_cIdVcmContent IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CONTENT%TYPE
                                       ) RETURN NUMBER AS
BEGIN

    DELETE FROM VCM_CHANNEL_TREE_CONTENT
    WHERE ID_VCM_CHANNEL_TREE = p_cIdVcmChannelTree
    AND ID_VCM_CONTENT = p_cIdVcmContent;

    RETURN OK;

    EXCEPTION
      WHEN OTHERS THEN
        RETURN NOK;

END fn_Delete_Channel_Tree_Content;

--==============================================================================

FUNCTION fn_Get_Channel_Id(p_cIdVcmSite in varchar2,
                          p_cFurlChannel in vcm_channel_tree.furl_channel%type) RETURN VARCHAR2 IS
  vIdChannel vcm_channel_tree.id_vcm_channel%type;
BEGIN

   SELECT VCT.ID_VCM_CHANNEL
     INTO vIdChannel
     FROM VCM_CHANNEL_TREE VCT
    WHERE VCT.ID_SITE = p_cIdVcmSite
      AND VCT.FURL_CHANNEL = p_cFurlChannel;


   return(vIdChannel);
end fn_Get_Channel_Id;

--==============================================================================

PROCEDURE pr_List_Last_News_Corrections(p_crCursor OUT PKG_VCMLIVE_UTIL.cRefCursor,
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
          select d.id_vcm_content, d.name, d.first_date_published, d.type from (
            select ROWNUM rnum, c.*
              from (Select distinct a.*
                      from (select /*+ First_rows(1000)  */
                                   ctc.id_vcm_content, ctc.name, ctc.first_date_published, decode(ctc.id_vcm_object_type,'5a124e75b5419110VgnVCM1000005801010a____','C','N') type
                              from vcm_channel_tree_content ctc
                             where ctc.id_vcm_channel_tree = p_vIdVcmChannel
                               and ((ctc.id_vcm_object_type = '5a124e75b5419110VgnVCM1000005801010a____')
                                     or (ctc.id_vcm_object_type = 'ca4a4e75b5419110VgnVCM1000005801010a____'
                                          and exists (Select 1 from atomo_vgn_news news where news.exibition_date = 'Y' and ctc.id_vcm_content_shift = news.id_news))) -- e a noticia tem exibition date = Y
                               and first_date_published between current_date - 150 and current_date
                             --order by ctc.id_vcm_channel_tree, first_date_published desc
                           ) a
                     where rownum <= ln_LimitTo*3
                     order by first_date_published desc) c
            )d
            where d.rnum <= ln_LimitTo and d.rnum >= p_nLimitFrom;
      else
        open p_crCursor for
          select d.id_vcm_content, d.name, d.first_date_published, d.type from (
            select ROWNUM rnum, c.*
              from (Select distinct a.*
                      from (select /*+ First_rows(1000)  */
                                   ctc.id_vcm_content, ctc.name, ctc.first_date_published, decode(ctc.id_vcm_object_type,'5a124e75b5419110VgnVCM1000005801010a____','C','N') type
                              from vcm_channel_tree_content ctc
                             where ctc.id_vcm_channel_tree = p_vIdVcmChannel
                               and ((ctc.id_vcm_object_type = 'ca4a4e75b5419110VgnVCM1000005801010a____'
                                          and exists (Select 1 from atomo_vgn_news news where (news.exibition_date = 'N' or news.exibition_date is null) and ctc.id_vcm_content_shift = news.id_news))) -- e a noticia tem exibition date = N ou nulo
                               and first_date_published between current_date - 150 and current_date
                             --order by ctc.id_vcm_channel_tree, first_date_published desc
                           ) a
                     where rownum <= ln_LimitTo*3
                     order by first_date_published desc) c
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
          select d.id_vcm_content, d.name, d.first_date_published, d.type from (
            select ROWNUM rnum, c.*
              from (Select distinct a.*
                      from (select /*+ First_rows(1000)  */
                                   ctc.id_vcm_content, ctc.name, ctc.first_date_published, decode(ctc.id_vcm_object_type,'5a124e75b5419110VgnVCM1000005801010a____','C','N') type
                              from vcm_channel_tree_content ctc
                             where SUBSTR(F_VCMCONT_ACCOUNT_PLAN(CTC.ACCOUNT_PLAN,lv_level),1,50) = lv_account_plan
                               and ((ctc.id_vcm_object_type = '5a124e75b5419110VgnVCM1000005801010a____')
                                     or (ctc.id_vcm_object_type = 'ca4a4e75b5419110VgnVCM1000005801010a____'
                                          and exists (Select 1 from atomo_vgn_news news where news.exibition_date = 'Y' and ctc.id_vcm_content_shift = news.id_news)))
                               and first_date_published between current_date - 150 and current_date
                             --order by SUBSTR(F_VCMCONT_ACCOUNT_PLAN(CTC.ACCOUNT_PLAN,lv_level),1,50),FIRST_DATE_PUBLISHED DESC
                            ) a
                     where rownum <= ln_LimitTo*3
                     order by first_date_published desc) c
            )d
            where d.rnum <= ln_LimitTo and d.rnum >= p_nLimitFrom;
      else
        open p_crCursor for
          select d.id_vcm_content, d.name, d.first_date_published, d.type from (
            select ROWNUM rnum, c.*
              from (Select distinct a.*
                      from (select /*+ First_rows(1000)  */
                                   ctc.id_vcm_content, ctc.name, ctc.first_date_published, decode(ctc.id_vcm_object_type,'5a124e75b5419110VgnVCM1000005801010a____','C','N') type
                              from vcm_channel_tree_content ctc
                             where SUBSTR(F_VCMCONT_ACCOUNT_PLAN(CTC.ACCOUNT_PLAN,lv_level),1,50) = lv_account_plan
                               and ((ctc.id_vcm_object_type = 'ca4a4e75b5419110VgnVCM1000005801010a____'
                                          and exists (Select 1 from atomo_vgn_news news where (news.exibition_date = 'N' or news.exibition_date is null) and ctc.id_vcm_content_shift = news.id_news)))
                               and first_date_published between current_date - 150 and current_date
                             --order by SUBSTR(F_VCMCONT_ACCOUNT_PLAN(CTC.ACCOUNT_PLAN,lv_level),1,50),FIRST_DATE_PUBLISHED DESC
                           ) a
                     where rownum <= ln_LimitTo*3
                     order by first_date_published desc) c
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

PROCEDURE pr_List_Last_Galleries(p_crCursor OUT PKG_VCMLIVE_UTIL.cRefCursor,
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

  lv_sql := ' select d.id_vcm_content, d.id_vcm_content_shift, d.name, d.first_date_published from (
                select ROWNUM rnum, c.*
                  from (Select distinct a.*
                          from (select /*+ First_rows(1000)  */
                                       ctc.id_vcm_content, ctc.id_vcm_content_shift, ctc.name, ctc.first_date_published
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
    lv_sql := lv_sql || ' order by SUBSTR(F_VCMCONT_ACCOUNT_PLAN(CTC.ACCOUNT_PLAN,'|| lv_level ||'),1,50),first_date_published DESC, ctc.id_vcm_object_type ';
  ELSE
    lv_sql := lv_sql || ' order by first_date_published desc ';
  END IF;

  lv_sql := lv_sql || '  ) a
                     where rownum <= :limit_to *5
                     order by first_date_published desc ) c
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

PROCEDURE pr_List_Auto_Highlights(p_cRefCursor OUT PKG_VCMLIVE_UTIL.cRefCursor,
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
            order by ctc.first_date_published desc
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
                                         ctc.id_vcm_content, ctc.first_date_published
                                          from vcm_channel_tree_content ctc
                                         where SUBSTR(F_VCMCONT_ACCOUNT_PLAN(CTC.ACCOUNT_PLAN,'|| lv_level ||'),1,50) = :lv_account_plan
                                           and ctc.id_vcm_object_type =''ca4a4e75b5419110VgnVCM1000005801010a____''
                                           and first_date_published between current_date - 150 and current_date                         
                                           and exists (select 1
                                                        from atomo_vgn_news_media vnm
                                                       where vnm.fk_atomo_vgn_news_id_news =
                                                             ctc.id_vcm_content_shift)
                                           and exists (Select 1
                                                          from atomo_vgn_news news
                                                         where news.exibition_date = ''Y''
                                                           and ctc.id_vcm_content_shift = news.id_news)) a
                                 where rownum <= :p_nTotal * 3
                                 order by first_date_published desc) c) d
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

PROCEDURE pr_List_Related_Contents(p_cRefCursor OUT PKG_VCMLIVE_UTIL.cRefCursor,
                                   p_vIdVcmContent IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CONTENT%TYPE,
                                   p_vIdContentType IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_OBJECT_TYPE%TYPE
                                   ) IS
    vError VARCHAR2(100);

   vNlsSortOld       VARCHAR2(40);
BEGIN

  SELECT VALUE
    INTO vNlsSortOld
    FROM NLS_SESSION_PARAMETERS
   WHERE PARAMETER = 'NLS_SORT';

    if (vNlsSortOld <> 'BINARY') then
      EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_SORT = ''BINARY'' ';
    end if;

    -- noticias
    if (p_vIdContentType = 'ca4a4e75b5419110VgnVCM1000005801010a____') then
       OPEN p_cRefCursor FOR
           select
                 c_rel.id_vcm_object_type,
                 c_rel.id_vcm_content,
                 av.id_mib
            from
                 vcm_content                c, -- conteudo principal
                 vcm_content                c_rel, -- conteudos relacionados
                 atomo_vgn_news_rel_content rel, -- relator
                 atomo_vgn_audio_video      av -- audio e video
           where
                 rel.fk_atomo_vgn_news_id_news = c.id_vcm_content_shift
             and c.id_vcm_content = p_vIdVcmContent
             and c_rel.id_vcm_content = rel.fk_atomo_vgn_id_rel_content
             and c_rel.id_vcm_content_shift = av.id_audio_video(+)
           order by c_rel.id_vcm_object_type desc, rel.display_order;

    -- galerias
    elsif (p_vIdContentType = '98e44e75b5419110VgnVCM1000005801010a____') then
       OPEN p_cRefCursor FOR
           select
                 c_rel.id_vcm_object_type,
                 c_rel.id_vcm_content,
                 av.id_mib
            from
                 vcm_content                   c, -- conteudo principal
                 vcm_content                   c_rel, -- conteudos relacionados
                 atomo_vgn_gallery_rel_content rel, -- relator
                 atomo_vgn_audio_video         av -- audio e video
           where
                 rel.fk_atomo_vgn_gallery_id_galler = c.id_vcm_content_shift
             and c.id_vcm_content = p_vIdVcmContent
             and c_rel.id_vcm_content = rel.fk_atomo_vgn_id_rel_content
             and c_rel.id_vcm_content_shift = av.id_audio_video(+)
           order by c_rel.id_vcm_object_type desc, rel.display_order;
    end if;

    if (vNlsSortOld <> 'BINARY') then
      EXECUTE IMMEDIATE
      'ALTER SESSION SET NLS_SORT = ''' || vNlsSortOld || '''';
    end if;

EXCEPTION

    WHEN OTHERS THEN

        IF(p_cRefCursor % ISOPEN) THEN
          CLOSE p_cRefCursor;
        END IF;
        vError := SQLERRM;
        RAISE_APPLICATION_ERROR(-20002, vError);

END pr_List_Related_Contents;

END PKG_VCM_MGMT_CHANNEL_CONTENT;
/
