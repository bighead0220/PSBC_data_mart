/*
Author             :dhy
Function           :���˴���˻���Ϣ��
Load method        :INSERT
Source table       :DW_SDATA.LCS_000_PK_CBK_BASE,DW_SDATA.LCS_000_PK_CBK_SUBACC_CLS,DW_SDATA.LCS_000_CARD_SC_BASE,DW_SDATA.LCS_000_CARD_SC_ACCTYPE,DW_SDATA.LCS_000_CARD_SC_CLS,DW_SDATA.LCS_000_CARD_OC_BASE,DW_SDATA.LCS_000_CARD_OC_ACCTYPE,DW_SDATA.LCS_000_CARD_OC_SUBACC_CLS,DW_SDATA.LCS_000_CARD_PUB_PAPER,DW_SDATA.LCS_000_PK_CBK_PAPER,DW_SDATA.ACC_000_T_INT_PRSN_CDM_DTL,DW_SDATA.LCS_000_QRY_CDM_DTL,DW_SDATA.LCS_000_CARD_CDM_LEG,DW_SDATA.LCS_000_PK_CDM_PAPERD,DW_SDATA.ACC_003_T_ACC_CDM_LEDGER,DW_SDATA.LCS_000_CARD_PUB_SVT,DW_SDATA.LCS_000_T_PUB_ITMRATE,DW_SDATA.LCS_000_PARA_RATE,DW_SDATA.LCS_000_SRM_RATE,DW_SDATA.ACC_003_T_ACCDATA_LAST_ITEM_NO,DW_SDATA.LCS_000_CARD_FC_CDM_LEG,DW_SDATA.ACC_003_T_ACC_CDM_FC_LEDGER,DW_SDATA.LCS_000_T_PUB_ITMRATE,DW_SDATA.ACC_003_T_INT_PRSN_CDM_FC_DTL,DW_SDATA.LCS_000_CARD_PUB_FC_SVT,DW_SDATA.LCS_000_PK_FIX_LEG,DW_SDATA.ACC_003_T_ACC_FIX_LEDGER,DW_SDATA.ACC_003_T_INT_PRSN_FIX_DTL,DW_SDATA.LCS_000_TSF_FIX_INT,DW_SDATA.LCS_000_PK_FIX_INT,DW_SDATA.LCS_000_PK_FC_FIX_LEG,DW_SDATA.ACC_003_T_ACC_FIX_FC_LEDGER,DW_SDATA.LCS_000_TSF_FC_FIX_INT,DW_SDATA.LCS_000_PK_FC_FIX_INT,DW_SDATA.LCS_000_PK_FC_FIX_INT,DW_SDATA.ACC_003_T_INT_PRSN_FIX_FC_DTL
Frequency          :D
Modify history list:Created by
                   :Modify  by liuxz 20160714 acc_003_T_INT_PRSN_CDM_DTL  ��Ϊ acc_000_T_INT_PRSN_CDM_DTL 
                   :modified by wyh 20160902 ����»����������
                   :Modify by gln 20160907  �޸ĵ�һ�飬���������ȥ�� 
                   :MOdify by wyh 20160925 �޸�lcs_000_pub_itmrate���߼�,��������ظ�����
                   :modify by zhangliang �޸���3��4   t3���Լ�t5������������i
                    modified by wyh at 20160930 ���3ȥ��PK�߼�������������ʼ�����
-------------------------------------------�߼�˵��---------------------------------------------
ҵ���߼�˵��
���˴���˻���Ϣ�� ���� ���ڱ��� ������� ���ڱ��� ������� ��������ӹ����ɡ�
*-------------------------------------------�߼�˵��END------------------------------------------
*/

/*���ݻ�����*/
delete from  f_fdm.F_DPST_INDV_ACCT where etl_date = '$TXDATE'::DATE;
/*���ݻ�����end*/
/*��ʱ��*/
--- ���˻��ڱ����˻�ȥ��
create local temporary table IF NOT EXISTS card_cdm_leg_tmp
 on commit preserve rows as
select * from 
 (
 select 
        acc,
         bgn_int_date,
         SVT_NO,
         b_flag,
        row_number()over(partition by acc order by bgn_int_date desc  ) rn 
   from dw_sdata.lcs_000_card_cdm_leg 
  where start_dt<='$TXDATE'::date and '$TXDATE'::date<end_dt 
  )  t where rn = 1
;
--- �˺�����ʺ� ��Ӧ��ϵ
create local temporary table IF NOT EXISTS TT_acct_med_rel 
  on commit preserve rows as
 select A.sign_id as sign_id ,
        coalesce(b.ecif_cust_no,c.ecif_cust_no) as ecif_cust_no
  from (select party_id,
               sign_id,
               row_number()over(partition by sign_id order by last_updated_ts desc) rn 
           from dw_sdata.ecf_001_t02_cust_acct_rel 
          where start_dt <='$TXDATE'
            and end_dt > '$TXDATE'   
        ) A 
  left join (select party_id,
                    ecif_cust_no,
                    row_number()over(partition by ecif_cust_no order by last_updated_ts desc )rn 
               from dw_sdata.ecf_001_t01_cust_info 
              where updated_ts = '99991231 00:00:00:000000'
 
                and start_dt <='$TXDATE'
                and end_dt > '$TXDATE'
             ) B
    on a.party_id = b.party_id
   and b.rn = 1
  left join (select party_id ,
                    ecif_cust_no,
                    row_number()over(partition by ecif_cust_no order by last_updated_ts desc ) rn
                 from dw_sdata.ecf_004_t01_cust_info
                where updated_ts = '99991231 00:00:00:000000'
                  and start_dt <='$TXDATE'
                  and end_dt > '$TXDATE'
             ) C
    on a.party_id = c.party_id
   and c.rn = 1 
 where a.rn = 1 ;
-- ���ڼ�Ϣ
create local temporary table IF NOT EXISTS TT_ACC_provs_Int 
  on commit preserve rows as
select ACC,  
       sum(case when ACC_DATE = '$TXDATE' then TRAN_AMT else 0 end ) as TRAN_AMT_D  -- ��
       ,sum(case when substr(ACC_DATE,1,6) = substr('$TXDATE',1,6) and  ACC_DATE <= '$TXDATE'   then TRAN_AMT else 0 end ) as TRAN_AMT_M  -- ��
      -- ,sum(case when  etl_dt<='$TXDATE'   then TRAN_AMT  else 0 end ) TRAN_AMT_SUM --�ۻ�
  from dw_sdata.acc_000_T_INT_PRSN_CDM_DTL 
 group by ACC
 ;
 -- ���ڸ�Ϣ
create local temporary table IF NOT EXISTS TT_ACC_Paid_Int 
  on commit preserve rows as
 SELECT ACC,
        SUM(CASE WHEN ('$MINDATE'::date + tran_date-2)::date  = '$TXDATE'::date THEN amt ELSE 0 END)Today_Int_Pay ,
        SUM(CASE WHEN month(('$MINDATE'::date + tran_date-2)::date )=month('$TXDATE'::date) and  ('$MINDATE'::date + tran_date-2)::date<='$TXDATE'::date  THEN amt else 0 end) CurMth_Paid_Int  
        --SUM(case when etl_dt<='$TXDATE' then amt else 0 end) Accm_Paid_Int
  FROM DW_SDATA.lcs_000_qry_cdm_dtl  --���ڽ�����ϸ��
 WHERE amt_type in ('3', '4')  --  ��Ϣ��Ϣ
   AND N_TRAN_TYPE = '0' -- �������� ����0
 GROUP BY 1;
-----���ڷֻ��ǼǱ������ң�ȥ�ش���                                        modified by wyh at 20160930
create local temporary table IF NOT EXISTS pk_fix_leg_tmp
 on commit preserve rows as
select  * from
 (
 select
        *,
        row_number()over(partition by acc order by bgn_int_date desc,bal desc ) rn
   from  dw_sdata.lcs_000_pk_fix_leg  -- ���ڷֻ��ǼǱ������ң�
  where start_dt<='$TXDATE'::date and '$TXDATE'::date<end_dt
  )  t where rn = 1
;

  
/*��ʱ�� end*/
/*���ݴ�����*/
  
  -- ���� ����
insert into f_fdm.F_DPST_INDV_ACCT
(etl_date
,grp_typ
,Agmt_Id
,Cust_Num
,Org_Num
,Cur_Cd
,Prod_Cd
,dpst_cate_cd
,Cash_Ind_Cd
,St_Int_Dt
,Due_Dt
,Open_Acct_Day
,Clos_Acct_Day
,Exec_Int_Rate
,Bmk_Int_Rate
,Basis
,Int_Base_Cd
,Cmpd_Int_Calc_Mode_Cd
,Is_Nt_Int_Ind
,Pre_Chrg_Int
,Int_Rate_Attr_Cd
,Orgnl_Term
,Orgnl_Term_Corp_Cd
,Rprc_Prd
,Rprc_Prd_Corp_Cd
,Last_Rprc_Day
,Next_Rprc_Day
,Is_AutoRnw
,Last_AutoRnw_Dt
,Agmt_Stat_Cd
,Prin_Subj
,Curr_Bal
,Int_Subj
,Today_Provs_Int
,CurMth_Provs_Int
,Accm_Provs_Int
,Today_Int_Pay
,CurMth_Paid_Int
,Accm_Paid_Int
,Int_Adj_Amt
,Mth_Accm
,Yr_Accm
,Mth_Day_Avg_Bal
,Yr_Day_Avg_Bal
,Sys_Src
 )
select '$TXDATE'::date,
       1,
       T.acc,
       --coalesce(a.cust_num,d.cstm_no),
       coalesce(t1.ecif_cust_no,''),
       coalesce(T2.OP_INST,''),
       '156',
       T.SVT_NO,
       coalesce(T3.cal_flag,''),
       '',
       ('$MINDATE'::date+T.BGN_INT_DATE-2)::date,
       '$MAXDATE' :: date ,
       coalesce(T2.OP_DATE::date,'$MINDATE' :: date ),
       coalesce(T2.CLS_DATE::date,'$MINDATE' :: date ),
       coalesce(T5.RATE_VAL,0),
       0.00,
       0.00,
       CASE WHEN SUBSTR(T3.INT_CAL_FLAG,2,1) ='0' THEN '1' --ʵ��/360
            WHEN SUBSTR(T3.INT_CAL_FLAG,2,1) ='1' THEN '10' --30/360
       ELSE '@'||T3.INT_CAL_FLAG
       END , --360��������
       '1', --����
       '1', --��
       '0', --����
       '4', --������
       0,
       '',
       0,
       '',
        coalesce(('$MINDATE'::date+T5.bgn_date-2)::date,'$MINDATE' :: date ),
       '$TXDATE' ::date + 1,
       '',
       '$MINDATE' :: date ,
       --substr(TO_BITSTRING(HEX_TO_BINARY(TO_HEX(T.B_FLAG::integer))),length(TO_BITSTRING(HEX_TO_BINARY(TO_HEX(T.B_FLAG::integer))))), -- ע�⣺���ֶ�Ҫ��תΪ�����ƣ�Ȼ����ұ��𣬽�ȡ�ұߵ�һλ����Ϊ״̬��ʶ��,
       to_char(mod(t.b_flag,2)),
       coalesce(T2.ITM_NO,''),
       coalesce(T2.BAL,0),
       coalesce(T6.ITM_NO,''),
       coalesce(T7.TRAN_AMT_D,0),
       coalesce(T7.TRAN_AMT_M,0),
       0,
       coalesce(T8.Today_Int_Pay,0),
       coalesce(T8.CurMth_Paid_Int,0),
       0,
       0,
      (case
            when '$TXDATE'= '$MONTHBGNDAY'
            then T2.BAL
            else T2.BAL+coalesce(T_yjs.mth_accm,0)
            end
       )                                                                      as mth_accm  --�»���
      ,(case
            when  '$TXDATE' = '$YEARBGNDAY'
            then T2.BAL
            else T2.BAL+coalesce(T_yjs.yr_accm,0)
            end
       )                                                                      as yr_accm   --�����
      ,(case
            when '$TXDATE' = '$MONTHBGNDAY'
            then T2.BAL
            else T2.BAL+coalesce(T_yjs.mth_accm,0)
            end
       )/('$TXDATE'::date-'$MONTHBGNDAY'::date+1)               as mth_day_avg_bal  --���վ����
      ,(case
           when '$TXDATE' = '$YEARBGNDAY'
           then T2.BAL
           else T2.BAL+coalesce(T_yjs.yr_accm,0)
           end
       )/('$TXDATE'::date-'$YEARBGNDAY'::date+1)                    as Yr_Day_Avg_Bal   --���վ����
       ,'LCS'
  from card_cdm_leg_tmp t    --- ���ڷֻ��ǼǱ����ң�  
   left join TT_acct_med_rel t1
     on t.acc = t1.sign_id  
  left join dw_sdata.acc_003_t_acc_cdm_ledger T2 ---��ծ�ഢ����˻����ڷֻ���
    ON T.ACC = T2.ACC
   and T2.SYS_CODE = '99700010000'
   and T2.start_dt <='$TXDATE'
   and T2.end_dt > '$TXDATE' 
  left join dw_sdata.lcs_000_card_pub_svt T3 ------���ֱ� 
    ON T.SVT_NO =T3.SVT_NO 
   and T3.start_dt <='$TXDATE'
   and T3.end_dt > '$TXDATE' 
 /* left join (select distinct t.ITM_NO,t.rate_no,t.CURR_TYPE,t.RATE_KIND FROM dw_sdata.lcs_000_pub_itmrate t)T4 ---��Ŀ���ʶ��ձ�
    ON T.SVT_NO=T4.ITM_NO
   AND T4.CURR_TYPE='156'
   And T4.RATE_KIND ='0'*/
 left join (
select * from (
select t.ITM_NO
--,t.ITM_NAME
,t.CURR_TYPE
,t.RATE_KIND
,t.RATE_NO
--,t.RATE_LEV
,row_number()over(partition by t.ITM_NO,t.CURR_TYPE,t.RATE_KIND order by t.RATE_LEV desc) NUM
FROM dw_sdata.lcs_000_pub_itmrate t
where T.start_dt <='$TXDATE'
   and T.end_dt > '$TXDATE'
)t
where NUM = 1
)T4 ---��Ŀ���ʶ��ձ�
    ON T.SVT_NO=T4.ITM_NO
   AND T4.CURR_TYPE='156'                                                     
   And T4.RATE_KIND ='0'
  left join  (SELECT A. RATE_NO, A. bgn_date , A.RATE_VAL FROM  dw_sdata.lcs_000_srm_rate  A 
              INNER JOIN
             (SELECT RATE_NO,MAX(bgn_date) AS bgn_date  FROM  dw_sdata.lcs_000_srm_rate
              where  ('$MINDATE'::date + bgn_date-2)::date  <='$TXDATE' GROUP  BY RATE_NO  ) B
              ON  A. RATE_NO=B. RATE_NO
              and A. bgn_date =B. bgn_date ) T5 ---���ʱ�
    ON T4.RATE_NO=T5.RATE_NO 
 
  left join dw_sdata.acc_003_t_accdata_last_item_no T6 --��Ŀת����
    ON T2.ITM_NO = T6.AMT_ITM
   AND T6.FIRST_ITM = '20' --��ծ������֧��  
   and T6.start_dt <='$TXDATE'
   and T6.end_dt > '$TXDATE'   
  left join TT_ACC_provs_Int T7 --������Ϣ
    ON T.ACC = T7.ACC 
  left join TT_ACC_Paid_Int T8 -- ��Ϣ
    ON T.ACC = T8.ACC 
left join f_fdm.F_DPST_INDV_ACCT T_yjs
on         t.acc= T_yjs.agmt_id
and  T_yjs.etl_date='$TXDATE'::date-1
 ;


-- ��� ���� 
insert into f_fdm.F_DPST_INDV_ACCT
(etl_date
,grp_typ
,Agmt_Id
,Cust_Num
,Org_Num
,Cur_Cd
,Prod_Cd
,dpst_cate_cd
,Cash_Ind_Cd
,St_Int_Dt
,Due_Dt
,Open_Acct_Day
,Clos_Acct_Day
,Exec_Int_Rate
,Bmk_Int_Rate
,Basis
,Int_Base_Cd
,Cmpd_Int_Calc_Mode_Cd
,Is_Nt_Int_Ind
,Pre_Chrg_Int
,Int_Rate_Attr_Cd
,Orgnl_Term
,Orgnl_Term_Corp_Cd
,Rprc_Prd
,Rprc_Prd_Corp_Cd
,Last_Rprc_Day
,Next_Rprc_Day
,Is_AutoRnw
,Last_AutoRnw_Dt
,Agmt_Stat_Cd
,Prin_Subj
,Curr_Bal
,Int_Subj
,Today_Provs_Int
,CurMth_Provs_Int
,Accm_Provs_Int
,Today_Int_Pay
,CurMth_Paid_Int
,Accm_Paid_Int
,Int_Adj_Amt
,Mth_Accm
,Yr_Accm
,Mth_Day_Avg_Bal
,Yr_Day_Avg_Bal
,Sys_Src
 )
select 
    '$TXDATE'::date, 
     2,
    T.ACC,                           -- Э����
    coalesce(t1.ecif_cust_no,''),    -- �ͻ���
    coalesce(T2.ACC_INST,''),        -- �����������
    T.CURR_TYPE,                     -- ����
    T.SVT_NO,                        -- ����
    coalesce(T14.cal_flag,''),       -- ���������
    T.CH_TYPE,                       -- �ʽ���̬ 
    ('$MINDATE'::date+T.BGN_INT_DATE-2)::date,      -- ��Ϣ��
    '$MAXDATE' :: date ,                        -- ������
    coalesce(T2.OP_DATE::date,'$MINDATE' :: date ),          -- ��������
    coalesce(T2.CLS_DATE::date,'$MINDATE' :: date ),         -- �������� 
    coalesce(T13.RATE_VAL,0),        -- ִ������
    0.00,                -- ��׼����
    0.00,                -- ����
    CASE WHEN SUBSTR(T14.INT_CAL_FLAG,2,1) ='0' THEN '1' --ʵ��/360
         WHEN SUBSTR(T14.INT_CAL_FLAG,2,1) ='1' THEN '10' --30/360
    ELSE  '@'||T14.INT_CAL_FLAG 
    END,                  -- ��Ϣ�������
    '1',                  -- �������㷽ʽ���� Ĭ�ϵ���
    '1',                  -- �Ƿ��Ϣ��־   ��
    '0',                  -- �Ƿ�����Ϣ ����
    '4',                  -- �������Դ��� ������
    0,                    -- ԭʼ����
    '',                   -- ԭʼ���޵�λ����
    0,                    -- �ض�������
    '',                   -- �ض������ڵ�λ����
    coalesce(('$MINDATE'::date+T13.bgn_date-2)::date ,'$MINDATE' :: date ),        -- �ϴ��ض�����
    '$TXDATE'::date + 1,                                         -- �´��ض�����
    '',                   -- �Ƿ��Զ�ת��
    '$MINDATE' :: date ,        -- �ϴ��Զ�ת������ Ĭ�Ͽ�
    to_char(mod(t.b_flag,2)),   -- ���ֶ�Ҫ��תΪ�����ƣ�Ȼ����ұ��𣬽�ȡ�ұߵ�һλ����Ϊ״̬��ʶ��
    coalesce(T2.ITM_NO,''),
    coalesce(T2.BAL,0),
    coalesce(T6.ITM_NO,''),
    coalesce(T7.TRAN_AMT_D,0),
    coalesce(T7.TRAN_AMT_M,0),
    0,
    coalesce(T8.Today_Int_Pay,0),
    coalesce(T8.CurMth_Paid_Int,0),
    0,
    0, -- Ĭ��0
      (case
            when '$TXDATE'= '$MONTHBGNDAY'
            then T2.BAL
            else T2.BAL+coalesce(T_yjs.mth_accm,0)
            end
       )                                                                      as mth_accm  --�»���
      ,(case
            when  '$TXDATE' = '$YEARBGNDAY'
            then T2.BAL
            else T2.BAL+coalesce(T_yjs.yr_accm,0)
            end
       )                                                                      as yr_accm   --�����
      ,(case
            when '$TXDATE' = '$MONTHBGNDAY'
            then T2.BAL
            else T2.BAL+coalesce(T_yjs.mth_accm,0)
            end
       )/('$TXDATE'::date-'$MONTHBGNDAY'::date+1)               as mth_day_avg_bal  --���վ����
      ,(case
           when '$TXDATE' = '$YEARBGNDAY'
           then T2.BAL
           else T2.BAL+coalesce(T_yjs.yr_accm,0)
           end
       )/('$TXDATE'::date-'$YEARBGNDAY'::date+1)                    as Yr_Day_Avg_Bal   --���վ����
    ,'LCS' 
  from dw_sdata.lcs_000_card_fc_cdm_leg T      --- ���ڷֻ��ǼǱ���ң� 
    left join TT_acct_med_rel t1
     on t.acc = t1.sign_id  
  left join dw_sdata.acc_003_t_acc_cdm_fc_ledger  T2 ---��ծ�ഢ����һ��ڷֻ���		
    ON T.ACC=T2.ACC 
   and T.CURR_TYPE=T2.CURR_TYPE 
   and T2.SYS_CODE='99700010000' 
   and T2.start_dt<='$TXDATE'::date
   and '$TXDATE'::date <T2.end_dt
 /* left join (select distinct t.ITM_NO,t.RATE_NO,t.CURR_TYPE,t.RATE_KIND FROM dw_sdata.lcs_000_pub_itmrate t) T3 ---��Ŀ���ʶ��ձ�		
    ON T.SVT_NO=T3.ITM_NO
   AND T.CURR_TYPE=T3.CURR_TYPE
   And T3.RATE_KIND ='0'*/
left join (
select * from (
select t.ITM_NO
--,t.ITM_NAME
,t.CURR_TYPE
,t.RATE_KIND
,t.RATE_NO
--,t.RATE_LEV
,row_number()over(partition by t.ITM_NO,t.CURR_TYPE,t.RATE_KIND order by t.RATE_LEV desc) NUM
FROM dw_sdata.lcs_000_pub_itmrate t
where T.start_dt <='$TXDATE'
   and T.end_dt > '$TXDATE'
)t
where NUM = 1
) T3 ---��Ŀ���ʶ��ձ�         
    ON T.SVT_NO=T3.ITM_NO
   AND T.CURR_TYPE=T3.CURR_TYPE
   And T3.RATE_KIND ='0'
  left join dw_sdata.acc_003_t_accdata_last_item_no T6 --��Ŀת����	
    ON T2.ITM_NO = T6.AMT_ITM
   AND T6.FIRST_ITM = '20' --��ծ������֧��  
   and T6.start_dt<='$TXDATE'::date
   and '$TXDATE'::date<T6.end_dt
  left join  (select ACC,
                     sum(case when ACC_DATE = '$TXDATE' then TRAN_AMT else 0 end) as TRAN_AMT_D  ,-- ��
                     sum(case when SUBSTR(ACC_DATE,1,6)  = SUBSTR('$TXDATE',1,6)  and ACC_DATE <='$TXDATE' then TRAN_AMT else 0 end) as TRAN_AMT_M  -- ��
                    -- sum(case when etl_dt<='$TXDATE' then  TRAN_AMT  else 0 end) TRAN_AMT_SUM --�ۻ�
                from dw_sdata.acc_000_T_INT_PRSN_CDM_FC_DTL 
	       group by ACC 
	      )T7--������һ��ڼ�Ϣ��ϸ�Ǽǲ�	
	ON T.ACC=T7.ACC
  left join TT_ACC_Paid_Int t8 
     on t.acc = t8.acc  
  left join (SELECT A. RATE_NO, A. bgn_date , A.RATE_VAL FROM  dw_sdata.lcs_000_srm_rate  A 
              INNER JOIN
             (SELECT RATE_NO,MAX(bgn_date) AS bgn_date  FROM  dw_sdata.lcs_000_srm_rate
              where  ('$MINDATE'::date + bgn_date-2)::date  <='$TXDATE' GROUP  BY RATE_NO  ) B
              ON  A. RATE_NO=B. RATE_NO
              and A. bgn_date =B. bgn_date) T13 ---���ʱ�	
    ON T3.RATE_NO=T13.RATE_NO 
  left join dw_sdata.lcs_000_card_pub_fc_svt T14 ------���ֱ����		
    ON T.SVT_NO =T14.SVT_NO 
    and T.CURR_TYPE=t14.curr_type
   and T14.start_dt<='$TXDATE'::DATE 
   AND '$TXDATE'::DATE <T14.end_dt 
    
left join f_fdm.F_DPST_INDV_ACCT T_yjs
on         t.acc= T_yjs.agmt_id
and  T_yjs.etl_date='$TXDATE'::date-1

 where T.start_dt<='$TXDATE'::DATE 
   AND '$TXDATE'::DATE <T.end_dt
;
--

-- ���ڱ���
insert into f_fdm.F_DPST_INDV_ACCT
(etl_date
,grp_typ
,Agmt_Id
,Cust_Num
,Org_Num
,Cur_Cd
,Prod_Cd
,dpst_cate_cd
,Cash_Ind_Cd
,St_Int_Dt
,Due_Dt
,Open_Acct_Day
,Clos_Acct_Day
,Exec_Int_Rate
,Bmk_Int_Rate
,Basis
,Int_Base_Cd
,Cmpd_Int_Calc_Mode_Cd
,Is_Nt_Int_Ind
,Pre_Chrg_Int
,Int_Rate_Attr_Cd
,Orgnl_Term
,Orgnl_Term_Corp_Cd
,Rprc_Prd
,Rprc_Prd_Corp_Cd
,Last_Rprc_Day
,Next_Rprc_Day
,Is_AutoRnw
,Last_AutoRnw_Dt
,Agmt_Stat_Cd
,Prin_Subj
,Curr_Bal
,Int_Subj
,Today_Provs_Int
,CurMth_Provs_Int
,Accm_Provs_Int
,Today_Int_Pay
,CurMth_Paid_Int
,Accm_Paid_Int
,Int_Adj_Amt
,Mth_Accm
,Yr_Accm
,Mth_Day_Avg_Bal
,Yr_Day_Avg_Bal
,Sys_Src
 )
select 
      '$TXDATE'::DATE,
      3,
      T.ACC,
      coalesce(t1.ecif_cust_no,''),
      coalesce(T2.OP_INST,''), 
      '156',
      T.SVT_NO,
      coalesce(T15.cal_flag,''),
      '',
      ('$MINDATE'::date+T.BGN_INT_DATE-2)::date,
      ('$MINDATE'::date+T.DUE_DATE-2)::date,
      coalesce(T2.OP_DATE::date,'$MINDATE' :: date ),
      coalesce(T2.CLS_DATE::date,'$MINDATE' :: date ),
      coalesce(T4.RATE_VAL,0),
      0.00,
      0.00,
      CASE WHEN SUBSTR(T15.INT_CAL_FLAG,2,1) ='0' THEN '1' --ʵ��/360
           WHEN SUBSTR(T15.INT_CAL_FLAG,2,1) ='1' THEN '10' --30/360
      ELSE '@'|| T15.INT_CAL_FLAG END,
      '1', --����
      '1', --��
      '0', --����
      '1', --�̶�
      T.DUE_DATE-T.BGN_INT_DATE,
      'D',     
      CASE WHEN T.DUE_DATE IS NULL  or ('$MINDATE'::date+ T.DUE_DATE-2)::date<='$TXDATE'::DATE THEN  NULL 
           ELSE T.DUE_DATE - T.BGN_INT_DATE 
      END ,
      'D',
      coalesce(('$MINDATE'::date+t4.bgn_date-2)::date,'$MINDATE' :: date ),      
      CASE WHEN T.DUE_DATE IS NULL  THEN '$MINDATE' :: date 
      WHEN T.DUE_DATE IS NOT NULL AND   ('$MINDATE'::date+ T.DUE_DATE-2)::date <= '$TXDATE'::DATE THEN '$TXDATE'::DATE+1
      ELSE  ('$MINDATE'::date+ T.DUE_DATE-2)::date
      END ,
      T.AUTO_TSF_FLAG,
      coalesce(('$MINDATE'::date+ T5.TRAN_DATE-2)::date,'$MINDATE' :: date ),
      to_char(mod(t.b_flag,2)),--T.B_FLAG ��ע����ת�����ƣ�Ȼ���ȡ�ұߵ�һλ����Ϊ�˻�״̬
      coalesce(T2.ITM_NO,'') ,
      coalesce(T2.BAL,0),
      coalesce(T6.ITM_NO,''),
      coalesce(T7.TRAN_AMT,0),
      coalesce(T12.TRAN_AMT_M,0),
      0,
      case when T8.INTS is not null then T8.INTS else T9.INTS end, 
      coalesce(T10.INTS,0),
      0,
      0,
       (case
            when '$TXDATE'= '$MONTHBGNDAY'
            then T2.BAL
            else T2.BAL+coalesce(T_yjs.mth_accm,0)
            end
       )                                                                      as mth_accm  --�»���
      ,(case
            when  '$TXDATE' = '$YEARBGNDAY'
            then T2.BAL
            else T2.BAL+coalesce(T_yjs.yr_accm,0)
            end
       )                                                                      as yr_accm   --�����
      ,(case
            when '$TXDATE' = '$MONTHBGNDAY'
            then T2.BAL
            else T2.BAL+coalesce(T_yjs.mth_accm,0)
            end
       )/('$TXDATE'::date-'$MONTHBGNDAY'::date+1)               as mth_day_avg_bal  --���վ����
      ,(case
           when '$TXDATE' = '$YEARBGNDAY'
           then T2.BAL
           else T2.BAL+coalesce(T_yjs.yr_accm,0)
           end
       )/('$TXDATE'::date-'$YEARBGNDAY'::date+1)                    as Yr_Day_Avg_Bal   --���վ����
      ,'LCS'
  from pk_fix_leg_tmp T  -- ���ڷֻ��ǼǱ������ң�
left join DW_SDATA.lcs_000_card_pub_svt T15 ------´¢ז±랠              
      ON T.SVT_NO =T15.SVT_NO
     and T15.start_dt<='$TXDATE'::DATE
     AND '$TXDATE'::DATE <T15.end_dt
  left join TT_acct_med_rel t1
    on t.acc = t1.sign_id
left join dw_sdata.acc_003_t_acc_fix_ledger  T2 ---��ծ�ഢ����˻����ڷֻ���	
  ON T.ACC=T2.ACC and T2.SYS_CODE='99700010000' 
 and T2.start_dt<='$TXDATE'::DATE
 AND '$TXDATE'::DATE<T2.end_dt
left join dw_sdata.lcs_000_pub_itmrate  T3        --��Ŀ���ʶ��ձ�   
on T.SVT_NO =T3.itm_NO
and t15.term=t3.rate_lev
and t3.CURR_TYPE='156'
and t3.rate_kind=(case when ('$MINDATE'::date + T.DUE_DATE-2)::date>='$TXDATE'::date then '0' else '1' end)
and T3.start_dt<='$TXDATE'::DATE
and '$TXDATE'::DATE <T3.end_dt
/*left join (select distinct t.ITM_NO,t.RATE_NO,t.CURR_TYPE,t.RATE_KIND FROM dw_sdata.lcs_000_pub_itmrate t) T3 ---��Ŀ���ʶ��ձ�		
  ON  T.SVT_NO=T3.ITM_NO
AND T3.CURR_TYPE='156'
And T3.RATE_KIND ='0'
left join (
select * from (
select t.ITM_NO
--,t.ITM_NAME
,t.CURR_TYPE
,t.RATE_KIND
,t.RATE_NO
--,t.RATE_LEV
,row_number()over(partition by t.ITM_NO,t.CURR_TYPE,t.RATE_KIND order by t.RATE_LEV desc) NUM
FROM dw_sdata.lcs_000_pub_itmrate t
)t
where NUM = 1
) T3 ---��Ŀ���ʶ��ձ�               
  ON  T.SVT_NO=T3.ITM_NO
AND T3.CURR_TYPE='156'
And T3.RATE_KIND ='0'
*/
left join (SELECT A. RATE_NO, A. bgn_date , A.RATE_VAL FROM  dw_sdata.lcs_000_srm_rate  A 
              INNER JOIN
             (SELECT RATE_NO,MAX(bgn_date) AS bgn_date  FROM  dw_sdata.lcs_000_srm_rate
              where  ('$MINDATE'::date + bgn_date-2)::date  <='$TXDATE' GROUP  BY RATE_NO  ) B
              ON  A. RATE_NO=B. RATE_NO
              and A. bgn_date =B. bgn_date) T4 ---���ʱ�	
ON T3.RATE_NO=T4.RATE_NO

left join (SELECT ACC,MAX(TRAN_DATE) as TRAN_DATE FROM dw_sdata.lcs_000_tsf_fix_int where ('$MINDATE'::date + tran_date-2)::date  <'$TXDATE' group by 1) T5 ---�����Զ�ת����Ϣ�Ǽǲ������ң�		
   ON T.ACC=T5.ACC
left join dw_sdata.acc_003_t_accdata_last_item_no T6   --��Ŀת����
   ON T2.ITM_NO= T6.AMT_ITM
  AND T6.FIRST_ITM='20'     --��ծ������֧�� 
  and T6.start_dt<='$TXDATE'::DATE
  AND '$TXDATE'::DATE <T6.end_dt
left join(select ACC,
                 sum(TRAN_AMT) as TRAN_AMT 
            from dw_sdata.acc_000_T_INT_PRSN_FIX_DTL 
           where ACC_DATE ='$TXDATE'
	  group by ACC 
	 ) T7--��������Ҷ��ڼ�Ϣ��ϸ�Ǽǲ� 
	ON T.ACC=T7.ACC
left join dw_sdata.lcs_000_tsf_fix_int T8  --�����Զ�ת����Ϣ�Ǽǲ������ң� 	
    ON T.ACC=T8.acc 
    and ('$MINDATE'::date + T8.tran_date-2)::DATE= '$TXDATE'::DATE
left join dw_sdata.lcs_000_pk_fix_int T9 --������Ϣ�Ǽǲ�(����)	
    ON T.ACC=T9.acc 
   and ('$MINDATE'::date + T9.tran_date-2)::DATE='$TXDATE'::DATE   
left join (select A.acc, 
                  sum(A.ints) as ints  
            from  (select acc,tran_date,ints from DW_sdata.lcs_000_pk_fix_int 
                    where month(('$MINDATE'::date + tran_date-2)::DATE) = month('$TXDATE'::date)  and ('$MINDATE'::date + tran_date-2)::DATE <='$TXDATE'::date
                    union all
                   select acc,tran_date,ints from DW_sdata.lcs_000_tsf_fix_int 
                   where month(('$MINDATE'::date + tran_date-2)::DATE) = month('$TXDATE'::date)  and ('$MINDATE'::date + tran_date-2)::DATE <='$TXDATE'::date
                  )  A
            group by acc
           ) T10
 	ON T.ACC=T10.acc  	
/* left join (select A.acc,
                  sum(A.ints)  as ints
             from  (select acc, tran_date,ints from DW_sdata.lcs_000_pk_fix_int where  etl_dt<='$TXDATE'::date
                    union all
                    select acc,tran_date,ints from DW_sdata.lcs_000_tsf_fix_int where etl_dt<='$TXDATE'::date ) A 
            group by acc
          ) T11
   ON T.ACC=T11.acc*/ 	

left join (select acc,
                  sum(case when substr(tran_time,1,6)=substr('$TXDATE',1,6)  and substr(tran_time,1,8) <='$TXDATE' then TRAN_AMT else 0 end ) TRAN_AMT_M
                 -- sum(case when etl_dt<='$TXDATE'::date then TRAN_AMT  else 0 end) TRAN_AMT_S
             from dw_sdata.acc_000_T_INT_PRSN_FIX_DTL 
            group by 1 
          ) T12
      on  T.ACC=T12.ACC

left join f_fdm.F_DPST_INDV_ACCT T_yjs
on         t.acc= T_yjs.agmt_id
and  T_yjs.etl_date='$TXDATE'::date-1 
where T.start_dt<='$TXDATE'::DATE 
  AND '$TXDATE'::DATE <T.end_dt
  ; 

-- �������
insert into f_fdm.F_DPST_INDV_ACCT
(etl_date
,grp_typ
,Agmt_Id
,Cust_Num
,Org_Num
,Cur_Cd
,Prod_Cd
,dpst_cate_cd
,Cash_Ind_Cd
,St_Int_Dt
,Due_Dt
,Open_Acct_Day
,Clos_Acct_Day
,Exec_Int_Rate
,Bmk_Int_Rate
,Basis
,Int_Base_Cd
,Cmpd_Int_Calc_Mode_Cd
,Is_Nt_Int_Ind
,Pre_Chrg_Int
,Int_Rate_Attr_Cd
,Orgnl_Term
,Orgnl_Term_Corp_Cd
,Rprc_Prd
,Rprc_Prd_Corp_Cd
,Last_Rprc_Day
,Next_Rprc_Day
,Is_AutoRnw
,Last_AutoRnw_Dt
,Agmt_Stat_Cd
,Prin_Subj
,Curr_Bal
,Int_Subj
,Today_Provs_Int
,CurMth_Provs_Int
,Accm_Provs_Int
,Today_Int_Pay
,CurMth_Paid_Int
,Accm_Paid_Int
,Int_Adj_Amt
,Mth_Accm
,Yr_Accm
,Mth_Day_Avg_Bal
,Yr_Day_Avg_Bal
,Sys_Src
 )select '$TXDATE'::DATE ,
         4,
         T.ACC,
        coalesce(t1.ecif_cust_no,''),
         coalesce(T2.ACC_INST,''),
         T.CURR_TYPE,
         T.SVT_NO,
         coalesce(T15.cal_flag,''),
         T.CH_TYPE,
         ('$MINDATE'::date + T.BGN_INT_DATE-2)::date,
         ('$MINDATE'::date + T.DUE_DATE-2)::date,
         coalesce(T2.OP_DATE::date,'$MINDATE' :: date ),
         coalesce(T2.CLS_DATE::date,'$MINDATE' :: date ),
         coalesce(T4.RATE_VAL,0),
         0.00,
         0.00,
         CASE WHEN SUBSTR(T15.INT_CAL_FLAG,2,1) ='0' THEN '1' --ʵ��/360
              WHEN SUBSTR(T15.INT_CAL_FLAG,2,1) ='1' THEN '10' --30/360
         ELSE '@'||T15.INT_CAL_FLAG END,
         '1',   --����
         '1',   --��
         '0',   --����
         '1',   --�̶�
         T.DUE_DATE-T.BGN_INT_DATE,
         'D',
         CASE WHEN T.DUE_DATE IS NULL  or ('$MINDATE'::date+ T.DUE_DATE-2)::date<='$TXDATE'::DATE THEN  NULL 
             ELSE T.DUE_DATE - T.BGN_INT_DATE 
         END ,          
         'D',
          coalesce(('$MINDATE'::date + t4.bgn_date-2)::date,'$MINDATE' :: date ),
          CASE WHEN T.DUE_DATE IS NULL  THEN '$MINDATE' :: date 
               WHEN T.DUE_DATE IS NOT NULL AND   ('$MINDATE'::date+ T.DUE_DATE-2)::date <= '$TXDATE'::DATE THEN '$TXDATE'::DATE+1
          ELSE  ('$MINDATE'::date+ T.DUE_DATE-2)::date
          END ,
         T.AUTO_TSF_FLAG,
         coalesce(('$MINDATE'::date+ T5.TRAN_DATE-2)::date,'$MINDATE' :: date ),
         to_char(mod(t.b_flag,2)), --T.B_FLAG ��ע����ת�����ƣ�Ȼ���ȡ�ұߵ�һλ����Ϊ�˻�״̬
         coalesce(T2.ITM_NO,''),
         coalesce(T2.BAL,0),
         coalesce(T6.ITM_NO,''),
         coalesce(T7.TRAN_AMT,0),
         coalesce(T12.TRAN_AMT_m,0),
         0,
         case when T8.INTS is not null then T8.INTS else T9.INTS end ,
         coalesce(T10.INTS,0),
         0,
         0,   
      (case
            when '$TXDATE'= '$MONTHBGNDAY'
            then T2.BAL
            else T2.BAL+coalesce(T_yjs.mth_accm,0)
            end
       )                                                                      as mth_accm  --�»���
      ,(case
            when  '$TXDATE' = '$YEARBGNDAY'
            then T2.BAL
            else T2.BAL+coalesce(T_yjs.yr_accm,0)
            end
       )                                                                      as yr_accm   --�����
      ,(case
            when '$TXDATE' = '$MONTHBGNDAY'
            then T2.BAL
            else T2.BAL+coalesce(T_yjs.mth_accm,0)
            end
       )/('$TXDATE'::date-'$MONTHBGNDAY'::date+1)               as mth_day_avg_bal  --���վ����
      ,(case
           when '$TXDATE' = '$YEARBGNDAY'
           then T2.BAL
           else T2.BAL+coalesce(T_yjs.yr_accm,0)
           end
       )/('$TXDATE'::date-'$YEARBGNDAY'::date+1)                    as Yr_Day_Avg_Bal   --���վ����
         ,'LCS'
   from dw_sdata.lcs_000_pk_fc_fix_leg   T -- ���ڷֻ��Ǽǲ�����ң�
    left join TT_acct_med_rel t1
    on t.acc = t1.sign_id
left join dw_sdata.lcs_000_card_pub_fc_svt T15 ------���ֱ����         
  ON T.SVT_NO =T15.SVT_NO
 and t.curr_type=t15.curr_type
 and T15.start_dt<='$TXDATE'::DATE
 and '$TXDATE'::DATE<T15.end_dt
left join dw_sdata.acc_003_t_acc_fix_fc_ledger T2 --- ��ծ�ഢ����Ҷ��ڷֻ��� 
    ON T.ACC=T2.ACC 
   and T.CURR_TYPE=T2.CURR_TYPE 
   and T2.SYS_CODE='99700010000'
   and T2.start_dt<='$TXDATE'::DATE
   AND '$TXDATE'::DATE<T2.end_dt
left join dw_sdata.lcs_000_pub_itmrate t3            -----��Ŀ���ʶ��ձ�
on t.svt_no=t3.itm_no
and t15.term=t3.rate_lev
and t.curr_type=t3.curr_type
and t3.rate_kind=(case when ('$MINDATE'::date + T.DUE_DATE-2)::date>='$TXDATE'::date then '0' else '1' end)
and T3.start_dt<='$TXDATE'::DATE
   AND '$TXDATE'::DATE<T3.end_dt
 /* left join (select distinct t.ITM_NO,t.RATE_NO,t.CURR_TYPE,t.RATE_KIND FROM dw_sdata.lcs_000_pub_itmrate t) T3 ---��Ŀ���ʶ��ձ�		
    ON  T.SVT_NO=T3.ITM_NO
   AND T.CURR_TYPE=T3.CURR_TYPE
   And T3.RATE_KIND ='0'
left join (
select * from (
select t.ITM_NO
--,t.ITM_NAME
,t.CURR_TYPE
,t.RATE_KIND
,t.RATE_NO
--,t.RATE_LEV
,row_number()over(partition by t.ITM_NO,t.CURR_TYPE,t.RATE_KIND order by t.RATE_LEV desc) NUM
FROM dw_sdata.lcs_000_pub_itmrate t
)t
where NUM = 1
) T3 ---��Ŀ���ʶ��ձ�             
    ON  T.SVT_NO=T3.ITM_NO
   AND T.CURR_TYPE=T3.CURR_TYPE
   And T3.RATE_KIND ='0'
*/
   left join (SELECT A. RATE_NO, A. bgn_date , A.RATE_VAL FROM  dw_sdata.lcs_000_srm_rate  A 
              INNER JOIN
             (SELECT RATE_NO,MAX(bgn_date) AS bgn_date  FROM  dw_sdata.lcs_000_srm_rate
              where  ('$MINDATE'::date + bgn_date-2)::date  <='$TXDATE' GROUP  BY RATE_NO  ) B
              ON  A. RATE_NO=B. RATE_NO
              and A. bgn_date =B. bgn_date) T4 ---���ʱ�	
    ON T3.RATE_NO=T4.RATE_NO
	
 left join (SELECT ACC,MAX(TRAN_DATE) as TRAN_DATE FROM DW_SDATA.lcs_000_tsf_fc_fix_int where ('$MINDATE'::date + tran_date-2)::date  <'$TXDATE'  group by 1 ) T5 ---�����Զ�ת����Ϣ�Ǽǲ�����ң�	
  ON T.ACC=T5.ACC
 left join dw_sdata.acc_003_t_accdata_last_item_no T6--��Ŀת����	
  ON T2.ITM_NO= T6.AMT_ITM
 AND T6.FIRST_ITM='20' --��ծ������֧�� 
 and T6.start_dt<='$TXDATE'::DATE
 AND '$TXDATE'::DATE<T6.end_dt
 
 	left join (select ACC,sum(TRAN_AMT) as TRAN_AMT 
           from DW_SDATA.acc_000_T_INT_PRSN_FIX_FC_DTL 
           where  ACC_DATE ='$TXDATE'
           group by ACC ) T7--������Ҷ��ڼ�Ϣ��ϸ�Ǽǲ�	
 	ON T.ACC=T7.ACC
 left join  dw_sdata.lcs_000_tsf_fc_fix_int T8--�����Զ�ת����Ϣ�Ǽǲ�����ң� 
  ON T.ACC=T8.acc 
and ('$MINDATE'::date+T8.tran_date-2)::DATE='$TXDATE'::DATE  

left join dw_sdata.lcs_000_pk_fc_fix_int T9 --������Ϣ�Ǽǲ�����ң� 
  ON T.ACC=T9.acc 
  and ('$MINDATE'::date + T9.tran_date-2)::DATE='$TXDATE'::DATE   
    
 left join (select A.acc, 
                  sum(A.ints) as ints  
            from  (select acc,tran_date,ints from DW_sdata.lcs_000_tsf_fc_fix_int
                    where month(('$MINDATE'::date + tran_date-2)::DATE) = month('$TXDATE'::date)  and ('$MINDATE'::date + tran_date-2)::DATE <='$TXDATE'::date
                    union all
                   select acc,tran_date,ints from DW_sdata.lcs_000_pk_fc_fix_int 
                   where month(('$MINDATE'::date + tran_date-2)::DATE) = month('$TXDATE'::date)  and ('$MINDATE'::date + tran_date-2)::DATE <='$TXDATE'::date
                  )  A
            group by acc
           ) T10
 	ON T.ACC=T10.acc

/* left join (select A.acc,
                  sum(A.ints)  as ints
             from  (select acc, tran_date,ints from DW_sdata.lcs_000_tsf_fc_fix_int where  etl_dt<='$TXDATE'::date
                    union all
                    select acc,tran_date,ints from DW_sdata.lcs_000_pk_fc_fix_int where etl_dt<='$TXDATE'::date ) A 
            group by acc
          ) T11
   ON T.ACC=T11.acc */ 	
   	 
 left join (select acc,
                  sum(case when substr(tran_time,1,6)=substr('$TXDATE',1,6)  and substr(tran_time,1,8) <='$TXDATE' then TRAN_AMT else 0 end ) TRAN_AMT_M
                 -- sum(case when etl_dt<='$TXDATE'::date then TRAN_AMT  else 0 end) TRAN_AMT_S
             from dw_sdata.acc_000_T_INT_PRSN_FIX_DTL 
            group by 1 
          ) T12
      on  T.ACC=T12.ACC
left join f_fdm.F_DPST_INDV_ACCT T_yjs
on         t.acc= T_yjs.agmt_id
and  T_yjs.etl_date='$TXDATE'::date-1
where T.start_dt<='$TXDATE'::DATE
 and '$TXDATE'::DATE<T.end_dt
;

/*���ݴ�����end*/

commit;

