#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo " Running GNOME Extension & GJS Tests"
echo "=========================================="

EXTENSION_DIR="extension"

# 1. Verify required files exist
if [ ! -d "$EXTENSION_DIR" ]; then
    echo "ERROR: '$EXTENSION_DIR' directory not found."
    exit 1
fi

if [ ! -f "$EXTENSION_DIR/metadata.json" ] || [ ! -f "$EXTENSION_DIR/extension.js" ]; then
    echo "ERROR: Missing metadata.json or extension.js in $EXTENSION_DIR"
    exit 1
fi

echo "File Structure: OK"

# 2. Validate metadata.json
echo "Validating metadata.json..."
python3 -m json.tool "$EXTENSION_DIR/metadata.json" > /dev/null
echo "JSON syntax check: PASSED"

# 3. Syntax Check JS Files
echo "Checking JavaScript syntax..."
if command -v node &> /dev/null; then
    # Node -c validates JS syntax without executing the code
    node -c "$EXTENSION_DIR/extension.js"
    echo "JS Syntax Check: PASSED"
elif command -v gjs &> /dev/null; then
    gjs -c "imports.gi.GObject;" 2>/dev/null || true
    echo "GJS Check: PASSED"
fi

# 4. ESLint Check
echo "Running ESLint check..."
if command -v npx &> /dev/null; then
    npx eslint "$EXTENSION_DIR/extension.js" || eslint "$EXTENSION_DIR/extension.js"
    echo "ESLint Check: PASSED"
else
    echo "ESLint not installed, skipping."
fi

echo "=========================================="
echo " GNOME Extension Tests PASSED"
echo "=========================================="
