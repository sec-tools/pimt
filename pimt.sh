#!/bin/bash
#
# pimt.sh
#
# pimt project
#
# main script
#

# defs and funcs
source defs.sh
source core.sh

# tools and usage
source tools.sh
source opt.sh

# config and target prep
source prep.sh
source runs.sh

main() {
    # if keyword only, make adjustments
    # also note: if not keywords are provided, KEYWORD=TARGET so we can use them for tools expecting keywords
    if [ -z $TARGET ] && [[ $KEYWORD ]]; then
        TARGET=$KEYWORD
        echo -e "(notice: only keywords were specified, disabling tools that require target domains)\n"
        disable_domain_tools
    fi

    # check options
    if [ -z $QUICK ] && [ -z $CHECK_PORTS ]; then
        echo -e "Running continous discovery for provided domains and keywords including '$TARGET'...\n"
    elif [ -z $QUICK ] && [ $CHECK_PORTS -eq 1 ]; then
        if [ ! -z $CHECK_PORTS_HOST ]; then
            echo -e "Running continous discovery for provided domains and keywords including $TARGET and $CHECK_PORTS_HOST...\n"
        elif [ ! -z $CHECK_PORTS_FILE ]; then
            echo -e "Running continous discovery for provided domains and keywords including $TARGET and $CHECK_PORTS_FILE...\n"
        fi
    elif [ $QUICK -eq 1 ] && [ -z $CHECK_PORTS ]; then
        echo -e "Doing a quick run for provided domains and keywords including $TARGET...\n"
    elif [ $QUICK -eq 1 ] && [ $CHECK_PORTS -eq 1 ]; then
        if [ ! -z $CHECK_PORTS_HOST ]; then
            echo -e "Doing a quick run for provided domains and keywords including $TARGET and $CHECK_PORTS_HOST...\n"
        elif [ ! -z $CHECK_PORTS_FILE ]; then
            echo -e "Doing a quick run for provided domains and keywords including $TARGET and $CHECK_PORTS_FILE...\n"
        fi
    fi

    while [ : ]; do
        ################################################################
        # bucketstream
        if [ $BUCKETSTREAM_ENABLE -eq 1 ]; then
            if [ ! -x "$(command -v "$BUCKETSTREAM_BIN")" ]; then
                echo -e "'$BUCKETSTREAM_BIN' was not found in PATH"
                exit 1
            fi

            if [[ $DEBUG -eq 1 ]]; then
                echo -e "> "$BUCKETSTREAM_RUN_CMD
            fi

            # make sure we always have an out file of some sort
            touch $BUCKETSTREAM_OUT_FILE

            if [ ! -z $DDEBUG ] && [[ $DDEBUG -eq 1 ]]; then
                $TIMEOUT_CMD $TIMEOUT_SEC $BUCKETSTREAM_TIMEOUT $BUCKETSTREAM_RUN_CMD
            else
                $TIMEOUT_CMD $TIMEOUT_SEC $BUCKETSTREAM_TIMEOUT $BUCKETSTREAM_RUN_CMD > /dev/null 2>&1
            fi

            if [ -s $BUCKETSTREAM_DEFAULT_FILE ]; then
                $GREP_BIN $CLOUD_CLEAN $BUCKETSTREAM_DEFAULT_FILE > $BUCKETSTREAM_TMP_FILE

                # for each target/kw in txt, do grep
                < $KEYWORD_FILE $BUCKETSTREAM_GREP_CMD $BUCKETSTREAM_TMP_FILE > $BUCKETSTREAM_OUT_FILE

                if ! rm $BUCKETSTREAM_DEFAULT_FILE || ! rm $BUCKETSTREAM_TMP_FILE; then
                    echo -e "rm failed on bucketstream files"
                fi

                if [[ $DEBUG -eq 1 ]]; then
                    echo -e ">> "$($WC $BUCKETSTREAM_OUT_FILE)"\n"
                fi

                annotate_output \
                    "$BUCKETSTREAM_OUT_FILE" \
                    "$BUCKETSTREAM_POUT_FILE" \
                    "$BUCKETSTREAM"

                if ! mv $BUCKETSTREAM_OUT_FILE $BUCKETSTREAM_POUT_FILE; then
                    echo -e "mv failed on $BUCKETSTREAM out to pout"
                fi

                if ! rm $BUCKETSTREAM_DEFAULT_FILE; then
                    echo -e "rm failed for default file\n"
                fi
            else
                if [[ $DEBUG -eq 1 ]]; then
                    echo -e ">> no results\n"
                fi
            fi
        fi
        ################################################################

        ################################################################
        # certstream
        if [ $CERTSTREAM_ENABLE -eq 1 ]; then
            if [ ! -x "$(command -v "$CERTSTREAM_BIN")" ]; then
                echo -e "'$CERTSTREAM_BIN' was not found in PATH"
                exit 1
            fi

            if [[ $DEBUG -eq 1 ]]; then
                echo -e "> "$CERTSTREAM_RUN_CMD
            fi

            # make sure we always have an out file of some sort
            touch $CERTSTREAM_OUT_FILE

            if [ ! -z $DDEBUG ] && [[ $DDEBUG -eq 1 ]]; then
                $CERTSTREAM_TIMEOUT $CERTSTREAM_RUN_CMD
            else
                $CERTSTREAM_TIMEOUT $CERTSTREAM_RUN_CMD > /dev/null 2>&1
            fi

            if [ -s $CERTSTREAM_DEFAULT_FILE ]; then
                # for each target/kw in txt, do grep
                < $KEYWORD_FILE $CERTSTREAM_GREP_CMD $CERTSTREAM_CLEAN $CERTSTREAM_DEFAULT_FILE > $CERTSTREAM_OUT_FILE

                if [[ $DEBUG -eq 1 ]]; then
                    echo -e ">> "$($WC $CERTSTREAM_OUT_FILE)"\n"
                fi

                annotate_output \
                    "$CERTSTREAM_OUT_FILE" \
                    "$CERTSTREAM_POUT_FILE" \
                    "$CERTSTREAM"

                if ! mv $CERTSTREAM_OUT_FILE $CERTSTREAM_POUT_FILE; then
                    echo -e "mv failed on $CERTSTREAM out to pout"
                fi

                if ! rm $CERTSTREAM_DEFAULT_FILE; then
                    echo -e "rm failed for default file\n"
                fi
            else
                if [[ $DEBUG -eq 1 ]]; then
                    echo -e ">> no results\n"
                fi
            fi
        fi
        ################################################################

        ################################################################
        # cloudenum
        if [ $CLOUDENUM_ENABLE -eq 1 ]; then
            if [ ! -x "$(command -v "$CLOUDENUM_BIN")" ]; then
                echo -e "'$CLOUDENUM_BIN' was not found in PATH"
                exit 1
            fi

            if [[ $DEBUG -eq 1 ]]; then
                echo -e "> "$CLOUDENUM_RUN_CMD
            fi

            if [ ! -z $DDEBUG ] && [[ $DDEBUG -eq 1 ]]; then
                $TIMEOUT_CMD $TIMEOUT_SEC $CLOUDENUM_RUN_CMD
            else
                $TIMEOUT_CMD $TIMEOUT_SEC $CLOUDENUM_RUN_CMD > /dev/null 2>&1
            fi

            if [ -s $CLOUDENUM_TMP_FILE ]; then
                $GREP_BIN $CLOUD_CLEAN $CLOUDENUM_TMP_FILE > $CLOUDENUM_OUT_FILE

                if ! rm $CLOUDENUM_TMP_FILE; then
                    echo -e "rm failed on cloudenum tmp"
                fi

                if [[ $DEBUG -eq 1 ]]; then
                    echo -e ">> "$($WC $CLOUDENUM_OUT_FILE)"\n"
                fi

                annotate_output \
                    "$CLOUDENUM_OUT_FILE" \
                    "$CLOUDENUM_POUT_FILE" \
                    "$CLOUDENUM"
            else
                if [[ $DEBUG -eq 1 ]]; then
                    echo -e ">> no results\n"
                fi
            fi

            if ! mv $CLOUDENUM_OUT_FILE $CLOUDENUM_POUT_FILE; then
                echo -e "mv failed on $CLOUDENUM out to pout"
            fi
        fi
        ################################################################

        ################################################################
        # subfinder
        if [ $SUBFINDER_ENABLE -eq 1 ]; then
            if [ ! -x "$(command -v "$SUBFINDER_BIN")" ]; then
                echo -e "'$SUBFINDER_BIN' was not found in PATH"
                exit 1
            fi

            if [[ $DEBUG -eq 1 ]]; then
                echo "> "$SUBFINDER_RUN_CMD
            fi

            if [ ! -z $DDEBUG ] && [[ $DDEBUG -eq 1 ]]; then
                $TIMEOUT_CMD $TIMEOUT_SEC $SUBFINDER_RUN_CMD
            else
                $TIMEOUT_CMD $TIMEOUT_SEC $SUBFINDER_RUN_CMD > /dev/null 2>&1
            fi

            if [ -s $SUBFINDER_TMP_FILE ]; then
                if ! sort $SUBFINDER_TMP_FILE > $SUBFINDER_OUT_FILE; then
                    echo -e "sort failed on subfinder tmp to out file"
                fi

                if ! rm $SUBFINDER_TMP_FILE; then
                    echo -e "rm failed on subfinder tmp"
                fi

                if [[ $DEBUG -eq 1 ]]; then
                    echo -e ">> "$($WC $SUBFINDER_OUT_FILE)"\n"
                fi

                annotate_output \
                    "$SUBFINDER_OUT_FILE" \
                    "$SUBFINDER_POUT_FILE" \
                    "$SUBFINDER"
            else
                if [[ $DEBUG -eq 1 ]]; then
                    echo -e ">> no results\n"
                fi
            fi

            if [ -f $SUBFINDER_OUT_FILE ]; then
                if ! mv $SUBFINDER_OUT_FILE $SUBFINDER_POUT_FILE; then
                    echo -e "mv failed on $SUBFINDER out to pout"
                fi
            fi
        fi
        ################################################################

        ################################################################
        # sublister
        if [ $SUBLISTER_ENABLE -eq 1 ]; then
            if [ ! -x "$(command -v "$SUBLISTER_BIN")" ]; then
                echo -e "'$SUBLISTER_BIN' was not found in PATH"
                exit 1
            fi

            if [[ $DEBUG -eq 1 ]]; then
                echo -e "> "$SUBLISTER_RUN_CMD
            fi

            if [ ! -z $DDEBUG ] && [[ $DDEBUG -eq 1 ]]; then
                < $TARGET_FILE $SUBLISTER_XARGS_CMD "$SUBLISTER_RUN_CMD"
            else
                < $TARGET_FILE $SUBLISTER_XARGS_CMD "$SUBLISTER_RUN_CMD" > /dev/null 2>&1
            fi

            # clean results (n/a for sublister)
            if [ -s $SUBLISTER_TMP_FILE ]; then
                cp $SUBLISTER_TMP_FILE $SUBLISTER_OUT_FILE

                if ! rm $SUBLISTER_PRE_FILE; then
                    echo -e "rm failed on sublister pre tmp"
                fi

                if ! rm $SUBLISTER_TMP_FILE; then
                    echo -e "rm failed on sublister tmp"
                fi

                if [[ $DEBUG -eq 1 ]]; then
                    echo -e ">> "$($WC $SUBLISTER_OUT_FILE)"\n"
                fi

                annotate_output \
                    "$SUBLISTER_OUT_FILE" \
                    "$SUBLISTER_POUT_FILE" \
                    "$SUBLISTER"
            else
                if [[ $DEBUG -eq 1 ]]; then
                    echo -e ">> no results\n"
                fi
            fi

            if [ -f $SUBLISTER_OUT_FILE ]; then
                if ! mv $SUBLISTER_OUT_FILE $SUBLISTER_POUT_FILE; then
                    echo -e "mv failed on $SUBLISTER out to pout"
                fi
            fi
        fi
        ################################################################

        # run masscan
        if [[ $CHECK_PORTS -eq 1 ]]; then
            check_ports
        fi

        # sort results into annotated and main out files
        if [ -f $OUT_TMP ]; then
            if ! sort $OUT_TMP > $OUT_ANNO; then
                echo -e "sort failed on tmp to annotated main out file"
            fi

            if ! $SED_BIN "$PAT_ANNOTATE_REMOVE" $OUT_ANNO > $OUT_FILE; then
                echo -e "sed failed to create main out file"
            fi
        fi

        if [[ $DEBUG -eq 1 ]]; then
            if [ -f $OUT_FILE ]; then
                echo -e "> "$($WC $OUT_FILE)
            fi

            if [ -f $POUT_FILE ]; then
                echo -e "> "$($WC $POUT_FILE)"\n"
            elif [[ $QUICK -ne 1 ]]; then
                echo
            fi
        fi

        if [[ $QUICK -eq 1 ]]; then
            exit 0
        else
            if ! diff_main \
                "$DIFF_ANNO" \
                "$OUT_ANNO" \
                "$POUT_ANNO"; then
                    echo -e "diff_main() failed"
            fi

            # move out to pout, because in the end, nothing really matters.. :'D
            if [ -f $OUT_TMP ] && [ -f $OUT_FILE ]; then
                if ! mv $OUT_FILE $POUT_FILE; then
                    echo -e "mv failed for out to pout file\n"
                fi

                if [ -f $OUT_ANNO ]; then
                    if ! mv $OUT_ANNO $POUT_ANNO; then
                        echo -e "mv failed for annotated out to annotated pout file\n"
                    fi
                fi

                if ! rm $OUT_TMP; then
                    echo -e "rm failed for tmp file\n"
                fi

                if [ $JSON -ne 0 ] && [ -f $POUT_FILE ]; then
                    if ! do_json "$POUT_FILE"; then
                        echo -e "do_json() failed"
                    fi
                fi
            fi
        fi

    sleep $CADENCE

done
}

main "$@"
