###INCLUDED to conf_type_sub_refs_g
##common (novlan)
sub just_interface_gen_ifcfg {
    my ($tmplt_dir_l,$target_dyn_ifcfg_dir_l,$prms_href_l)=@_;
    ###if STATIC. TMPLT = playbooks/ifcfg_tmplt/just_interface/ifcfg-eth-static
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _interface_name_, _hwaddr_, _ipaddr_, _netmask_, _gw_, _conf_id_
    ###
    
    ###if DHCP. TMPLT = playbooks/ifcfg_tmplt/just_interface/ifcfg-eth-dhcp
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _interface_name_, _hwaddr_, _conf_id_
    ###
    
    ###
    #HREF->{'main'}{'_inv_host_'}=inv_host;
    #HREF->{'main'}{'_conf_id_'}=conf_id;
    #HREF->{'main'}{'_vlan_id_'}=vlan_id;
    #HREF->{'main'}{'_bond_name_'}=bond_name;
    #HREF->{'main'}{'_bridge_name_'}=bridge_name;
    #HREF->{'main'}{'_defroute_'}=defroute;
    #HREF->{'main'}{'_ipaddr_'}=ipaddr/dhcp;
    #HREF->{'main'}{'_gw_'}=gw/dhcp;
    #HREF->{'main'}{'_netmask_'}=gw/dhcp;
    #HREF->{'main'}{'_bond_opts_'}=bond_opts_string_for_ifcfg;
    #HREF->{'int_list'}=[array of interfaces];
    #HREF->{'hwaddr_list'}=[array of hwaddr];
    ###
    
    my @int_list_l=@{${$prms_href_l}{'int_list'}};
    my @hwaddr_list_l=@{${$prms_href_l}{'hwaddr_list'}};

    ###vars
    my $arr_i0_l=0;
    my $ifcfg_file_path_l=undef;
    ###vars
        
    for ( $arr_i0_l=0; $arr_i0_l<=$#int_list_l; $arr_i0_l++ ) {
	$ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.$int_list_l[$arr_i0_l];
	if ( ${$prms_href_l}{'main'}{'_ipaddr_'} eq 'dhcp' ) {
	    system("cp ".$tmplt_dir_l.'/ifcfg-eth-dhcp'.' '.$ifcfg_file_path_l);
	    
	    &replace_values_in_file($ifcfg_file_path_l,'eth-dhcp',$int_list_l[$arr_i0_l],$hwaddr_list_l[$arr_i0_l],$prms_href_l);
	    #$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
	}
	else {
	    system("cp ".$tmplt_dir_l.'/ifcfg-eth-static'.' '.$ifcfg_file_path_l);

	    &replace_values_in_file($ifcfg_file_path_l,'eth-static',$int_list_l[$arr_i0_l],$hwaddr_list_l[$arr_i0_l],$prms_href_l);
	    #$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
	}
    }

    ###some other specific operations if need
}

sub virt_bridge_gen_ifcfg {
    my ($tmplt_dir_l,$target_dyn_ifcfg_dir_l,$prms_href_l)=@_;
    ###if STATIC. TMPLT = playbooks/ifcfg_tmplt/virt_bridge/ifcfg-bridge-static
    #TMPLT_VALUES_FOR_REPLACE:_bridge_name_, _ipaddr_, _netmask_, _conf_id_
    ###

    ###
    #HREF->{'main'}{'_inv_host_'}=inv_host;
    #HREF->{'main'}{'_conf_id_'}=conf_id;
    #HREF->{'main'}{'_vlan_id_'}=vlan_id;
    #HREF->{'main'}{'_bond_name_'}=bond_name;
    #HREF->{'main'}{'_bridge_name_'}=bridge_name;
    #HREF->{'main'}{'_defroute_'}=defroute;
    #HREF->{'main'}{'_ipaddr_'}=ipaddr/dhcp;
    #HREF->{'main'}{'_gw_'}=gw/dhcp;
    #HREF->{'main'}{'_netmask_'}=gw/dhcp;
    #HREF->{'main'}{'_bond_opts_'}=bond_opts_string_for_ifcfg;
    #HREF->{'int_list'}=[array of interfaces];
    #HREF->{'hwaddr_list'}=[array of hwaddr];
    ###
    my @int_list_l=@{${$prms_href_l}{'int_list'}};
    my @hwaddr_list_l=@{${$prms_href_l}{'hwaddr_list'}};
    
    ###vars
    my $ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.${$prms_href_l}{'main'}{'_bridge_name_'};
    ###vars
    
    system("cp ".$tmplt_dir_l.'/ifcfg-bridge-static'.' '.$ifcfg_file_path_l);
    
    &replace_values_in_file($ifcfg_file_path_l,'virt-bridge','no','no',$prms_href_l);
    #$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l

    ###some other specific operations if need
}

sub just_bridge_gen_ifcfg {
    my ($tmplt_dir_l,$target_dyn_ifcfg_dir_l,$prms_href_l)=@_;
    #interface -> bridge
    
    ###ETH for BRIDGE. tmplt = playbooks/ifcfg_tmplt/just_bridge/ifcfg-eth
    #TMPLT_VALUES_FOR_REPLACE:_interface_name_, _bridge_name_, _hwaddr_, _conf_id_
    ###
    
    ###if STATIC. TMPLT = playbooks/ifcfg_tmplt/just_bridge/ifcfg-bridge-static
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bridge_name_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###

    ###if DHCP. TMPLT = playbooks/ifcfg_tmplt/just_bridge/ifcfg-bridge-dhcp
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bridge_name_, _conf_id_
    ###

    ###
    #HREF->{'main'}{'_inv_host_'}=inv_host;
    #HREF->{'main'}{'_conf_id_'}=conf_id;
    #HREF->{'main'}{'_vlan_id_'}=vlan_id;
    #HREF->{'main'}{'_bond_name_'}=bond_name;
    #HREF->{'main'}{'_bridge_name_'}=bridge_name;
    #HREF->{'main'}{'_defroute_'}=defroute;
    #HREF->{'main'}{'_ipaddr_'}=ipaddr/dhcp;
    #HREF->{'main'}{'_gw_'}=gw/dhcp;
    #HREF->{'main'}{'_netmask_'}=gw/dhcp;
    #HREF->{'main'}{'_bond_opts_'}=bond_opts_string_for_ifcfg;
    #HREF->{'int_list'}=[array of interfaces];
    #HREF->{'hwaddr_list'}=[array of hwaddr];
    ###
    my @int_list_l=@{${$prms_href_l}{'int_list'}};
    my @hwaddr_list_l=@{${$prms_href_l}{'hwaddr_list'}};

    ###vars
    my $arr_i0_l=0;
    my $ifcfg_file_path_l=undef;
    ###vars

    for ( $arr_i0_l=0; $arr_i0_l<=$#int_list_l; $arr_i0_l++ ) {
	$ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.$int_list_l[$arr_i0_l];
	system("cp ".$tmplt_dir_l.'/ifcfg-eth'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'eth-for-bridge',$int_list_l[$arr_i0_l],$hwaddr_list_l[$arr_i0_l],$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }
    $ifcfg_file_path_l=undef;

    $ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.${$prms_href_l}{'main'}{'_bridge_name_'};
    if ( ${$prms_href_l}{'main'}{'_ipaddr_'} eq 'dhcp' ) {
	system("cp ".$tmplt_dir_l.'/ifcfg-bridge-dhcp'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'bridge-dhcp','no','no',$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }
    else {
	system("cp ".$tmplt_dir_l.'/ifcfg-bridge-static'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'bridge-static','no','no',$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }

    ###some other specific operations if need
}

sub just_bond_gen_ifcfg {
    my ($tmplt_dir_l,$target_dyn_ifcfg_dir_l,$prms_href_l)=@_;
    #interface1+interface2 -> bond
    
    ###ETH for bond. tmplt = playbooks/ifcfg_tmplt/just_bond/ifcfg-eth
    #TMPLT_VALUES_FOR_REPLACE:_interface_name_, _bond_name_, _hwaddr_, _conf_id_
    ###
    
    ###if STATIC. TMPLT = playbooks/ifcfg_tmplt/just_bond/ifcfg-bond-static
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bond_name_, _bond_opts_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###

    ###if DHCP. TMPLT = playbooks/ifcfg_tmplt/just_bond/ifcfg-bond-dhcp
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bond_name_, _bond_opts_, _conf_id_
    ###

    ###
    #HREF->{'main'}{'_inv_host_'}=inv_host;
    #HREF->{'main'}{'_conf_id_'}=conf_id;
    #HREF->{'main'}{'_vlan_id_'}=vlan_id;
    #HREF->{'main'}{'_bond_name_'}=bond_name;
    #HREF->{'main'}{'_bridge_name_'}=bridge_name;
    #HREF->{'main'}{'_defroute_'}=defroute;
    #HREF->{'main'}{'_ipaddr_'}=ipaddr/dhcp;
    #HREF->{'main'}{'_gw_'}=gw/dhcp;
    #HREF->{'main'}{'_netmask_'}=gw/dhcp;
    #HREF->{'main'}{'_bond_opts_'}=bond_opts_string_for_ifcfg;
    #HREF->{'int_list'}=[array of interfaces];
    #HREF->{'hwaddr_list'}=[array of hwaddr];
    ###
    my @int_list_l=@{${$prms_href_l}{'int_list'}};
    my @hwaddr_list_l=@{${$prms_href_l}{'hwaddr_list'}};

    ###vars
    my $arr_i0_l=0;
    my $ifcfg_file_path_l=undef;
    ###vars

    for ( $arr_i0_l=0; $arr_i0_l<=$#int_list_l; $arr_i0_l++ ) {
	$ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.$int_list_l[$arr_i0_l];
	system("cp ".$tmplt_dir_l.'/ifcfg-eth'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'eth-for-bond',$int_list_l[$arr_i0_l],$hwaddr_list_l[$arr_i0_l],$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }
    $ifcfg_file_path_l=undef;

    $ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.${$prms_href_l}{'main'}{'_bond_name_'};
    if ( ${$prms_href_l}{'main'}{'_ipaddr_'} eq 'dhcp' ) {
	system("cp ".$tmplt_dir_l.'/ifcfg-bond-dhcp'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'bond-dhcp','no','no',$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }
    else {
	system("cp ".$tmplt_dir_l.'/ifcfg-bond-static'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'bond-static','no','no',$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }

    ###some other specific operations if need
}

sub bond_bridge_gen_ifcfg {
    my ($tmplt_dir_l,$target_dyn_ifcfg_dir_l,$prms_href_l)=@_;
    #interface1+interface2 -> bond -> bridge
    
    ###ETH for bond. tmplt = playbooks/ifcfg_tmplt/bond-bridge/ifcfg-eth
    #TMPLT_VALUES_FOR_REPLACE:_interface_name_, _bond_name_, _hwaddr_, _conf_id_
    ###
    
    ###BOND for bridge. TMPLT = playbooks/ifcfg_tmplt/bond-bridge/ifcfg-bond
    #TMPLT_VALUES_FOR_REPLACE:_bond_name_, _bond_opts_, _bridge_name_, _conf_id_
    ###

    ###if STATIC. TMPLT = playbooks/ifcfg_tmplt/bond-bridge/ifcfg-bridge-static
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bridge_name_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###

    ###if DHCP. TMPLT = playbooks/ifcfg_tmplt/bond-bridge/ifcfg-bridge-dhcp
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bridge_name_, _conf_id_
    ###

    ###
    #HREF->{'main'}{'_inv_host_'}=inv_host;
    #HREF->{'main'}{'_conf_id_'}=conf_id;
    #HREF->{'main'}{'_vlan_id_'}=vlan_id;
    #HREF->{'main'}{'_bond_name_'}=bond_name;
    #HREF->{'main'}{'_bridge_name_'}=bridge_name;
    #HREF->{'main'}{'_defroute_'}=defroute;
    #HREF->{'main'}{'_ipaddr_'}=ipaddr/dhcp;
    #HREF->{'main'}{'_gw_'}=gw/dhcp;
    #HREF->{'main'}{'_netmask_'}=gw/dhcp;
    #HREF->{'main'}{'_bond_opts_'}=bond_opts_string_for_ifcfg;
    #HREF->{'int_list'}=[array of interfaces];
    #HREF->{'hwaddr_list'}=[array of hwaddr];
    ###
    my @int_list_l=@{${$prms_href_l}{'int_list'}};
    my @hwaddr_list_l=@{${$prms_href_l}{'hwaddr_list'}};

    ###vars
    my $arr_i0_l=0;
    my $ifcfg_file_path_l=undef;
    ###vars

    for ( $arr_i0_l=0; $arr_i0_l<=$#int_list_l; $arr_i0_l++ ) {
	$ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.$int_list_l[$arr_i0_l];
	system("cp ".$tmplt_dir_l.'/ifcfg-eth'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'eth-for-bond',$int_list_l[$arr_i0_l],$hwaddr_list_l[$arr_i0_l],$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }
    $ifcfg_file_path_l=undef;

    $ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.${$prms_href_l}{'main'}{'_bond_name_'};
    system("cp ".$tmplt_dir_l.'/ifcfg-bond'.' '.$ifcfg_file_path_l);
	
    &replace_values_in_file($ifcfg_file_path_l,'bond-for-bridge','no','no',$prms_href_l);
    #$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    $ifcfg_file_path_l=undef;

    $ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.${$prms_href_l}{'main'}{'_bridge_name_'};
    if ( ${$prms_href_l}{'main'}{'_ipaddr_'} eq 'dhcp' ) {
	system("cp ".$tmplt_dir_l.'/ifcfg-bridge-dhcp'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'bridge-dhcp','no','no',$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }
    else {
	system("cp ".$tmplt_dir_l.'/ifcfg-bridge-static'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'bridge-static','no','no',$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }

    ###some other specific operations if need
}
#

##vlan
sub interface_vlan_gen_ifcfg {
    my ($tmplt_dir_l,$target_dyn_ifcfg_dir_l,$prms_href_l)=@_;
    ###if STATIC. TMPLT = playbooks/ifcfg_tmplt/interface-vlan/ifcfg-eth-static
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _interface_name_, _hwaddr_, _ipaddr_, _netmask_, _gw_, _conf_id_
    ###
    
    ###if DHCP. TMPLT = playbooks/ifcfg_tmplt/interface-vlan/ifcfg-eth-dhcp
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _interface_name_, _hwaddr_, _conf_id_
    ###

    ###
    #HREF->{'main'}{'_inv_host_'}=inv_host;
    #HREF->{'main'}{'_conf_id_'}=conf_id;
    #HREF->{'main'}{'_vlan_id_'}=vlan_id;
    #HREF->{'main'}{'_bond_name_'}=bond_name;
    #HREF->{'main'}{'_bridge_name_'}=bridge_name;
    #HREF->{'main'}{'_defroute_'}=defroute;
    #HREF->{'main'}{'_ipaddr_'}=ipaddr/dhcp;
    #HREF->{'main'}{'_gw_'}=gw/dhcp;
    #HREF->{'main'}{'_netmask_'}=gw/dhcp;
    #HREF->{'main'}{'_bond_opts_'}=bond_opts_string_for_ifcfg;
    #HREF->{'int_list'}=[array of interfaces];
    #HREF->{'hwaddr_list'}=[array of hwaddr];
    ###
    my @int_list_l=@{${$prms_href_l}{'int_list'}};
    my @hwaddr_list_l=@{${$prms_href_l}{'hwaddr_list'}};

    ###vars
    my $arr_i0_l=0;
    my $ifcfg_file_path_l=undef;
    ###vars
        
    for ( $arr_i0_l=0; $arr_i0_l<=$#int_list_l; $arr_i0_l++ ) {
	$ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.$int_list_l[$arr_i0_l];
	if ( ${$prms_href_l}{'main'}{'_ipaddr_'} eq 'dhcp' ) {
	    system("cp ".$tmplt_dir_l.'/ifcfg-eth-dhcp'.' '.$ifcfg_file_path_l);
	    
	    &replace_values_in_file($ifcfg_file_path_l,'eth-dhcp',$int_list_l[$arr_i0_l],$hwaddr_list_l[$arr_i0_l],$prms_href_l);
	    #$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
	}
	else {
	    system("cp ".$tmplt_dir_l.'/ifcfg-eth-static'.' '.$ifcfg_file_path_l);

	    &replace_values_in_file($ifcfg_file_path_l,'eth-static',$int_list_l[$arr_i0_l],$hwaddr_list_l[$arr_i0_l],$prms_href_l);
	    #$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
	}
    }

    ###some other specific operations if need
}

sub bridge_vlan_gen_ifcfg {
    my ($tmplt_dir_l,$target_dyn_ifcfg_dir_l,$prms_href_l)=@_;
    #interface-vlan -> bridge
    
    ###ETH for BRIDGE-vlan. tmplt = playbooks/ifcfg_tmplt/bridge-vlan/ifcfg-eth
    #TMPLT_VALUES_FOR_REPLACE:_interface_name_, _bridge_name_, _hwaddr_, _conf_id_
    ###
    
    ###if STATIC. TMPLT = playbooks/ifcfg_tmplt/bridge-vlan/ifcfg-bridge-static
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bridge_name_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###

    ###if DHCP. TMPLT = playbooks/ifcfg_tmplt/bridge-vlan/ifcfg-bridge-dhcp
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bridge_name_, _conf_id_
    ###

    ###
    #HREF->{'main'}{'_inv_host_'}=inv_host;
    #HREF->{'main'}{'_conf_id_'}=conf_id;
    #HREF->{'main'}{'_vlan_id_'}=vlan_id;
    #HREF->{'main'}{'_bond_name_'}=bond_name;
    #HREF->{'main'}{'_bridge_name_'}=bridge_name;
    #HREF->{'main'}{'_defroute_'}=defroute;
    #HREF->{'main'}{'_ipaddr_'}=ipaddr/dhcp;
    #HREF->{'main'}{'_gw_'}=gw/dhcp;
    #HREF->{'main'}{'_netmask_'}=gw/dhcp;
    #HREF->{'main'}{'_bond_opts_'}=bond_opts_string_for_ifcfg;
    #HREF->{'int_list'}=[array of interfaces];
    #HREF->{'hwaddr_list'}=[array of hwaddr];
    ###
    my @int_list_l=@{${$prms_href_l}{'int_list'}};
    my @hwaddr_list_l=@{${$prms_href_l}{'hwaddr_list'}};

    ###vars
    my $arr_i0_l=0;
    my $ifcfg_file_path_l=undef;
    ###vars

    for ( $arr_i0_l=0; $arr_i0_l<=$#int_list_l; $arr_i0_l++ ) {
	$ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.$int_list_l[$arr_i0_l];
	system("cp ".$tmplt_dir_l.'/ifcfg-eth'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'eth-for-bridge',$int_list_l[$arr_i0_l],$hwaddr_list_l[$arr_i0_l],$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }
    $ifcfg_file_path_l=undef;

    $ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.${$prms_href_l}{'main'}{'_bridge_name_'};
    if ( ${$prms_href_l}{'main'}{'_ipaddr_'} eq 'dhcp' ) {
	system("cp ".$tmplt_dir_l.'/ifcfg-bridge-dhcp'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'bridge-dhcp','no','no',$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }
    else {
	system("cp ".$tmplt_dir_l.'/ifcfg-bridge-static'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'bridge-static','no','no',$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }

    ###some other specific operations if need
}

sub bond_vlan_gen_ifcfg {
    my ($tmplt_dir_l,$target_dyn_ifcfg_dir_l,$prms_href_l)=@_;
    #interface1+interface2 -> bond-vlan
    
    ###ETH for bond-vlan. tmplt = playbooks/ifcfg_tmplt/bond-vlan/ifcfg-eth
    #TMPLT_VALUES_FOR_REPLACE:_interface_name_, _bond_name_, _hwaddr_, _conf_id_
    ###
    
    ###if STATIC. TMPLT = playbooks/ifcfg_tmplt/bond-vlan/ifcfg-bond-static
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bond_name_, _bond_opts_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###

    ###if DHCP. TMPLT = playbooks/ifcfg_tmplt/bond-vlan/ifcfg-bond-dhcp
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bond_name_, _bond_opts_, _conf_id_
    ###

    ###
    #HREF->{'main'}{'_inv_host_'}=inv_host;
    #HREF->{'main'}{'_conf_id_'}=conf_id;
    #HREF->{'main'}{'_vlan_id_'}=vlan_id;
    #HREF->{'main'}{'_bond_name_'}=bond_name;
    #HREF->{'main'}{'_bridge_name_'}=bridge_name;
    #HREF->{'main'}{'_defroute_'}=defroute;
    #HREF->{'main'}{'_ipaddr_'}=ipaddr/dhcp;
    #HREF->{'main'}{'_gw_'}=gw/dhcp;
    #HREF->{'main'}{'_netmask_'}=gw/dhcp;
    #HREF->{'main'}{'_bond_opts_'}=bond_opts_string_for_ifcfg;
    #HREF->{'int_list'}=[array of interfaces];
    #HREF->{'hwaddr_list'}=[array of hwaddr];
    ###
    my @int_list_l=@{${$prms_href_l}{'int_list'}};
    my @hwaddr_list_l=@{${$prms_href_l}{'hwaddr_list'}};

    ###vars
    my $arr_i0_l=0;
    my $ifcfg_file_path_l=undef;
    ###vars

    for ( $arr_i0_l=0; $arr_i0_l<=$#int_list_l; $arr_i0_l++ ) {
	$ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.$int_list_l[$arr_i0_l];
	system("cp ".$tmplt_dir_l.'/ifcfg-eth'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'eth-for-bond',$int_list_l[$arr_i0_l],$hwaddr_list_l[$arr_i0_l],$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }
    $ifcfg_file_path_l=undef;

    $ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.${$prms_href_l}{'main'}{'_bond_name_'};
    if ( ${$prms_href_l}{'main'}{'_ipaddr_'} eq 'dhcp' ) {
	system("cp ".$tmplt_dir_l.'/ifcfg-bond-dhcp'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'bond-dhcp','no','no',$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }
    else {
	system("cp ".$tmplt_dir_l.'/ifcfg-bond-static'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'bond-static','no','no',$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }

    ###some other specific operations if need
}

sub bond_bridge_vlan_gen_ifcfg {
    my ($tmplt_dir_l,$target_dyn_ifcfg_dir_l,$prms_href_l)=@_;
    #interface1+interface2 -> bondbrvlan -> bond-bridge-vlan
    
    ###ETH for bond4bondbrvlan. tmplt = playbooks/ifcfg_tmplt/bond-bridge-vlan/ifcfg-eth
    #TMPLT_VALUES_FOR_REPLACE:_interface_name_, _bond_name_, _hwaddr_, _conf_id_
    ###
    
    ###BOND for bondbrvlan. TMPLT = playbooks/ifcfg_tmplt/bond-bridge-vlan/ifcfg-bond
    #TMPLT_VALUES_FOR_REPLACE:_bond_name_, _bond_opts_, _bridge_name_, _conf_id_
    ###

    ###if STATIC. TMPLT = playbooks/ifcfg_tmplt/bond-bridge-vlan/ifcfg-bridge-static
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bridge_name_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###

    ###if DHCP. TMPLT = playbooks/ifcfg_tmplt/bond-bridge-vlan/ifcfg-bridge-dhcp
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bridge_name_, _conf_id_
    ###

    ###
    #HREF->{'main'}{'_inv_host_'}=inv_host;
    #HREF->{'main'}{'_conf_id_'}=conf_id;
    #HREF->{'main'}{'_vlan_id_'}=vlan_id;
    #HREF->{'main'}{'_bond_name_'}=bond_name;
    #HREF->{'main'}{'_bridge_name_'}=bridge_name;
    #HREF->{'main'}{'_defroute_'}=defroute;
    #HREF->{'main'}{'_ipaddr_'}=ipaddr/dhcp;
    #HREF->{'main'}{'_gw_'}=gw/dhcp;
    #HREF->{'main'}{'_netmask_'}=gw/dhcp;
    #HREF->{'main'}{'_bond_opts_'}=bond_opts_string_for_ifcfg;
    #HREF->{'int_list'}=[array of interfaces];
    #HREF->{'hwaddr_list'}=[array of hwaddr];
    ###
    my @int_list_l=@{${$prms_href_l}{'int_list'}};
    my @hwaddr_list_l=@{${$prms_href_l}{'hwaddr_list'}};

    ###vars
    my $arr_i0_l=0;
    my $ifcfg_file_path_l=undef;
    ###vars

    for ( $arr_i0_l=0; $arr_i0_l<=$#int_list_l; $arr_i0_l++ ) {
	$ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.$int_list_l[$arr_i0_l];
	system("cp ".$tmplt_dir_l.'/ifcfg-eth'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'eth-for-bond',$int_list_l[$arr_i0_l],$hwaddr_list_l[$arr_i0_l],$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }
    $ifcfg_file_path_l=undef;

    $ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.${$prms_href_l}{'main'}{'_bond_name_'};
    system("cp ".$tmplt_dir_l.'/ifcfg-bond'.' '.$ifcfg_file_path_l);
	
    &replace_values_in_file($ifcfg_file_path_l,'bond-for-bridge','no','no',$prms_href_l);
    #$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    $ifcfg_file_path_l=undef;

    $ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.${$prms_href_l}{'main'}{'_bridge_name_'};
    if ( ${$prms_href_l}{'main'}{'_ipaddr_'} eq 'dhcp' ) {
	system("cp ".$tmplt_dir_l.'/ifcfg-bridge-dhcp'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'bridge-dhcp','no','no',$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }
    else {
	system("cp ".$tmplt_dir_l.'/ifcfg-bridge-static'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'bridge-static','no','no',$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }

    ###some other specific operations if need
}
##INCLUDED to conf_type_sub_refs_g

##other
sub ifcfg_diff_with_zone_param_save {
    #FOR REPLACE THIS=`diff $dyn_ifcfg_common_dir_g/$hkey0_g/fin/$hkey1_g $ifcfg_backup_from_remote_dir_g/$hkey0_g/$hkey1_g | wc -l`.
    #Compare file and add "firewall ZONE=*" (from_remote) to generated ifcfg.
    my ($ifcfg_generated_file_l,$ifcfg_from_remote_file_l)=@_;
    my ($zone_substr_l,$exec_res_l)=(undef,undef);
    
    $zone_substr_l=`grep -i zone $ifcfg_from_remote_file_l`;
    
    if ( defined($zone_substr_l) && length($zone_substr_l)>0 ) {
	$zone_substr_l=~s/\n|\r|\n\r|\r\n//g;
	$exec_res_l=`echo $zone_substr_l >> $ifcfg_generated_file_l`;
	$exec_res_l=undef;
    }
    
    $exec_res_l=`diff $ifcfg_generated_file_l $ifcfg_from_remote_file_l | wc -l`;
    $exec_res_l=~s/\n|\r|\n\r|\r\n//g;
    $exec_res_l=int($exec_res_l);
    
    return $exec_res_l;
}

sub replace_values_in_file {
    my ($file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l)=@_;
    ###if STATIC. 		virt_bridge/ifcfg-bridge-static:	_bridge_name_, _ipaddr_, _netmask_, _conf_id_
    
    ###if STATIC.		just_interface/ifcfg-eth-static:	_defroute_, _interface_name_, _hwaddr_, _ipaddr_, _netmask_, _gw_, _conf_id_
    ###if DHCP. 		just_interface/ifcfg-eth-dhcp:		_defroute_, _interface_name_, _hwaddr_, _conf_id_
    
    ###ETH for BRIDGE. 		just_bridge/ifcfg-eth:			_interface_name_, _bridge_name_, _hwaddr_, _conf_id_
    ###if STATIC. 		just_bridge/ifcfg-bridge-static:	_defroute_, _bridge_name_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###if DHCP. 		just_bridge/ifcfg-bridge-dhcp:		_defroute_, _bridge_name_, _conf_id_
    
    ###ETH for bond. 		just_bond/ifcfg-eth:			_interface_name_, _bond_name_, _hwaddr_, _conf_id_
    ###if STATIC. 		just_bond/ifcfg-bond-static:		_defroute_, _bond_name_, _bond_opts_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###if DHCP. 		just_bond/ifcfg-bond-dhcp:		_defroute_, _bond_name_, _bond_opts_, _conf_id_
    
    ###ETH for bond. 		bond-bridge/ifcfg-eth:			_interface_name_, _bond_name_, _hwaddr_, _conf_id_
    ###BOND for bridge. 	bond-bridge/ifcfg-bond:			_bond_name_, _bond_opts_, _bridge_name_, _conf_id_
    ###if STATIC. 		bond-bridge/ifcfg-bridge-static:	_defroute_, _bridge_name_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###if DHCP. 		bond-bridge/ifcfg-bridge-dhcp:		_defroute_, _bridge_name_, _conf_id_
    
    ###if STATIC. 		interface-vlan/ifcfg-eth-static:	_defroute_, _interface_name_, _hwaddr_, _ipaddr_, _netmask_, _gw_, _conf_id_
    ###if DHCP. 		interface-vlan/ifcfg-eth-dhcp:		_defroute_, _interface_name_, _hwaddr_, _conf_id_
    
    ###ETH for BRIDGE-vlan.	bridge-vlan/ifcfg-eth:			_interface_name_, _bridge_name_, _hwaddr_, _conf_id_
    ###if STATIC. 		bridge-vlan/ifcfg-bridge-static:	_defroute_, _bridge_name_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###if DHCP. 		bridge-vlan/ifcfg-bridge-dhcp:		_defroute_, _bridge_name_, _conf_id_
    
    ###ETH for bond-vlan. 	bond-vlan/ifcfg-eth:			_interface_name_, _bond_name_, _hwaddr_, _conf_id_
    ###if STATIC. 		bond-vlan/ifcfg-bond-static:		_defroute_, _bond_name_, _bond_opts_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###if DHCP. 		bond-vlan/ifcfg-bond-dhcp:		_defroute_, _bond_name_, _bond_opts_, _conf_id_
    
    ###ETH for bond4bondbrvlan. bond-bridge-vlan/ifcfg-eth:		_interface_name_, _bond_name_, _hwaddr_, _conf_id_
    ###BOND for bondbrvlan. 	bond-bridge-vlan/ifcfg-bond:		_bond_name_, _bond_opts_, _bridge_name_, _conf_id_
    ###if STATIC. 		bond-bridge-vlan/ifcfg-bridge-static:	_defroute_, _bridge_name_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###if DHCP. 		bond-bridge-vlan/ifcfg-bridge-dhcp:	_defroute_, _bridge_name_, _conf_id_
    
    my $arr_el0_l=undef;
    
    my %file_type_hash_l=(
	'virt-bridge'=>		['_bridge_name_','_ipaddr_','_netmask_','_conf_id_'],
	###
	#just_bond, bond-bridge, bond-vlan, bond-bridge-vlan
	'eth-for-bond'=>	['_bond_name_','_conf_id_'], 
	###
	#just_bridge, bridge-vlan
	'eth-for-bridge'=>	['_bridge_name_','_conf_id_'],
	###
	##just_interface, interface-vlan
	'eth-static'=>		['_defroute_','_ipaddr_','_netmask_','_gw_','_conf_id_'],
	'eth-dhcp'=>		['_defroute_','_conf_id_'],
	###
	#just_bridge, bridge-vlan, bond-bridge-vlan
	'bridge-static'=>	['_defroute_','_bridge_name_','_ipaddr_','_gw_','_netmask_','_conf_id_'],
	'bridge-dhcp'=>		['_defroute_','_bridge_name_','_conf_id_'],
	###
	#just_bond
	'bond-static'=>		['_defroute_','_bond_name_','_bond_opts_','_ipaddr_','_gw_','_netmask_','_conf_id_'],
	'bond-dhcp'=>		['_defroute_','_bond_name_','_bond_opts_','_conf_id_'],
	###
	#bond-bridge-vlan, bond-bridge
	'bond-for-bridge'=>	['_bond_name_','_bond_opts_','_bridge_name_','_conf_id_']
    );
    
    if ( $hwaddr_l ne 'no' ) { system("sed -i -e 's/_hwaddr_/$hwaddr_l/g' $file_path_l"); }
    
    #if ( ${$prms_href_l}{'main'}{'_vlan_id_'} )
    if ( $int_name_l ne 'no' ) { system("sed -i -e 's/_interface_name_/$int_name_l/g' $file_path_l"); }    
    foreach $arr_el0_l ( @{$file_type_hash_l{$file_type_l}} ) {
	system("sed -i -e 's/$arr_el0_l/${$prms_href_l}{'main'}{$arr_el0_l}/g' $file_path_l");
    }
}
##other
######SUBROUTINES

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
