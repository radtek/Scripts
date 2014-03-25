prompt Gera scripts para mover tabelas ou indices entre tablespaces diferentes

define tbs_name=&tbs_name
define seg_name=&seg_name

set lines 2000
set pages 100

   select decode( segment_type, 'TABLE', 
                          segment_name, table_name ) order_col1,
          decode( segment_type, 'TABLE', 1, 2 ) order_col2,
          'alter ' || segment_type || ' ' || segment_name ||
          decode( segment_type, 'TABLE', ' move ', ' rebuild ' ) || 
          chr(10) ||
          ' tablespace &tbs_name' || chr(10) ||
          ' storage ( initial ' || initial_extent || ' next ' || 
          next_extent || chr(10) ||
          ' minextents ' || min_extents || ' maxextents ' || 
          max_extents || chr(10) ||
          ' pctincrease ' || pct_increase || ' freelists ' || 
          freelists || ');'
   from   user_segments, 
          (select table_name, index_name from user_indexes )
   where   segment_type in ( 'TABLE', 'INDEX' )
   and     segment_name = index_name (+)
   and    segment_name = UPPER('&seg_name')
   order by 1, 2;
undef seg_name;
undef tbs_name;