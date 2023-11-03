#!/usr/bin/bash

###GENERATED BY ansible_helpers/conf_firewalld (https://github.com/vladimir-chursin000/ansible_helpers)

######INIT DIRS and FILES
SELF_DIR_str="$(dirname $(readlink -f $0))";
EXEC_RESULT_DIR_str="$SELF_DIR_str/exec_results";
NOW_YYYYMMDDHHMISS_AT_START_str=`date '+%Y%m%d%H%M%S'`;
EXEC_RESULT_FILE_str="$EXEC_RESULT_DIR_str/$NOW_YYYYMMDDHHMISS_AT_START_str-apply_fwrules.log";
######INIT DIRS and FILES

touch "$SELF_DIR_str/apply_fwrules_is_run_now";
if [[ ! -d $EXEC_RESULT_DIR_str ]]; then
    mkdir -p "$EXEC_RESULT_DIR_str";
fi;

######CFG
APPLY_RUN_INFO_DIR_str="$SELF_DIR_str/apply_run_info";
BACKUP_FOR_ROLLBACK_DIR_str="$SELF_DIR_str/fwrules_backup_now";
TEMP_IPSET_CONT_BACKUP_FOR_ROLLBACK_DIR_str="$BACKUP_FOR_ROLLBACK_DIR_str/temporary_ipsets_content";
######CFG

######VARS
FWCONFIG_CHANGED_str='no';
RECREATE_PERMANENT_IPSETS_CHANGED_str='no';
RECREATE_TEMPORARY_IPSETS_CHANGED_str='no';
RECREATE_FW_ZONES_CHANGED_str='no';
RECREATE_POLICIES_CHANGED_str='no';
PERMANENT_IPSETS_FLAG_FILE_CHANGED_str='no';
PERMANENT_IPSETS_FLAG_FILE_PWET_CHANGED_str='no'; # for permanent with external timeout
TEMPORARY_IPSETS_FLAG_FILE_CHANGED_str='no';
ROLLBACK_FWRULES_NEED_RUN_str='no';
RELOAD_NEED_RUN_AT_THE_END_str='no'; # for "--reload" after apply "--permanent" changes
#
SPEC_TAGS_CHECK_NEED_str='no'; # if "yes" -> need to check for spec tags at step 1.1
RELOAD_NEED_RUN_AFTER_SPEC_TAGS_CHECK_str='no'; # for "--reload" before apply "--permanent" changes (and after, for example, "#FORCE_REMOVE_PERMANENT_IPSETS" at step 1.1)
#
ARR_EL0_str='';
EXE_RES_str='';
declare -a TMP_arr;
######VARS

######FUNCTIONS
function write_log_func() {
    local local_log_str=$1;
    local local_log_file_str=$2;
    local local_now_yyyymmddhhmiss_str=`date '+%Y%m%d%H%M%S'`;

    echo "$local_now_yyyymmddhhmiss_str;+$local_log_str" &>> "$local_log_file_str";
}
######FUNCTIONS

######APPLY_RUN_INFO read
if [[ -f "$APPLY_RUN_INFO_DIR_str/recreate_permanent_ipsets_changed" ]]; then
    RECREATE_PERMANENT_IPSETS_CHANGED_str='yes';
    RELOAD_NEED_RUN_AT_THE_END_str='yes';
    SPEC_TAGS_CHECK_NEED_str='yes';
    
    write_log_func "Exists apply-run-info-file 'recreate_permanent_ipsets_changed'. Set RECREATE_PERMANENT_IPSETS_CHANGED='yes', RELOAD_NEED_RUN='yes'" "$EXEC_RESULT_FILE_str";
fi;

if [[ -f "$APPLY_RUN_INFO_DIR_str/recreate_temporary_ipsets_changed" ]]; then
    RECREATE_TEMPORARY_IPSETS_CHANGED_str='yes';
    RELOAD_NEED_RUN_AT_THE_END_str='yes';
    SPEC_TAGS_CHECK_NEED_str='yes';

    write_log_func "Exists apply-run-info-file 'recreate_temporary_ipsets_changed'. Set RECREATE_TEMPORARY_IPSETS_CHANGED='yes', RELOAD_NEED_RUN='yes'" "$EXEC_RESULT_FILE_str";
fi;

if [[ -f "$APPLY_RUN_INFO_DIR_str/recreate_fw_zones_changed" ]]; then
    RECREATE_FW_ZONES_CHANGED_str='yes';
    RELOAD_NEED_RUN_AT_THE_END_str='yes';
    SPEC_TAGS_CHECK_NEED_str='yes';

    write_log_func "Exists apply-run-info-file 'recreate_fw_zones_changed'. Set RECREATE_FW_ZONES_CHANGED='yes', RELOAD_NEED_RUN='yes'" "$EXEC_RESULT_FILE_str";
fi;

if [[ -f "$APPLY_RUN_INFO_DIR_str/recreate_policies_changed" ]]; then
    RECREATE_POLICIES_CHANGED_str='yes';
    RELOAD_NEED_RUN_AT_THE_END_str='yes';
    SPEC_TAGS_CHECK_NEED_str='yes';

    write_log_func "Exists apply-run-info-file 'recreate_policies_changed'. Set RECREATE_POLICIES_CHANGED='yes', RELOAD_NEED_RUN='yes'" "$EXEC_RESULT_FILE_str";
fi;

if [[ -f "$APPLY_RUN_INFO_DIR_str/permanent_ipsets_flag_file_changed" ]]; then
    PERMANENT_IPSETS_FLAG_FILE_CHANGED_str='yes';
    RELOAD_NEED_RUN_AT_THE_END_str='yes';

    write_log_func "Exists apply-run-info-file 'permanent_ipsets_flag_file_changed'. Set PERMANENT_IPSETS_FLAG_FILE_CHANGED='yes', RELOAD_NEED_RUN='yes'" "$EXEC_RESULT_FILE_str";
fi;

if [[ -f "$APPLY_RUN_INFO_DIR_str/permanent_ipsets_flag_file_pwet_changed" ]]; then
    # for permanent with external timeout
    PERMANENT_IPSETS_FLAG_FILE_PWET_CHANGED_str='yes';
    RELOAD_NEED_RUN_AT_THE_END_str='yes';

    write_log_func "Exists apply-run-info-file 'permanent_ipsets_flag_file_pwet_changed'. Set PERMANENT_IPSETS_FLAG_FILE_PWET_CHANGED='yes', RELOAD_NEED_RUN='yes'" "$EXEC_RESULT_FILE_str";
fi;

if [[ -f "$APPLY_RUN_INFO_DIR_str/temporary_ipsets_flag_file_changed" ]]; then
    TEMPORARY_IPSETS_FLAG_FILE_CHANGED_str='yes';

    write_log_func "Exists apply-run-info-file 'temporary_ipsets_flag_file_changed'. Set TEMPORARY_IPSETS_FLAG_FILE_CHANGED='yes'" "$EXEC_RESULT_FILE_str";
fi;

if [[ -f "$APPLY_RUN_INFO_DIR_str/rollback_fwrules_need_run" ]]; then
    ROLLBACK_FWRULES_NEED_RUN_str='yes';

    write_log_func "Exists apply-run-info-file 'rollback_fwrules_need_run'. Set ROLLBACK_FWRULES_NEED_RUN='yes'" "$EXEC_RESULT_FILE_str";
fi;

if [[ -f "$APPLY_RUN_INFO_DIR_str/fwconfig_changed" ]]; then
    FWCONFIG_CHANGED_str='yes';
    RELOAD_NEED_RUN_AT_THE_END_str='no';

    write_log_func "Exists apply-run-info-file 'fwconfig_changed'. Set FWCONFIG_CHANGED='yes', RELOAD_NEED_RUN='yes'" "$EXEC_RESULT_FILE_str";
fi;

if [[ "$RELOAD_NEED_RUN_AT_THE_END_str" == "yes" || "$FWCONFIG_CHANGED_str" == "yes" ]]; then
    # if no changes for temporary (timeout>0), but reload/restart expected -> need to restore temporary ipsets entries after reload/restart
    TEMPORARY_IPSETS_FLAG_FILE_CHANGED_str='yes';
    ###
    
    # For script 're_add_ipsets_content.sh' with ARGV[0]='temporary'
    touch "$APPLY_RUN_INFO_DIR_str/reload_or_restart_yes";
    ###

    write_log_func "If RELOAD_NEED_RUN='yes' or FWCONFIG_CHANGED='yes' -> set TEMPORARY_IPSETS_FLAG_FILE_CHANGED='yes' and create apply-run-info-file 'reload_or_restart_yes' for script 're_add_ipsets_content.sh' (with 'temporary' argv param)" "$EXEC_RESULT_FILE_str";
fi;
######APPLY_RUN_INFO read

# 1) Save content of "/etc/firewalld" to "~/ansible_helpers/conf_firewalld/fwrules_backup_now" (if need).
    # For rollback of permanent content/rules. Exception - content of a temporary ipsets.
    # Create "~/ansible_helpers/conf_firewalld/fwrules_backup_now" if need.
if [[ "$ROLLBACK_FWRULES_NEED_RUN_str" == "yes" ]]; then
    mkdir -p "$BACKUP_FOR_ROLLBACK_DIR_str";
    rm -rf $BACKUP_FOR_ROLLBACK_DIR_str/*;
    cp -r /etc/firewalld/* "$BACKUP_FOR_ROLLBACK_DIR_str";

    # 1a) Save content of temporary ipsets (if need) to 'fwrules_backup_now'. For rollback.
    mkdir -p "$TEMP_IPSET_CONT_BACKUP_FOR_ROLLBACK_DIR_str";
    
    EXE_RES_str=`ls /etc/firewalld/ipsets/*.xml`; # get string with ipsets xml-s
    
    if [[ ! -z "$EXE_RES_str" ]]; then # check for exists ipsets configs (if string is not empty)
	# get list of temporary ipsets and their content
	TMP_arr=($(grep -l "name=\"timeout\"" /etc/firewalld/ipsets/*.xml | xargs grep -L "value=\"0\"")); # write to array all ipsets with timeout!=0
	for ARR_EL0_str in "${TMP_arr[@]}"
	do
	    ARR_EL0_str=`echo ${ARR_EL0_str//\/etc\/firewalld\/ipsets\//}`; # remove path from var
	    ARR_EL0_str=`echo ${ARR_EL0_str//\.xml/}`; # remove extension from var
	    echo $ARR_EL0_str >> "$BACKUP_FOR_ROLLBACK_DIR_str/temporary_ipsets_list.txt";
	    ipset list $ARR_EL0_str | grep timeout | grep -v Header > "$TEMP_IPSET_CONT_BACKUP_FOR_ROLLBACK_DIR_str/$ARR_EL0_str.txt";
	done;
	###
    fi;
    
    EXE_RES_str='';
    ###

    write_log_func "Prepare files and ipsets content for rollback (if ROLLBACK_FWRULES_NEED_RUN='yes')" "$EXEC_RESULT_FILE_str";
fi;
###

# 1.1) Special tags operations at scripts:
    # recreate_permanent_ipsets.sh (#FORCE_REMOVE_PERMANENT_IPSETS),
    # recreate_temporary_ipsets.sh (#FORCE_REMOVE_TEMPORARY_IPSETS),
    # recreate_fw_zones.sh (#REMOVE_CUSTOM_ZONES, #REMOVE_UNCONFIGURED_CUSTOM_ZONES, #RESTORE_DEFAULT_ZONES),
    # recreate_policies.sh (#REMOVE_POLICIES)
if [[ "$SPEC_TAGS_CHECK_NEED_str" == "yes" ]]; then
    if [[ `grep '#FORCE_REMOVE_PERMANENT_IPSETS' "$SELF_DIR_str/recreate_permanent_ipsets.sh"` ]]; then
	# for cases: 1) permanent ipsets is recreated; 2) yes configured permanent ipsets.
	
	# For script 're_add_ipsets_content.sh' with ARGV[0]='permanent'
	touch "$APPLY_RUN_INFO_DIR_str/is_force_removed_permanent_ipsets";
	###

	if [[ `grep -s -l "name=\"timeout\" value=\"0\"" /etc/firewalld/ipsets/*` ]]; then
	    grep -s -l "name=\"timeout\" value=\"0\"" /etc/firewalld/ipsets/* | xargs rm;
	fi;
	
	if [[ `grep -s -L "name=\"timeout\"" /etc/firewalld/ipsets/*` ]]; then
	    grep -s -L "name=\"timeout\"" /etc/firewalld/ipsets/* | xargs rm;
	fi;
	
	write_log_func "FORCE_REMOVE_PERMANENT_IPSETS (if RECREATE_PERMANENT_IPSETS_CHANGED='yes'). Set RELOAD_NEED_RUN_AFTER_SPEC_TAGS_CHECK_str='yes')" "$EXEC_RESULT_FILE_str";
	
	RELOAD_NEED_RUN_AFTER_SPEC_TAGS_CHECK_str='yes';
    fi;

    if [[ `grep '#FORCE_REMOVE_TEMPORARY_IPSETS' "$SELF_DIR_str/recreate_temporary_ipsets.sh"` ]]; then
	# for cases: 1) temporary ipsets is recreated; 2) yes configured temporary ipsets.
	
	if [[ `grep -s -l "name=\"timeout\"" /etc/firewalld/ipsets/* | xargs grep -L "value=\"0\""` ]]; then
	    grep -s -l "name=\"timeout\"" /etc/firewalld/ipsets/* | xargs grep -L "value=\"0\"" | xargs rm;
	fi;
	
	write_log_func "FORCE_REMOVE_TEMPORARY_IPSETS (if RECREATE_TEMPORARY_IPSETS_CHANGED='yes'). Set RELOAD_NEED_RUN_AFTER_SPEC_TAGS_CHECK_str='yes')" "$EXEC_RESULT_FILE_str";
	
	RELOAD_NEED_RUN_AFTER_SPEC_TAGS_CHECK_str='yes';
    fi;
    
    if [[ "$RELOAD_NEED_RUN_AFTER_SPEC_TAGS_CHECK_str" == "yes" ]]; then
	write_log_func "Run 'firewall-cmd --reload' (if RELOAD_NEED_RUN_AFTER_SPEC_TAGS_CHECK_str='yes')" "$EXEC_RESULT_FILE_str";
	firewall-cmd --reload;
    fi;
fi;
###

# 2) Recreate permanent ipsets (if need).
if [[ "$RECREATE_PERMANENT_IPSETS_CHANGED_str" == "yes" ]]; then
    echo '#######################' &>> $EXEC_RESULT_FILE_str;
    write_log_func "Begin run 'recreate_permanent_ipsets.sh' (if RECREATE_PERMANENT_IPSETS_CHANGED='yes')" "$EXEC_RESULT_FILE_str";
    "$SELF_DIR_str/recreate_permanent_ipsets.sh" &>> $EXEC_RESULT_FILE_str;
    write_log_func "End run 'recreate_permanent_ipsets.sh' (if RECREATE_PERMANENT_IPSETS_CHANGED='yes')" "$EXEC_RESULT_FILE_str";
    echo '#######################' &>> $EXEC_RESULT_FILE_str;
fi;
###

# 3) Recreate temporary ipsets (if need).
if [[ "$RECREATE_TEMPORARY_IPSETS_CHANGED_str" == "yes" ]]; then
    echo '#######################' &>> $EXEC_RESULT_FILE_str;
    write_log_func "Begin run 'recreate_temporary_ipsets.sh' (if RECREATE_TEMPORARY_IPSETS_CHANGED='yes')" "$EXEC_RESULT_FILE_str";
    "$SELF_DIR_str/recreate_temporary_ipsets.sh" &>> $EXEC_RESULT_FILE_str;
    write_log_func "End run 'recreate_temporary_ipsets.sh' (if RECREATE_TEMPORARY_IPSETS_CHANGED='yes')" "$EXEC_RESULT_FILE_str";
    echo '#######################' &>> $EXEC_RESULT_FILE_str;
fi;
###

# 4) Recreate firewalld zones (if need).
if [[ "$RECREATE_FW_ZONES_CHANGED_str" == "yes" ]]; then
    echo '#######################' &>> $EXEC_RESULT_FILE_str;
    write_log_func "Begin run 'recreate_fw_zones.sh' (if RECREATE_FW_ZONES_CHANGED='yes')" "$EXEC_RESULT_FILE_str";
    "$SELF_DIR_str/recreate_fw_zones.sh" &>> $EXEC_RESULT_FILE_str;
    write_log_func "End run 'recreate_fw_zones.sh' (if RECREATE_FW_ZONES_CHANGED='yes')" "$EXEC_RESULT_FILE_str";
    echo '#######################' &>> $EXEC_RESULT_FILE_str;
fi;
###

# 5) Recreate firewalld policies (if need).
if [[ "$RECREATE_POLICIES_CHANGED_str" == "yes" ]]; then
    echo '#######################' &>> $EXEC_RESULT_FILE_str;
    write_log_func "Begin run 'recreate_policies.sh' (if RECREATE_POLICIES_CHANGED='yes')" "$EXEC_RESULT_FILE_str";
    "$SELF_DIR_str/recreate_policies.sh" &>> $EXEC_RESULT_FILE_str;
    write_log_func "End run 'recreate_policies.sh' (if RECREATE_POLICIES_CHANGED='yes')" "$EXEC_RESULT_FILE_str";
    echo '#######################' &>> $EXEC_RESULT_FILE_str;
fi;
###

# 6) Re-add. If need to re-add permanent ipsets elements from ansible-host as source.
if [[ "$PERMANENT_IPSETS_FLAG_FILE_CHANGED_str" == "yes" || "$PERMANENT_IPSETS_FLAG_FILE_PWET_CHANGED_str" == "yes" ]]; then
    # for permanent and permanent_with_external_timeout (pwet) if pwet-ipset-content exists
    
    echo '#######################' &>> $EXEC_RESULT_FILE_str;
    write_log_func "Begin run 're_add_ipsets_content.sh' with param='permanent' (if PERMANENT_IPSETS_FLAG_FILE_CHANGED/PERMANENT_IPSETS_FLAG_FILE_PWET_CHANGED='yes')" "$EXEC_RESULT_FILE_str";
    "$SELF_DIR_str/re_add_ipsets_content.sh" permanent &>> $EXEC_RESULT_FILE_str;
    write_log_func "End run 're_add_ipsets_content.sh' with param='permanent' (if PERMANENT_IPSETS_FLAG_FILE_CHANGED/PERMANENT_IPSETS_FLAG_FILE_PWET_CHANGED='yes')" "$EXEC_RESULT_FILE_str";
    echo '#######################' &>> $EXEC_RESULT_FILE_str;
fi;
###

# 7) Reload "firewall-cmd --reload" (if need).
    # If changed: recreate_permanent_ipsets.sh, recreate_temporary_ipsets.sh, recreate_fw_zones.sh, recreate_policies.sh
    # If executed: re_add_permanent_ipsets_content.sh
if [[ "$RELOAD_NEED_RUN_AT_THE_END_str" == "yes" ]]; then
    write_log_func "Run 'firewall-cmd --reload' (if RELOAD_NEED_RUN='yes')" "$EXEC_RESULT_FILE_str";
    firewall-cmd --reload;
fi;
###

# 8) Restart firewalld "systemctl restart firewalld" (if need).
    # If changed: firewalld.conf
if [[ "$FWCONFIG_CHANGED_str" == "yes" ]]; then
    write_log_func "Run 'systemctl restart firewalld' (if FWCONFIG_CHANGED='yes')" "$EXEC_RESULT_FILE_str";
    systemctl restart firewalld;
fi;
###

# 9) Re-add. If need to re-add ipsets elements from ansible-host as source.
if [[ "$TEMPORARY_IPSETS_FLAG_FILE_CHANGED_str" == "yes" ]]; then
    echo '#######################' &>> $EXEC_RESULT_FILE_str;
    write_log_func "Begin run 're_add_ipsets_content.sh' with param='temporary' (if TEMPORARY_IPSETS_FLAG_FILE_CHANGED='yes')" "$EXEC_RESULT_FILE_str";
    "$SELF_DIR_str/re_add_ipsets_content.sh" temporary &>> $EXEC_RESULT_FILE_str;
    write_log_func "End run 're_add_ipsets_content.sh' with param='temporary' (if TEMPORARY_IPSETS_FLAG_FILE_CHANGED='yes')" "$EXEC_RESULT_FILE_str";
    echo '#######################' &>> $EXEC_RESULT_FILE_str;
fi;
###

# 10) Rollback all changes (if need).
    # For rollback -> saved permanent ipsets content from 'fwrules_backup_now' (at 1 step).
    # For rollback -> saved temporary ipsets content from 'fwrules_backup_now' (at 1a step).
if [[ "$ROLLBACK_FWRULES_NEED_RUN_str" == "yes" ]]; then
    write_log_func "Run 'rollback_fwrules_changes.sh' as process (if ROLLBACK_FWRULES_NEED_RUN='yes')" "$EXEC_RESULT_FILE_str";
    nohup sh -c '~/ansible_helpers/conf_firewalld/rollback_fwrules_changes.sh >/dev/null 2>&1' & sleep 1;
fi;
###

# remove files
rm -rf "$SELF_DIR_str/apply_fwrules_is_run_now";
rm -rf $APPLY_RUN_INFO_DIR_str/*; # remove run-info
###
