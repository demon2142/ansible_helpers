#!/usr/bin/bash

###GENERATED BY ansible_helpers/conf_firewalld (https://github.com/vladimir-chursin000/ansible_helpers)

SELF_DIR_str="$(dirname $(readlink -f $0))";

######CFG
APPLY_RUN_INFO_DIR_str="$SELF_DIR_str/apply_run_info";
######CFG

######VARS
OPERATION_IPSET_TYPE_str=$1; # possible values: permanent (for "without ext timeout" or not), temporary
#
CONTENT_DIR_str='no'; # future content
PREV_CONTENT_DIR_str='no'; # now content (will be prev. after run)
#
CONTENT_DIR_PWET_str='no'; # future content for permanent ipsets with external timeout
PREV_CONTENT_DIR_PWET_str='no'; # now content (will be prev. after run) for permanent ipsets with external timeout
#
LIST_FILE_str='no';
LIST_FILE_PWET_str='no';

###
PREV_LIST_FILE_FROM_CFG_str='no';
# Get list of temporary ipsets (with timeout>0):
    # grep -l "name=\"timeout\"" /etc/firewalld/ipsets/*.xml | xargs grep -L "value=\"0\"" | sed -r 's/\.xml$|\/etc\/firewalld\/ipsets\///g' | grep -v '.old$'
# Get list of permanent ipsets (with timeout=0):
    # grep -l "name=\"timeout\" value=\"0\"" /etc/firewalld/ipsets/* | sed -r 's/\.xml$|\/etc\/firewalld\/ipsets\///g' | grep -v '.old$'
    # and
    # grep -L "name=\"timeout\"" /etc/firewalld/ipsets/* | sed -r 's/\.xml$|\/etc\/firewalld\/ipsets\///g' | grep -v '.old$'
# Content of files from list is form with help of commands
# "firewall-cmd --permanent --ipset=some_permanent_ipset --get-entries" (for permanent ipsets)
# or "ipset list temporary_ipset_changed_params | grep -i timeout | grep -v 'Header'" (for temporary ipsets).
###
#
NO_LIST_FILE_str='no';
NO_LIST_FILE_PWET_str='no';
#

###
DELETE_IPSETS_CONTENT_NEED_str='no';
# Possible values: delete_all_permanent (delete all entries for all permanent ipsets),
# delete_all_temporary (delete all entries for all temporary ipsets),
###

###
MAIN_SCENARIO_str='no';
# possible values: re_add_permanent (delete all entries for all permanent ipsets and add new entries), 
# re_add_temporary (delete all entries for all permanent ipsets and add new entries), 
###
LINE0_str='';
LINE1_str='';
NOW_YYYYMMDDHHMISS_str='';
IS_CLEARED_TEMP_IPSETS_BEFORE_RUN_str='no'; # for ARGV[0]=temporary
IS_FORCE_REMOVED_PERMANENT_IPSETS_str='no';
declare -a TMP_arr;

EPOCH_TIME_NOW_num=0;
EPOCH_TIME_CFG_num=0;
TIMEOUT_num=0;
######VARS

###APPLY_RUN_INFO read
NOW_YYYYMMDDHHMISS_str=`date '+%Y%m%d%H%M%S'`;

if [[ -f "$APPLY_RUN_INFO_DIR_str/reload_or_restart_yes" ]]; then
    IS_CLEARED_TEMP_IPSETS_BEFORE_RUN_str='yes';
    
    echo "$NOW_YYYYMMDDHHMISS_str;+re_add_ipsets_content.sh: finded aplly-run-info-file 'reload_or_restart_yes'. Set IS_CLEARED_TEMP_IPSETS_BEFORE_RUN='yes' -> NO(!) NEED TO GET content of temporary ipsets";
fi;

if [[ -f "$APPLY_RUN_INFO_DIR_str/is_force_removed_permanent_ipsets" ]]; then
    IS_FORCE_REMOVED_PERMANENT_IPSETS_str='yes';

    echo "$NOW_YYYYMMDDHHMISS_str;+re_add_ipsets_content.sh: finded aplly-run-info-file 'is_force_removed_permanent_ipsets'. Set IS_FORCE_REMOVED_PERMANENT_IPSETS='yes' -> NO(!) NEED TO GET content of permanent ipsets";
fi;
###APPLY_RUN_INFO read

######MAIN

# GET PREV CONTENT of ipsets and define content-dirs + list-files (begin)
if [[ "$OPERATION_IPSET_TYPE_str" == "permanent" ]]; then
    NOW_YYYYMMDDHHMISS_str=`date '+%Y%m%d%H%M%S'`;
    echo "$NOW_YYYYMMDDHHMISS_str;+re_add_ipsets_content.sh: run with argv-param='permanent'";

    # for permanent ipsets without external timeout
    CONTENT_DIR_str="$SELF_DIR_str/permanent_ipsets";
    PREV_CONTENT_DIR_str="$SELF_DIR_str/prev_permanent_ipsets";
    LIST_FILE_str="$CONTENT_DIR_str/LIST";
    NO_LIST_FILE_str="$CONTENT_DIR_str/NO_LIST";
    ###
    
    # for permanent ipsets with external timeout
    CONTENT_DIR_PWET_str="$SELF_DIR_str/permanent_ipsets";
    PREV_CONTENT_DIR_PWET_str="$SELF_DIR_str/prev_permanent_ipsets";
    LIST_FILE_PWET_str="$CONTENT_DIR_PWET_str/LIST";
    NO_LIST_FILE_PWET_str="$CONTENT_DIR_PWET_str/NO_LIST";
    ###

    if [[ "$IS_FORCE_REMOVED_PERMANENT_IPSETS_str" == "no" ]]; then
	# for cases: permanent ipsets is not recreated, no confugured permanent ipsets
    	if [[ ! -d $PREV_CONTENT_DIR_str ]]; then
    	    mkdir -p $PREV_CONTENT_DIR_str;
    	fi;
    	
    	# Get list of permanent ipsets (timeout=0)
    	PREV_LIST_FILE_FROM_CFG_str="$PREV_CONTENT_DIR_str/LIST_CFG"
    	if [[ `grep -s -l "name=\"timeout\" value=\"0\"" /etc/firewalld/ipsets/*` ]]; then
    	    grep -s -l "name=\"timeout\" value=\"0\"" /etc/firewalld/ipsets/* | sed -r 's/\.xml$|\/etc\/firewalld\/ipsets\///g' | grep -v '.old$' > $PREV_LIST_FILE_FROM_CFG_str;
    	    echo "$NOW_YYYYMMDDHHMISS_str;+re_add_ipsets_content.sh: write permanent ipsets names (with 'timeout=0') to the file '$PREV_LIST_FILE_FROM_CFG_str'";
    	fi;
    	if [[ `grep -s -L "name=\"timeout\"" /etc/firewalld/ipsets/*` ]]; then
    	    grep -s -L "name=\"timeout\"" /etc/firewalld/ipsets/* | sed -r 's/\.xml$|\/etc\/firewalld\/ipsets\///g' | grep -v '.old$' >> $PREV_LIST_FILE_FROM_CFG_str;
    	    echo "$NOW_YYYYMMDDHHMISS_str;+re_add_ipsets_content.sh: write permanent ipsets names (with 'no timeout param') to the file '$PREV_LIST_FILE_FROM_CFG_str'";
    	fi;
    	###
    	
    	# Get content of permanent ipsets
    	if [[ -s "$PREV_LIST_FILE_FROM_CFG_str" ]]; then # if file exists and not empty
    	    echo "$NOW_YYYYMMDDHHMISS_str;+re_add_ipsets_content.sh: start get content of permanent ipsets from the file '$PREV_LIST_FILE_FROM_CFG_str'";
    	    while read -r LINE0_str; # LINE0_str = ipset_name
    	    do
    		if [[ -s "/etc/firewalld/ipsets/$LINE0_str.xml" ]]; then # if file exists and not empty
    		    NOW_YYYYMMDDHHMISS_str=`date '+%Y%m%d%H%M%S'`;
    		    echo "$NOW_YYYYMMDDHHMISS_str;+re_add_ipsets_content.sh: write entries from permanent ipset-xml '$LINE0_str.xml' to '$PREV_CONTENT_DIR_str/CFG_$LINE0_str'";
    		
    		    firewall-cmd --permanent --ipset=$LINE0_str --get-entries > "$PREV_CONTENT_DIR_str/CFG_$LINE0_str";
    		fi;
    	    done < $PREV_LIST_FILE_FROM_CFG_str;
    	fi;
    fi;
    ###
elif [[ "$OPERATION_IPSET_TYPE_str" == "temporary" ]]; then
    NOW_YYYYMMDDHHMISS_str=`date '+%Y%m%d%H%M%S'`;
    echo "$NOW_YYYYMMDDHHMISS_str;+re_add_ipsets_content.sh: run with argv-param='temporary'";

    CONTENT_DIR_str="$SELF_DIR_str/temporary_ipsets";
    PREV_CONTENT_DIR_str="$SELF_DIR_str/prev_temporary_ipsets";
    
    LIST_FILE_str="$CONTENT_DIR_str/LIST";
    NO_LIST_FILE_str="$CONTENT_DIR_str/NO_LIST";
    
    # if IS_CLEARED_TEMP_IPSETS_BEFORE_RUN_str=yes -> already executed 'reload/restart' and info about current (in memory) temporary ipsets is no need
    if [[ "$IS_CLEARED_TEMP_IPSETS_BEFORE_RUN_str" == "no" ]]; then
	if [[ ! -d $PREV_CONTENT_DIR_str ]]; then
	    mkdir -p $PREV_CONTENT_DIR_str;
	fi;

	# Get list of temporary ipsets (timeout>0)
	PREV_LIST_FILE_FROM_CFG_str="$PREV_CONTENT_DIR_str/LIST_CFG";
	if [[ `grep -s -l "name=\"timeout\"" /etc/firewalld/ipsets/* | xargs grep -L "value=\"0\""` ]]; then
	    grep -s -l "name=\"timeout\"" /etc/firewalld/ipsets/*.xml | xargs grep -L "value=\"0\"" | sed -r 's/\.xml$|\/etc\/firewalld\/ipsets\///g' | grep -v '.old$' > $PREV_LIST_FILE_FROM_CFG_str;
	    echo "$NOW_YYYYMMDDHHMISS_str;+re_add_ipsets_content.sh: write teporary ipsets names (with 'timeout param') to the file '$PREV_LIST_FILE_FROM_CFG_str'";
	fi;
	###
	
	# Get content of temporary ipsets
	if [[ -s "$PREV_LIST_FILE_FROM_CFG_str" ]]; then # if file exists and not empty
	    echo "$NOW_YYYYMMDDHHMISS_str;+re_add_ipsets_content.sh: start get content of temporary ipsets from the file '$PREV_LIST_FILE_FROM_CFG_str'";
	    while read -r LINE0_str; # LINE0_str = ipset_name
	    do
	    	if [[ -s "/etc/firewalld/ipsets/$LINE0_str.xml" ]]; then # if file exists and not empty
		    NOW_YYYYMMDDHHMISS_str=`date '+%Y%m%d%H%M%S'`;
		    echo "$NOW_YYYYMMDDHHMISS_str;+re_add_ipsets_content.sh: write entries from temporary ipset-xml '$LINE0_str.xml' to '$PREV_CONTENT_DIR_str/CFG_$LINE0_str'";

	    	    ipset list $LINE0_str | grep -i timeout | grep -v 'Header' > "$PREV_CONTENT_DIR_str/CFG_$LINE0_str";
	    	fi;
	    done < $PREV_LIST_FILE_FROM_CFG_str;
	fi;
	###
    fi;
fi;
# GET PREV CONTENT of ipsets and define content-dirs + list-files (end)

# MAIN SCENARIO CHOICE (begin)
NOW_YYYYMMDDHHMISS_str=`date '+%Y%m%d%H%M%S'`;

if [[ -f "$NO_LIST_FILE_str" && "$OPERATION_IPSET_TYPE_str" == "permanent" ]]; then
    # Delete all entries for all permanent ipsets (including pwet)
    echo 'Delete all permanent ipset entries (including pwet) if exists!' > $NO_LIST_FILE_str;
    DELETE_IPSETS_CONTENT_NEED_str='delete_all_permanent';
    
    echo "$NOW_YYYYMMDDHHMISS_str;+re_add_ipsets_content.sh: MAIN SCENARIO CHOICE. Exists NO_LIST_FILE='$NO_LIST_FILE_str' and OPERATION_IPSET_TYPE='permanent' -> set DELETE_IPSETS_CONTENT_NEED='delete_all_permanent'";
elif [[ -f "$NO_LIST_FILE_str" && "$OPERATION_IPSET_TYPE_str" == "temporary" ]]; then
    # Delete all entries for all temporary ipsets
    echo 'Delete all temporary ipset entries if exists!' > $NO_LIST_FILE_str;
    DELETE_IPSETS_CONTENT_NEED_str='delete_all_temporary';

    echo "$NOW_YYYYMMDDHHMISS_str;+re_add_ipsets_content.sh: MAIN SCENARIO CHOICE. Exists NO_LIST_FILE='$NO_LIST_FILE_str' and OPERATION_IPSET_TYPE='temporary' -> set DELETE_IPSETS_CONTENT_NEED='delete_all_temporary'";
elif [[ -f "$LIST_FILE_str" && "$OPERATION_IPSET_TYPE_str" == "permanent" ]]; then
    # Delete all entries for all permanent ipsets and add new entries
    DELETE_IPSETS_CONTENT_NEED_str='delete_all_permanent';
    MAIN_SCENARIO_str='re_add_permanent';

    echo "$NOW_YYYYMMDDHHMISS_str;+re_add_ipsets_content.sh: MAIN SCENARIO CHOICE. Exists NO_LIST_FILE='$NO_LIST_FILE_str' and OPERATION_IPSET_TYPE='permanent' -> set DELETE_IPSETS_CONTENT_NEED='delete_all_permanent', MAIN_SCENARIO_str='re_add_permanent'";
elif [[ -f "$LIST_FILE_str" && "$OPERATION_IPSET_TYPE_str" == "temporary" ]]; then
    # Delete all entries for all temporary ipsets and add new entries
    DELETE_IPSETS_CONTENT_NEED_str='delete_all_temporary';
    MAIN_SCENARIO_str='re_add_temporary';

    echo "$NOW_YYYYMMDDHHMISS_str;+re_add_ipsets_content.sh: MAIN SCENARIO CHOICE. Exists NO_LIST_FILE='$NO_LIST_FILE_str' and OPERATION_IPSET_TYPE='temporary' -> set DELETE_IPSETS_CONTENT_NEED='delete_all_temporary', MAIN_SCENARIO_str='re_add_temporary'";
fi;
# MAIN SCENARIO CHOICE (end)

# DELETE ipsets content if need (begin)
NOW_YYYYMMDDHHMISS_str=`date '+%Y%m%d%H%M%S'`;

if [[ "$DELETE_IPSETS_CONTENT_NEED_str" == "delete_all_permanent" ]]; then
    if [[ -s "$PREV_LIST_FILE_FROM_CFG_str" ]]; then
	echo "$NOW_YYYYMMDDHHMISS_str;+re_add_ipsets_content.sh: Execute scenario='delete_all_permanent'. Read ipset-names from file='$PREV_LIST_FILE_FROM_CFG_str'";
	
	# delete all permanent entries via 'sed'
	while read -r LINE0_str; # LINE0_str = ipset_name
	do
	    if [[ -s "/etc/firewalld/ipsets/$LINE0_str.xml" ]]; then # if file exists and not empty
		echo "$NOW_YYYYMMDDHHMISS_str;+re_add_ipsets_content.sh: Delete entries from ipset='$LINE0_str'";

		sed -i '/\<entry\>/d' "/etc/firewalld/ipsets/$LINE0_str.xml";
	    fi;
	done < $PREV_LIST_FILE_FROM_CFG_str;
	###
    fi;
elif [[ "$DELETE_IPSETS_CONTENT_NEED_str" == "delete_all_temporary" && "$IS_CLEARED_TEMP_IPSETS_BEFORE_RUN_str" == "no" ]]; then
    if [[ -s "$PREV_LIST_FILE_FROM_CFG_str" ]]; then # if file exists and not empty
	echo "$NOW_YYYYMMDDHHMISS_str;+re_add_ipsets_content.sh: Execute scenario='delete_all_temporary'. Read ipset-names from file='$PREV_LIST_FILE_FROM_CFG_str'";
	
	# delete all temorary entries via 'ipset'
	while read -r LINE0_str; # LINE0_str = ipset_name
	do
	    if [[ -s "$PREV_CONTENT_DIR_str/CFG_$LINE0_str" ]]; then
		echo "$NOW_YYYYMMDDHHMISS_str;+re_add_ipsets_content.sh: Delete entries from ipset='$LINE0_str'";

		while read -r LINE1_str; # LINE1_str = one line with ipset entry
		do
		    TMP_arr=($LINE1_str); # 0=ip, 1=string "timeout", 2=timeout (num)
		    ipset del $LINE0_str ${TMP_arr[0]};
		    
		    # clear vars
		    TMP_arr=();
		    ###
		done < "$PREV_CONTENT_DIR_str/CFG_$LINE0_str";
	    fi;
	done < $PREV_LIST_FILE_FROM_CFG_str;
	###
    fi;
fi;
# DELETE ipsets content if need (end)

# RE_ADD ipsets content if need (begin)
NOW_YYYYMMDDHHMISS_str=`date '+%Y%m%d%H%M%S'`;

if [[ "$MAIN_SCENARIO_str" == "re_add_permanent" ]]; then
    # for permanent WITHOUT external timeout
    if [[ -s "$LIST_FILE_str" ]]; then
	echo "$NOW_YYYYMMDDHHMISS_str;+re_add_ipsets_content.sh: Execute scenario='re_add_permanent'. Read ipset-names from file='$LIST_FILE_str'";
	
	while read -r LINE0_str; # LINE0_str = ipset_name
	do
	    if [[ -s "/etc/firewalld/ipsets/$LINE0_str.xml" ]]; then # if file exists and not empty
		echo "$NOW_YYYYMMDDHHMISS_str;+re_add_ipsets_content.sh: Add ipsets entries from file='$CONTENT_DIR_str/$LINE0_str' to ipset='$LINE0_str'";

		firewall-cmd --permanent --ipset=$LINE0_str --add-entries-from-file="$CONTENT_DIR_str/$LINE0_str";
	    fi;
	done < $LIST_FILE_str;
    fi;
    ###
    
    # for permanent WITH external timeout
    if [[ -s "$LIST_FILE_PWET_str" ]]; then
	NOW_YYYYMMDDHHMISS_str=`date '+%Y%m%d%H%M%S'`;
	echo "$NOW_YYYYMMDDHHMISS_str;+re_add_ipsets_content.sh: Execute scenario='re_add_permanent'. Read ipset-names with external timeout from file='$LIST_FILE_PWET_str'";
	
	while read -r LINE0_str; # LINE0_str = ipset_name
	do
	    if [[ -s "/etc/firewalld/ipsets/$LINE0_str.xml" ]]; then # if file exists and not empty
		echo "$NOW_YYYYMMDDHHMISS_str;+re_add_ipsets_content.sh: Add ipsets entries with external timeout from file='$CONTENT_DIR_PWET_str/$LINE0_str' to ipset='$LINE0_str'";
		
		while read -r LINE1_str; # LINE1_str = one line with ipset entry
		do
		    TMP_arr=($(echo "$LINE1_str" | sed 's/;+/\n/g')); # 0=ip, 1=expire_dt_at_format_YYYYMMDDHHMISS (num)
		    
		    # clear vars
		    TMP_arr=();
		    EPOCH_TIME_NOW_num=0;
		    EPOCH_TIME_CFG_num=0;
		    TIMEOUT_num=0;
		    ###
		done < "$CONTENT_DIR_PWET_str/$LINE0_str";
	    fi;
	done < $LIST_FILE_str;
    fi;
    ###
elif [[ "$MAIN_SCENARIO_str" == "re_add_temporary" ]]; then
    if [[ -s "$LIST_FILE_str" ]]; then
	echo "$NOW_YYYYMMDDHHMISS_str;+re_add_ipsets_content.sh: Execute scenario='re_add_temporary'. Read ipset-names from file='$LIST_FILE_str'";
	
	while read -r LINE0_str; # LINE0_str = ipset_name
	do
	    if [[ -s "$CONTENT_DIR_str/$LINE0_str" && -s "/etc/firewalld/ipsets/$LINE0_str.xml" ]]; then # if file exists and not empty
		echo "$NOW_YYYYMMDDHHMISS_str;+re_add_ipsets_content.sh: Add ipsets entries from file='$CONTENT_DIR_str/$LINE0_str' to ipset='$LINE0_str'";

		while read -r LINE1_str; # LINE1_str = one line with ipset entry
		do
		    TMP_arr=($(echo "$LINE1_str" | sed 's/;+/\n/g')); # 0=ip, 1=expire_dt_at_format_YYYYMMDDHHMISS (num)
		
		    EPOCH_TIME_CFG_num=`date -d "$(echo ${TMP_arr[1]} | awk '{print substr($1,1,8), substr($1,9,2) ":" substr($1,11,2) ":" substr($1,13,2)}')" '+%s'`;
		    EPOCH_TIME_NOW_num=`date '+%s'`;
		    TIMEOUT_num=$(($EPOCH_TIME_CFG_num - $EPOCH_TIME_NOW_num));
		    
		    if [[ "$TIMEOUT_num" -gt "0" ]]; then
			if [[ "$TIMEOUT_num" -gt "2147483" ]]; then
			    TIMEOUT_num='2147483';
			    
			    NOW_YYYYMMDDHHMISS_str=`date '+%Y%m%d%H%M%S'`;
			    echo "$NOW_YYYYMMDDHHMISS_str;+re_add_ipsets_content.sh: Add ipset entry '${TMP_arr[0]}' from file='$CONTENT_DIR_str/$LINE0_str' to ipset='$LINE0_str' = DONE, but timeout is set to '2147483' because calculated value > maximum_timeout_value ('2147483')";
			fi;
			
			ipset add $LINE0_str ${TMP_arr[0]} timeout $TIMEOUT_num;
		    else
			NOW_YYYYMMDDHHMISS_str=`date '+%Y%m%d%H%M%S'`;
			echo "$NOW_YYYYMMDDHHMISS_str;+re_add_ipsets_content.sh: Add ipset entry '${TMP_arr[0]}' from file='$CONTENT_DIR_str/$LINE0_str' to ipset='$LINE0_str' is CANCELLED. Entry is expired";
		    fi;
		    
		    # clear vars
		    TMP_arr=();
		    EPOCH_TIME_NOW_num=0;
		    EPOCH_TIME_CFG_num=0;
		    TIMEOUT_num=0;
		    ###
		done < "$CONTENT_DIR_str/$LINE0_str";
	    fi;
	done < $LIST_FILE_str;
    fi;
fi;
# RE_ADD ipsets content if need (end)
######MAIN
