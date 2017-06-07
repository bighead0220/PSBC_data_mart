#!/usr/bin/perl
#####################################################################
# Program :  
# Author  :  
# Date Time :
# Script File  : 
#====================================================================
# �޸���ʷ:
#
# ###################################################################
use strict;
use bdp_pub;
use Time::localtime;
use Time::Local;
use IPC::Open3;
use etl_unix;

my $PROJECT_CD = 'FDM';          #��Ŀ����
my $VSQL_CFG_NAME = 'FDM_VSQL';  #app_config.ini��VSQL�������õ����� 

if ( $#ARGV < 0 or $ARGV[0] !~ /^(.{3})_.{3}_(\d{2,4})_(.*)_(\d{8}).dir$/) {
   print "\n";
   print "Usage: $0  \n";
   print "Usage: ʹ�ò��� \n";
   print "       CONTROL_FILE  -- �����ļ�(SYS_JOBNAME_YYYYMMDD.dir) \n";
   exit(1);
}
my %Macro;
open(STDERR, ">&STDOUT");
my $CtrlInfo = BDP::parseDirInfo($ARGV[0]);

my $sqlfile = $ARGV[0];
$sqlfile =~ s/_\d{8}.dir$/.sql/;
$sqlfile = substr($sqlfile, 4);

my $runSql = getSqlFileTxt($PROJECT_CD);
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
#my $job_name=lc($CtrlInfo->{SUBJOBNAME});

$Macro{'$file_name'}=~ s/YYYYMMDD/$CtrlInfo->{TXDATE}/;
my $ret=system("curl -l -s -i \"http://$Macro{'$hadoop_namenode_id1'}:50070/webhdfs/v1/$Macro{'$path2'}/$Macro{'$file_name'}.ok?op=LISTSTATUS\" ");
if ($ret != 0){
   while(1){#�ж�ok�ļ��Ƿ񵽴�
   my $result = `curl -l -s -i "http://$Macro{'$hadoop_namenode_id2'}:50070/webhdfs/v1/$Macro{'$path2'}/$Macro{'$file_name'}.ok?op=LISTSTATUS" | grep HTTP`;
   print "result : $result \n";
   if ($result =~ /200|OK/ ) {
         `sed -i 's/\$hadoop_namenode_id/$Macro{'$hadoop_namenode_id2'}/' ${BDP::AUTO_HOME}/tmp/RUNSQL/$CtrlInfo->{SYS}/$sqlfile`;
         last;
         }
   print "OK�ļ�[ $CtrlInfo->{SUBJOBNAME}.ok ]δ���� Waiting ...30s \n";
   sleep 5;
        }
}else {
   while(1){#�ж�ok�ļ��Ƿ񵽴�
   my $result = `curl -l -s -i "http://$Macro{'$hadoop_namenode_id1'}:50070/webhdfs/v1/$Macro{'$path2'}/$Macro{'$file_name'}.ok?op=LISTSTATUS" | grep HTTP`;
   print "*************$Macro{'$file_name'}*********\n";
   if ($result =~ /200|OK/ ) {
         `sed -i 's/\$hadoop_namenode_id/$Macro{'$hadoop_namenode_id1'}/' ${BDP::AUTO_HOME}/tmp/RUNSQL/$CtrlInfo->{SYS}/$sqlfile`;
         last;
         }
   print "OK�ļ�[ $CtrlInfo->{SUBJOBNAME}.ok ]δ���� Waiting ...30s \n";
   sleep 5;
       }
}

#ȥ���س����з���

my $ret = BDP::runVsqlCommand($VSQL_CFG_NAME, "${BDP::AUTO_HOME}/tmp/RUNSQL/$CtrlInfo->{SYS}/$sqlfile");

exit($ret);

#===================================================
#���ݿ����ļ�,��ȡ��Ӧ��sql�ļ�����
#===================================================
sub getSqlFileTxt {
   my $PROJECT_CD = shift;
   
   my $fname = $ARGV[0]; #�����ļ���
   my $r = BDP::parseDirInfo($fname);

   $fname = "${BDP::AUTO_HOME}/APP/SQLSCRIPT/$r->{SYS}/" . lc($r->{SUBJOBNAME}) . '.sql';
   
   print " fname = $fname \n";   

   unless(open(FS,$fname)) {
      print "cann't open sql file $fname $!\n";
      return -1;  
   }

   my $str;
   my $len = 1024 * 1024 * 10;
   read(FS,$str,$len);
   close(FS);

   #��ȡunload.ini�еı���
   my $cfg_unload = "${BDP::AUTO_HOME}/etc/FDM_unload.ini";
   my %Files = &GetConfigs($cfg_unload,'ADM');

   
   #��ȡapp_config.ini��SQL����
   my $para = ETL::getAppParameters("PUBLIC_SQL_VARS");
   foreach (@$para) {
      $Macro{"\$${_}"} = ETL::getAppConfig("PUBLIC_SQL_VARS", $_);
   }
   
   $para = ETL::getAppParameters("${PROJECT_CD}_SQL_VARS");
   foreach (@$para) {
      $Macro{"\$${_}"} = ETL::getAppConfig("${PROJECT_CD}_SQL_VARS", $_);
   }
   
   #print Dumper(%Macro);

   #������صı���
   $Macro{'$SYS'}     = $r->{SYS};                       #��ҵϵͳ��
   $Macro{'$PROV'}    = $r->{PROV};                      #ʡ��/ҵ�����(��λ����λ����)
   $Macro{'$TXDATE'}  = $r->{TXDATE};                    #��������/ͳ������
   $Macro{'$JOBNAME'} = $r->{JOBNAME};                   #��������ҵ����,���� SAV_44_AGREEMENT_INI
   $Macro{'$SUBJOBNAME'} = $r->{SUBJOBNAME};             #��������ҵ����ʡ�ݴ������Ĳ���,���� AGREEMENT_INI
   
   $Macro{'$YESTERDAY'}  = BDP::decDate($r->{TXDATE},-1);    #��������/ͳ������($TXDATE)֮ǰ��һ��
   $Macro{'$NEXTDAY'}    = BDP::decDate($r->{TXDATE}, 1);    #��������/ͳ������($TXDATE)֮���һ��

   my $tmpPeriodDay=BDP::getPeriodDay($r->{TXDATE});
   $Macro{'$PERIODBGNDAY'} = $$tmpPeriodDay[0];      #���ݽ�������ȡ����Ѯ�ĵ�һ��
   $Macro{'$PERIODENDDAY'} = $$tmpPeriodDay[1];      #���ݽ�������ȡ����Ѯ�����һ��
   $Macro{'$PERIODNO'}     = $$tmpPeriodDay[2];      #���ݽ�������ȡ����Ѯ�����20060101/20060102/20060102

   my $tmpMonthDay=BDP::getMonthDay($r->{TXDATE});
   $Macro{'$MONTHBGNDAY'} = $$tmpMonthDay[0];        #���ݽ�������ȡ�µĵ�һ��
   $Macro{'$MONTHENDDAY'} = $$tmpMonthDay[1];        #���ݽ�������ȡ�µ����һ��
   $Macro{'$MONTHNO'}     = $$tmpMonthDay[2];        #���ݽ�������ȡ��200601/200602/200603

   my $tmpSeasonDay=BDP::getSeasonDay($r->{TXDATE});
   $Macro{'$SEASONBGNDAY'} = $$tmpSeasonDay[0];      #���ݽ�������ȡ���ȵĵ�һ��
   $Macro{'$SEASONENDDAY'} = $$tmpSeasonDay[1];      #���ݽ�������ȡ���ȵ����һ��
   $Macro{'$SEASONNO'}     = $$tmpSeasonDay[2];      #���ݽ�������ȡ����200601/200602/200603/200604

   my $tmpYearDay=BDP::getYearDay($r->{TXDATE});
   $Macro{'$YEARBGNDAY'} = $$tmpYearDay[0];          #���ݽ�������ȡ��ĵ�һ��
   $Macro{'$YEARENDDAY'} = $$tmpYearDay[1];          #���ݽ�������ȡ������һ��
   $Macro{'$YEARNO'}     = $$tmpYearDay[2];          #���ݽ�������ȡ��2006

   #�滻sqL ��
   $Macro{'$table_name'} = $r->{SUBJOBNAME};


   $Macro{'$file_name'} = $Files{lc($r->{SUBJOBNAME})};
   $Macro{'YYYYMMDD'}  = $r->{TXDATE};
   #��sql�ļ��б�����Ϣ���м����滻
   my $tmp;
   foreach (sort{length($b) <=> length($a)} keys %Macro) {
      $tmp = quotemeta($_);
      $str =~ s/$tmp/$Macro{$_}/gi;
   }
   #print " $r->{TXDATE}    =     $Macro{'$MONTHENDDAY'} \n";  
  # ������Ƶ��  
   print "This is a Month job running with date[$r->{TXDATE}] Exit! \n"  if $r->{TXDATE} ne $Macro{'$MONTHENDDAY'} ;
   exit 0 if $r->{TXDATE} ne $Macro{'$MONTHENDDAY'} ;
   
   return \$str;
}

#----------------------------------------------------
#����: GetConfigs()
#˵��:
#���: �����ļ�  �����ļ��йؼ�������
#����: ��ȷ:0 ����: 1 
#----------------------------------------------------

sub GetConfigs {
		 
    my ($g_cfgs,$key) = @_ ;
    if (!-e "$g_cfgs") {
    	  #my $time = getTime("YYYY-MM-DD HH:MI:SS");
        print "[ time] �Ҳ��������ļ� [$g_cfgs] \n";
        exit(1);
    }
    my $g_config = Config::IniFiles->new( -file => "$g_cfgs");
    if (!$g_config) {
    	  #my $time = getTime("YYYY-MM-DD HH:MI:SS");
        print "[ time] �������ļ�[$g_cfgs]ʧ�� ! $! \n";
        exit(1);
    } 
   my %hash = IniToHash($g_config, $key);      
   %hash ; 
}
#----------------------------------------------------
#����: IniToHash()
#˵��:
#���: ��ini�ļ�תhash
#����: ��ȷ:0 ����: 1 
#----------------------------------------------------
sub IniToHash {

    my $ini = $_[0];
    my @para = $ini->Parameters($_[1]);
    my %hash_val;

    foreach  (@para) {
        $hash_val{$_} = ForceDel($ini->val($_[1], $_));
    }

    return %hash_val;
}
#----------------------------------------------------
#����: ForceDel()
#˵��: ȥ�ո�
#���: 
#����: ��ȷ:0 ����: 1 
#----------------------------------------------------
sub ForceDel {

    defined $_[0] or return '';

    $_[0] =~ s/\s+//g;
    return $_[0];
}
