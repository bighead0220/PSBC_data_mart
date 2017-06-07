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
DELETE FROM dw_sdata.BBS_001_PLG_SAVE_DTL WHERE start_dt>=DATE('${TX_DATE_YYYYMMDD}');
UPDATE dw_sdata.BBS_001_PLG_SAVE_DTL SET end_dt=DATE('2100-12-31') WHERE end_dt>=DATE('${TX_DATE_YYYYMMDD}') AND end_dt<>DATE('2100-12-31');

--Step1:
CREATE LOCAL TEMPORARY TABLE  T_53 ON COMMIT PRESERVE ROWS AS SELECT * FROM dw_sdata.BBS_001_PLG_SAVE_DTL WHERE 1=0;

--Step2:
INSERT  INTO T_53 (
  ID,
  CONTRACT_ID,
  PLG_DRAFT_ID,
  STATUS,
  CREATE_OPR_ID,
  CREATE_TIME,
  LAST_UPD_OPR_ID,
  LAST_UPD_TIME,
  CREDIT_LINE_STATUS,
  CREDIT_LINE_ID,
  IN_OUT_FLAG,
  CREDIT_LINE,
  DRAFT_ID,
  COLLZTN_SWT_BIZ_ID,
  COLLZTN_TYPE,
  COLLZTN_ECDS_PRC_MSG,
  COLLZTN_CM_ERR_PROCD,
  COLLZTN_ENDST_DATE,
  COLLZTN_SIG_MK,
  COLLZTN_STATUS,
  COLLZTN_CM_STATUS,
  COLLZTN_CANCEL_DATE,
  start_dt,
  end_dt)
SELECT
  N.ID,
  N.CONTRACT_ID,
  N.PLG_DRAFT_ID,
  N.STATUS,
  N.CREATE_OPR_ID,
  N.CREATE_TIME,
  N.LAST_UPD_OPR_ID,
  N.LAST_UPD_TIME,
  N.CREDIT_LINE_STATUS,
  N.CREDIT_LINE_ID,
  N.IN_OUT_FLAG,
  N.CREDIT_LINE,
  N.DRAFT_ID,
  N.COLLZTN_SWT_BIZ_ID,
  N.COLLZTN_TYPE,
  N.COLLZTN_ECDS_PRC_MSG,
  N.COLLZTN_CM_ERR_PROCD,
  N.COLLZTN_ENDST_DATE,
  N.COLLZTN_SIG_MK,
  N.COLLZTN_STATUS,
  N.COLLZTN_CM_STATUS,
  N.COLLZTN_CANCEL_DATE,
  DATE('${TX_DATE_YYYYMMDD}'),
  DATE('2100-12-31')
FROM 
 (SELECT
  COALESCE(ID, 0 ) AS ID ,
  COALESCE(CONTRACT_ID, 0 ) AS CONTRACT_ID ,
  COALESCE(PLG_DRAFT_ID, 0 ) AS PLG_DRAFT_ID ,
  COALESCE(STATUS, '' ) AS STATUS ,
  COALESCE(CREATE_OPR_ID, 0 ) AS CREATE_OPR_ID ,
  COALESCE(CREATE_TIME, '' ) AS CREATE_TIME ,
  COALESCE(LAST_UPD_OPR_ID, 0 ) AS LAST_UPD_OPR_ID ,
  COALESCE(LAST_UPD_TIME, '' ) AS LAST_UPD_TIME ,
  COALESCE(CREDIT_LINE_STATUS, '' ) AS CREDIT_LINE_STATUS ,
  COALESCE(CREDIT_LINE_ID, 0 ) AS CREDIT_LINE_ID ,
  COALESCE(IN_OUT_FLAG, '' ) AS IN_OUT_FLAG ,
  COALESCE(CREDIT_LINE, 0 ) AS CREDIT_LINE ,
  COALESCE(DRAFT_ID, 0 ) AS DRAFT_ID ,
  COALESCE(COLLZTN_SWT_BIZ_ID, 0 ) AS COLLZTN_SWT_BIZ_ID ,
  COALESCE(COLLZTN_TYPE, '' ) AS COLLZTN_TYPE ,
  COALESCE(COLLZTN_ECDS_PRC_MSG, '' ) AS COLLZTN_ECDS_PRC_MSG ,
  COALESCE(COLLZTN_CM_ERR_PROCD, '' ) AS COLLZTN_CM_ERR_PROCD ,
  COALESCE(COLLZTN_ENDST_DATE, '' ) AS COLLZTN_ENDST_DATE ,
  COALESCE(COLLZTN_SIG_MK, '' ) AS COLLZTN_SIG_MK ,
  COALESCE(COLLZTN_STATUS, '' ) AS COLLZTN_STATUS ,
  COALESCE(COLLZTN_CM_STATUS, '' ) AS COLLZTN_CM_STATUS ,
  COALESCE(COLLZTN_CANCEL_DATE, '' ) AS COLLZTN_CANCEL_DATE 
 FROM  dw_tdata.BBS_001_PLG_SAVE_DTL_${TX_DATE_YYYYMMDD}) N
LEFT JOIN
 (SELECT 
  ID ,
  CONTRACT_ID ,
  PLG_DRAFT_ID ,
  STATUS ,
  CREATE_OPR_ID ,
  CREATE_TIME ,
  LAST_UPD_OPR_ID ,
  LAST_UPD_TIME ,
  CREDIT_LINE_STATUS ,
  CREDIT_LINE_ID ,
  IN_OUT_FLAG ,
  CREDIT_LINE ,
  DRAFT_ID ,
  COLLZTN_SWT_BIZ_ID ,
  COLLZTN_TYPE ,
  COLLZTN_ECDS_PRC_MSG ,
  COLLZTN_CM_ERR_PROCD ,
  COLLZTN_ENDST_DATE ,
  COLLZTN_SIG_MK ,
  COLLZTN_STATUS ,
  COLLZTN_CM_STATUS ,
  COLLZTN_CANCEL_DATE 
 FROM dw_sdata.BBS_001_PLG_SAVE_DTL 
 WHERE END_DT = DATE('2100-12-31') ) T
ON N.ID = T.ID
WHERE
(T.ID IS NULL)
 OR N.CONTRACT_ID<>T.CONTRACT_ID
 OR N.PLG_DRAFT_ID<>T.PLG_DRAFT_ID
 OR N.STATUS<>T.STATUS
 OR N.CREATE_OPR_ID<>T.CREATE_OPR_ID
 OR N.CREATE_TIME<>T.CREATE_TIME
 OR N.LAST_UPD_OPR_ID<>T.LAST_UPD_OPR_ID
 OR N.LAST_UPD_TIME<>T.LAST_UPD_TIME
 OR N.CREDIT_LINE_STATUS<>T.CREDIT_LINE_STATUS
 OR N.CREDIT_LINE_ID<>T.CREDIT_LINE_ID
 OR N.IN_OUT_FLAG<>T.IN_OUT_FLAG
 OR N.CREDIT_LINE<>T.CREDIT_LINE
 OR N.DRAFT_ID<>T.DRAFT_ID
 OR N.COLLZTN_SWT_BIZ_ID<>T.COLLZTN_SWT_BIZ_ID
 OR N.COLLZTN_TYPE<>T.COLLZTN_TYPE
 OR N.COLLZTN_ECDS_PRC_MSG<>T.COLLZTN_ECDS_PRC_MSG
 OR N.COLLZTN_CM_ERR_PROCD<>T.COLLZTN_CM_ERR_PROCD
 OR N.COLLZTN_ENDST_DATE<>T.COLLZTN_ENDST_DATE
 OR N.COLLZTN_SIG_MK<>T.COLLZTN_SIG_MK
 OR N.COLLZTN_STATUS<>T.COLLZTN_STATUS
 OR N.COLLZTN_CM_STATUS<>T.COLLZTN_CM_STATUS
 OR N.COLLZTN_CANCEL_DATE<>T.COLLZTN_CANCEL_DATE
;

--Step3:
UPDATE dw_sdata.BBS_001_PLG_SAVE_DTL P 
SET End_Dt=DATE('${TX_DATE_YYYYMMDD}')
FROM T_53
WHERE P.End_Dt=DATE('2100-12-31')
AND P.ID=T_53.ID
;

--Step4:
INSERT  INTO dw_sdata.BBS_001_PLG_SAVE_DTL SELECT * FROM T_53;

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
