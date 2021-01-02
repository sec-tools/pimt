#!/bin/bash
#
# opt.sh
#
# pimt project
#
# options
#

usage() {
    echo -e "usage: $0 -t/T <target/TXT> [-k/K <keyword/TXT] [-ef email] [-w wordlist] [-s 60] [-a config.ini] [-d -dd -k -q -r -u -m -j -p/-pp]"
    exit 1
}

while [[ $# -gt 0 ]]; do
    opt=$1
    case $opt in
        -t)
            shift
            TARGET=$1 ;;
        -T)
            shift
            TARGET_FILE=$1 ;;
        -k)
            shift
            KEYWORD=$1 ;;
        -K)
            shift
            KEYWORD_FILE=$1 ;;
        -ef)
            shift
            EMAIL_FROM=$1 ;;
        -et)
            shift
            EMAIL_TO=$1 ;;
        -w)
            shift
            WORDLIST=$1
            [ ! -f $WORDLIST ] && echo -e "error: '$WORDLIST' not found" && exit 1 ;;
        -s)
            shift
            CADENCE=$1
            ((CADENCE == 1 || CADENCE <= (60*60*24*60))) || usage ;;
        -a)
            shift
            AMASS_CONFIG=$1
            [ ! -f $AMASS_CONFIG ] && echo -e "error: '$AMASS_CONFIG' not found" && exit 1 ;;
        -p)
            shift
            CHECK_PORTS_HOST=$1 ;;
        -P)
            shift
            CHECK_PORTS_FILE=$1 ;;
        -d)
            DEBUG=1 ;;
        -dd)
            DDEBUG=1 ;;
        -j)
            JSON=1 ;;
        -q)
            QUICK=1 ;;
        -r)
            CHECK_REMOVALS=1 ;;
        -u)
            SAVE_RUN=0 ;;
        # tools
        -DAMASS)
            AMASS_ENABLE=0 ;;
        -DBUCKETSTREAM)
            BUCKETSTREAM_ENABLE=0 ;;
        -DCERTSTREAM)
            CERTSTREAM_ENABLE=0 ;;
        -DCLOUDENUM)
            CLOUDENUM_ENABLE=0 ;;
        -DSUBFINDER)
            SUBFINDER_ENABLE=0 ;;
        -DSUBLISTER)
            SUBLISTER_ENABLE=0 ;;
        -h|--help)
            usage ;;
        esac
    shift
done

# some tools only need targets, some only use keywords.. and then there's check ports file
if [ -z $TARGET ] && [ -z $TARGET_FILE ]; then
    if [ -z $KEYWORD ] && [ -z $KEYWORD_FILE ]; then
        if [ -z $CHECK_PORTS_HOST ] && [ -z $CHECK_PORTS_FILE ]; then
            usage
        fi
    fi
fi

# if user doesn't specify target file, use the default
#if [ -n "$TARGET" ] && [ -z $TARGET_FILE ]; then
if [[ $TARGET ]] && [ -z $TARGET_FILE ]; then
    TARGET_FILE=$DATA_DIR"target.txt"
fi

# if we have keyword and no keyword file specified, use the default
if [ ! -z $KEYWORD ] && [ -z $KEYWORD_FILE ]; then
    KEYWORD_FILE=$DATA_DIR"keyword.txt"
fi

# if no keyword file is given (eg. cloudenum), just use the target file
if [ -z $KEYWORD ] && [ -z $KEYWORD_FILE ]; then
    KEYWORD_FILE=$TARGET_FILE
fi

# by default we only monitor for additions
if [ -z $CHECK_REMOVALS ]; then
    DIFF_PAT='(>).*'
else
    DIFF_PAT='(<|>).*'
fi

if [ ! -z $CHECK_PORTS_HOST ] || [ ! -z $CHECK_PORTS_FILE ]; then
    CHECK_PORTS=1
fi

if [ ! -z $EMAIL_FROM ] && [ ! -z $EMAIL_TO ]; then
    EMAIL_ENABLE=1
fi

# debug flags are escalating
if [ -z $DEBUG ] && [[ $DDEBUG == 1 ]]; then
    DEBUG=1
fi
