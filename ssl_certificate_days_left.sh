#!/bin/bash -e
#
# ssl_certificate_days_left.sh – returns the number of days remaining for the SSL certificate of the given domain
#
# sample:
# $ ./ssl_certificate_days_left.sh domain.com
# 86
#
# tested on:
# - macOS X 13
# - Debian GNU/Linux 11
# - CentOS Stream 9
#
# https://github.com/muhme/scripts
# hlu, May 8th 2023
# MIT license

SCRIPT=`basename $0`

if [[ $# != 1 ]] ; then
  echo "${SCRIPT}: ERROR: wrong number of arguments, please use: ${SCRIPT} domain" 1>&2
  exit 1
fi
SERVER="$1"

# get the operating system name
OS=$(uname -s)

# actual Unix timestamp in seconds
NOW=$(date +%s)

END_DATE=$(openssl s_client -connect ${SERVER}:443 -servername ${SERVER} < /dev/null 2>/dev/null | openssl x509 -text 2>/dev/null | grep 'Not After' | awk '{print $4,$5,$7}')

if [ "$OS" = "Darwin" ]; then
  # get the Unix timestamp for the end date on macOS
  END_TIMESTAMP=$(date -j -f "%b %d %Y" "${END_DATE}" "+%s")
else
  # get the Unix timestamp for the end date on CentOS
  END_TIMESTAMP=$(date -d "${END_DATE}" "+%s")
fi

DAYS=$(( (END_TIMESTAMP - NOW) / 86400 ))

echo "${DAYS}"
