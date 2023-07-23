#!/usr/bin/bash

###GENERATED BY ansible_helpers/conf_firewalld (https://github.com/vladimir-chursin000/ansible_helpers)

SELF_DIR_str="$(dirname $(readlink -f $0))";

######VARS
OPERATION_IPSET_TYPE_str=$1; # possible values: permanent, temporary
#
CONTENT_DIR_str='no';
PREV_CONTENT_DIR_str='no';
#
LIST_FILE_str='no';

###
PREV_LIST_FILE_FROM_CFG_str='no'; # content of files from list is form with help of commands
# "firewall-cmd --permanent --ipset=some_permanent_ipset --get-entries"
# or "ipset list temporary_ipset_changed_params | grep -i timeout | grep -v 'Header'"
###
#
NO_LIST_FILE_str='no';
#

###
DELETE_IPSETS_CONTENT_NEED_str='no';
# Possible values: delete_all_permanent (delete all entries for all permanent ipsets),
# delete_all_temporary (delete all entries for all temporary ipsets),
###

MAIN_SCENARIO_str='no';
# possible values: re_add_permanent (delete all entries for all permanent ipsets and add new entries), 
# re_add_temporary (delete all entries for all permanent ipsets and add new entries), 
###
######VARS

######MAIN
if [[ "$OPERATION_IPSET_TYPE_str" == "permanent" ]]; then
    CONTENT_DIR_str="$SELF_DIR_str/permanent_ipsets";
    PREV_CONTENT_DIR_str="$SELF_DIR_str/prev_permanent_ipsets";
elif [[ "$OPERATION_IPSET_TYPE_str" == "temporary" ]]; then
    CONTENT_DIR_str="$SELF_DIR_str/temporary_ipsets";
    PREV_CONTENT_DIR_str="$SELF_DIR_str/prev_temporary_ipsets";
fi;

LIST_FILE_str="$CONTENT_DIR_str/LIST";
NO_LIST_FILE_str="$CONTENT_DIR_str/NO_LIST";

if [[ -f "$NO_LIST_FILE_str" ]] && [[ "$OPERATION_IPSET_TYPE_str" == "permanent" ]]; then
    # Delete all entries for all premanent ipsets
    echo 'Delete all permanent ipset entries if exists!' > $NO_LIST_FILE_str;
    DELETE_IPSETS_CONTENT_NEED_str='delete_all_permanent';
if [[ -f "$NO_LIST_FILE_str" ]] && [[ "$OPERATION_IPSET_TYPE_str" == "temporary" ]]; then
    # Delete all entries for all temporary ipsets
    echo 'Delete all temporary ipset entries if exists!' > $NO_LIST_FILE_str;
    DELETE_IPSETS_CONTENT_NEED_str='delete_all_temporary';
elif [[ -f "$LIST_FILE_str" ]] && [[ "$OPERATION_IPSET_TYPE_str" == "permanent" ]]; then
    # Delete all entries for all permanent ipsets and add new entries
    DELETE_IPSETS_CONTENT_NEED_str='delete_all_permanent';
    MAIN_SCENARIO_str='re_add_permanent';
elif [[ -f "$LIST_FILE_str" ]] && [[ "$OPERATION_IPSET_TYPE_str" == "temporary" ]]; then
    # Delete all entries for all temporary ipsets and add new entries
    DELETE_IPSETS_CONTENT_NEED_str='delete_all_temporary';
    MAIN_SCENARIO_str='re_add_temporary';
fi;
######MAIN
