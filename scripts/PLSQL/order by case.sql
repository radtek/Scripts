var cur refcursor

begin
PKG_TTVWS.SP_GET_CONTENT_LIST(p_instance_id => 1, p_channel_id => 4004, p_first => 10, p_count => 100,p_hide_rankable=> 0,p_hide_adult => 0,p_order => 2, datareader => :cur);
end;
/
print cur


begin
PKG_TTVWS2.SP_GET_CONTENT_LIST(p_instance_id => 1, p_channel_id => 4004, p_first => 10, p_count => 100,p_hide_rankable=> 0,p_hide_adult => 0,p_order => 2, datareader => :cur);
end;
/
print cur

PROCEDURE SP_GET_CONTENT_LIST(p_instance_id IN INT, p_channel_id IN INT, p_first IN INT, p_count IN INT, p_hide_rankable IN INT, p_hide_adult IN INT, p_order IN INT, datareader OUT T_CURSOR)
IS
BEGIN
  OPEN datareader FOR
  'with subsql as
   (	SELECT
              fe.audience AS audience,
						fe.audience_24h AS audience24h,
						fe.description AS description,
						NVL(fe.duration_flash, fe.duration_wmv) AS duration,
						fe.content_id AS id,
						fe.content_name AS name,
						fe.keywords AS keywords,
						fe.originalpublishingdate AS originalpublishdate,
						0 AS prioritized,
						fe.rating AS rate,
						fe.rating_24h AS rate24h,
						fe.rating_total AS ratingtotal,
						fe.content_title AS title,
						fe.content_provider_id AS providerid,
						fe.content_provider_name AS providername,
						fe.isadult AS isadult,
					            decode(fe.subtitle, 2, 1, 3, 1, 0) as hassubtitle,
				        	    decode(fe.subtitle, 1, 1, 3, 1, 0) as isdubbed,
						fe.is_supercontent AS issupercontent,
						fe.child_content as parts
				FROM	ttv3_frontend fe
				WHERE	fe.instance_id = :p_instance_id
				AND		fe.channel_id = :p_channel_id
				AND		DECODE(NVL(:p_hide_adult, 0), 0, 0, NVL(fe.isadult,0)) = 0
				AND		DECODE(NVL(:p_hide_rankable, 0), 0, 0, NVL(fe.is_rankable,0)) = 0
				ORDER BY ' ||
					CASE p_order
               WHEN 2 THEN 'fe.audience_24h DESC, fe.audience DESC,'
					     WHEN 3 THEN 'fe.rating_24h DESC, fe.rating DESC,'
					     WHEN 4 THEN 'fe.rating_total DESC,'
               ELSE ''
          END
          || '
					originalpublishingdate DESC,
					creationdate DESC,
          publishdate DESC,
					dateins DESC
    ),
    PAGINATION AS
    (
      SELECT subsql.*,
      ROWNUM RN
      FROM subsql
      WHERE rownum < (:p_first + :p_count)
    )
    select pag.*, (	SELECT CASE WHEN
            ( SELECT 1
              FROM linkobjects lo,
                         live_channels lc,
                         cdn_lives cl
              WHERE lo.tlocal = 1
              AND	lo.tremote = 52
              AND	lo.vlocal =  pag.id
              AND	lo.vremote = lc.id
              AND	NVL(lc.wmp_high, lc.wmp_low) = cl.id )
            IS NOT NULL THEN 1 ELSE 0 END AS islive FROM dual
        ) as islive
    from PAGINATION pag
    WHERE rn >= :p_first' USING p_instance_id, p_channel_id, p_hide_adult, p_hide_rankable, p_first, p_count, p_first;

END SP_GET_CONTENT_LIST;



Alterações em ambiente orahlg05:
----- TABLE: TTV3_FRONTEND_B
--> indice alterado
create index IBOXNET_HLG.IDX_TTV3_FRONTEND_B_ORD2_NEW on IBOXNET_HLG.TTV3_FRONTEND_B (INSTANCE_ID, CHANNEL_ID, AUDIENCE_24H DESC, AUDIENCE DESC, originalpublishingdate 

DESC, creationdate DESC, publishdate DESC, dateins desc)
tablespace IBOXNET_DAT
nologging
parallel;
  
--> novo indice
create index IBOXNET_HLG.IDX_TTV3_FRONTEND_B_ORD6 on IBOXNET_HLG.TTV3_FRONTEND_B (INSTANCE_ID, CHANNEL_ID, RATING_24H DESC, rating DESC, originalpublishingdate DESC, 

creationdate DESC, publishdate DESC, dateins desc)
tablespace IBOXNET_DAT
nologging
parallel;

create index IBOXNET_HLG.IDX_TTV3_FRONTEND_B_ORD7
on  IBOXNET_HLG.TTV3_FRONTEND_B(INSTANCE_ID, CHANNEL_ID, RATING_TOTAL DESC, originalpublishingdate DESC, creationdate DESC, publishdate DESC, dateins desc)
tablespace IBOXNET_DAT
nologging
parallel;


------- TABLE: TTV3_FRONTEND_A
--> indice alterado
create index IBOXNET_HLG.IDX_TTV3_FRONTEND_A_ORD2_NEW on IBOXNET_HLG.TTV3_FRONTEND_A (INSTANCE_ID, CHANNEL_ID, AUDIENCE_24H DESC, AUDIENCE DESC, originalpublishingdate 

DESC, creationdate DESC, publishdate DESC, dateins desc)
tablespace IBOXNET_DAT
nologging
parallel;
    
--> novo indice
create index IBOXNET_HLG.IDX_TTV3_FRONTEND_A_ORD6 on IBOXNET_HLG.TTV3_FRONTEND_A (INSTANCE_ID, CHANNEL_ID, RATING_24H DESC, RATING DESC, originalpublishingdate DESC, 

creationdate DESC, publishdate DESC, dateins desc)
tablespace IBOXNET_DAT
nologging
parallel;

create index IBOXNET_HLG.IDX_TTV3_FRONTEND_A_ORD7
on  IBOXNET_HLG.TTV3_FRONTEND_A(INSTANCE_ID, CHANNEL_ID, RATING_TOTAL DESC, originalpublishingdate DESC, creationdate DESC, publishdate DESC, dateins desc)
tablespace IBOXNET_DAT
nologging
parallel;
--------------------------------------------------------
--> remove indices antigos: 
drop index IBOXNET_HLG.IDX_TTV3_FRONTEND_B_ORD2;
drop index IBOXNET_HLG.IDX_TTV3_FRONTEND_A_ORD2;
--------------------------------------------------------
--> rename do indices
alter index IBOXNET_HLG.IDX_TTV3_FRONTEND_B_ORD2_NEW RENAME TO IDX_TTV3_FRONTEND_B_ORD2;
alter index IBOXNET_HLG.IDX_TTV3_FRONTEND_A_ORD2_NEW RENAME TO IDX_TTV3_FRONTEND_A_ORD2;
--------------------------------------------------------


