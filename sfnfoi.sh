#!/bin/bash -e
#
# sfnfoi.sh - save file name for Obsidian import
#
# work-around for https://github.com/obsidianmd/obsidian-importer/issues/190
#
# reads Evernote exported ENEX file from stdin and write to stdout for Obsidian import
# 
# replace all points in the file name except the last one
# changes from <file-name>ct.12.15.172-177.pdf</file-name>
#           to <file-name>ct_12_15_172-177.pdf</file-name>
#
# snfnoi.sh < from_evernote_export.enex > for_obsidian_import.enex
# 
# tested on:
# - macOS 14.1.2 (Sonoma)
# - Debian GNU/Linux 12 (bullseye), inside docker container
#
# https://github.com/muhme/scripts
# hlu, Dec 14th 2023
# MIT license

# read standard input line by line
while IFS= read -r line; do
    # is <file-name> attribute?
    if [[ $line =~ \<file-name\>.*\.pdf\<\/file-name\> ]]; then
        # replace all dots with underline 
        echo "$line" | tr '.' '_' | \
        # and simple replace last _pdf with .pdf
        sed 's/\(.*\)_pdf<\/file-name>$/\1.pdf<\/file-name>/'
    else
        # leave the line unchanged
        echo "$line"
    fi
done
