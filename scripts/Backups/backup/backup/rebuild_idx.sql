conn system/htg75cdba
set echo on
set time on
set timing on


Alter index Acct.MOVI_DTCHEGADA_IDX    rebuild Partition MENORQ_20070701 Tablespace ACCT_MOV_INDX_P81 Nologging;
Alter index Acct.MOVI_IPASSINALADO_IDX rebuild Partition MENORQ_20070701 Tablespace ACCT_MOV_INDX_P81 Nologging;
Alter index Acct.PK_TRR_MOVIMENTOS     rebuild Partition MENORQ_20070701 Tablespace ACCT_MOV_INDX_P81 Nologging;

Spool off;
exit;

