#!/bin/bash
#
# runs.sh
#
# xasy project
#
# tool runs
#

# because it just runs, streaming incoming data, we gotta choose when to cut it off
BUCKETSTREAM_RUN_CMD="$BUCKETSTREAM_BIN -l"

CERTSTREAM_RUN_CMD="$CERTSTREAM_BIN $KEYWORD_FILE"

if [ $ALL_CLOUD = 0 ]; then
    CLOUDENUM_RUN_CMD="$CLOUDENUM_BIN -kf $KEYWORD_FILE -l $CLOUDENUM_TMP_FILE --disable-gcp --disable-azure"
else
    CLOUDENUM_RUN_CMD="$CLOUDENUM_BIN -kf $KEYWORD_FILE -l $CLOUDENUM_TMP_FILE"
fi

# only use consistent sources
SUBFINDER_RUN_CMD="$SUBFINDER_BIN -sources threatminer -dL $TARGET_FILE -o $SUBFINDER_TMP_FILE"

# same here
SUBLISTER_RUN_CMD="$SUBLISTER_BIN -e threatcrowd -d {} -o $SUBLISTER_PRE_FILE; cat $SUBLISTER_PRE_FILE >> $SUBLISTER_TMP_FILE"

# check ports
if [ ! -z $CHECK_PORTS_HOST ]; then
    PORT_SCAN_CMD="masscan --open -p $NMAP_TOP_PORTS -oL $PORT_PRE_FILE $CHECK_PORTS_HOST"
elif [ ! -z $CHECK_PORTS_FILE ]; then
    PORT_SCAN_CMD="masscan --open -p $NMAP_TOP_PORTS -oL $PORT_PRE_FILE -iL $CHECK_PORTS_FILE"
fi
