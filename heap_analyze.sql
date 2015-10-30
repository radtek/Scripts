set echo off
--------------------------------------------------------
-- @name: heap_analyze
-- @author: dion cho
-- @note: analyze heap dump file.
--    this is a example of how to analyze heap dump only works only for
--  my local database 10gR2(windows)
--  get_trace_file script should be executed beforehand
-- @usage: heap_analyze <file_name>
--------------------------------------------------------
set verify off

/* -- execute following object at initial step
drop table t_heap_dump purge;

create global temporary table t_heap_dump(
    heap_name varchar2(20),
    chunk_type varchar2(20),
    obj_type varchar2(20),
    subheap        varchar2(20),
    chunk_size number
);


create or replace function f_get_N(p_value in number)
return number
is
    v_n   number := 1;
begin
    
    for idx in 1 .. 1000000 loop
        v_n := v_n * 2;
        
        if v_n >= p_value then
            return v_n;
        end if;
    end loop;

    return 1;
end;
/

*/

delete from t_heap_dump;

declare
    v_heap_name            t_heap_dump.heap_name%TYPE;
    v_chunk_type        t_heap_dump.chunk_type%TYPE;
    v_obj_type            t_heap_dump.obj_type%TYPE;
    v_subheap                t_heap_dump.obj_type%TYPE;
    v_chunk_size        t_heap_dump.chunk_size%TYPE;
    b_count_heap                boolean := false;
begin
    for r in (select * from table(get_trace_file2('&1'))) loop
        if instr(r.column_value, 'heap name=') > 0 then
            v_heap_name := substr(regexp_substr(r.column_value,
                                                        'heap name="[[:print:]]+"'),11);
            v_heap_name := regexp_replace(v_heap_name, '"([[:print:]]+)"', '\1');
            b_count_heap := true;
            dbms_output.put_line('heap_name='||v_heap_name);
        end if;
        
        if instr(r.column_value, 'Total heap size') > 0 then
                b_count_heap := false;
        end if;
        
        if b_count_heap then 
            if instr(r.column_value, 'Chunk') >0 then
                v_chunk_type := regexp_substr(r.column_value, '(R\-freeable|R\-free|freeable|free|perm|recreate)');
                v_obj_type := regexp_substr(r.column_value, '"[[:print:]]+"');
                v_obj_type := trim(regexp_replace(v_obj_type,  '"([[:print:]]+)"', '\1'));
                v_subheap := regexp_substr(r.column_value, 'ds=[[:xdigit:]]+',4);
                v_chunk_size := substr(regexp_substr(r.column_value, 'sz=[ ]*[[:digit:]]+'),4);
                               
              insert into t_heap_dump(heap_name, chunk_type, obj_type, subheap, chunk_size)
                values(v_heap_name, v_chunk_type, v_obj_type, v_subheap, v_chunk_size);
            end if;
          end if;
    end loop;
end;
/

col chunk_type format a15
col obj_type format a20
col cnt format 999,999
col sz format 999,999.9
col hsz format 999,999.9
--col tsz format 999,999.9
col hratio format 999.9
col tratio format 999.9
col hist format a15

set line 100

spool heap_analyze.txt

-- size per heap
prompt 01. size per heap
select
    heap_name, sum(chunk_size)/1024/1024 as hsz
from
    t_heap_dump
group by heap_name
order by 2 desc
;


-- chunk_type
prompt 02. size per chunk type
with x as (
    select
        heap_name, chunk_type, cnt, sz,
        sum(sz) over(partition by heap_name) as hsz
    from (
        select heap_name, chunk_type, count(*) as cnt, sum(chunk_size) as sz
        from t_heap_dump
        group by heap_name, chunk_type
        order by 1 asc, 4 desc
    )
)
select heap_name, chunk_type, cnt,
             (sz/1024/1024) as sz,
             (hsz/1024/1024) as hsz,
             (sz/hsz)*100 as hratio
from x
;

-- obj_type
prompt 03. size per object type
with x as (
    select
        heap_name, obj_type, cnt, sz,
        sum(sz) over(partition by heap_name) as hsz
    from (
        select heap_name, obj_type, count(*) as cnt, sum(chunk_size) as sz
        from t_heap_dump
        group by heap_name, obj_type
        order by 1 asc, 4 desc
    )
)
select heap_name, obj_type, cnt,
             (sz/1024/1024) as sz,
             (hsz/1024/1024) as hsz,
             (sz/hsz)*100 as hratio
from x
;


-- subheap
prompt 04. size per subheap
with x as (
    select
        heap_name, subheap, cnt, sz,
        sum(sz) over(partition by heap_name) as hsz
    from (
        select heap_name, subheap, count(*) as cnt, sum(chunk_size) as sz
        from t_heap_dump
        group by heap_name, subheap
        order by 1 asc, 4 desc
    )
)
select heap_name, subheap, cnt,
             (sz/1024/1024) as sz,
             (hsz/1024/1024) as hsz,
             (sz/hsz)*100 as hratio
from x
;


-- freelists
prompt 05. freelists histogram
with x as (
    select
        heap_name, high/2 as low, high, cnt, sz,
        sum(sz) over (partition by heap_name) as hsz
    from (
            select heap_name, f_get_N(chunk_size) as high, count(*) as cnt, 
                            sum(chunk_size) as sz
            from t_heap_dump
            where chunk_type = 'free'
            group by heap_name, f_get_N(chunk_size)
            order by 1 asc, 3 desc
    )
)
select
    heap_name, '('||low||'~'||high||')' as hist, cnt,
    (sz/1024/1024) as sz,
    (hsz/1024/1024) as hsz,
  (sz/hsz)*100 as hratio
from x
order by heap_name, low, cnt desc
;

 
spool off
@ed heap_analyze.txt
set line 80
set echo on