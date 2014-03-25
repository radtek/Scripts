col NAME format a10
col SOFTWARE_VERSION format a15
col COMPATIBLE_VERSION format a15

SELECT I.DB_NAME, I.STATUS, DG.NAME, DG.TOTAL_MB, DG.FREE_MB, I.SOFTWARE_VERSION, I.COMPATIBLE_VERSION
FROM V$ASM_CLIENT I
	INNER JOIN V$ASM_DISKGROUP DG
		ON I.GROUP_NUMBER = DG.GROUP_NUMBER;