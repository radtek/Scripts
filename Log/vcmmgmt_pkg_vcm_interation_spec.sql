CREATE OR REPLACE PACKAGE "VCMMGMT"."PKG_VCM_INTEGRATION" AS


/*
Objetivo: Package com a finalidade de possuir procedures e functions,
          que retornem conteudo para geracao de XMLs. Com isto existe
          a integracao do V7 com sistemas externos.

Histórico de alterações:
22/09/2009 - CB - Criação da Package
30/03/2010 - FF - Criacao da proc pr_get_LoMas
*/

PROCEDURE pr_List_Content_Instances(p_crCursor OUT PKG_VCMCONT_UTIL.cRefCursor,
                                    p_vIdVcmChannel IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL%TYPE,
                                    p_cIdVcmObjectType IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_OBJECT_TYPE%TYPE,
                                    p_vDateInitial IN VARCHAR2,
                                    p_nMinutes IN NUMBER,
                                    p_vIdLanguage IN VCM_CHANNEL_TREE_CONTENT.ID_LANGUAGE%TYPE,
                                    p_vLight IN VARCHAR2);

PROCEDURE pr_Pull_Content_Instances(p_crCursor         OUT PKG_VCMCONT_UTIL.cRefCursor,
                                      p_vIdVcmChannel    IN VCM_CHANNEL_TREE.ID_VCM_CHANNEL%TYPE,
                                      p_cIdVcmObjectType IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_OBJECT_TYPE%TYPE,
                                      p_nDateInitial     IN INTEGER,
                                      p_nDateEnd         IN INTEGER);

PROCEDURE pr_get_LoMas(p_crCursor         OUT PKG_VCMCONT_UTIL.cRefCursor,
                       p_vIdVcmContent    IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CONTENT%TYPE,
                       p_cIdVcmObjectType IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_OBJECT_TYPE%TYPE);

PROCEDURE pr_get_LoMas_Article_Authors(p_crCursor         OUT PKG_VCMCONT_UTIL.cRefCursor,
                                       p_vIdVcmContent    IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CONTENT%TYPE);

PROCEDURE pr_get_LoMas_Article_Sources(p_crCursor         OUT PKG_VCMCONT_UTIL.cRefCursor,
                                       p_vIdVcmContent    IN VCM_CHANNEL_TREE_CONTENT.ID_VCM_CONTENT%TYPE);

END PKG_VCM_INTEGRATION;
/
