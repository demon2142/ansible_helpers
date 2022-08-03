#!/usr/bin/perl

use strict;
use warnings;
use Cwd;

our ($self_dir_g,$script_name_g)=Cwd::abs_path($0)=~/(.*[\/\\])(\S+)$/;

###CFG
our $conf_file_g=$self_dir_g.'config';
###CFG

############VARS
our $line_g=undef;
our $arr_el0_g=undef;
our $skip_conf_line_g=0;
our ($inv_host_g,$conf_id_g,$conf_type_g,$int_list_str_g,$hwaddr_list_str_g,$vlan_id_g,$bond_name_g,$brigde_name_g,$ipaddr_opts_g,$bond_opts_g)=(undef,undef,undef,undef,undef,undef,undef,undef,undef,undef);
######
our %cfg0_hash_g=();
#$cfg0_hash_g{inv_host-conf_id}{conf_type}{'main'}=[inv_host,conf_id,vlan_id,bond_name,brigde_name];
#$cfg0_hash_g{inv_host-conf_id}{conf_type}{'int_list'}=[array of interfaces];
#$cfg0_hash_g{inv_host-conf_id}{conf_type}{'hwaddr_list'}=[array of hwaddr];
#$cfg0_hash_g{inv_host-conf_id}{conf_type}{'ipaddr_opts'}=[array of ipaddr opts];
#$cfg0_hash_g{inv_host-conf_id}{conf_type}{'bond_opts'}=bond_opts_string_for_ifcfg;
######
our %cfg0_uniq_check=();
#Checks (uniq) for novlan interfaces at current inv_host.
#$cfg0_uniq_check{inv_host}{'common'}{interface_name}=conf_id; #if interface_name ne 'no' and vlan_id eq 'no'.
#$cfg0_uniq_check{inv_host}{'common'}{hwaddr}=conf_id; if vlan_id eq 'no'.
#$cfg0_uniq_check{inv_host}{'common'}{bond_name}=conf_id; #if bond_name ne 'no' and vlan_id eq 'no'.
#$cfg0_uniq_check{inv_host}{'common'}{bridge_name}=conf_id; #if bridge_name ne 'no' and vlan_id eq 'no'.
#$cfg0_uniq_check{inv_host}{'common'}{ipaddr}=conf_id; #if ipaddr_opts ne 'dhcp'.
###
#Checks (uniq) for vlan interfaces at current inv_host.
#$cfg0_uniq_check{inv_host}{'vlan'}{vlan_id}=conf_id; #if vlan_id ne 'no'.
#$cfg0_uniq_check{inv_host}{'vlan'}{interface_name-vlan_id}=conf_id; #if vlan_id ne 'no'.
#$cfg0_uniq_check{inv_host}{'vlan'}{hwaddr-vlan_id}=conf_id; #if vlan_id ne 'no'.
#$cfg0_uniq_check{inv_host}{'vlan'}{bond_name-vlan_id}=conf_id; #if vlan_id ne 'no' and bond_name ne 'no'.
#$cfg0_uniq_check{inv_host}{'vlan'}{bridge_name-vlan_id}=conf_id; #if vlan_id ne 'no' and bridge_name ne 'no'.
###
#Checks (uniq) for interfaces at config (for all inv_hosts)
#$cfg0_uniq_check{'all_hosts'}{hwaddr}=inv_host;
#$cfg0_uniq_check{'all_hosts'}{ipaddr}=inv_host; #if ipaddr ne 'dhcp'.
######
our %cfg_ready_hash_g=();
our @int_list_arr_g=();
our @hwaddr_list_arr_g=();
our @ipaddr_opts_arr_g=();
our @bond_opts_arr_g=();
our $bond_opts_str_g='mode=4 xmit_hash_policy=2 lacp_rate=1 miimon=100';
############VARS

###MAIN SEQ
open(CONF,'<',$conf_file_g);
while ( <CONF> ) {
    $line_g=$_;
    $line_g=~s/\n$|\r$|\n\r$|\r\n$//g;
    while ($line_g=~/\t/) { $line_g=~s/\t/ /g; }
    $line_g=~s/\s+/ /g;
    $line_g=~s/^ //g;
    if ( length($line_g)>0 && $line_g!~/^\#/ ) {
	$line_g=~s/ \,/\,/g;
	$line_g=~s/\, /\,/g;
	$line_g=~s/ \, /\,/g;
	$skip_conf_line_g=0;
	($inv_host_g,$conf_id_g,$conf_type_g,$int_list_str_g,$hwaddr_list_str_g,$vlan_id_g,$bond_name_g,$brigde_name_g,$ipaddr_opts_g,$bond_opts_g)=split(' ',$line_g);
	
	#extract complex vars
	@int_list_arr_g=split(/\,/,$int_list_str_g);
	@hwaddr_list_arr_g=split(/\,/,$hwaddr_list_str_g);
	@ipaddr_opts_arr_g=split(/\,/,$ipaddr_opts_g);
	if ( $bond_opts_g!~/^def$/ ) {
	    $bond_opts_str_g=$bond_opts_g;
	    $bond_opts_str_g=~s/\,/ /g;
	}
	#extract complex vars
	
	#######uniq checks for all hosts (hwaddr, ipaddr)
	    #$cfg0_uniq_check{'all_hosts'}{hwaddr}=inv_host;
	    #$cfg0_uniq_check{'all_hosts'}{ipaddr}=inv_host; #if ipaddr ne 'dhcp'.
	foreach $arr_el0_g ( @hwaddr_list_arr_g ) {
	    if ( !exists($cfg0_uniq_check{'all_hosts'}{$arr_el0_g}) ) {
		$cfg0_uniq_check{'all_hosts'}{$arr_el0_g}=$inv_host_g;
	    }
	    else {
		if ( $cfg0_uniq_check{'all_hosts'}{$arr_el0_g} ne $inv_host_g ) {
		    print "Hwaddr='$arr_el0_g' is already used at host='$cfg0_uniq_check{'all_hosts'}{$arr_el0_g}'. Please, check and correct config-file\n";
		    $skip_conf_line_g=1;
		}
	    }
	}
	if ( $skip_conf_line_g==1 ) { next; }
	
	if ( $ipaddr_opts_arr_g[0] ne 'dhcp' ) {
	    if ( !exists($cfg0_uniq_check{'all_hosts'}{$ipaddr_opts_arr_g[0]}) ) {
		$cfg0_uniq_check{'all_hosts'}{$ipaddr_opts_arr_g[0]}=$inv_host_g;
	    }
	    else {
		print "IPaddr='$ipaddr_opts_arr_g[0]' is already used at host='$cfg0_uniq_check{'all_hosts'}{$ipaddr_opts_arr_g[0]}'. Please, check and correct config-file\n";
		$skip_conf_line_g=1;
	    }
	    if ( $skip_conf_line_g==1 ) { next; }
	}
	########uniq checks for all hosts

	########uniq checks (for local params of hosts)
	if ( $vlan_id_g=~/^no$/ ) { #if novlan
	    ###$cfg0_uniq_check{inv_host}{'common'}{interface_name}=conf_id; #if interface_name ne 'no' and vlan_id eq 'no'.
	    foreach $arr_el0_g ( @int_list_arr_g ) {
		if ( $arr_el0_g=~/^no$/ ) { last; }
		if ( !exists($cfg0_uniq_check{$inv_host_g}{'common'}{$arr_el0_g}) ) {
		    $cfg0_uniq_check{$inv_host_g}{'common'}{$arr_el0_g}=$conf_id_g;
		}
		else {
		    print "Interface_name='$arr_el0_g' (inv_host='$inv_host_g') is already used at config with id='$cfg0_uniq_check{$inv_host_g}{'common'}{$arr_el0_g}'. Please, check and correct config-file\n";
		    $skip_conf_line_g=1;
		}
	    }
	    if ( $skip_conf_line_g==1 ) { next; }
	    ###

	    ###$cfg0_uniq_check{inv_host}{'common'}{hwaddr}=conf_id; if vlan_id eq 'no'.
	    foreach $arr_el0_g ( @hwaddr_list_arr_g ) {
		if ( !exists($cfg0_uniq_check{$inv_host_g}{'common'}{$arr_el0_g}) ) {
		    $cfg0_uniq_check{$inv_host_g}{'common'}{$arr_el0_g}=$conf_id_g;
		}
		else {
		    print "Hwaddr='$arr_el0_g' (inv_host='$inv_host_g') is already used at config with id='$cfg0_uniq_check{$inv_host_g}{'common'}{$arr_el0_g}'. Please, check and correct config-file\n";
		    $skip_conf_line_g=1;
		}
	    }
	    if ( $skip_conf_line_g==1 ) { next; }
	    ###
	    
	    ###$cfg0_uniq_check{inv_host}{'common'}{bond_name}=conf_id; #if bond_name ne 'no' and vlan_id eq 'no'.
	    if ( $bond_name_g ne 'no' ) {
		if ( !exists($cfg0_uniq_check{$inv_host_g}{'common'}{$bond_name_g}) ) {
		    $cfg0_uniq_check{$inv_host_g}{'common'}{$bond_name_g}=$conf_id_g;
		}
		else {
		    print "Bond_name='$bond_name_g' (inv_host='$inv_host_g') is already used at config with id='$cfg0_uniq_check{$inv_host_g}{'common'}{$bond_name_g}'. Please, check and correct config-file\n";
		    $skip_conf_line_g=1;
		}
		if ( $skip_conf_line_g==1 ) { next; }
	    }
	    ###
	    
	    ###$cfg0_uniq_check{inv_host}{'common'}{bridge_name}=conf_id; #if bridge_name ne 'no' and vlan_id eq 'no'.
	    if ( $brigde_name_g ne 'no' ) {
		if ( !exists($cfg0_uniq_check{$inv_host_g}{'common'}{$brigde_name_g}) ) {
		    $cfg0_uniq_check{$inv_host_g}{'common'}{$brigde_name_g}=$conf_id_g;
		}
		else {
		    print "Bridge_name='$brigde_name_g' (inv_host='$inv_host_g') is already used at config with id='$cfg0_uniq_check{$inv_host_g}{'common'}{$brigde_name_g}'. Please, check and correct config-file\n";
		    $skip_conf_line_g=1;
		}
		if ( $skip_conf_line_g==1 ) { next; }
	    }
	    ###
	    
	    ###$cfg0_uniq_check{inv_host}{'common'}{ipaddr}=conf_id; #if ipaddr_opts ne 'dhcp'.
	    if ( $ipaddr_opts_arr_g[0] ne 'dhcp' ) {
		if ( !exists($cfg0_uniq_check{$inv_host_g}{'common'}{$ipaddr_opts_arr_g[0]}) ) {
		    $cfg0_uniq_check{$inv_host_g}{'common'}{$ipaddr_opts_arr_g[0]}=$conf_id_g;
		}
		else {
		    print "Ipaddr='$ipaddr_opts_arr_g[0]' (inv_host='$inv_host_g') is already used at config with id='$cfg0_uniq_check{$inv_host_g}{'common'}{$ipaddr_opts_arr_g[0]}'. Please, check and correct config-file\n";
		    $skip_conf_line_g=1;
		}
		if ( $skip_conf_line_g==1 ) { next; }
	    }
	    ###
	}
	else { #if vlan
	    ###$cfg0_uniq_check{inv_host}{'vlan'}{vlan_id}=conf_id; #if vlan_id ne 'no'.
	    if ( $vlan_id_g ne 'no' ) {
		if ( !exists($cfg0_uniq_check{$inv_host_g}{'vlan'}{$vlan_id_g}) ) {
		    $cfg0_uniq_check{$inv_host_g}{'vlan'}{$vlan_id_g}=$conf_id_g;
		}
		else {
		    print "Vlan_id='$vlan_id_g' (inv_host='$inv_host_g') is already used at config with id='$cfg0_uniq_check{$inv_host_g}{'vlan'}{$vlan_id_g}'. Please, check and correct config-file\n";
		    $skip_conf_line_g=1;
		}
		if ( $skip_conf_line_g==1 ) { next; }
	    }
	    ###
	    
	    ###$cfg0_uniq_check{inv_host}{'vlan'}{interface_name-vlan_id}=conf_id; #if vlan_id ne 'no'.
	    ###
	    
	    ###$cfg0_uniq_check{inv_host}{'vlan'}{hwaddr-vlan_id}=conf_id; #if vlan_id ne 'no'.
	    ###
	    
	    ###$cfg0_uniq_check{inv_host}{'vlan'}{bond_name-vlan_id}=conf_id; #if vlan_id ne 'no' and bond_name ne 'no'.
	    ###
	    
	    ###$cfg0_uniq_check{inv_host}{'vlan'}{bridge_name-vlan_id}=conf_id; #if vlan_id ne 'no' and bridge_name ne 'no'.
	    ###
	}
	########uniq checks
	
	########unique conf_id for inventory_host
	if ( !exists($cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}) ) { 
	    $cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'main'}=[$inv_host_g,$conf_id_g,$bond_name_g,$brigde_name_g];
	    $cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'int_list'}=[@int_list_arr_g];
	    $cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'hwaddr_list'}=[@hwaddr_list_arr_g];
	    $cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'ipaddr_opts'}=[@ipaddr_opts_arr_g]; #ip, gw, netmask
	    $cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'bond_opts'}=$bond_opts_str_g;
	}
	else {
	    print "For inv_host='$inv_host_g' conf_id='$conf_id_g' is already exists. Please, check and correct config-file\n";
	    $skip_conf_line_g=1;
	}
	if ( $skip_conf_line_g==1 ) { next; }
	########unique conf_id for inventory_host
	
	#print "'($inv_host_g,$conf_id_g,$conf_type_g,$int_list_str_g,$hwaddr_list_str_g,$vlan_id_g,$bond_name_g,$brigde_name_g,$ipaddr_opts_g,$bond_opts_g)'\n";
    }
}
close(CONF);
###MAIN SEQ

###SUBROUTINES
###SUBROUTINES

