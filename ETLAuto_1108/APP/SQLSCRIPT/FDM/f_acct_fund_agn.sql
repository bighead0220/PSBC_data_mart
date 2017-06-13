/*
Author             :zhangwj
Function           :���������
Load method        :
Source table       :dw_sdata.fss_001_fd_acctquotient,dw_sdata.fss_001_fd_addconsign,dw_sdata.fss_001_fd_customerinfo,dw_sdata.fss_001_fd_custtomgr,dw_sdata.fss_001_fd_netvalue      
Destination Table  :f_fdm.f_acct_fund_agn
Modify history list:Created by zhangwj at 2016-4-27 14:22 v1.0
                    Changed by zhangwj at 2016-5-30 14:22 v1.1  ��T1���
                              :Modify  by liudongyan 20160704 ����������
                    modified by wyh at 20160921 ���������,����������;
-------------------------------------------����---------------------------------------------
������
-------------------------------------------����END------------------------------------------
*/

/*������*/
-----�������-------------------------
create local temporary table tt_f_acct_fund_agn_temp_yjs  ----����������������������
on commit preserve rows as 
select * 
from f_fdm.f_acct_fund_agn
where 1=2;
/*������END*/

/*�����*/
delete /* +direct */ from f_fdm.f_acct_fund_agn
where etl_date = '$TXDATE'
;
/*�����END*/

/*�����*/
insert /* +direct */  into f_fdm.f_acct_fund_agn
    (
     grp_typ                                               --��            
     ,etl_date                                             --����        
     ,agmt_id                                              --����        
     ,prod_cd                                              --����        
     ,biz_typ_cd                                           --������    
     ,entrs_corp_cd                                        --�����      
     ,dpst_acct                                            --����        
     ,cust_id                                              --����        
     ,org_num                                              --���          
     ,cur_cd                                               --����        
     ,open_acct_dt                                         --����        
     ,subj_cd                                              --����        
     ,fund_lot                                             --����        
     ,fund_net_worth                                       --����        
     ,fund_amt                                             --����        
     ,cust_mgr_id                                          --������    
     ,mth_accm                                             --���          
     ,yr_accm                                              --���          
     ,mth_day_avg_bal                                      --�����      
     ,yr_day_avg_bal                                       --�����      
     ,sys_src                                              --���� 
    )
 select
      1                                                        as  grp_typ           --组别
      ,'$TXDATE'::date                                as  etl_date          --数据日期
      ,coalesce(t.customerid,'')                               as  agmt_id           --协议编号
      ,coalesce(t.businesskindcode,'')                         as  prod_cd           --产品代码
      ,coalesce(t.businesstypecode,'')                         as  biz_typ_cd        --业务种类代号
      ,coalesce(t.agentcorpcode,'')                            as  entrs_corp_cd     --委托单位号
      ,coalesce(t1.greenacctno,'')                             as  dpst_acct         --存款账户
      ,coalesce(t2.ecifcustomerno,'')                          as  cust_id           --客户编号
      ,coalesce(t.fporgancode,'')                              as  org_num           --机构号
      ,'156'                                                   as  cur_cd            --货币代码
      ,coalesce(to_date(t.opendate,'yyyymmdd'),'$MAXDATE'::date)   as  open_acct_dt      --开户日期
      ,''                                       as  subj_cd           --科目代码
      ,coalesce(t.totalquotient,0)                             as  fund_lot          --基金份额
      ,coalesce(t4.netvalue,0)                                 as  fund_net_worth    --基金净值
      ,coalesce( t4.netvalue,0)*coalesce(t.totalquotient,0)    as  fund_amt          --基金金额
      ,coalesce(t3.customermgrcode,'')                         as  cust_mgr_id       --客户经理编号
      ,0                                        as  mth_accm          --映射不确定    --月积数
      ,0                                        as  yr_accm           --映射不确定    --年积数
      ,0                                        as  mth_day_avg_bal   --映射不确定    --月日均余额
      ,0                                        as  yr_day_avg_bal    --映射不确定    --年日均余额
      ,'FSS'                                                   as  sys_src           --系统来源
 from dw_sdata.fss_001_fd_acctquotient         t               --基金分户余额表
 left join dw_sdata.fss_001_fd_addconsign      t1              --加办关系登记表
 on        t.customerid=t1.customerid
 and       t.businesskindcode=t1.businesstypecode
 and       t.agentcorpcode=t1.agentcorpcode
 and       t1.start_dt<='$TXDATE'::date
 and       t1.end_dt>'$TXDATE'::date
 left join dw_sdata.fss_001_fd_customerinfo   t2               --客户基本资料表
 on        t.customerid=t2.customerid
 and       t2.start_dt<='$TXDATE'::date
 and       t2.end_dt>'$TXDATE'::date
 left join (select customerid,customermgrcode,start_dt,end_dt,row_number() over(partition by customerid order by customermgrcode desc ) num from  dw_sdata.fss_001_fd_custtomgr)      t3               --客户理财经理对照表
 on        t.customerid=t3.customerid
 and       t3.num=1
 and       t3.start_dt<='$TXDATE'::date
 and       t3.end_dt>'$TXDATE'::date
 left join
         (select
                a.netvalue
                ,a.procliamdate
                ,a.agentcorpcode
                ,a.businesskindcode
         from   dw_sdata.fss_001_fd_netvalue a                  --净值表
         inner join
                  (select
                        agentcorpcode
                        ,businesskindcode
                        ,max(procliamdate) as procliamdate
                  from  dw_sdata.fss_001_fd_netvalue
                  where start_dt<='$TXDATE'::date
                  and   end_dt>'$TXDATE'::date
                  group by agentcorpcode,businesskindcode
                  )b
         on       a.agentcorpcode=b.agentcorpcode
         and      a.businesskindcode=b.businesskindcode
         and      a.procliamdate=b.procliamdate
         where    a.start_dt<='$TXDATE'::date
         and      a.end_dt>'$TXDATE'::date
         )                                       t4             --净值表
 on      t.agentcorpcode=t4.agentcorpcode
 and     t.businesskindcode=t4.businesskindcode
 where t.businesstypecode ='01'
 and   t.start_dt<='$TXDATE'::date
 and   t.end_dt>'$TXDATE'::date
 ;
    /*月积数、年积数、月日均余额、年日均余额临时表创建区*/
 
insert into tt_f_acct_fund_agn_temp_yjs
(
      agmt_id
      ,biz_typ_cd
      ,entrs_corp_cd
      ,prod_cd
      ,Mth_Accm
      ,Yr_Accm
      ,Mth_Day_Avg_Bal 
      ,Yr_Day_Avg_Bal
)
select 
      t.agmt_id
      ,t.biz_typ_cd
      ,t.entrs_corp_cd
      ,t.prod_cd 
      ,(case 
            when '$TXDATE'= '$MONTHBGNDAY' 
            then t.fund_amt
            else t.fund_amt+coalesce(t1.mth_accm,0)
            end
       )                                                                      as mth_accm  --月积数
      ,(case 
            when  '$TXDATE' = '$YEARBGNDAY' 
            then t.fund_amt
            else t.fund_amt+coalesce(t1.yr_accm,0)
            end
       )                                                                      as yr_accm   --年积数
      ,(case 
            when '$TXDATE' = '$MONTHBGNDAY' 
            then t.fund_amt
            else t.fund_amt+coalesce(t1.mth_accm,0)
            end
       )/('$TXDATE'::date-'$MONTHBGNDAY'::date+1)               as mth_day_avg_bal  --月日均余额
      ,(case 
           when '$TXDATE' = '$YEARBGNDAY' 
           then t.fund_amt
           else t.fund_amt+coalesce(t1.yr_accm,0)
           end
       )/('$TXDATE'::date-'$YEARBGNDAY'::date+1)                    as Yr_Day_Avg_Bal   --年日均余额
from  f_fdm.f_acct_fund_agn     t
left join  f_fdm.f_acct_fund_agn t1
on        t.agmt_id=t1.agmt_id
and       t.biz_typ_cd=t1.biz_typ_cd
and       t.entrs_corp_cd=t1.entrs_corp_cd
and       t.prod_cd=t1.prod_cd
and       t1.etl_date='$TXDATE'::date-1
where     t.etl_date='$TXDATE'::date
;
/*月积数、年积数、月日均余额、年日均余额临时表创建区END*/
/*更新月积数、年积数、月日均余额、年日均余额*/
update f_fdm.f_acct_fund_agn   t
set mth_accm=t1.mth_accm 
,yr_accm=t1.yr_accm
,mth_day_avg_bal=t1.mth_day_avg_bal
,Yr_Day_Avg_Bal=t1.Yr_Day_Avg_Bal
from  tt_f_acct_fund_agn_temp_yjs t1
where t.agmt_id=t1.agmt_id
and       t.biz_typ_cd=t1.biz_typ_cd
and       t.entrs_corp_cd=t1.entrs_corp_cd
and       t.prod_cd=t1.prod_cd
and       t.etl_date='$TXDATE'::date
;
/*数据处理区END*/

 COMMIT;
