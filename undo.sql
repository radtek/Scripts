col rname format a20
col username format a30
col machine format a30
col sid format 999999
select r.name rname,rs.extents,u.username,u.sql_id,u.machine,
       u.sid, t.used_ublk,t.used_urec, t.start_uext,
       t.log_io,t.phy_io,t.start_time
from v$rollname r     ,
     v$session u     ,
     v$transaction t     ,
     v$rollstat rs
where r.usn=t.xidusn(+)
  and u.taddr(+)=t.addr
  and rs.usn=r.usn
  and t.used_ublk > 0
order by t.start_time, r.name;

select * from GV$FAST_START_TRANSACTIONS where state <> 'RECOVERED';