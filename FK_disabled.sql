select  OWNER,
        TABLE_NAME,
        CONSTRAINT_NAME,
        decode(CONSTRAINT_TYPE, 'C','Check',
                                'P','Primary Key',
                                'U','Unique',
                                'R','Foreign Key',
                                'V','With Check Option') type,
        STATUS 
from 	dba_constraints
where 	STATUS = 'DISABLED'
order 	by OWNER, TABLE_NAME, CONSTRAINT_NAME;