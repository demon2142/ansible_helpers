###NO DEPENDENCIES

sub check_port_for_apply_to_fw_conf {
    my ($port_str_l)=@_;
    #port=NUM/udp, NUM/tcp, NUM_begin-NUM_end/tcp, NUM_begin-NUM_end/udp (sctp and dccp)
    my $proc_name_l=(caller(0))[3];
    
    my ($port_num0_l,$port_num1_l)=(undef,undef);
    my $return_str_l='OK';
    
    if ( $port_str_l=~/^(\d+)\/tcp$|^(\d+)\/udp$|^(\d+)\/sctp$|^(\d+)\/dccp$/ ) {
	($port_num0_l)=$port_str_l=~/^(\d+)\//;
	$port_num0_l=int($port_num0_l);
	if ( $port_num0_l<1 or $port_num0_l>65535 ) {
	    return "fail [$proc_name_l]. Port number must be >= 1 and <= 65535";
	}
    }
    elsif ( $port_str_l=~/^\d+\-\d+\/tcp$|^\d+\-\d+\/udp$|^\d+\-\d+\/sctp$|^\d+\-\d+\/dccp$/ ) {
	($port_num0_l,$port_num1_l)=$port_str_l=~/^(\d+)\-(\d+)\//;
	$port_num0_l=int($port_num0_l);
	$port_num1_l=int($port_num1_l);
	if ( $port_num0_l<1 or $port_num0_l>65535 ) { return "fail [$proc_name_l]. Port number must be >= 1 and <= 65535"; }
	if ( $port_num1_l<1 or $port_num1_l>65535 ) { return "fail [$proc_name_l]. Port number must be >= 1 and <= 65535"; }
	if ( $port_num0_l>=$port_num1_l ) { return "fail [$proc_name_l]. Begin_port can not be >= end_port"; }
    }
    else {
	return "fail [$proc_name_l]. Port (or port range)='$port_str_l' is not correct. It must be like 'NUM/port_type' or 'NUMbegin-NUMend/port_type' where port_type='udp/tcp/sctp/dccp'";
    }
    
    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
