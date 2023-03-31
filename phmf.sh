#!/bin/bash -e
#
# phmf.sh – prevent hidden mac folders e.g. on a USB stick on Mac OS X
#
# The ".Spotlight-V*" folder on a volume is used by macOS to store metadata and indexing information
# for the Spotlight search feature, enabling fast and efficient searching across the file system.
# 
# The ".fseventsd" folder on a volume is used by macOS to store file system event logs, which track changes
# in the file system, such as file creation, modification, deletion, and renaming, allowing applications and
# services to efficiently update their data based on these events.
#
# The ".Trashes" folder is used to store files and folders that have been moved to the Trash,
# allowing users to recover deleted items or permanently delete them later.
#
# The ".DS_Store" file has custom attributes and metadata for each folder.
# The "._.DS_Store" is an AppleDouble file that holds resource fork information for the ".DS_Store" file.
#
# All hidden folders and files can be omitted e.g. on a USB stick.
#
# run with Volume name e.g.
# $ phmf.sh /Volume/KINGSTON
#
# tested on:
# - Mac OS X Ventura 13.2.1
#
# On Catalina and later, if you get "Operation not permitted" when deleting metadata on removable volumes
# via scipting, grant Terminal Full Disk Access in System Preferences > Security & Privacy.

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

FOLDER="$1/.Spotlight-V*" 
if [ -d "$FOLDER" ] ; then
  rm -rf "$FOLDER" && echo "${ME}: Spotlight metadata folder \"$FOLDER\" deleted"
else
  echo "${ME}: OK: No Spotlight metadata folder \"$FOLDER\" exists"
fi

FILE="$1/.metadata_never_index"
if [ -f "$FILE" ] ; then
  echo "${ME}: OK: File \"$FILE\" already exists"
else
  touch "$FILE" && echo "${ME}: Empty file \"$FILE\" created"
fi

FSE="$1/.fseventsd/no_log"
FSEVENTSD="$1/.fseventsd"
if [ -f "$FSE" ] ; then
  echo "${ME}: OK: File \"$FSE\" already exists"
elif [ -d "$FSEVENTSD" ] ; then
  rm -rf "$FSEVENTSD" && echo "${ME}: File system event folder \"$FSEVENTSD\" deleted"
fi
if [ ! -f "$FSE" ] ; then
  mkdir -p "$FSEVENTSD" && touch "$FSE"
  echo "${ME}: Empty file \"$FSE\" created"
fi

TRASHES="$1/.Trashes" 
if [ -f "$TRASHES" ] ; then
  echo "${ME}: OK: File \"$TRASHES\" already exist"
elif [ -d "$TRASHES" ] ; then
  rm -rf "$TRASHES" && echo "${ME}: Trash folder \"$TRASHES\" deleted"
fi
if [ ! -f "$TRASHES" ] ; then
  touch "$TRASHES"
  echo "${ME}: Empty file \"$TRASHES\" created"
fi

# inspect and disable Desktop Services Store for USB volumes
STATE=$(defaults read com.apple.desktopservices DSDontWriteUSBStores)
if [ "$STATE" == "0" ] ; then
  echo "${ME}: com.apple.desktopservices DSDontWriteUSBStores was false"
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true && \
    echo "${ME}: com.apple.desktopservices DSDontWriteUSBStores set true"
elif [ "$STATE" == "1" ] ; then
  echo "${ME}: OK: com.apple.desktopservices DSDontWriteUSBStores is true"
else
  echo "${ME}: Unknown state \"$STATE\" from com.apple.desktopservices DSDontWriteUSBStores, no idea what to do"
fi
DS_STORE="$1/.DS_Store"
if [ -f "$DS_STORE" ] ; then
  rm "$DS_STORE" && echo "${ME}: File \"$DS_STORE\" deleted"
else
  echo "${ME}: OK: File \"$DS_STORE\" doesn't exist"
fi
DS_STORE2="$1/._.DS_Store"
if [ -f "$DS_STORE2" ] ; then
  rm "$DS_STORE2" && echo "${ME}: File \"$DS_STORE2\" deleted"
else
  echo "${ME}: OK: File \"$DS_STORE2\" doesn't exist"
fi
