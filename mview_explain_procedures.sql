whenever SQLerror exit failure;
select aaaa///

-> não precisa ser no sys

create table MV_CAPABILITIES_TABLE
(
  statement_id      varchar(30) ,
  mvowner           varchar(30) ,
  mvname            varchar(30) ,
  capability_name   varchar(30) ,
  possible          character(1) ,
  related_text      varchar(2000) ,
  related_num       number ,
  msgno             integer ,
  msgtxt            varchar(2000) ,
  seq               number
) ;


create or replace function my_mv_capabilities
(
  p_mv                       in  varchar2 ,
  p_capability_name_filter   in  varchar2 default '%' ,
  p_include_pct_capabilities in  varchar2 default 'N' ,
  p_linesize                 in  number   default 80
)
  return clob
as
  --------------------------------------------------------------------------------
  -- From http://www.sqlsnippets.com/en/topic-12884.html
  --
  -- Parameters:
  --
  --   p_mv
  --     o this value is passed to DBMS_MVIEW.EXPLAIN_MVIEW's "mv" parameter
  --     o it can contain either a query, CREATE MATERIALIZED VIEW command text,
  --       or a materialized view name
  --
  --   p_capability_name_filter
  --     o use either REFRESH, REWRITE, PCT, or the default
  --
  --   p_include_pct_capabilities
  --     Y - capabilities like REFRESH_FAST_PCT are included in the report
  --     N - capabilities like REFRESH_FAST_PCT are not included in the report
  --
  --   p_linesize
  --     o the maximum size allowed for any line in the report output
  --     o data that is longer than this value will be word wrapped
  --
  -- Typical Usage:
  --
  --   set long 5000
  --   select my_mv_capabilities( 'MV_NAME' ) as mv_report from dual ;
  --
  --   o the value 5000 is arbitraty; any value big enough to contain the
  --     report output will do
  --
  --------------------------------------------------------------------------------

  pragma autonomous_transaction ;

  v_nl constant char(1) := unistr( '\000A' ); -- new line

  v_previous_possible char(1) := 'X' ;

  v_capabilities sys.ExplainMVArrayType ;

  v_output clob ;

begin

  dbms_mview.explain_mview( mv => p_mv, msg_array => v_capabilities ) ;

  for v_capability in
  (
    select
      capability_name ,
      possible ,
      related_text ,
      msgtxt
    from
      table( v_capabilities )
    where
      capability_name like '%' || upper( p_capability_name_filter ) || '%' and
      not
        ( capability_name like '%PCT%' and
          upper(p_include_pct_capabilities) = 'N'
        )
    order by
      mvowner ,
      mvname ,
      possible desc ,
      seq
  )
  loop

    ------------------------------------------------------------
    -- print section heading
    ------------------------------------------------------------

    if v_capability.possible <> v_previous_possible then

      v_output :=
        v_output
        || v_nl
        || case v_capability.possible
           when 'T' then 'Capable of: '
           when 'Y' then 'Capable of: '
           when 'F' then 'Not Capable of: '
           when 'N' then 'Not Capable of: '
           else v_capability.possible || ':'
           end
        || v_nl
      ;

    end if;

    v_previous_possible := v_capability.possible ;

    ------------------------------------------------------------
    -- print section body
    ------------------------------------------------------------
    declare

      v_indented_line_size varchar2(3) := to_char( p_linesize - 5 );

    begin

      -- print capability name indented 2 spaces

      v_output :=
        v_output
        || v_nl
        || '  '
        || v_capability.capability_name
        || v_nl
      ;

      -- print related text indented 4 spaces and word wrapped

      if v_capability.related_text is not null then

        v_output :=
          v_output
          || regexp_replace
             ( v_capability.related_text || ' '
             , '(.{1,'
                 || v_indented_line_size || '} |.{1,'
                 || v_indented_line_size || '})'
             , '    \1' || v_nl
             )
        ;

      end if;

      -- print message text indented 4 spaces and word wrapped

      if v_capability.msgtxt is not null then

        v_output :=
          v_output
          || regexp_replace
             ( v_capability.msgtxt || ' '
             , '(.{1,'
                 || v_indented_line_size || '} |.{1,'
                 || v_indented_line_size || '})'
             , '    \1' || v_nl
             )
        ;

      end if;

    end;

  end loop;

  commit ;

  return( v_output );

end;
/

truncate table MV_CAPABILITIES_TABLE;
select my_mv_capabilities( 'MVW_MENSAGEM_ANUNCIO', 'REFRESH' ) as mv_report from dual ;

