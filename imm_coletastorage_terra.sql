set serveroutput on
declare
    nRun_id          number;
    nCount           number;
    nTotal_blocks    number;
    nTotal_bytes     number;
    nUnused_blocks   number;
    nUnused_bytes    number;
    nLast_used_file_id number;
    nLast_used_ext_id  number;
    nLast_used_block   number;
    dono   varchar2(100);
    segmento   varchar2(100);
    tipo   varchar2(100);
    cursor c1 is
        with sqls as
(
   select /*+ materialize */ owner,segment_name,
           decode(segment_type,'LOBSEGMENT','LOB','LOBINDEX','INDEX','NESTED TABLE','TABLE',segment_type) segment_type,
               partition_name, tablespace_name
        from dba_segments
        where segment_type not in ('CACHE','ROLLBACK','TEMPORARY','TYPE2 UNDO') and
              owner not in ('SYS')
),
sqls2 as
(
   select /*+ materialize */ t.tablespace_name
        from dba_tablespaces t, dba_data_files df, v$datafile f
        where t.tablespace_name = df.tablespace_name and
           df.file_name = f.name and
                f.status = 'OFFLINE'
)
        select /*+ use_hash(s s2) */ owner,
           segment_name,
               segment_type,
               partition_name
        from sqls s
           left join sqls2 s2
                   on  s.tablespace_name = s2.tablespace_name
        where  s2.tablespace_name is null;
begin
    select count(1)
     into nCount
     from system.imm_storage;
    if nCount = 0  then
        nRun_id := 1;
    else
        select max(nvl(run_id,0))+1
         into nRun_id
         from system.imm_storage;
    end if;
    nCount := 0;
    for c1_rec in c1 loop
        dono := c1_rec.owner;
        segmento := c1_rec.segment_name;
        tipo := c1_rec.segment_type;
        dbms_space.unused_space(c1_rec.owner,c1_rec.segment_name,c1_rec.segment_type,
                  nTotal_blocks,nTotal_bytes,nUnused_blocks,nUnused_bytes,
                  nLast_used_file_id,nLast_used_ext_id,nLast_used_block,c1_rec.partition_name);
        insert into system.imm_storage values (nRun_id,sysdate,
            c1_rec.owner,c1_rec.segment_name,c1_rec.segment_type,c1_rec.partition_name,
            nTotal_blocks,nTotal_bytes,nUnused_blocks,nUnused_bytes,
            nLast_used_file_id,nLast_used_ext_id,nLast_used_block);
        nCount := nCount + 1;
        if mod(nCount,1000) = 0 then
            commit;
        end if;
    end loop;
    exception
     when others then
        delete from system.imm_storage where run_id = nRun_id;
        dbms_output.put_line(dono||' '||segmento||' '||tipo);
        raise_application_error(-20000,sqlerrm,true);
        commit;
end;
/
