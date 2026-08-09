#!/bin/bash

set -e

# ============================================================
# Internet Speed Monitor
# Installation script
# ============================================================

echo "=========================================="
echo "    Internet Speed Monitor Installer"
echo "=========================================="
echo

# ------------------------------------------------------------
# Ensure script is NOT run directly with sudo
# ------------------------------------------------------------

if [ "$EUID" -eq 0 ]; then
    echo "ERROR: Do NOT run this script with 'sudo ./install.sh'."
    echo "Run it as a regular user: './install.sh'"
    echo "The script will ask for sudo password when required."
    exit 1
fi

# ------------------------------------------------------------
# Check operating system
# ------------------------------------------------------------

if [ ! -f /etc/os-release ]; then
    echo "ERROR: Cannot determine operating system."
    exit 1
fi

. /etc/os-release

if [ "$ID" != "ubuntu" ]; then
    echo "WARNING: This installer was designed for Ubuntu."
    echo "Detected OS: $PRETTY_NAME"
    echo

    read -p "Continue anyway? [y/N]: " answer

    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 1
    fi
fi

# ------------------------------------------------------------
# Check required build commands
# ------------------------------------------------------------

echo "Checking required build commands..."

MISSING_COMMANDS=()

for cmd in make gcc g++ pkg-config; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        MISSING_COMMANDS+=("$cmd")
    fi
done

if [ ${#MISSING_COMMANDS[@]} -ne 0 ]; then
    echo
    echo "ERROR: The following required commands are missing:"
    printf '  %s\n' "${MISSING_COMMANDS[@]}"
    echo
    echo "Install the required build tools with:"
    echo
    echo "    sudo apt update"
    echo "    sudo apt install build-essential pkg-config libglib2.0-dev"
    echo
    exit 1
fi

echo "Build tools: OK"

# ------------------------------------------------------------
# Check GLib/GIO development files
# ------------------------------------------------------------

if ! pkg-config --exists gio-2.0; then
    echo
    echo "ERROR: gio-2.0 development files were not found."
    echo
    echo "Install them with:"
    echo
    echo "    sudo apt install libglib2.0-dev"
    echo
    exit 1
fi

echo "GLib/GIO development files: OK"

# ------------------------------------------------------------
# Check gnome-extensions
# ------------------------------------------------------------

if ! command -v gnome-extensions >/dev/null 2>&1; then
    echo
    echo "ERROR: 'gnome-extensions' command was not found."
    echo
    echo "On Ubuntu, install it with:"
    echo
    echo "    sudo apt install gnome-shell-extension-prefs"
    echo
    exit 1
fi

GNOME_EXTENSIONS_VERSION=$(gnome-extensions --version 2>/dev/null || true)
echo "gnome-extensions: $GNOME_EXTENSIONS_VERSION"

# ------------------------------------------------------------
# Check GNOME Shell Version (Require >= 50)
# ------------------------------------------------------------

if ! command -v gnome-shell >/dev/null 2>&1; then
    echo
    echo "ERROR: 'gnome-shell' command was not found."
    echo
    exit 1
fi

GNOME_SHELL_VERSION=$(gnome-shell --version 2>/dev/null | awk '{print $3}')

if [ -z "$GNOME_SHELL_VERSION" ]; then
    echo
    echo "ERROR: Could not determine GNOME Shell version."
    exit 1
fi

GNOME_SHELL_MAJOR=$(echo "$GNOME_SHELL_VERSION" | cut -d. -f1)

echo "GNOME Shell version: $GNOME_SHELL_VERSION"

if [ "$GNOME_SHELL_MAJOR" -ne 50 ]; then
    echo
    echo "ERROR: This extension requires GNOME Shell 50."
    echo "Detected GNOME Shell version: $GNOME_SHELL_VERSION"
    exit 1
fi

echo "GNOME Shell compatibility: OK"

# ------------------------------------------------------------
# Check project files
# ------------------------------------------------------------

REQUIRED_FILES=(
    "Makefile"
    "extension/extension.js"
    "extension/metadata.json"
    "systemd/internet-speed.service"
    "dbus/arindamsen95.NetworkSpeed.service"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo
        echo "ERROR: Required file not found: $file"
        exit 1
    fi
done

echo "Project files: OK"

# ------------------------------------------------------------
# Build C++ application
# ------------------------------------------------------------

echo
echo "=========================================="
echo "Building Internet Speed Monitor"
echo "=========================================="
echo

make

echo
echo "Build completed successfully."

# ------------------------------------------------------------
# Install executable & D-Bus service (Requires sudo)
# ------------------------------------------------------------

echo
echo "Installing executable and D-Bus service (sudo required)..."

TARGET_BIN="internet-speed"

sudo install -Dm755 \
    "$TARGET_BIN" \
    "/usr/bin/$TARGET_BIN"

sudo install -Dm644 \
    dbus/arindamsen95.NetworkSpeed.service \
    /usr/share/dbus-1/services/arindamsen95.NetworkSpeed.service

echo "Executable installed: /usr/bin/$TARGET_BIN"
echo "D-Bus service installed: /usr/share/dbus-1/services/arindamsen95.NetworkSpeed.service"

# ------------------------------------------------------------
# Install systemd user service (No sudo)
# ------------------------------------------------------------

echo
echo "Installing systemd user service..."

USER_SYSTEMD_DIR="$HOME/.config/systemd/user"
mkdir -p "$USER_SYSTEMD_DIR"

install -Dm644 \
    systemd/internet-speed.service \
    "$USER_SYSTEMD_DIR/internet-speed.service"

echo "Systemd user service installed: $USER_SYSTEMD_DIR/internet-speed.service"

# ------------------------------------------------------------
# Reload and enable systemd service
# ------------------------------------------------------------

echo
echo "Configuring systemd user service..."

systemctl --user daemon-reload
systemctl --user enable internet-speed.service
systemctl --user restart internet-speed.service

echo "Internet Speed Monitor service started."

# ------------------------------------------------------------
# Install GNOME Shell extension (No sudo)
# ------------------------------------------------------------

echo
echo "Installing GNOME Shell extension..."

EXTENSION_UUID="internet-speed@arindamsen95"
EXTENSION_DIR="$HOME/.local/share/gnome-shell/extensions/$EXTENSION_UUID"

mkdir -p "$EXTENSION_DIR"

install -Dm644 \
    extension/extension.js \
    "$EXTENSION_DIR/extension.js"

install -Dm644 \
    extension/metadata.json \
    "$EXTENSION_DIR/metadata.json"

echo "Extension installed to: $EXTENSION_DIR"

# ------------------------------------------------------------
# Enable GNOME extension
# ------------------------------------------------------------

echo
echo "Attempting to enable GNOME extension..."

if gnome-extensions enable "$EXTENSION_UUID" 2>/dev/null; then
    echo "GNOME extension enabled."
else
    echo
    echo "NOTE: Extension installed, but GNOME Shell needs a restart."
    echo "Log out and log back in, then run:"
    echo "    gnome-extensions enable $EXTENSION_UUID"
fi

# ------------------------------------------------------------
# Final status
# ------------------------------------------------------------

echo
echo "=========================================="
echo "Installation completed successfully!"
echo "=========================================="
echo
echo "Check systemd service:"
echo "    systemctl --user status internet-speed.service"
echo
echo "Check GNOME extension:"
echo "    gnome-extensions info $EXTENSION_UUID"
echo
