#!/bin/bash
#
# tests.sh
#
# pimt project
#
# Tests
#
# TBD
#

source core.sh

TEST_DIR="test/"

# check_diff
TEST_DIFF_CMD="diff"
TEST_DIFF_FILE=$TEST_DIR"test.diff"
TEST_OUT_FILE=$TEST_DIR"test.out"
TEST_POUT_FILE=$TEST_DIR"test.pout"

# send_mail
#TEST_DIFF_FILE=$TEST_DIR"test.diff"
TEST_EMAIL_ADDR="test-emailXXYY@here.com"
TEST_TARGET_INFO="test"

mkdir -p $TEST_DIR

#echo "123" > $TEST_DIFF_FILE

# check_diff returns zero for no difference, non-zero for difference
# test_check_diff() {
#     TEST=$1

#     if [ $TEST -eq 0 ]; then
#         echo "1" > $TEST_OUT_FILE
#         echo "1" > $TEST_POUT_FILE
#     fi

#     if [ $TEST -eq 1 ]; then
#         echo "1" > $TEST_OUT_FILE
#         echo "2" > $TEST_POUT_FILE
#     fi

#     check_diff \
#         "$TEST_DIFF_CMD" \
#         "$TEST_DIFF_FILE" \
#         "$TEST_OUT_FILE" \
#         "$TEST_POUT_FILE"
# }

# test_send_mail() {
#     send_mail \
#     "$TEST_DIFF" \
#     "$TEST_EMAIL_FROM" \
#     "$TEST_EMAIL_TO" \
#     "$TEST_TARGET"
# }

# no diff
# test_check_diff 0

# if [ $? -eq 0 ]; then
#     echo "test_check_diff 0 passed"
# fi

# with diff
# test_check_diff 1

# if [ $? -ne 0 ]; then
#     echo "test_check_diff 1 passed"
# fi

# with diff
# test_send_mail

# if [ $? -eq 0 ]; then
#     echo "test_send_mail passed"
# fi
