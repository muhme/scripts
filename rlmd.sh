#!/bin/bash -e
#
# rlmd.sh - read last modified date
#
# sample: find . name \*.md | rlmd.sh
# 201303240636.32 ./Evernote/Semantic Web/Live Microdata.md
# 201303172036.36 ./Evernote/Semantic Web/Best Practice Recipes for Publishing RDF Vocabularies.md
# 201303040627.21 ./Evernote/Semantic Web/Logic Calculator.md
# ...
#
# usage: find . name \*.md | rlmd.sh > modfied.txt # save last modified date and time
#        slmd.sh < modified.txt                    # restore last modified date and time
# 
# tested on:
# - macOS 14.1.2 (Sonoma)
#
# https://github.com/muhme/scripts
# hlu, Dec 15th 2023
# MIT license

# read standard input line by line
while IFS= read -r file; do
    original_date=$(stat -f "%Sm" -t "%Y%m%d%H%M.%S" "$file")
    echo "${original_date} ${file}"
done
