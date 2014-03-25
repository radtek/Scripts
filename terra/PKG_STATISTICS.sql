create or replace package PKG_STATISTICS is

  -- Author  : FERNANDO.FISCHER
  -- Created : 14/2/2011 16:41:18
  -- Purpose : Retornar estatísticas para o SEMON, Big Brother e Relatórios


  -- Public function and procedure declarations
  function F_STAT_SEMON return pkg_vcmlive_util.cRefCursor;

  function F_LAST_COUNTRY_PUBLISH return pkg_vcmlive_util.cRefCursor;

  function F_PUBLISHED_ITEMS_PERIOD(p_vDateInitial in varchar2,
                                    p_vDateFinal in varchar2) return pkg_vcmlive_util.cRefCursor;
                                    
end PKG_STATISTICS;
/
create or replace package body PKG_STATISTICS is

function F_STAT_SEMON return pkg_vcmlive_util.cRefCursor is  
/*
Objetivo: Stored Function para retornar estatisticas de conteúdos publicados por site
          para o Semon.

Histórico de alterações:
09/02/2011 - FF - Criação da Stored Function
*/
   c_cursor pkg_vcmlive_util.cRefCursor;
begin
  open c_cursor for
      select sot.site_name, sot.type_name, nvl(total, 0) total
        from (select c.site_id, c.type_id, count(0) total
                from (select distinct c.id_vcm_content,
                                      ot.id            type_id,
                                      s.id             site_id
                        from vcm_content              c,
                             vcm_channel_tree_content vctc,
                             vcm_channel_tree         vct,
                             vgnassite                s,
                             vgnasobjecttype          ot
                       where c.first_date_published >
                             current_date - 5 / 60 / 24 -- ultimos 5 minutos
                         and c.id_vcm_object_type = ot.id
                         and c.id_vcm_content = vctc.id_vcm_content
                         and vctc.id_vcm_channel_tree =
                             vct.id_vcm_channel_tree
                         and vct.id_site = s.id) c
               group by c.site_id, c.type_id) grup,
             (select s.id    site_id,
                     s.name  site_name,
                     ot.id   type_id,
                     ot.name type_name
                from vgnassite s, vgnasobjecttype ot
               where ot.id in
                     ('ca4a4e75b5419110VgnVCM1000005801010a____',
                      '98e44e75b5419110VgnVCM1000005801010a____',
                      'a2594e75b5419110VgnVCM1000005801010a____',
                      '7a8897708eb2a110VgnVCM100000a61d31c9____')) sot
       where sot.site_id = grup.site_id(+)
         and sot.type_id = grup.type_id(+)
       order by sot.site_name, sot.type_name;  

   return(c_cursor);
   
end F_STAT_SEMON;

function F_LAST_COUNTRY_PUBLISH return pkg_vcmlive_util.cRefCursor is
/*
Objetivo: Stored Function para retornar a quantos minutos atras foi publicado um contudo para o pais.
          Consulta chamada pela monitoracao.

Histórico de alterações:
09/02/2011 - FF - Criação da Stored Function
*/
   c_cursor pkg_vcmlive_util.cRefCursor;
begin  

   open c_cursor for
     select /*+ Leading(c) */
         s.name site_name,
           round((current_date - max(c.first_date_published)) * 1440,0) minutes_ago
      from vcm_content              c,
           vcm_channel_tree_content vctc,
           vcm_channel_tree         vct,
           vgnassite                s
     where c.id_vcm_content = vctc.id_vcm_content
       and vctc.id_vcm_channel_tree = vct.id_vcm_channel_tree
       and vct.id_site = s.id
       and c.first_date_published > current_date - 4
     group by s.name;

   return(c_cursor);  
  
end F_LAST_COUNTRY_PUBLISH;




function F_PUBLISHED_ITEMS_PERIOD(p_vDateInitial in varchar2,
                                  p_vDateFinal in varchar2) return pkg_vcmlive_util.cRefCursor is
/*
Objetivo: Stored Function para retornar a quantos minutos atras foi publicado um contudo para o pais.
          Consulta chamada pela monitoracao.

Histórico de alterações:
09/02/2011 - FF - Criação da Stored Function
*/
   c_cursor pkg_vcmlive_util.cRefCursor;
begin
	
  open c_cursor for
      select s.name  site_name,
             ot.name type_name,
             ( -- total para cada site - tipo
                        select count(0)
                              from vcm_content              c,
                                   vcm_channel_tree_content vctc,
                                   vcm_channel_tree         vct,
                                   atomo_vgn_news           n,
                                   atomo_vgn_gallery        g,
                                   atomo_vgn_headline       h,
                                   atomo_vgn_link           l
                             where c.first_date_published between to_date(p_vDateInitial,'dd/mm/yyyy hh24:mi:ss') and to_date(p_vDateFinal,'dd/mm/yyyy hh24:mi:ss')
                               and c.id_vcm_object_type = ot.id
                               and c.id_vcm_content = vctc.id_vcm_content
                               and vctc.id_vcm_channel_tree = vct.id_vcm_channel_tree
                               and c.id_vcm_content_shift = n.id_news(+)
                               and c.id_vcm_content_shift = g.id_gallery(+)
                               and c.id_vcm_content_shift = h.id_headline(+)
                               and c.id_vcm_content_shift = l.id_link(+)
                               and (g.platform_source != 'FEED'
                                    or n.platform_source != 'FEED'
                                    or c.id_vcm_object_type in ('a2594e75b5419110VgnVCM1000005801010a____','7a8897708eb2a110VgnVCM100000a61d31c9____')
                                    )
                               and vct.id_site = s.id
                               and c.id_vcm_object_type = ot.id
             )
        from vgnassite s, vgnasobjecttype ot
       where ot.id in
             ('ca4a4e75b5419110VgnVCM1000005801010a____',
              '98e44e75b5419110VgnVCM1000005801010a____',
              'a2594e75b5419110VgnVCM1000005801010a____',
              '7a8897708eb2a110VgnVCM100000a61d31c9____') 
      order by site_name, type_name;  
    
   return(c_cursor);  

return null;


end F_PUBLISHED_ITEMS_PERIOD; 
 
  
  
end PKG_STATISTICS;
/
