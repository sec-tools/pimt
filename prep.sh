#!/bin/bash
#
# prep.sh
#
# xasy project
#
# misc prep work
#

source core.sh

# copy bucketstream files over to local dir
if [[ $BUCKETSTREAM_ENABLE = 1 ]]; then
    if [ ! -f config.yaml ]; then
        cp $BUCKETSTREAM_HOME/config.yaml .
    fi

    if [ ! -f keywords.txt ]; then
        cp $BUCKETSTREAM_HOME/keywords.txt .
    fi

    if [ ! -f permutations/default.txt ]; then
        cp -R $BUCKETSTREAM_HOME/permutations .
    fi
fi

if [[ $SAVE_RUN = 1 ]]; then
    save_last_run
fi

if [[ $CLEAN_DATA_DIR = 1 ]]; then
    rm -rf $DATA_DIR/*
fi

# make dirs
mkdir -p $DATA_DIR $DIFF_DIR $RUN_DIR

# reverse hammer time
touch POUT_FILE

# handle target and keyword options and associated files

if [ -z $TARGET ] && [[ $TARGET_FILE ]]; then
    if [ -f $TARGET_FILE ]; then
        # newline2comma
        TARGET_PRE=$(tr '\n' ',' < $TARGET_FILE)
        TARGET=${TARGET_PRE%?}
    else
        echo -e "target file '$TARGET_FILE' doesn't exist\n"
        exit 1
    fi
else
    # accept targets as domain1,domain2 but support tools that need files
    echo -n $TARGET > $TARGET_TMP

    # comma2newline
    if [ ! -z $TARGET_FILE ]; then
        tr ',' '\n' < $TARGET_TMP > $TARGET_FILE
        rm $TARGET_TMP
    fi
fi

if [ -z $KEYWORD ] && [[ $KEYWORD_FILE ]]; then
    if [ -f $KEYWORD_FILE ]; then
        KEYWORD_PRE=$(tr '\n' ',' < $KEYWORD_FILE)
        KEYWORD=${KEYWORD_PRE%?}
    else
        echo -e "keyword file '$KEYWORD_FILE' doesn't exist\n"
        exit 1
    fi
else
    echo -n $KEYWORD > $KEYWORD_TMP

    tr ',' '\n' < $KEYWORD_TMP > $KEYWORD_FILE
    rm $KEYWORD_TMP
fi

# handle check ports
if [ -z $TARGET ] && [[ $KEYWORD ]]; then
    if [[ $CHECK_PORTS_ONLY = 1 ]]; then
        if [ ! -z $CHECK_PORTS_HOST ]; then
            TARGET=$CHECK_PORTS_HOST
        elif [ ! -z $CHECK_PORTS_FILE ]; then
            TARGET=$CHECK_PORTS_FILE
        fi
    fi
fi
