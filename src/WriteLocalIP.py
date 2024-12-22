# Convert to exe with: pyinstaller --onefile --icon=dev\ip-network.ico src\WriteLocalIP.py

import json
import socket
import sys
import os

def get_ip_address():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(("8.8.8.8", 80))
    return s.getsockname()[0]

# Set defaults but overwrite when parameter exists
path = "settings.ini"
if len(sys.argv) > 1:
    path = str(sys.argv[1])

key = "localip$"
if len(sys.argv) > 2:
    key = str(sys.argv[2])

# Quote the path and key to handle spaces
path = f"{path}"
key = f"{key}"

# Check if the file exists, and create it if it doesn't
if not os.path.isfile(path):
    with open(path, 'w') as new_file:
        new_file.write('{}')

# Read existing data from the file
with open(path, "r") as file:
    data = file.read()

# Load JSON data, or create a new dictionary if the file is empty
json_object = json.loads(data.rstrip('\x00')) if data else {}

# Update the dictionary with the new value
json_object[key] = get_ip_address()

# Write the updated data back to the file
with open(path, "w") as file:
    file.write(json.dumps(json_object, indent=4))

# Print out the key and path
print(f"Key: {key}")
print(f"Path: {path}")

# Print out the updated IP address
print(f"The IP address is: {json_object[key]}")
# input()
