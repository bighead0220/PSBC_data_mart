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
DELETE FROM dw_sdata.CCS_004_TB_CON_SUBCONTRACT WHERE start_dt>=DATE('${TX_DATE_YYYYMMDD}');
UPDATE dw_sdata.CCS_004_TB_CON_SUBCONTRACT SET end_dt=DATE('2100-12-31') WHERE end_dt>=DATE('${TX_DATE_YYYYMMDD}') AND end_dt<>DATE('2100-12-31');

--Step1:
CREATE LOCAL TEMPORARY TABLE  T_116 ON COMMIT PRESERVE ROWS AS SELECT * FROM dw_sdata.CCS_004_TB_CON_SUBCONTRACT WHERE 1=0;

--Step2:
INSERT  INTO T_116 (
  SUBCONTRACT_ID,
  CONTRACT_NUM,
  SUBCONTRACT_NUM,
  CUSTOMER_NUM,
  CURRENCY_CD,
  GUARANTY_AMT,
  SUPER_TOP_GUARANTY_ID,
  TOP_GUARANTY_START_DATE,
  TOP_GUARANTY_EXPIRATION_DATE,
  SUB_CONTRACT_SIGN_DATE,
  SUB_CONTRACT_SIGN_PLACE,
  SUBCONTRACT_TYPE_CD,
  START_DATE,
  SUBCONTRACT_STATUS_CD,
  EXPIRATION_DATE,
  HANDLING_ORG_CD,
  OTHER_PROMISE,
  HANDLING_USER_NUM,
  SUB_CONTRACT_AMT,
  GUARANTY_USE_AMT_COUNT,
  SUB_CONT_RATE,
  TOP_GUARANTY_AMT,
  TOP_CUMULATE_GUARANTY_AMT,
  GUARANT_CUSTOMER_NUM,
  GUARANTY_RATE,
  DEBT_CUSTOMER_NUM,
  GUARANTEE_TYPE_CD,
  SUBCONTRACT_MANUAL_NUM,
  WARRANTOR_NAME,
  DEBT_PERSON_NAME,
  TOP_USE_GUARANTY_AMT,
  IF_TOP_GUARANTY,
  COLLATERAL_TYPE_CD,
  REGISTER_ORG,
  COLLATERAL_REMARK,
  IMPORT_IND,
  PRINT_SUBCONTRACT_TYPE,
  CONTRACT_ID,
  TOP_CYCLE_IND,
  TIME_MARK,
  CONTACRT_NAME,
  WARRANT_CONTACRT_SCALE,
  FAITH_DUTY,
  SEARCH_AREA,
  SUPPLY_ITEM,
  CONTRACT_PAGE,
  SIGN_DAYS,
  HANDING_DATE,
  HIGH_ADJUSTING_IND,
  FXBS_TIME_MARK,
  start_dt,
  end_dt)
SELECT
  N.SUBCONTRACT_ID,
  N.CONTRACT_NUM,
  N.SUBCONTRACT_NUM,
  N.CUSTOMER_NUM,
  N.CURRENCY_CD,
  N.GUARANTY_AMT,
  N.SUPER_TOP_GUARANTY_ID,
  N.TOP_GUARANTY_START_DATE,
  N.TOP_GUARANTY_EXPIRATION_DATE,
  N.SUB_CONTRACT_SIGN_DATE,
  N.SUB_CONTRACT_SIGN_PLACE,
  N.SUBCONTRACT_TYPE_CD,
  N.START_DATE,
  N.SUBCONTRACT_STATUS_CD,
  N.EXPIRATION_DATE,
  N.HANDLING_ORG_CD,
  N.OTHER_PROMISE,
  N.HANDLING_USER_NUM,
  N.SUB_CONTRACT_AMT,
  N.GUARANTY_USE_AMT_COUNT,
  N.SUB_CONT_RATE,
  N.TOP_GUARANTY_AMT,
  N.TOP_CUMULATE_GUARANTY_AMT,
  N.GUARANT_CUSTOMER_NUM,
  N.GUARANTY_RATE,
  N.DEBT_CUSTOMER_NUM,
  N.GUARANTEE_TYPE_CD,
  N.SUBCONTRACT_MANUAL_NUM,
  N.WARRANTOR_NAME,
  N.DEBT_PERSON_NAME,
  N.TOP_USE_GUARANTY_AMT,
  N.IF_TOP_GUARANTY,
  N.COLLATERAL_TYPE_CD,
  N.REGISTER_ORG,
  N.COLLATERAL_REMARK,
  N.IMPORT_IND,
  N.PRINT_SUBCONTRACT_TYPE,
  N.CONTRACT_ID,
  N.TOP_CYCLE_IND,
  N.TIME_MARK,
  N.CONTACRT_NAME,
  N.WARRANT_CONTACRT_SCALE,
  N.FAITH_DUTY,
  N.SEARCH_AREA,
  N.SUPPLY_ITEM,
  N.CONTRACT_PAGE,
  N.SIGN_DAYS,
  N.HANDING_DATE,
  N.HIGH_ADJUSTING_IND,
  N.FXBS_TIME_MARK,
  DATE('${TX_DATE_YYYYMMDD}'),
  DATE('2100-12-31')
FROM 
 (SELECT
  COALESCE(SUBCONTRACT_ID, '' ) AS SUBCONTRACT_ID ,
  COALESCE(CONTRACT_NUM, '' ) AS CONTRACT_NUM ,
  COALESCE(SUBCONTRACT_NUM, '' ) AS SUBCONTRACT_NUM ,
  COALESCE(CUSTOMER_NUM, '' ) AS CUSTOMER_NUM ,
  COALESCE(CURRENCY_CD, '' ) AS CURRENCY_CD ,
  COALESCE(GUARANTY_AMT, 0 ) AS GUARANTY_AMT ,
  COALESCE(SUPER_TOP_GUARANTY_ID, '' ) AS SUPER_TOP_GUARANTY_ID ,
  COALESCE(TOP_GUARANTY_START_DATE,'4999-12-31 00:00:00' ) AS TOP_GUARANTY_START_DATE ,
  COALESCE(TOP_GUARANTY_EXPIRATION_DATE,'4999-12-31 00:00:00' ) AS TOP_GUARANTY_EXPIRATION_DATE ,
  COALESCE(SUB_CONTRACT_SIGN_DATE,'4999-12-31 00:00:00' ) AS SUB_CONTRACT_SIGN_DATE ,
  COALESCE(SUB_CONTRACT_SIGN_PLACE, '' ) AS SUB_CONTRACT_SIGN_PLACE ,
  COALESCE(SUBCONTRACT_TYPE_CD, '' ) AS SUBCONTRACT_TYPE_CD ,
  COALESCE(START_DATE,'4999-12-31 00:00:00' ) AS START_DATE ,
  COALESCE(SUBCONTRACT_STATUS_CD, '' ) AS SUBCONTRACT_STATUS_CD ,
  COALESCE(EXPIRATION_DATE,'4999-12-31 00:00:00' ) AS EXPIRATION_DATE ,
  COALESCE(HANDLING_ORG_CD, '' ) AS HANDLING_ORG_CD ,
  COALESCE(OTHER_PROMISE, '' ) AS OTHER_PROMISE ,
  COALESCE(HANDLING_USER_NUM, '' ) AS HANDLING_USER_NUM ,
  COALESCE(SUB_CONTRACT_AMT, 0 ) AS SUB_CONTRACT_AMT ,
  COALESCE(GUARANTY_USE_AMT_COUNT, 0 ) AS GUARANTY_USE_AMT_COUNT ,
  COALESCE(SUB_CONT_RATE, 0 ) AS SUB_CONT_RATE ,
  COALESCE(TOP_GUARANTY_AMT, 0 ) AS TOP_GUARANTY_AMT ,
  COALESCE(TOP_CUMULATE_GUARANTY_AMT, 0 ) AS TOP_CUMULATE_GUARANTY_AMT ,
  COALESCE(GUARANT_CUSTOMER_NUM, '' ) AS GUARANT_CUSTOMER_NUM ,
  COALESCE(GUARANTY_RATE, 0 ) AS GUARANTY_RATE ,
  COALESCE(DEBT_CUSTOMER_NUM, '' ) AS DEBT_CUSTOMER_NUM ,
  COALESCE(GUARANTEE_TYPE_CD, '' ) AS GUARANTEE_TYPE_CD ,
  COALESCE(SUBCONTRACT_MANUAL_NUM, '' ) AS SUBCONTRACT_MANUAL_NUM ,
  COALESCE(WARRANTOR_NAME, '' ) AS WARRANTOR_NAME ,
  COALESCE(DEBT_PERSON_NAME, '' ) AS DEBT_PERSON_NAME ,
  COALESCE(TOP_USE_GUARANTY_AMT, 0 ) AS TOP_USE_GUARANTY_AMT ,
  COALESCE(IF_TOP_GUARANTY, '' ) AS IF_TOP_GUARANTY ,
  COALESCE(COLLATERAL_TYPE_CD, '' ) AS COLLATERAL_TYPE_CD ,
  COALESCE(REGISTER_ORG, '' ) AS REGISTER_ORG ,
  COALESCE(COLLATERAL_REMARK, '' ) AS COLLATERAL_REMARK ,
  COALESCE(IMPORT_IND, '' ) AS IMPORT_IND ,
  COALESCE(PRINT_SUBCONTRACT_TYPE, '' ) AS PRINT_SUBCONTRACT_TYPE ,
  COALESCE(CONTRACT_ID, '' ) AS CONTRACT_ID ,
  COALESCE(TOP_CYCLE_IND, '' ) AS TOP_CYCLE_IND ,
  COALESCE(TIME_MARK,'4999-12-31 00:00:00' ) AS TIME_MARK ,
  COALESCE(CONTACRT_NAME, '' ) AS CONTACRT_NAME ,
  COALESCE(WARRANT_CONTACRT_SCALE, 0 ) AS WARRANT_CONTACRT_SCALE ,
  COALESCE(FAITH_DUTY, '' ) AS FAITH_DUTY ,
  COALESCE(SEARCH_AREA, '' ) AS SEARCH_AREA ,
  COALESCE(SUPPLY_ITEM, '' ) AS SUPPLY_ITEM ,
  COALESCE(CONTRACT_PAGE, 0 ) AS CONTRACT_PAGE ,
  COALESCE(SIGN_DAYS, 0 ) AS SIGN_DAYS ,
  COALESCE(HANDING_DATE,'4999-12-31 00:00:00' ) AS HANDING_DATE ,
  COALESCE(HIGH_ADJUSTING_IND, '' ) AS HIGH_ADJUSTING_IND ,
  COALESCE(FXBS_TIME_MARK,'4999-12-31 00:00:00' ) AS FXBS_TIME_MARK 
 FROM  dw_tdata.CCS_004_TB_CON_SUBCONTRACT_${TX_DATE_YYYYMMDD}) N
LEFT JOIN
 (SELECT 
  SUBCONTRACT_ID ,
  CONTRACT_NUM ,
  SUBCONTRACT_NUM ,
  CUSTOMER_NUM ,
  CURRENCY_CD ,
  GUARANTY_AMT ,
  SUPER_TOP_GUARANTY_ID ,
  TOP_GUARANTY_START_DATE ,
  TOP_GUARANTY_EXPIRATION_DATE ,
  SUB_CONTRACT_SIGN_DATE ,
  SUB_CONTRACT_SIGN_PLACE ,
  SUBCONTRACT_TYPE_CD ,
  START_DATE ,
  SUBCONTRACT_STATUS_CD ,
  EXPIRATION_DATE ,
  HANDLING_ORG_CD ,
  OTHER_PROMISE ,
  HANDLING_USER_NUM ,
  SUB_CONTRACT_AMT ,
  GUARANTY_USE_AMT_COUNT ,
  SUB_CONT_RATE ,
  TOP_GUARANTY_AMT ,
  TOP_CUMULATE_GUARANTY_AMT ,
  GUARANT_CUSTOMER_NUM ,
  GUARANTY_RATE ,
  DEBT_CUSTOMER_NUM ,
  GUARANTEE_TYPE_CD ,
  SUBCONTRACT_MANUAL_NUM ,
  WARRANTOR_NAME ,
  DEBT_PERSON_NAME ,
  TOP_USE_GUARANTY_AMT ,
  IF_TOP_GUARANTY ,
  COLLATERAL_TYPE_CD ,
  REGISTER_ORG ,
  COLLATERAL_REMARK ,
  IMPORT_IND ,
  PRINT_SUBCONTRACT_TYPE ,
  CONTRACT_ID ,
  TOP_CYCLE_IND ,
  TIME_MARK ,
  CONTACRT_NAME ,
  WARRANT_CONTACRT_SCALE ,
  FAITH_DUTY ,
  SEARCH_AREA ,
  SUPPLY_ITEM ,
  CONTRACT_PAGE ,
  SIGN_DAYS ,
  HANDING_DATE ,
  HIGH_ADJUSTING_IND ,
  FXBS_TIME_MARK 
 FROM dw_sdata.CCS_004_TB_CON_SUBCONTRACT 
 WHERE END_DT = DATE('2100-12-31') ) T
ON N.SUBCONTRACT_ID = T.SUBCONTRACT_ID
WHERE
(T.SUBCONTRACT_ID IS NULL)
 OR N.CONTRACT_NUM<>T.CONTRACT_NUM
 OR N.SUBCONTRACT_NUM<>T.SUBCONTRACT_NUM
 OR N.CUSTOMER_NUM<>T.CUSTOMER_NUM
 OR N.CURRENCY_CD<>T.CURRENCY_CD
 OR N.GUARANTY_AMT<>T.GUARANTY_AMT
 OR N.SUPER_TOP_GUARANTY_ID<>T.SUPER_TOP_GUARANTY_ID
 OR N.TOP_GUARANTY_START_DATE<>T.TOP_GUARANTY_START_DATE
 OR N.TOP_GUARANTY_EXPIRATION_DATE<>T.TOP_GUARANTY_EXPIRATION_DATE
 OR N.SUB_CONTRACT_SIGN_DATE<>T.SUB_CONTRACT_SIGN_DATE
 OR N.SUB_CONTRACT_SIGN_PLACE<>T.SUB_CONTRACT_SIGN_PLACE
 OR N.SUBCONTRACT_TYPE_CD<>T.SUBCONTRACT_TYPE_CD
 OR N.START_DATE<>T.START_DATE
 OR N.SUBCONTRACT_STATUS_CD<>T.SUBCONTRACT_STATUS_CD
 OR N.EXPIRATION_DATE<>T.EXPIRATION_DATE
 OR N.HANDLING_ORG_CD<>T.HANDLING_ORG_CD
 OR N.OTHER_PROMISE<>T.OTHER_PROMISE
 OR N.HANDLING_USER_NUM<>T.HANDLING_USER_NUM
 OR N.SUB_CONTRACT_AMT<>T.SUB_CONTRACT_AMT
 OR N.GUARANTY_USE_AMT_COUNT<>T.GUARANTY_USE_AMT_COUNT
 OR N.SUB_CONT_RATE<>T.SUB_CONT_RATE
 OR N.TOP_GUARANTY_AMT<>T.TOP_GUARANTY_AMT
 OR N.TOP_CUMULATE_GUARANTY_AMT<>T.TOP_CUMULATE_GUARANTY_AMT
 OR N.GUARANT_CUSTOMER_NUM<>T.GUARANT_CUSTOMER_NUM
 OR N.GUARANTY_RATE<>T.GUARANTY_RATE
 OR N.DEBT_CUSTOMER_NUM<>T.DEBT_CUSTOMER_NUM
 OR N.GUARANTEE_TYPE_CD<>T.GUARANTEE_TYPE_CD
 OR N.SUBCONTRACT_MANUAL_NUM<>T.SUBCONTRACT_MANUAL_NUM
 OR N.WARRANTOR_NAME<>T.WARRANTOR_NAME
 OR N.DEBT_PERSON_NAME<>T.DEBT_PERSON_NAME
 OR N.TOP_USE_GUARANTY_AMT<>T.TOP_USE_GUARANTY_AMT
 OR N.IF_TOP_GUARANTY<>T.IF_TOP_GUARANTY
 OR N.COLLATERAL_TYPE_CD<>T.COLLATERAL_TYPE_CD
 OR N.REGISTER_ORG<>T.REGISTER_ORG
 OR N.COLLATERAL_REMARK<>T.COLLATERAL_REMARK
 OR N.IMPORT_IND<>T.IMPORT_IND
 OR N.PRINT_SUBCONTRACT_TYPE<>T.PRINT_SUBCONTRACT_TYPE
 OR N.CONTRACT_ID<>T.CONTRACT_ID
 OR N.TOP_CYCLE_IND<>T.TOP_CYCLE_IND
 OR N.TIME_MARK<>T.TIME_MARK
 OR N.CONTACRT_NAME<>T.CONTACRT_NAME
 OR N.WARRANT_CONTACRT_SCALE<>T.WARRANT_CONTACRT_SCALE
 OR N.FAITH_DUTY<>T.FAITH_DUTY
 OR N.SEARCH_AREA<>T.SEARCH_AREA
 OR N.SUPPLY_ITEM<>T.SUPPLY_ITEM
 OR N.CONTRACT_PAGE<>T.CONTRACT_PAGE
 OR N.SIGN_DAYS<>T.SIGN_DAYS
 OR N.HANDING_DATE<>T.HANDING_DATE
 OR N.HIGH_ADJUSTING_IND<>T.HIGH_ADJUSTING_IND
 OR N.FXBS_TIME_MARK<>T.FXBS_TIME_MARK
;

--Step3:
UPDATE dw_sdata.CCS_004_TB_CON_SUBCONTRACT P 
SET End_Dt=DATE('${TX_DATE_YYYYMMDD}')
FROM T_116
WHERE P.End_Dt=DATE('2100-12-31')
AND P.SUBCONTRACT_ID=T_116.SUBCONTRACT_ID
;

--Step4:
INSERT  INTO dw_sdata.CCS_004_TB_CON_SUBCONTRACT SELECT * FROM T_116;

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