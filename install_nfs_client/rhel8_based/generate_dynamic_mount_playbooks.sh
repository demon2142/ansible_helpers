#!/usr/bin/bash

SELF_DIR="$(dirname $(readlink -f $0))";
DYNAMIC_PLAYBOOKS="$SELF_DIR/playbooks/dynamic_playbooks";
CONF_FILE="$SELF_DIR/dyn_mount_config";

###VARS
LINE='';
EXE_RES='';
PARAM_ARRAY=();
DYN_MOUNT_FILE_NAME='';
###VARS

IS_ONLY_UNMOUNT=$1;

EXE_RES=`rm -rf "$DYNAMIC_PLAYBOOKS"/*_dyn_mount.yml`;
REGEX="^#.*";

while read LINE; do
    if [[ ! -z "$LINE" ]] && [[ ! "$LINE" =~ $REGEX ]]; then
	PARAM_ARRAY=($LINE);
	DYN_MOUNT_FILE_NAME="$DYNAMIC_PLAYBOOKS/${PARAM_ARRAY[0]}_dyn_mount.yml";
	if [[ ! -z "$IS_ONLY_UNMOUNT" ]] && [[ "$IS_ONLY_UNMOUNT" == "1" ]]; then
	    PARAM_ARRAY[5]='absent';
	fi;
	echo "- name: mount_nfs" >> $DYN_MOUNT_FILE_NAME;
	echo "  ansible.posix.mount:" >> $DYN_MOUNT_FILE_NAME;
	echo "    src: ${PARAM_ARRAY[1]}" >> $DYN_MOUNT_FILE_NAME;
	echo "    path: ${PARAM_ARRAY[2]}" >> $DYN_MOUNT_FILE_NAME;
	echo "    opts: ${PARAM_ARRAY[3]}" >> $DYN_MOUNT_FILE_NAME;
	echo "    boot: ${PARAM_ARRAY[4]}" >> $DYN_MOUNT_FILE_NAME;
	echo "    state: ${PARAM_ARRAY[5]}" >> $DYN_MOUNT_FILE_NAME;
	echo "    fstype: nfs" >> $DYN_MOUNT_FILE_NAME;
	echo "    backup: yes" >> $DYN_MOUNT_FILE_NAME;
	echo " " >> $DYN_MOUNT_FILE_NAME;
	echo "######################################################" >> $DYN_MOUNT_FILE_NAME;
	echo " " >> $DYN_MOUNT_FILE_NAME;
    fi;
done < "$CONF_FILE";
