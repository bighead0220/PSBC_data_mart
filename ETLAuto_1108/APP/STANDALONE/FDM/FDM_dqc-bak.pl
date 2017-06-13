#!/usr/bin/perl
# dqc.pl

use strict;
use etl_unix;
use bdp_pub;

#1�������Ƿ����ظ���¼
#   �����ֶΣ�A,B
#   �ظ���¼��A1,B1 
#   10 ��
#2���ֶ��Ƿ�Ϊ��
#   �����ֶΣ�A,B
#   Ϊ�ռ�¼��A2,B2
#3��@��ֵ�Ƿ�ת��
   
open(STDERR, ">&STDOUT");

my $PROJECT_CD = 'FDM';          #��Ŀ����
my $VSQL_CFG_NAME = 'FDM_VSQL';  #app_config.ini��VSQL�������õ����� 
if ( $#ARGV < 0 or $ARGV[0] !~ /^(.{3})_.{3}_(\d{2,4})_(.*)_(\d{8}).dir$/) {
   print "\n";
   print "Usage: $0  \n";
   print "Usage: ʹ�ò��� \n";
   print "       CONTROL_FILE  -- �����ļ�(SYS_JOBNAME_YYYYMMDD.dir) \n";
   exit(1);
}
my $CtrlInfo = BDP::parseDirInfo($ARGV[0]);

my $etl_date = "$CtrlInfo->{TXDATE}";

print  $etl_date ;
my $VSQL_NODE_COUNT = int(ETL::getAppConfig($VSQL_CFG_NAME,'VSQL_NODE_COUNT'));
my $VSQL_IP_PREFIX = ETL::getAppConfig($VSQL_CFG_NAME,'VSQL_IP_PREFIX');
my $VSQL_IP_START = int(ETL::getAppConfig($VSQL_CFG_NAME,'VSQL_IP_START')); 
my $randomnumber = int(rand($VSQL_NODE_COUNT))+$VSQL_IP_START;
$ENV{'VSQL_HOST'} = "${VSQL_IP_PREFIX}$randomnumber";
print 'VSQL_HOST:', $ENV{'VSQL_HOST'}, "\n";
$ENV{'VSQL_PORT'} = ETL::getAppConfig($VSQL_CFG_NAME,'VSQL_PORT');
$ENV{'VSQL_DATABASE'} = ETL::getAppConfig($VSQL_CFG_NAME,'VSQL_DATABASE');
$ENV{'VSQL_USER'} = ETL::getAppConfig($VSQL_CFG_NAME,'VSQL_USER');
$ENV{'VSQL_PASSWORD'} = ETL::Decrypt(ETL::getAppConfig($VSQL_CFG_NAME,'VSQL_PASSWORD'));
$randomnumber = int(rand($VSQL_NODE_COUNT))+$VSQL_IP_START;
my $VSQL_BACKUP_HOST = "${VSQL_IP_PREFIX}$randomnumber";
print 'VSQL_BACKUP_HOST:', $VSQL_BACKUP_HOST, "\n";
my %hash ;

my $COMMAND = "vsql -B ${VSQL_BACKUP_HOST} -C -h $ENV{'VSQL_HOST'} -d $ENV{'VSQL_DATABASE'} -w $ENV{'VSQL_PASSWORD'} -t";
print $COMMAND ,"\n"; 
#
my @result = `$COMMAND<<EOF
\\set ON_ERROR_STOP on
  select rule_type, 
        tab_en_name,
        field_en_name,
        primary_key,
        tab_cn_name,
        field_cn_name,
        RULE_ID, 
        'select '|| PRIMARY_KEY ||' from f_fdm.'||tab_en_name ||' where 1=1 and etl_date = '||'''$etl_date'''||'::date group by '||field_en_name||' having count(1) <> 1 limit 5; '  
   from f_app.T_RD_VALIDATE_RULE 
  where rule_type = 'C' 
  union all 
  select rule_type, 
        tab_en_name,
        field_en_name,
        primary_key,
        tab_cn_name,
        field_cn_name,
        rule_id , 
         'select '|| PRIMARY_KEY ||' from f_fdm.'||tab_en_name||'  where  '||field_en_name||' is null limit 5 ;'  
    from f_app.t_rd_validate_rule 
   where rule_type = 'A'
  union all 
  select rule_type, 
        tab_en_name,
        field_en_name,
        primary_key,
        tab_cn_name,
        field_cn_name,
        RULE_ID, 
         'select '|| PRIMARY_KEY ||' from f_fdm.'||tab_en_name ||' where 1=1 and to_char('||field_en_name||') like '||'''@%'''||'and etl_date = '||'''$etl_date'''||'::date limit 5'
    from f_app.T_RD_VALIDATE_RULE
    where rule_type = 'B'
    order by 1
 ;
\\q
EOF`;
chop @result;
print @result;

my $deletesql = " delete from f_app.t_rd_exception where work_dt = '$etl_date'::date ; ";
  my $insertsqlresult = `$COMMAND<<EOF
     
   $deletesql 
     
   commit;
   \\q
EOF`;


foreach my $row(@result)
{ 
  next if &trim($row) eq '';
  my ($rule_type,$tab_en_name,$field_en_name,$primary_key,$tab_cn_name,$field_cn_name,$key,$val) = split (/\|/,$row) ;
  $key = trim($key);
  $rule_type=trim($rule_type);
  $tab_en_name=trim($tab_en_name);
  $field_en_name=trim($field_en_name);
  $tab_cn_name=trim($tab_cn_name); 
  $field_cn_name=trim($field_cn_name); 
  $primary_key=trim($primary_key); 
  print  $val ,"\n";
  my $execsqlresult = `$COMMAND<<EOF
    $val 
   \\q
EOF`; 
  chop $execsqlresult ;
  
  next if $execsqlresult eq '' ;
  #my @wrongresut = split (/\|/,$execsqlresult ) ;
  my $wrongresut = $primary_key."\n".$execsqlresult ;
  my $insertsql = "INSERT INTO f_app.t_rd_exception 
  (rule_type, tab_en_name, rule_id, check_time, field_en_name, work_dt, exception_msg, tab_pk_value, field_value,tabcnname,fieldcnname) 
  VALUES 
  ('$rule_type', '$tab_en_name', '$key' , sysdate , '$field_en_name','$etl_date'::date, '$wrongresut' , '$primary_key', '','$tab_cn_name','$field_cn_name');";
  print $insertsql ,"\n";
  

my $insertsqlresult = `$COMMAND<<EOF
   
   $insertsql
   commit;
   \\q
EOF`; 
  #my $ret = BDP::runVsqlCommand($VSQL_CFG_NAME, $runSql);

  #exit($ret->{RetCode}); 
   
}


my $result = `vsql -B ${VSQL_BACKUP_HOST} -C -h $ENV{'VSQL_HOST'} -d $ENV{'VSQL_DATABASE'} -w $ENV{'VSQL_PASSWORD'} -Atq  -c "select count(1) from f_app.T_RD_EXCEPTION where work_dt = '$etl_date'::date "`;
print "================== $result \n";
if ($result == 0 ){
 my $insertsql2 = "INSERT INTO f_app.t_rd_exception 
  (rule_type, tab_en_name, rule_id, check_time, field_en_name, work_dt, exception_msg, tab_pk_value, field_value,tabcnname,fieldcnname) 
  VALUES 
  ('', '', '' , sysdate , '','$etl_date'::date, '����У�����,����������' , '', '','','');";
my $insertsqlresult2 = `$COMMAND<<EOF  
   $insertsql2
   commit;
   \\q
EOF`;
} 
if ($result != 0 ){

 my $wron = " 有 $result 个数据问题";
 my $insertsql2 = "INSERT INTO f_app.t_rd_exception 

  (rule_type, tab_en_name, rule_id, check_time, field_en_name, work_dt, exception_msg, tab_pk_value, field_value,tabcnname,fieldcnname) 

  VALUES 

  ('', '', '' , sysdate , '','$etl_date'::date, '$wron' , '', '','','');";

my $insertsqlresult2 = `$COMMAND<<EOF  

   $insertsql2

   commit;

   \\q

EOF`;

}



exit 0;
 sub trim{
 	
 	my $s = shift ;
 	$s =~ s/^\s+|\s+$//g;
 	return $s ;
 	
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
    	  my $time = getTime("YYYY-MM-DD HH:MI:SS");
        print "[$time] �Ҳ��������ļ� [$g_cfgs] \n";
        exit(1);
    }
    my $g_config = Config::IniFiles->new( -file => "$g_cfgs");
    if (!$g_config) {
    	  my $time = getTime("YYYY-MM-DD HH:MI:SS");
        print "[$time] �������ļ�[$g_cfgs]ʧ�� ! $! \n";
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


