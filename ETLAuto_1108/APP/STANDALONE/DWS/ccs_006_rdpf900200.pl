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
DELETE FROM dw_sdata.CCS_006_RDPF90 WHERE start_dt>=DATE('${TX_DATE_YYYYMMDD}');
UPDATE dw_sdata.CCS_006_RDPF90 SET end_dt=DATE('2100-12-31') WHERE end_dt>=DATE('${TX_DATE_YYYYMMDD}') AND end_dt<>DATE('2100-12-31');

--Step1:
CREATE LOCAL TEMPORARY TABLE  T_144 ON COMMIT PRESERVE ROWS AS SELECT * FROM dw_sdata.CCS_006_RDPF90 WHERE 1=0;

--Step2:
INSERT  INTO T_144 (
  RD90PRE,
  RD90DPNOK,
  RD90DPNOA,
  RD90DATE,
  RD90LNCATG,
  RD90DUEBNO,
  RD90NAME,
  RD90CACNT,
  RD90LNCLS,
  RD90TRFROM,
  RD90DATEB,
  RD90DATEE,
  RD90PAYCHA,
  RD90PAYFLG,
  RD90PAYACC,
  RD90CUR,
  RD90AMTPOR,
  RD90AMTAOR,
  RD90TAMTAR,
  RD90AMTAPR,
  RD90BAMTAR,
  RD90OAMTAR,
  RD90CAMTAR,
  RD90AAHK,
  RD90HXBJ,
  RD90HXLX,
  RD90HXSH1,
  RD90HXSH2,
  RD90AMT1,
  RD90AMT2,
  RD90BZ,
  RD90OPR,
  RD90STAN,
  start_dt,
  end_dt)
SELECT
  N.RD90PRE,
  N.RD90DPNOK,
  N.RD90DPNOA,
  N.RD90DATE,
  N.RD90LNCATG,
  N.RD90DUEBNO,
  N.RD90NAME,
  N.RD90CACNT,
  N.RD90LNCLS,
  N.RD90TRFROM,
  N.RD90DATEB,
  N.RD90DATEE,
  N.RD90PAYCHA,
  N.RD90PAYFLG,
  N.RD90PAYACC,
  N.RD90CUR,
  N.RD90AMTPOR,
  N.RD90AMTAOR,
  N.RD90TAMTAR,
  N.RD90AMTAPR,
  N.RD90BAMTAR,
  N.RD90OAMTAR,
  N.RD90CAMTAR,
  N.RD90AAHK,
  N.RD90HXBJ,
  N.RD90HXLX,
  N.RD90HXSH1,
  N.RD90HXSH2,
  N.RD90AMT1,
  N.RD90AMT2,
  N.RD90BZ,
  N.RD90OPR,
  N.RD90STAN,
  DATE('${TX_DATE_YYYYMMDD}'),
  DATE('2100-12-31')
FROM 
 (SELECT
  COALESCE(RD90PRE, '' ) AS RD90PRE ,
  COALESCE(RD90DPNOK, '' ) AS RD90DPNOK ,
  COALESCE(RD90DPNOA, '' ) AS RD90DPNOA ,
  COALESCE(RD90DATE, '' ) AS RD90DATE ,
  COALESCE(RD90LNCATG, '' ) AS RD90LNCATG ,
  COALESCE(RD90DUEBNO, '' ) AS RD90DUEBNO ,
  COALESCE(RD90NAME, '' ) AS RD90NAME ,
  COALESCE(RD90CACNT, 0 ) AS RD90CACNT ,
  COALESCE(RD90LNCLS, '' ) AS RD90LNCLS ,
  COALESCE(RD90TRFROM, '' ) AS RD90TRFROM ,
  COALESCE(RD90DATEB, '' ) AS RD90DATEB ,
  COALESCE(RD90DATEE, '' ) AS RD90DATEE ,
  COALESCE(RD90PAYCHA, '' ) AS RD90PAYCHA ,
  COALESCE(RD90PAYFLG, '' ) AS RD90PAYFLG ,
  COALESCE(RD90PAYACC, '' ) AS RD90PAYACC ,
  COALESCE(RD90CUR, '' ) AS RD90CUR ,
  COALESCE(RD90AMTPOR, 0 ) AS RD90AMTPOR ,
  COALESCE(RD90AMTAOR, 0 ) AS RD90AMTAOR ,
  COALESCE(RD90TAMTAR, 0 ) AS RD90TAMTAR ,
  COALESCE(RD90AMTAPR, 0 ) AS RD90AMTAPR ,
  COALESCE(RD90BAMTAR, 0 ) AS RD90BAMTAR ,
  COALESCE(RD90OAMTAR, 0 ) AS RD90OAMTAR ,
  COALESCE(RD90CAMTAR, 0 ) AS RD90CAMTAR ,
  COALESCE(RD90AAHK, 0 ) AS RD90AAHK ,
  COALESCE(RD90HXBJ, 0 ) AS RD90HXBJ ,
  COALESCE(RD90HXLX, 0 ) AS RD90HXLX ,
  COALESCE(RD90HXSH1, 0 ) AS RD90HXSH1 ,
  COALESCE(RD90HXSH2, 0 ) AS RD90HXSH2 ,
  COALESCE(RD90AMT1, 0 ) AS RD90AMT1 ,
  COALESCE(RD90AMT2, 0 ) AS RD90AMT2 ,
  COALESCE(RD90BZ, '' ) AS RD90BZ ,
  COALESCE(RD90OPR, '' ) AS RD90OPR ,
  COALESCE(RD90STAN, 0 ) AS RD90STAN 
 FROM  dw_tdata.CCS_006_RDPF90_${TX_DATE_YYYYMMDD}) N
LEFT JOIN
 (SELECT 
  RD90PRE ,
  RD90DPNOK ,
  RD90DPNOA ,
  RD90DATE ,
  RD90LNCATG ,
  RD90DUEBNO ,
  RD90NAME ,
  RD90CACNT ,
  RD90LNCLS ,
  RD90TRFROM ,
  RD90DATEB ,
  RD90DATEE ,
  RD90PAYCHA ,
  RD90PAYFLG ,
  RD90PAYACC ,
  RD90CUR ,
  RD90AMTPOR ,
  RD90AMTAOR ,
  RD90TAMTAR ,
  RD90AMTAPR ,
  RD90BAMTAR ,
  RD90OAMTAR ,
  RD90CAMTAR ,
  RD90AAHK ,
  RD90HXBJ ,
  RD90HXLX ,
  RD90HXSH1 ,
  RD90HXSH2 ,
  RD90AMT1 ,
  RD90AMT2 ,
  RD90BZ ,
  RD90OPR ,
  RD90STAN 
 FROM dw_sdata.CCS_006_RDPF90 
 WHERE END_DT = DATE('2100-12-31') ) T
ON N.RD90DATE = T.RD90DATE AND N.RD90DUEBNO = T.RD90DUEBNO
WHERE
(T.RD90DATE IS NULL AND T.RD90DUEBNO IS NULL)
 OR N.RD90PRE<>T.RD90PRE
 OR N.RD90DPNOK<>T.RD90DPNOK
 OR N.RD90DPNOA<>T.RD90DPNOA
 OR N.RD90LNCATG<>T.RD90LNCATG
 OR N.RD90NAME<>T.RD90NAME
 OR N.RD90CACNT<>T.RD90CACNT
 OR N.RD90LNCLS<>T.RD90LNCLS
 OR N.RD90TRFROM<>T.RD90TRFROM
 OR N.RD90DATEB<>T.RD90DATEB
 OR N.RD90DATEE<>T.RD90DATEE
 OR N.RD90PAYCHA<>T.RD90PAYCHA
 OR N.RD90PAYFLG<>T.RD90PAYFLG
 OR N.RD90PAYACC<>T.RD90PAYACC
 OR N.RD90CUR<>T.RD90CUR
 OR N.RD90AMTPOR<>T.RD90AMTPOR
 OR N.RD90AMTAOR<>T.RD90AMTAOR
 OR N.RD90TAMTAR<>T.RD90TAMTAR
 OR N.RD90AMTAPR<>T.RD90AMTAPR
 OR N.RD90BAMTAR<>T.RD90BAMTAR
 OR N.RD90OAMTAR<>T.RD90OAMTAR
 OR N.RD90CAMTAR<>T.RD90CAMTAR
 OR N.RD90AAHK<>T.RD90AAHK
 OR N.RD90HXBJ<>T.RD90HXBJ
 OR N.RD90HXLX<>T.RD90HXLX
 OR N.RD90HXSH1<>T.RD90HXSH1
 OR N.RD90HXSH2<>T.RD90HXSH2
 OR N.RD90AMT1<>T.RD90AMT1
 OR N.RD90AMT2<>T.RD90AMT2
 OR N.RD90BZ<>T.RD90BZ
 OR N.RD90OPR<>T.RD90OPR
 OR N.RD90STAN<>T.RD90STAN
;

--Step3:
UPDATE dw_sdata.CCS_006_RDPF90 P 
SET End_Dt=DATE('${TX_DATE_YYYYMMDD}')
FROM T_144
WHERE P.End_Dt=DATE('2100-12-31')
AND P.RD90DATE=T_144.RD90DATE
AND P.RD90DUEBNO=T_144.RD90DUEBNO
;

--Step4:
INSERT  INTO dw_sdata.CCS_006_RDPF90 SELECT * FROM T_144;

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