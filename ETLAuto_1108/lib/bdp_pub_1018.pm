##############################################
# Program : ������ƽ̨�õ��Ĺ�������
# Author  : wuzhg@teamsun.com.cn
# Date Time    :  2016/06/03
# Script File  :  bdp_pub.pm
# ˵����
# Modify Info:
#    2016/6/3 ��ʼ�汾
#    2016/7/9 �޸�runVsqlCommand2������ʱʱ����8Сʱ��Ϊ4Сʱ
#             ����SQL�����Hint��ʾ,����INSERT/UPDATE/DELETEǿ�Ƽ���/*+ DIRECT */��ʾ
#    2016/8/25 ����vsqlִ�й����еĴ������,����������������ֵת��
##############################################
package BDP;

#���õİ�
use strict;
use DBI;
use Time::localtime;
use Time::Local;
use IPC::Open3;
use etl_unix;
#use Data::Dumper;

#��������,�� ~/.bash_profile �ļ��ж���
$BDP::AUTO_HOME = $ENV{'AUTO_HOME'};

my %Macro;

#==================================================================
#�ж��Ƿ�������
#���������򷵻� 1 ���򷵻� 0
#�������Ϣǰ��λһ������
#==================================================================
sub isYeapYear{
   my $tmpYear="$_[0]";

   $tmpYear=int(substr($tmpYear,0,4));

   return (($tmpYear % 4 eq 0 && $tmpYear % 100 ne 0) || $tmpYear % 400 eq 0) ? 1 : 0;
}


#��������($date)����������֮��Ĳ�ֵ($count),�����µ�����
sub decDate {
   my ($date,$count) = @_;
      
   return ETL::addDeltaDays($date, $count);
}


#==================================================================
#����dir�����ļ����ṹ
#��$AUTO_HOME/DATA/process�µĿ����ļ���Ϣ,�ļ����������µ�����
#BCD_BCD_11_CURRENCY_CD_20060309.dir(������ҵBCD_11_CURRENCY_CD 20060309 ��Ŀ¼$AUTO_HOME/DATA/process�µĿ����ļ�)
#==================================================================
sub parseDirInfo {

   my $dirfile = shift;
   my ($ret,$tmpIniTabNm);

   $dirfile =~ /^(.{3})_.{3}_(\d{2,4})_(.*)_(\d{8}).dir$/;
   $ret->{SYS} = $1;                      #��ҵϵͳ��;
   $ret->{PROV} = $2;                     #ʡ��/ҵ�������Ϣ;
   $ret->{JOBNAME} = "${1}_${2}_${3}";    #��ҵ����;
   $ret->{TXDATE} = $4;                   #��������/��������;
   $ret->{SUBJOBNAME} = $3;               #��ҵ����ʡ�ݴ������Ĳ���;
   $ret->{SDA_TABLE_NAME} =  $3;          #����DQCȡ��SDATA���еļ��ر�ı���,ͬʱ���ڳ�ʼ����ȥ�������INI

   return $ret;
}


#===================================================================
# format: YYYY MM DD HH MI SS
#===================================================================
sub getTime{

   my $ret = "@_";
   my $tc = localtime(time());
   $tc = sprintf("%4d%02d%02d%02d%02d%02d",$tc->year+1900,$tc->mon+1,
                 $tc->mday, $tc->hour, $tc->min,$tc->sec);
   my $tmp = substr($tc,0,4);
   $ret =~ s/YYYY/$tmp/g;

   $tmp = substr($tc,4,2);
   $ret =~ s/MM/$tmp/g;

   $tmp = substr($tc,6,2);
   $ret =~ s/DD/$tmp/g;

   $tmp = substr($tc,8,2);
   $ret =~ s/HH/$tmp/g;

   $tmp = substr($tc,10,2);
   $ret =~ s/MI/$tmp/g;

   $tmp = substr($tc,12,2);
   $ret =~ s/SS/$tmp/g;
   return $ret;
}

#===================================================
# ��ȡapp_config.ini�е����ݿ�����,��ͨ��DBI�������ݿ�
# ʹ�ø÷���ǰ��Ҫ��/etc/odbcinst.ini����������ΪVertica��ODBC Driver:
#[Vertica]
#Description = vertica
#Driver = /opt/vertica/opt/vertica/lib64/libverticaodbc.so
#===================================================
sub connectDB {
   my ($db_cfg_name) = @_;

   my $VSQL_NODE_COUNT = int(ETL::getAppConfig($db_cfg_name,'VSQL_NODE_COUNT'));
   my $VSQL_IP_PREFIX = ETL::getAppConfig($db_cfg_name,'VSQL_IP_PREFIX');
   my $VSQL_IP_START = int(ETL::getAppConfig($db_cfg_name,'VSQL_IP_START'));

   my $randomnumber = int(rand($VSQL_NODE_COUNT))+$VSQL_IP_START;
   my $VSQL_HOST = "${VSQL_IP_PREFIX}$randomnumber";
   print 'VSQL_HOST:', $VSQL_HOST, "\n";
   my $VSQL_PORT = ETL::getAppConfig($db_cfg_name,'VSQL_PORT');
   my $VSQL_DATABASE = ETL::getAppConfig($db_cfg_name,'VSQL_DATABASE');
   my $VSQL_USER = ETL::getAppConfig($db_cfg_name,'VSQL_USER');
   my $VSQL_PASSWORD = ETL::Decrypt(ETL::getAppConfig($db_cfg_name,'VSQL_PASSWORD'));
   
   my $dbh = DBI->connect("dbi:ODBC:DRIVER={Vertica};Server=${VSQL_HOST};Port=${VSQL_PORT};Database=${VSQL_DATABASE}", $VSQL_USER, $VSQL_PASSWORD,
                          { AutoCommit => 1, PrintError => 1, RaiseError => 0 } );
   
   unless ( defined($dbh) ) { print $DBI::errstr; return undef; }
   
   return $dbh;
}

#===================================================
#���ݿ����ļ�,��ȡ��Ӧ��sql�ļ�����
#===================================================
sub getSqlFileTxt {
   my $PROJECT_CD = shift;
   
   my $fname = $ARGV[0]; #�����ļ���
   my $r = parseDirInfo($fname);

   $fname = "${BDP::AUTO_HOME}/APP/SQLSCRIPT/$r->{SYS}/" . lc($r->{SUBJOBNAME}) . '.sql';

   unless(open(FS,$fname)) {
      print "cann't open sql file $fname $!\n";
      return -1; #�˴��� -1 ����������getSqlFileTxt�ĵط�����ʹ��
   }

   my $str;
   my $len = 1024 * 1024 * 10;
   read(FS,$str,$len);
   close(FS);
   
   return replaceVariable($PROJECT_CD, \$str);
}

#===================================================
#�滻����
#===================================================
sub replaceVariable {
   my ($PROJECT_CD, $str) = @_;
   
   my $fname = $ARGV[0]; #�����ļ���
   my $r = parseDirInfo($fname);
   
   #��ȡapp_config.ini��SQL����
   my $para = ETL::getAppParameters("PUBLIC_SQL_VARS");
   foreach (@$para) {
      $Macro{$_} = ETL::getAppConfig("PUBLIC_SQL_VARS", $_);
   }
   
   $para = ETL::getAppParameters("${PROJECT_CD}_SQL_VARS");
   foreach (@$para) {
      $Macro{$_} = ETL::getAppConfig("${PROJECT_CD}_SQL_VARS", $_);
   }
   
   #print Dumper(%Macro);

   #������صı���
   $Macro{'SYS'}     = $r->{SYS};                       #��ҵϵͳ��
   $Macro{'PROV'}    = $r->{PROV};                      #ʡ��/ҵ�����(��λ����λ����)
   $Macro{'TXDATE'}  = $r->{TXDATE};                    #��������/ͳ������
   $Macro{'JOBNAME'} = $r->{JOBNAME};                   #��������ҵ����,���� SAV_44_AGREEMENT_INI
   $Macro{'SUBJOBNAME'} = $r->{SUBJOBNAME};             #��������ҵ����ʡ�ݴ������Ĳ���,���� AGREEMENT_INIE
   
   $Macro{'YEAR'}    = substr($r->{TXDATE}, 0, 4);      #4λ���
   $Macro{'MONTH'}   = substr($r->{TXDATE}, 4, 2);      #2λ�·�
   $Macro{'DAY'}     = substr($r->{TXDATE}, 6, 2);      #2λ����
   
   $Macro{'YESTERDAY'}  = &decDate($r->{TXDATE},-1);    #��������/ͳ������($TXDATE)֮ǰ��һ��
   $Macro{'NEXTDAY'}    = &decDate($r->{TXDATE}, 1);    #��������/ͳ������($TXDATE)֮���һ��

   my $tmpPeriodDay=&getPeriodDay($r->{TXDATE});
   $Macro{'PERIODBGNDAY'} = $$tmpPeriodDay[0];      #���ݽ�������ȡ����Ѯ�ĵ�һ��
   $Macro{'PERIODENDDAY'} = $$tmpPeriodDay[1];      #���ݽ�������ȡ����Ѯ�����һ��
   $Macro{'PERIODNO'}     = $$tmpPeriodDay[2];      #���ݽ�������ȡ����Ѯ�����20060101/20060102/20060102

   my $tmpMonthDay=&getMonthDay($r->{TXDATE});
   $Macro{'MONTHBGNDAY'} = $$tmpMonthDay[0];        #���ݽ�������ȡ�µĵ�һ��
   $Macro{'MONTHENDDAY'} = $$tmpMonthDay[1];        #���ݽ�������ȡ�µ����һ��
   $Macro{'MONTHNO'}     = $$tmpMonthDay[2];        #���ݽ�������ȡ��200601/200602/200603

   my $tmpSeasonDay=&getSeasonDay($r->{TXDATE});
   $Macro{'SEASONBGNDAY'} = $$tmpSeasonDay[0];      #���ݽ�������ȡ���ȵĵ�һ��
   $Macro{'SEASONENDDAY'} = $$tmpSeasonDay[1];      #���ݽ�������ȡ���ȵ����һ��
   $Macro{'SEASONNO'}     = $$tmpSeasonDay[2];      #���ݽ�������ȡ����200601/200602/200603/200604

   my $tmpYearDay=&getYearDay($r->{TXDATE});
   $Macro{'YEARBGNDAY'} = $$tmpYearDay[0];          #���ݽ�������ȡ��ĵ�һ��
   $Macro{'YEARENDDAY'} = $$tmpYearDay[1];          #���ݽ�������ȡ������һ��
   $Macro{'YEARNO'}     = $$tmpYearDay[2];          #���ݽ�������ȡ��2006

   #��sql�ļ��б�����Ϣ���м����滻
   my $tmp;
   foreach (sort{length($b) <=> length($a)} keys %Macro) {
      $tmp = quotemeta($_);
      $$str =~ s/\$\{${tmp}\}/$Macro{$_}/gi;
      $$str =~ s/\$${tmp}/$Macro{$_}/gi;
   }

   return $str;
}

#===================================================
#����vsqlִ��SQL�ļ�,������ѯ��������ı��ļ�
#����1: �����ļ���
#����2: �ֶηָ���
#����3: �зָ���
#����4: ��ѯSQL�ļ���
#===================================================
sub runVsqlExport {

   my ($db_cfg_name, $filename, $delimiter, $terminator, $runSql) = @_;
   my %returncode;
   
   #��ȡapp_config.ini�д�������Ӧ����ֵ
   my $para = ETL::getAppParameters("VSQL_EXIT_CODE");
   foreach (@$para) {
      $returncode{$_} = ETL::getAppConfig("VSQL_EXIT_CODE", $_);
   }

   my $VSQL_NODE_COUNT = int(ETL::getAppConfig($db_cfg_name,'VSQL_NODE_COUNT'));
   my $VSQL_IP_PREFIX = ETL::getAppConfig($db_cfg_name,'VSQL_IP_PREFIX');
   my $VSQL_IP_START = int(ETL::getAppConfig($db_cfg_name,'VSQL_IP_START'));

   my $randomnumber = int(rand($VSQL_NODE_COUNT))+$VSQL_IP_START;
   $ENV{'VSQL_HOST'} = "${VSQL_IP_PREFIX}$randomnumber";
   print 'VSQL_HOST:', $ENV{'VSQL_HOST'}, "\n";
   $ENV{'VSQL_PORT'} = ETL::getAppConfig($db_cfg_name,'VSQL_PORT');
   $ENV{'VSQL_DATABASE'} = ETL::getAppConfig($db_cfg_name,'VSQL_DATABASE');
   $ENV{'VSQL_USER'} = ETL::getAppConfig($db_cfg_name,'VSQL_USER');
   $ENV{'VSQL_PASSWORD'} = ETL::Decrypt(ETL::getAppConfig($db_cfg_name,'VSQL_PASSWORD'));
   $randomnumber = int(rand($VSQL_NODE_COUNT))+$VSQL_IP_START;
   my $VSQL_BACKUP_HOST = "${VSQL_IP_PREFIX}$randomnumber";
   print 'VSQL_BACKUP_HOST:', $VSQL_BACKUP_HOST, "\n";
   
   my $expfile = $filename;
   if ( defined($terminator) && $terminator ne '') {
      $terminator = quotemeta($terminator);
      $expfile = "${filename}.p";
      if ( -p $expfile ) { unlink($expfile); }
      system("mkfifo $expfile");
      system("cat $expfile | perl -p -e 's/\\n/$terminator\\n/' > $filename &");
   }
   
   my $ret;
   my @result;
   if (substr($delimiter,0,2) eq "\$'") {
      @result = readpipe("vsql -a -B ${VSQL_BACKUP_HOST} -C -F $delimiter -At -o $expfile -f $runSql 2>&1");
   } else {
      @result = readpipe("vsql -a -B ${VSQL_BACKUP_HOST} -C -F '$delimiter' -At -o $expfile -f $runSql 2>&1");
   }
   
   print "@result\n";
   $ret = $? >> 8;
   foreach (@result) {
      s/^\s+//; s/\s+$//;
      if (/^vsql: could not connect to server/) {
         $ret = 11; last;
      } elsif (/server closed the connection unexpectedly/) {
         $ret = 13; last;
      } elsif (/ERROR\s+(\d+):/ || /FATAL\s+(\d+):/ || /ROLLBACK\s+(\d+):/) {
         $ret = $1; last;
      }
   }

   #���ݴ���ź����ò������з���ֵת��
   if ($ret != 0) {
      print "Error Code:$ret\n";
      if (exists $returncode{$ret}) {
         $ret = $returncode{$ret};
      } else {
         $ret = ($ret < 100 ? $ret : 1);
      }
   }
   
   if (defined($terminator) && $terminator ne '') { unlink($expfile); }
   
   print "Return Code:$ret\n";
   return $ret;
}


#===================================================
#����vsql����,����ΪSQL�ļ���
#===================================================
sub runVsqlCommand {
   my ($db_cfg_name, $runSql) = @_;
   my %returncode;
   
   #��ȡapp_config.ini�д�������Ӧ����ֵ
   my $para = ETL::getAppParameters("VSQL_EXIT_CODE");
   foreach (@$para) {
      $returncode{$_} = ETL::getAppConfig("VSQL_EXIT_CODE", $_);
   }

   my $VSQL_NODE_COUNT = int(ETL::getAppConfig($db_cfg_name,'VSQL_NODE_COUNT'));
   my $VSQL_IP_PREFIX = ETL::getAppConfig($db_cfg_name,'VSQL_IP_PREFIX');
   my $VSQL_IP_START = int(ETL::getAppConfig($db_cfg_name,'VSQL_IP_START'));

   my $randomnumber = int(rand($VSQL_NODE_COUNT))+$VSQL_IP_START;
   $ENV{'VSQL_HOST'} = "${VSQL_IP_PREFIX}$randomnumber";
   print 'VSQL_HOST:', $ENV{'VSQL_HOST'}, "\n";
   $ENV{'VSQL_PORT'} = ETL::getAppConfig($db_cfg_name,'VSQL_PORT');
   $ENV{'VSQL_DATABASE'} = ETL::getAppConfig($db_cfg_name,'VSQL_DATABASE');
   $ENV{'VSQL_USER'} = ETL::getAppConfig($db_cfg_name,'VSQL_USER');
   $ENV{'VSQL_PASSWORD'} = ETL::Decrypt(ETL::getAppConfig($db_cfg_name,'VSQL_PASSWORD'));
   $randomnumber = int(rand($VSQL_NODE_COUNT))+$VSQL_IP_START;
   my $VSQL_BACKUP_HOST = "${VSQL_IP_PREFIX}$randomnumber";
   print 'VSQL_BACKUP_HOST:', $VSQL_BACKUP_HOST, "\n";
   
   my $ret;
   my @result = readpipe("vsql -a -B ${VSQL_BACKUP_HOST} -C -v ON_ERROR_STOP=on -v AUTOCOMMIT=off -f $runSql 2>&1");
   
   print "@result\n";
   $ret = $? >> 8;
   if ($ret != 0) {
      foreach (@result) {
         s/^\s+//; s/\s+$//;
         if (/^vsql: could not connect to server/) {
            $ret = 11; last;
         } elsif (/server closed the connection unexpectedly/) {
            $ret = 13; last;
         } elsif (/ERROR\s+(\d+):/ || /FATAL\s+(\d+):/ || /ROLLBACK\s+(\d+):/) {
            $ret = $1; last;
         }
      }
   }

   #���ݴ���ź����ò������з���ֵת��
   if ($ret != 0) {
      print "Error Code:$ret\n";
      if (exists $returncode{$ret}) {
         $ret = $returncode{$ret};
      } else {
         $ret = ($ret < 100 ? $ret : 1);
      }
   }
   
   print "Return Code:$ret\n";
   return $ret;
}


#===================================================
#����vsql����,����ΪSQL���ĵ�ַ����
#===================================================
sub runVsqlCommand1 {
   my ($db_cfg_name, $runSql) = @_;
   my %returncode;
   
   #��ȡapp_config.ini�д�������Ӧ����ֵ
   my $para = ETL::getAppParameters("VSQL_EXIT_CODE");
   foreach (@$para) {
      $returncode{$_} = ETL::getAppConfig("VSQL_EXIT_CODE", $_);
   }

   my $VSQL_NODE_COUNT = int(ETL::getAppConfig($db_cfg_name,'VSQL_NODE_COUNT'));
   my $VSQL_IP_PREFIX = ETL::getAppConfig($db_cfg_name,'VSQL_IP_PREFIX');
   my $VSQL_IP_START = int(ETL::getAppConfig($db_cfg_name,'VSQL_IP_START'));

   my $randomnumber = int(rand($VSQL_NODE_COUNT))+$VSQL_IP_START;
   $ENV{'VSQL_HOST'} = "${VSQL_IP_PREFIX}$randomnumber";
   print 'VSQL_HOST:', $ENV{'VSQL_HOST'}, "\n";
   $ENV{'VSQL_PORT'} = ETL::getAppConfig($db_cfg_name,'VSQL_PORT');
   $ENV{'VSQL_DATABASE'} = ETL::getAppConfig($db_cfg_name,'VSQL_DATABASE');
   $ENV{'VSQL_USER'} = ETL::getAppConfig($db_cfg_name,'VSQL_USER');
   $ENV{'VSQL_PASSWORD'} = ETL::Decrypt(ETL::getAppConfig($db_cfg_name,'VSQL_PASSWORD'));
   $randomnumber = int(rand($VSQL_NODE_COUNT))+$VSQL_IP_START;
   my $VSQL_BACKUP_HOST = "${VSQL_IP_PREFIX}$randomnumber";
   print 'VSQL_BACKUP_HOST:', $VSQL_BACKUP_HOST, "\n";
   
   my $ret;
   my @result = readpipe("vsql -a -B ${VSQL_BACKUP_HOST} -C -v ON_ERROR_STOP=on -v AUTOCOMMIT=off 2>&1 <<EOF\n$$runSql\nEOF");
   
   print "@result\n";
   $ret = $? >> 8;
   if ($ret != 0) {
      foreach (@result) {
         s/^\s+//; s/\s+$//;
         if (/^vsql: could not connect to server/) {
            $ret = 11; last;
         } elsif (/server closed the connection unexpectedly/) {
            $ret = 13; last;
         } elsif (/ERROR\s+(\d+):/ || /FATAL\s+(\d+):/ || /ROLLBACK\s+(\d+):/) {
            $ret = $1; last;
         }
      }
   }

   #���ݴ���ź����ò������з���ֵת��
   if ($ret != 0) {
      print "Error Code:$ret\n";
      if (exists $returncode{$ret}) {
         $ret = $returncode{$ret};
      } else {
         $ret = ($ret < 100 ? $ret : 1);
      }
   }
   
   print "Return Code:$ret\n";
   return $ret;
}

#===================================================
#����vsql����,����ΪSQL���ĵ�ַ����
#===================================================
sub runVsqlCommand2 {
   my ($db_cfg_name, $runSql) = @_;
   my %returncode;
   
   #��ȡapp_config.ini�д�������Ӧ����ֵ
   my $para = ETL::getAppParameters("VSQL_EXIT_CODE");
   foreach (@$para) {
      $returncode{$_} = ETL::getAppConfig("VSQL_EXIT_CODE", $_);
   }
   
   my %last_on_error = (4568=>1, 2624=>1, 4876=>1);

   my $VSQL_NODE_COUNT = int(ETL::getAppConfig($db_cfg_name,'VSQL_NODE_COUNT'));
   my $VSQL_IP_PREFIX = ETL::getAppConfig($db_cfg_name,'VSQL_IP_PREFIX');
   my $VSQL_IP_START = int(ETL::getAppConfig($db_cfg_name,'VSQL_IP_START'));

   my $randomnumber = int(rand($VSQL_NODE_COUNT))+$VSQL_IP_START;
   $ENV{'VSQL_HOST'} = "${VSQL_IP_PREFIX}$randomnumber";
   print 'VSQL_HOST:', $ENV{'VSQL_HOST'}, "\n";
   $ENV{'VSQL_PORT'} = ETL::getAppConfig($db_cfg_name,'VSQL_PORT');
   $ENV{'VSQL_DATABASE'} = ETL::getAppConfig($db_cfg_name,'VSQL_DATABASE');
   $ENV{'VSQL_USER'} = ETL::getAppConfig($db_cfg_name,'VSQL_USER');
   $ENV{'VSQL_PASSWORD'} = ETL::Decrypt(ETL::getAppConfig($db_cfg_name,'VSQL_PASSWORD'));
   $randomnumber = int(rand($VSQL_NODE_COUNT))+$VSQL_IP_START;
   my $VSQL_BACKUP_HOST = "${VSQL_IP_PREFIX}$randomnumber";
   print 'VSQL_BACKUP_HOST:', $VSQL_BACKUP_HOST, "\n";

   local(*Reader,*Writer);
   my @Msg;
   my $ret;
   my $rc;
   my $flag = 0;
   my $TimeOut = 8*3600;
   my @statements;
   
   my $sqlstr = $$runSql;
   
   #ȥ��/**/ע����Ϣ,������ԭ��Hint("/*+"��ͷ)
   my $s = 0;
   my $t = 0;
   while (1) {
      $s = index($sqlstr ,'/*', $s);
      if ($s == -1) { last; }
      if (substr($sqlstr,$s+2,1) eq '+') {
         $s += 2;
      } else {
         $t = index($sqlstr, '*/', $s);
         $sqlstr = substr($sqlstr,0,$s) . substr($sqlstr,$t+2);
         $s = 0;
      }
   }
   
   #ȥ��--ע���еķֺ�
   my ($str1, $str2);
   while ( $sqlstr =~ /--(.*)/g) {
      $str1 = $str2 = $1;
      if (index($1,';') != -1) {
         $str1 = quotemeta($str1);
         $str2 =~ s/;//g;
         $sqlstr =~ s/--${str1}/--${str2}/;
      }
   }
   
   @statements = split /;\s+/, $sqlstr;

   $|++;
   my $pid = open3(\*Writer, \*Reader, \*Reader, "vsql -a -B ${VSQL_BACKUP_HOST} -C");

   eval {
      local $SIG{INT}  = sub { alarm 0; die "killed\n" };
      local $SIG{QUIT} = sub { alarm 0; die "killed\n" };
      local $SIG{TERM} = sub { alarm 0; die "killed\n" };
      local $SIG{ALRM} = sub { alarm 0; die "alarm\n" };
      alarm $TimeOut;

      print Writer "\\set AUTOCOMMIT off\n";
      print Writer "\\set ON_ERROR_STOP on\n";
      print Writer "\\timing\n";
      
      #��������Ƿ�ɹ�
      while (my $line = <Reader>) {
         print $line;
         push @Msg, $line;
         chomp($line);
         $line =~ s/^\s+//;
         $line =~ s/\s+$//;
         if ($line =~ /^vsql: could not connect to server/) {
            $flag = 11; last;
         } elsif ($line =~ /FATAL\s+(\d+):/) {
            $flag = $1; last;
         } else {
            last;
         }
      }
      
      if ($flag) { print "Error Code:$flag\n"; }
      if (exists $returncode{$flag}) {
         $flag = $returncode{$flag};
      } else {
         $flag = ($flag < 100 ? $flag : 1);
      }
      
      if ($flag) {
         print "Return Code:$flag\n";
         pop @Msg;
         $ret->{RetCode} = $flag;
         $ret->{RetMsg} = \@Msg;
         alarm 0;
         return $ret;
      }
      
      my $sql;
      my $activitycount = 0;
      my @label;
      my $label;
      my @tmp;
      
      #����ִ��SQL���,����ȡ��������Լ���Ƿ�ִ�гɹ�
      foreach (my $i=0; $i<=$#statements; $i++) {
         $sql = $statements[$i];
         $sql =~ s/^\s+//;
         $sql =~ s/\s+$//;
         if ($sql eq '') {next;}
         
         if ($sql =~ /INSERT(.*)[INTO|\n]/i && index($1,'/*+') == -1) {
            $sql =~ s/INSERT\s+/INSERT \/*+ DIRECT *\/ /i;
         } elsif ($sql =~ /DELETE(.*)[\w+|\n]/i && index($1,'/*+') == -1) {
            $sql =~ s/DELETE\s+/DELETE \/*+ DIRECT *\/ /i;
         } elsif ($sql =~ /UPDATE(.*)[\w+|\n]/i && index($1,'/*+') == -1) {
            $sql =~ s/UPDATE\s+/UPDATE \/*+ DIRECT *\/ /i;
         }
         
         if ($sql =~ /ActivityCount\s*(\<*\>*\=*)\s*(\d+)\s+(.*)$/i && @label==0) {
            if (($1 eq '<' && $activitycount < $2) ||
                ($1 eq '<=' && $activitycount <= $2) ||
                ($1 eq '>' && $activitycount > $2) ||
                ($1 eq '>=' && $activitycount >= $2) ||
                ($1 eq '=' && $activitycount == $2)) {
               @tmp = split(/\s+/,$3);
               $label = $tmp[$#tmp];
               print "$sql\n\n";
               print "label $label start.\n\n";
               push @label,$label;
            } else {
               print "$sql\n\n";
               print "statment ignored.\n\n";
            }
         } elsif ($sql =~ /\.GOTO\s+(.*)$/i && @label==0) {
            @tmp = split(/\s+/,$1);
            $label = $tmp[$#tmp];
            print "$sql\n\n";
            print "label $label start.\n\n";
            push @label,$label;
         } elsif ($sql =~ /\.LABEL\s+(.*)$/i) {
            @tmp = split(/\s+/,$1);
            $label = $tmp[$#tmp];
            if ($label eq $label[$#label]) {
               print "$sql\n\n";
               print "label $label end.\n\n";
               pop @label;
            } else {
               print "$sql\n\n";
               print "statment ignored.\n\n";
            }
         } elsif (@label>0) {
            print "$sql\n\n";
            print "statment ignored.\n\n";
         } else {
            print Writer "${sql}\n;\n";
            $flag = 0;
            @Msg = ();
            my $result_start = 0;
            $activitycount = -1;
            while (my $line = <Reader>) {
               print $line;
               push @Msg, $line;
               chomp($line);
               $line =~ s/^\s+//;
               $line =~ s/\s+$//;
               if (index($line,'----')>=0) {
                  $result_start = 1;
               } elsif ($line =~ /^(\d+)$/ && $result_start==1) {
                  $activitycount = $1;
               } elsif ($line =~ /^Time:/ || ($flag>0)) {
                  last;
               } elsif ($line =~ /server closed the connection unexpectedly/) { #session has been killed
                  $flag = 13; last;
               } elsif ($line =~ /ERROR\s+(\d+):/ || $line =~ /ROLLBACK\s+(\d+):/) {
                  $flag = $1; last;
               }
            }
            print "\n";
            last if ($flag>0);
         }
      }

      if ($flag == 0) {
         print Writer "commit;\n";
         print Writer "\\q\n";
      }      
      close Writer;
      close Reader;
      waitpid($pid,0);
      
      #���ݴ���ź����ò������з���ֵת��
      if ($flag) { print "Error Code:$flag\n"; }
      if (exists $returncode{$flag}) {
         $flag = $returncode{$flag};
      } else {
         $flag = ($flag < 100 ? $flag : 1);
      }
      
      print "Return Code:$flag\n";
      $ret->{RetCode} = $flag;
      if ($flag) {
         pop @Msg;
         $ret->{RetMsg} = \@Msg;
      } else {
         @Msg = ();
         $Msg[0] = 'Call vsql success.';
         $ret->{RetMsg} = \@Msg;
      }
      alarm 0;
   }; # end of eval
   
   if ($@ eq "alarm\n") {
      close Writer;
      close Reader;
      kill 9,$pid;
      waitpid($pid,0);
      
      print "Call vsql timeout.\n";   
      $ret->{RetCode} = 10;
      @Msg = ();
      $Msg[0] = 'Call vsql timeout.';
      $ret->{RetMsg} = \@Msg;
   } elsif ($@ eq "killed\n") {
      print "Call vsql has been killed\n";
      $ret->{RetCode} = 9;
      @Msg = ();
      $Msg[0] = 'Call vsql has been killed.';
      $ret->{RetMsg} = \@Msg;
   }
   
   return $ret;
}


#===================================================
#����beeline����,����ΪSQL�ļ���
#===================================================
sub runBeelineCommand {
   my ($hive_cfg_name, $runSql) = @_;

   my $HIVE_URL = ETL::getAppConfig($hive_cfg_name,'HIVE_URL');
   my $HIVE_USER = ETL::getAppConfig($hive_cfg_name,'HIVE_USER');
   my $HIVE_PWDFILE = ETL::getAppConfig($hive_cfg_name,'HIVE_PWDFILE');
   
   my $ret;
   my @result = readpipe("beeline -u ${HIVE_URL} -n ${HIVE_USER} -w ${HIVE_PWDFILE} -f $runSql 2>&1");
   
   print "@result\n";
   $ret = $? >> 8;
   
   print "Return Code:$ret\n";
   if ($ret == 0) {
      if (grep(/JOB FINISHED SUCCESSFULLY/, @result)) {
         return $ret;
      } else {
         print "Job does not finished successfully, reset return code to 1\n";
         return 1;
      }
   } else {
      return $ret;
   }   
}


#===================================================
#���������������Ϣ,�õ�����������Ѯ�ĵ�һ������һ��,ͬʱ����Ѯ�����
#����20060101 20060110 20060101
#���ڸ�ʽͳһ��YYYYMMDD
#===================================================
sub getPeriodDay {
   my $tmpDate="$_[0]";

   my @tmpDays=(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

   my ($tmpYear,$tmpMonth,$tmpDay) = (int(substr($tmpDate,0,4)),int(substr($tmpDate,4,2)),int(substr($tmpDate,6,2)));

   my @tmpPeriodDay;
   if($tmpDay >=1 && $tmpDay <=10)
   {
      $tmpPeriodDay[0]=sprintf("%04d%02d%02d",$tmpYear,$tmpMonth,1);
      $tmpPeriodDay[1]=sprintf("%04d%02d%02d",$tmpYear,$tmpMonth,10);
      $tmpPeriodDay[2]=sprintf("%04d%02d%02d",$tmpYear,$tmpMonth,1);
   }elsif($tmpDay >=11 && $tmpDay <=20){
      $tmpPeriodDay[0]=sprintf("%04d%02d%02d",$tmpYear,$tmpMonth,11);
      $tmpPeriodDay[1]=sprintf("%04d%02d%02d",$tmpYear,$tmpMonth,20);
      $tmpPeriodDay[2]=sprintf("%04d%02d%02d",$tmpYear,$tmpMonth,2);
   }elsif($tmpDay >=21 && $tmpDay <=31){
      #����
      my $tmpEndDate = $tmpDays[$tmpMonth-1];
      $tmpEndDate = $tmpDays[$tmpMonth-1] + isYeapYear($tmpYear) if ( $tmpMonth == 2 );

      $tmpPeriodDay[0]=sprintf("%04d%02d%02d",$tmpYear,$tmpMonth,21);
      $tmpPeriodDay[1]=sprintf("%04d%02d%02d",$tmpYear,$tmpMonth,$tmpEndDate);
      $tmpPeriodDay[2]=sprintf("%04d%02d%02d",$tmpYear,$tmpMonth,3);
   }

   return \@tmpPeriodDay;
}


#===================================================
#���������������Ϣ,�õ������������µĵ�һ������һ�������ֵ,��������
#���ڸ�ʽͳһ��YYYYMMDD,������Ϣ������6λ��ʾ��/����Ϣ
#===================================================
sub getMonthDay {
   my $tmpDate="$_[0]";

   my @tmpDays=(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
   my ($tmpYear,$tmpMonth) = (int(substr($tmpDate,0,4)),int(substr($tmpDate,4,2)));

   my ($tmpBgnDate,$tmpEndDate)=(1,$tmpDays[$tmpMonth-1]);

   $tmpEndDate = 29 if ( $tmpMonth == 2 && isYeapYear($tmpYear));

   my @tmpMonthDay;

   $tmpMonthDay[0]=sprintf("%04d%02d%02d",$tmpYear,$tmpMonth,$tmpBgnDate);
   $tmpMonthDay[1]=sprintf("%04d%02d%02d",$tmpYear,$tmpMonth,$tmpEndDate);
   $tmpMonthDay[2]=sprintf("%04d%02d",$tmpYear,$tmpMonth);

   return \@tmpMonthDay;
}


#===================================================
#���������������Ϣ,�õ����������ڼ��ȵĵ�һ������һ�������ֵ,��������
#���ڸ�ʽͳһ��YYYYMMDD
#===================================================
sub getSeasonDay {
   my $tmpDate="$_[0]";

   my @tmpSeasonDay;
   if(substr($tmpDate,4) ge "0101" && substr($tmpDate,4) le "0331")
   {
      $tmpSeasonDay[0]=substr($tmpDate,0,4)."0101";
      $tmpSeasonDay[1]=substr($tmpDate,0,4)."0331";
      $tmpSeasonDay[2]=substr($tmpDate,0,4)."01";
   }
   elsif(substr($tmpDate,4) ge "0401" && substr($tmpDate,4) le "0630")
   {
      $tmpSeasonDay[0]=substr($tmpDate,0,4)."0401";
      $tmpSeasonDay[1]=substr($tmpDate,0,4)."0630";
      $tmpSeasonDay[2]=substr($tmpDate,0,4)."02";
   }
   elsif(substr($tmpDate,4) ge "0701" && substr($tmpDate,4) le "0930")
   {
      $tmpSeasonDay[0]=substr($tmpDate,0,4)."0701";
      $tmpSeasonDay[1]=substr($tmpDate,0,4)."0930";
      $tmpSeasonDay[2]=substr($tmpDate,0,4)."03";
   }
   elsif(substr($tmpDate,4) ge "1001" && substr($tmpDate,4) le "1231")
   {
      $tmpSeasonDay[0]=substr($tmpDate,0,4)."1001";
      $tmpSeasonDay[1]=substr($tmpDate,0,4)."1231";
      $tmpSeasonDay[2]=substr($tmpDate,0,4)."04";
   }

   return \@tmpSeasonDay;
}


#===================================================
#���������������Ϣ,�õ�������������ĵ�һ������һ�������ֵ
#���ڸ�ʽͳһ��YYYYMMDD
#===================================================
sub getYearDay {
   my $tmpDate="$_[0]";

   my @tmpYearDay;

   $tmpYearDay[0]=substr($tmpDate,0,4)."0101";
   $tmpYearDay[1]=substr($tmpDate,0,4)."1231";
   $tmpYearDay[2]=substr($tmpDate,0,4);

   return \@tmpYearDay;
}


#===================================================
#����ָ�������Թ�Ԫ1��1��1�տ�ʼ������(��������),���ڸ�ʽYYYYMMDD
#===================================================
sub DateLocal
{
   my $tmpDate="$_[0]";
   my ($yy, $mm, $dd) = (int(substr($tmpDate,0,4)),int(substr($tmpDate,4,2)),int(substr($tmpDate,6,2)));

   my @MonthDays = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
   my $Days;
   my $LeapYear = isYeapYear($yy);

   $Days = ($yy - 1) * 365 + int(($yy - 1) / 4) - int(($yy - 1) / 100) + int(($yy - 1) / 400);

   for (my $i = 1; $i < $mm; $i++)
   {
      $Days += $MonthDays[$i - 1];
      if ($i == 2) { $Days += $LeapYear; }
   }

   $Days += ($dd - 1);
   return $Days;
}


#===================================================
# ����� $tmpDate1 �� $tmpDate2 ������
# ���ǰһ�����ں��ں�һ�����ڣ���õ�����
# ����: ���ӹ�Ԫ 1 �꿪ʼ���㾭����������Ȼ���������������
#===================================================
sub DateDiff
{
   my($tmpDate1,$tmpDate2)=@_;

   return &DateLocal($tmpDate2) - &DateLocal($tmpDate1);
}

###############################################################################
#
#18λ���֤�ŵ���֤
#�ҹ��°�18λ���֤�ŵ����һλ��У��λ,���� MOD 11-2�㷨,���������
#�򵥵�˵����ǰ17λ��Ȩֵ����Ϊѭ��(7,9,10,5,8,4,2,1,6,3),���ȼ�Ȩ�����
#Ҳ����:ID[1] * 7 + ID[2] * 9 + ... + ID[9] * 6 + ID[10] * 3 + ID[11] * 7 + ... + ID[16] * 4 + ID[17] * 2
#	      --^--^-^------^--^--
#���»ص�7,9,10... ������ĺ�,��11ȡģ,������[0~10]���һ��ֵ
#Ȼ�������¹�ϵ,�õ����һλУ��λ��ֵ:
#'0'  =>  '1','1'  =>  '0','2'  =>  'X','3'  =>  '9','4'  =>  '8',
#'5'  =>  '7','6'  =>  '6','7'  =>  '5','8'  =>  '4','9'  =>  '3','10' =>  '2'
###############################################################################
#��17λ����18λ���ȵ����֤����У��λ
sub IdenCardParityBit {
   my ($tmpCardID)=@_;

   my %tmpMap=('0'  =>  '1',
               '1'  =>  '0',
               '2'  =>  'X',
               '3'  =>  '9',
               '4'  =>  '8',
               '5'  =>  '7',
               '6'  =>  '6',
               '7'  =>  '5',
               '8'  =>  '4',
               '9'  =>  '3',
               '10' =>  '2');

   my (@tmpParityBitArray,$tmpParityBit);
   #����У��λ��Ϣ
   @tmpParityBitArray=split(//,$tmpCardID);
   $tmpParityBit=$tmpMap{($tmpParityBitArray[0 ] * 7  +
                          $tmpParityBitArray[1 ] * 9  +
                          $tmpParityBitArray[2 ] * 10 +
                          $tmpParityBitArray[3 ] * 5  +
                          $tmpParityBitArray[4 ] * 8  +
                          $tmpParityBitArray[5 ] * 4  +
                          $tmpParityBitArray[6 ] * 2  +
                          $tmpParityBitArray[7 ] * 1  +
                          $tmpParityBitArray[8 ] * 6  +
                          $tmpParityBitArray[9 ] * 3  +
                          $tmpParityBitArray[10] * 7  +
                          $tmpParityBitArray[11] * 9  +
                          $tmpParityBitArray[12] * 10 +
                          $tmpParityBitArray[13] * 5  +
                          $tmpParityBitArray[14] * 8  +
                          $tmpParityBitArray[15] * 4  +
                          $tmpParityBitArray[16] * 2) % 11};
   return $tmpParityBit;
}
# end IdenCardParityBit


###############################################################################
#���֤��Ϣ��ת������֤
#����һ������[0]���֤��[1]�Ƿ���Ч��־
###############################################################################
sub IdenCardConvert {
   my ($tmpCardID)=@_;

   my (@tmpCardIDInfo);

   #$flag=1��ʾ����Ч���֤,flag=0��ʾ����Ч���֤��Ϣ
   my ($flag,$tmpParityBit)=(0,'');

   $tmpCardID =~ s/\s//g;
   $tmpCardID =~ tr[a-z][A-Z];
   #��֤���֤����
   #һ�������ȫ�����������
   #һ�������ǰ��ȫ��������,���һ������ĸ X
   if (($tmpCardID =~ /^\d+$/) || ($tmpCardID =~ /^\d+X$/))
   {
      if(length($tmpCardID) eq 18)
      {
         $tmpParityBit = IdenCardParityBit($tmpCardID);

         #��֤18λ���֤��У��λ�Ƿ���ȷ
         $flag = 1 if ($tmpParityBit eq substr($tmpCardID,17));
      }elsif(length($tmpCardID) eq 15 || length($tmpCardID) eq 17)
      {
         #15λת����17λ
         if (length($tmpCardID) eq 15)
         {
            $tmpCardID =~ /^(.{6})(.+)$/;
            $tmpCardID = $1."19".$2;
         }

         #����У��λ��Ϣ
         $tmpParityBit = IdenCardParityBit($tmpCardID);
         $tmpCardID = $tmpCardID.$tmpParityBit;

         $flag = 1;
      }
   }# (($tmpCardID =~ /^\d+$/) || ($tmpCardID =~ /^\d+X$/))

   $tmpCardIDInfo[0]=$tmpCardID;
   $tmpCardIDInfo[1]=$flag;

   return \@tmpCardIDInfo;
}

1;
