# Internet Speed Monitor

A lightweight internet speed monitor for **Ubuntu GNOME** that displays real-time download and upload speeds directly in the **GNOME top panel**.

The project consists of a C++ backend that monitors network traffic and exposes the measured speeds through **D-Bus**, together with a GNOME Shell extension that displays the values in the top panel.

## Features

* Real-time download speed monitoring
* Real-time upload speed monitoring
* Supports multiple network interfaces
* Automatically detects network interfaces
* C++ backend for network monitoring
* D-Bus interface for communication between the backend and GNOME Shell
* GNOME Shell 50 extension
* Automatic background execution using systemd
* Displays speeds using:

  * `B/s`
  * `KB/s`
  * `MB/s`
* Lightweight and does not require a graphical application window

Example:

```text
↓ 125.42 KB/s   ↑ 18.7 KB/s
```

or:

```text
↓ 12.34 MB/s   ↑ 1.25 MB/s
```

---

# Architecture

The project is divided into three main components:

```text
                   ┌──────────────────────────┐
                   │     GNOME Shell          │
                   │       Extension         │
                   │                          │
                   │  ↓ 12.34 MB/s           │
                   │  ↑  1.25 MB/s            │
                   └────────────┬─────────────┘
                                │
                                │ D-Bus
                                │
                   ┌────────────▼─────────────┐
                   │     C++ Backend          │
                   │                          │
                   │   NetworkManager         │
                   │   NetworkMonitor         │
                   │   InterfaceDetector      │
                   │   DBusService            │
                   └────────────┬─────────────┘
                                │
                                ▼
                         Linux network
                         interfaces
```

## C++ Backend

The C++ application:

```text
internet-speed
```

is responsible for:

1. Detecting available network interfaces.
2. Reading network traffic statistics.
3. Calculating download and upload rates.
4. Updating the values periodically.
5. Providing the values through D-Bus.

The backend does not directly interact with GNOME Shell.

---

# D-Bus Interface

The backend exposes the following D-Bus service:

```text
Bus name:
arindamsen95.NetworkSpeed
```

Object path:

```text
/arindamsen95/NetworkSpeed
```

Interface:

```text
arindamsen95.NetworkSpeed
```

The interface provides two methods:

```text
GetDownload() → double
GetUpload()   → double
```

The returned value is in:

```text
MB/s
```

For example:

```text
GetDownload()
    → 0.014925956726074219

GetUpload()
    → 0.0029611587524414062
```

The GNOME Shell extension receives these values and performs the final display formatting.

---

# Project Structure

```text
.
├── extension/
│   ├── extension.js
│   └── metadata.json
│
├── src/
│   ├── DBusService.cpp
│   ├── DBusService.h
│   ├── InterfaceDetector.cpp
│   ├── InterfaceDetector.h
│   ├── NetworkManager.cpp
│   ├── NetworkManager.h
│   ├── NetworkMonitor.cpp
│   ├── NetworkMonitor.h
│   ├── NetworkSpeed.h
│   ├── NetworkSpeed.xml
│   ├── NetworkSpeedDBus.c
│   └── NetworkSpeedDBus.h
│
├── dbus/
│   └── arindamsen95.NetworkSpeed.service
│
├── systemd/
│   └── internet-speed.service
│
├── Makefile
├── .gitignore
└── README.md
```

---

# Requirements

The project is currently designed for:

* Ubuntu Linux
* GNOME Shell 50
* Wayland
* C++17
* GCC/G++
* GLib
* GIO
* D-Bus
* systemd

The GNOME extension uses the modern GNOME Shell extension API:

```javascript
import { Extension } from
    'resource:///org/gnome/shell/extensions/extension.js';
```

---

# Installing Dependencies

Install the required development packages:

```bash
sudo apt update
sudo apt install \
    build-essential \
    pkg-config \
    libglib2.0-dev \
    libgio-2.0-dev
```

The GNOME Shell extension requires GNOME Shell 50 or a compatible version.

Check your GNOME Shell version with:

```bash
gnome-shell --version
```

---

# Building

Clone the repository:

```bash
git clone https://github.com/arindamsen95/Internet-Speed-Monitor.git
cd Internet-Speed-Monitor
```

Switch to the GNOME Shell 50 branch if necessary:

```bash
git checkout GNOME_Shell.V50
```

Build the C++ backend:

```bash
make
```

The executable will be created as:

```text
./internet-speed
```

To remove build files:

```bash
make clean
```

---

# Testing the Backend

The backend can first be tested manually:

```bash
./internet-speed
```

The application starts the D-Bus service and enters its GLib main loop.

You should see:

```text
Connected to D-Bus
D-Bus object registered
```

The backend normally runs without printing network-speed values continuously. The values are intended to be consumed through D-Bus by the GNOME extension.

Stop the backend with:

```text
Ctrl+C
```

---

# Testing the D-Bus Interface

With the backend running, inspect the exported object:

```bash
gdbus introspect \
    --session \
    --dest arindamsen95.NetworkSpeed \
    --object-path /arindamsen95/NetworkSpeed
```

You should see:

```text
interface arindamsen95.NetworkSpeed {
    methods:
        GetDownload(out d speed);
        GetUpload(out d speed);
}
```

Test download speed:

```bash
gdbus call \
    --session \
    --dest arindamsen95.NetworkSpeed \
    --object-path /arindamsen95/NetworkSpeed \
    --method arindamsen95.NetworkSpeed.GetDownload
```

Example:

```text
(0.014925956726074219,)
```

Test upload speed:

```bash
gdbus call \
    --session \
    --dest arindamsen95.NetworkSpeed \
    --object-path /arindamsen95/NetworkSpeed \
    --method arindamsen95.NetworkSpeed.GetUpload
```

The values returned by D-Bus are in **MB/s**.

---

# D-Bus Service

The repository contains:

```text
dbus/arindamsen95.NetworkSpeed.service
```

Its contents are:

```ini
[D-BUS Service]
Name=arindamsen95.NetworkSpeed
Exec=/usr/bin/internet-speed
```

This associates the D-Bus name:

```text
arindamsen95.NetworkSpeed
```

with:

```text
/usr/bin/internet-speed
```

The purpose of this file is D-Bus service activation.

---

# systemd User Service

The project also contains:

```text
systemd/internet-speed.service
```

This allows the backend to run automatically as a user service instead of requiring the user to manually execute:

```bash
./internet-speed
```

The service is installed for the current user under:

```text
~/.config/systemd/user/
```

After installation, it can be controlled using:

```bash
systemctl --user start internet-speed.service
```

Check its status:

```bash
systemctl --user status internet-speed.service
```

Enable it at login:

```bash
systemctl --user enable internet-speed.service
```

Start it immediately:

```bash
systemctl --user start internet-speed.service
```

Or enable and start it together:

```bash
systemctl --user enable --now internet-speed.service
```

Stop it with:

```bash
systemctl --user stop internet-speed.service
```

Disable automatic startup:

```bash
systemctl --user disable internet-speed.service
```

View logs:

```bash
journalctl --user -u internet-speed.service
```

---

# GNOME Shell Extension

The GNOME Shell extension is located in:

```text
extension/
```

It contains:

```text
extension/
├── extension.js
└── metadata.json
```

The extension connects to the C++ backend through D-Bus.

It creates a proxy for:

```text
arindamsen95.NetworkSpeed
```

and periodically calls:

```text
GetDownload
GetUpload
```

The extension then formats the values for display.

For example:

```text
↓ 512 B/s   ↑ 128 B/s
```

```text
↓ 125.4 KB/s   ↑ 18.7 KB/s
```

```text
↓ 12.34 MB/s   ↑ 1.25 MB/s
```

The formatting is intentionally performed in JavaScript rather than in the C++ backend because the backend provides raw numerical measurements while the presentation layer is responsible for displaying them.

---

# Installing the GNOME Extension Manually

Create the GNOME Shell extension directory:

```bash
mkdir -p \
    ~/.local/share/gnome-shell/extensions/internet-speed@arindamsen95
```

Copy the extension files:

```bash
cp extension/extension.js \
   ~/.local/share/gnome-shell/extensions/internet-speed@arindamsen95/

cp extension/metadata.json \
   ~/.local/share/gnome-shell/extensions/internet-speed@arindamsen95/
```

Verify:

```bash
ls \
    ~/.local/share/gnome-shell/extensions/internet-speed@arindamsen95
```

You should see:

```text
extension.js
metadata.json
```

Check whether GNOME recognizes the extension:

```bash
gnome-extensions list
```

Enable it:

```bash
gnome-extensions enable internet-speed@arindamsen95
```

Check its status:

```bash
gnome-extensions info internet-speed@arindamsen95
```

You should see:

```text
Enabled: Yes
State: ACTIVE
```

---

# Troubleshooting

## Extension does not appear

Check that the directory name exactly matches the UUID:

```text
~/.local/share/gnome-shell/extensions/internet-speed@arindamsen95
```

Check:

```bash
cat ~/.local/share/gnome-shell/extensions/internet-speed@arindamsen95/metadata.json
```

The UUID must be:

```json
"uuid": "internet-speed@arindamsen95"
```

The GNOME Shell version must also match the installed version.

---

## Extension shows `Error`

Check whether the C++ backend is running:

```bash
pgrep -a internet-speed
```

Check whether the D-Bus service exists:

```bash
gdbus introspect \
    --session \
    --dest arindamsen95.NetworkSpeed \
    --object-path /arindamsen95/NetworkSpeed
```

If the backend is running but D-Bus is unavailable, check:

```bash
journalctl --user -u internet-speed.service
```

You can also check GNOME Shell messages:

```bash
journalctl --user -b | grep "Internet Speed"
```

---

## Check D-Bus name

Run:

```bash
gdbus call \
    --session \
    --dest org.freedesktop.DBus \
    --object-path /org/freedesktop/DBus \
    --method org.freedesktop.DBus.NameHasOwner \
    arindamsen95.NetworkSpeed
```

A successful running backend should return:

```text
(true,)
```

---

## Backend is not running

Check:

```bash
systemctl --user status internet-speed.service
```

Start it manually:

```bash
systemctl --user start internet-speed.service
```

If necessary, inspect the logs:

```bash
journalctl --user -u internet-speed.service -f
```

---

# Development

During development, the C++ backend can be run manually:

```bash
./internet-speed
```

The GNOME extension can then be enabled separately.

For extension debugging, GNOME Shell messages can be monitored with:

```bash
journalctl --user -f | grep "Internet Speed"
```

After modifying `extension.js`, disable and re-enable the extension:

```bash
gnome-extensions disable internet-speed@arindamsen95
gnome-extensions enable internet-speed@arindamsen95
```

If the extension becomes stuck after development changes, logging out and logging back in can reload the GNOME Shell extension environment.

---

# Network Speed Calculation

The backend reads network interface traffic statistics from Linux.

For each update interval, the change in transmitted and received bytes is measured:

```text
Download bytes = current received bytes
               - previous received bytes

Upload bytes   = current transmitted bytes
               - previous transmitted bytes
```

The byte difference is converted to a rate based on the elapsed time.

The C++ backend exposes the resulting value as:

```text
double
```

in:

```text
MB/s
```

The GNOME extension subsequently converts the value into:

```text
B/s
KB/s
MB/s
```

depending on the magnitude.

---

# Why C++ + D-Bus + GNOME Shell?

The project deliberately separates the monitoring backend from the graphical interface.

### C++ backend

Responsible for:

* Network interface detection
* Traffic measurement
* Speed calculation
* D-Bus service

### D-Bus

Provides a clean communication interface between the backend and desktop environment.

### GNOME Shell extension

Responsible for:

* Top-panel UI
* Periodic requests
* Speed formatting
* Displaying download/upload values

This separation makes it possible to change the graphical interface without modifying the network-monitoring code.

---

# Future Improvements

Possible future improvements include:

* Network interface selection
* Automatic handling of network interface changes
* Configurable update interval
* Configurable display units
* Download/upload color customization
* Preferences window
* Support for additional desktop environments
* Packaging as a `.deb`
* GNOME Extensions distribution
* Improved installation and uninstall scripts
* Better handling of D-Bus service startup and shutdown

---

# License

Add your chosen license here.

For example, if you choose MIT:

```text
MIT License
```

A license file should be added to the repository as:

```text
LICENSE
```

---

# Author

**Arindam Sen**

GitHub:

https://github.com/arindamsen95

Repository:

https://github.com/arindamsen95/Internet-Speed-Monitor

Branch:

```text
GNOME_Shell.V50
```

---

# Status

This project is currently under development.

The current version successfully provides:

* C++ network monitoring
* D-Bus communication
* GNOME Shell 50 integration
* Download speed display
* Upload speed display
* B/s, KB/s and MB/s formatting
* Background execution through systemd

