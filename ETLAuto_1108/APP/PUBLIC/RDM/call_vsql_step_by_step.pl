#!/usr/bin/perl
#####################################################################
# Program : ͨ��vsql����SQL�ű�ģ��(��ִ��,֧��TD��BTEQ���ߵ�.IF ActivityCount <= 0 THEN .GOTO LABEL_NAME; && .LABEL LABEL_NAME �﷨)
# Author  : wuzhg@teamsun.com.cn
# Date Time    :  2016/06/03
# Script File  :  call_vsql_step_by_step.pl
#====================================================================
# �޸���ʷ:
#
# ###################################################################
use strict;
use bdp_pub;

my $PROJECT_CD = 'FDM';          #��Ŀ����
my $VSQL_CFG_NAME = 'FDM_VSQL';  #app_config.ini��VSQL�������õ����� 

if ( $#ARGV < 0 or $ARGV[0] !~ /^(.{3})_.{3}_(\d{2,4})_(.*)_(\d{8}).dir$/) {
   print "\n";
   print "Usage: $0  \n";
   print "Usage: ʹ�ò��� \n";
   print "       CONTROL_FILE  -- �����ļ�(SYS_JOBNAME_YYYYMMDD.dir) \n";
   exit(1);
}

open(STDERR, ">&STDOUT");

my $CtrlInfo = BDP::parseDirInfo($ARGV[0]);

my $sqlfile = $ARGV[0];
$sqlfile =~ s/_\d{8}.dir$/.sql/;
$sqlfile = substr($sqlfile, 4);

my $runSql = BDP::getSqlFileTxt($PROJECT_CD);
exit 1 if($runSql == -1);

unless(-d "${BDP::AUTO_HOME}/tmp/RUNSQL/$CtrlInfo->{SYS}") {
   `mkdir -p ${BDP::AUTO_HOME}/tmp/RUNSQL/$CtrlInfo->{SYS}`;
}

my $FH;
open($FH,">${BDP::AUTO_HOME}/tmp/RUNSQL/$CtrlInfo->{SYS}/$sqlfile");
unless($FH) {
   print "Create ${BDP::AUTO_HOME}/tmp/RUNSQL/$CtrlInfo->{SYS}/$sqlfile failed.\n";
   exit 1;
}
print $FH "\\timing\n";
print $FH $$runSql;
print $FH "\ncommit;\n";
close($FH);

my $ret = BDP::runVsqlCommand2($VSQL_CFG_NAME, $runSql);

exit($ret->{RetCode});
