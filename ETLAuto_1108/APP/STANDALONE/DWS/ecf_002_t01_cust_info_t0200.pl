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
DELETE FROM dw_sdata.ECF_002_T01_CUST_INFO_T WHERE start_dt>=DATE('${TX_DATE_YYYYMMDD}');
UPDATE dw_sdata.ECF_002_T01_CUST_INFO_T SET end_dt=DATE('2100-12-31') WHERE end_dt>=DATE('${TX_DATE_YYYYMMDD}') AND end_dt<>DATE('2100-12-31');

--Step1:
CREATE LOCAL TEMPORARY TABLE  T_167 ON COMMIT PRESERVE ROWS AS SELECT * FROM dw_sdata.ECF_002_T01_CUST_INFO_T WHERE 1=0;

--Step2:
INSERT  INTO T_167 (
  PARTY_ID,
  ECIF_CUST_NO,
  CUSTOMER_TYPE_CD,
  PARTY_NAME,
  TRANS_EMT_NO,
  CREDIT_FLAG,
  FIN_LIC_NO,
  LEGAL_FLAG,
  CERT_TYPE,
  CERT_NO,
  GOVN_EXPD_DATE,
  CUST_SHORTNAME,
  CUST_ENNAME,
  CUST_SHORT_ENNAME,
  TAX_REG_NO,
  TAX_AREA_NO,
  COMPANY_NO,
  UNIT_STDCODE_EXPDATE,
  SPE_INST_CODE,
  SWIFT_NO,
  COUNTRY,
  PROVINCE,
  CITY,
  POST_CODE,
  ADDR,
  WEB_SITE,
  UNIT_CREDIT_CODE,
  ORG_START_DATE,
  REG_CPTL_CURR,
  REG_CPTL,
  WORK_COUNTRY,
  COUNT_TYPE,
  PROVINCE_R,
  PROVINCE_M,
  REG_ADDRESS,
  REG_POST,
  WORK_ADDRESS,
  WORK_POST,
  ENG_ADDRESS,
  ORG_TYPE,
  ADMN_TYPE,
  INDUSTRY_TYPE,
  HOLDING_NAME,
  ACTUAL_CONTROLLER,
  LEGALINCHARGE_TYPE,
  LGPS_NAME,
  LGPS_CERT_TYPE,
  LGPS_CERT_NO,
  CLOSE_DATE,
  SUP_FLAG,
  LGPS_CONTACT,
  FIN_CONNTR,
  FIN_CONTACT,
  FIN_CERT_TYPE,
  FIN_CERT_NO,
  BSSAV_ACC_NO,
  BASIC_AC_OPEN_BNK,
  BAS_ACBANK_NO,
  BAS_OPEN_PERMIT_NO,
  ACCT_LIC_NO,
  NRA_FLAG,
  CUST_FORE_EXCH_ATTR,
  ECON_NATURE,
  FORE_EXCH_ICCARD_NO,
  IMP_DIRE,
  T_CUSTOMER_TYPE,
  FIRST_NAME,
  SECOND_NAME,
  BUSI_SITE_FLAG,
  RES_COUNTRY,
  FORE_INV_COUNTRY,
  SPE_ECON_INST,
  SPE_ECON_INST_FLAG,
  FORE_CODE,
  FORE_INDUSTRY_ATTR,
  FORE_ECON_TYPE,
  CREDIT_CUST_FLAG,
  OPEN_ORG,
  OWN_ORG,
  LAST_UPDATED_TE,
  LAST_UPDATED_ORG,
  CREATED_TS,
  UPDATED_TS,
  INIT_SYSTEM_ID,
  INIT_CREATED_TS,
  LAST_SYSTEM_ID,
  LAST_UPDATED_TS,
  INDUSTRY_TYPE_INNER,
  TAXPAYER_TYPE,
  PHONE_NUMBER,
  start_dt,
  end_dt)
SELECT
  N.PARTY_ID,
  N.ECIF_CUST_NO,
  N.CUSTOMER_TYPE_CD,
  N.PARTY_NAME,
  N.TRANS_EMT_NO,
  N.CREDIT_FLAG,
  N.FIN_LIC_NO,
  N.LEGAL_FLAG,
  N.CERT_TYPE,
  N.CERT_NO,
  N.GOVN_EXPD_DATE,
  N.CUST_SHORTNAME,
  N.CUST_ENNAME,
  N.CUST_SHORT_ENNAME,
  N.TAX_REG_NO,
  N.TAX_AREA_NO,
  N.COMPANY_NO,
  N.UNIT_STDCODE_EXPDATE,
  N.SPE_INST_CODE,
  N.SWIFT_NO,
  N.COUNTRY,
  N.PROVINCE,
  N.CITY,
  N.POST_CODE,
  N.ADDR,
  N.WEB_SITE,
  N.UNIT_CREDIT_CODE,
  N.ORG_START_DATE,
  N.REG_CPTL_CURR,
  N.REG_CPTL,
  N.WORK_COUNTRY,
  N.COUNT_TYPE,
  N.PROVINCE_R,
  N.PROVINCE_M,
  N.REG_ADDRESS,
  N.REG_POST,
  N.WORK_ADDRESS,
  N.WORK_POST,
  N.ENG_ADDRESS,
  N.ORG_TYPE,
  N.ADMN_TYPE,
  N.INDUSTRY_TYPE,
  N.HOLDING_NAME,
  N.ACTUAL_CONTROLLER,
  N.LEGALINCHARGE_TYPE,
  N.LGPS_NAME,
  N.LGPS_CERT_TYPE,
  N.LGPS_CERT_NO,
  N.CLOSE_DATE,
  N.SUP_FLAG,
  N.LGPS_CONTACT,
  N.FIN_CONNTR,
  N.FIN_CONTACT,
  N.FIN_CERT_TYPE,
  N.FIN_CERT_NO,
  N.BSSAV_ACC_NO,
  N.BASIC_AC_OPEN_BNK,
  N.BAS_ACBANK_NO,
  N.BAS_OPEN_PERMIT_NO,
  N.ACCT_LIC_NO,
  N.NRA_FLAG,
  N.CUST_FORE_EXCH_ATTR,
  N.ECON_NATURE,
  N.FORE_EXCH_ICCARD_NO,
  N.IMP_DIRE,
  N.T_CUSTOMER_TYPE,
  N.FIRST_NAME,
  N.SECOND_NAME,
  N.BUSI_SITE_FLAG,
  N.RES_COUNTRY,
  N.FORE_INV_COUNTRY,
  N.SPE_ECON_INST,
  N.SPE_ECON_INST_FLAG,
  N.FORE_CODE,
  N.FORE_INDUSTRY_ATTR,
  N.FORE_ECON_TYPE,
  N.CREDIT_CUST_FLAG,
  N.OPEN_ORG,
  N.OWN_ORG,
  N.LAST_UPDATED_TE,
  N.LAST_UPDATED_ORG,
  N.CREATED_TS,
  N.UPDATED_TS,
  N.INIT_SYSTEM_ID,
  N.INIT_CREATED_TS,
  N.LAST_SYSTEM_ID,
  N.LAST_UPDATED_TS,
  N.INDUSTRY_TYPE_INNER,
  N.TAXPAYER_TYPE,
  N.PHONE_NUMBER,
  DATE('${TX_DATE_YYYYMMDD}'),
  DATE('2100-12-31')
FROM 
 (SELECT
  COALESCE(PARTY_ID, '' ) AS PARTY_ID ,
  COALESCE(ECIF_CUST_NO, '' ) AS ECIF_CUST_NO ,
  COALESCE(CUSTOMER_TYPE_CD, '' ) AS CUSTOMER_TYPE_CD ,
  COALESCE(PARTY_NAME, '' ) AS PARTY_NAME ,
  COALESCE(TRANS_EMT_NO, '' ) AS TRANS_EMT_NO ,
  COALESCE(CREDIT_FLAG, '' ) AS CREDIT_FLAG ,
  COALESCE(FIN_LIC_NO, '' ) AS FIN_LIC_NO ,
  COALESCE(LEGAL_FLAG, '' ) AS LEGAL_FLAG ,
  COALESCE(CERT_TYPE, '' ) AS CERT_TYPE ,
  COALESCE(CERT_NO, '' ) AS CERT_NO ,
  COALESCE(GOVN_EXPD_DATE, '' ) AS GOVN_EXPD_DATE ,
  COALESCE(CUST_SHORTNAME, '' ) AS CUST_SHORTNAME ,
  COALESCE(CUST_ENNAME, '' ) AS CUST_ENNAME ,
  COALESCE(CUST_SHORT_ENNAME, '' ) AS CUST_SHORT_ENNAME ,
  COALESCE(TAX_REG_NO, '' ) AS TAX_REG_NO ,
  COALESCE(TAX_AREA_NO, '' ) AS TAX_AREA_NO ,
  COALESCE(COMPANY_NO, '' ) AS COMPANY_NO ,
  COALESCE(UNIT_STDCODE_EXPDATE, '' ) AS UNIT_STDCODE_EXPDATE ,
  COALESCE(SPE_INST_CODE, '' ) AS SPE_INST_CODE ,
  COALESCE(SWIFT_NO, '' ) AS SWIFT_NO ,
  COALESCE(COUNTRY, '' ) AS COUNTRY ,
  COALESCE(PROVINCE, '' ) AS PROVINCE ,
  COALESCE(CITY, '' ) AS CITY ,
  COALESCE(POST_CODE, '' ) AS POST_CODE ,
  COALESCE(ADDR, '' ) AS ADDR ,
  COALESCE(WEB_SITE, '' ) AS WEB_SITE ,
  COALESCE(UNIT_CREDIT_CODE, '' ) AS UNIT_CREDIT_CODE ,
  COALESCE(ORG_START_DATE, '' ) AS ORG_START_DATE ,
  COALESCE(REG_CPTL_CURR, '' ) AS REG_CPTL_CURR ,
  COALESCE(REG_CPTL, 0 ) AS REG_CPTL ,
  COALESCE(WORK_COUNTRY, '' ) AS WORK_COUNTRY ,
  COALESCE(COUNT_TYPE, '' ) AS COUNT_TYPE ,
  COALESCE(PROVINCE_R, '' ) AS PROVINCE_R ,
  COALESCE(PROVINCE_M, '' ) AS PROVINCE_M ,
  COALESCE(REG_ADDRESS, '' ) AS REG_ADDRESS ,
  COALESCE(REG_POST, '' ) AS REG_POST ,
  COALESCE(WORK_ADDRESS, '' ) AS WORK_ADDRESS ,
  COALESCE(WORK_POST, '' ) AS WORK_POST ,
  COALESCE(ENG_ADDRESS, '' ) AS ENG_ADDRESS ,
  COALESCE(ORG_TYPE, '' ) AS ORG_TYPE ,
  COALESCE(ADMN_TYPE, '' ) AS ADMN_TYPE ,
  COALESCE(INDUSTRY_TYPE, '' ) AS INDUSTRY_TYPE ,
  COALESCE(HOLDING_NAME, '' ) AS HOLDING_NAME ,
  COALESCE(ACTUAL_CONTROLLER, '' ) AS ACTUAL_CONTROLLER ,
  COALESCE(LEGALINCHARGE_TYPE, '' ) AS LEGALINCHARGE_TYPE ,
  COALESCE(LGPS_NAME, '' ) AS LGPS_NAME ,
  COALESCE(LGPS_CERT_TYPE, '' ) AS LGPS_CERT_TYPE ,
  COALESCE(LGPS_CERT_NO, '' ) AS LGPS_CERT_NO ,
  COALESCE(CLOSE_DATE, '' ) AS CLOSE_DATE ,
  COALESCE(SUP_FLAG, '' ) AS SUP_FLAG ,
  COALESCE(LGPS_CONTACT, '' ) AS LGPS_CONTACT ,
  COALESCE(FIN_CONNTR, '' ) AS FIN_CONNTR ,
  COALESCE(FIN_CONTACT, '' ) AS FIN_CONTACT ,
  COALESCE(FIN_CERT_TYPE, '' ) AS FIN_CERT_TYPE ,
  COALESCE(FIN_CERT_NO, '' ) AS FIN_CERT_NO ,
  COALESCE(BSSAV_ACC_NO, '' ) AS BSSAV_ACC_NO ,
  COALESCE(BASIC_AC_OPEN_BNK, '' ) AS BASIC_AC_OPEN_BNK ,
  COALESCE(BAS_ACBANK_NO, '' ) AS BAS_ACBANK_NO ,
  COALESCE(BAS_OPEN_PERMIT_NO, '' ) AS BAS_OPEN_PERMIT_NO ,
  COALESCE(ACCT_LIC_NO, '' ) AS ACCT_LIC_NO ,
  COALESCE(NRA_FLAG, '' ) AS NRA_FLAG ,
  COALESCE(CUST_FORE_EXCH_ATTR, '' ) AS CUST_FORE_EXCH_ATTR ,
  COALESCE(ECON_NATURE, '' ) AS ECON_NATURE ,
  COALESCE(FORE_EXCH_ICCARD_NO, '' ) AS FORE_EXCH_ICCARD_NO ,
  COALESCE(IMP_DIRE, '' ) AS IMP_DIRE ,
  COALESCE(T_CUSTOMER_TYPE, '' ) AS T_CUSTOMER_TYPE ,
  COALESCE(FIRST_NAME, '' ) AS FIRST_NAME ,
  COALESCE(SECOND_NAME, '' ) AS SECOND_NAME ,
  COALESCE(BUSI_SITE_FLAG, '' ) AS BUSI_SITE_FLAG ,
  COALESCE(RES_COUNTRY, '' ) AS RES_COUNTRY ,
  COALESCE(FORE_INV_COUNTRY, '' ) AS FORE_INV_COUNTRY ,
  COALESCE(SPE_ECON_INST, '' ) AS SPE_ECON_INST ,
  COALESCE(SPE_ECON_INST_FLAG, '' ) AS SPE_ECON_INST_FLAG ,
  COALESCE(FORE_CODE, '' ) AS FORE_CODE ,
  COALESCE(FORE_INDUSTRY_ATTR, '' ) AS FORE_INDUSTRY_ATTR ,
  COALESCE(FORE_ECON_TYPE, '' ) AS FORE_ECON_TYPE ,
  COALESCE(CREDIT_CUST_FLAG, '' ) AS CREDIT_CUST_FLAG ,
  COALESCE(OPEN_ORG, '' ) AS OPEN_ORG ,
  COALESCE(OWN_ORG, '' ) AS OWN_ORG ,
  COALESCE(LAST_UPDATED_TE, '' ) AS LAST_UPDATED_TE ,
  COALESCE(LAST_UPDATED_ORG, '' ) AS LAST_UPDATED_ORG ,
  COALESCE(CREATED_TS,'4999-12-31 00:00:00' ) AS CREATED_TS ,
  COALESCE(UPDATED_TS,'4999-12-31 00:00:00' ) AS UPDATED_TS ,
  COALESCE(INIT_SYSTEM_ID, '' ) AS INIT_SYSTEM_ID ,
  COALESCE(INIT_CREATED_TS,'4999-12-31 00:00:00' ) AS INIT_CREATED_TS ,
  COALESCE(LAST_SYSTEM_ID, '' ) AS LAST_SYSTEM_ID ,
  COALESCE(LAST_UPDATED_TS,'4999-12-31 00:00:00' ) AS LAST_UPDATED_TS ,
  COALESCE(INDUSTRY_TYPE_INNER, '' ) AS INDUSTRY_TYPE_INNER ,
  COALESCE(TAXPAYER_TYPE, '' ) AS TAXPAYER_TYPE ,
  COALESCE(PHONE_NUMBER, '' ) AS PHONE_NUMBER 
 FROM  dw_tdata.ECF_002_T01_CUST_INFO_T_${TX_DATE_YYYYMMDD}) N
LEFT JOIN
 (SELECT 
  PARTY_ID ,
  ECIF_CUST_NO ,
  CUSTOMER_TYPE_CD ,
  PARTY_NAME ,
  TRANS_EMT_NO ,
  CREDIT_FLAG ,
  FIN_LIC_NO ,
  LEGAL_FLAG ,
  CERT_TYPE ,
  CERT_NO ,
  GOVN_EXPD_DATE ,
  CUST_SHORTNAME ,
  CUST_ENNAME ,
  CUST_SHORT_ENNAME ,
  TAX_REG_NO ,
  TAX_AREA_NO ,
  COMPANY_NO ,
  UNIT_STDCODE_EXPDATE ,
  SPE_INST_CODE ,
  SWIFT_NO ,
  COUNTRY ,
  PROVINCE ,
  CITY ,
  POST_CODE ,
  ADDR ,
  WEB_SITE ,
  UNIT_CREDIT_CODE ,
  ORG_START_DATE ,
  REG_CPTL_CURR ,
  REG_CPTL ,
  WORK_COUNTRY ,
  COUNT_TYPE ,
  PROVINCE_R ,
  PROVINCE_M ,
  REG_ADDRESS ,
  REG_POST ,
  WORK_ADDRESS ,
  WORK_POST ,
  ENG_ADDRESS ,
  ORG_TYPE ,
  ADMN_TYPE ,
  INDUSTRY_TYPE ,
  HOLDING_NAME ,
  ACTUAL_CONTROLLER ,
  LEGALINCHARGE_TYPE ,
  LGPS_NAME ,
  LGPS_CERT_TYPE ,
  LGPS_CERT_NO ,
  CLOSE_DATE ,
  SUP_FLAG ,
  LGPS_CONTACT ,
  FIN_CONNTR ,
  FIN_CONTACT ,
  FIN_CERT_TYPE ,
  FIN_CERT_NO ,
  BSSAV_ACC_NO ,
  BASIC_AC_OPEN_BNK ,
  BAS_ACBANK_NO ,
  BAS_OPEN_PERMIT_NO ,
  ACCT_LIC_NO ,
  NRA_FLAG ,
  CUST_FORE_EXCH_ATTR ,
  ECON_NATURE ,
  FORE_EXCH_ICCARD_NO ,
  IMP_DIRE ,
  T_CUSTOMER_TYPE ,
  FIRST_NAME ,
  SECOND_NAME ,
  BUSI_SITE_FLAG ,
  RES_COUNTRY ,
  FORE_INV_COUNTRY ,
  SPE_ECON_INST ,
  SPE_ECON_INST_FLAG ,
  FORE_CODE ,
  FORE_INDUSTRY_ATTR ,
  FORE_ECON_TYPE ,
  CREDIT_CUST_FLAG ,
  OPEN_ORG ,
  OWN_ORG ,
  LAST_UPDATED_TE ,
  LAST_UPDATED_ORG ,
  CREATED_TS ,
  UPDATED_TS ,
  INIT_SYSTEM_ID ,
  INIT_CREATED_TS ,
  LAST_SYSTEM_ID ,
  LAST_UPDATED_TS ,
  INDUSTRY_TYPE_INNER ,
  TAXPAYER_TYPE ,
  PHONE_NUMBER 
 FROM dw_sdata.ECF_002_T01_CUST_INFO_T 
 WHERE END_DT = DATE('2100-12-31') ) T
ON N.PARTY_ID = T.PARTY_ID
WHERE
(T.PARTY_ID IS NULL)
 OR N.ECIF_CUST_NO<>T.ECIF_CUST_NO
 OR N.CUSTOMER_TYPE_CD<>T.CUSTOMER_TYPE_CD
 OR N.PARTY_NAME<>T.PARTY_NAME
 OR N.TRANS_EMT_NO<>T.TRANS_EMT_NO
 OR N.CREDIT_FLAG<>T.CREDIT_FLAG
 OR N.FIN_LIC_NO<>T.FIN_LIC_NO
 OR N.LEGAL_FLAG<>T.LEGAL_FLAG
 OR N.CERT_TYPE<>T.CERT_TYPE
 OR N.CERT_NO<>T.CERT_NO
 OR N.GOVN_EXPD_DATE<>T.GOVN_EXPD_DATE
 OR N.CUST_SHORTNAME<>T.CUST_SHORTNAME
 OR N.CUST_ENNAME<>T.CUST_ENNAME
 OR N.CUST_SHORT_ENNAME<>T.CUST_SHORT_ENNAME
 OR N.TAX_REG_NO<>T.TAX_REG_NO
 OR N.TAX_AREA_NO<>T.TAX_AREA_NO
 OR N.COMPANY_NO<>T.COMPANY_NO
 OR N.UNIT_STDCODE_EXPDATE<>T.UNIT_STDCODE_EXPDATE
 OR N.SPE_INST_CODE<>T.SPE_INST_CODE
 OR N.SWIFT_NO<>T.SWIFT_NO
 OR N.COUNTRY<>T.COUNTRY
 OR N.PROVINCE<>T.PROVINCE
 OR N.CITY<>T.CITY
 OR N.POST_CODE<>T.POST_CODE
 OR N.ADDR<>T.ADDR
 OR N.WEB_SITE<>T.WEB_SITE
 OR N.UNIT_CREDIT_CODE<>T.UNIT_CREDIT_CODE
 OR N.ORG_START_DATE<>T.ORG_START_DATE
 OR N.REG_CPTL_CURR<>T.REG_CPTL_CURR
 OR N.REG_CPTL<>T.REG_CPTL
 OR N.WORK_COUNTRY<>T.WORK_COUNTRY
 OR N.COUNT_TYPE<>T.COUNT_TYPE
 OR N.PROVINCE_R<>T.PROVINCE_R
 OR N.PROVINCE_M<>T.PROVINCE_M
 OR N.REG_ADDRESS<>T.REG_ADDRESS
 OR N.REG_POST<>T.REG_POST
 OR N.WORK_ADDRESS<>T.WORK_ADDRESS
 OR N.WORK_POST<>T.WORK_POST
 OR N.ENG_ADDRESS<>T.ENG_ADDRESS
 OR N.ORG_TYPE<>T.ORG_TYPE
 OR N.ADMN_TYPE<>T.ADMN_TYPE
 OR N.INDUSTRY_TYPE<>T.INDUSTRY_TYPE
 OR N.HOLDING_NAME<>T.HOLDING_NAME
 OR N.ACTUAL_CONTROLLER<>T.ACTUAL_CONTROLLER
 OR N.LEGALINCHARGE_TYPE<>T.LEGALINCHARGE_TYPE
 OR N.LGPS_NAME<>T.LGPS_NAME
 OR N.LGPS_CERT_TYPE<>T.LGPS_CERT_TYPE
 OR N.LGPS_CERT_NO<>T.LGPS_CERT_NO
 OR N.CLOSE_DATE<>T.CLOSE_DATE
 OR N.SUP_FLAG<>T.SUP_FLAG
 OR N.LGPS_CONTACT<>T.LGPS_CONTACT
 OR N.FIN_CONNTR<>T.FIN_CONNTR
 OR N.FIN_CONTACT<>T.FIN_CONTACT
 OR N.FIN_CERT_TYPE<>T.FIN_CERT_TYPE
 OR N.FIN_CERT_NO<>T.FIN_CERT_NO
 OR N.BSSAV_ACC_NO<>T.BSSAV_ACC_NO
 OR N.BASIC_AC_OPEN_BNK<>T.BASIC_AC_OPEN_BNK
 OR N.BAS_ACBANK_NO<>T.BAS_ACBANK_NO
 OR N.BAS_OPEN_PERMIT_NO<>T.BAS_OPEN_PERMIT_NO
 OR N.ACCT_LIC_NO<>T.ACCT_LIC_NO
 OR N.NRA_FLAG<>T.NRA_FLAG
 OR N.CUST_FORE_EXCH_ATTR<>T.CUST_FORE_EXCH_ATTR
 OR N.ECON_NATURE<>T.ECON_NATURE
 OR N.FORE_EXCH_ICCARD_NO<>T.FORE_EXCH_ICCARD_NO
 OR N.IMP_DIRE<>T.IMP_DIRE
 OR N.T_CUSTOMER_TYPE<>T.T_CUSTOMER_TYPE
 OR N.FIRST_NAME<>T.FIRST_NAME
 OR N.SECOND_NAME<>T.SECOND_NAME
 OR N.BUSI_SITE_FLAG<>T.BUSI_SITE_FLAG
 OR N.RES_COUNTRY<>T.RES_COUNTRY
 OR N.FORE_INV_COUNTRY<>T.FORE_INV_COUNTRY
 OR N.SPE_ECON_INST<>T.SPE_ECON_INST
 OR N.SPE_ECON_INST_FLAG<>T.SPE_ECON_INST_FLAG
 OR N.FORE_CODE<>T.FORE_CODE
 OR N.FORE_INDUSTRY_ATTR<>T.FORE_INDUSTRY_ATTR
 OR N.FORE_ECON_TYPE<>T.FORE_ECON_TYPE
 OR N.CREDIT_CUST_FLAG<>T.CREDIT_CUST_FLAG
 OR N.OPEN_ORG<>T.OPEN_ORG
 OR N.OWN_ORG<>T.OWN_ORG
 OR N.LAST_UPDATED_TE<>T.LAST_UPDATED_TE
 OR N.LAST_UPDATED_ORG<>T.LAST_UPDATED_ORG
 OR N.CREATED_TS<>T.CREATED_TS
 OR N.UPDATED_TS<>T.UPDATED_TS
 OR N.INIT_SYSTEM_ID<>T.INIT_SYSTEM_ID
 OR N.INIT_CREATED_TS<>T.INIT_CREATED_TS
 OR N.LAST_SYSTEM_ID<>T.LAST_SYSTEM_ID
 OR N.LAST_UPDATED_TS<>T.LAST_UPDATED_TS
 OR N.INDUSTRY_TYPE_INNER<>T.INDUSTRY_TYPE_INNER
 OR N.TAXPAYER_TYPE<>T.TAXPAYER_TYPE
 OR N.PHONE_NUMBER<>T.PHONE_NUMBER
;

--Step3:
UPDATE dw_sdata.ECF_002_T01_CUST_INFO_T P 
SET End_Dt=DATE('${TX_DATE_YYYYMMDD}')
FROM T_167
WHERE P.End_Dt=DATE('2100-12-31')
AND P.PARTY_ID=T_167.PARTY_ID
;

--Step4:
INSERT  INTO dw_sdata.ECF_002_T01_CUST_INFO_T SELECT * FROM T_167;

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