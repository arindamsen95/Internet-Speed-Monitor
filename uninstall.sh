#!/bin/bash

set -e

echo "======================================"
echo " Internet Speed Monitor Uninstaller"
echo "======================================"
echo

# ------------------------------------------------------------
# Ensure script is NOT run directly with sudo
# ------------------------------------------------------------

if [ "$EUID" -eq 0 ]; then
    echo "ERROR: Do NOT run this script with 'sudo ./uninstall.sh'."
    echo "Run it as a regular user: './uninstall.sh'"
    echo "The script will ask for sudo password when required."
    exit 1
fi

# ------------------------------------------------------------
# Stop and disable systemd service
# ------------------------------------------------------------

echo "Stopping systemd user service..."

systemctl --user disable --now internet-speed.service 2>/dev/null || true

# Kill binary if triggered independently by D-Bus
killall internet-speed 2>/dev/null || true

# ------------------------------------------------------------
# Remove systemd user service file
# ------------------------------------------------------------

echo "Removing systemd user service..."

rm -f "$HOME/.config/systemd/user/internet-speed.service"

systemctl --user daemon-reload

# ------------------------------------------------------------
# Disable and remove GNOME extension
# ------------------------------------------------------------

EXTENSION_UUID="internet-speed@arindamsen95"

if command -v gnome-extensions >/dev/null 2>&1; then
    echo "Disabling GNOME extension..."
    gnome-extensions disable "$EXTENSION_UUID" 2>/dev/null || true
fi

echo "Removing GNOME extension..."

rm -rf "$HOME/.local/share/gnome-shell/extensions/$EXTENSION_UUID"

# ------------------------------------------------------------
# Remove D-Bus service (Requires sudo)
# ------------------------------------------------------------

echo "Removing D-Bus service (sudo required)..."

sudo rm -f /usr/share/dbus-1/services/arindamsen95.NetworkSpeed.service

# Reload D-Bus daemon configuration
sudo systemctl reload dbus 2>/dev/null || true

# ------------------------------------------------------------
# Remove executable (Requires sudo)
# ------------------------------------------------------------

echo "Removing executable..."

sudo rm -f /usr/bin/internet-speed

# ------------------------------------------------------------
# Finished
# ------------------------------------------------------------

echo
echo "======================================"
echo "Uninstallation completed successfully!"
echo "======================================"
echo
