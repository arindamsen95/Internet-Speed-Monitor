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
if command -v gnome-extensions &> /dev/null; then
    gnome-extensions pack --extra-source=extension.js --force "$EXTENSION_DIR" --out-dir=/tmp
    echo "metadata.json validation: PASSED"
else
    # Fallback JSON syntax check if gnome-extensions tool is missing
    python3 -m json.tool "$EXTENSION_DIR/metadata.json" > /dev/null
    echo "JSON syntax check: PASSED"
fi

# 3. Syntax check JS using GJS (GNOME JavaScript Engine)
echo "Checking GJS syntax..."
if command -v gjs &> /dev/null; then
    gjs -c "imports.gi.GObject; imports.stuff" 2>/dev/null || true
    # Compile-check extension.js using gjs
    gjs --check-syntax "$EXTENSION_DIR/extension.js"
    echo "GJS Syntax Check: PASSED"
else
    echo "WARNING: gjs not installed, skipping syntax execution check."
fi

# 4. ESLint Check for GNOME JS Rules
echo "Running ESLint check..."
if command -v npx &> /dev/null; then
    npx eslint "$EXTENSION_DIR/extension.js"
    echo "ESLint Check: PASSED"
else
    echo "WARNING: npx/eslint not installed, skipping linting."
fi

echo "=========================================="
echo " GNOME Extension Tests PASSED"
echo "=========================================="
