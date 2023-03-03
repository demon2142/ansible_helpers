#!/usr/bin/perl

###SCRIPT for create subfolders and manipulate ipset-files for each inventory host

use strict;
use warnings;
use Cwd;
use Data::Dumper;

our ($self_dir_g,$script_name_g)=Cwd::abs_path($0)=~/(.*[\/\\])(\S+)$/;

############ARGV
our $inventory_conf_path_g='no';

if ( defined($ARGV[0]) && length($ARGV[0])>0 ) {
    $inventory_conf_path_g=$ARGV[0];
}
############ARGV

############CFG file
our $conf_temp_apply_g=$self_dir_g.'/additional_configs/config_temporary_apply_fwrules';
our $f00_conf_divisions_for_inv_hosts_path_g=$self_dir_g.'/fwrules_configs/00_conf_divisions_for_inv_hosts';
our $f01_conf_ipset_templates_path_g=$self_dir_g.'/fwrules_configs/01_conf_ipset_templates';
our $f66_conf_ipsets_FIN_path_g=$self_dir_g.'/fwrules_configs/66_conf_ipsets_FIN';
############CFG file

############STATIC VARS
our $remote_dir_for_absible_helper_g='$HOME/ansible_helpers/conf_firewalld'; # dir for creating/manipulate files at remote side
our $scripts_for_remote_dir_g=$self_dir_g.'/playbooks/scripts_for_remote';
our $dyn_ipsets_files_dir_g=$scripts_for_remote_dir_g.'/fwrules_files/ipsets'; # dir for recreate shell-scripts for executing it at remote side (if need)
############STATIC VARS

############VARS
######
our %inv_hosts_tmp_apply_fwrules_g=(); #key=inv_host/common, value=rollback_ifcfg_timeout
######

######
our %inventory_hosts_g=(); # for checks of h00_conf_firewalld_hash_g/h66_conf_ipsets_FIN_hash_g/h77_conf_zones_FIN_hash_g/h88_conf_policies_FIN_hash_g
# and operate with 'all' (apply for all inv hosts) options
###
#Key=inventory_host, value=1
######

######
our %h00_conf_divisions_for_inv_hosts_hash_g=();
#DIVISION_NAME/GROUP_NAME       #LIST_OF_HOSTS
###
#$h00_conf_divisions_for_inv_hosts_hash_g{group_name}{inv-host}=1;
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
#$h01_conf_ipset_templates_hash_g{'temporary/permanent'}{ipset_template_name--TMPLT}->
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
our %h66_conf_ipsets_FIN_hash_g=();
#INVENTORY_HOST         #IPSET_NAME_TMPLT_LIST
#all                    ipset1--TMPLT,ipset4all_public--TMPLT (example)
#10.3.2.2               ipset4public--TMPLT (example)
###
#$h66_conf_ipsets_FIN_hash_g{'temporary/permanent'}{inventory_host}->
    #{ipset_name_tmplt-0}=1;
    #{ipset_name_tmplt-1}=1;
    #etc
######

our ($exec_res_g,$exec_status_g)=(undef,'OK');
############VARS

############MAIN SEQ
system("mkdir -p $dyn_ipsets_files_dir_g");
system("rm -rf $dyn_ipsets_files_dir_g/*");

while ( 1 ) { # ONE RUN CYCLE begin
    
    last;
} # ONE RUN CYCLE end

system("echo $exec_status_g > $self_dir_g/GEN_DYN_FWRULES_STATUS");
if ( $exec_status_g!~/^OK$/ ) {
    print "EXEC_STATUS not OK. Exit!\n\n";
    exit;
}
############MAIN SEQ


#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
