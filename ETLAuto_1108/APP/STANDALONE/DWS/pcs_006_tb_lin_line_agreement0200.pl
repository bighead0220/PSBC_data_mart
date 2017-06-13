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
DELETE FROM dw_sdata.PCS_006_TB_LIN_LINE_AGREEMENT WHERE start_dt>=DATE('${TX_DATE_YYYYMMDD}');
UPDATE dw_sdata.PCS_006_TB_LIN_LINE_AGREEMENT SET end_dt=DATE('2100-12-31') WHERE end_dt>=DATE('${TX_DATE_YYYYMMDD}') AND end_dt<>DATE('2100-12-31');

--Step1:
CREATE LOCAL TEMPORARY TABLE  T_333 ON COMMIT PRESERVE ROWS AS SELECT * FROM dw_sdata.PCS_006_TB_LIN_LINE_AGREEMENT WHERE 1=0;

--Step2:
INSERT  INTO T_333 (
  LINE_ID,
  CUS_ID,
  AGREEMENT_NAME,
  CONTRACT_NUM,
  CYCLE_FLAG,
  CONTRACT_AMOUNT,
  LINE_BEGIN_DATE,
  LINE_MATURE_DATE,
  LINE_AJUSTEND_DATE,
  LOAN_AJUSTEND_DATE,
  SECURITY_KIND,
  CONTRACT_QUANTITY,
  IS_CONSIGN_ADMISSIBILITY,
  IS_CONSIGN_SURVEY,
  IS_HELP_APPROVAL,
  IS_CONSIGN_CONTRACT,
  IS_CONSIGN_IMPLEMENT,
  IS_CONSIGN_HANDLE,
  IS_CONSIGN_LOANS,
  IS_CONSIGN_RECOVER,
  IS_CONSIGN_INSURANCE,
  IS_CALCULATE_REPAYMENTS,
  IS_POST_LOAN,
  IS_FILE_MANAGEMENT,
  IS_FUNDS_TRANSFER,
  FEE_RATE_STANDARD,
  FUNDS_PAYMENT_DEADLINE,
  FUNDS_PAYMENT,
  COOPERATION_BEGIN_DATE,
  COOPERATION_END_DATE,
  SECURITY_HANDLE_ORDER,
  IS_CONSISTENCY,
  REPAYMENT_ORDER,
  INSURANCE_HANDLE_ORDER,
  IS_COLLECT_POUNDAGE,
  COLLECT_TYPE,
  BASIC_AMOUNT,
  POUNDAGE_RATE,
  POUNDAGE_CYCLE,
  IS_FIXED,
  DEDUCT_DATE,
  PROVINCE_NUM,
  CREATE_TIME,
  UPDATE_TIME,
  DELFLAG,
  TRUNC_NO,
  start_dt,
  end_dt)
SELECT
  N.LINE_ID,
  N.CUS_ID,
  N.AGREEMENT_NAME,
  N.CONTRACT_NUM,
  N.CYCLE_FLAG,
  N.CONTRACT_AMOUNT,
  N.LINE_BEGIN_DATE,
  N.LINE_MATURE_DATE,
  N.LINE_AJUSTEND_DATE,
  N.LOAN_AJUSTEND_DATE,
  N.SECURITY_KIND,
  N.CONTRACT_QUANTITY,
  N.IS_CONSIGN_ADMISSIBILITY,
  N.IS_CONSIGN_SURVEY,
  N.IS_HELP_APPROVAL,
  N.IS_CONSIGN_CONTRACT,
  N.IS_CONSIGN_IMPLEMENT,
  N.IS_CONSIGN_HANDLE,
  N.IS_CONSIGN_LOANS,
  N.IS_CONSIGN_RECOVER,
  N.IS_CONSIGN_INSURANCE,
  N.IS_CALCULATE_REPAYMENTS,
  N.IS_POST_LOAN,
  N.IS_FILE_MANAGEMENT,
  N.IS_FUNDS_TRANSFER,
  N.FEE_RATE_STANDARD,
  N.FUNDS_PAYMENT_DEADLINE,
  N.FUNDS_PAYMENT,
  N.COOPERATION_BEGIN_DATE,
  N.COOPERATION_END_DATE,
  N.SECURITY_HANDLE_ORDER,
  N.IS_CONSISTENCY,
  N.REPAYMENT_ORDER,
  N.INSURANCE_HANDLE_ORDER,
  N.IS_COLLECT_POUNDAGE,
  N.COLLECT_TYPE,
  N.BASIC_AMOUNT,
  N.POUNDAGE_RATE,
  N.POUNDAGE_CYCLE,
  N.IS_FIXED,
  N.DEDUCT_DATE,
  N.PROVINCE_NUM,
  N.CREATE_TIME,
  N.UPDATE_TIME,
  N.DELFLAG,
  N.TRUNC_NO,
  DATE('${TX_DATE_YYYYMMDD}'),
  DATE('2100-12-31')
FROM 
 (SELECT
  COALESCE(LINE_ID, '' ) AS LINE_ID ,
  COALESCE(CUS_ID, '' ) AS CUS_ID ,
  COALESCE(AGREEMENT_NAME, '' ) AS AGREEMENT_NAME ,
  COALESCE(CONTRACT_NUM, '' ) AS CONTRACT_NUM ,
  COALESCE(CYCLE_FLAG, '' ) AS CYCLE_FLAG ,
  COALESCE(CONTRACT_AMOUNT, 0 ) AS CONTRACT_AMOUNT ,
  COALESCE(LINE_BEGIN_DATE,DATE('4999-12-31') ) AS LINE_BEGIN_DATE ,
  COALESCE(LINE_MATURE_DATE,DATE('4999-12-31') ) AS LINE_MATURE_DATE ,
  COALESCE(LINE_AJUSTEND_DATE,DATE('4999-12-31') ) AS LINE_AJUSTEND_DATE ,
  COALESCE(LOAN_AJUSTEND_DATE,DATE('4999-12-31') ) AS LOAN_AJUSTEND_DATE ,
  COALESCE(SECURITY_KIND, '' ) AS SECURITY_KIND ,
  COALESCE(CONTRACT_QUANTITY, 0 ) AS CONTRACT_QUANTITY ,
  COALESCE(IS_CONSIGN_ADMISSIBILITY, '' ) AS IS_CONSIGN_ADMISSIBILITY ,
  COALESCE(IS_CONSIGN_SURVEY, '' ) AS IS_CONSIGN_SURVEY ,
  COALESCE(IS_HELP_APPROVAL, '' ) AS IS_HELP_APPROVAL ,
  COALESCE(IS_CONSIGN_CONTRACT, '' ) AS IS_CONSIGN_CONTRACT ,
  COALESCE(IS_CONSIGN_IMPLEMENT, '' ) AS IS_CONSIGN_IMPLEMENT ,
  COALESCE(IS_CONSIGN_HANDLE, '' ) AS IS_CONSIGN_HANDLE ,
  COALESCE(IS_CONSIGN_LOANS, '' ) AS IS_CONSIGN_LOANS ,
  COALESCE(IS_CONSIGN_RECOVER, '' ) AS IS_CONSIGN_RECOVER ,
  COALESCE(IS_CONSIGN_INSURANCE, '' ) AS IS_CONSIGN_INSURANCE ,
  COALESCE(IS_CALCULATE_REPAYMENTS, '' ) AS IS_CALCULATE_REPAYMENTS ,
  COALESCE(IS_POST_LOAN, '' ) AS IS_POST_LOAN ,
  COALESCE(IS_FILE_MANAGEMENT, '' ) AS IS_FILE_MANAGEMENT ,
  COALESCE(IS_FUNDS_TRANSFER, '' ) AS IS_FUNDS_TRANSFER ,
  COALESCE(FEE_RATE_STANDARD, 0 ) AS FEE_RATE_STANDARD ,
  COALESCE(FUNDS_PAYMENT_DEADLINE, '' ) AS FUNDS_PAYMENT_DEADLINE ,
  COALESCE(FUNDS_PAYMENT, '' ) AS FUNDS_PAYMENT ,
  COALESCE(COOPERATION_BEGIN_DATE,DATE('4999-12-31') ) AS COOPERATION_BEGIN_DATE ,
  COALESCE(COOPERATION_END_DATE,DATE('4999-12-31') ) AS COOPERATION_END_DATE ,
  COALESCE(SECURITY_HANDLE_ORDER, '' ) AS SECURITY_HANDLE_ORDER ,
  COALESCE(IS_CONSISTENCY, '' ) AS IS_CONSISTENCY ,
  COALESCE(REPAYMENT_ORDER, '' ) AS REPAYMENT_ORDER ,
  COALESCE(INSURANCE_HANDLE_ORDER, '' ) AS INSURANCE_HANDLE_ORDER ,
  COALESCE(IS_COLLECT_POUNDAGE, '' ) AS IS_COLLECT_POUNDAGE ,
  COALESCE(COLLECT_TYPE, '' ) AS COLLECT_TYPE ,
  COALESCE(BASIC_AMOUNT, '' ) AS BASIC_AMOUNT ,
  COALESCE(POUNDAGE_RATE, 0 ) AS POUNDAGE_RATE ,
  COALESCE(POUNDAGE_CYCLE, '' ) AS POUNDAGE_CYCLE ,
  COALESCE(IS_FIXED, '' ) AS IS_FIXED ,
  COALESCE(DEDUCT_DATE,DATE('4999-12-31') ) AS DEDUCT_DATE ,
  COALESCE(PROVINCE_NUM, '' ) AS PROVINCE_NUM ,
  COALESCE(CREATE_TIME,'4999-12-31 00:00:00' ) AS CREATE_TIME ,
  COALESCE(UPDATE_TIME,'4999-12-31 00:00:00' ) AS UPDATE_TIME ,
  COALESCE(DELFLAG, '' ) AS DELFLAG ,
  COALESCE(TRUNC_NO, 0 ) AS TRUNC_NO 
 FROM  dw_tdata.PCS_006_TB_LIN_LINE_AGREEMENT_${TX_DATE_YYYYMMDD}) N
LEFT JOIN
 (SELECT 
  LINE_ID ,
  CUS_ID ,
  AGREEMENT_NAME ,
  CONTRACT_NUM ,
  CYCLE_FLAG ,
  CONTRACT_AMOUNT ,
  LINE_BEGIN_DATE ,
  LINE_MATURE_DATE ,
  LINE_AJUSTEND_DATE ,
  LOAN_AJUSTEND_DATE ,
  SECURITY_KIND ,
  CONTRACT_QUANTITY ,
  IS_CONSIGN_ADMISSIBILITY ,
  IS_CONSIGN_SURVEY ,
  IS_HELP_APPROVAL ,
  IS_CONSIGN_CONTRACT ,
  IS_CONSIGN_IMPLEMENT ,
  IS_CONSIGN_HANDLE ,
  IS_CONSIGN_LOANS ,
  IS_CONSIGN_RECOVER ,
  IS_CONSIGN_INSURANCE ,
  IS_CALCULATE_REPAYMENTS ,
  IS_POST_LOAN ,
  IS_FILE_MANAGEMENT ,
  IS_FUNDS_TRANSFER ,
  FEE_RATE_STANDARD ,
  FUNDS_PAYMENT_DEADLINE ,
  FUNDS_PAYMENT ,
  COOPERATION_BEGIN_DATE ,
  COOPERATION_END_DATE ,
  SECURITY_HANDLE_ORDER ,
  IS_CONSISTENCY ,
  REPAYMENT_ORDER ,
  INSURANCE_HANDLE_ORDER ,
  IS_COLLECT_POUNDAGE ,
  COLLECT_TYPE ,
  BASIC_AMOUNT ,
  POUNDAGE_RATE ,
  POUNDAGE_CYCLE ,
  IS_FIXED ,
  DEDUCT_DATE ,
  PROVINCE_NUM ,
  CREATE_TIME ,
  UPDATE_TIME ,
  DELFLAG ,
  TRUNC_NO 
 FROM dw_sdata.PCS_006_TB_LIN_LINE_AGREEMENT 
 WHERE END_DT = DATE('2100-12-31') ) T
ON N.LINE_ID = T.LINE_ID
WHERE
(T.LINE_ID IS NULL)
 OR N.CUS_ID<>T.CUS_ID
 OR N.AGREEMENT_NAME<>T.AGREEMENT_NAME
 OR N.CONTRACT_NUM<>T.CONTRACT_NUM
 OR N.CYCLE_FLAG<>T.CYCLE_FLAG
 OR N.CONTRACT_AMOUNT<>T.CONTRACT_AMOUNT
 OR N.LINE_BEGIN_DATE<>T.LINE_BEGIN_DATE
 OR N.LINE_MATURE_DATE<>T.LINE_MATURE_DATE
 OR N.LINE_AJUSTEND_DATE<>T.LINE_AJUSTEND_DATE
 OR N.LOAN_AJUSTEND_DATE<>T.LOAN_AJUSTEND_DATE
 OR N.SECURITY_KIND<>T.SECURITY_KIND
 OR N.CONTRACT_QUANTITY<>T.CONTRACT_QUANTITY
 OR N.IS_CONSIGN_ADMISSIBILITY<>T.IS_CONSIGN_ADMISSIBILITY
 OR N.IS_CONSIGN_SURVEY<>T.IS_CONSIGN_SURVEY
 OR N.IS_HELP_APPROVAL<>T.IS_HELP_APPROVAL
 OR N.IS_CONSIGN_CONTRACT<>T.IS_CONSIGN_CONTRACT
 OR N.IS_CONSIGN_IMPLEMENT<>T.IS_CONSIGN_IMPLEMENT
 OR N.IS_CONSIGN_HANDLE<>T.IS_CONSIGN_HANDLE
 OR N.IS_CONSIGN_LOANS<>T.IS_CONSIGN_LOANS
 OR N.IS_CONSIGN_RECOVER<>T.IS_CONSIGN_RECOVER
 OR N.IS_CONSIGN_INSURANCE<>T.IS_CONSIGN_INSURANCE
 OR N.IS_CALCULATE_REPAYMENTS<>T.IS_CALCULATE_REPAYMENTS
 OR N.IS_POST_LOAN<>T.IS_POST_LOAN
 OR N.IS_FILE_MANAGEMENT<>T.IS_FILE_MANAGEMENT
 OR N.IS_FUNDS_TRANSFER<>T.IS_FUNDS_TRANSFER
 OR N.FEE_RATE_STANDARD<>T.FEE_RATE_STANDARD
 OR N.FUNDS_PAYMENT_DEADLINE<>T.FUNDS_PAYMENT_DEADLINE
 OR N.FUNDS_PAYMENT<>T.FUNDS_PAYMENT
 OR N.COOPERATION_BEGIN_DATE<>T.COOPERATION_BEGIN_DATE
 OR N.COOPERATION_END_DATE<>T.COOPERATION_END_DATE
 OR N.SECURITY_HANDLE_ORDER<>T.SECURITY_HANDLE_ORDER
 OR N.IS_CONSISTENCY<>T.IS_CONSISTENCY
 OR N.REPAYMENT_ORDER<>T.REPAYMENT_ORDER
 OR N.INSURANCE_HANDLE_ORDER<>T.INSURANCE_HANDLE_ORDER
 OR N.IS_COLLECT_POUNDAGE<>T.IS_COLLECT_POUNDAGE
 OR N.COLLECT_TYPE<>T.COLLECT_TYPE
 OR N.BASIC_AMOUNT<>T.BASIC_AMOUNT
 OR N.POUNDAGE_RATE<>T.POUNDAGE_RATE
 OR N.POUNDAGE_CYCLE<>T.POUNDAGE_CYCLE
 OR N.IS_FIXED<>T.IS_FIXED
 OR N.DEDUCT_DATE<>T.DEDUCT_DATE
 OR N.PROVINCE_NUM<>T.PROVINCE_NUM
 OR N.CREATE_TIME<>T.CREATE_TIME
 OR N.UPDATE_TIME<>T.UPDATE_TIME
 OR N.DELFLAG<>T.DELFLAG
 OR N.TRUNC_NO<>T.TRUNC_NO
;

--Step3:
UPDATE dw_sdata.PCS_006_TB_LIN_LINE_AGREEMENT P 
SET End_Dt=DATE('${TX_DATE_YYYYMMDD}')
FROM T_333
WHERE P.End_Dt=DATE('2100-12-31')
AND P.LINE_ID=T_333.LINE_ID
;

--Step4:
INSERT  INTO dw_sdata.PCS_006_TB_LIN_LINE_AGREEMENT SELECT * FROM T_333;

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