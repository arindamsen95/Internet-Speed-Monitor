#!/usr/bin/env bash

set -euo pipefail

VERSION="${1:-1.0.0}"
PROJECT_NAME="internet-speed-monitor"
RELEASE_DIR="${PROJECT_NAME}-${VERSION}"
ARCHIVE_NAME="${RELEASE_DIR}.tar.gz"

echo "=========================================="
echo " Creating release package"
echo "=========================================="
echo

echo "Project : $PROJECT_NAME"
echo "Version : $VERSION"
echo

# ------------------------------------------------------------
# Clean previous release files
# ------------------------------------------------------------

rm -rf "$RELEASE_DIR"
rm -f "$ARCHIVE_NAME"

# ------------------------------------------------------------
# Create release directory
# ------------------------------------------------------------

mkdir -p "$RELEASE_DIR"

# ------------------------------------------------------------
# Copy files required by users
# ------------------------------------------------------------

cp -r src "$RELEASE_DIR/"
cp -r extension "$RELEASE_DIR/"
cp -r dbus "$RELEASE_DIR/"
cp -r systemd "$RELEASE_DIR/"

cp Makefile "$RELEASE_DIR/"
cp install.sh "$RELEASE_DIR/"
cp README.md "$RELEASE_DIR/"

# ------------------------------------------------------------
# Remove build artifacts if they happen to exist
# ------------------------------------------------------------

find "$RELEASE_DIR" -name "*.o" -delete
find "$RELEASE_DIR" -name "internet-speed" -delete

# ------------------------------------------------------------
# Create archive
# ------------------------------------------------------------

tar -czf "$ARCHIVE_NAME" "$RELEASE_DIR"

# ------------------------------------------------------------
# Show result
# ------------------------------------------------------------

echo
echo "Release package created:"
echo

ls -lh "$ARCHIVE_NAME"

echo
echo "Contents:"
echo

tar -tzf "$ARCHIVE_NAME"

echo
echo "=========================================="
echo " Release package created successfully"
echo "=========================================="
