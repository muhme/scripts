#!/bin/bash -e
#
# phmf.sh – prevent hidden mac folders ".Spotlight-V100" and ".fseventsd" e.g. on a USB stick on Mac OS X
#
# The ".Spotlight-V100" folder on a volume is used by macOS to store metadata and indexing information
# for the Spotlight search feature, enabling fast and efficient searching across the file system.
# 
# The ".fseventsd" folder on a volume is used by macOS to store file system event logs, which track changes
# in the file system, such as file creation, modification, deletion, and renaming, allowing applications and
# services to efficiently update their data based on these events.
#
# Both folders can be omitted e.g. on a USB stick.
#
# run with Volume name e.g.
# $ phmf.sh /Volume/KINGSTON
#
# tested on:
# - Mac OS X Ventura 13.2.1
#
# https://github.com/muhme/scripts
# hlu, Mar 31st 2023
# MIT license

ME=$(basename "$0")

if [[ $# != 1 ]] ; then
  echo "${ME}: wrong number of arguments! Please use e.g.: $0 /Volumes/KINGSTON" 1>&2
  exit 1
fi

VOLUME=$(df "$1" | awk 'NR==2 {print $NF}')
if [ "$1" != "$VOLUME" ] ; then
  echo "${ME}: Perhaps \"$1\" is not a volume? Did you mean \"$VOLUME\"?" 1>&2
  exit 1
fi

mdutil -s "$1" | grep -q "enabled" && {
  echo "${ME}: Spotlight metadata were enabled on \"$1\""
  mdutil -i off "$1" 
  if mdutil -s "$1" | grep -q "disabled" ; then
    echo "${ME}: Spotlight metadata are now disabled on \"$1\""
  else
    echo "${ME}: Probably Spotlight metadata are still enabled?" 1>&2
  fi
}

FOLDER="$1/.Spotlight-V100" 
if [ -d "$FOLDER" ] ; then
  rm -rf "$FOLDER" && echo "${ME}: Spotlight metadata folder \"$FOLDER\" deleted"
else
  echo "${ME}: No Spotlight metadata folder \"$FOLDER\" exists, that sounds good"
fi

FILE="$1/.metadata_never_index"
if [ -f "$FILE" ] ; then
  echo "${ME}: File \"$FILE\" already exists, that sounds good"
else
  touch "$FILE" && echo "${ME}: Empty file \"$FILE\" created"
fi

FSE="$1/.fseventsd" 
if [ -f "$FSE" ] ; then
  echo "${ME}: File \"$FSE\" already exist, that sounds good"
elif [ -d "$FSE" ] ; then
  rm -rf "$FSE" && echo "${ME}: File system event folder \"$FSE\" deleted"
fi
if [ ! -f "$FSE" ] ; then
  touch "$FSE"
  echo "${ME}: Empty file \"$FSE\" created"
fi
