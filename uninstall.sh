#!/bin/bash

set -e

echo "======================================"
echo " Internet Speed Monitor Uninstaller"
echo "======================================"
echo

# ------------------------------------------------------------
# Stop and disable systemd service
# ------------------------------------------------------------

echo "Stopping systemd service..."

systemctl --user disable --now internet-speed.service 2>/dev/null || true

# ------------------------------------------------------------
# Remove systemd service
# ------------------------------------------------------------

echo "Removing systemd service..."

rm -f \
    "$HOME/.config/systemd/user/internet-speed.service"

systemctl --user daemon-reload

# ------------------------------------------------------------
# Disable and remove GNOME extension
# ------------------------------------------------------------

if command -v gnome-extensions >/dev/null 2>&1; then
    echo "Disabling GNOME extension..."

    gnome-extensions disable internet-speed@arindamsen95 \
        2>/dev/null || true
fi

echo "Removing GNOME extension..."

rm -rf \
    "$HOME/.local/share/gnome-shell/extensions/internet-speed@arindamsen95"

# ------------------------------------------------------------
# Remove D-Bus service
# ------------------------------------------------------------

echo "Removing D-Bus service..."

sudo rm -f \
    /usr/share/dbus-1/services/arindamsen95.NetworkSpeed.service

# ------------------------------------------------------------
# Remove executable
# ------------------------------------------------------------

echo "Removing executable..."

sudo rm -f \
    /usr/bin/internet-speed

# ------------------------------------------------------------
# Finished
# ------------------------------------------------------------

echo
echo "======================================"
echo "Uninstallation completed."
echo "======================================"
