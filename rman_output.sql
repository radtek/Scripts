select output
from v$rman_output ro
	INNER JOIN v$rman_status rs
		on decode(rs.ROW_LEVEL, 0, ro.SESSION_RECID, ro.RMAN_STATUS_RECID) = rs.RECID
		and decode(rs.ROW_LEVEL, 0, ro.SESSION_STAMP, ro.RMAN_STATUS_STAMP) = rs.STAMP
where rs.recid=&recid
and rs.stamp=&stamp;