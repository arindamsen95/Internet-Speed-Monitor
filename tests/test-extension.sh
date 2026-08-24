#!/usr/bin/env bash
set -euo pipefail

echo "Checking GNOME Extension files..."

# Ensure metadata.json and extension.js exist
test -f "extension/metadata.json" || { echo "Missing metadata.json"; exit 1; }
test -f "extension/extension.js" || { echo "Missing extension.js"; exit 1; }

# Validate JSON syntax
python3 -m json.tool extension/metadata.json > /dev/null

echo "Extension files: OK!"
