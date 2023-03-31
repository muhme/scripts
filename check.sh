#!/bin/bash -e
#
# check.sh - checking file consistency, e.g. on a USB stick
#   Working for the files from actual working directory.
#   Creating files ".check.size" and ".check.md5" with counting of bytes and
#   MD5 hashes of all files at first run.
#   In following runs all files are compared by size and MD5 hash.
#
# sample outputs:
#
#   $ ./check  # initial running
#   check: Running 1st time, creating files ".check.size" and ".check.md5"
#   check: Found 21925 files, stored file sizes and MD5 hashes, have a nice day
# 
#   $ ./check  # running 2nd time
#   check: Checking all files with files ".check.size" and ".check.md5"
#   check: 21925 files are checked in size and MD5 hash successfully, have a nice day
#
#   $ ./check  # showing a difference in file size
#   check: Checking all files with files ".check.size" and ".check.md5"
#   1c1
#   <     1448 ./check
#   ---
#   >     1472 ./check
#   check: Oops file sizes differ! You may have a problem?
#
# tested on:
# - Mac OS X Ventura 13.2.1
# - Debian GNU/Linux 11 (bullseye), inside docker container
# - CentOS Stream 9
#
# https://github.com/muhme/scripts
# hlu, Mar 30th 2023
# MIT license

ME=$(basename "$0")
CHECKFILE=".check"
MD5="${CHECKFILE}.md5"
SIZE="${CHECKFILE}.size"
TMP_MD5="/tmp/${ME}.MD5.$$"
TMP_SIZE="/tmp/${ME}.SIZE.$$"

trap 'rm -rf "${TMP_MD5}" "${TMP_SIZE}"' 0

# Check for md5 or md5sum command
if command -v md5 > /dev/null; then
    MD5_CMD="md5"
elif command -v md5sum > /dev/null; then
    MD5_CMD="md5sum"
else
    echo "${ME}: Error: Neither 'md5' nor 'md5sum' command is available on this system!" 1>&2
    exit 1
fi

if [ -f "${SIZE}" -a -f "${MD5}" ] ; then
  echo "${ME}: Checking all files with files \"${SIZE}\" and \"${MD5}\""
  find . -type f -not -name '.*' -exec wc -c {} \; > "${TMP_SIZE}"
  if ! diff "${SIZE}" "${TMP_SIZE}" ; then
    echo "${ME}: Oops: File sizes differ! You may have a problem?" 1>&2
    exit 1
  fi
  find . -type f -not -name '.*' -exec ${MD5_CMD} {} \; > "${TMP_MD5}"
  if ! diff "${MD5}" "${TMP_MD5}" ; then
    echo "${ME}: Oops: MD5 hashes differ! You may have a problem?" 1>&2
    exit 1
  fi
  echo "${ME}:" $(wc -l < "${SIZE}") "files were successfully checked for size and MD5 hash, have a nice day"
  exit 0
else
  echo "${ME}: Running 1st time, creating files \"${SIZE}\" and \"${MD5}\""
  find . -type f -not -name '.*' -exec wc -c {} \; > "${SIZE}"
  find . -type f -not -name '.*' -exec ${MD5_CMD} {} \; > "${MD5}"
  echo "${ME}: Found " $(wc -l < "${SIZE}") " files, stored file sizes and MD5 hashes, have a nice day"
fi
