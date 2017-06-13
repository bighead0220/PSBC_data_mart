#!/usr/bin/perl

use strict;     # Declare using Perl strict syntax
use DBI;        # If you are using other package, declare here

# ------------ Variable Section ------------
my ${AUTO_HOME} = $ENV{"AUTO_HOME"};

my ${WML_DB} = $ENV{"AUTO_WML_DB"};
if ( !defined(${WML_DB}) ) {
    ${WML_DB} = "WML";
}
my ${WTL_DB} = $ENV{"AUTO_WTL_DB"};
if ( !defined(${WTL_DB}) ) {
    ${WTL_DB} = "WTL";
}
my ${WMLVIEW_DB} = $ENV{"AUTO_WMLVIEW_DB"};
if ( !defined(${WMLVIEW_DB}) ) {
    ${WMLVIEW_DB} = "WMLVIEW";
}
my ${WTLVIEW_DB} = $ENV{"AUTO_WTLVIEW_DB"};
if ( !defined(${WTLVIEW_DB}) ) {
    ${WTLVIEW_DB} = "WTLVIEW";
}

my ${NULL_DATE} = "1900-01-02";
my ${MIN_DATE} = "1900-01-01";
my ${MAX_DATE} = "2100-12-31";

my ${LOGON_FILE} = "${AUTO_HOME}/etc/VERTICA_LOGON";
my ${LOGON_STR};
my ${CONTROL_FILE};
my ${TX_DATE};
my ${TX_DATE_YYYYMMDD};
my ${TX_MON_DAY_MMDD};

# ------------ VSQL function ------------
sub run_vsql_command
{
  #my $rc = open(VSQL, "${LOGON_STR}");
  my $rc = open(VSQL, "|vsql -h 22.224.65.171 -p 5433 -d CPCIMDB_TEST -U dwtrans -w dwtrans2016");

  unless ($rc) {
      print "Could not invoke VSQL command
";
      return -1;
  }

# ------ Below are VSQL scripts ----------
  print VSQL <<ENDOFINPUT;

\\set ON_ERROR_STOP on

--Step0:
DELETE FROM dw_sdata.CCS_004_TB_CON_PAYOUT_INT_RATE WHERE start_dt>=DATE('${TX_DATE_YYYYMMDD}');
UPDATE dw_sdata.CCS_004_TB_CON_PAYOUT_INT_RATE SET end_dt=DATE('2100-12-31') WHERE end_dt>=DATE('${TX_DATE_YYYYMMDD}') AND end_dt<>DATE('2100-12-31');

--Step1:
CREATE LOCAL TEMPORARY TABLE  T_114 ON COMMIT PRESERVE ROWS AS SELECT * FROM dw_sdata.CCS_004_TB_CON_PAYOUT_INT_RATE WHERE 1=0;

--Step2:
INSERT  INTO T_114 (
  PAYOUT_INFO_DETAIL_ID,
  INT_RATE_ID,
  PAYOUT_INFO_ID,
  IR_TYPE_CD,
  IR_GIST_STYLE_CD,
  IR_NEGO_SYMB_CD,
  IR_NEGO_RATE,
  IR_FLUCTUATE_TYPE,
  IR_GRADE_CD,
  IR_SETTLEMT_DATE,
  IR_SETTLEMT_STYLE_CD,
  IR_RATE_DIFFERENCE,
  IR_ADJUST_CYC,
  IR_PAY_MODE_CD,
  IR_OTHER_STYLE,
  IR_SETTLEMENT_IND,
  IR_PAY_NAME,
  IR_SETTLEMENT_RATE,
  IR_SETTLEMENT_END_DATE,
  BENCHMARK_IR_YEAR_RATE,
  IR_RATE_YEAR,
  IR_FREE_IND,
  IR_FREE_TERM,
  IR_FREE_TERM_TYPE_CD,
  IR_COUNT_WAY,
  IR_COUNT_ACCRUAL_CYC_CD,
  OVDUE_IR_GIST_STYLE_CD,
  OVDUE_IR_NEGO_SYMB_CD,
  OVDUE_IR_NEGO_RATE,
  OVDUE_IR_YEAR_RATE,
  OVDUE_IR_DIFFERENCE,
  PECUL_IR_GIST_STYLE_CD,
  PECUL_IR_NEGO_SYMB_CD,
  PECUL_IR_NEGO_RATE,
  PECUL_IR_YEAR_RATE,
  PECUL_IR_SETTLEMT_STYLE_CD,
  ADVANCE_RESTORE_TYPE,
  ADVANCE_UP_RATE,
  ADVANCE_BREACH_AMT,
  PREPAYMENT_QUOTA,
  ADVANCE_GIST_STYLE_CD,
  PREPAY_QUOTA_FLUCTUATE_RATE,
  ADVANCE_BREACH_AMT_RATE,
  PUNISH_GIST_STYLE_CD,
  PUNISH_NEGO_SYMB_CD,
  PUNISH_NEGO_RATE,
  PUNISH_RATE_YEAR,
  BREACH_AMT_RATE,
  HANDLING_FEE_BREACH_AMT,
  BAIL_ACCT_RATE_EXECUTE_CD,
  PUNISH_AGAIN_RATE,
  NORM_VIOLATION_RATE,
  EXE_VIOLATION_RATE,
  VIOLATION_FLUCTUATE_RATE,
  VIOLATION_PREPAYMENT_RATE,
  UP_FLUCTUATE_RATE,
  EFFECTIVE_DATE,
  INVALID_DATE,
  TIME_MARK,
  DAY_RATE,
  RATE_ADJUST_DATE_CODE,
  RATE_ADJUST_DATE,
  RATE_CHANGE_MONTH,
  RATE_CHANGE_DAY,
  FIRSE_CHANGE_DATE,
  CHANGE_DATE_TYPE,
  RATE_APPLY_TYPE,
  IF_CALBYLATEST_PRDINT,
  FXBS_TIME_MARK,
  start_dt,
  end_dt)
SELECT
  N.PAYOUT_INFO_DETAIL_ID,
  N.INT_RATE_ID,
  N.PAYOUT_INFO_ID,
  N.IR_TYPE_CD,
  N.IR_GIST_STYLE_CD,
  N.IR_NEGO_SYMB_CD,
  N.IR_NEGO_RATE,
  N.IR_FLUCTUATE_TYPE,
  N.IR_GRADE_CD,
  N.IR_SETTLEMT_DATE,
  N.IR_SETTLEMT_STYLE_CD,
  N.IR_RATE_DIFFERENCE,
  N.IR_ADJUST_CYC,
  N.IR_PAY_MODE_CD,
  N.IR_OTHER_STYLE,
  N.IR_SETTLEMENT_IND,
  N.IR_PAY_NAME,
  N.IR_SETTLEMENT_RATE,
  N.IR_SETTLEMENT_END_DATE,
  N.BENCHMARK_IR_YEAR_RATE,
  N.IR_RATE_YEAR,
  N.IR_FREE_IND,
  N.IR_FREE_TERM,
  N.IR_FREE_TERM_TYPE_CD,
  N.IR_COUNT_WAY,
  N.IR_COUNT_ACCRUAL_CYC_CD,
  N.OVDUE_IR_GIST_STYLE_CD,
  N.OVDUE_IR_NEGO_SYMB_CD,
  N.OVDUE_IR_NEGO_RATE,
  N.OVDUE_IR_YEAR_RATE,
  N.OVDUE_IR_DIFFERENCE,
  N.PECUL_IR_GIST_STYLE_CD,
  N.PECUL_IR_NEGO_SYMB_CD,
  N.PECUL_IR_NEGO_RATE,
  N.PECUL_IR_YEAR_RATE,
  N.PECUL_IR_SETTLEMT_STYLE_CD,
  N.ADVANCE_RESTORE_TYPE,
  N.ADVANCE_UP_RATE,
  N.ADVANCE_BREACH_AMT,
  N.PREPAYMENT_QUOTA,
  N.ADVANCE_GIST_STYLE_CD,
  N.PREPAY_QUOTA_FLUCTUATE_RATE,
  N.ADVANCE_BREACH_AMT_RATE,
  N.PUNISH_GIST_STYLE_CD,
  N.PUNISH_NEGO_SYMB_CD,
  N.PUNISH_NEGO_RATE,
  N.PUNISH_RATE_YEAR,
  N.BREACH_AMT_RATE,
  N.HANDLING_FEE_BREACH_AMT,
  N.BAIL_ACCT_RATE_EXECUTE_CD,
  N.PUNISH_AGAIN_RATE,
  N.NORM_VIOLATION_RATE,
  N.EXE_VIOLATION_RATE,
  N.VIOLATION_FLUCTUATE_RATE,
  N.VIOLATION_PREPAYMENT_RATE,
  N.UP_FLUCTUATE_RATE,
  N.EFFECTIVE_DATE,
  N.INVALID_DATE,
  N.TIME_MARK,
  N.DAY_RATE,
  N.RATE_ADJUST_DATE_CODE,
  N.RATE_ADJUST_DATE,
  N.RATE_CHANGE_MONTH,
  N.RATE_CHANGE_DAY,
  N.FIRSE_CHANGE_DATE,
  N.CHANGE_DATE_TYPE,
  N.RATE_APPLY_TYPE,
  N.IF_CALBYLATEST_PRDINT,
  N.FXBS_TIME_MARK,
  DATE('${TX_DATE_YYYYMMDD}'),
  DATE('2100-12-31')
FROM 
 (SELECT
  COALESCE(PAYOUT_INFO_DETAIL_ID, '' ) AS PAYOUT_INFO_DETAIL_ID ,
  COALESCE(INT_RATE_ID, '' ) AS INT_RATE_ID ,
  COALESCE(PAYOUT_INFO_ID, '' ) AS PAYOUT_INFO_ID ,
  COALESCE(IR_TYPE_CD, '' ) AS IR_TYPE_CD ,
  COALESCE(IR_GIST_STYLE_CD, '' ) AS IR_GIST_STYLE_CD ,
  COALESCE(IR_NEGO_SYMB_CD, '' ) AS IR_NEGO_SYMB_CD ,
  COALESCE(IR_NEGO_RATE, 0 ) AS IR_NEGO_RATE ,
  COALESCE(IR_FLUCTUATE_TYPE, '' ) AS IR_FLUCTUATE_TYPE ,
  COALESCE(IR_GRADE_CD, '' ) AS IR_GRADE_CD ,
  COALESCE(IR_SETTLEMT_DATE, '' ) AS IR_SETTLEMT_DATE ,
  COALESCE(IR_SETTLEMT_STYLE_CD, '' ) AS IR_SETTLEMT_STYLE_CD ,
  COALESCE(IR_RATE_DIFFERENCE, 0 ) AS IR_RATE_DIFFERENCE ,
  COALESCE(IR_ADJUST_CYC, '' ) AS IR_ADJUST_CYC ,
  COALESCE(IR_PAY_MODE_CD, '' ) AS IR_PAY_MODE_CD ,
  COALESCE(IR_OTHER_STYLE, '' ) AS IR_OTHER_STYLE ,
  COALESCE(IR_SETTLEMENT_IND, '' ) AS IR_SETTLEMENT_IND ,
  COALESCE(IR_PAY_NAME, '' ) AS IR_PAY_NAME ,
  COALESCE(IR_SETTLEMENT_RATE, 0 ) AS IR_SETTLEMENT_RATE ,
  COALESCE(IR_SETTLEMENT_END_DATE,'4999-12-31 00:00:00' ) AS IR_SETTLEMENT_END_DATE ,
  COALESCE(BENCHMARK_IR_YEAR_RATE, 0 ) AS BENCHMARK_IR_YEAR_RATE ,
  COALESCE(IR_RATE_YEAR, 0 ) AS IR_RATE_YEAR ,
  COALESCE(IR_FREE_IND, '' ) AS IR_FREE_IND ,
  COALESCE(IR_FREE_TERM, 0 ) AS IR_FREE_TERM ,
  COALESCE(IR_FREE_TERM_TYPE_CD, '' ) AS IR_FREE_TERM_TYPE_CD ,
  COALESCE(IR_COUNT_WAY, '' ) AS IR_COUNT_WAY ,
  COALESCE(IR_COUNT_ACCRUAL_CYC_CD, '' ) AS IR_COUNT_ACCRUAL_CYC_CD ,
  COALESCE(OVDUE_IR_GIST_STYLE_CD, '' ) AS OVDUE_IR_GIST_STYLE_CD ,
  COALESCE(OVDUE_IR_NEGO_SYMB_CD, '' ) AS OVDUE_IR_NEGO_SYMB_CD ,
  COALESCE(OVDUE_IR_NEGO_RATE, 0 ) AS OVDUE_IR_NEGO_RATE ,
  COALESCE(OVDUE_IR_YEAR_RATE, 0 ) AS OVDUE_IR_YEAR_RATE ,
  COALESCE(OVDUE_IR_DIFFERENCE, 0 ) AS OVDUE_IR_DIFFERENCE ,
  COALESCE(PECUL_IR_GIST_STYLE_CD, '' ) AS PECUL_IR_GIST_STYLE_CD ,
  COALESCE(PECUL_IR_NEGO_SYMB_CD, '' ) AS PECUL_IR_NEGO_SYMB_CD ,
  COALESCE(PECUL_IR_NEGO_RATE, 0 ) AS PECUL_IR_NEGO_RATE ,
  COALESCE(PECUL_IR_YEAR_RATE, 0 ) AS PECUL_IR_YEAR_RATE ,
  COALESCE(PECUL_IR_SETTLEMT_STYLE_CD, '' ) AS PECUL_IR_SETTLEMT_STYLE_CD ,
  COALESCE(ADVANCE_RESTORE_TYPE, '' ) AS ADVANCE_RESTORE_TYPE ,
  COALESCE(ADVANCE_UP_RATE, 0 ) AS ADVANCE_UP_RATE ,
  COALESCE(ADVANCE_BREACH_AMT, 0 ) AS ADVANCE_BREACH_AMT ,
  COALESCE(PREPAYMENT_QUOTA, 0 ) AS PREPAYMENT_QUOTA ,
  COALESCE(ADVANCE_GIST_STYLE_CD, '' ) AS ADVANCE_GIST_STYLE_CD ,
  COALESCE(PREPAY_QUOTA_FLUCTUATE_RATE, 0 ) AS PREPAY_QUOTA_FLUCTUATE_RATE ,
  COALESCE(ADVANCE_BREACH_AMT_RATE, 0 ) AS ADVANCE_BREACH_AMT_RATE ,
  COALESCE(PUNISH_GIST_STYLE_CD, '' ) AS PUNISH_GIST_STYLE_CD ,
  COALESCE(PUNISH_NEGO_SYMB_CD, '' ) AS PUNISH_NEGO_SYMB_CD ,
  COALESCE(PUNISH_NEGO_RATE, 0 ) AS PUNISH_NEGO_RATE ,
  COALESCE(PUNISH_RATE_YEAR, 0 ) AS PUNISH_RATE_YEAR ,
  COALESCE(BREACH_AMT_RATE, 0 ) AS BREACH_AMT_RATE ,
  COALESCE(HANDLING_FEE_BREACH_AMT, 0 ) AS HANDLING_FEE_BREACH_AMT ,
  COALESCE(BAIL_ACCT_RATE_EXECUTE_CD, '' ) AS BAIL_ACCT_RATE_EXECUTE_CD ,
  COALESCE(PUNISH_AGAIN_RATE, 0 ) AS PUNISH_AGAIN_RATE ,
  COALESCE(NORM_VIOLATION_RATE, 0 ) AS NORM_VIOLATION_RATE ,
  COALESCE(EXE_VIOLATION_RATE, 0 ) AS EXE_VIOLATION_RATE ,
  COALESCE(VIOLATION_FLUCTUATE_RATE, 0 ) AS VIOLATION_FLUCTUATE_RATE ,
  COALESCE(VIOLATION_PREPAYMENT_RATE, 0 ) AS VIOLATION_PREPAYMENT_RATE ,
  COALESCE(UP_FLUCTUATE_RATE, 0 ) AS UP_FLUCTUATE_RATE ,
  COALESCE(EFFECTIVE_DATE,'4999-12-31 00:00:00' ) AS EFFECTIVE_DATE ,
  COALESCE(INVALID_DATE,'4999-12-31 00:00:00' ) AS INVALID_DATE ,
  COALESCE(TIME_MARK,'4999-12-31 00:00:00' ) AS TIME_MARK ,
  COALESCE(DAY_RATE, '' ) AS DAY_RATE ,
  COALESCE(RATE_ADJUST_DATE_CODE, '' ) AS RATE_ADJUST_DATE_CODE ,
  COALESCE(RATE_ADJUST_DATE,'4999-12-31 00:00:00' ) AS RATE_ADJUST_DATE ,
  COALESCE(RATE_CHANGE_MONTH, '' ) AS RATE_CHANGE_MONTH ,
  COALESCE(RATE_CHANGE_DAY, '' ) AS RATE_CHANGE_DAY ,
  COALESCE(FIRSE_CHANGE_DATE,'4999-12-31 00:00:00' ) AS FIRSE_CHANGE_DATE ,
  COALESCE(CHANGE_DATE_TYPE, '' ) AS CHANGE_DATE_TYPE ,
  COALESCE(RATE_APPLY_TYPE, '' ) AS RATE_APPLY_TYPE ,
  COALESCE(IF_CALBYLATEST_PRDINT, '' ) AS IF_CALBYLATEST_PRDINT ,
  COALESCE(FXBS_TIME_MARK,'4999-12-31 00:00:00' ) AS FXBS_TIME_MARK 
 FROM  dw_tdata.CCS_004_TB_CON_PAYOUT_INT_RATE_${TX_DATE_YYYYMMDD}) N
LEFT JOIN
 (SELECT 
  PAYOUT_INFO_DETAIL_ID ,
  INT_RATE_ID ,
  PAYOUT_INFO_ID ,
  IR_TYPE_CD ,
  IR_GIST_STYLE_CD ,
  IR_NEGO_SYMB_CD ,
  IR_NEGO_RATE ,
  IR_FLUCTUATE_TYPE ,
  IR_GRADE_CD ,
  IR_SETTLEMT_DATE ,
  IR_SETTLEMT_STYLE_CD ,
  IR_RATE_DIFFERENCE ,
  IR_ADJUST_CYC ,
  IR_PAY_MODE_CD ,
  IR_OTHER_STYLE ,
  IR_SETTLEMENT_IND ,
  IR_PAY_NAME ,
  IR_SETTLEMENT_RATE ,
  IR_SETTLEMENT_END_DATE ,
  BENCHMARK_IR_YEAR_RATE ,
  IR_RATE_YEAR ,
  IR_FREE_IND ,
  IR_FREE_TERM ,
  IR_FREE_TERM_TYPE_CD ,
  IR_COUNT_WAY ,
  IR_COUNT_ACCRUAL_CYC_CD ,
  OVDUE_IR_GIST_STYLE_CD ,
  OVDUE_IR_NEGO_SYMB_CD ,
  OVDUE_IR_NEGO_RATE ,
  OVDUE_IR_YEAR_RATE ,
  OVDUE_IR_DIFFERENCE ,
  PECUL_IR_GIST_STYLE_CD ,
  PECUL_IR_NEGO_SYMB_CD ,
  PECUL_IR_NEGO_RATE ,
  PECUL_IR_YEAR_RATE ,
  PECUL_IR_SETTLEMT_STYLE_CD ,
  ADVANCE_RESTORE_TYPE ,
  ADVANCE_UP_RATE ,
  ADVANCE_BREACH_AMT ,
  PREPAYMENT_QUOTA ,
  ADVANCE_GIST_STYLE_CD ,
  PREPAY_QUOTA_FLUCTUATE_RATE ,
  ADVANCE_BREACH_AMT_RATE ,
  PUNISH_GIST_STYLE_CD ,
  PUNISH_NEGO_SYMB_CD ,
  PUNISH_NEGO_RATE ,
  PUNISH_RATE_YEAR ,
  BREACH_AMT_RATE ,
  HANDLING_FEE_BREACH_AMT ,
  BAIL_ACCT_RATE_EXECUTE_CD ,
  PUNISH_AGAIN_RATE ,
  NORM_VIOLATION_RATE ,
  EXE_VIOLATION_RATE ,
  VIOLATION_FLUCTUATE_RATE ,
  VIOLATION_PREPAYMENT_RATE ,
  UP_FLUCTUATE_RATE ,
  EFFECTIVE_DATE ,
  INVALID_DATE ,
  TIME_MARK ,
  DAY_RATE ,
  RATE_ADJUST_DATE_CODE ,
  RATE_ADJUST_DATE ,
  RATE_CHANGE_MONTH ,
  RATE_CHANGE_DAY ,
  FIRSE_CHANGE_DATE ,
  CHANGE_DATE_TYPE ,
  RATE_APPLY_TYPE ,
  IF_CALBYLATEST_PRDINT ,
  FXBS_TIME_MARK 
 FROM dw_sdata.CCS_004_TB_CON_PAYOUT_INT_RATE 
 WHERE END_DT = DATE('2100-12-31') ) T
ON N.INT_RATE_ID = T.INT_RATE_ID
WHERE
(T.INT_RATE_ID IS NULL)
 OR N.PAYOUT_INFO_DETAIL_ID<>T.PAYOUT_INFO_DETAIL_ID
 OR N.PAYOUT_INFO_ID<>T.PAYOUT_INFO_ID
 OR N.IR_TYPE_CD<>T.IR_TYPE_CD
 OR N.IR_GIST_STYLE_CD<>T.IR_GIST_STYLE_CD
 OR N.IR_NEGO_SYMB_CD<>T.IR_NEGO_SYMB_CD
 OR N.IR_NEGO_RATE<>T.IR_NEGO_RATE
 OR N.IR_FLUCTUATE_TYPE<>T.IR_FLUCTUATE_TYPE
 OR N.IR_GRADE_CD<>T.IR_GRADE_CD
 OR N.IR_SETTLEMT_DATE<>T.IR_SETTLEMT_DATE
 OR N.IR_SETTLEMT_STYLE_CD<>T.IR_SETTLEMT_STYLE_CD
 OR N.IR_RATE_DIFFERENCE<>T.IR_RATE_DIFFERENCE
 OR N.IR_ADJUST_CYC<>T.IR_ADJUST_CYC
 OR N.IR_PAY_MODE_CD<>T.IR_PAY_MODE_CD
 OR N.IR_OTHER_STYLE<>T.IR_OTHER_STYLE
 OR N.IR_SETTLEMENT_IND<>T.IR_SETTLEMENT_IND
 OR N.IR_PAY_NAME<>T.IR_PAY_NAME
 OR N.IR_SETTLEMENT_RATE<>T.IR_SETTLEMENT_RATE
 OR N.IR_SETTLEMENT_END_DATE<>T.IR_SETTLEMENT_END_DATE
 OR N.BENCHMARK_IR_YEAR_RATE<>T.BENCHMARK_IR_YEAR_RATE
 OR N.IR_RATE_YEAR<>T.IR_RATE_YEAR
 OR N.IR_FREE_IND<>T.IR_FREE_IND
 OR N.IR_FREE_TERM<>T.IR_FREE_TERM
 OR N.IR_FREE_TERM_TYPE_CD<>T.IR_FREE_TERM_TYPE_CD
 OR N.IR_COUNT_WAY<>T.IR_COUNT_WAY
 OR N.IR_COUNT_ACCRUAL_CYC_CD<>T.IR_COUNT_ACCRUAL_CYC_CD
 OR N.OVDUE_IR_GIST_STYLE_CD<>T.OVDUE_IR_GIST_STYLE_CD
 OR N.OVDUE_IR_NEGO_SYMB_CD<>T.OVDUE_IR_NEGO_SYMB_CD
 OR N.OVDUE_IR_NEGO_RATE<>T.OVDUE_IR_NEGO_RATE
 OR N.OVDUE_IR_YEAR_RATE<>T.OVDUE_IR_YEAR_RATE
 OR N.OVDUE_IR_DIFFERENCE<>T.OVDUE_IR_DIFFERENCE
 OR N.PECUL_IR_GIST_STYLE_CD<>T.PECUL_IR_GIST_STYLE_CD
 OR N.PECUL_IR_NEGO_SYMB_CD<>T.PECUL_IR_NEGO_SYMB_CD
 OR N.PECUL_IR_NEGO_RATE<>T.PECUL_IR_NEGO_RATE
 OR N.PECUL_IR_YEAR_RATE<>T.PECUL_IR_YEAR_RATE
 OR N.PECUL_IR_SETTLEMT_STYLE_CD<>T.PECUL_IR_SETTLEMT_STYLE_CD
 OR N.ADVANCE_RESTORE_TYPE<>T.ADVANCE_RESTORE_TYPE
 OR N.ADVANCE_UP_RATE<>T.ADVANCE_UP_RATE
 OR N.ADVANCE_BREACH_AMT<>T.ADVANCE_BREACH_AMT
 OR N.PREPAYMENT_QUOTA<>T.PREPAYMENT_QUOTA
 OR N.ADVANCE_GIST_STYLE_CD<>T.ADVANCE_GIST_STYLE_CD
 OR N.PREPAY_QUOTA_FLUCTUATE_RATE<>T.PREPAY_QUOTA_FLUCTUATE_RATE
 OR N.ADVANCE_BREACH_AMT_RATE<>T.ADVANCE_BREACH_AMT_RATE
 OR N.PUNISH_GIST_STYLE_CD<>T.PUNISH_GIST_STYLE_CD
 OR N.PUNISH_NEGO_SYMB_CD<>T.PUNISH_NEGO_SYMB_CD
 OR N.PUNISH_NEGO_RATE<>T.PUNISH_NEGO_RATE
 OR N.PUNISH_RATE_YEAR<>T.PUNISH_RATE_YEAR
 OR N.BREACH_AMT_RATE<>T.BREACH_AMT_RATE
 OR N.HANDLING_FEE_BREACH_AMT<>T.HANDLING_FEE_BREACH_AMT
 OR N.BAIL_ACCT_RATE_EXECUTE_CD<>T.BAIL_ACCT_RATE_EXECUTE_CD
 OR N.PUNISH_AGAIN_RATE<>T.PUNISH_AGAIN_RATE
 OR N.NORM_VIOLATION_RATE<>T.NORM_VIOLATION_RATE
 OR N.EXE_VIOLATION_RATE<>T.EXE_VIOLATION_RATE
 OR N.VIOLATION_FLUCTUATE_RATE<>T.VIOLATION_FLUCTUATE_RATE
 OR N.VIOLATION_PREPAYMENT_RATE<>T.VIOLATION_PREPAYMENT_RATE
 OR N.UP_FLUCTUATE_RATE<>T.UP_FLUCTUATE_RATE
 OR N.EFFECTIVE_DATE<>T.EFFECTIVE_DATE
 OR N.INVALID_DATE<>T.INVALID_DATE
 OR N.TIME_MARK<>T.TIME_MARK
 OR N.DAY_RATE<>T.DAY_RATE
 OR N.RATE_ADJUST_DATE_CODE<>T.RATE_ADJUST_DATE_CODE
 OR N.RATE_ADJUST_DATE<>T.RATE_ADJUST_DATE
 OR N.RATE_CHANGE_MONTH<>T.RATE_CHANGE_MONTH
 OR N.RATE_CHANGE_DAY<>T.RATE_CHANGE_DAY
 OR N.FIRSE_CHANGE_DATE<>T.FIRSE_CHANGE_DATE
 OR N.CHANGE_DATE_TYPE<>T.CHANGE_DATE_TYPE
 OR N.RATE_APPLY_TYPE<>T.RATE_APPLY_TYPE
 OR N.IF_CALBYLATEST_PRDINT<>T.IF_CALBYLATEST_PRDINT
 OR N.FXBS_TIME_MARK<>T.FXBS_TIME_MARK
;

--Step3:
UPDATE dw_sdata.CCS_004_TB_CON_PAYOUT_INT_RATE P 
SET End_Dt=DATE('${TX_DATE_YYYYMMDD}')
FROM T_114
WHERE P.End_Dt=DATE('2100-12-31')
AND P.INT_RATE_ID=T_114.INT_RATE_ID
;

--Step4:
INSERT  INTO dw_sdata.CCS_004_TB_CON_PAYOUT_INT_RATE SELECT * FROM T_114;

COMMIT;

ENDOFINPUT

  close(VSQL);

  my $RET_CODE = $? >> 8;

  if ( $RET_CODE == 0 ) {
      return 0;
  }
  else {
      return 1;
  }
}

# ------------ main function ------------
sub main
{
   my $ret;
   open(LOGONFILE_H, "${LOGON_FILE}");
   ${LOGON_STR} = <LOGONFILE_H>;
   close(LOGONFILE_H);
   
   # Get the decoded logon string
   my($user,$passwd) = split(',',${LOGON_STR}); 
   #my $decodepasswd = `${AUTO_HOME}/bin/IceCode.exe -d "$passwd" "$user"`;                     
   #${LOGON_STR} = "|vsql -h 192.168.2.44 -p 5433 -d CPCIMDB_TEST -U ".$user." -w ".$decodepasswd;

   # Call vsql command to load data
   $ret = run_vsql_command();

   print "run_vsql_command() = $ret";
   return $ret;
}

# ------------ program section ------------
if ( $#ARGV < 0 ) {
   print "Usage: [perl ������ Control_File] (Control_File format: dir.jobnameYYYYMMDD or sysname_jobname_YYYYMMDD.dir) 
";
   print "
";
   exit(1);
}

# Get the first argument
${CONTROL_FILE} = $ARGV[0];

if (${CONTROL_FILE} =~/[0-9]{8}($|\.)/) {
   ${TX_DATE_YYYYMMDD} = substr($&,0,8);
}
else{
   print "Usage: [perl ������ Control_File] (Control_File format: dir.jobnameYYYYMMDD or sysname_jobname_YYYYMMDD.dir) 
";
   print "
";
   exit(1);
}

${TX_MON_DAY_MMDD} = substr(${TX_DATE_YYYYMMDD}, length(${TX_DATE_YYYYMMDD})-4,4);
${TX_DATE} = substr(${TX_DATE_YYYYMMDD}, 0, 4)."-".substr(${TX_DATE_YYYYMMDD}, 4, 2)."-".substr(${TX_DATE_YYYYMMDD}, 6, 2);
open(STDERR, ">&STDOUT");

my $ret = main();

exit($ret);