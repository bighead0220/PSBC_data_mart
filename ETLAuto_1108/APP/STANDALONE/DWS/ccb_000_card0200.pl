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
DELETE FROM dw_sdata.CCB_000_CARD WHERE start_dt>=DATE('${TX_DATE_YYYYMMDD}');
UPDATE dw_sdata.CCB_000_CARD SET end_dt=DATE('2100-12-31') WHERE end_dt>=DATE('${TX_DATE_YYYYMMDD}') AND end_dt<>DATE('2100-12-31');

--Step1:
CREATE LOCAL TEMPORARY TABLE  T_90 ON COMMIT PRESERVE ROWS AS SELECT * FROM dw_sdata.CCB_000_CARD WHERE 1=0;

--Step2:
INSERT  INTO T_90 (
  XACCOUNT,
  BANK,
  CARD_ID,
  CARD_NBR,
  CARDHOLDER,
  EXPIRY_DTE,
  ISSUE_NBR,
  ISSUE_STS,
  MASTER_NBR,
  ACTIONCODE,
  ADDR_TYPE,
  APP_BATCH,
  AREA_CODE,
  AUTH_OFLAG,
  AUTH_ORIDE,
  AUTH_PDAY,
  AUTH_PTIME,
  AUTHS_AMT,
  AUTHS_AMX,
  BALINQ_YN,
  BASEI_DAY,
  BASEI_SRCE,
  BASEI_TIME,
  CANCL_BRCH,
  CANCL_CODE,
  CANCL_DAY,
  CANCL_EMPL,
  CANCL_NEW,
  CANCL_REAS,
  CANCL_TIME,
  CARD_BIN,
  CASH_DAYX,
  CASHDXFG,
  CASH_LDAY,
  CASHAD_NOX,
  CASHADV_NO,
  CASHBCK_YN,
  CDFRM,
  CDINDEX,
  CHECK_DIG,
  CHQ_BNKCDE,
  CLASS_CD,
  CLIMIT,
  CLMTFLAG,
  COURIERFEE,
  CRB_REGION,
  CREATE_DAY,
  CRED_LMT,
  CUSTR_NBR,
  CVC2,
  CVC2_NEW,
  CVC2_PREV,
  CVV,
  CVV_NEW,
  CVV_PREV,
  DEF_BNKCDE,
  DEF_DSPCH,
  DEF_LOCN,
  DEP_NOX,
  DEPAM_TDX,
  DPTDXFLAG,
  DEPAM_TDY,
  DPTDYFLAG,
  DEPNO_TDX,
  DEPNO_TDY,
  DEPOSIT_NO,
  DEPOSIT_YN,
  DESPATCH,
  DSPCH_LOCN,
  EC_YN,
  ELIG_LOYAL,
  EMBOSS_CRD,
  EMBOSS_LN2,
  EMBOSS_NME,
  EMBOSS_SUL,
  EMBOSS_SUR,
  EXPIRY_NEW,
  EXPIRY_PRV,
  FEE_CODE,
  FEE_MONTH,
  FST_CASAMT,
  FST_PURAMT,
  HOLD_ORIG,
  HOLD_REAS,
  HRCAMT_TDX,
  HRCTXFLAG,
  HRCAMT_TDY,
  HRCTYFLAG,
  HRCASH_NO,
  HRCASH_NOX,
  HRCNO_TDX,
  HRCNO_TDY,
  ISS_SERIAL,
  ISSUE_DAY,
  ISSUE_REAS,
  LASTAUTHDY,
  LASTPIN_DY,
  LASTREV_DY,
  LIMIT_X,
  LOSS_AMPM,
  LOSS_DAY,
  LOSS_LOCN,
  LOSS_REPRT,
  LOSS_TIME,
  MAILER_1ST,
  MAX_AINAMT,
  MAX_AUOAMT,
  MAX_CAMT,
  MAX_CAMTX,
  MAX_CHATM,
  MAX_CHATMX,
  MAX_CHTLR,
  MAX_CHTLRX,
  MAX_DAMT,
  MAX_DAMTX,
  MAX_HRCAMT,
  MAX_HRCAMX,
  MAX_NOTLR,
  MAX_NOTLRX,
  MAX_PAMT,
  MAX_PAMTX,
  MAX_PINTRY,
  MAX_POAMT,
  MAX_POAMX,
  MCC102,
  MCC103,
  MCGALLOWED,
  MCGRESTRI,
  MEMBER,
  OTH_BNKCDE,
  PIN_CHK,
  PIN_DATE,
  PIN_FAILDL,
  PIN_FAILS,
  PIN_REQD,
  PIN_RESET,
  PIN_TIME,
  PREV_CANC,
  PREV_DAY,
  PREV_TIME,
  PRODUCT,
  PURCH_YN,
  PURCHS_NOX,
  PURCHSE_NO,
  PURGE_DATE,
  REISS_DTE,
  REISS_FLG,
  REPLACEFEE,
  REVTDY_NO,
  RUSHFEE,
  RUSHFLAG,
  RVSLS_NO,
  SAV_BNKCDE,
  SCHD_DSPCH,
  SCHD_LOCN,
  STIPYN,
  STM_BALNCE,
  STMBFLAG,
  STM_BALNCX,
  STMBXFLAG,
  STM_CODE,
  STM_FLAG,
  TOTAL_AMT,
  TTLFLAG,
  TOTAL_AMX,
  TTLXFLAG,
  TRACK2_N,
  URG_CARD,
  URGENTFEE,
  VALID_FROM,
  VALID_NEW,
  VIP_CNT,
  VIP_LIM,
  WITHDRW_YN,
  XFRFROM_YN,
  PINSET_DAY,
  PINSET_NO,
  APP_SOURCE,
  LMT_RSN,
  POINT_IMER,
  PTIFLAG,
  POINT_OMER,
  PTOFLAG,
  ACTIVE_DAY,
  PIN_OFFFL,
  UP_CARD,
  PBOC_YN,
  VCRLMT,
  VFCRLMTSET,
  FCRLMT,
  CUSTR_REF,
  PRMAG_CODE,
  FEE_GROUP,
  CARD_TO,
  ACTIVE_FST,
  ETL_DAY,
  ISS_MOD,
  CPNO,
  NBRMTH,
  MIN_MPAMT,
  MAX_MPAMT,
  start_dt,
  end_dt)
SELECT
  N.XACCOUNT,
  N.BANK,
  N.CARD_ID,
  N.CARD_NBR,
  N.CARDHOLDER,
  N.EXPIRY_DTE,
  N.ISSUE_NBR,
  N.ISSUE_STS,
  N.MASTER_NBR,
  N.ACTIONCODE,
  N.ADDR_TYPE,
  N.APP_BATCH,
  N.AREA_CODE,
  N.AUTH_OFLAG,
  N.AUTH_ORIDE,
  N.AUTH_PDAY,
  N.AUTH_PTIME,
  N.AUTHS_AMT,
  N.AUTHS_AMX,
  N.BALINQ_YN,
  N.BASEI_DAY,
  N.BASEI_SRCE,
  N.BASEI_TIME,
  N.CANCL_BRCH,
  N.CANCL_CODE,
  N.CANCL_DAY,
  N.CANCL_EMPL,
  N.CANCL_NEW,
  N.CANCL_REAS,
  N.CANCL_TIME,
  N.CARD_BIN,
  N.CASH_DAYX,
  N.CASHDXFG,
  N.CASH_LDAY,
  N.CASHAD_NOX,
  N.CASHADV_NO,
  N.CASHBCK_YN,
  N.CDFRM,
  N.CDINDEX,
  N.CHECK_DIG,
  N.CHQ_BNKCDE,
  N.CLASS_CD,
  N.CLIMIT,
  N.CLMTFLAG,
  N.COURIERFEE,
  N.CRB_REGION,
  N.CREATE_DAY,
  N.CRED_LMT,
  N.CUSTR_NBR,
  N.CVC2,
  N.CVC2_NEW,
  N.CVC2_PREV,
  N.CVV,
  N.CVV_NEW,
  N.CVV_PREV,
  N.DEF_BNKCDE,
  N.DEF_DSPCH,
  N.DEF_LOCN,
  N.DEP_NOX,
  N.DEPAM_TDX,
  N.DPTDXFLAG,
  N.DEPAM_TDY,
  N.DPTDYFLAG,
  N.DEPNO_TDX,
  N.DEPNO_TDY,
  N.DEPOSIT_NO,
  N.DEPOSIT_YN,
  N.DESPATCH,
  N.DSPCH_LOCN,
  N.EC_YN,
  N.ELIG_LOYAL,
  N.EMBOSS_CRD,
  N.EMBOSS_LN2,
  N.EMBOSS_NME,
  N.EMBOSS_SUL,
  N.EMBOSS_SUR,
  N.EXPIRY_NEW,
  N.EXPIRY_PRV,
  N.FEE_CODE,
  N.FEE_MONTH,
  N.FST_CASAMT,
  N.FST_PURAMT,
  N.HOLD_ORIG,
  N.HOLD_REAS,
  N.HRCAMT_TDX,
  N.HRCTXFLAG,
  N.HRCAMT_TDY,
  N.HRCTYFLAG,
  N.HRCASH_NO,
  N.HRCASH_NOX,
  N.HRCNO_TDX,
  N.HRCNO_TDY,
  N.ISS_SERIAL,
  N.ISSUE_DAY,
  N.ISSUE_REAS,
  N.LASTAUTHDY,
  N.LASTPIN_DY,
  N.LASTREV_DY,
  N.LIMIT_X,
  N.LOSS_AMPM,
  N.LOSS_DAY,
  N.LOSS_LOCN,
  N.LOSS_REPRT,
  N.LOSS_TIME,
  N.MAILER_1ST,
  N.MAX_AINAMT,
  N.MAX_AUOAMT,
  N.MAX_CAMT,
  N.MAX_CAMTX,
  N.MAX_CHATM,
  N.MAX_CHATMX,
  N.MAX_CHTLR,
  N.MAX_CHTLRX,
  N.MAX_DAMT,
  N.MAX_DAMTX,
  N.MAX_HRCAMT,
  N.MAX_HRCAMX,
  N.MAX_NOTLR,
  N.MAX_NOTLRX,
  N.MAX_PAMT,
  N.MAX_PAMTX,
  N.MAX_PINTRY,
  N.MAX_POAMT,
  N.MAX_POAMX,
  N.MCC102,
  N.MCC103,
  N.MCGALLOWED,
  N.MCGRESTRI,
  N.MEMBER,
  N.OTH_BNKCDE,
  N.PIN_CHK,
  N.PIN_DATE,
  N.PIN_FAILDL,
  N.PIN_FAILS,
  N.PIN_REQD,
  N.PIN_RESET,
  N.PIN_TIME,
  N.PREV_CANC,
  N.PREV_DAY,
  N.PREV_TIME,
  N.PRODUCT,
  N.PURCH_YN,
  N.PURCHS_NOX,
  N.PURCHSE_NO,
  N.PURGE_DATE,
  N.REISS_DTE,
  N.REISS_FLG,
  N.REPLACEFEE,
  N.REVTDY_NO,
  N.RUSHFEE,
  N.RUSHFLAG,
  N.RVSLS_NO,
  N.SAV_BNKCDE,
  N.SCHD_DSPCH,
  N.SCHD_LOCN,
  N.STIPYN,
  N.STM_BALNCE,
  N.STMBFLAG,
  N.STM_BALNCX,
  N.STMBXFLAG,
  N.STM_CODE,
  N.STM_FLAG,
  N.TOTAL_AMT,
  N.TTLFLAG,
  N.TOTAL_AMX,
  N.TTLXFLAG,
  N.TRACK2_N,
  N.URG_CARD,
  N.URGENTFEE,
  N.VALID_FROM,
  N.VALID_NEW,
  N.VIP_CNT,
  N.VIP_LIM,
  N.WITHDRW_YN,
  N.XFRFROM_YN,
  N.PINSET_DAY,
  N.PINSET_NO,
  N.APP_SOURCE,
  N.LMT_RSN,
  N.POINT_IMER,
  N.PTIFLAG,
  N.POINT_OMER,
  N.PTOFLAG,
  N.ACTIVE_DAY,
  N.PIN_OFFFL,
  N.UP_CARD,
  N.PBOC_YN,
  N.VCRLMT,
  N.VFCRLMTSET,
  N.FCRLMT,
  N.CUSTR_REF,
  N.PRMAG_CODE,
  N.FEE_GROUP,
  N.CARD_TO,
  N.ACTIVE_FST,
  N.ETL_DAY,
  N.ISS_MOD,
  N.CPNO,
  N.NBRMTH,
  N.MIN_MPAMT,
  N.MAX_MPAMT,
  DATE('${TX_DATE_YYYYMMDD}'),
  DATE('2100-12-31')
FROM 
 (SELECT
  COALESCE(XACCOUNT, 0 ) AS XACCOUNT ,
  COALESCE(BANK, 0 ) AS BANK ,
  COALESCE(CARD_ID, '' ) AS CARD_ID ,
  COALESCE(CARD_NBR, '' ) AS CARD_NBR ,
  COALESCE(CARDHOLDER, 0 ) AS CARDHOLDER ,
  COALESCE(EXPIRY_DTE, 0 ) AS EXPIRY_DTE ,
  COALESCE(ISSUE_NBR, 0 ) AS ISSUE_NBR ,
  COALESCE(ISSUE_STS, 0 ) AS ISSUE_STS ,
  COALESCE(MASTER_NBR, '' ) AS MASTER_NBR ,
  COALESCE(ACTIONCODE, '' ) AS ACTIONCODE ,
  COALESCE(ADDR_TYPE, '' ) AS ADDR_TYPE ,
  COALESCE(APP_BATCH, '' ) AS APP_BATCH ,
  COALESCE(AREA_CODE, 0 ) AS AREA_CODE ,
  COALESCE(AUTH_OFLAG, '' ) AS AUTH_OFLAG ,
  COALESCE(AUTH_ORIDE, 0 ) AS AUTH_ORIDE ,
  COALESCE(AUTH_PDAY, 0 ) AS AUTH_PDAY ,
  COALESCE(AUTH_PTIME, 0 ) AS AUTH_PTIME ,
  COALESCE(AUTHS_AMT, 0 ) AS AUTHS_AMT ,
  COALESCE(AUTHS_AMX, 0 ) AS AUTHS_AMX ,
  COALESCE(BALINQ_YN, '' ) AS BALINQ_YN ,
  COALESCE(BASEI_DAY, 0 ) AS BASEI_DAY ,
  COALESCE(BASEI_SRCE, '' ) AS BASEI_SRCE ,
  COALESCE(BASEI_TIME, 0 ) AS BASEI_TIME ,
  COALESCE(CANCL_BRCH, 0 ) AS CANCL_BRCH ,
  COALESCE(CANCL_CODE, '' ) AS CANCL_CODE ,
  COALESCE(CANCL_DAY, 0 ) AS CANCL_DAY ,
  COALESCE(CANCL_EMPL, 0 ) AS CANCL_EMPL ,
  COALESCE(CANCL_NEW, '' ) AS CANCL_NEW ,
  COALESCE(CANCL_REAS, '' ) AS CANCL_REAS ,
  COALESCE(CANCL_TIME, 0 ) AS CANCL_TIME ,
  COALESCE(CARD_BIN, 0 ) AS CARD_BIN ,
  COALESCE(CASH_DAYX, 0 ) AS CASH_DAYX ,
  COALESCE(CASHDXFG, '' ) AS CASHDXFG ,
  COALESCE(CASH_LDAY, 0 ) AS CASH_LDAY ,
  COALESCE(CASHAD_NOX, 0 ) AS CASHAD_NOX ,
  COALESCE(CASHADV_NO, 0 ) AS CASHADV_NO ,
  COALESCE(CASHBCK_YN, '' ) AS CASHBCK_YN ,
  COALESCE(CDFRM, '' ) AS CDFRM ,
  COALESCE(CDINDEX, 0 ) AS CDINDEX ,
  COALESCE(CHECK_DIG, 0 ) AS CHECK_DIG ,
  COALESCE(CHQ_BNKCDE, '' ) AS CHQ_BNKCDE ,
  COALESCE(CLASS_CD, 0 ) AS CLASS_CD ,
  COALESCE(CLIMIT, 0 ) AS CLIMIT ,
  COALESCE(CLMTFLAG, '' ) AS CLMTFLAG ,
  COALESCE(COURIERFEE, 0 ) AS COURIERFEE ,
  COALESCE(CRB_REGION, '' ) AS CRB_REGION ,
  COALESCE(CREATE_DAY, 0 ) AS CREATE_DAY ,
  COALESCE(CRED_LMT, 0 ) AS CRED_LMT ,
  COALESCE(CUSTR_NBR, '' ) AS CUSTR_NBR ,
  COALESCE(CVC2, '' ) AS CVC2 ,
  COALESCE(CVC2_NEW, '' ) AS CVC2_NEW ,
  COALESCE(CVC2_PREV, '' ) AS CVC2_PREV ,
  COALESCE(CVV, '' ) AS CVV ,
  COALESCE(CVV_NEW, '' ) AS CVV_NEW ,
  COALESCE(CVV_PREV, '' ) AS CVV_PREV ,
  COALESCE(DEF_BNKCDE, '' ) AS DEF_BNKCDE ,
  COALESCE(DEF_DSPCH, '' ) AS DEF_DSPCH ,
  COALESCE(DEF_LOCN, 0 ) AS DEF_LOCN ,
  COALESCE(DEP_NOX, 0 ) AS DEP_NOX ,
  COALESCE(DEPAM_TDX, 0 ) AS DEPAM_TDX ,
  COALESCE(DPTDXFLAG, '' ) AS DPTDXFLAG ,
  COALESCE(DEPAM_TDY, 0 ) AS DEPAM_TDY ,
  COALESCE(DPTDYFLAG, '' ) AS DPTDYFLAG ,
  COALESCE(DEPNO_TDX, 0 ) AS DEPNO_TDX ,
  COALESCE(DEPNO_TDY, 0 ) AS DEPNO_TDY ,
  COALESCE(DEPOSIT_NO, 0 ) AS DEPOSIT_NO ,
  COALESCE(DEPOSIT_YN, '' ) AS DEPOSIT_YN ,
  COALESCE(DESPATCH, '' ) AS DESPATCH ,
  COALESCE(DSPCH_LOCN, 0 ) AS DSPCH_LOCN ,
  COALESCE(EC_YN, 0 ) AS EC_YN ,
  COALESCE(ELIG_LOYAL, '' ) AS ELIG_LOYAL ,
  COALESCE(EMBOSS_CRD, '' ) AS EMBOSS_CRD ,
  COALESCE(EMBOSS_LN2, '' ) AS EMBOSS_LN2 ,
  COALESCE(EMBOSS_NME, '' ) AS EMBOSS_NME ,
  COALESCE(EMBOSS_SUL, 0 ) AS EMBOSS_SUL ,
  COALESCE(EMBOSS_SUR, 0 ) AS EMBOSS_SUR ,
  COALESCE(EXPIRY_NEW, 0 ) AS EXPIRY_NEW ,
  COALESCE(EXPIRY_PRV, 0 ) AS EXPIRY_PRV ,
  COALESCE(FEE_CODE, '' ) AS FEE_CODE ,
  COALESCE(FEE_MONTH, 0 ) AS FEE_MONTH ,
  COALESCE(FST_CASAMT, 0 ) AS FST_CASAMT ,
  COALESCE(FST_PURAMT, 0 ) AS FST_PURAMT ,
  COALESCE(HOLD_ORIG, '' ) AS HOLD_ORIG ,
  COALESCE(HOLD_REAS, '' ) AS HOLD_REAS ,
  COALESCE(HRCAMT_TDX, 0 ) AS HRCAMT_TDX ,
  COALESCE(HRCTXFLAG, '' ) AS HRCTXFLAG ,
  COALESCE(HRCAMT_TDY, 0 ) AS HRCAMT_TDY ,
  COALESCE(HRCTYFLAG, '' ) AS HRCTYFLAG ,
  COALESCE(HRCASH_NO, 0 ) AS HRCASH_NO ,
  COALESCE(HRCASH_NOX, 0 ) AS HRCASH_NOX ,
  COALESCE(HRCNO_TDX, 0 ) AS HRCNO_TDX ,
  COALESCE(HRCNO_TDY, 0 ) AS HRCNO_TDY ,
  COALESCE(ISS_SERIAL, 0 ) AS ISS_SERIAL ,
  COALESCE(ISSUE_DAY, 0 ) AS ISSUE_DAY ,
  COALESCE(ISSUE_REAS, '' ) AS ISSUE_REAS ,
  COALESCE(LASTAUTHDY, 0 ) AS LASTAUTHDY ,
  COALESCE(LASTPIN_DY, 0 ) AS LASTPIN_DY ,
  COALESCE(LASTREV_DY, 0 ) AS LASTREV_DY ,
  COALESCE(LIMIT_X, 0 ) AS LIMIT_X ,
  COALESCE(LOSS_AMPM, '' ) AS LOSS_AMPM ,
  COALESCE(LOSS_DAY, 0 ) AS LOSS_DAY ,
  COALESCE(LOSS_LOCN, 0 ) AS LOSS_LOCN ,
  COALESCE(LOSS_REPRT, '' ) AS LOSS_REPRT ,
  COALESCE(LOSS_TIME, 0 ) AS LOSS_TIME ,
  COALESCE(MAILER_1ST, 0 ) AS MAILER_1ST ,
  COALESCE(MAX_AINAMT, 0 ) AS MAX_AINAMT ,
  COALESCE(MAX_AUOAMT, 0 ) AS MAX_AUOAMT ,
  COALESCE(MAX_CAMT, 0 ) AS MAX_CAMT ,
  COALESCE(MAX_CAMTX, 0 ) AS MAX_CAMTX ,
  COALESCE(MAX_CHATM, 0 ) AS MAX_CHATM ,
  COALESCE(MAX_CHATMX, 0 ) AS MAX_CHATMX ,
  COALESCE(MAX_CHTLR, 0 ) AS MAX_CHTLR ,
  COALESCE(MAX_CHTLRX, 0 ) AS MAX_CHTLRX ,
  COALESCE(MAX_DAMT, 0 ) AS MAX_DAMT ,
  COALESCE(MAX_DAMTX, 0 ) AS MAX_DAMTX ,
  COALESCE(MAX_HRCAMT, 0 ) AS MAX_HRCAMT ,
  COALESCE(MAX_HRCAMX, 0 ) AS MAX_HRCAMX ,
  COALESCE(MAX_NOTLR, 0 ) AS MAX_NOTLR ,
  COALESCE(MAX_NOTLRX, 0 ) AS MAX_NOTLRX ,
  COALESCE(MAX_PAMT, 0 ) AS MAX_PAMT ,
  COALESCE(MAX_PAMTX, 0 ) AS MAX_PAMTX ,
  COALESCE(MAX_PINTRY, 0 ) AS MAX_PINTRY ,
  COALESCE(MAX_POAMT, 0 ) AS MAX_POAMT ,
  COALESCE(MAX_POAMX, 0 ) AS MAX_POAMX ,
  COALESCE(MCC102, '' ) AS MCC102 ,
  COALESCE(MCC103, '' ) AS MCC103 ,
  COALESCE(MCGALLOWED, '' ) AS MCGALLOWED ,
  COALESCE(MCGRESTRI, '' ) AS MCGRESTRI ,
  COALESCE(MEMBER, 0 ) AS MEMBER ,
  COALESCE(OTH_BNKCDE, '' ) AS OTH_BNKCDE ,
  COALESCE(PIN_CHK, '' ) AS PIN_CHK ,
  COALESCE(PIN_DATE, '' ) AS PIN_DATE ,
  COALESCE(PIN_FAILDL, 0 ) AS PIN_FAILDL ,
  COALESCE(PIN_FAILS, 0 ) AS PIN_FAILS ,
  COALESCE(PIN_REQD, '' ) AS PIN_REQD ,
  COALESCE(PIN_RESET, '' ) AS PIN_RESET ,
  COALESCE(PIN_TIME, 0 ) AS PIN_TIME ,
  COALESCE(PREV_CANC, '' ) AS PREV_CANC ,
  COALESCE(PREV_DAY, 0 ) AS PREV_DAY ,
  COALESCE(PREV_TIME, 0 ) AS PREV_TIME ,
  COALESCE(PRODUCT, 0 ) AS PRODUCT ,
  COALESCE(PURCH_YN, '' ) AS PURCH_YN ,
  COALESCE(PURCHS_NOX, 0 ) AS PURCHS_NOX ,
  COALESCE(PURCHSE_NO, 0 ) AS PURCHSE_NO ,
  COALESCE(PURGE_DATE, 0 ) AS PURGE_DATE ,
  COALESCE(REISS_DTE, '' ) AS REISS_DTE ,
  COALESCE(REISS_FLG, '' ) AS REISS_FLG ,
  COALESCE(REPLACEFEE, 0 ) AS REPLACEFEE ,
  COALESCE(REVTDY_NO, 0 ) AS REVTDY_NO ,
  COALESCE(RUSHFEE, '' ) AS RUSHFEE ,
  COALESCE(RUSHFLAG, '' ) AS RUSHFLAG ,
  COALESCE(RVSLS_NO, 0 ) AS RVSLS_NO ,
  COALESCE(SAV_BNKCDE, '' ) AS SAV_BNKCDE ,
  COALESCE(SCHD_DSPCH, '' ) AS SCHD_DSPCH ,
  COALESCE(SCHD_LOCN, 0 ) AS SCHD_LOCN ,
  COALESCE(STIPYN, '' ) AS STIPYN ,
  COALESCE(STM_BALNCE, 0 ) AS STM_BALNCE ,
  COALESCE(STMBFLAG, '' ) AS STMBFLAG ,
  COALESCE(STM_BALNCX, 0 ) AS STM_BALNCX ,
  COALESCE(STMBXFLAG, '' ) AS STMBXFLAG ,
  COALESCE(STM_CODE, '' ) AS STM_CODE ,
  COALESCE(STM_FLAG, '' ) AS STM_FLAG ,
  COALESCE(TOTAL_AMT, 0 ) AS TOTAL_AMT ,
  COALESCE(TTLFLAG, '' ) AS TTLFLAG ,
  COALESCE(TOTAL_AMX, 0 ) AS TOTAL_AMX ,
  COALESCE(TTLXFLAG, '' ) AS TTLXFLAG ,
  COALESCE(TRACK2_N, 0 ) AS TRACK2_N ,
  COALESCE(URG_CARD, '' ) AS URG_CARD ,
  COALESCE(URGENTFEE, '' ) AS URGENTFEE ,
  COALESCE(VALID_FROM, 0 ) AS VALID_FROM ,
  COALESCE(VALID_NEW, 0 ) AS VALID_NEW ,
  COALESCE(VIP_CNT, 0 ) AS VIP_CNT ,
  COALESCE(VIP_LIM, 0 ) AS VIP_LIM ,
  COALESCE(WITHDRW_YN, '' ) AS WITHDRW_YN ,
  COALESCE(XFRFROM_YN, '' ) AS XFRFROM_YN ,
  COALESCE(PINSET_DAY, 0 ) AS PINSET_DAY ,
  COALESCE(PINSET_NO, 0 ) AS PINSET_NO ,
  COALESCE(APP_SOURCE, '' ) AS APP_SOURCE ,
  COALESCE(LMT_RSN, '' ) AS LMT_RSN ,
  COALESCE(POINT_IMER, 0 ) AS POINT_IMER ,
  COALESCE(PTIFLAG, '' ) AS PTIFLAG ,
  COALESCE(POINT_OMER, 0 ) AS POINT_OMER ,
  COALESCE(PTOFLAG, '' ) AS PTOFLAG ,
  COALESCE(ACTIVE_DAY, 0 ) AS ACTIVE_DAY ,
  COALESCE(PIN_OFFFL, '' ) AS PIN_OFFFL ,
  COALESCE(UP_CARD, '' ) AS UP_CARD ,
  COALESCE(PBOC_YN, 0 ) AS PBOC_YN ,
  COALESCE(VCRLMT, 0 ) AS VCRLMT ,
  COALESCE(VFCRLMTSET, 0 ) AS VFCRLMTSET ,
  COALESCE(FCRLMT, 0 ) AS FCRLMT ,
  COALESCE(CUSTR_REF, '' ) AS CUSTR_REF ,
  COALESCE(PRMAG_CODE, '' ) AS PRMAG_CODE ,
  COALESCE(FEE_GROUP, 0 ) AS FEE_GROUP ,
  COALESCE(CARD_TO, '' ) AS CARD_TO ,
  COALESCE(ACTIVE_FST, 0 ) AS ACTIVE_FST ,
  COALESCE(ETL_DAY, 0 ) AS ETL_DAY,
  COALESCE(ISS_MOD,'') AS ISS_MOD,
  COALESCE(CPNO,0) AS CPNO,
  COALESCE(NBRMTH,0) AS NBRMTH,
  COALESCE(MIN_MPAMT,0) AS MIN_MPAMT,
  COALESCE(MAX_MPAMT,0) AS MAX_MPAMT 
 FROM  dw_tdata.CCB_000_CARD_${TX_DATE_YYYYMMDD}) N
LEFT JOIN
 (SELECT 
  XACCOUNT ,
  BANK ,
  CARD_ID ,
  CARD_NBR ,
  CARDHOLDER ,
  EXPIRY_DTE ,
  ISSUE_NBR ,
  ISSUE_STS ,
  MASTER_NBR ,
  ACTIONCODE ,
  ADDR_TYPE ,
  APP_BATCH ,
  AREA_CODE ,
  AUTH_OFLAG ,
  AUTH_ORIDE ,
  AUTH_PDAY ,
  AUTH_PTIME ,
  AUTHS_AMT ,
  AUTHS_AMX ,
  BALINQ_YN ,
  BASEI_DAY ,
  BASEI_SRCE ,
  BASEI_TIME ,
  CANCL_BRCH ,
  CANCL_CODE ,
  CANCL_DAY ,
  CANCL_EMPL ,
  CANCL_NEW ,
  CANCL_REAS ,
  CANCL_TIME ,
  CARD_BIN ,
  CASH_DAYX ,
  CASHDXFG ,
  CASH_LDAY ,
  CASHAD_NOX ,
  CASHADV_NO ,
  CASHBCK_YN ,
  CDFRM ,
  CDINDEX ,
  CHECK_DIG ,
  CHQ_BNKCDE ,
  CLASS_CD ,
  CLIMIT ,
  CLMTFLAG ,
  COURIERFEE ,
  CRB_REGION ,
  CREATE_DAY ,
  CRED_LMT ,
  CUSTR_NBR ,
  CVC2 ,
  CVC2_NEW ,
  CVC2_PREV ,
  CVV ,
  CVV_NEW ,
  CVV_PREV ,
  DEF_BNKCDE ,
  DEF_DSPCH ,
  DEF_LOCN ,
  DEP_NOX ,
  DEPAM_TDX ,
  DPTDXFLAG ,
  DEPAM_TDY ,
  DPTDYFLAG ,
  DEPNO_TDX ,
  DEPNO_TDY ,
  DEPOSIT_NO ,
  DEPOSIT_YN ,
  DESPATCH ,
  DSPCH_LOCN ,
  EC_YN ,
  ELIG_LOYAL ,
  EMBOSS_CRD ,
  EMBOSS_LN2 ,
  EMBOSS_NME ,
  EMBOSS_SUL ,
  EMBOSS_SUR ,
  EXPIRY_NEW ,
  EXPIRY_PRV ,
  FEE_CODE ,
  FEE_MONTH ,
  FST_CASAMT ,
  FST_PURAMT ,
  HOLD_ORIG ,
  HOLD_REAS ,
  HRCAMT_TDX ,
  HRCTXFLAG ,
  HRCAMT_TDY ,
  HRCTYFLAG ,
  HRCASH_NO ,
  HRCASH_NOX ,
  HRCNO_TDX ,
  HRCNO_TDY ,
  ISS_SERIAL ,
  ISSUE_DAY ,
  ISSUE_REAS ,
  LASTAUTHDY ,
  LASTPIN_DY ,
  LASTREV_DY ,
  LIMIT_X ,
  LOSS_AMPM ,
  LOSS_DAY ,
  LOSS_LOCN ,
  LOSS_REPRT ,
  LOSS_TIME ,
  MAILER_1ST ,
  MAX_AINAMT ,
  MAX_AUOAMT ,
  MAX_CAMT ,
  MAX_CAMTX ,
  MAX_CHATM ,
  MAX_CHATMX ,
  MAX_CHTLR ,
  MAX_CHTLRX ,
  MAX_DAMT ,
  MAX_DAMTX ,
  MAX_HRCAMT ,
  MAX_HRCAMX ,
  MAX_NOTLR ,
  MAX_NOTLRX ,
  MAX_PAMT ,
  MAX_PAMTX ,
  MAX_PINTRY ,
  MAX_POAMT ,
  MAX_POAMX ,
  MCC102 ,
  MCC103 ,
  MCGALLOWED ,
  MCGRESTRI ,
  MEMBER ,
  OTH_BNKCDE ,
  PIN_CHK ,
  PIN_DATE ,
  PIN_FAILDL ,
  PIN_FAILS ,
  PIN_REQD ,
  PIN_RESET ,
  PIN_TIME ,
  PREV_CANC ,
  PREV_DAY ,
  PREV_TIME ,
  PRODUCT ,
  PURCH_YN ,
  PURCHS_NOX ,
  PURCHSE_NO ,
  PURGE_DATE ,
  REISS_DTE ,
  REISS_FLG ,
  REPLACEFEE ,
  REVTDY_NO ,
  RUSHFEE ,
  RUSHFLAG ,
  RVSLS_NO ,
  SAV_BNKCDE ,
  SCHD_DSPCH ,
  SCHD_LOCN ,
  STIPYN ,
  STM_BALNCE ,
  STMBFLAG ,
  STM_BALNCX ,
  STMBXFLAG ,
  STM_CODE ,
  STM_FLAG ,
  TOTAL_AMT ,
  TTLFLAG ,
  TOTAL_AMX ,
  TTLXFLAG ,
  TRACK2_N ,
  URG_CARD ,
  URGENTFEE ,
  VALID_FROM ,
  VALID_NEW ,
  VIP_CNT ,
  VIP_LIM ,
  WITHDRW_YN ,
  XFRFROM_YN ,
  PINSET_DAY ,
  PINSET_NO ,
  APP_SOURCE ,
  LMT_RSN ,
  POINT_IMER ,
  PTIFLAG ,
  POINT_OMER ,
  PTOFLAG ,
  ACTIVE_DAY ,
  PIN_OFFFL ,
  UP_CARD ,
  PBOC_YN ,
  VCRLMT ,
  VFCRLMTSET ,
  FCRLMT ,
  CUSTR_REF ,
  PRMAG_CODE ,
  FEE_GROUP ,
  CARD_TO ,
  ACTIVE_FST ,
  ETL_DAY,
 ISS_MOD,
 CPNO,
 NBRMTH,
 MIN_MPAMT,
 MAX_MPAMT

 FROM dw_sdata.CCB_000_CARD 
 WHERE END_DT = DATE('2100-12-31') ) T
ON N.CARD_NBR = T.CARD_NBR
WHERE
(T.CARD_NBR IS NULL)
 OR N.XACCOUNT<>T.XACCOUNT
 OR N.BANK<>T.BANK
 OR N.CARD_ID<>T.CARD_ID
 OR N.CARDHOLDER<>T.CARDHOLDER
 OR N.EXPIRY_DTE<>T.EXPIRY_DTE
 OR N.ISSUE_NBR<>T.ISSUE_NBR
 OR N.ISSUE_STS<>T.ISSUE_STS
 OR N.MASTER_NBR<>T.MASTER_NBR
 OR N.ACTIONCODE<>T.ACTIONCODE
 OR N.ADDR_TYPE<>T.ADDR_TYPE
 OR N.APP_BATCH<>T.APP_BATCH
 OR N.AREA_CODE<>T.AREA_CODE
 OR N.AUTH_OFLAG<>T.AUTH_OFLAG
 OR N.AUTH_ORIDE<>T.AUTH_ORIDE
 OR N.AUTH_PDAY<>T.AUTH_PDAY
 OR N.AUTH_PTIME<>T.AUTH_PTIME
 OR N.AUTHS_AMT<>T.AUTHS_AMT
 OR N.AUTHS_AMX<>T.AUTHS_AMX
 OR N.BALINQ_YN<>T.BALINQ_YN
 OR N.BASEI_DAY<>T.BASEI_DAY
 OR N.BASEI_SRCE<>T.BASEI_SRCE
 OR N.BASEI_TIME<>T.BASEI_TIME
 OR N.CANCL_BRCH<>T.CANCL_BRCH
 OR N.CANCL_CODE<>T.CANCL_CODE
 OR N.CANCL_DAY<>T.CANCL_DAY
 OR N.CANCL_EMPL<>T.CANCL_EMPL
 OR N.CANCL_NEW<>T.CANCL_NEW
 OR N.CANCL_REAS<>T.CANCL_REAS
 OR N.CANCL_TIME<>T.CANCL_TIME
 OR N.CARD_BIN<>T.CARD_BIN
 OR N.CASH_DAYX<>T.CASH_DAYX
 OR N.CASHDXFG<>T.CASHDXFG
 OR N.CASH_LDAY<>T.CASH_LDAY
 OR N.CASHAD_NOX<>T.CASHAD_NOX
 OR N.CASHADV_NO<>T.CASHADV_NO
 OR N.CASHBCK_YN<>T.CASHBCK_YN
 OR N.CDFRM<>T.CDFRM
 OR N.CDINDEX<>T.CDINDEX
 OR N.CHECK_DIG<>T.CHECK_DIG
 OR N.CHQ_BNKCDE<>T.CHQ_BNKCDE
 OR N.CLASS_CD<>T.CLASS_CD
 OR N.CLIMIT<>T.CLIMIT
 OR N.CLMTFLAG<>T.CLMTFLAG
 OR N.COURIERFEE<>T.COURIERFEE
 OR N.CRB_REGION<>T.CRB_REGION
 OR N.CREATE_DAY<>T.CREATE_DAY
 OR N.CRED_LMT<>T.CRED_LMT
 OR N.CUSTR_NBR<>T.CUSTR_NBR
 OR N.CVC2<>T.CVC2
 OR N.CVC2_NEW<>T.CVC2_NEW
 OR N.CVC2_PREV<>T.CVC2_PREV
 OR N.CVV<>T.CVV
 OR N.CVV_NEW<>T.CVV_NEW
 OR N.CVV_PREV<>T.CVV_PREV
 OR N.DEF_BNKCDE<>T.DEF_BNKCDE
 OR N.DEF_DSPCH<>T.DEF_DSPCH
 OR N.DEF_LOCN<>T.DEF_LOCN
 OR N.DEP_NOX<>T.DEP_NOX
 OR N.DEPAM_TDX<>T.DEPAM_TDX
 OR N.DPTDXFLAG<>T.DPTDXFLAG
 OR N.DEPAM_TDY<>T.DEPAM_TDY
 OR N.DPTDYFLAG<>T.DPTDYFLAG
 OR N.DEPNO_TDX<>T.DEPNO_TDX
 OR N.DEPNO_TDY<>T.DEPNO_TDY
 OR N.DEPOSIT_NO<>T.DEPOSIT_NO
 OR N.DEPOSIT_YN<>T.DEPOSIT_YN
 OR N.DESPATCH<>T.DESPATCH
 OR N.DSPCH_LOCN<>T.DSPCH_LOCN
 OR N.EC_YN<>T.EC_YN
 OR N.ELIG_LOYAL<>T.ELIG_LOYAL
 OR N.EMBOSS_CRD<>T.EMBOSS_CRD
 OR N.EMBOSS_LN2<>T.EMBOSS_LN2
 OR N.EMBOSS_NME<>T.EMBOSS_NME
 OR N.EMBOSS_SUL<>T.EMBOSS_SUL
 OR N.EMBOSS_SUR<>T.EMBOSS_SUR
 OR N.EXPIRY_NEW<>T.EXPIRY_NEW
 OR N.EXPIRY_PRV<>T.EXPIRY_PRV
 OR N.FEE_CODE<>T.FEE_CODE
 OR N.FEE_MONTH<>T.FEE_MONTH
 OR N.FST_CASAMT<>T.FST_CASAMT
 OR N.FST_PURAMT<>T.FST_PURAMT
 OR N.HOLD_ORIG<>T.HOLD_ORIG
 OR N.HOLD_REAS<>T.HOLD_REAS
 OR N.HRCAMT_TDX<>T.HRCAMT_TDX
 OR N.HRCTXFLAG<>T.HRCTXFLAG
 OR N.HRCAMT_TDY<>T.HRCAMT_TDY
 OR N.HRCTYFLAG<>T.HRCTYFLAG
 OR N.HRCASH_NO<>T.HRCASH_NO
 OR N.HRCASH_NOX<>T.HRCASH_NOX
 OR N.HRCNO_TDX<>T.HRCNO_TDX
 OR N.HRCNO_TDY<>T.HRCNO_TDY
 OR N.ISS_SERIAL<>T.ISS_SERIAL
 OR N.ISSUE_DAY<>T.ISSUE_DAY
 OR N.ISSUE_REAS<>T.ISSUE_REAS
 OR N.LASTAUTHDY<>T.LASTAUTHDY
 OR N.LASTPIN_DY<>T.LASTPIN_DY
 OR N.LASTREV_DY<>T.LASTREV_DY
 OR N.LIMIT_X<>T.LIMIT_X
 OR N.LOSS_AMPM<>T.LOSS_AMPM
 OR N.LOSS_DAY<>T.LOSS_DAY
 OR N.LOSS_LOCN<>T.LOSS_LOCN
 OR N.LOSS_REPRT<>T.LOSS_REPRT
 OR N.LOSS_TIME<>T.LOSS_TIME
 OR N.MAILER_1ST<>T.MAILER_1ST
 OR N.MAX_AINAMT<>T.MAX_AINAMT
 OR N.MAX_AUOAMT<>T.MAX_AUOAMT
 OR N.MAX_CAMT<>T.MAX_CAMT
 OR N.MAX_CAMTX<>T.MAX_CAMTX
 OR N.MAX_CHATM<>T.MAX_CHATM
 OR N.MAX_CHATMX<>T.MAX_CHATMX
 OR N.MAX_CHTLR<>T.MAX_CHTLR
 OR N.MAX_CHTLRX<>T.MAX_CHTLRX
 OR N.MAX_DAMT<>T.MAX_DAMT
 OR N.MAX_DAMTX<>T.MAX_DAMTX
 OR N.MAX_HRCAMT<>T.MAX_HRCAMT
 OR N.MAX_HRCAMX<>T.MAX_HRCAMX
 OR N.MAX_NOTLR<>T.MAX_NOTLR
 OR N.MAX_NOTLRX<>T.MAX_NOTLRX
 OR N.MAX_PAMT<>T.MAX_PAMT
 OR N.MAX_PAMTX<>T.MAX_PAMTX
 OR N.MAX_PINTRY<>T.MAX_PINTRY
 OR N.MAX_POAMT<>T.MAX_POAMT
 OR N.MAX_POAMX<>T.MAX_POAMX
 OR N.MCC102<>T.MCC102
 OR N.MCC103<>T.MCC103
 OR N.MCGALLOWED<>T.MCGALLOWED
 OR N.MCGRESTRI<>T.MCGRESTRI
 OR N.MEMBER<>T.MEMBER
 OR N.OTH_BNKCDE<>T.OTH_BNKCDE
 OR N.PIN_CHK<>T.PIN_CHK
 OR N.PIN_DATE<>T.PIN_DATE
 OR N.PIN_FAILDL<>T.PIN_FAILDL
 OR N.PIN_FAILS<>T.PIN_FAILS
 OR N.PIN_REQD<>T.PIN_REQD
 OR N.PIN_RESET<>T.PIN_RESET
 OR N.PIN_TIME<>T.PIN_TIME
 OR N.PREV_CANC<>T.PREV_CANC
 OR N.PREV_DAY<>T.PREV_DAY
 OR N.PREV_TIME<>T.PREV_TIME
 OR N.PRODUCT<>T.PRODUCT
 OR N.PURCH_YN<>T.PURCH_YN
 OR N.PURCHS_NOX<>T.PURCHS_NOX
 OR N.PURCHSE_NO<>T.PURCHSE_NO
 OR N.PURGE_DATE<>T.PURGE_DATE
 OR N.REISS_DTE<>T.REISS_DTE
 OR N.REISS_FLG<>T.REISS_FLG
 OR N.REPLACEFEE<>T.REPLACEFEE
 OR N.REVTDY_NO<>T.REVTDY_NO
 OR N.RUSHFEE<>T.RUSHFEE
 OR N.RUSHFLAG<>T.RUSHFLAG
 OR N.RVSLS_NO<>T.RVSLS_NO
 OR N.SAV_BNKCDE<>T.SAV_BNKCDE
 OR N.SCHD_DSPCH<>T.SCHD_DSPCH
 OR N.SCHD_LOCN<>T.SCHD_LOCN
 OR N.STIPYN<>T.STIPYN
 OR N.STM_BALNCE<>T.STM_BALNCE
 OR N.STMBFLAG<>T.STMBFLAG
 OR N.STM_BALNCX<>T.STM_BALNCX
 OR N.STMBXFLAG<>T.STMBXFLAG
 OR N.STM_CODE<>T.STM_CODE
 OR N.STM_FLAG<>T.STM_FLAG
 OR N.TOTAL_AMT<>T.TOTAL_AMT
 OR N.TTLFLAG<>T.TTLFLAG
 OR N.TOTAL_AMX<>T.TOTAL_AMX
 OR N.TTLXFLAG<>T.TTLXFLAG
 OR N.TRACK2_N<>T.TRACK2_N
 OR N.URG_CARD<>T.URG_CARD
 OR N.URGENTFEE<>T.URGENTFEE
 OR N.VALID_FROM<>T.VALID_FROM
 OR N.VALID_NEW<>T.VALID_NEW
 OR N.VIP_CNT<>T.VIP_CNT
 OR N.VIP_LIM<>T.VIP_LIM
 OR N.WITHDRW_YN<>T.WITHDRW_YN
 OR N.XFRFROM_YN<>T.XFRFROM_YN
 OR N.PINSET_DAY<>T.PINSET_DAY
 OR N.PINSET_NO<>T.PINSET_NO
 OR N.APP_SOURCE<>T.APP_SOURCE
 OR N.LMT_RSN<>T.LMT_RSN
 OR N.POINT_IMER<>T.POINT_IMER
 OR N.PTIFLAG<>T.PTIFLAG
 OR N.POINT_OMER<>T.POINT_OMER
 OR N.PTOFLAG<>T.PTOFLAG
 OR N.ACTIVE_DAY<>T.ACTIVE_DAY
 OR N.PIN_OFFFL<>T.PIN_OFFFL
 OR N.UP_CARD<>T.UP_CARD
 OR N.PBOC_YN<>T.PBOC_YN
 OR N.VCRLMT<>T.VCRLMT
 OR N.VFCRLMTSET<>T.VFCRLMTSET
 OR N.FCRLMT<>T.FCRLMT
 OR N.CUSTR_REF<>T.CUSTR_REF
 OR N.PRMAG_CODE<>T.PRMAG_CODE
 OR N.FEE_GROUP<>T.FEE_GROUP
 OR N.CARD_TO<>T.CARD_TO
 OR N.ACTIVE_FST<>T.ACTIVE_FST
 OR N.ETL_DAY<>T.ETL_DAY
 OR N.ISS_MOD<>T.ISS_MOD
 OR N.CPNO<>T.CPNO
 OR N.NBRMTH<>T.NBRMTH
 OR N.MIN_MPAMT<>T.MIN_MPAMT
 OR N.MAX_MPAMT<>T.MAX_MPAMT

;

--Step3:
UPDATE dw_sdata.CCB_000_CARD P 
SET End_Dt=DATE('${TX_DATE_YYYYMMDD}')
FROM T_90
WHERE P.End_Dt=DATE('2100-12-31')
AND P.CARD_NBR=T_90.CARD_NBR
;

--Step4:
INSERT  INTO dw_sdata.CCB_000_CARD SELECT * FROM T_90;

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