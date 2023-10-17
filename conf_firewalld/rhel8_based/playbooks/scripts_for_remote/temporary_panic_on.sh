#!/usr/bin/bash

###GENERATED BY ansible_helpers/conf_firewalld (https://github.com/vladimir-chursin000/ansible_helpers)

######INIT DIRS and FILES
SELF_DIR_str="$(dirname $(readlink -f $0))";
EXEC_RESULT_DIR_str="$SELF_DIR_str/exec_results";
NOW_YYYYMMDDHHMISS_AT_START_str=`date '+%Y%m%d%H%M%S'`;
EXEC_RESULT_FILE_str="$EXEC_RESULT_DIR_str/$NOW_YYYYMMDDHHMISS_AT_START_str-temporary_panic_on.log";
######INIT DIRS and FILES

if [[ ! -d $EXEC_RESULT_DIR_str ]]; then
    mkdir -p "$EXEC_RESULT_DIR_str";
fi;

######VARS
TIMEOUT_num=$1;
IS_CONNTRACK_TCP_LOOSE_ENABLED_str='';
######VARS

######FUNCTIONS
function write_log_func() {
    local local_log_str=$1;
    local local_log_file_str=$2;
    local local_now_yyyymmddhhmiss_str=`date '+%Y%m%d%H%M%S'`;

    echo "$local_now_yyyymmddhhmiss_str;+$local_log_str" &>> $local_log_file_str;
}
######FUNCTIONS

######MAIN
sleep 2;

write_log_func "Set panic on" "$EXEC_RESULT_FILE_str";
firewall-cmd --panic-on;
conntrack -F;

while :
do
    write_log_func "Wait iteration number $TIMEOUT_num" "$EXEC_RESULT_FILE_str";
     
    sleep 60;

    let "TIMEOUT_num-=1";
    
    if [[ "$TIMEOUT_num" -le "0" ]]; then
	write_log_func "Set panic off" "$EXEC_RESULT_FILE_str";
	firewall-cmd --panic-off;
	
	exit;
    fi;
done;
######MAIN
