#!/bin/bash -e

# Create a new SSH key
if [ $# -ne 1 ]; then
  echo "Usage: $0 <key_name>"
  exit 1
fi

KEY_NAME=$1
OUTPUT_DIR=$(pwd)

ssh-keygen -t rsa -b 4096 -C "$KEY_NAME" -f "$OUTPUT_DIR/$KEY_NAME" -q -N ""

echo "Created key $KEY_NAME in $OUTPUT_DIR"
exit 0



