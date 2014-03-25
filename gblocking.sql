select  DECODE( l.block, 0, '       ','YES    ') BLOCKER,
        DECODE( l.block, 0, 'YES    ','       ') WAITER,
        l.INST_ID, l.SID, l.TYPE, l.ID1, l.ID2, l.LMODE, l.REQUEST, l.CTIME, l.BLOCK
from gv$lock l
where (ID1,ID2,TYPE) in
(select ID1,ID2,TYPE from gv$lock where request>0)     
order by id1,id2,waiter;