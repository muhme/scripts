#!/usr/bin/env python3
#
# photos_from_gedcom.py - download photos from GEDCOM export (e.g. from myheritage.com)
#
# running with GEDCOM file export, e.g. photos_from_gedcom.py family_tree.ged
#
# needs python-gedcom packages installed, e.g. pip3 install python-gedcom
# see https://github.com/nickreynke/python-gedcom
#
# https://github.com/muhme/scripts
# hlu, December 5th 2023
# MIT license
#
# sample from following dataset will be stored in folder 'A5_historical_photos_of_the_Smiths' as file
# 'P8_Family_picture_ca_1950,_silver_wedding_anniversary_.jpg'
#
# ...
# 0 @A5@ ALBUM
# 1 TITL historical photos of the Smiths
# ...
# 1 OBJE
# 2 FORM jpg
# 2 FILE https://server.com/e/1/Aw/007/807/5383/000008_497071b45be4b429gvuwai_V.jpg
# 2 TITL Family picture ca 1950, silver wedding anniversary?
# 2 _ALBUM @A5@
# 2 _PHOTO_RIN MH:P8

import os
import sys
import re
import requests
from pathlib import Path
from gedcom.element.individual import IndividualElement
from gedcom.parser import Parser

if len(sys.argv) < 2:
    print("Please give GEDCOM file as argument", file=sys.stderr)
    sys.exit(1)

album_directory_mapping = {}
gedcom_parser = Parser()
# disable strict parsing for myheritage.com export
gedcom_parser.parse_file(sys.argv[1], False)
root_child_elements = gedcom_parser.get_root_child_elements()
for element0 in root_child_elements:
    # 1st check for 0 'ALBUM' to create subdirectories
    if element0.get_tag() == "ALBUM":
        current_title = None  # reset to iterate over children
        # use e.g. 'A105' from album id e.g. '@A105@'
        album_id = element0.get_pointer()
        current_album = album_id.replace('@', '')
        print(f"found album ID '{current_album}'", end=" ")
        for element1 in element0.get_child_elements():
            if element1.get_tag() == "TITL":
                current_title = element1.get_value()
        if current_title:
            print(f"as '{current_title}'")
            directory_name = current_album + '_' + \
                current_title.replace(' ', '_')
        else:
            print("(no title found)")
            directory_name = current_album
        if not os.path.exists(directory_name):
            os.makedirs(directory_name)
            print(f"created directory '{directory_name}'")
        album_directory_mapping[album_id] = directory_name
    else:
        for element1 in element0.get_child_elements():
            if element1.get_tag() == "OBJE":
                # reset to iterate over children
                current_title, current_url, current_photo_rin, current_album, current_form = None, None, None, None, None
                for element2 in element1.get_child_elements():
                    if element2.get_tag() == "TITL":
                        current_title = element2.get_value()
                    elif element2.get_tag() == "FILE":
                        current_url = element2.get_value()
                    elif element2.get_tag() == "_PHOTO_RIN":  # unique photo record identifier number
                        current_photo_rin = element2.get_value().replace("MH:","")
                    elif element2.get_tag() == "_ALBUM":  # unique album ID
                        current_album = element2.get_value()
                    elif element2.get_tag() == "FORM":
                        current_form = element2.get_value()
                if current_url:
                    if current_photo_rin:
                        filename = current_photo_rin
                    else:
                        # the photo RIN should always exist, anyway try to use filename instead
                        filename = current_url.split('/')[-1]
                        print(f"missing _PHOTO_RIN, using '{filename}'")
                    if current_title:
                        filename = filename + '_' + current_title.replace(' ', '_')
                    if current_form:
                        filename = filename + '.' + current_form
                    # sanitize filename
                    for c in '<>:"/\\|?* ':
                        filename = filename.replace(c, "_")
                    if current_album and current_album in album_directory_mapping:
                        filename = os.path.join(album_directory_mapping[current_album], filename)
                    # print(f"Found '{current_url}'")
                    # print(f"Filename {filename}")
                    if not os.path.exists(filename):
                        try:
                            response = requests.get(current_url)
                            response.raise_for_status()
                            with open(filename, 'wb') as photo_file:
                                photo_file.write(response.content)
                            print(f"downloaded: {filename}")
                        except Exception as e:
                            print(f"Failed to download {current_url}: {e}")
                    else:
                        print(f"file '{filename}' exists already")
