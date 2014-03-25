select CHILD_NUMBER,
	   UNBOUND_CURSOR, 
	   SQL_TYPE_MISMATCH, 
	   OPTIMIZER_MISMATCH, 
	   OUTLINE_MISMATCH,
		STATS_ROW_MISMATCH, 
		LITERAL_MISMATCH, 
		EXPLAIN_PLAN_CURSOR,
		BUFFERED_DML_MISMATCH, 
		PDML_ENV_MISMATCH, 
		INST_DRTLD_MISMATCH, 
		SLAVE_QC_MISMATCH,
	    TYPECHECK_MISMATCH, 
		AUTH_CHECK_MISMATCH, 
		BIND_MISMATCH, 
		DESCRIBE_MISMATCH, 
		LANGUAGE_MISMATCH,
	    TRANSLATION_MISMATCH, 
		INSUFF_PRIVS, 
		INSUFF_PRIVS_REM,
		REMOTE_TRANS_MISMATCH, 
		LOGMINER_SESSION_MISMATCH, 
		INCOMP_LTRL_MISMATCH, 
		OVERLAP_TIME_MISMATCH,
		MV_QUERY_GEN_MISMATCH, 
		USER_BIND_PEEK_MISMATCH, 
		TYPCHK_DEP_MISMATCH,
		NO_TRIGGER_MISMATCH, 
		FLASHBACK_CURSOR, 
		ANYDATA_TRANSFORMATION, 
		TOP_LEVEL_RPI_CURSOR, 
		DIFFERENT_LONG_LENGTH, 
		LOGICAL_STANDBY_APPLY, 
		DIFF_CALL_DURN,
		BIND_UACS_DIFF, 
		PLSQL_CMP_SWITCHS_DIFF, 
		CURSOR_PARTS_MISMATCH, 
		STB_OBJECT_MISMATCH,
		PQ_SLAVE_MISMATCH, 
		TOP_LEVEL_DDL_MISMATCH, 
		MULTI_PX_MISMATCH,
		BIND_PEEKED_PQ_MISMATCH, 
		MV_REWRITE_MISMATCH, 
		ROLL_INVALID_MISMATCH, 
		OPTIMIZER_MODE_MISMATCH,
		PX_MISMATCH, 
		MV_STALEOBJ_MISMATCH, 
		FLASHBACK_TABLE_MISMATCH, 
		LITREP_COMP_MISMATCH
from V$SQL_SHARED_CURSOR
where sql_id = '&sql_id';