#!/usr/bin/bash

SELF_DIR="$(dirname $(readlink -f $0))";
INV_FILE="$SELF_DIR/conf_firewall_hosts";
PLAYBOOK='full_install_firewall_and_configure_fwrules_pb.yml';
LOG_DIR="$SELF_DIR/run_history";
PLAYBOOK_BEFORE='fwrules_backup_pb.yml';
GEN_DYN_FWRULES_RUN='yes';

$SELF_DIR/main.sh "$INV_FILE" "$PLAYBOOK" "$LOG_DIR" "$PLAYBOOK_BEFORE" "$GEN_DYN_FWRULES_RUN";
