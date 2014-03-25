CREATE OR REPLACE PACKAGE BODY "VCMMGMT"."PKG_VCM_INTEGRATION" AS
  /*
  Objetivo: Package com a finalidade de possuir procedures e functions,
            que retornem conteudo para geracao de XMLs. Com isto existe
            a integracao do V7 com sistemas externos.

  Histórico de alterações:
  22/09/2009 - CB - Criação da Package
  */

  --==============================================================================

  PROCEDURE pr_List_Content_Instances(p_crCursor         OUT PKG_VCMCONT_UTIL.cRefCursor,
                                      p_vIdVcmChannel    IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL%TYPE,
                                      p_cIdVcmObjectType IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_OBJECT_TYPE%TYPE,
                                      p_vDateInitial     IN VARCHAR2,
                                      p_nMinutes         IN NUMBER,
                                      p_vIdLanguage      IN VCM_CHANNEL_TREE_CONTENT.ID_LANGUAGE%TYPE,
                                      p_vLight           IN VARCHAR2) AS

    vAccountPlan VCM_CHANNEL_TREE.ACCOUNT_PLAN%TYPE;
    vSql         VARCHAR2(15000);
    vSelect      VARCHAR2(500);
    vFrom        VARCHAR2(1000);
    vWhere       VARCHAR2(1000);
    vError       VARCHAR2(200);

    PROCEDURE pr_Article_Detail AS
    BEGIN

      IF (p_vLight IS NOT NULL) THEN

        vSelect := ', DECODE(DMC.SOURCEPATH, NULL, NULL, I.DOMINIO_IMAGE||DMC.SOURCEPATH) SOURCEPATH  ' ||
                   ', DECODE(DMC.THUMBNAILPATH, NULL, NULL, I.DOMINIO_IMAGE||DMC.THUMBNAILPATH) THUMBNAILPATH  ' ||
                   ', DMC.CAPTION ' || ', DMC.COPYRIGHT ' || ', DMC.WIDTH ' ||
                   ', DMC.HEIGHT ' || ', DMC.PUBLISHER ';

        vFrom := ', ATOMO_VGN_NEWS_MEDIA VNM ' ||
                 ', VCMSYS.VGNASMOMAP VMM ' || ', DSX_MEDIA_COMMON DMC ' ||
                 ',(SELECT DBMS_LOB.SUBSTR(RUNVALUE, 500, 1) DOMINIO_IMAGE' ||
                 '  FROM VCMSYS.VGNCONFIGVAR ' ||
                 '  WHERE NAME = ''URL_PATH_PREFIX'' ' ||
                 '  AND NODEPATH = ''/vcm-vgninst/cdsvcs/stage-live/cds-live/resources/URLPathPrefix/staticfile/URLPathPrefix'' ' ||
                 '  AND ROWNUM <= 1) I ';

        vWhere := 'AND VCTC.ID_VCM_CONTENT_SHIFT = VNM.FK_ATOMO_VGN_NEWS_ID_NEWS(+) ' ||
                  'AND VNM.IS_REPRESENTATIVE(+) = ''Y'' ' ||
                  'AND VNM.FK_RMS_ID_MEDIA = VMM.RECORDID(+) ' ||
                  'AND VMM.KEYSTRING1 = DMC.MEDIAID(+) ';
      ELSE

        vSelect := ', DECODE(DMC.SOURCEPATH, NULL, NULL, I.DOMINIO_IMAGE||DMC.SOURCEPATH) SOURCEPATH  ' ||
                   ', DECODE(DMC.THUMBNAILPATH, NULL, NULL, I.DOMINIO_IMAGE||DMC.THUMBNAILPATH) THUMBNAILPATH  ' ||
                   ', DMC.CAPTION ' || ', DMC.COPYRIGHT ' || ', DMC.WIDTH ' ||
                   ', DMC.HEIGHT ' || ', DMC.PUBLISHER ' ||
                   ', AVN.BODY TEXT ' || ', AVA.NAME AUTHOR ' ||
                   ', AVS.NAME SOURCE ' ||
                   ', AVN.FREE_AUTHOR_NAME FREE_AUTHOR ' ||
                   ', AVN.FREE_TEXT_SOURCE FREE_SOURCE ';

        vFrom := ', ATOMO_VGN_NEWS AVN ' || ', ATOMO_VGN_NEWS_MEDIA VNM ' ||
                 ', ATOMO_VGN_NEWS_AUTHOR VNA ' ||
                 ', ATOMO_VGN_NEWS_SOURCE VNS ' ||
                 ', VCMSYS.VGNASMOMAP VMM ' || ', DSX_MEDIA_COMMON DMC ' ||
                 ', ATOMO_VGN_AUTHOR AVA ' || ', VCMSYS.VGNASMOMAP VMM1 ' ||
                 ', ATOMO_VGN_SOURCE AVS ' || ', VCMSYS.VGNASMOMAP VMM2 ' ||
                 ',(SELECT DBMS_LOB.SUBSTR(RUNVALUE, 500, 1) DOMINIO_IMAGE' ||
                 '  FROM VCMSYS.VGNCONFIGVAR ' ||
                 '  WHERE NAME = ''URL_PATH_PREFIX'' ' ||
                 '  AND NODEPATH = ''/vcm-vgninst/cdsvcs/stage-live/cds-live/resources/URLPathPrefix/staticfile/URLPathPrefix'' ' ||
                 '  AND ROWNUM <= 1) I ';

        vWhere := 'AND AVN.ID_NEWS = VCTC.ID_VCM_CONTENT_SHIFT ' ||
                  'AND AVN.ID_NEWS = VNM.FK_ATOMO_VGN_NEWS_ID_NEWS(+) ' ||
                  'AND VNM.IS_REPRESENTATIVE(+) = ''Y'' ' ||
                  'AND VNM.FK_RMS_ID_MEDIA = VMM.RECORDID(+) ' ||
                  'AND VMM.KEYSTRING1 = DMC.MEDIAID(+) ' ||
                  'AND VNM.FK_ATOMO_VGN_NEWS_ID_NEWS = VNA.FK_ATOMO_VGN_NEWS_ID_NEWS(+) ' ||
                  'AND VNA.FK_ATOMO_VGN_AUTHOR_ID_AUTHOR = VMM1.RECORDID(+) ' ||
                  'AND VMM1.KEYSTRING1 = AVA.ID_AUTHOR(+) ' ||
                  'AND VNM.FK_ATOMO_VGN_NEWS_ID_NEWS = VNS.FK_ATOMO_VGN_NEWS_ID_NEWS(+) ' ||
                  'AND VNS.FK_ATOMO_VGN_SOURCE_ID_SOURCE = VMM2.RECORDID(+) ' ||
                  'AND VMM2.KEYSTRING1 = AVS.ID_SOURCE(+) ';

      END IF;

    END pr_Article_Detail;

    --==========================================================================

    PROCEDURE pr_Gallery_Detail AS
    BEGIN

      vSelect := ', DECODE(DMC.SOURCEPATH, NULL, NULL, I.DOMINIO_IMAGE||DMC.SOURCEPATH) SOURCEPATH  ' ||
                 ', DECODE(DMC.THUMBNAILPATH, NULL, NULL, I.DOMINIO_IMAGE||DMC.THUMBNAILPATH) THUMBNAILPATH  ' ||
                 ', DMC.CAPTION ' || ', DMC.COPYRIGHT ' || ', DMC.WIDTH ' ||
                 ', DMC.HEIGHT ' || ', DMC.PUBLISHER ';

      vFrom := ', ATOMO_VGN_GALLERY_MEDIA VGM ' ||
               ', VCMSYS.VGNASMOMAP VMM ' || ', DSX_MEDIA_COMMON DMC ' ||
               ',(SELECT DBMS_LOB.SUBSTR(RUNVALUE, 500, 1) DOMINIO_IMAGE' ||
               '  FROM VCMSYS.VGNCONFIGVAR ' ||
               '  WHERE NAME = ''URL_PATH_PREFIX'' ' ||
               '  AND NODEPATH = ''/vcm-vgninst/cdsvcs/stage-live/cds-live/resources/URLPathPrefix/staticfile/URLPathPrefix'' ' ||
               '  AND ROWNUM <= 1) I ';

      vWhere := 'AND VCTC.ID_VCM_CONTENT_SHIFT = VGM.FK_ATOMO_VGN_GALLERY_ID_GALERY(+) ' ||
                'AND VGM.IS_REPRESENTATIVE(+) = ''Y'' ' ||
                'AND VGM.FK_RMS_ID_MEDIA = VMM.RECORDID(+) ' ||
                'AND VMM.KEYSTRING1 = DMC.MEDIAID(+) ';

    END pr_Gallery_Detail;

    --==========================================================================

    PROCEDURE pr_Correction_Detail AS
    BEGIN

      vSelect := ', AVC.BODY TEXT ' || ', AVA.NAME AUTHOR ' ||
                 ', AVS.NAME SOURCE ' ||
                 ', AVC.FREE_AUTHOR_NAME FREE_AUTHOR ' ||
                 ', AVC.FREE_TEXT_SOURCE FREE_SOURCE ';

      vFrom := ', ATOMO_VGN_CORRECTION AVC ' ||
               ', ATOMO_VGN_CORRECTION_AUTHOR VCA ' ||
               ', ATOMO_VGN_CORRECTION_SOURCE VCS ' ||
               ', ATOMO_VGN_AUTHOR AVA ' || ', VCMSYS.VGNASMOMAP VMM1 ' ||
               ', ATOMO_VGN_SOURCE AVS ' || ', VCMSYS.VGNASMOMAP VMM2 ';

      vWhere := 'AND AVC.ID_CORRECTION = VCTC.ID_VCM_CONTENT_SHIFT ' ||
                'AND AVC.ID_CORRECTION = VCA.FK_VGN_ATOMO_COR_ID_CORRECTION(+) ' ||
                'AND VCA.FK_VGN_ATOMO_AUTHOR_ID_AUTHOR = VMM1.RECORDID(+) ' ||
                'AND VMM1.KEYSTRING1 = AVA.ID_AUTHOR(+) ' ||
                'AND AVC.ID_CORRECTION = VCS.FK_VGN_ATOMO_COR_ID_CORRECTION(+) ' ||
                'AND VCS.FK_VGN_ATOMO_SOURCE_ID_SOURCE = VMM2.RECORDID(+) ' ||
                'AND VMM2.KEYSTRING1 = AVS.ID_SOURCE(+) ';

    END pr_Correction_Detail;

  BEGIN

    SELECT ACCOUNT_PLAN
      INTO vAccountPlan
      FROM VCM_CHANNEL_TREE
     WHERE ID_VCM_CHANNEL = p_vIdVcmChannel;

    IF (p_vLight IS NOT NULL) THEN

      -- CT Article
      IF (p_cIdVcmObjectType = 'ca4a4e75b5419110VgnVCM1000005801010a____') THEN

        pr_Article_Detail;

        -- CT Gallery
      ELSIF (p_cIdVcmObjectType =
            '98e44e75b5419110VgnVCM1000005801010a____') THEN

        pr_Gallery_Detail;

      END IF;

    ELSE

      -- CT Article
      IF (p_cIdVcmObjectType = 'ca4a4e75b5419110VgnVCM1000005801010a____') THEN

        pr_Article_Detail;

        -- CT Correction
      ELSIF (p_cIdVcmObjectType =
            '5a124e75b5419110VgnVCM1000005801010a____') THEN

        pr_Correction_Detail;

        -- CT Gallery
      ELSIF (p_cIdVcmObjectType =
            '98e44e75b5419110VgnVCM1000005801010a____') THEN

        pr_Gallery_Detail;

      END IF;

    END IF;

    --vSql:= 'SELECT * FROM ('||
    vSql := 'SELECT Y.*, ' ||
            'DECODE(Y.STATUS, ''Published'',  Y.DATE_PUBLISHED, NULL) MAX_DATE_PUBLISHED,' ||
            'DECODE(Y.STATUS, ''Unpublished'',  Y.DATE_PUBLISHED, NULL) MAX_DATE_UNPUBLISHED ' ||
           /* ' F_GET_STATUS_PUBLISH(Y.DATE_MODIFIED, Y.DATE_PUBLISHED) STATUS, '||
                                                                                                                                '( SELECT MAX(DATE_UPDATED - (GMT/24)) '||
                                                                                                                                '  FROM VCMLIVE.ATOMO_VGN_HISTORY_CONTENT '||
                                                                                                                                '  WHERE ID_CONTENT_INSTANCE = Y.ID_VCM_CONTENT_SHIFT '||
                                                                                                                                '  AND DESCRIPTION = ''PUBLISHED'' ) MAX_DATE_PUBLISHED, '||
                                                                                                                                '( SELECT MAX(DATE_UPDATED - (GMT/24)) '||
                                                                                                                                '  FROM VCMLIVE.ATOMO_VGN_HISTORY_CONTENT '||
                                                                                                                                '  WHERE ID_CONTENT_INSTANCE = Y.ID_VCM_CONTENT_SHIFT '||
                                                                                                                                '  AND DESCRIPTION = ''UNPUBLISHED'' ) MAX_DATE_UNPUBLISHED '||
                                                                                                                                */
            'FROM(' || 'SELECT X.* ' ||
           /*
                                                                                                                                       '(CASE WHEN X.XML_NAME = ''atomo-noticia'' THEN (SELECT DATE_MODIFIED FROM ATOMO_VGN_NEWS WHERE ID_NEWS = X.ID_VCM_CONTENT_SHIFT) '||
                                                                                                                                             'WHEN X.XML_NAME = ''atomo-galeria'' THEN (SELECT DATE_MODIFIED FROM ATOMO_VGN_GALLERY WHERE ID_GALLERY = X.ID_VCM_CONTENT_SHIFT) '||
                                                                                                                                             'ELSE (SELECT DATE_MODIFIED FROM ATOMO_VGN_CORRECTION WHERE ID_CORRECTION = X.ID_VCM_CONTENT_SHIFT) '||
                                                                                                                                        'END '||
                                                                                                                                       ') DATE_MODIFIED, '||
                                                                                                                                       '(CASE WHEN X.XML_NAME = ''atomo-noticia'' THEN (SELECT DATE_PUBLISHED FROM VCMLIVE.ATOMO_VGN_NEWS WHERE ID_NEWS = X.ID_VCM_CONTENT_SHIFT) '||
                                                                                                                                             'WHEN X.XML_NAME = ''atomo-galeria'' THEN (SELECT DATE_PUBLISHED FROM VCMLIVE.ATOMO_VGN_GALLERY WHERE ID_GALLERY = X.ID_VCM_CONTENT_SHIFT) '||
                                                                                                                                             'ELSE (SELECT DATE_PUBLISHED FROM VCMLIVE.ATOMO_VGN_CORRECTION WHERE ID_CORRECTION = X.ID_VCM_CONTENT_SHIFT) '||
                                                                                                                                        'END '||
                                                                                                                                       ') DATE_PUBLISHED '||
                                                                                                                                       */
            'FROM( ' ||
            'SELECT /*+ INDEX(VCTC VCTC IDX_VCM_PUB_ACCOUNT_OBJECT) */ ' ||
            'VCTC.ID_VCM_CONTENT_SHIFT, ' ||
            'VCTC.ID_VCM_CONTENT ID_RECORD, ' ||
            'VCT.ID_VCM_CHANNEL ID_CHANNEL, ' || 'VCT.PATH, ' ||
            'VCTC.NAME TITLE, ' ||
            'VCTC.DATE_CREATED DATE_CREATED, ' ||
            'VCTC.DATE_PUBLISHED DATE_PUBLISHED, ' ||
            'DECODE(VCTC.STATUS, ''P'', ''Published'', ''Unpublished'') STATUS, ' ||
            'VCTC.ID_LANGUAGE, ' ||
            'f_Mount_Furl(VCT.FURL_CHANNEL,VCTC.FURL_CONTENT_TITLE,VCTC.ID_VCM_CONTENT) URL ' ||
            vSelect ||
           --'SYSOBJ.NAME XML_NAME '||vSelect||
            'FROM VCM_CHANNEL_TREE_CONTENT VCTC, ' ||
            'VCM_CHANNEL_TREE VCT ' ||
           --'VCMSYSDSV.VGNASOBJECTTYPE SYSOBJ, '||
            vFrom ||
            'WHERE VCT.ACCOUNT_PLAN LIKE ''' || vAccountPlan || '%'' ' ||
            'AND VCTC.ID_VCM_OBJECT_TYPE = ''' || p_cIdVcmObjectType ||'''' ||
            ' AND VCTC.ID_VCM_CHANNEL_TREE = VCT.ID_VCM_CHANNEL_TREE ';

            IF ( p_nMinutes != 0 ) THEN -- se minutos for 0 somente retorna Publisheds
               vSql := vSql || 'AND VCTC.STATUS IN (''P'', ''U'') ';
            ELSE
               vSql := vSql || 'AND VCTC.STATUS = ''P'' ';
            END IF;

            IF ( p_nMinutes != 0 ) THEN -- se minutos for 0, nao filtra por periodo, e traz as 10 ultimas
              vSql := vSql || 'AND VCTC.DATE_PUBLISHED BETWEEN ';

              IF (p_vDateInitial IS NOT NULL) THEN

                IF (p_nMinutes IS NOT NULL AND p_nMinutes > -1) THEN
                  vSql := vSql || ' TO_DATE(''' || p_vDateInitial ||
                          ''',''YYYYMMDDHH24MISS'') - ' || p_nMinutes ||
                          '/(24*60) AND TO_DATE(''' || p_vDateInitial ||
                          ''',''YYYYMMDDHH24MISS'') ';
                ELSE
                  vSql := vSql || ' TO_DATE(''' || p_vDateInitial ||
                          ''',''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''' ||
                          p_vDateInitial || ''',''YYYYMMDDHH24MISS'') ';
                END IF;

              ELSE

                IF (p_nMinutes IS NOT NULL AND p_nMinutes > -1) THEN
                  vSql := vSql || ' (CURRENT_DATE) - ' || p_nMinutes ||
                          '/(24*60) AND (CURRENT_DATE) ';
                ELSE
                  vSql := vSql || ' (CURRENT_DATE) - 1 AND (CURRENT_DATE) ';
                END IF;

              END IF;
            END IF;


    IF (p_vIdLanguage IS NOT NULL) THEN

      vSql := vSql || 'AND VCTC.ID_LANGUAGE = ''' || UPPER(p_vIdLanguage) ||
              ''' ';

    END IF;

    vSql := vSql || vWhere ||
            ' ORDER BY VCTC.DATE_PUBLISHED DESC ) X ';

    IF ( p_nMinutes = 0 ) THEN -- se minutos for 0, nao filtra por periodo, e traz as 10 ultimas
      vSql := vSql || ' WHERE ROWNUM <= 10 ';
    END IF;

    vSql := vSql || ') Y ';
    --) '||
    --'WHERE STATUS != ''Stale'' ';

    --DBMS_OUTPUT.PUT_LINE(vSql);

    OPEN p_crCursor FOR vSql;

  EXCEPTION
    WHEN OTHERS THEN
      IF (p_crCursor%ISOPEN) THEN
        CLOSE p_crCursor;
      END IF;
      vError := SQLERRM;
      RAISE_APPLICATION_ERROR(-20002, vError);

  END pr_List_Content_Instances;

  --==============================================================================

  PROCEDURE pr_Pull_Content_Instances(p_crCursor         OUT PKG_VCMCONT_UTIL.cRefCursor,
                                      p_vIdVcmChannel    IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL%TYPE,
                                      p_cIdVcmObjectType IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_OBJECT_TYPE%TYPE,
                                      p_nDateInitial     IN INTEGER,
                                      p_nDateEnd         IN INTEGER) AS

    vAccountPlan VCM_CHANNEL_TREE.ACCOUNT_PLAN%TYPE;
    vSql         VARCHAR2(15000);
    vSelect      VARCHAR2(250);
    vSelect2     VARCHAR2(500);
    vFrom        VARCHAR2(1000);
    vFrom2       VARCHAR2(100);
    vWhere       VARCHAR2(1000);
    vWhere2      VARCHAR2(500);
    vOrderBy     VARCHAR2(500);
    vError       VARCHAR2(200);
    nTotal       NUMBER(10);

    PROCEDURE pr_Article_Detail AS
    BEGIN

      vSelect := ', I.DOMINIO_IMAGE' || ', DMC.THUMBNAILPATH ' ||
                 ', AVN.KEYWORDS ';

      vSelect2 := ', AVN.BODY TEXT ' || ', AVN.SUBTITLE ' ||
                  ', VCT.ID_VCM_CHANNEL ' || ', SUBSTR(VCT."PATH",INSTR(VCT."PATH",''/'',1,2)) PATH_CHANNEL ';

      vFrom := ', ATOMO_VGN_NEWS AVN ' || ', ATOMO_VGN_NEWS_MEDIA VNM ' ||
               ', VCMSYS.VGNASMOMAP VMM ' || ', DSX_MEDIA_COMMON DMC ' ||
               ',(SELECT DBMS_LOB.SUBSTR(RUNVALUE, 500, 1) DOMINIO_IMAGE' ||
               '  FROM VCMSYS.VGNCONFIGVAR ' ||
               '  WHERE NAME = ''URL_PATH_PREFIX'' ' ||
               '  AND NODEPATH = ''/vcm-vgninst/cdsvcs/stage-live/cds-live/resources/URLPathPrefix/staticfile/URLPathPrefix'' ' ||
               '  AND ROWNUM <= 1) I ';

      vFrom2 := 'ATOMO_VGN_NEWS AVN, ' || 'VCM_CHANNEL_TREE VCT, '||' VCM_CHANNEL_TREE_CONTENT VCTC, ';

      vWhere := 'AND AVN.ID_NEWS = VCTC.ID_VCM_CONTENT_SHIFT ' ||
                'AND AVN.ID_NEWS = VNM.FK_ATOMO_VGN_NEWS_ID_NEWS(+) ' ||
                'AND VNM.IS_REPRESENTATIVE(+) = ''Y'' ' ||
                'AND VNM.FK_RMS_ID_MEDIA = VMM.RECORDID(+) ' ||
                'AND VMM.KEYSTRING1 = DMC.MEDIAID(+) ';

      vWhere2 := 'WHERE AVN.ID_NEWS = K.ID_VCM_CONTENT_SHIFT ' ||
                 'AND VCTC.ID_VCM_CONTENT = K.ID_RECORD ' ||
                 'AND VCTC.ID_VCM_CHANNEL_TREE = VCT.ID_VCM_CHANNEL_TREE ' ||
                 'AND VCT.ID_VCM_CHANNEL_TREE = K.ID_CHANNEL ';

      vOrderBy := ' ORDER BY K.ID_RECORD, K.ID_CHANNEL ';

    END pr_Article_Detail;

    --==========================================================================

    PROCEDURE pr_Gallery_Detail AS
    BEGIN

      vSelect := ', I.DOMINIO_IMAGE' || ', DMC.THUMBNAILPATH ' ||
                 ', AVG.KEYWORDS ';
      -- concatena na TEXT as legendas de todas as fotos da galeria
      vSelect2 := ', (SELECT stragg('' ''|| VGM.SUBTITLE)
                          FROM ATOMO_VGN_GALLERY_MEDIA VGM
                          WHERE VGM.FK_ATOMO_VGN_GALLERY_ID_GALERY = K.ID_VCM_CONTENT_SHIFT) TEXT ' || ', AVG.SUBTITLE ' ||
                  ', VCT.ID_VCM_CHANNEL ' || ', SUBSTR(VCT."PATH",INSTR(VCT."PATH",''/'',1,2)) PATH_CHANNEL ';

      vFrom := ', ATOMO_VGN_GALLERY AVG ' ||
               ', ATOMO_VGN_GALLERY_MEDIA VGM ' ||
               ', VCMSYS.VGNASMOMAP VMM ' || ', DSX_MEDIA_COMMON DMC ' ||
               ',(SELECT DBMS_LOB.SUBSTR(RUNVALUE, 500, 1) DOMINIO_IMAGE' ||
               '  FROM VCMSYS.VGNCONFIGVAR ' ||
               '  WHERE NAME = ''URL_PATH_PREFIX'' ' ||
               '  AND NODEPATH = ''/vcm-vgninst/cdsvcs/stage-live/cds-live/resources/URLPathPrefix/staticfile/URLPathPrefix'' ' ||
               '  AND ROWNUM <= 1) I ';

      vFrom2 := 'ATOMO_VGN_GALLERY AVG, ' || 'VCM_CHANNEL_TREE VCT, '||' VCM_CHANNEL_TREE_CONTENT VCTC, ';

      vWhere := 'AND AVG.ID_GALLERY = VCTC.ID_VCM_CONTENT_SHIFT ' ||
                'AND AVG.ID_GALLERY = VGM.FK_ATOMO_VGN_GALLERY_ID_GALERY(+) ' ||
                'AND VGM.IS_REPRESENTATIVE(+) = ''Y'' ' ||
                'AND VGM.FK_RMS_ID_MEDIA = VMM.RECORDID(+) ' ||
                'AND VMM.KEYSTRING1 = DMC.MEDIAID(+) ';

      vWhere2 := 'WHERE AVG.ID_GALLERY = K.ID_VCM_CONTENT_SHIFT ' ||
                 'AND VCTC.ID_VCM_CONTENT = K.ID_RECORD ' ||
                 'AND VCTC.ID_VCM_CHANNEL_TREE = VCT.ID_VCM_CHANNEL_TREE ' ||
                 'AND VCT.ID_VCM_CHANNEL_TREE = K.ID_CHANNEL ';

    END pr_Gallery_Detail;

    --==========================================================================

    PROCEDURE pr_Correction_Detail AS
    BEGIN

      vSelect := ', I.DOMINIO_IMAGE' || ', DMC.THUMBNAILPATH ' ||
                 ', AVC.KEYWORDS ';

      vSelect2 := ', AVC.BODY TEXT ' || ', AVC.SUBTITLE ' ||
                  ', VCT.ID_VCM_CHANNEL ' || ', SUBSTR(VCT."PATH",INSTR(VCT."PATH",''/'',1,2)) PATH_CHANNEL ';

      vFrom := ', ATOMO_VGN_CORRECTION AVC ' ||
               ', ATOMO_VGN_CORRECTION_MEDIA VCM ' ||
               ', VCMSYS.VGNASMOMAP VMM ' || ', DSX_MEDIA_COMMON DMC ' ||
               ',(SELECT DBMS_LOB.SUBSTR(RUNVALUE, 500, 1) DOMINIO_IMAGE' ||
               '  FROM VCMSYS.VGNCONFIGVAR ' ||
               '  WHERE NAME = ''URL_PATH_PREFIX'' ' ||
               '  AND NODEPATH = ''/vcm-vgninst/cdsvcs/stage-live/cds-live/resources/URLPathPrefix/staticfile/URLPathPrefix'' ' ||
               '  AND ROWNUM <= 1) I ';

      vFrom2 := 'ATOMO_VGN_CORRECTION AVC, ' || 'VCM_CHANNEL_TREE VCT, '||' VCM_CHANNEL_TREE_CONTENT VCTC, ';

      vWhere := 'AND AVC.ID_CORRECTION = VCTC.ID_VCM_CONTENT_SHIFT ' ||
                'AND AVC.ID_CORRECTION = VCM.FK_VGN_ATOMO_COR_ID_CORRECTION(+) ' ||
                'AND VCM.IS_REPRESENTATIVE(+) = ''Y'' ' ||
                'AND VCM.FK_RMS_ID_MEDIA = VMM.RECORDID(+) ' ||
                'AND VMM.KEYSTRING1 = DMC.MEDIAID(+) ';

      vWhere2 := 'WHERE AVC.ID_CORRECTION = K.ID_VCM_CONTENT_SHIFT ' ||
                 'AND VCTC.ID_VCM_CONTENT = K.ID_RECORD ' ||
                 'AND VCTC.ID_VCM_CHANNEL_TREE = VCT.ID_VCM_CHANNEL_TREE ' ||
                 'AND VCT.ID_VCM_CHANNEL_TREE = K.ID_CHANNEL ';

      vOrderBy := ' ORDER BY K.ID_RECORD, K.ID_CHANNEL ';

    END pr_Correction_Detail;

  BEGIN

    SELECT ACCOUNT_PLAN
      INTO vAccountPlan
      FROM VCM_CHANNEL_TREE
     WHERE ID_VCM_CHANNEL = p_vIdVcmChannel;

    --================CONTADOR DE REGISTROS=====================================

    vSql := 'SELECT COUNT(*) TOTAL ' || 'FROM ( ' ||
            'SELECT MAX(ID_CHANNEL) ID_CHANNEL, ID_VCM_CONTENT_SHIFT, ID_RECORD, TITLE ' ||
            'FROM (' ||
            'SELECT /*+ INDEX(VCTC IDX_VCM_PUB_ACCOUNT_OBJECT) */ ' ||
            'VCTC.ID_VCM_CONTENT_SHIFT, ' ||
            'VCTC.ID_VCM_CONTENT ID_RECORD, ' ||
            'VCTC.ID_VCM_CHANNEL_TREE ID_CHANNEL, ' || 'VCTC.NAME TITLE ' ||
            'FROM VCM_CHANNEL_TREE_CONTENT VCTC ' ||
            'WHERE VCTC.ACCOUNT_PLAN LIKE ''' || vAccountPlan || '%'' ' ||
            'AND VCTC.ID_VCM_OBJECT_TYPE = ''' || p_cIdVcmObjectType ||
            ''' ' || 'AND VCTC.STATUS IN (''P'', ''U'') ' ||
            'AND VCTC.DATE_PUBLISHED BETWEEN to_date(''19700101'',''YYYYMMDD'')+ '||p_nDateInitial||'/86400 ' ||
            '                            AND to_date(''19700101'',''YYYYMMDD'')+ '||p_nDateEnd||'/86400 ';

    vSql := vSql || ') GROUP BY ID_VCM_CONTENT_SHIFT, ID_RECORD, TITLE)';

    OPEN p_crCursor FOR vSql;

    FETCH p_crCursor
      INTO nTotal;

    CLOSE p_crCursor;

    --==========================================================================

    IF (nTotal > 0) THEN

      -- CT Article
      IF (p_cIdVcmObjectType = 'ca4a4e75b5419110VgnVCM1000005801010a____') THEN

        pr_Article_Detail;

        -- CT Correction
      ELSIF (p_cIdVcmObjectType =
            '5a124e75b5419110VgnVCM1000005801010a____') THEN

        pr_Correction_Detail;

        -- CT Gallery
      ELSIF (p_cIdVcmObjectType =
            '98e44e75b5419110VgnVCM1000005801010a____') THEN

        pr_Gallery_Detail;

      END IF;

      vSql := 'SELECT Y.*, ' ||
              'ROUND((86400 * (Y.DATE_PUBLISHED  - TO_DATE(''01.01.1970 00:00:00'',''DD.MM.RRRR HH24:MI:SS''))),0) UNIX_TIME, ' ||
              nTotal || ' TOTAL_RECORDS ' || 'FROM(' || 'SELECT X.* ' ||
              'FROM( ' ||
              'SELECT K.ID_CHANNEL, K.ID_VCM_CONTENT_SHIFT, K.ID_RECORD, K.TITLE, K.KEYWORDS, K.DATE_PUBLISHED, K.STATUS, DECODE(K.THUMBNAILPATH, NULL, NULL, K.DOMINIO_IMAGE||K.THUMBNAILPATH) THUMBNAILPATH, ' ||
              'F_MOUNT_FURL(VCT.FURL_CHANNEL,VCTC.FURL_CONTENT_TITLE,K.ID_RECORD) URL ' ||
          --    'PKG_VCM_INTEGRATION.fn_Mount_FUrl(K.ID_RECORD, K.ID_CHANNEL, K.CHANNEL_REFERENCE, K.TITLE) URL ' ||
              vSelect2 || 'FROM ' || vFrom2 ||
              '(  SELECT MAX(ID_CHANNEL) ID_CHANNEL, ID_VCM_CONTENT_SHIFT, ID_RECORD, TITLE, KEYWORDS, DOMINIO_IMAGE, THUMBNAILPATH, DATE_PUBLISHED, STATUS ' ||
              'FROM (' ||
              'SELECT ' ||
              'VCTC.ID_VCM_CONTENT_SHIFT, ' ||
              'VCTC.ID_VCM_CONTENT ID_RECORD, ' ||
              'VCTC.ID_VCM_CHANNEL_TREE ID_CHANNEL, ' ||
              'VCTC.NAME TITLE, ' ||
              'VCTC.DATE_PUBLISHED DATE_PUBLISHED,' ||
              'DECODE(VCTC.STATUS, ''P'', ''Publish'', ''Unpublish'')	STATUS ' ||
              vSelect || 'FROM VCM_CHANNEL_TREE_CONTENT VCTC,  ' ||
                         'VCM_CHANNEL_TREE VCT ' ||
              vFrom ||
              'WHERE VCT.ACCOUNT_PLAN LIKE ''' || vAccountPlan || '%'' ' ||
              'AND VCT.IS_MIGRATED = 1 ' || -- SOMENTE DE CANAIS MIGRADOS (solucao temporaria, ate migracao total)
              'AND VCTC.ID_VCM_CHANNEL_TREE = VCT.ID_VCM_CHANNEL_TREE ' ||
              'AND VCTC.ID_VCM_OBJECT_TYPE = ''' || p_cIdVcmObjectType ||
              ''' ' || 'AND VCTC.STATUS IN (''P'', ''U'') ' ||
              'AND VCTC.DATE_PUBLISHED BETWEEN to_date(''19700101'',''YYYYMMDD'')+ '||p_nDateInitial||'/86400 ' ||
              '                            AND to_date(''19700101'',''YYYYMMDD'')+ '||p_nDateEnd||'/86400 ';

      vSql := vSql || vWhere || ')' ||
              ' GROUP BY ID_VCM_CONTENT_SHIFT, ID_RECORD, TITLE, KEYWORDS, DOMINIO_IMAGE, THUMBNAILPATH, DATE_PUBLISHED, STATUS ' ||
              ') K ' || vWhere2 || vOrderBy ||
              ' ) X ) Y';

      OPEN p_crCursor FOR vSql;

    ELSE

      OPEN p_crCursor FOR 'SELECT 1 FROM DUAL WHERE 1 != 1';

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (p_crCursor%ISOPEN) THEN
        CLOSE p_crCursor;
      END IF;
      vError := SQLERRM;
      RAISE_APPLICATION_ERROR(-20002, vError);

  END pr_Pull_Content_Instances;

PROCEDURE pr_get_LoMas(p_crCursor         OUT PKG_VCMCONT_UTIL.cRefCursor,
                       p_vIdVcmContent    IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CONTENT%TYPE,
                       p_cIdVcmObjectType IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_OBJECT_TYPE%TYPE) AS

    vSql         VARCHAR2(15000);
    vSelect      VARCHAR2(500);
    vFrom        VARCHAR2(1000);
    vWhere       VARCHAR2(1000);
    vError       VARCHAR2(200);

    PROCEDURE pr_Article_Detail AS
    BEGIN

      vSelect := ', DECODE(DMC.SOURCEPATH, NULL, NULL, I.DOMINIO_IMAGE||DMC.SOURCEPATH) SOURCEPATH  ' ||
                 ', DECODE(DMC.THUMBNAILPATH, NULL, NULL, I.DOMINIO_IMAGE||DMC.THUMBNAILPATH) THUMBNAILPATH  ' ||
                 ', VNM.SUBTITLE CAPTION ' || ', VNM.SOURCE COPYRIGHT ' ||
                 ', DMC.PUBLISHER ' ||
                 ', AVN.BODY TEXT ' ||
                 ', AVN.FREE_AUTHOR_NAME FREE_AUTHOR ' ||
                 ', AVN.FREE_TEXT_SOURCE FREE_SOURCE ';

      vFrom := ', ATOMO_VGN_NEWS AVN ' || ', ATOMO_VGN_NEWS_MEDIA VNM ' ||
               ', VCMSYS.VGNASMOMAP VMM ' || ', DSX_MEDIA_COMMON DMC ' ||
               ',(SELECT DBMS_LOB.SUBSTR(RUNVALUE, 500, 1) DOMINIO_IMAGE' ||
               '  FROM VCMSYS.VGNCONFIGVAR ' ||
               '  WHERE NAME = ''URL_PATH_PREFIX'' ' ||
               '  AND NODEPATH = ''/vcm-vgninst/cdsvcs/stage-live/cds-live/resources/URLPathPrefix/staticfile/URLPathPrefix'' ' ||
               '  AND ROWNUM <= 1) I ';

      vWhere := 'AND AVN.ID_NEWS = VCTC.ID_VCM_CONTENT_SHIFT ' ||
                'AND AVN.ID_NEWS = VNM.FK_ATOMO_VGN_NEWS_ID_NEWS(+) ' ||
                'AND VNM.IS_REPRESENTATIVE(+) = ''Y'' ' ||
                'AND VNM.FK_RMS_ID_MEDIA = VMM.RECORDID(+) ' ||
                'AND VMM.KEYSTRING1 = DMC.MEDIAID(+) ';
    END pr_Article_Detail;

    --==========================================================================

    PROCEDURE pr_Gallery_Detail AS
    BEGIN

      vSelect := ', DECODE(DMC.SOURCEPATH, NULL, NULL, I.DOMINIO_IMAGE||DMC.SOURCEPATH) SOURCEPATH  ' ||
                 ', DECODE(DMC.THUMBNAILPATH, NULL, NULL, I.DOMINIO_IMAGE||DMC.THUMBNAILPATH) THUMBNAILPATH  ' ||
                 ', VGM.SUBTITLE CAPTION ' || ', VGM.SOURCE COPYRIGHT ' ||
                 ', DMC.PUBLISHER ';

      vFrom := ', ATOMO_VGN_GALLERY_MEDIA VGM ' ||
               ', VCMSYS.VGNASMOMAP VMM ' || ', DSX_MEDIA_COMMON DMC ' ||
               ',(SELECT DBMS_LOB.SUBSTR(RUNVALUE, 500, 1) DOMINIO_IMAGE' ||
               '  FROM VCMSYS.VGNCONFIGVAR ' ||
               '  WHERE NAME = ''URL_PATH_PREFIX'' ' ||
               '  AND NODEPATH = ''/vcm-vgninst/cdsvcs/stage-live/cds-live/resources/URLPathPrefix/staticfile/URLPathPrefix'' ' ||
               '  AND ROWNUM <= 1) I ';

      vWhere := 'AND VCTC.ID_VCM_CONTENT_SHIFT = VGM.FK_ATOMO_VGN_GALLERY_ID_GALERY(+) ' ||
                'AND VGM.IS_REPRESENTATIVE(+) = ''Y'' ' ||
                'AND VGM.FK_RMS_ID_MEDIA = VMM.RECORDID(+) ' ||
                'AND VMM.KEYSTRING1 = DMC.MEDIAID(+) ';

    END pr_Gallery_Detail;

  BEGIN

      -- CT Article
      IF (p_cIdVcmObjectType = 'ca4a4e75b5419110VgnVCM1000005801010a____') THEN

        pr_Article_Detail;

      -- CT Gallery
      ELSIF (p_cIdVcmObjectType =
            '98e44e75b5419110VgnVCM1000005801010a____') THEN

        pr_Gallery_Detail;

      END IF;

      vSql := 'SELECT /*+ INDEX(VCTC VCTC IDX_VCM_PUB_ACCOUNT_OBJECT) */ ' ||
              'VCTC.ID_VCM_CONTENT ID_RECORD, ' ||
              'VCTC.NAME TITLE, ' ||
              'VCTC.DATE_PUBLISHED DATE_PUBLISHED, ' ||
              'VC.DATE_UPDATED DATE_UPDATED, ' ||
              'F_MOUNT_FURL(VCT.FURL_CHANNEL,VCTC.FURL_CONTENT_TITLE,VCTC.ID_VCM_CONTENT) URL ' ||
              vSelect ||
              'FROM VCM_CHANNEL_TREE_CONTENT VCTC, ' ||
              ' VCM_CONTENT VC, ' ||
              ' VCM_CHANNEL_TREE VCT ' || vFrom ||
              'WHERE VCTC.ID_VCM_CONTENT = ''' || p_vIdVcmContent || ''' ' ||
              'AND VCTC.ID_VCM_CHANNEL_TREE = VCT.ID_VCM_CHANNEL_TREE ' ||
              'AND VCTC.ID_VCM_OBJECT_TYPE = ''' || p_cIdVcmObjectType ||
              ''' ' || 'AND VCTC.STATUS = ''P'' ' ||
              ' AND VCT."LEVEL" > 1  '||
              ' AND VCTC.ID_VCM_CONTENT = VC.ID_VCM_CONTENT  ';


    vSql := vSql || vWhere;

    OPEN p_crCursor FOR vSql;

  EXCEPTION
    WHEN OTHERS THEN
      IF (p_crCursor%ISOPEN) THEN
        CLOSE p_crCursor;
      END IF;
      vError := SQLERRM;
      RAISE_APPLICATION_ERROR(-20002, vError);

END pr_get_LoMas;

PROCEDURE pr_get_LoMas_Article_Authors(p_crCursor         OUT PKG_VCMCONT_UTIL.cRefCursor,
                                       p_vIdVcmContent    IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CONTENT%TYPE) AS

    vSql         VARCHAR2(15000);
  BEGIN
   vSql := ' SELECT
                   AVA.NAME AUTHOR
              FROM
                   ATOMO_VGN_NEWS_AUTHOR VNA,
                   ATOMO_VGN_AUTHOR AVA,
                   VCMSYS.VGNASMOMAP VMM,
                   VCM_CHANNEL_TREE_CONTENT VCTC
              WHERE
                  VNA.FK_ATOMO_VGN_AUTHOR_ID_AUTHOR = VMM.RECORDID
                 AND VMM.KEYSTRING1 = AVA.ID_AUTHOR
                 AND VNA.FK_ATOMO_VGN_NEWS_ID_NEWS = VCTC.ID_VCM_CONTENT_SHIFT
                 AND VCTC.ID_VCM_CONTENT = :1
                 AND VCTC.ID_VCM_OBJECT_TYPE = ''ca4a4e75b5419110VgnVCM1000005801010a____''
                 AND VCTC.STATUS = ''P'' ';


  OPEN p_crCursor FOR vSql using p_vIdVcmContent;

END pr_get_LoMas_Article_Authors;

PROCEDURE pr_get_LoMas_Article_Sources(p_crCursor         OUT PKG_VCMCONT_UTIL.cRefCursor,
                                       p_vIdVcmContent    IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CONTENT%TYPE) AS

    vSql         VARCHAR2(15000);
  BEGIN

   vSql := ' SELECT
                   AVS.NAME SOURCE
              FROM
                   ATOMO_VGN_SOURCE AVS,
                   ATOMO_VGN_NEWS_SOURCE VNS,
                   VCM_CHANNEL_TREE_CONTENT VCTC,
                   VCMSYS.VGNASMOMAP VMM
              WHERE
                     VCTC.ID_VCM_CONTENT_SHIFT = VNS.FK_ATOMO_VGN_NEWS_ID_NEWS
                 AND VNS.FK_ATOMO_VGN_SOURCE_ID_SOURCE = VMM.RECORDID
                 AND VMM.KEYSTRING1 = AVS.ID_SOURCE
                 AND VCTC.ID_VCM_CONTENT = :1
                 AND VCTC.ID_VCM_OBJECT_TYPE = ''ca4a4e75b5419110VgnVCM1000005801010a____''
                 AND VCTC.STATUS = ''P'' ';


  OPEN p_crCursor FOR vSql using p_vIdVcmContent;

END pr_get_LoMas_Article_Sources;

END PKG_VCM_INTEGRATION;
/
