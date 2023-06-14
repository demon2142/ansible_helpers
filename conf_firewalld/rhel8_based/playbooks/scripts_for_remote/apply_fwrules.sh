#!/usr/bin/bash

###GENERATED BY ansible_helpers/conf_firewalld (https://github.com/vladimir-chursin000/ansible_helpers)

SELF_DIR_str="$(dirname $(readlink -f $0))";
touch "$SELF_DIR_str/apply_fwrules_is_run_now";

###CFG
APPLY_RUN_INFO_DIR_str="$SELF_DIR_str/apply_run_info";
BACKUP_FOR_ROLLBACK_DIR_str="$SELF_DIR_str/fwrules_backup_now";
###CFG

###VARS
FWCONFIG_CHANGED_str='no';
RECREATE_PERMANENT_IPSETS_CHANGED_str='no';
RECREATE_TEMPORARY_IPSETS_CHANGED_str='no';
RECREATE_FW_ZONES_CHANGED_str='no';
RECREATE_POLICIES_CHANGED_str='no';
ROLLBACK_FWRULES_NEED_RUN_str='no';
RELOAD_NEED_RUN_str='no';
###VARS

###APPLY_RUN_INFO read
if [[ -f "$APPLY_RUN_INFO_DIR_str/fwconfig_changed" ]]; then
    FWCONFIG_CHANGED_str='yes';
fi;

if [[ -f "$APPLY_RUN_INFO_DIR_str/recreate_permanent_ipsets_changed" ]]; then
    RECREATE_PERMANENT_IPSETS_CHANGED_str='yes';
    RELOAD_NEED_RUN_str='yes';
fi;

if [[ -f "$APPLY_RUN_INFO_DIR_str/recreate_temporary_ipsets_changed" ]]; then
    RECREATE_TEMPORARY_IPSETS_CHANGED_str='yes';
    RELOAD_NEED_RUN_str='yes';
fi;

if [[ -f "$APPLY_RUN_INFO_DIR_str/recreate_fw_zones_changed" ]]; then
    RECREATE_FW_ZONES_CHANGED_str='yes';
    RELOAD_NEED_RUN_str='yes';
fi;

if [[ -f "$APPLY_RUN_INFO_DIR_str/recreate_policies_changed" ]]; then
    RECREATE_POLICIES_CHANGED_str='yes';
    RELOAD_NEED_RUN_str='yes';
fi;

if [[ -f "$APPLY_RUN_INFO_DIR_str/rollback_fwrules_need_run" ]]; then
    ROLLBACK_FWRULES_NEED_RUN_str='yes';
fi;

rm -rf $APPLY_RUN_INFO_DIR_str/*;
###APPLY_RUN_INFO read

# 1) Save content of "/etc/firewalld" to "~/ansible_helpers/conf_firewalld/fwrules_backup_now" (if need).
    # For rollback of permanent content/rules. Exception - content of a temporary ipsets.
    # Create "~/ansible_helpers/conf_firewalld/fwrules_backup_now" if need.
if [[ "$ROLLBACK_FWRULES_NEED_RUN_str" == "yes" ]]; then
    mkdir -p "$BACKUP_FOR_ROLLBACK_DIR_str";
    cp -r /etc/firewalld/* "$BACKUP_FOR_ROLLBACK_DIR_str";

    # 1a) Save content of temporary ipsets (if need) to 'fwrules_backup_now'. For rollback.
    mkdir -p "$BACKUP_FOR_ROLLBACK_DIR_str/temporary_ipsets_content";
    ###
fi;
###

# 2) Restart firewalld "systemctl restart firewalld" (if need).
    # If changed: firewalld.conf
if [[ "$FWCONFIG_CHANGED_str" == "yes" ]]; then
    systemctl restart firewalld;
fi;
###

# 3) Recreate permanent ipsets (if need).
#if [[ "$RECREATE_PERMANENT_IPSETS_CHANGED_str" == "yes" ]]; then
#    "$SELF_DIR_str/recreate_permanent_ipsets.sh" &> "$SELF_DIR_str/recreate_permanent_ipsets-res.txt";
#fi;
###

# 4) Recreate temporary ipsets (if need).
#if [[ "$RECREATE_TEMPORARY_IPSETS_CHANGED_str" == "yes" ]]; then
#    "$SELF_DIR_str/recreate_temporary_ipsets.sh" &> "$SELF_DIR_str/recreate_temporary_ipsets-res.txt";
#fi;
###

# 5) Recreate firewalld zones (if need).
#if [[ "$RECREATE_FW_ZONES_CHANGED_str" == "yes" ]]; then
#    "$SELF_DIR_str/recreate_fw_zones.sh" &> "$SELF_DIR_str/recreate_fw_zones-res.txt";
#fi;
###

# 6) Recreate firewalld policies (if need).
#if [[ "$RECREATE_POLICIES_CHANGED_str" == "yes" ]]; then
#    "$SELF_DIR_str/recreate_policies.sh" &> "$SELF_DIR_str/recreate_policies-res.txt";    
#fi;
###

# 7) Re-add. If need to re-add ipsets elements from ansible-host as source.
#if [[ -s "$SELF_DIR_str/re_add_permanent_ipsets_content.sh" ]]; then
#    "$SELF_DIR_str/re_add_permanent_ipsets_content.sh" &> "$SELF_DIR_str/re_add_permanent_ipsets_content-res.txt";
#fi;
###

# 8) Reload "firewall-cmd --reload" (if need).
    # If changed: recreate_permanent_ipsets.sh, recreate_temporary_ipsets.sh, recreate_fw_zones.sh, recreate_policies.sh,
    # If executed: restore_permanent_ipsets_content.sh, modify_permanent_ipsets_content.sh
#if [[ "$RELOAD_NEED_RUN_str" == "yes" ]]; then
#    firewall-cmd --reload;
#fi;
###

# 9) Re-add. If need to re-add ipsets elements from ansible-host as source.
#if [[ -s "$SELF_DIR_str/re_add_temporary_ipsets_content.sh" ]]; then
#    "$SELF_DIR_str/re_add_temporary_ipsets_content.sh" &> "$SELF_DIR_str/re_add_temporary_ipsets_content-res.txt";
#fi;
###

# 10) Rollback all changes (if need).
    # For rollback -> saved permanent ipsets content from 'fwrules_backup_now' (at 1 step).
    # For rollback -> saved temporary ipsets content from 'fwrules_backup_now' (at 1a step).
#if [[ "$ROLLBACK_FWRULES_NEED_RUN_str" == "yes" ]]; then
#    nohup sh -c '~/ansible_helpers/conf_firewalld/rollback_fwrules_changes.sh >/dev/null 2>&1' & sleep 1;
#fi;
###

rm -rf "$SELF_DIR_str/apply_fwrules_is_run_now";
