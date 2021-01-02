#!/bin/bash
#
# func.sh
#
# pimt project
#
# core functions
#

trap ctrl_c INT

function ctrl_c() {
    exit 1
}

disable_domain_tools() {
    SUBFINDER_ENABLE=0
    SUBLISTER_ENABLE=0
}

check_ports() {
    if [ ! -x "$(command -v "$MASSCAN_BIN")" ]; then
        echo -e "'$MASSCAN_BIN' was not found in PATH"
        exit 1
    fi

    if [ ! -f $CHECK_PORTS_FILE ]; then
        echo -e "check ports file doesn't exist"
        exit 1
    fi

    if [ -s $CHECK_PORTS_FILE ]; then
        if [[ $DEBUG -eq 1 ]]; then
            echo "> "$PORT_SCAN_CMD
        fi

        if [ ! -z $DDEBUG ] && [[ $DDEBUG -eq 1 ]]; then
            if ! $PORT_SCAN_CMD; then
                echo -e "failed to run $MASSCAN -- make sure to setcap cap_net_raw=ep `which $MASSCAN_BIN`"
                return 1
            fi
        else
            if ! $PORT_SCAN_CMD > /dev/null 2>&1; then
                echo -e "failed to run $MASSCAN_BIN"
                return 1
            fi
        fi

        $GREP_BIN "$PAT_PORT" $PORT_PRE_FILE > $PORT_TMP_FILE

        if ! sort $PORT_TMP_FILE > $PORT_OUT_FILE; then
            echo -e "sort failed on port tmp to out file"
        fi

        if [[ $DEBUG == 1 ]]; then
            echo -e ">> "$($WC $PORT_OUT_FILE)"\n"
        fi

        if ! diff_main \
            "$PORT_DIFF_FILE" \
            "$PORT_OUT_FILE" \
            "$PORT_POUT_FILE"; then
                echo -e "diff_main() failed\n"
        fi

        if ! mv $PORT_OUT_FILE $PORT_POUT_FILE; then
            echo -e "mv failed for port out to pout file\n"
        fi

        if ! rm $PORT_TMP_FILE; then
            echo -e "rm failed for port tmp file\n"
        fi
    fi

    return 0
}

# create json files for a given input file
do_json() {
    local in_file=$1
    local in_file_path="$(realpath $in_file)"
    local out_file=$in_file_path".json"

    # new line causes empty json string, fix would be nice
    if ! $JQ_BIN -R -s -c "$JQ_SPLIT" < $in_file > $out_file; then
        return $?
    fi

    return 0
}

# if there's a prior run (that completed at least one cycle to produce a .pout), save it
save_last_run() {
    if [ -f $POUT_FILE ]; then
        ts_last_run=$(stat -c %Z $POUT_FILE)
        last_run_dir=$RUN_DIR$ts_last_run

        if ! mkdir $last_run_dir; then
            echo -e "mkdir failed on last run dir"
            return 1
        fi

        if ! cp -R $DATA_DIR $last_run_dir; then
            echo -e "cp failed to last run dir"
            return 1
        fi
    fi

    return 0
}

# annotate tool output and add them to the eventual main out file
annotate_output() {
    local out_file=$1
    local pout_file=$2
    local tool_name=$3

    if [ ! -f $out_file ]; then
        echo -e "cannot find out file $out_file"
        return 1
    fi

    # annotate output with tool name
    local pat_annotate=$PAT_ANNOTATE_BEGIN$tool_name$PAT_ANNOTATE_END

    # annotate the contents
    if ! $SED_BIN "$pat_annotate" $out_file >> $OUT_TMP; then
        echo -e "failed to annotate and add out content to main tmp file"
        return 1
    fi

    return 0
}

# main check
diff_main() {
    local diff_file=$1
    local out_file=$2
    local pout_file=$3

    if [ ! -f $out_file ] || [ ! -f $pout_file ]; then
        return 0
    fi

    # if there was a diff, create diff, debug files and do mail
    if ! check_diff \
            "$DIFF_BIN" \
            "$diff_file" \
            "$out_file" \
            "$pout_file"; then

            echo -e "\nchanges detected, creating new diff\n"

            local timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

            # annotated, clean diff, stats files
            local ts_anno_file=$DIFF_DIR$timestamp".anno.diff"
            local ts_diff_file=$DIFF_DIR$timestamp".diff"
            local ts_stat_file=$DIFF_DIR$timestamp".stat.txt"

            # create annotated diff
            local anno_diff=$($GREP_BIN $DIFF_PAT $diff_file)

            if ! echo -e "$anno_diff" > $ts_anno_file; then
                echo -e "failed to create timestamped anno diff in $DIFF_DIR"
                return 1
            fi

            # create normal diff (if email is enabled, this diff gets used)
            local diff=$($GREP_BIN $DIFF_PAT $diff_file | $SED_BIN "$PAT_ANNOTATE_REMOVE")

            if ! echo -e "$diff" > $ts_diff_file; then
                echo -e "failed to create timestamped diff in $DIFF_DIR"
                return 1
            fi

            if [ $JSON -ne 0 ] && [ -f $ts_diff_file ]; then
                if ! do_json "$ts_diff_file"; then
                    echo -e "do_json() failed"
                fi
            fi

            if [[ $STATS = 1 ]]; then
                if [ -s $ts_diff_file ]; then
                    local wc_out=$($WC $out_file)
                    local wc_pout=$($WC $pout_file)

                    if ! echo -e "$wc_out\n$wc_pout" > $ts_stat_file; then
                        echo -e "failed to create timestamped stat in $DIFF_DIR"
                        return 1
                    fi
                fi
            fi

            # should probably check if .aws directory exists and error out otherwise
            if [[ $EMAIL_ENABLE = 1 ]]; then
                if ! send_mail \
                    "$diff" \
                    "$EMAIL_FROM" \
                    "$EMAIL_TO" \
                    "$TARGET"; then
                        echo -e "send_mail() failed"
                        return 1
                fi
            fi
        fi

    return 0
}

# check for difference in current and previous runs
# diff returns differently: 0 for nothing, > 0 for something
check_diff() {
    local diff_cmd=$1
    local diff_file=$2
    local out_file=$3
    local pout_file=$4

    # only run the diff if we have a previous run to compare
    if [ -f $pout_file ]; then

        # diff produces > 0 if there's a diff
        if [ ! -z $DDEBUG ] && [[ $DDEBUG = 1 ]]; then
            $diff_cmd $pout_file $out_file
        else
            $diff_cmd $pout_file $out_file > /dev/null 2>&1
        fi

        if [ $? -ne 0 ]; then
            $diff_cmd $pout_file $out_file > $DIFF_TMP

            # only produce a diff if it fits our chosen diff pattern
            if [ $($GREP_BIN_COUNT $DIFF_PAT $DIFF_TMP) -ne 0 ]; then
                $diff_cmd $pout_file $out_file > $diff_file
                #return $?
                return 1
            fi
        fi
    fi

    return 0
}

# awscli to send mail via ses
send_mail() {
    local diff=$1
    local email_from=$2
    local email_to=$3
    local target_info=$4

    if [ ! -z $DDEBUG ] && [[ $DDEBUG -eq 1 ]]; then
        echo -e "\n$diff\n"
    fi

    # func.sh: line 56: /snap/bin/aws: Argument list too long
    # happens with really long diff, maybe is there a way to
    # supply the Body as file input...
    if ! $AWS_SES_CMD \
        --from "$email_from" \
        --destination "ToAddresses=$email_to" \
        --message "Subject={Data='diff detected for $target_info'}, \
            Body={Text={Data='$diff'}}" >/dev/null 2>&1; then
                echo -e "awscli failed to send mail"
                return 1
    fi

    return 0
}
