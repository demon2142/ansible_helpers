#!/usr/bin/perl

###SCRIPT for generate firewall rules for each inventory host

use strict;
use warnings;
use Cwd;
use Data::Dumper;

our ($self_dir_g,$script_name_g)=Cwd::abs_path($0)=~/(.*[\/\\])(\S+)$/;

############ARGV
our $inventory_conf_path_g='no';
our $gen_with_rollback_g=0;

if ( defined($ARGV[0]) && length($ARGV[0])>0 ) {
    $inventory_conf_path_g=$ARGV[0];
}

if ( defined($ARGV[1]) && $ARGV[1]=~/^with_rollback$/ ) {
    $gen_with_rollback_g=1;
}
############ARGV

############CFG file
#00_conf_firewalld
#01_conf_ipset_templates
#02_conf_custom_firewall_zones_templates
#02_conf_standard_firewall_zones_templates
#03_conf_policy_templates
#04_conf_zone_forward_ports_sets
#05_conf_zone_rich_rules_sets
#66_conf_ipsets_FIN
#77_conf_zones_FIN
#88_conf_policies_FIN
###
our $f00_conf_firewalld_path_g=$self_dir_g.'/fwrules_configs/00_conf_firewalld';
our $f01_conf_ipset_templates_path_g=$self_dir_g.'/fwrules_configs/01_conf_ipset_templates';
our $f02_conf_custom_firewall_zones_templates_path_g=$self_dir_g.'/fwrules_configs/02_conf_custom_firewall_zones_templates';
our $f02_conf_standard_firewall_zones_templates_path_g=$self_dir_g.'/fwrules_configs/02_conf_standard_firewall_zones_templates';
our $f03_conf_policy_templates_path_g=$self_dir_g.'/fwrules_configs/03_conf_policy_templates';
our $f04_conf_zone_forward_ports_sets_path_g=$self_dir_g.'/fwrules_configs/04_conf_zone_forward_ports_sets';
our $f05_conf_zone_rich_rules_sets_path_g=$self_dir_g.'/fwrules_configs/05_conf_zone_rich_rules_sets';
our $f66_conf_ipsets_FIN_path_g=$self_dir_g.'/fwrules_configs/66_conf_ipsets_FIN';
our $f77_conf_zones_FIN_path_g=$self_dir_g.'/fwrules_configs/77_conf_zones_FIN';
our $f88_conf_policies_FIN_path_g=$self_dir_g.'/fwrules_configs/88_conf_policies_FIN';
###
our $ifcfg_backup_from_remote_nd_file_g=$self_dir_g.'playbooks/fwrules_backup_from_remote/network_data/inv_hosts_interfaces_info.txt'; # dir contains actual network_data (eth) downloaded from remote hosts with help of playbook 'fwrules_backup_playbook.yml' before run this script
############CFG file

############STATIC VARS
our $remote_dir_for_absible_helper_g='~/ansible_helpers/conf_firewalld'; # dir for creating/manipulate files at remote side
############STATIC VARS

############VARS
######
our %inventory_hosts_g=(); # for checks of h00_conf_firewalld_hash_g/h66_conf_ipsets_FIN_hash_g/h77_conf_zones_FIN_hash_g/h88_conf_policies_FIN_hash_g 
# and operate with 'all' (apply for all inv hosts) options
###
#Key=inventory_host, value=1
######

######
our %inv_hosts_network_data_g=();
#INV_HOST       #INT_NAME       #IPADDR
#$inv_hosts_network_data_g{inv_host}{int_name}=ipaddr
######

######
our %h00_conf_firewalld_hash_g=();
#[firewall_conf_for_all--TMPLT:BEGIN]
#host_list_for_apply=all
#unconfigured_custom_firewall_zones_action=no_action
#DefaultZone=public
#CleanupOnExit=yes
#CleanupModulesOnExit=yes
#Lockdown=no
#IPv6_rpfilter=yes
#IndividualCalls=no
#LogDenied=off
#enable_logging_of_dropped_packets=no
#FirewallBackend=nftables
#FlushAllOnReload=yes
#RFC3964_IPv4=yes
#AllowZoneDrifting=no
#[firewall_conf_for_all--TMPLT:END]
###
#$h00_conf_firewalld_hash_g{inventory_host}{fwconf_tmplt_name--TMPLT}->
#{'unconfigured_custom_firewall_zones_action'}=no_action|remove
#{'DefaultZone'}=name_of_default_zone
#{'CleanupOnExit'}=yes|no
#{'CleanupModulesOnExit'}=yes|no
#{'Lockdown'}=yes|no
#{'IPv6_rpfilter'}=yes|no
#{'IndividualCalls'}=yes|no
#{'LogDenied'}=all|unicast|broadcast|multicast|off
#{'enable_logging_of_dropped_packets'}=yes|no
#{'FirewallBackend'}=nftables|iptables
#{'FlushAllOnReload'}=yes|no
#{'RFC3964_IPv4'}=yes|no
#{'AllowZoneDrifting'}=yes|no
######

######
our %h01_conf_ipset_templates_hash_g=();
#[some_ipset_template_name--TMPLT:BEGIN]
#ipset_name=some_ipset_name
#ipset_description=empty
#ipset_short_description=empty
#ipset_create_option_timeout=0
#ipset_create_option_hashsize=1024
#ipset_create_option_maxelem=65536
#ipset_create_option_family=inet
#ipset_type=some_ipset_type
#[some_ipset_template_name--TMPLT:END]
###
#$h01_conf_ipset_templates_hash_g{ipset_template_name--TMPLT}->
#{'ipset_name'}=value
#{'ipset_description'}=empty|value
#{'ipset_short_description'}=empty|value
#{'ipset_create_option_timeout'}=num
#{'ipset_create_option_hashsize'}=num
#{'ipset_create_option_maxelem'}=num
#{'ipset_create_option_family'}=inet|inet6
#{'ipset_type'}=hash:ip|hash:ip,port|hash:ip,mark|hash:net|hash:net,port|hash:net,iface|hash:mac|hash:ip,port,ip|hash:ip,port,net|hash:net,net|hash:net,port,net
######

######
our %h02_conf_custom_firewall_zones_templates_hash_g=();
#[some_zone--TMPLT:BEGIN]
#zone_name=some_zone--custom
#zone_description=
#zone_short_description=
#zone_target=
#zone_allowed_services=
#zone_allowed_ports=
#zone_allowed_protocols=
#zone_forward=
#zone_masquerade_general=
#zone_allowed_source_ports=
#zone_icmp_block_inversion=
#zone_icmp_block=
#[some_zone--TMPLT:END]
###
#$h02_conf_custom_firewall_zones_templates_hash_g{zone_teplate_name--TMPLT}->
#{'zone_name'}=some_zone--custom
#{'zone_description'}=empty|value
#{'zone_short_description'}=empty|value
#{'zone_target'}=ACCEPT|REJECT|DROP|default
#{'zone_allowed_services'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'service-0'}=1
	#{'service-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=service)
#{'zone_allowed_ports'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'port-0'}=1
	#{'port-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=port)
#{'zone_allowed_protocols'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'proto-0'}=1
	#{'proto-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=proto)
#{'zone_forward'}=yes|no
#{'zone_masquerade_general'}=yes|no
#{'zone_allowed_source_ports'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'port-0'}=1
	#{'port-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=port)
#{'zone_icmp_block_inversion'}=yes|no
#{'zone_icmp_block'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'icmptype-0'}=1
	#{'icmptype-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=icmptype)
######

######
our %h02_conf_standard_firewall_zones_templates_hash_g=();
#[public--TMPLT:BEGIN]
#zone_name=public
#zone_target=default
#zone_allowed_services=cockpit,dhcpv6-client,ssh
#zone_allowed_ports=empty
#zone_allowed_protocols=empty
#zone_forward=no
#zone_masquerade_general=no
#zone_allowed_source_ports=empty
#zone_icmp_block_inversion=no
#zone_icmp_block=empty
#[public--TMPLT:END]
###
#$h02_conf_standard_firewall_zones_templates_hash_g{zone_teplate_name--TMPLT}->
#{'zone_name'}=std_zone_name
#{'zone_target'}=ACCEPT|REJECT|DROP|default
#{'zone_allowed_services'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'service-0'}=1
	#{'service-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=service)
#{'zone_allowed_ports'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'port-0'}=1
	#{'port-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=proto)
#{'zone_allowed_protocols'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'proto-0'}=1
	#{'proto-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=proto)
#{'zone_forward'}=yes|no
#{'zone_masquerade_general'}=yes|no
#{'zone_allowed_source_ports'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'port-0'}=1
	#{'port-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=port)
#{'zone_icmp_block_inversion'}=yes|no
#{'zone_icmp_block'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'icmptype-0'}=1
	#{'icmptype-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=icmptype)
######

######
our %h03_conf_policy_templates_hash_g=();
#[some_policy--TMPLT:BEGIN]
#policy_name=some_policy_name
#policy_description=empty
#policy_short_description=empty
#policy_target=CONTINUE
#policy_priority=-1
#policy_allowed_services=empty
#policy_allowed_ports=empty
#policy_allowed_protocols=empty
#policy_masquerade_general=no
#policy_allowed_source_ports=empty
#policy_icmp_block=empty
#[some_policy--TMPLT:END]
###
#$h03_conf_policy_templates_hash_g{policy_tmplt_name--TMPLT}->
#{'policy_name'}=value
#{'policy_description'}=empty|value
#{'policy_short_description'}=empty|value
#{'policy_target'}=ACCEPT|REJECT|DROP|CONTINUE
#{'policy_priority'}=num (+/-)
#{'policy_allowed_services'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'service-0'}=1
	#{'service-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=service)
#{'policy_allowed_ports'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'port-0'}=1
	#{'port-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=port)
#{'policy_allowed_protocols'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'proto-0'}=1
	#{'proto-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=proto)
#{'policy_masquerade_general'}=yes|no
#{'policy_allowed_source_ports'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'port-0'}=1
	#{'port-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=port)
#{'policy_icmp_block'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'icmptype-0'}=1
	#{'icmptype-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=icmptype)
######

######
our %h04_conf_zone_forward_ports_sets_hash_g=();
#[some_forward_ports_set_name:BEGIN]
#port=80:proto=tcp:toport=8080:toaddr=192.168.1.60 (example)
#port=80:proto=tcp:toport=8080 (example)
#[some_forward_ports_set_name:END]
###
#$h04_conf_zone_forward_ports_sets_hash_g{set_name}->
    #{'rule-0'}=1
    #{'rule-1'}=1
    #etc
    #{'seq'}=[val-0,val-1] (val=rule)
######

######
our %h05_conf_zone_rich_rules_sets_hash_g=();
#[some_rich_rules_set_name:BEGIN]
#rule family=ipv4 forward-port to-port=8080 protocol=tcp port=80 (example)
#rule family=ipv4 source address=192.168.55.4/32 destination address=10.10.7.0/24 masquerade (example)
#[some_rich_rules_set_name:END]
###
#$h05_conf_zone_rich_rules_sets_hash_g{set_name}->
    #{'rule-0'}=1
    #{'rule-1'}=1
    #etc
    #{'seq'}=[val-0,val-1] (val=rule)
######

######
our %h66_conf_ipsets_FIN_hash_g=();
#INVENTORY_HOST         #IPSET_NAME_TMPLT_LIST
#all                    ipset1--TMPLT,ipset4all_public--TMPLT (example)
#10.3.2.2               ipset4public--TMPLT (example)
###
#$h66_conf_ipsets_FIN_hash_g{inventory_host}->
#{ipset_name_tmplt}=1;
######

######
our %h77_conf_zones_FIN_hash_g=();
#INVENTORY_HOST         #FIREWALL_ZONE_NAME_TMPLT       #INTERFACE_LIST   #SOURCE_LIST                                  #FORWARD_PORTS_SET      #RICH_RULES_SET
#all                    public--TMPLT                   ens1,ens2,ens3    10.10.16.0/24,ipset:ipset4all_public--TMPLT   empty                   empty (example)
#10.3.2.2               public--TMPLT                   empty             10.10.15.0/24,ipset:ipset4public--TMPLT       fw_ports_set4public     rich_rules_set4public (example)
#10.1.2.3,10.1.2.4      zone1--TMPLT                    eth0,eth1,ens01   empty                                         fw_ports_set4zone1      rich_rules_set4zone1 (example)
###
#$h77_conf_zones_FIN_hash_g{inventory_host}{firewall_zone_name_tmplt}->
#{'interface_list'}->;
    #{'interface-0'}=1
    #{'interface-1'}=1
    #etc
#{'source_list'}->
    #{'source-0'}=1
    #{'source-1'}=1
    #etc
#{'forward_ports_set'}=empty|fw_ports_set (FROM '04_conf_zone_forward_ports_sets')
#{'rich_rules_set'}=empty|rich_rules_set (FROM '05_conf_zone_rich_rules_sets')
######

######
our %h88_conf_policies_FIN_hash_g=();
#INVENTORY_HOST         #POLICY_NAME_TMPLT           	#INGRESS-FIREWALL_ZONE_NAME_TMPLT    	#EGRESS-FIREWALL_ZONE_NAME_TMPLT     	#FORWARD_PORTS_SET      #RICH_RULES_SET
#all                    policy_public2home--TMPLT       public--TMPLT                           home--TMPLT                             fw_ports_set1           rich_rules_set1 (example)
#10.3.2.2               policy_zoneone2zonetwo--TMPLT   zoneone--TMPLT                          zonetwo--TMPLT                          fw_ports_set2           rich_rules_set2 (example)
###
#$h88_conf_policies_FIN_hash_g{inventory_host}{policy_name_tmplt}->
#{'ingress-firewall_zone_name_tmplt'}=value
#{'egress-firewall_zone_name_tmplt'}=value
#{'forward_ports_set'}=empty|fw_ports_set (FROM '04_conf_zone_forward_ports_sets')
#{'rich_rules_set'}=empty|rich_rules_set (FROM '05_conf_zone_rich_rules_sets')
######

our ($exec_res_g,$exec_status_g)=(undef,'OK');
############VARS

############MAIN SEQ
while ( 1 ) { # ONE RUN CYCLE begin
    $exec_res_g=&read_inventory_file($inventory_conf_path_g,\%inventory_hosts_g);
    #$file_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
	$exec_status_g='FAIL';
	print "$exec_res_g\n";
	last;
    }

    $exec_res_g=&read_network_data_for_checks($ifcfg_backup_from_remote_nd_file_g,\%inv_hosts_network_data_g);
    #$file_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
	$exec_status_g='FAIL';
	print "$exec_res_g\n";
	last;
    }
    
    $exec_res_g=&read_00_conf_firewalld($f00_conf_firewalld_path_g,\%inventory_hosts_g,\%h00_conf_firewalld_hash_g);
    #$file_l,$inv_hosts_href_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
	$exec_status_g='FAIL';
	print "$exec_res_g\n";
	last;
    }
    
    $exec_res_g=&read_01_conf_ipset_templates($f01_conf_ipset_templates_path_g,\%h01_conf_ipset_templates_hash_g);
    #$file_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
	$exec_status_g='FAIL';
	print "$exec_res_g\n";
	last;
    }
    
    $exec_res_g=&read_02_conf_custom_firewall_zones_templates($f02_conf_custom_firewall_zones_templates_path_g,\%h02_conf_custom_firewall_zones_templates_hash_g);
    #$file_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
	$exec_status_g='FAIL';
	print "$exec_res_g\n";
	last;
    }
    
    $exec_res_g=&read_02_conf_standard_firewall_zones_templates($f02_conf_standard_firewall_zones_templates_path_g,\%h02_conf_standard_firewall_zones_templates_hash_g);
    #$file_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
	$exec_status_g='FAIL';
	print "$exec_res_g\n";
	last;
    }
    
    $exec_res_g=&read_03_conf_policy_templates($f03_conf_policy_templates_path_g,\%h03_conf_policy_templates_hash_g);
    #$file_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
	$exec_status_g='FAIL';
	print "$exec_res_g\n";
	last;
    }
    print Dumper(\%h03_conf_policy_templates_hash_g);
    last;
} # ONE RUN CYCLE end

system("echo $exec_status_g > GEN_DYN_FWRULES_STATUS");
if ( $exec_status_g!~/^OK$/ ) {
    print "EXEC_STATUS not OK. Exit!\n\n";
    exit;
}
############MAIN SEQ

############SUBROUTINES
######general subs
sub read_inventory_file {
    my ($file_l,$res_href_l)=@_;
    #file_l=$inventory_conf_path_g, res_href_l=hash-ref for %inventory_hosts_g
    my $proc_name_l='read_inventory_file';
            
    my ($line_l,$start_read_hosts_flag_l,$value_cnt_l)=(undef,0,0);
    
    if ( length($file_l)<1 or ! -e($file_l) ) { return "fail [$proc_name_l]. File='$file_l' is not exists"; }
    
    open(INVDATA,'<',$file_l);
    while ( <INVDATA> ) {
    	$line_l=$_;
    	$line_l=~s/\n$|\r$|\n\r$|\r\n$//g;
    	while ($line_l=~/\t/) { $line_l=~s/\t/ /g; }
    	$line_l=~s/\s+/ /g;
    	$line_l=~s/^ //g;
	$line_l=~s/ $//g;
    	if ( length($line_l)>0 && $line_l!~/^\#/ ) {
	    if ( $line_l=~/^\[rhel8_firewall_hosts\]/ && $start_read_hosts_flag_l==0 ) { $start_read_hosts_flag_l=1; }
	    elsif ( $start_read_hosts_flag_l==1 && $line_l=~/^\[rhel8_firewall_hosts\:vars\]/ ) {
		$start_read_hosts_flag_l=0;
		last;
	    }
	    elsif ( $start_read_hosts_flag_l==1 ) {
		${$res_href_l}{$line_l}=1;
		$value_cnt_l++;
	    }
    	}
    }
    close(INVDATA);
    
    ($line_l,$start_read_hosts_flag_l)=(undef,undef);
    
    if ( $value_cnt_l<1 ) { return "fail [$proc_name_l]. No needed data at file='$file_l'"; }
    
    return 'OK';
}

sub read_network_data_for_checks {
    my ($file_l,$res_href_l)=@_;
    #file_l=$ifcfg_backup_from_remote_nd_file_g
    #res_href_l=hash-ref for %inv_hosts_network_data_g
    my $proc_name_l='read_network_data_for_checks';
        
    my ($line_l,$value_cnt_l)=(undef,0);
    my @arr0_l=undef;

    if ( length($file_l)<1 or ! -e($file_l) ) { return "fail [$proc_name_l]. File='$file_l' is not exists"; }

    open(NDATA,'<',$file_l);
    while ( <NDATA> ) {
        $line_l=$_;
        $line_l=~s/\n$|\r$|\n\r$|\r\n$//g;
        while ($line_l=~/\t/) { $line_l=~s/\t/ /g; }
        $line_l=~s/\s+/ /g;
        $line_l=~s/^ //g;
	$line_l=~s/ $//g;
        if ( length($line_l)>0 && $line_l!~/^\#/ ) {
            #INV_HOST-0       #INT_NAME-1       #IPADDR-2
	    #$inv_hosts_network_data_g{inv_host}{int_name}=ipaddr
	    ###
            @arr0_l=split(' ',$line_l);
            ${$res_href_l}{$arr0_l[0]}{$arr0_l[1]}=$arr0_l[2];
	    $value_cnt_l++;
        }
    }
    close(NDATA);
    
    $line_l=undef;

    if ( $value_cnt_l<1 ) { return "fail [$proc_name_l]. No needed data at file='$file_l'"; }

    return 'OK';
}

sub read_00_conf_firewalld {
    my ($file_l,$inv_hosts_href_l,$res_href_l)=@_;
    #file_l=$f00_conf_firewalld_path_g
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #res_href_l=hash-ref for %h00_conf_firewalld_hash_g
    my $proc_name_l='read_00_conf_firewalld';
    
    #[firewall_conf_for_all--TMPLT:BEGIN]
    #host_list_for_apply=all
    #unconfigured_custom_firewall_zones_action=no_action
    #DefaultZone=public
    #CleanupOnExit=yes
    #CleanupModulesOnExit=yes
    #Lockdown=no
    #IPv6_rpfilter=yes
    #IndividualCalls=no
    #LogDenied=off
    #enable_logging_of_dropped_packets=no
    #FirewallBackend=nftables
    #FlushAllOnReload=yes
    #RFC3964_IPv4=yes
    #AllowZoneDrifting=no
    #[firewall_conf_for_all--TMPLT:END]
    ###
    #$h00_conf_firewalld_hash_g{inventory_host}{fwconf_tmplt_name--TMPLT}->
    #{'unconfigured_custom_firewall_zones_action'}=no_action|remove
    #{'DefaultZone'}=name_of_default_zone
    #{'CleanupOnExit'}=yes|no
    #{'CleanupModulesOnExit'}=yes|no
    #{'Lockdown'}=yes|no
    #{'IPv6_rpfilter'}=yes|no
    #{'IndividualCalls'}=yes|no
    #{'LogDenied'}=all|unicast|broadcast|multicast|off
    #{'enable_logging_of_dropped_packets'}=yes|no
    #{'FirewallBackend'}=nftables|iptables
    #{'FlushAllOnReload'}=yes|no
    #{'RFC3964_IPv4'}=yes|no
    #{'AllowZoneDrifting'}=yes|no

    my $arr_el0_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my $exec_res_l=undef;
    my $return_str_l='OK';
    
    my @inv_hosts_arr_l=();
    
    my %res_tmp_lv0_l=();
	#key0=tmplt_name, key1=param, value=value filtered by regex
    my %res_tmp_lv1_l=();
	#key0=inv-host, key1=param (except = host_list_for_apply), value=hash ref for %res_tmp_lv0_l
    my %cfg_params_and_regex_l=(
	'host_list_for_apply'=>'^all$|\S+',
	'unconfigured_custom_firewall_zones_action'=>'^no_action$|^remove$',
	'DefaultZone'=>'^\S+$',
	'CleanupOnExit'=>'^yes$|^no$',
	'CleanupModulesOnExit'=>'^yes$|^no$',
	'Lockdown'=>'^yes$|^no$',
	'IPv6_rpfilter'=>'^yes$|^no$',
	'IndividualCalls'=>'^yes$|^no$',
	'LogDenied'=>'^all$|^unicast$|^broadcast$|^multicast$|^off$',
	'enable_logging_of_dropped_packets'=>'^yes$|^no$',
	'FirewallBackend'=>'^nftables$|^iptables$',
	'FlushAllOnReload'=>'^yes$|^no$',
	'RFC3964_IPv4'=>'^yes$|^no$',
	'AllowZoneDrifting'=>'^yes$|^no$'
    );

    $exec_res_l=&read_param_value_templates_from_config($file_l,\%cfg_params_and_regex_l,\%res_tmp_lv0_l);
    #$file_l,$regex_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    
    # fill res_tmp_lv1_l
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
	#hkey0_l=tmplt_name, hval0_l=hash of params
	if ( ${$hval0_l}{'host_list_for_apply'} eq 'all' ) {
	    while ( ($hkey1_l,$hval1_l)=each %{$inv_hosts_href_l} ) {
		#$hkey1_l=inv-host from inv-host-hash
		push(@inv_hosts_arr_l,$hkey1_l);
	    }
	    
	    ($hkey1_l,$hval1_l)=(undef,undef);
	}
	else {
	    @inv_hosts_arr_l=split(/\,/,${$hval0_l}{'host_list_for_apply'});
	}
	delete(${$hval0_l}{'host_list_for_apply'});
	
	foreach $arr_el0_l ( @inv_hosts_arr_l ) {
	    #arr_el0_l=inv-host
	    %{$res_tmp_lv1_l{$arr_el0_l}}=%{$hval0_l};
	}
	
	$arr_el0_l=undef;
	@inv_hosts_arr_l=();
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    @inv_hosts_arr_l=();
    %res_tmp_lv0_l=();
    ###

    # check for not existing configs for inv-hosts
    while ( ($hkey0_l,$hval0_l)=each %{$inv_hosts_href_l} ) {
	# hkey0_l = inv-host-name
	if ( !exists($res_tmp_lv1_l{$hkey0_l}) ) {
	    $return_str_l="fail [$proc_name_l]. Host='$hkey0_l' have not configuration";
	    last;
	}
    }
    ###
    
    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###
    
    return $return_str_l;
}

sub read_01_conf_ipset_templates {
    my ($file_l,$res_href_l)=@_;
    #file_l=$f01_conf_ipset_templates_path_g
    #res_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
    my $proc_name_l='read_01_conf_ipset_templates';

    #[some_ipset_template_name--TMPLT:BEGIN]
    #ipset_name=some_ipset_name
    #ipset_description=empty
    #ipset_short_description=empty
    #ipset_create_option_timeout=0
    #ipset_create_option_hashsize=1024
    #ipset_create_option_maxelem=65536
    #ipset_create_option_family=inet
    #ipset_type=some_ipset_type
    #[some_ipset_template_name--TMPLT:END]
    ###
    #$h01_conf_ipset_templates_hash_g{ipset_template_name--TMPLT}->
    #{'ipset_name'}=value
    #{'ipset_description'}=empty|value
    #{'ipset_short_description'}=empty|value
    #{'ipset_create_option_timeout'}=num
    #{'ipset_create_option_hashsize'}=num
    #{'ipset_create_option_maxelem'}=num
    #{'ipset_create_option_family'}=inet|inet6
    #{'ipset_type'}=hash:ip|hash:ip,port|hash:ip,mark|hash:net|hash:net,port|hash:net,iface|hash:mac|hash:ip,port,ip|hash:ip,port,net|hash:net,net|hash:net,port,net
    
    my $exec_res_l=undef;
    my $return_str_l='OK';

    my %res_tmp_lv0_l=();
	#key=param, value=value filtered by regex

    my %cfg_params_and_regex_l=(
	'ipset_name'=>'^\S+$',
	'ipset_description'=>'^empty$|^.{1,100}',
	'ipset_short_description'=>'^empty$|^.{1,20}',
	'ipset_create_option_timeout'=>'^\d+$',
	'ipset_create_option_hashsize'=>'^\d+$',
	'ipset_create_option_maxelem'=>'^\d+$',
	'ipset_create_option_family'=>'^inet$|^inet6$',
	'ipset_type'=>'^hash\:ip$|^hash\:ip\,port$|^hash\:ip\,mark$|^hash\:net$|^hash\:net\,port$|^hash\:net\,iface$|^hash\:mac$|^hash\:ip\,port\,ip$|^hash\:ip\,port\,net$|^hash\:net\,net$|^hash\:net\,port\,net$',
    );

    $exec_res_l=&read_param_value_templates_from_config($file_l,\%cfg_params_and_regex_l,\%res_tmp_lv0_l);
    #$file_l,$regex_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    
    # fill result hash
    %{$res_href_l}=%res_tmp_lv0_l;
    ###
    
    return $return_str_l;    
}

sub read_02_conf_custom_firewall_zones_templates {
    my ($file_l,$res_href_l)=@_;
    #file_l=$f02_conf_custom_firewall_zones_templates_path_g
    #res_href_l=hash-ref for %h02_conf_custom_firewall_zones_templates_hash_g
    my $proc_name_l='read_02_conf_custom_firewall_zones_templates';

    #[some_zone--TMPLT:BEGIN]
    #zone_name=some_zone--custom
    #zone_description=
    #zone_short_description=
    #zone_target=
    #zone_allowed_services=
    #zone_allowed_ports=
    #zone_allowed_protocols=
    #zone_forward=
    #zone_masquerade_general=
    #zone_allowed_source_ports=
    #zone_icmp_block_inversion=
    #zone_icmp_block=
    #[some_zone--TMPLT:END]
    ###
    #$h02_conf_custom_firewall_zones_templates_hash_g{zone_teplate_name--TMPLT}->
    #{'zone_name'}=some_zone--custom
    #{'zone_description'}=empty|value
    #{'zone_short_description'}=empty|value
    #{'zone_target'}=ACCEPT|REJECT|DROP|default
    #{'zone_allowed_services'}->
	#{'empty'}=1 or
	#{'list'}->
    	    #{'service-0'}=1
    	    #{'service-1'}=1
    	    #etc
	#{'seq'}=[val-0,val-1] (val=service)
    #{'zone_allowed_ports'}->
	#{'empty'}=1 or
	#{'list'}->
    	    #{'port-0'}=1
    	    #{'port-1'}=1
    	    #etc
	#{'seq'}=[val-0,val-1] (val=port)
    #{'zone_allowed_protocols'}->
	#{'empty'}=1 or
	#{'list'}->
    	    #{'proto-0'}=1
    	    #{'proto-1'}=1
    	    #etc
	#{'seq'}=[val-0,val-1] (val=proto)
    #{'zone_forward'}=yes|no
    #{'zone_masquerade_general'}=yes|no
    #{'zone_allowed_source_ports'}->
	#{'empty'}=1 or
	#{'list'}->
    	    #{'port-0'}=1
    	    #{'port-1'}=1
    	    #etc
	#{'seq'}=[val-0,val-1] (val=port)
    #{'zone_icmp_block_inversion'}=yes|no
    #{'zone_icmp_block'}->
	#{'empty'}=1 or
	#{'list'}->
    	    #{'icmptype-0'}=1
    	    #{'icmptype-1'}=1
    	    #etc
	#{'seq'}=[val-0,val-1] (val=icmptype)

    my $exec_res_l=undef;
    my $arr_el0_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my @split_arr0_l=();
    my $return_str_l='OK';
    my $param_list_regex_l='^zone_allowed_services$|^zone_allowed_protocols$|^zone_icmp_block$|^zone_allowed_ports$|^zone_allowed_source_ports$';

    my %res_tmp_lv0_l=();
	#key0=tmplt_name,key1=param, value=value filtered by regex
    my %res_tmp_lv1_l=();

    my %cfg_params_and_regex_l=(
	'zone_name'=>'^\S+\-\-custom$',
	'zone_description'=>'^empty$|^.{1,100}',
	'zone_short_description'=>'^empty$|^.{1,20}',
	'zone_target'=>'^ACCEPT$|^REJECT$|^DROP$|^default$',
	'zone_allowed_services'=>'^empty$|^.*$',
	'zone_allowed_ports'=>'^empty$|^.*$',
	'zone_allowed_protocols'=>'^empty$|^.*$',
	'zone_forward'=>'$yes$|^no$',
	'zone_masquerade_general'=>'$yes$|^no$',
	'zone_allowed_source_ports'=>'^empty$|^.*$',
	'zone_icmp_block_inversion'=>'$yes$|^no$',
	'zone_icmp_block'=>'^empty$|^.*$',
    );

    $exec_res_l=&read_param_value_templates_from_config($file_l,\%cfg_params_and_regex_l,\%res_tmp_lv0_l);
    #$file_l,$regex_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    
    # fill %res_tmp_lv1_l (postprocessing_v1_after_read_param_value_templates_from_config)
    $exec_res_l=&postprocessing_v1_after_read_param_value_templates_from_config($param_list_regex_l,\%res_tmp_lv0_l,\%res_tmp_lv1_l);
    #$param_list_regex_for_postproc_l,$src_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    ###
    
    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###
    
    return $return_str_l;    
}

sub read_02_conf_standard_firewall_zones_templates {
    my ($file_l,$res_href_l)=@_;
    #file_l=$f02_conf_standard_firewall_zones_templates_path_g
    #res_href_l=hash-ref for %h02_conf_standard_firewall_zones_templates_hash_g
    my $proc_name_l='read_02_conf_standard_firewall_zones_templates';

    #[public--TMPLT:BEGIN]
    #zone_name=public
    #zone_target=default
    #zone_allowed_services=cockpit,dhcpv6-client,ssh
    #zone_allowed_ports=empty
    #zone_allowed_protocols=empty
    #zone_forward=no
    #zone_masquerade_general=no
    #zone_allowed_source_ports=empty
    #zone_icmp_block_inversion=no
    #zone_icmp_block=empty
    #[public--TMPLT:END]
    ###
    #$h02_conf_standard_firewall_zones_templates_hash_g{zone_teplate_name--TMPLT}->
    #{'zone_name'}=std_zone_name
    #{'zone_target'}=ACCEPT|REJECT|DROP|default
    #{'zone_allowed_services'}->
	#{'empty'}=1 or
	#{'list'}->
	    #{'service-0'}=1
	    #{'service-1'}=1
	    #etc
	#{'seq'}=[val-0,val-1] (val=service)
    #{'zone_allowed_ports'}->
	#{'empty'}=1 or
	#{'list'}->
	    #{'port-0'}=1
	    #{'port-1'}=1
	    #etc
	#{'seq'}=[val-0,val-1] (val=port)
    #{'zone_allowed_protocols'}->
	#{'empty'}=1 or
	#{'list'}->
	    #{'proto-0'}=1
	    #{'proto-1'}=1
	    #etc
	#{'seq'}=[val-0,val-1] (val=proto)
    #{'zone_forward'}=yes|no
    #{'zone_masquerade_general'}=yes|no
    #{'zone_allowed_source_ports'}->
	#{'empty'}=1 or
	#{'list'}->
	    #{'port-0'}=1
	    #{'port-1'}=1
	    #etc
	#{'seq'}=[val-0,val-1] (val=port)
    #{'zone_icmp_block_inversion'}=yes|no
    #{'zone_icmp_block'}->
	#{'empty'}=1 or
	#{'list'}->
	    #{'icmptype-0'}=1
	    #{'icmptype-1'}=1
	    #etc
	#{'seq'}=[val-0,val-1] (val=icmptype)
    
    my $exec_res_l=undef;
    my $arr_el0_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my @split_arr0_l=();
    my $return_str_l='OK';
    my $param_list_regex_l='^zone_allowed_services$|^zone_allowed_protocols$|^zone_icmp_block$|^zone_allowed_ports$|^zone_allowed_source_ports$';

    my %res_tmp_lv0_l=();
	#key0=tmplt_name,key1=param, value=value filtered by regex
    my %res_tmp_lv1_l=();

    my %cfg_params_and_regex_l=(
	'zone_name'=>'^block$|^dmz$|^drop$|^external$|^internal$|^public$|^trusted$|^work$|^home$',
	'zone_target'=>'^ACCEPT$|^REJECT$|^DROP$|^default$',
	'zone_allowed_services'=>'^empty$|^.*$',
	'zone_allowed_ports'=>'^empty$|^.*$',
	'zone_allowed_protocols'=>'^empty$|^.*$',
	'zone_forward'=>'$yes$|^no$',
	'zone_masquerade_general'=>'$yes$|^no$',
	'zone_allowed_source_ports'=>'^empty$|^.*$',
	'zone_icmp_block_inversion'=>'$yes$|^no$',
	'zone_icmp_block'=>'^empty$|^.*$',
    );

    $exec_res_l=&read_param_value_templates_from_config($file_l,\%cfg_params_and_regex_l,\%res_tmp_lv0_l);
    #$file_l,$regex_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    
    # fill %res_tmp_lv1_l (postprocessing_v1_after_read_param_value_templates_from_config)
    $exec_res_l=&postprocessing_v1_after_read_param_value_templates_from_config($param_list_regex_l,\%res_tmp_lv0_l,\%res_tmp_lv1_l);
    #$param_list_regex_for_postproc_l,$src_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    ###
    
    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###
    
    return $return_str_l;    
}

sub read_03_conf_policy_templates {
    my ($file_l,$res_href_l)=@_;
    #file_l=$f03_conf_policy_templates_path_g
    #res_href_l=hash-ref for %h02_conf_policy_templates_hash_g
    my $proc_name_l='read_03_conf_policy_templates';

    #[some_policy--TMPLT:BEGIN]
    #policy_name=some_policy_name
    #policy_description=empty
    #policy_short_description=empty
    #policy_target=CONTINUE
    #policy_priority=-1
    #policy_allowed_services=empty
    #policy_allowed_ports=empty
    #policy_allowed_protocols=empty
    #policy_masquerade_general=no
    #policy_allowed_source_ports=empty
    #policy_icmp_block=empty
    #[some_policy--TMPLT:END]
    ###
    #$h03_conf_policy_templates_hash_g{policy_tmplt_name--TMPLT}->
    #{'policy_name'}=value
    #{'policy_description'}=empty|value
    #{'policy_short_description'}=empty|value
    #{'policy_target'}=ACCEPT|REJECT|DROP|CONTINUE
    #{'policy_priority'}=num (+/-)
    #{'policy_allowed_services'}->
	#{'empty'}=1 or
	#{'list'}->
	    #{'service-0'}=1
	    #{'service-1'}=1
	    #etc
	#{'seq'}=[val-0,val-1] (val=service)
    #{'policy_allowed_ports'}->
	#{'empty'}=1 or
	#{'list'}->
	    #{'port-0'}=1
	    #{'port-1'}=1
	    #etc
	#{'seq'}=[val-0,val-1] (val=port)
    #{'policy_allowed_protocols'}->
	#{'empty'}=1 or
	#{'list'}->
	    #{'proto-0'}=1
	    #{'proto-1'}=1
	    #etc
	#{'seq'}=[val-0,val-1] (val=proto)
    #{'policy_masquerade_general'}=yes|no
    #{'policy_allowed_source_ports'}->
	#{'empty'}=1 or
	#{'list'}->
	    #{'port-0'}=1
	    #{'port-1'}=1
	    #etc
	#{'seq'}=[val-0,val-1] (val=port)
    #{'policy_icmp_block'}->
	#{'empty'}=1 or
	#{'list'}->
	    #{'icmptype-0'}=1
	    #{'icmptype-1'}=1
	    #etc
	#{'seq'}=[val-0,val-1] (val=icmptype)

    my $exec_res_l=undef;
    my $arr_el0_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my @split_arr0_l=();
    my $return_str_l='OK';
    my $param_list_regex_l='^policy_allowed_services$|^policy_allowed_protocols$|^policy_icmp_block$|^policy_allowed_ports$|^policy_allowed_source_ports$';

    my %res_tmp_lv0_l=();
	#key0=tmplt_name,key1=param, value=value filtered by regex
    my %res_tmp_lv1_l=();

    my %cfg_params_and_regex_l=(
	'policy_name'=>'^\S+$',
	'policy_description'=>'^empty$|^.{1,100}',
	'policy_short_description'=>'^empty$|^.{1,20}',
	'policy_target'=>'^ACCEPT$|^REJECT$|^DROP$|^CONTINUE$',
	'policy_priority'=>'^\d+$|^\-\d+$',
	'policy_allowed_services'=>'^empty$|^.*$',
	'policy_allowed_ports'=>'^empty$|^.*$',
	'policy_allowed_protocols'=>'^empty$|^.*$',
	'policy_masquerade_general'=>'$yes$|^no$',
	'policy_allowed_source_ports'=>'^empty$|^.*$',
	'policy_icmp_block'=>'^empty$|^.*$',
    );

    $exec_res_l=&read_param_value_templates_from_config($file_l,\%cfg_params_and_regex_l,\%res_tmp_lv0_l);
    #$file_l,$regex_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    
    # fill %res_tmp_lv1_l (postprocessing_v1_after_read_param_value_templates_from_config)
    $exec_res_l=&postprocessing_v1_after_read_param_value_templates_from_config($param_list_regex_l,\%res_tmp_lv0_l,\%res_tmp_lv1_l);
    #$param_list_regex_for_postproc_l,$src_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    ###
    
    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###
    
    return $return_str_l;    
}
######general subs

######other subs
sub read_param_value_templates_from_config {
    my ($file_l,$regex_href_l,$res_href_l)=@_;
    #file_l=config with templates
    #regex_href_l=hash-ref for %cfg_params_and_regex_l
    #res_href_l=hash-ref for result-hash
    my $proc_name_l='read_param_value_templates_from_config';

    my ($line_l)=(undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my ($read_tmplt_flag_l)=(0);
    my ($tmplt_name_begin_l,$tmplt_name_end_l)=(undef,undef);
    my $return_str_l='OK';

    my @split_arr0_l=();

    my %res_tmp_lv0_l=();
	#key=param, value=value filtered by regex
    my %uniq_tmplt_name_check_l=();
	#key=tmplt_name, value=1
    
    if ( length($file_l)<1 or ! -e($file_l) ) { return "fail [$proc_name_l]. File='$file_l' is not exists"; }

    # read file
    open(CONF_TMPLT,'<',$file_l);
    while ( <CONF_TMPLT> ) {
        $line_l=$_;
        $line_l=~s/\n$|\r$|\n\r$|\r\n$//g;
        while ($line_l=~/\t/) { $line_l=~s/\t/ /g; }
        $line_l=~s/\s+/ /g;
        $line_l=~s/^ //g;
	$line_l=~s/ $//g;
	
	$line_l=~s/ \,/\,/g;
	$line_l=~s/\, /\,/g;

	$line_l=~s/ \=/\=/g;
	$line_l=~s/\= /\=/g;

        if ( length($line_l)>0 && $line_l!~/^\#/ ) {
	    if ( $line_l=~/^\[(\S+\-\-TMPLT)\:BEGIN\]$/ ) { # if cfg block begin
		$tmplt_name_begin_l=$1;
		$read_tmplt_flag_l=1;
		if ( exists($uniq_tmplt_name_check_l{$tmplt_name_begin_l}) ) {
		    $return_str_l="fail [$proc_name_l]. Duplicated template='$tmplt_name_begin_l'. Check and correct config='$file_l'";
		    last;
		}
		$uniq_tmplt_name_check_l{$tmplt_name_begin_l}=1;
	    }
	    elsif ( $read_tmplt_flag_l==1 && $line_l=~/^\[(\S+\-\-TMPLT)\:END\]$/ ) { # if cfg block ends
		$tmplt_name_end_l=$1;
		if ( $tmplt_name_begin_l eq $tmplt_name_end_l ) { # if correct begin and end of template
		    $read_tmplt_flag_l=0;
		    $tmplt_name_begin_l='notmplt';
		}
		else { # if incorrect begin and end of template
		    $return_str_l="fail [$proc_name_l]. Tmplt_name_begin ('$tmplt_name_begin_l') != tmplt_name_end ('$tmplt_name_end_l'). Check and correct config='$file_l'";
		    last;
		}
	    }
	    elsif ( $read_tmplt_flag_l==1 && $tmplt_name_begin_l ne 'notmplt' ) { # if cfg param + value
		@split_arr0_l=split(/\=/,$line_l);
		
		if ( exists(${$regex_href_l}{$split_arr0_l[0]}) && $split_arr0_l[1]=~/${$regex_href_l}{$split_arr0_l[0]}/ ) {
		    ($res_tmp_lv0_l{$tmplt_name_begin_l}{$split_arr0_l[0]})=$split_arr0_l[1]=~/(${$regex_href_l}{$split_arr0_l[0]})/;
		}
		elsif ( exists(${$regex_href_l}{$split_arr0_l[0]}) && $split_arr0_l[1]!~/${$regex_href_l}{$split_arr0_l[0]}/ ) {
		    $return_str_l="fail [$proc_name_l]. For param='$split_arr0_l[0]' value ('$split_arr0_l[1]') is incorrect (tmplt_name='$tmplt_name_begin_l')";
		    last;
		}
		elsif ( !exists(${$regex_href_l}{$split_arr0_l[0]}) ) {
		    $return_str_l="fail [$proc_name_l]. Param='$split_arr0_l[0]' is not allowed (tmplt_name='$tmplt_name_begin_l')";
		    last;
		}
		@split_arr0_l=();
	    }
	}
    }
    close(CONF_TMPLT);
        
    $line_l=undef;
    ($tmplt_name_begin_l,$tmplt_name_end_l)=(undef,undef);
    @split_arr0_l=();

    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; } # check for return_str err after lv1-read
    ###

    # check for not existsing params
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
	# hkey0_l = tmplt_name
	# hval0_l = hash with params
	while ( ($hkey1_l,$hval1_l)=each %{$regex_href_l} ) {
	    #hkey1_l = param
	    if ( !exists(${$hval0_l}{$hkey1_l}) ) {
		$return_str_l="fail [$proc_name_l]. Param '$hkey1_l' is not exists at cfg for tmplt_name='$hkey0_l'";
		last;
	    }
	}
	if ( $return_str_l!~/^OK$/ ) { last; }
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    ($hkey1_l,$hval1_l)=(undef,undef);
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; } # check for return_str err after 'check for not existsing params'
    ###

    # fill result hash
    %{$res_href_l}=%res_tmp_lv0_l;
    ###
    
    %res_tmp_lv0_l=();
    
    return $return_str_l;    
}

sub read_param_only_templates_from_config {
    my ($file_l,$res_href_l)=@_;
    #file_l=config with templates
    #res_href_l=hash-ref for result-hash
    my $proc_name_l='read_param_only_templates_from_config';

    my ($line_l)=(undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my ($read_tmplt_flag_l)=(0);
    my ($tmplt_name_begin_l,$tmplt_name_end_l)=(undef,undef);
    my $return_str_l='OK';

    my @split_arr0_l=();

    my %res_tmp_lv0_l=();
	#key=param, value=1
    my %uniq_tmplt_name_check_l=();
	#key=tmplt_name, value=1
    
    if ( length($file_l)<1 or ! -e($file_l) ) { return "fail [$proc_name_l]. File='$file_l' is not exists"; }

    # read file
    open(CONF_TMPLT,'<',$file_l);
    while ( <CONF_TMPLT> ) {
        $line_l=$_;
        $line_l=~s/\n$|\r$|\n\r$|\r\n$//g;
        while ($line_l=~/\t/) { $line_l=~s/\t/ /g; }
        $line_l=~s/\s+/ /g;
        $line_l=~s/^ //g;
	$line_l=~s/ $//g;
	
	$line_l=~s/ \./\./g;
	$line_l=~s/\. /\./g;

	$line_l=~s/ \:/\:/g;
	$line_l=~s/\: /\:/g;

	$line_l=~s/ \=/\=/g;
	$line_l=~s/\= /\=/g;

        if ( length($line_l)>0 && $line_l!~/^\#/ ) {
	    if ( $line_l=~/^\[(\S+)\:BEGIN\]$/ ) { # if cfg block begin
		$tmplt_name_begin_l=$1;
		$read_tmplt_flag_l=1;
		if ( exists($uniq_tmplt_name_check_l{$tmplt_name_begin_l}) ) {
		    $return_str_l="fail [$proc_name_l]. Duplicated template='$tmplt_name_begin_l'. Check and correct config='$file_l'";
		    last;
		}
		$uniq_tmplt_name_check_l{$tmplt_name_begin_l}=1;
	    }
	    elsif ( $read_tmplt_flag_l==1 && $line_l=~/^\[(\S+)\:END\]$/ ) { # if cfg block ends
		$tmplt_name_end_l=$1;
		if ( $tmplt_name_begin_l eq $tmplt_name_end_l ) { # if correct begin and end of template
		    $read_tmplt_flag_l=0;
		    $tmplt_name_begin_l='notmplt';
		}
		else { # if incorrect begin and end of template
		    $return_str_l="fail [$proc_name_l]. Tmplt_name_begin ('$tmplt_name_begin_l') != tmplt_name_end ('$tmplt_name_end_l'). Check and correct config='$file_l'";
		    last;
		}
	    }
	    elsif ( $read_tmplt_flag_l==1 && $tmplt_name_begin_l ne 'notmplt' ) { # if param str
		$res_tmp_lv0_l{$line_l}=1;
	    }
	}
    }
    close(CONF_TMPLT);
        
    $line_l=undef;
    ($tmplt_name_begin_l,$tmplt_name_end_l)=(undef,undef);

    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; } # check for return_str err after lv1-read
    ###

    # fill result hash
    %{$res_href_l}=%res_tmp_lv0_l;
    ###
    
    %res_tmp_lv0_l=();
    
    return $return_str_l;    
}

sub postprocessing_v1_after_read_param_value_templates_from_config {
    my ($param_list_regex_for_postproc_l,$src_href_l,$res_href_l)=@_;
    #$param_list_regex_for_postproc_l = string like '^zone_allowed_services$|^zone_allowed_protocols$|^zone_icmp_block$|^zone_allowed_ports$|^zone_allowed_source_ports$'
    #$src_href_l=hash ref for result hash of '&read_templates_from_config'
    #$res_href_lhash ref for result hash
    my $proc_name_l='postprocessing_v1_after_read_param_value_templates_from_config';
    
    my $arr_el0_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my @split_arr0_l=();
    my $return_str_l='OK';
    
    while ( ($hkey0_l,$hval0_l)=each %{$src_href_l} ) {
	#hkey0_l=zone_tmpltname, hval0_l=hash ref with params and values
	while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) {
	    #hkey1_l=param_name, hval1_l=param_value
	    if ( $hkey1_l=~/$param_list_regex_for_postproc_l/ ) { #if regex list params
		if ( $hval1_l!~/^empty$/ ) { # if regex list params and value is not empty
		    @split_arr0_l=split(/\,/,$hval1_l);
		    foreach $arr_el0_l ( @split_arr0_l ) {
			if ( $hkey1_l=~/_ports$/ ) { # if need to check values with ports (udp/tcp)
			    $arr_el0_l=~s/\/ /\//g;
			    $arr_el0_l=~s/ \//\//g;
			    if ( $arr_el0_l=~/^\d+\/tcp$|^\d+\/udp$|^\d+\-\d+\/tcp$|^\d+\-\d+\/udp/ ) {
				if ( !exists(${$res_href_l}{$hkey0_l}{$hkey1_l}{'list'}{$arr_el0_l}) ) { push(@{${$res_href_l}{$hkey0_l}{$hkey1_l}{'seq'}},$arr_el0_l); }
				${$res_href_l}{$hkey0_l}{$hkey1_l}{'list'}{$arr_el0_l}=1;
			    }
			    else {
				$return_str_l="fail [$proc_name_l]. For param='$hkey1_l' port must be like portNUM/tcp|portNUM/udp|portBEGIN-portEND/tcp|portBEGIN-portEND/udp";
				last;
			    }
			}
			else {
			    if ( !exists(${$res_href_l}{$hkey0_l}{$hkey1_l}{'list'}{$arr_el0_l}) ) { push(@{${$res_href_l}{$hkey0_l}{$hkey1_l}{'seq'}},$arr_el0_l); }
			    ${$res_href_l}{$hkey0_l}{$hkey1_l}{'list'}{$arr_el0_l}=1;
			}
		    }
		    
		    $arr_el0_l=undef;
		    @split_arr0_l=();
		    
		    if ( $return_str_l!~/^OK$/ ) { last; }
		}
		else { ${$res_href_l}{$hkey0_l}{$hkey1_l}{'empty'}=1; } # regex params and value = empty
	    }
	    else { ${$res_href_l}{$hkey0_l}{$hkey1_l}=$hval1_l; } # just param=value
	}
	
	($hkey1_l,$hval1_l)=(undef,undef);
	
	if ( $return_str_l!~/^OK$/ ) { last; }
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    ($hkey1_l,$hval1_l)=(undef,undef);
    %{$src_href_l}=();
    
    return $return_str_l;
}

sub check_port_for_apply_to_fw_conf {
    my ($port_str_l)=@_;
    #port=NUM/udp, NUM/tcp, NUM_begin-NUM_end/tcp, NUM_begin-NUM_end/udp
    my $proc_name_l='check_port_for_apply_to_fw_conf';
    
    my $port_num_l=undef;
    my $return_str_l='OK';
    
    if ( $port_str_l=~/^(\d+)\/tcp$|^(\d+)\/udp$/ ) {
	($port_num_l)=$port_str_l=~/^(\d+)\//;
	$port_num_l=int($port_num_l);
    }
    elsif ( $port_str_l=~/^\d+\-\d+\/tcp$|^\d+\-\d+\/udp$/ ) {
	
    }
    
    return $return_str_l;
}
######other subs
############SUBROUTINES

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )