# yml2json.py - converts YAML file format from stdin to JSON on stdout
#
# e.g. python3.10 yml2json.py < uk.yml > uk.json
#
# https://github.com/muhme/scripts
# hlu, April 15th 2023
# MIT license

import yaml
import json
import sys

# Load YAML data from standard input
data = yaml.safe_load(sys.stdin)

# Encode the data structure in JSON format
json_data = json.dumps(data)

# Write JSON data to standard output
sys.stdout.write(json_data)

