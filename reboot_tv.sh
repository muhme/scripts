#!/bin/bash
#
# reboot_tv.sh - reboot Android TV if it has been up for more than 24 hours
#
# The problem is that the TV occasionally crashes and restarts. This can be avoided if it is restarted regularly.
# This can be done between 3 and 8 o'clock in the morning, for example. The system checks whether the Android TV
# is accessible and then restarts it without root rights if the TV has been switched on for more than 24 hours.
#
#   . working with SONY Bavaria TV for me, does not need root rights
#   . needs adb installed, on Mac with: brew install android-platform-tools
#   . nneds to authorize the connection once on TV
#   . correspondig crontab entry to restart between 3 and 8 o'clock in the Morning is:
#     0 3-8 * * * /Users/hlu/scripts/reboot_tv.sh
#   . syslog entries are shown on Mac with e.g. with:
#     log show --predicate 'process == "logger"'
#     ... logger: TV 192.168.178.66 Failed get uptime: adb: device offline
#     ... logger: TV 192.168.178.66 no reboot is needed, uptime is 20:48
#     ... logger: TV 192.168.178.66 is rebooting, uptime was 1 day
#
# https://github.com/muhme/scripts
# hlu, Apr 15 2024
# MIT license

# give the TV a fixed IP address and adjust it here
TV_IP="192.168.178.66"

# for adb, adjust if needed
PATH=$PATH:/usr/local/bin

ME=$(basename "$0")

OUTPUT=$(adb connect ${TV_IP} 2>&1)
# check for: "failed to connect to '192.168.178.66:5555': Host is down"
if [ $? -ne 0 ]; then
  logger -t "${ME}" "TV ${TV_IP} Failed to connect: ${OUTPUT}"
  exit 1
fi

# get uptime
OUTPUT=$(adb shell uptime 2>&1)
# check for "adb: device offline"
if [ $? -ne 0 ]; then
  logger -t "${ME}" "TV ${TV_IP} Failed get uptime: ${OUTPUT}"
  exit 1
fi

# samples with minutes, hours and days:
#   10:33:46 up 22 min,  0 users,  load average: 41.38, 40.77, 32.08
#   10:33:46 up  5:07, 4 users, load averages: 41.38, 40.77, 32.08
#   10:33:46 up 25 days,  4:01,  1 user,  load average: 41.38, 40.77, 32.08
UPTIME=$(echo $OUTPUT | sed 's/.*up //' | sed 's/, .*//')

# check if the TV is up > 24 hours
if echo "${UPTIME}" | grep -q "day"; then
  logger -t "${ME}" "TV ${TV_IP} is rebooting, uptime was ${UPTIME}"
  adb shell reboot
else
  logger -t "${ME}" "TV ${TV_IP} no reboot is needed, uptime is ${UPTIME}"
fi
