#!/usr/bin/bash

###GENERATED BY ansible_helpers/conf_firewalld (https://github.com/vladimir-chursin000/ansible_helpers)

SELF_DIR_str="$(dirname $(readlink -f $0))";

######CFG
APPLY_RUN_INFO_DIR_str="$SELF_DIR_str/apply_run_info";
######CFG

######VARS
OPERATION_IPSET_TYPE_str=$1; # possible values: permanent, temporary
#
CONTENT_DIR_str='no'; # future content
PREV_CONTENT_DIR_str='no'; # now content (will be prev. after run)
#
LIST_FILE_str='no';

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
IS_CLEARED_TEMP_IPSETS_BEFORE_RUN_str='no'; # for ARGV[0]=temporary
declare -a TMP_arr;

EPOCH_TIME_NOW_str='';
EPOCH_TIME_CFG_str='';
######VARS

###APPLY_RUN_INFO read
if [[ -f "$APPLY_RUN_INFO_DIR_str/reload_or_restart_yes" ]]; then
    IS_CLEARED_TEMP_IPSETS_BEFORE_RUN_str='yes';
fi;
###APPLY_RUN_INFO read

######MAIN
if [[ "$OPERATION_IPSET_TYPE_str" == "permanent" ]]; then
    CONTENT_DIR_str="$SELF_DIR_str/permanent_ipsets";
    PREV_CONTENT_DIR_str="$SELF_DIR_str/prev_permanent_ipsets";
    
    # Get list of permanent ipsets (timeout=0)
    PREV_LIST_FILE_FROM_CFG_str="$PREV_CONTENT_DIR_str/LIST_CFG"
    grep -l "name=\"timeout\" value=\"0\"" /etc/firewalld/ipsets/* | sed -r 's/\.xml$|\/etc\/firewalld\/ipsets\///g' | grep -v '.old$' > $PREV_LIST_FILE_FROM_CFG_str;
    grep -L "name=\"timeout\"" /etc/firewalld/ipsets/* | sed -r 's/\.xml$|\/etc\/firewalld\/ipsets\///g' | grep -v '.old$' >> $PREV_LIST_FILE_FROM_CFG_str;
    ###
    
    # Get content of permanent ipsets
    while read -r LINE0_str; # LINE0_str = ipset_name
    do
	firewall-cmd --permanent --ipset=$LINE0_str --get-entries > "$PREV_CONTENT_DIR_str/CFG_$LINE0_str";
    done < $PREV_LIST_FILE_FROM_CFG_str;
    ###
elif [[ "$OPERATION_IPSET_TYPE_str" == "temporary" ]]; then
    CONTENT_DIR_str="$SELF_DIR_str/temporary_ipsets";
    PREV_CONTENT_DIR_str="$SELF_DIR_str/prev_temporary_ipsets";
    
    # if IS_CLEARED_TEMP_IPSETS_BEFORE_RUN_str=yes -> already executed 'reload/restart' and info about current (in memory) temporary ipsets is no need
    if [[ "$IS_CLEARED_TEMP_IPSETS_BEFORE_RUN_str" == "no" ]]; then
	# Get list of temporary ipsets (timeout>0)
	PREV_LIST_FILE_FROM_CFG_str="$PREV_CONTENT_DIR_str/LIST_CFG"
	grep -l "name=\"timeout\"" /etc/firewalld/ipsets/*.xml | xargs grep -L "value=\"0\"" | sed -r 's/\.xml$|\/etc\/firewalld\/ipsets\///g' | grep -v '.old$' > PREV_LIST_FILE_FROM_CFG_str;
	###
	
	# Get content of temporary ipsets
	while read -r LINE0_str; # LINE0_str = ipset_name
	do
	    ipset list $LINE0_str | grep -i timeout | grep -v 'Header' > "$PREV_CONTENT_DIR_str/CFG_$LINE0_str";
	done < $PREV_LIST_FILE_FROM_CFG_str;
	###
    fi;
fi;

LIST_FILE_str="$CONTENT_DIR_str/LIST";
NO_LIST_FILE_str="$CONTENT_DIR_str/NO_LIST";


if [[ -f "$NO_LIST_FILE_str" && "$OPERATION_IPSET_TYPE_str" == "permanent" ]]; then
    # Delete all entries for all premanent ipsets
    echo 'Delete all permanent ipset entries if exists!' > $NO_LIST_FILE_str;
    DELETE_IPSETS_CONTENT_NEED_str='delete_all_permanent';
elif [[ -f "$NO_LIST_FILE_str" && "$OPERATION_IPSET_TYPE_str" == "temporary" ]]; then
    # Delete all entries for all temporary ipsets
    echo 'Delete all temporary ipset entries if exists!' > $NO_LIST_FILE_str;
    DELETE_IPSETS_CONTENT_NEED_str='delete_all_temporary';
elif [[ -f "$LIST_FILE_str" && "$OPERATION_IPSET_TYPE_str" == "permanent" ]]; then
    # Delete all entries for all permanent ipsets and add new entries
    DELETE_IPSETS_CONTENT_NEED_str='delete_all_permanent';
    MAIN_SCENARIO_str='re_add_permanent';
elif [[ -f "$LIST_FILE_str" && "$OPERATION_IPSET_TYPE_str" == "temporary" ]]; then
    # Delete all entries for all temporary ipsets and add new entries
    DELETE_IPSETS_CONTENT_NEED_str='delete_all_temporary';
    MAIN_SCENARIO_str='re_add_temporary';
fi;

# DELETE ipsets content if need
if [[ "$DELETE_IPSETS_CONTENT_NEED_str" == "delete_all_permanent" ]]; then
    while read -r LINE0_str; # LINE0_str = ipset_name
    do
	sed -i '/\<entry\>/d' "/etc/firewalld/ipsets/$LINE0_str.xml";
    done < $PREV_LIST_FILE_FROM_CFG_str;
fi;

if [[ "$DELETE_IPSETS_CONTENT_NEED_str" == "delete_all_temporary" && "$IS_CLEARED_TEMP_IPSETS_BEFORE_RUN_str" == "no" ]]; then
    while read -r LINE0_str; # LINE0_str = ipset_name
    do
	while read -r LINE1_str; # LINE1_str = one line with ipset entry
	do
	    TMP_arr=($LINE1_str); # 0=ip, 1=string "timeout", 2=timeout (num)
	    ipset del $LINE0_str ${TMP_arr[0]};
	    
	    # clear vars
	    TMP_arr=();
	    ###
	done < "$PREV_CONTENT_DIR_str/CFG_$LINE0_str";
    done < $PREV_LIST_FILE_FROM_CFG_str;
fi;
###

# RE_ADD ipsets content if need
if [[ "$MAIN_SCENARIO_str" == "re_add_permanent" ]]; then
    while read -r LINE0_str; # LINE0_str = ipset_name
    do
	firewall-cmd --permanent --ipset=$LINE0_str --add-entries-from-file="$CONTENT_DIR_str/$LINE0_str";
    done < $LIST_FILE_str;
fi;

if [[ "$MAIN_SCENARIO_str" == "re_add_temporary" ]]; then
    while read -r LINE0_str; # LINE0_str = ipset_name
    do
	while read -r LINE1_str; # LINE1_str = one line with ipset entry
	do
	    readarray -d ';+' -t TMP_arr <<< "$LINE1_str"; # 0=ip, 1=expire_dt_at_format_YYYYMMDDHHMISS (num)
	    
	    # clear vars
	    TMP_arr=();
	    ###
	done < "$CONTENT_DIR_str/$LINE0_str";
    done < $LIST_FILE_str;
fi;
###
######MAIN
