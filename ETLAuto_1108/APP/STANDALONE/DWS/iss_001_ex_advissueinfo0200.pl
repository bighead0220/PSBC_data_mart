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
DELETE FROM dw_sdata.ISS_001_EX_ADVISSUEINFO WHERE start_dt>=DATE('${TX_DATE_YYYYMMDD}');
UPDATE dw_sdata.ISS_001_EX_ADVISSUEINFO SET end_dt=DATE('2100-12-31') WHERE end_dt>=DATE('${TX_DATE_YYYYMMDD}') AND end_dt<>DATE('2100-12-31');

--Step1:
CREATE LOCAL TEMPORARY TABLE  T_233 ON COMMIT PRESERVE ROWS AS SELECT * FROM dw_sdata.ISS_001_EX_ADVISSUEINFO WHERE 1=0;

--Step2:
INSERT  INTO T_233 (
  TXNSERIALNO,
  BIZNO,
  LCNO,
  OLDTXNSERIALNO,
  AMENDADVNO,
  ISVALID,
  ISSENDSWF,
  SWIFTTYPE,
  TESTSIGN,
  SELFLC,
  ISAGENT,
  CHGUNDERTAKER,
  AGENTBANKNO,
  AGENTBANKSWFCODE,
  AGENTBANKNAME,
  ISSIMPLESWFLC,
  LCFORM,
  SDFLAG,
  DRAFTDAYS,
  DRAFTDAYSDESCR,
  DRAFTDAYSTYPE,
  SPECLC,
  BENEFNO,
  BENEFNAME,
  ISSUINGDATE,
  ADVDATE,
  EXPIRYDATE,
  LASTSHIPDATE,
  AVAILABLEBY,
  APPNO,
  APPNAMEADDR,
  ISSUINGBANKNO,
  ISSUINGSWFCODE,
  ISSUINGBANKNAME,
  OLDISSUINGBANKNO,
  OLDISSUINGBANKNAME,
  ISCONFIRM,
  CONFIRMINSTR,
  CONFIRMBANKNO,
  CONFIRBANKSWFCODE,
  CONFIRMBANKNAME,
  CONFIRMBANKREF,
  REIMBBANKNO,
  REIMBBANKSWFCODE,
  REIMBBANK,
  ISTRANS,
  TRANSDEGREE,
  TRANSAMT,
  TRANSBANKNO,
  TRANSBANKSWFCODE,
  TRANSBANKNAME,
  TRANSBANKREF,
  ISTRANSMIT,
  TRANSMITFLAG,
  TRANSMITBANKNO,
  TRANSMITSWFCODE,
  TRANSMITBANKNAME,
  TRANSMITBANKSWFNO,
  PRESENTBANKNO,
  PRESENTBANKSWFCODE,
  PRESENTBANKNAME,
  LCCUR,
  LCAMT,
  LCAMTBAL,
  LCAMTTOLERUP,
  LCAMTTOLERDOWN,
  LCMAXAMT,
  LCMINAMT,
  ISSUEMODE,
  ISLCRET,
  INSTRUCTION,
  COUNTRYCODE,
  NEGTYPE,
  NEGBANKNO,
  NEGBANKSWFCODE,
  NEGBANKNAMEADDR,
  PRESENTPERIOD,
  EXPIRYPLACE,
  LCAVAILTYPE,
  ISMIXEDPAY,
  MIXEDPAYDETAILS,
  ISPARTIALSHPTS,
  ISTRANSHIPMENT,
  ADDITIONALAMT,
  COMMODITY,
  AMENDDETAILS,
  MODIFYLCDATE,
  MODIFYDEGREE,
  MODIFYAMTFLAG,
  MODIFYCUR,
  MODIFYAMT,
  CANCELDATE,
  CANCELLC,
  OPTYPE,
  MODIFYTYPE,
  REVOLVETYPE,
  NEGDEGREE,
  NEGCUR,
  SUMAMT,
  NEGAMT,
  TRANSMITDATE,
  TRANSMITVIA,
  TRANSTHRUBANKNO,
  TRANSTHRUBANKSWF,
  TRANSTHRUBANKNAME,
  AMENDCONFIRM,
  DEFPAYMENTDETAILS,
  DRAWEEBANKNO,
  DRAWEEBANKNAME,
  DRAWEEBANKSWFCODE,
  ISAGREE,
  RECVAMT,
  BELONGORGNO,
  MANAGERID,
  TRADENO,
  ISLG,
  NEWLCAMT,
  OPPPARTYCLASS,
  OPPNAME,
  INOUTAREA,
  MAILBANKNO,
  MAILBANKSWFCODE,
  MAILBANKADDR,
  LCMEMO,
  ISSUINGBANKMEMO,
  CONFIRBANKMEMO,
  URFLAG,
  ISCFM,
  OUTACCTSERIALNO,
  CONSTRACTNO,
  LCACCEPTAMT,
  LCNOTPAYAMT,
  SECONDOPPNAME,
  SECONDAPPNAMEADDR,
  CANCELAPPPRE,
  LCAMTREPRESENT,
  APPCANCELISSENDSWF,
  NEG,
  start_dt,
  end_dt)
SELECT
  N.TXNSERIALNO,
  N.BIZNO,
  N.LCNO,
  N.OLDTXNSERIALNO,
  N.AMENDADVNO,
  N.ISVALID,
  N.ISSENDSWF,
  N.SWIFTTYPE,
  N.TESTSIGN,
  N.SELFLC,
  N.ISAGENT,
  N.CHGUNDERTAKER,
  N.AGENTBANKNO,
  N.AGENTBANKSWFCODE,
  N.AGENTBANKNAME,
  N.ISSIMPLESWFLC,
  N.LCFORM,
  N.SDFLAG,
  N.DRAFTDAYS,
  N.DRAFTDAYSDESCR,
  N.DRAFTDAYSTYPE,
  N.SPECLC,
  N.BENEFNO,
  N.BENEFNAME,
  N.ISSUINGDATE,
  N.ADVDATE,
  N.EXPIRYDATE,
  N.LASTSHIPDATE,
  N.AVAILABLEBY,
  N.APPNO,
  N.APPNAMEADDR,
  N.ISSUINGBANKNO,
  N.ISSUINGSWFCODE,
  N.ISSUINGBANKNAME,
  N.OLDISSUINGBANKNO,
  N.OLDISSUINGBANKNAME,
  N.ISCONFIRM,
  N.CONFIRMINSTR,
  N.CONFIRMBANKNO,
  N.CONFIRBANKSWFCODE,
  N.CONFIRMBANKNAME,
  N.CONFIRMBANKREF,
  N.REIMBBANKNO,
  N.REIMBBANKSWFCODE,
  N.REIMBBANK,
  N.ISTRANS,
  N.TRANSDEGREE,
  N.TRANSAMT,
  N.TRANSBANKNO,
  N.TRANSBANKSWFCODE,
  N.TRANSBANKNAME,
  N.TRANSBANKREF,
  N.ISTRANSMIT,
  N.TRANSMITFLAG,
  N.TRANSMITBANKNO,
  N.TRANSMITSWFCODE,
  N.TRANSMITBANKNAME,
  N.TRANSMITBANKSWFNO,
  N.PRESENTBANKNO,
  N.PRESENTBANKSWFCODE,
  N.PRESENTBANKNAME,
  N.LCCUR,
  N.LCAMT,
  N.LCAMTBAL,
  N.LCAMTTOLERUP,
  N.LCAMTTOLERDOWN,
  N.LCMAXAMT,
  N.LCMINAMT,
  N.ISSUEMODE,
  N.ISLCRET,
  N.INSTRUCTION,
  N.COUNTRYCODE,
  N.NEGTYPE,
  N.NEGBANKNO,
  N.NEGBANKSWFCODE,
  N.NEGBANKNAMEADDR,
  N.PRESENTPERIOD,
  N.EXPIRYPLACE,
  N.LCAVAILTYPE,
  N.ISMIXEDPAY,
  N.MIXEDPAYDETAILS,
  N.ISPARTIALSHPTS,
  N.ISTRANSHIPMENT,
  N.ADDITIONALAMT,
  N.COMMODITY,
  N.AMENDDETAILS,
  N.MODIFYLCDATE,
  N.MODIFYDEGREE,
  N.MODIFYAMTFLAG,
  N.MODIFYCUR,
  N.MODIFYAMT,
  N.CANCELDATE,
  N.CANCELLC,
  N.OPTYPE,
  N.MODIFYTYPE,
  N.REVOLVETYPE,
  N.NEGDEGREE,
  N.NEGCUR,
  N.SUMAMT,
  N.NEGAMT,
  N.TRANSMITDATE,
  N.TRANSMITVIA,
  N.TRANSTHRUBANKNO,
  N.TRANSTHRUBANKSWF,
  N.TRANSTHRUBANKNAME,
  N.AMENDCONFIRM,
  N.DEFPAYMENTDETAILS,
  N.DRAWEEBANKNO,
  N.DRAWEEBANKNAME,
  N.DRAWEEBANKSWFCODE,
  N.ISAGREE,
  N.RECVAMT,
  N.BELONGORGNO,
  N.MANAGERID,
  N.TRADENO,
  N.ISLG,
  N.NEWLCAMT,
  N.OPPPARTYCLASS,
  N.OPPNAME,
  N.INOUTAREA,
  N.MAILBANKNO,
  N.MAILBANKSWFCODE,
  N.MAILBANKADDR,
  N.LCMEMO,
  N.ISSUINGBANKMEMO,
  N.CONFIRBANKMEMO,
  N.URFLAG,
  N.ISCFM,
  N.OUTACCTSERIALNO,
  N.CONSTRACTNO,
  N.LCACCEPTAMT,
  N.LCNOTPAYAMT,
  N.SECONDOPPNAME,
  N.SECONDAPPNAMEADDR,
  N.CANCELAPPPRE,
  N.LCAMTREPRESENT,
  N.APPCANCELISSENDSWF,
  N.NEG,
  DATE('${TX_DATE_YYYYMMDD}'),
  DATE('2100-12-31')
FROM 
 (SELECT
  COALESCE(TXNSERIALNO, '' ) AS TXNSERIALNO ,
  COALESCE(BIZNO, '' ) AS BIZNO ,
  COALESCE(LCNO, '' ) AS LCNO ,
  COALESCE(OLDTXNSERIALNO, '' ) AS OLDTXNSERIALNO ,
  COALESCE(AMENDADVNO, '' ) AS AMENDADVNO ,
  COALESCE(ISVALID, '' ) AS ISVALID ,
  COALESCE(ISSENDSWF, '' ) AS ISSENDSWF ,
  COALESCE(SWIFTTYPE, '' ) AS SWIFTTYPE ,
  COALESCE(TESTSIGN, '' ) AS TESTSIGN ,
  COALESCE(SELFLC, '' ) AS SELFLC ,
  COALESCE(ISAGENT, '' ) AS ISAGENT ,
  COALESCE(CHGUNDERTAKER, '' ) AS CHGUNDERTAKER ,
  COALESCE(AGENTBANKNO, '' ) AS AGENTBANKNO ,
  COALESCE(AGENTBANKSWFCODE, '' ) AS AGENTBANKSWFCODE ,
  COALESCE(AGENTBANKNAME, '' ) AS AGENTBANKNAME ,
  COALESCE(ISSIMPLESWFLC, '' ) AS ISSIMPLESWFLC ,
  COALESCE(LCFORM, '' ) AS LCFORM ,
  COALESCE(SDFLAG, '' ) AS SDFLAG ,
  COALESCE(DRAFTDAYS, 0 ) AS DRAFTDAYS ,
  COALESCE(DRAFTDAYSDESCR, '' ) AS DRAFTDAYSDESCR ,
  COALESCE(DRAFTDAYSTYPE, '' ) AS DRAFTDAYSTYPE ,
  COALESCE(SPECLC, '' ) AS SPECLC ,
  COALESCE(BENEFNO, '' ) AS BENEFNO ,
  COALESCE(BENEFNAME, '' ) AS BENEFNAME ,
  COALESCE(ISSUINGDATE,DATE('4999-12-31') ) AS ISSUINGDATE ,
  COALESCE(ADVDATE,DATE('4999-12-31') ) AS ADVDATE ,
  COALESCE(EXPIRYDATE,DATE('4999-12-31') ) AS EXPIRYDATE ,
  COALESCE(LASTSHIPDATE,DATE('4999-12-31') ) AS LASTSHIPDATE ,
  COALESCE(AVAILABLEBY, '' ) AS AVAILABLEBY ,
  COALESCE(APPNO, '' ) AS APPNO ,
  COALESCE(APPNAMEADDR, '' ) AS APPNAMEADDR ,
  COALESCE(ISSUINGBANKNO, '' ) AS ISSUINGBANKNO ,
  COALESCE(ISSUINGSWFCODE, '' ) AS ISSUINGSWFCODE ,
  COALESCE(ISSUINGBANKNAME, '' ) AS ISSUINGBANKNAME ,
  COALESCE(OLDISSUINGBANKNO, '' ) AS OLDISSUINGBANKNO ,
  COALESCE(OLDISSUINGBANKNAME, '' ) AS OLDISSUINGBANKNAME ,
  COALESCE(ISCONFIRM, '' ) AS ISCONFIRM ,
  COALESCE(CONFIRMINSTR, '' ) AS CONFIRMINSTR ,
  COALESCE(CONFIRMBANKNO, '' ) AS CONFIRMBANKNO ,
  COALESCE(CONFIRBANKSWFCODE, '' ) AS CONFIRBANKSWFCODE ,
  COALESCE(CONFIRMBANKNAME, '' ) AS CONFIRMBANKNAME ,
  COALESCE(CONFIRMBANKREF, '' ) AS CONFIRMBANKREF ,
  COALESCE(REIMBBANKNO, '' ) AS REIMBBANKNO ,
  COALESCE(REIMBBANKSWFCODE, '' ) AS REIMBBANKSWFCODE ,
  COALESCE(REIMBBANK, '' ) AS REIMBBANK ,
  COALESCE(ISTRANS, '' ) AS ISTRANS ,
  COALESCE(TRANSDEGREE, 0 ) AS TRANSDEGREE ,
  COALESCE(TRANSAMT, 0 ) AS TRANSAMT ,
  COALESCE(TRANSBANKNO, '' ) AS TRANSBANKNO ,
  COALESCE(TRANSBANKSWFCODE, '' ) AS TRANSBANKSWFCODE ,
  COALESCE(TRANSBANKNAME, '' ) AS TRANSBANKNAME ,
  COALESCE(TRANSBANKREF, '' ) AS TRANSBANKREF ,
  COALESCE(ISTRANSMIT, '' ) AS ISTRANSMIT ,
  COALESCE(TRANSMITFLAG, '' ) AS TRANSMITFLAG ,
  COALESCE(TRANSMITBANKNO, '' ) AS TRANSMITBANKNO ,
  COALESCE(TRANSMITSWFCODE, '' ) AS TRANSMITSWFCODE ,
  COALESCE(TRANSMITBANKNAME, '' ) AS TRANSMITBANKNAME ,
  COALESCE(TRANSMITBANKSWFNO, '' ) AS TRANSMITBANKSWFNO ,
  COALESCE(PRESENTBANKNO, '' ) AS PRESENTBANKNO ,
  COALESCE(PRESENTBANKSWFCODE, '' ) AS PRESENTBANKSWFCODE ,
  COALESCE(PRESENTBANKNAME, '' ) AS PRESENTBANKNAME ,
  COALESCE(LCCUR, '' ) AS LCCUR ,
  COALESCE(LCAMT, 0 ) AS LCAMT ,
  COALESCE(LCAMTBAL, 0 ) AS LCAMTBAL ,
  COALESCE(LCAMTTOLERUP, 0 ) AS LCAMTTOLERUP ,
  COALESCE(LCAMTTOLERDOWN, 0 ) AS LCAMTTOLERDOWN ,
  COALESCE(LCMAXAMT, 0 ) AS LCMAXAMT ,
  COALESCE(LCMINAMT, 0 ) AS LCMINAMT ,
  COALESCE(ISSUEMODE, '' ) AS ISSUEMODE ,
  COALESCE(ISLCRET, '' ) AS ISLCRET ,
  COALESCE(INSTRUCTION, '' ) AS INSTRUCTION ,
  COALESCE(COUNTRYCODE, '' ) AS COUNTRYCODE ,
  COALESCE(NEGTYPE, '' ) AS NEGTYPE ,
  COALESCE(NEGBANKNO, '' ) AS NEGBANKNO ,
  COALESCE(NEGBANKSWFCODE, '' ) AS NEGBANKSWFCODE ,
  COALESCE(NEGBANKNAMEADDR, '' ) AS NEGBANKNAMEADDR ,
  COALESCE(PRESENTPERIOD, 0 ) AS PRESENTPERIOD ,
  COALESCE(EXPIRYPLACE, '' ) AS EXPIRYPLACE ,
  COALESCE(LCAVAILTYPE, '' ) AS LCAVAILTYPE ,
  COALESCE(ISMIXEDPAY, '' ) AS ISMIXEDPAY ,
  COALESCE(MIXEDPAYDETAILS, '' ) AS MIXEDPAYDETAILS ,
  COALESCE(ISPARTIALSHPTS, '' ) AS ISPARTIALSHPTS ,
  COALESCE(ISTRANSHIPMENT, '' ) AS ISTRANSHIPMENT ,
  COALESCE(ADDITIONALAMT, '' ) AS ADDITIONALAMT ,
  COALESCE(COMMODITY, '' ) AS COMMODITY ,
  COALESCE(AMENDDETAILS, '' ) AS AMENDDETAILS ,
  COALESCE(MODIFYLCDATE,DATE('4999-12-31') ) AS MODIFYLCDATE ,
  COALESCE(MODIFYDEGREE, 0 ) AS MODIFYDEGREE ,
  COALESCE(MODIFYAMTFLAG, '' ) AS MODIFYAMTFLAG ,
  COALESCE(MODIFYCUR, '' ) AS MODIFYCUR ,
  COALESCE(MODIFYAMT, 0 ) AS MODIFYAMT ,
  COALESCE(CANCELDATE,DATE('4999-12-31') ) AS CANCELDATE ,
  COALESCE(CANCELLC, '' ) AS CANCELLC ,
  COALESCE(OPTYPE, '' ) AS OPTYPE ,
  COALESCE(MODIFYTYPE, '' ) AS MODIFYTYPE ,
  COALESCE(REVOLVETYPE, '' ) AS REVOLVETYPE ,
  COALESCE(NEGDEGREE, 0 ) AS NEGDEGREE ,
  COALESCE(NEGCUR, '' ) AS NEGCUR ,
  COALESCE(SUMAMT, 0 ) AS SUMAMT ,
  COALESCE(NEGAMT, 0 ) AS NEGAMT ,
  COALESCE(TRANSMITDATE,DATE('4999-12-31') ) AS TRANSMITDATE ,
  COALESCE(TRANSMITVIA, '' ) AS TRANSMITVIA ,
  COALESCE(TRANSTHRUBANKNO, '' ) AS TRANSTHRUBANKNO ,
  COALESCE(TRANSTHRUBANKSWF, '' ) AS TRANSTHRUBANKSWF ,
  COALESCE(TRANSTHRUBANKNAME, '' ) AS TRANSTHRUBANKNAME ,
  COALESCE(AMENDCONFIRM, '' ) AS AMENDCONFIRM ,
  COALESCE(DEFPAYMENTDETAILS, '' ) AS DEFPAYMENTDETAILS ,
  COALESCE(DRAWEEBANKNO, '' ) AS DRAWEEBANKNO ,
  COALESCE(DRAWEEBANKNAME, '' ) AS DRAWEEBANKNAME ,
  COALESCE(DRAWEEBANKSWFCODE, '' ) AS DRAWEEBANKSWFCODE ,
  COALESCE(ISAGREE, '' ) AS ISAGREE ,
  COALESCE(RECVAMT, 0 ) AS RECVAMT ,
  COALESCE(BELONGORGNO, '' ) AS BELONGORGNO ,
  COALESCE(MANAGERID, '' ) AS MANAGERID ,
  COALESCE(TRADENO, '' ) AS TRADENO ,
  COALESCE(ISLG, '' ) AS ISLG ,
  COALESCE(NEWLCAMT, 0 ) AS NEWLCAMT ,
  COALESCE(OPPPARTYCLASS, '' ) AS OPPPARTYCLASS ,
  COALESCE(OPPNAME, '' ) AS OPPNAME ,
  COALESCE(INOUTAREA, '' ) AS INOUTAREA ,
  COALESCE(MAILBANKNO, '' ) AS MAILBANKNO ,
  COALESCE(MAILBANKSWFCODE, '' ) AS MAILBANKSWFCODE ,
  COALESCE(MAILBANKADDR, '' ) AS MAILBANKADDR ,
  COALESCE(LCMEMO, '' ) AS LCMEMO ,
  COALESCE(ISSUINGBANKMEMO, '' ) AS ISSUINGBANKMEMO ,
  COALESCE(CONFIRBANKMEMO, '' ) AS CONFIRBANKMEMO ,
  COALESCE(URFLAG, '' ) AS URFLAG ,
  COALESCE(ISCFM, '' ) AS ISCFM ,
  COALESCE(OUTACCTSERIALNO, '' ) AS OUTACCTSERIALNO ,
  COALESCE(CONSTRACTNO, '' ) AS CONSTRACTNO ,
  COALESCE(LCACCEPTAMT, 0 ) AS LCACCEPTAMT ,
  COALESCE(LCNOTPAYAMT, 0 ) AS LCNOTPAYAMT ,
  COALESCE(SECONDOPPNAME, '' ) AS SECONDOPPNAME ,
  COALESCE(SECONDAPPNAMEADDR, '' ) AS SECONDAPPNAMEADDR ,
  COALESCE(CANCELAPPPRE, '' ) AS CANCELAPPPRE ,
  COALESCE(LCAMTREPRESENT, '' ) AS LCAMTREPRESENT ,
  COALESCE(APPCANCELISSENDSWF, '' ) AS APPCANCELISSENDSWF ,
  COALESCE(NEG, '' ) AS NEG 
 FROM  dw_tdata.ISS_001_EX_ADVISSUEINFO_${TX_DATE_YYYYMMDD}) N
LEFT JOIN
 (SELECT 
  TXNSERIALNO ,
  BIZNO ,
  LCNO ,
  OLDTXNSERIALNO ,
  AMENDADVNO ,
  ISVALID ,
  ISSENDSWF ,
  SWIFTTYPE ,
  TESTSIGN ,
  SELFLC ,
  ISAGENT ,
  CHGUNDERTAKER ,
  AGENTBANKNO ,
  AGENTBANKSWFCODE ,
  AGENTBANKNAME ,
  ISSIMPLESWFLC ,
  LCFORM ,
  SDFLAG ,
  DRAFTDAYS ,
  DRAFTDAYSDESCR ,
  DRAFTDAYSTYPE ,
  SPECLC ,
  BENEFNO ,
  BENEFNAME ,
  ISSUINGDATE ,
  ADVDATE ,
  EXPIRYDATE ,
  LASTSHIPDATE ,
  AVAILABLEBY ,
  APPNO ,
  APPNAMEADDR ,
  ISSUINGBANKNO ,
  ISSUINGSWFCODE ,
  ISSUINGBANKNAME ,
  OLDISSUINGBANKNO ,
  OLDISSUINGBANKNAME ,
  ISCONFIRM ,
  CONFIRMINSTR ,
  CONFIRMBANKNO ,
  CONFIRBANKSWFCODE ,
  CONFIRMBANKNAME ,
  CONFIRMBANKREF ,
  REIMBBANKNO ,
  REIMBBANKSWFCODE ,
  REIMBBANK ,
  ISTRANS ,
  TRANSDEGREE ,
  TRANSAMT ,
  TRANSBANKNO ,
  TRANSBANKSWFCODE ,
  TRANSBANKNAME ,
  TRANSBANKREF ,
  ISTRANSMIT ,
  TRANSMITFLAG ,
  TRANSMITBANKNO ,
  TRANSMITSWFCODE ,
  TRANSMITBANKNAME ,
  TRANSMITBANKSWFNO ,
  PRESENTBANKNO ,
  PRESENTBANKSWFCODE ,
  PRESENTBANKNAME ,
  LCCUR ,
  LCAMT ,
  LCAMTBAL ,
  LCAMTTOLERUP ,
  LCAMTTOLERDOWN ,
  LCMAXAMT ,
  LCMINAMT ,
  ISSUEMODE ,
  ISLCRET ,
  INSTRUCTION ,
  COUNTRYCODE ,
  NEGTYPE ,
  NEGBANKNO ,
  NEGBANKSWFCODE ,
  NEGBANKNAMEADDR ,
  PRESENTPERIOD ,
  EXPIRYPLACE ,
  LCAVAILTYPE ,
  ISMIXEDPAY ,
  MIXEDPAYDETAILS ,
  ISPARTIALSHPTS ,
  ISTRANSHIPMENT ,
  ADDITIONALAMT ,
  COMMODITY ,
  AMENDDETAILS ,
  MODIFYLCDATE ,
  MODIFYDEGREE ,
  MODIFYAMTFLAG ,
  MODIFYCUR ,
  MODIFYAMT ,
  CANCELDATE ,
  CANCELLC ,
  OPTYPE ,
  MODIFYTYPE ,
  REVOLVETYPE ,
  NEGDEGREE ,
  NEGCUR ,
  SUMAMT ,
  NEGAMT ,
  TRANSMITDATE ,
  TRANSMITVIA ,
  TRANSTHRUBANKNO ,
  TRANSTHRUBANKSWF ,
  TRANSTHRUBANKNAME ,
  AMENDCONFIRM ,
  DEFPAYMENTDETAILS ,
  DRAWEEBANKNO ,
  DRAWEEBANKNAME ,
  DRAWEEBANKSWFCODE ,
  ISAGREE ,
  RECVAMT ,
  BELONGORGNO ,
  MANAGERID ,
  TRADENO ,
  ISLG ,
  NEWLCAMT ,
  OPPPARTYCLASS ,
  OPPNAME ,
  INOUTAREA ,
  MAILBANKNO ,
  MAILBANKSWFCODE ,
  MAILBANKADDR ,
  LCMEMO ,
  ISSUINGBANKMEMO ,
  CONFIRBANKMEMO ,
  URFLAG ,
  ISCFM ,
  OUTACCTSERIALNO ,
  CONSTRACTNO ,
  LCACCEPTAMT ,
  LCNOTPAYAMT ,
  SECONDOPPNAME ,
  SECONDAPPNAMEADDR ,
  CANCELAPPPRE ,
  LCAMTREPRESENT ,
  APPCANCELISSENDSWF ,
  NEG 
 FROM dw_sdata.ISS_001_EX_ADVISSUEINFO 
 WHERE END_DT = DATE('2100-12-31') ) T
ON N.BIZNO = T.BIZNO
WHERE
(T.BIZNO IS NULL)
 OR N.TXNSERIALNO<>T.TXNSERIALNO
 OR N.LCNO<>T.LCNO
 OR N.OLDTXNSERIALNO<>T.OLDTXNSERIALNO
 OR N.AMENDADVNO<>T.AMENDADVNO
 OR N.ISVALID<>T.ISVALID
 OR N.ISSENDSWF<>T.ISSENDSWF
 OR N.SWIFTTYPE<>T.SWIFTTYPE
 OR N.TESTSIGN<>T.TESTSIGN
 OR N.SELFLC<>T.SELFLC
 OR N.ISAGENT<>T.ISAGENT
 OR N.CHGUNDERTAKER<>T.CHGUNDERTAKER
 OR N.AGENTBANKNO<>T.AGENTBANKNO
 OR N.AGENTBANKSWFCODE<>T.AGENTBANKSWFCODE
 OR N.AGENTBANKNAME<>T.AGENTBANKNAME
 OR N.ISSIMPLESWFLC<>T.ISSIMPLESWFLC
 OR N.LCFORM<>T.LCFORM
 OR N.SDFLAG<>T.SDFLAG
 OR N.DRAFTDAYS<>T.DRAFTDAYS
 OR N.DRAFTDAYSDESCR<>T.DRAFTDAYSDESCR
 OR N.DRAFTDAYSTYPE<>T.DRAFTDAYSTYPE
 OR N.SPECLC<>T.SPECLC
 OR N.BENEFNO<>T.BENEFNO
 OR N.BENEFNAME<>T.BENEFNAME
 OR N.ISSUINGDATE<>T.ISSUINGDATE
 OR N.ADVDATE<>T.ADVDATE
 OR N.EXPIRYDATE<>T.EXPIRYDATE
 OR N.LASTSHIPDATE<>T.LASTSHIPDATE
 OR N.AVAILABLEBY<>T.AVAILABLEBY
 OR N.APPNO<>T.APPNO
 OR N.APPNAMEADDR<>T.APPNAMEADDR
 OR N.ISSUINGBANKNO<>T.ISSUINGBANKNO
 OR N.ISSUINGSWFCODE<>T.ISSUINGSWFCODE
 OR N.ISSUINGBANKNAME<>T.ISSUINGBANKNAME
 OR N.OLDISSUINGBANKNO<>T.OLDISSUINGBANKNO
 OR N.OLDISSUINGBANKNAME<>T.OLDISSUINGBANKNAME
 OR N.ISCONFIRM<>T.ISCONFIRM
 OR N.CONFIRMINSTR<>T.CONFIRMINSTR
 OR N.CONFIRMBANKNO<>T.CONFIRMBANKNO
 OR N.CONFIRBANKSWFCODE<>T.CONFIRBANKSWFCODE
 OR N.CONFIRMBANKNAME<>T.CONFIRMBANKNAME
 OR N.CONFIRMBANKREF<>T.CONFIRMBANKREF
 OR N.REIMBBANKNO<>T.REIMBBANKNO
 OR N.REIMBBANKSWFCODE<>T.REIMBBANKSWFCODE
 OR N.REIMBBANK<>T.REIMBBANK
 OR N.ISTRANS<>T.ISTRANS
 OR N.TRANSDEGREE<>T.TRANSDEGREE
 OR N.TRANSAMT<>T.TRANSAMT
 OR N.TRANSBANKNO<>T.TRANSBANKNO
 OR N.TRANSBANKSWFCODE<>T.TRANSBANKSWFCODE
 OR N.TRANSBANKNAME<>T.TRANSBANKNAME
 OR N.TRANSBANKREF<>T.TRANSBANKREF
 OR N.ISTRANSMIT<>T.ISTRANSMIT
 OR N.TRANSMITFLAG<>T.TRANSMITFLAG
 OR N.TRANSMITBANKNO<>T.TRANSMITBANKNO
 OR N.TRANSMITSWFCODE<>T.TRANSMITSWFCODE
 OR N.TRANSMITBANKNAME<>T.TRANSMITBANKNAME
 OR N.TRANSMITBANKSWFNO<>T.TRANSMITBANKSWFNO
 OR N.PRESENTBANKNO<>T.PRESENTBANKNO
 OR N.PRESENTBANKSWFCODE<>T.PRESENTBANKSWFCODE
 OR N.PRESENTBANKNAME<>T.PRESENTBANKNAME
 OR N.LCCUR<>T.LCCUR
 OR N.LCAMT<>T.LCAMT
 OR N.LCAMTBAL<>T.LCAMTBAL
 OR N.LCAMTTOLERUP<>T.LCAMTTOLERUP
 OR N.LCAMTTOLERDOWN<>T.LCAMTTOLERDOWN
 OR N.LCMAXAMT<>T.LCMAXAMT
 OR N.LCMINAMT<>T.LCMINAMT
 OR N.ISSUEMODE<>T.ISSUEMODE
 OR N.ISLCRET<>T.ISLCRET
 OR N.INSTRUCTION<>T.INSTRUCTION
 OR N.COUNTRYCODE<>T.COUNTRYCODE
 OR N.NEGTYPE<>T.NEGTYPE
 OR N.NEGBANKNO<>T.NEGBANKNO
 OR N.NEGBANKSWFCODE<>T.NEGBANKSWFCODE
 OR N.NEGBANKNAMEADDR<>T.NEGBANKNAMEADDR
 OR N.PRESENTPERIOD<>T.PRESENTPERIOD
 OR N.EXPIRYPLACE<>T.EXPIRYPLACE
 OR N.LCAVAILTYPE<>T.LCAVAILTYPE
 OR N.ISMIXEDPAY<>T.ISMIXEDPAY
 OR N.MIXEDPAYDETAILS<>T.MIXEDPAYDETAILS
 OR N.ISPARTIALSHPTS<>T.ISPARTIALSHPTS
 OR N.ISTRANSHIPMENT<>T.ISTRANSHIPMENT
 OR N.ADDITIONALAMT<>T.ADDITIONALAMT
 OR N.COMMODITY<>T.COMMODITY
 OR N.AMENDDETAILS<>T.AMENDDETAILS
 OR N.MODIFYLCDATE<>T.MODIFYLCDATE
 OR N.MODIFYDEGREE<>T.MODIFYDEGREE
 OR N.MODIFYAMTFLAG<>T.MODIFYAMTFLAG
 OR N.MODIFYCUR<>T.MODIFYCUR
 OR N.MODIFYAMT<>T.MODIFYAMT
 OR N.CANCELDATE<>T.CANCELDATE
 OR N.CANCELLC<>T.CANCELLC
 OR N.OPTYPE<>T.OPTYPE
 OR N.MODIFYTYPE<>T.MODIFYTYPE
 OR N.REVOLVETYPE<>T.REVOLVETYPE
 OR N.NEGDEGREE<>T.NEGDEGREE
 OR N.NEGCUR<>T.NEGCUR
 OR N.SUMAMT<>T.SUMAMT
 OR N.NEGAMT<>T.NEGAMT
 OR N.TRANSMITDATE<>T.TRANSMITDATE
 OR N.TRANSMITVIA<>T.TRANSMITVIA
 OR N.TRANSTHRUBANKNO<>T.TRANSTHRUBANKNO
 OR N.TRANSTHRUBANKSWF<>T.TRANSTHRUBANKSWF
 OR N.TRANSTHRUBANKNAME<>T.TRANSTHRUBANKNAME
 OR N.AMENDCONFIRM<>T.AMENDCONFIRM
 OR N.DEFPAYMENTDETAILS<>T.DEFPAYMENTDETAILS
 OR N.DRAWEEBANKNO<>T.DRAWEEBANKNO
 OR N.DRAWEEBANKNAME<>T.DRAWEEBANKNAME
 OR N.DRAWEEBANKSWFCODE<>T.DRAWEEBANKSWFCODE
 OR N.ISAGREE<>T.ISAGREE
 OR N.RECVAMT<>T.RECVAMT
 OR N.BELONGORGNO<>T.BELONGORGNO
 OR N.MANAGERID<>T.MANAGERID
 OR N.TRADENO<>T.TRADENO
 OR N.ISLG<>T.ISLG
 OR N.NEWLCAMT<>T.NEWLCAMT
 OR N.OPPPARTYCLASS<>T.OPPPARTYCLASS
 OR N.OPPNAME<>T.OPPNAME
 OR N.INOUTAREA<>T.INOUTAREA
 OR N.MAILBANKNO<>T.MAILBANKNO
 OR N.MAILBANKSWFCODE<>T.MAILBANKSWFCODE
 OR N.MAILBANKADDR<>T.MAILBANKADDR
 OR N.LCMEMO<>T.LCMEMO
 OR N.ISSUINGBANKMEMO<>T.ISSUINGBANKMEMO
 OR N.CONFIRBANKMEMO<>T.CONFIRBANKMEMO
 OR N.URFLAG<>T.URFLAG
 OR N.ISCFM<>T.ISCFM
 OR N.OUTACCTSERIALNO<>T.OUTACCTSERIALNO
 OR N.CONSTRACTNO<>T.CONSTRACTNO
 OR N.LCACCEPTAMT<>T.LCACCEPTAMT
 OR N.LCNOTPAYAMT<>T.LCNOTPAYAMT
 OR N.SECONDOPPNAME<>T.SECONDOPPNAME
 OR N.SECONDAPPNAMEADDR<>T.SECONDAPPNAMEADDR
 OR N.CANCELAPPPRE<>T.CANCELAPPPRE
 OR N.LCAMTREPRESENT<>T.LCAMTREPRESENT
 OR N.APPCANCELISSENDSWF<>T.APPCANCELISSENDSWF
 OR N.NEG<>T.NEG
;

--Step3:
UPDATE dw_sdata.ISS_001_EX_ADVISSUEINFO P 
SET End_Dt=DATE('${TX_DATE_YYYYMMDD}')
FROM T_233
WHERE P.End_Dt=DATE('2100-12-31')
AND P.BIZNO=T_233.BIZNO
;

--Step4:
INSERT  INTO dw_sdata.ISS_001_EX_ADVISSUEINFO SELECT * FROM T_233;

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