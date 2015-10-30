-> Antes:
select d.id_vcm_content, d.name, d.first_date_published, 
decode(d.id_vcm_object_type,'5a124e75b5419110VgnVCM1000005801010a____','C','N') type
from (
select ROWNUM rnum, c.*
from (Select distinct a.*
from (select /*+ First_rows(1000) leading(ctc) index(ctc 
IDX_VCM_CHAN_TR_CONT_ACCT2) */ 
ctc.id_vcm_content, ctc.name, ctc.first_date_published, 
ctc.id_vcm_object_type
from vcm_channel_tree_content ctc where ctc.FIRST_DATE_PUBLISHED < 
current_date + 1 
and ctc.hide_content is null 
and ctc.is_active = 1 
and SUBSTR(F_VCMCONT_ACCOUNT_PLAN(CTC.ACCOUNT_PLAN,2),1,50) 
= '2.2.'
and (ctc.id_vcm_object_type = 
'5a124e75b5419110VgnVCM1000005801010a____'
or ctc.id_vcm_object_type = 
'ca4a4e75b5419110VgnVCM1000005801010a____' ) 
order by SUBSTR(F_VCMCONT_ACCOUNT_PLAN(ACCOUNT_PLAN,2),1,50), 
FIRST_DATE_PUBLISHED DESC, ID_VCM_OBJECT_TYPE ) a
where rownum <= 50 *12
order by first_date_published desc
) c
)d
where d.rnum <= 50 and d.rnum >= 1;

-> Depois:
select c.id_vcm_content, C.name, c.first_date_published, 
decode(C.id_vcm_object_type,'5a124e75b5419110VgnVCM1000005801010a____','C','N') type
from(select /*+ no_merge*/ c.*, row_number() over(order by first_date_published desc, name) rnum
from(select /*+ First_rows(1000) index(ctc IDX_VCM_CHAN_TR_CONT_ACCT2) */ 
distinct dense_rank() over(order by 
SUBSTR(F_VCMCONT_ACCOUNT_PLAN(ACCOUNT_PLAN,2),1,50), FIRST_DATE_PUBLISHED DESC, 
ID_VCM_OBJECT_TYPE) rnk,
ctc.id_vcm_content, ctc.name, ctc.first_date_published, ctc.id_vcm_object_type
from vcm_channel_tree_content ctc 
where ctc.FIRST_DATE_PUBLISHED < current_date + 1 
and ctc.hide_content is null 
and ctc.is_active = 1 
and SUBSTR(F_VCMCONT_ACCOUNT_PLAN(CTC.ACCOUNT_PLAN,2),1,50) = '2.2.'
and (ctc.id_vcm_object_type = '5a124e75b5419110VgnVCM1000005801010a____'
or ctc.id_vcm_object_type = 'ca4a4e75b5419110VgnVCM1000005801010a____' )) c	
where c.rnk <= 50 and c.rnk >= 1) c
where c.rnum <= 50 and c.rnum >= 1
order by c.first_date_published desc ;