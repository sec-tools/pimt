#!/bin/bash
#
# defs.sh
#
# pimt project
#
# definitions
#

# defaults
#WORDLIST="/opt/SecLists/Discovery/DNS/deepmagic.com-prefixes-top50000.txt"
WORDLIST="/opt/SecLists/Discovery/DNS/deepmagic.com-prefixes-top500.txt"
CADENCE=$((60*60))

# misc
ALL_CLOUD=0
AWS_SES_CMD="aws ses send-email"
CLEAN_DATA_DIR=1
CLEAN_MAIL_DIFF=1
DIFF_BIN="diff"
DIFF_THRESHOLD=64
GREP_BIN_COUNT="grep -ohPc"
GREP_BIN="grep -ohP"
SED_BIN="sed -e"
JQ_BIN="jq"
JQ_SPLIT='split("\n")'
PAT_ANNOTATE_BEGIN='s/$/ ('
PAT_ANNOTATE_END=')/'
PAT_ANNOTATE_REMOVE='s/ (.*//'
PAT_DROP_DIFF='s/> //'
NMAP_TOP_PORTS="21-23,25,53,80,110-111,135,139,143,443,445,993,995,1723,3306,3389,5900,8080"
PORT_SED_BIN="sed -rn"
PORT_MATCH_IP='/([0-9]{1,3}\.){3}[0-9]{1,3}/p'
PAT_PORT='.+\s.+\s'
PAT_NO_NEWLINE='${/^$/d}'
STATS=1
WC="wc -l"

# tools shouldn't take longer than 2min to complete
TIMEOUT_CMD="timeout"
TIMEOUT_SEC=120

# dirs
DATA_DIR="data/"
DIFF_DIR=$DATA_DIR"diff/"
RUN_DIR="run/"

# main files
TARGET_TMP=$DATA_DIR"target.tmp"
KEYWORD_TMP=$DATA_DIR"keyword.tmp"
DIFF_TMP=$DATA_DIR"tmp.diff"
DIFF_ANNO=$DATA_DIR"run.anno"
DIFF_FILE=$DATA_DIR"run.diff"
OUT_TMP=$DATA_DIR"run.tmp"
OUT_ANNO=$DATA_DIR"run.anno.out"
OUT_FILE=$DATA_DIR"run.out"
POUT_ANNO=$DATA_DIR"run.anno.pout"
POUT_FILE=$DATA_DIR"run.pout"

# check ports
IP_OUT_FILE=$DATA_DIR"ips.out"
PORT_PRE_FILE=$DATA_DIR"port.pre"
PORT_TMP_FILE=$DATA_DIR"port.tmp"
PORT_OUT_FILE=$DATA_DIR"port.out"
PORT_POUT_FILE=$DATA_DIR"port.pout"
PORT_DIFF_FILE=$DATA_DIR"port.diff"

# tool data

# bucketstream
BUCKETSTREAM_DEFAULT_FILE="buckets.log"
BUCKETSTREAM_TMP_FILE=$DATA_DIR"bucketstream.tmp"
BUCKETSTREAM_OUT_FILE=$DATA_DIR"bucketstream.out"
BUCKETSTREAM_POUT_FILE=$DATA_DIR"bucketstream.pout"
BUCKETSTREAM_DIFF_FILE=$DATA_DIR"bucketstream.diff"

# how long to stream
BUCKETSTREAM_TIMEOUT="timeout 30"
BUCKETSTREAM_GREP_CMD="xargs -I {} grep {}"

# certstream
CERTSTREAM_DEFAULT_FILE="certstream.log"
CERTSTREAM_TMP_FILE="certstream.tmp"
CERTSTREAM_OUT_FILE=$DATA_DIR"certstream.out"
CERTSTREAM_POUT_FILE=$DATA_DIR"certstream.pout"
CERTSTREAM_DIFF_FILE=$DATA_DIR"certstream.diff"

# how long to stream
CERTSTREAM_TIMEOUT="timeout 10"
CERTSTREAM_GREP_CMD="xargs -I {} $GREP_BIN"
CERTSTREAM_CLEAN='.*[\.\-]+{}[\.\-].*'

# cloudenum
CLOUDENUM_TMP_FILE=$DATA_DIR"cloudenum.tmp"
CLOUDENUM_OUT_FILE=$DATA_DIR"cloudenum.out"
CLOUDENUM_POUT_FILE=$DATA_DIR"cloudenum.pout"
CLOUDENUM_DIFF_FILE=$DATA_DIR"cloudenum.diff"

# this works for aws, but probably not for gcp or azure urls
CLOUD_CLEAN='(?<=http://).*[^\/]'

# subfinder
SUBFINDER_TMP_FILE=$DATA_DIR"subfinder.tmp"
SUBFINDER_OUT_FILE=$DATA_DIR"subfinder.out"
SUBFINDER_POUT_FILE=$DATA_DIR"subfinder.pout"
SUBFINDER_DIFF_FILE=$DATA_DIR"subfinder.diff"

# sublist3r
SUBLISTER_PRE_FILE=$DATA_DIR"sublister.pre.tmp"
SUBLISTER_TMP_FILE=$DATA_DIR"sublister.tmp"
SUBLISTER_OUT_FILE=$DATA_DIR"sublister.out"
SUBLISTER_POUT_FILE=$DATA_DIR"sublister.pout"
SUBLISTER_DIFF_FILE=$DATA_DIR"sublister.diff"

SUBLISTER_XARGS_CMD="xargs -I {} sh -c"
