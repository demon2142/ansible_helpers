#!/usr/bin/bash

SELF_DIR="$(dirname $(readlink -f $0))";
INV_FILE="$SELF_DIR/nfs_server_hosts";
PLAYBOOK='check_nfs_serv_conf_is_changed_playbook.yml';
LOG_DIR="$SELF_DIR/run_history";
IS_NEED_RUN_GEN_DYN_EXPORTS="NO";

$SELF_DIR/main.sh "$INV_FILE" "$PLAYBOOK" "$LOG_DIR" "$IS_NEED_RUN_GEN_DYN_EXPORTS";
