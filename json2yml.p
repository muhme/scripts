# json2yml.py - converts JSON file format from stdin to YAML on stdout
#
# e.g. python3.10 json2yml.py < es.json > es.yml
#
# https://github.com/muhme/scripts
# hlu, April 15th 2023
# MIT license

import yaml
import json
import sys

# Load JSON data from standard input
json_data = sys.stdin.read()
data = json.loads(json_data)

# Convert the data structure to YAML format
yaml_data = yaml.dump(data)

# Write YAML data to standard output
sys.stdout.write(yaml_data)

