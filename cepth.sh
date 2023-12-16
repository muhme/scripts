#!/bin/bash -e
#
# cepth.sh - convert embedded PDF to hyperlinks
#
# Obsidian imported markdown files from Evernote ENEX export can not distinguish
# between embedded and hyperlinked PDFs. Simple change all PDFs to hyperlinks.
# After modification restore files original last updated date and time.
# Script runs from current directory. Without options it shows only what would
# be changed. With option -doit the markdown files are modified.
#
# replaces e.g.
# < ![](_ressources/Website%20Performance_ressources/ct_21_01_144-149.pdf)
# ---
# > [ct_21_01_144-149.pdf](_ressources/Website%20Performance_ressources/ct_21_01_144-149.pdf))
#
# $ cepth.sh       # recursively dry run, nothing is changed
# $ cepth.sh -doit # recursively modify *.md files and restore changed files last update date/time
# 
# tested on:
# - macOS 14.1.2 (Sonoma)
#
# This script modifies your notes! First create a backup of your Obsidian vault,
# then perform a dry run before you modify your notes.
#
# https://github.com/muhme/scripts
# hlu, Dec 15th 2023
# MIT license

ME=$(basename "$0")
TMP_FILE="/tmp/${ME}.file.$$"
DIFF_OUTPUT="/tmp/${ME}.diff.$$"

trap 'rm -rf "${TMP_FILE}" "${DIFF_OUTPUT}"' 0

# check no argument or -doit
if [[ $# -gt 1 ]] ; then
  echo "${ME}: Error: Too many arguments" 1>&2
  exit 1
fi
doit="false"
if [[ $# -eq 1 ]] ; then
    if [[ "$1" != "-doit" ]]; then
        echo "${ME}: Error: Invalid option. The only valid option is '-doit'."
        exit 1
    else
        doit="true"
    fi
fi

# run recursively over all *.md files
find . -name \*.md | while read file; do
    sed 's/!\[\](\(.*\)\/\(.*\.pdf\))/[\2](\1\/\2)/' "$file" > "$TMP_FILE"
    if ! diff "$file" "$TMP_FILE" > "$DIFF_OUTPUT"; then
        if [[ $doit == "true" ]]; then
            echo "Changing file \"$file\""
        else
            echo "File \"$file\" would be changed"
        fi
        cat "$DIFF_OUTPUT"
        if [[ $doit == "true" ]]; then
            original_date=$(stat -f "%Sm" -t "%Y%m%d%H%M.%S" "$file")
            cp "$TMP_FILE" "$file"
            touch -t "$(date -j -f "%Y%m%d%H%M.%S" "$original_date" +"%Y%m%d%H%M.%S")" "$file"
        fi
    fi
done
