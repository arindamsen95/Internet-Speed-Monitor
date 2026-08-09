# Internet Speed Monitor — Terminal Version

A lightweight **C++ terminal-based internet speed monitor** for Linux.

This branch contains the original terminal version of the project, before the D-Bus and GNOME Shell integration was introduced.

The program detects the available network interface(s), monitors network traffic, and displays the current download and upload speed directly in the terminal.

## Features

* Written in C++17
* Lightweight terminal-based application
* Automatically detects network interfaces
* Monitors download and upload traffic
* Displays speed continuously in the terminal
* Updates once every second
* No graphical interface required
* No D-Bus dependency
* No GNOME Shell extension required
* Simple `make` based build system

---

## Requirements

The project currently targets Linux systems and requires:

* Linux
* GCC/G++
* C++17
* GNU Make

The project uses standard Linux network statistics to measure network traffic.

### Ubuntu / Debian

Install the required build tools:

```bash
sudo apt update
sudo apt install build-essential
```

This provides:

* `gcc`
* `g++`
* `make`

---

# Getting the Source Code

Clone this branch directly from GitHub:

```bash
git clone -b Terminal_cpp https://github.com/arindamsen95/Internet-Speed-Monitor.git
```

Then enter the project directory:

```bash
cd Internet-Speed-Monitor
```

If the branch has a different name, you can check the available branches with:

```bash
git branch -a
```

The terminal-based version is maintained separately from the GNOME Shell version.

---

# Building

Once inside the project directory, simply run:

```bash
make
```

The Makefile compiles the C++ source files and creates the executable:

```text
internet-speed
```

After a successful build, you should see the executable in the project directory:

```bash
ls
```

Example:

```text
Makefile
internet-speed
src
```

---

# Running

Run the program with:

```bash
./internet-speed
```

The program starts monitoring network traffic and displays the current network speed in the terminal.

Example output:

```text
==============================
   Internet Speed Monitor
==============================

Interface: wlp0s20f3
   Download:   125.42 KB/s
     Upload:    18.70 KB/s
```

The values are updated continuously.

The actual interface name will depend on your system.

For example, your system may use:

```text
wlp0s20f3
```

for a Wi-Fi interface or something such as:

```text
enp3s0
```

for an Ethernet interface.

---

# How It Works

The program reads network traffic statistics provided by the Linux kernel.

For each network interface, it obtains the number of bytes received and transmitted.

The program periodically measures the difference between two readings:

```text
Received bytes:
current received bytes - previous received bytes

Transmitted bytes:
current transmitted bytes - previous transmitted bytes
```

The difference is then converted into a data rate.

Conceptually:

```text
Download speed =
    received bytes during interval
    ------------------------------
          elapsed time
```

and:

```text
Upload speed =
    transmitted bytes during interval
    --------------------------------
             elapsed time
```

The monitor updates these values once per second.

---

# Project Structure

The terminal version has a simple structure:

```text
.
├── Makefile
├── internet-speed
├── InterfaceDetector.cpp
├── InterfaceDetector.h
├── NetworkManager.cpp
├── NetworkManager.h
├── NetworkMonitor.cpp
├── NetworkMonitor.h
├── NetworkSpeed.h
└── main.cpp
```

## Components

### `main.cpp`

The entry point of the application.

It creates the network manager, performs the initial setup, and starts the periodic monitoring loop.

### `InterfaceDetector`

Responsible for detecting available network interfaces.

### `NetworkMonitor`

Responsible for reading network traffic statistics from the Linux system.

### `NetworkManager`

Coordinates interface detection and network monitoring.

It manages the network interfaces and calculates the current download and upload speeds.

### `NetworkSpeed.h`

Defines the structure used to store the measured speeds:

```cpp
struct NetworkSpeed
{
    double downloadSpeed;
    double uploadSpeed;
};
```

### `Makefile`

Contains the build rules for compiling the project.

---

# Cleaning the Build

To remove compiled object files and the executable:

```bash
make clean
```

You can then rebuild the project with:

```bash
make
```

---

# Quick Start

If you just want to try the program, the complete process is:

```bash
git clone -b Terminal_cpp https://github.com/arindamsen95/Internet-Speed-Monitor.git
cd Internet-Speed-Monitor
make
./internet-speed
```

That's all that is required.

---

# Stopping the Monitor

The program runs continuously until it is stopped.

Press:

```text
Ctrl+C
```

to terminate it.

---

# Terminal Version vs GNOME Version

This branch represents the **original terminal-based implementation**.

The project was later extended with a D-Bus backend and GNOME Shell integration.

The development history can therefore be viewed conceptually as:

```text
Terminal Monitor
       │
       │
       ▼
C++ Network Monitoring
       │
       │
       ▼
D-Bus Backend
       │
       │
       ▼
GNOME Shell Extension
```

The terminal version itself does **not** require:

* D-Bus
* GNOME Shell
* GNOME Shell extensions
* systemd services

It is simply built with:

```bash
make
```

and executed with:

```bash
./internet-speed
```

---

# Development

To build the project after making source-code changes:

```bash
make
```

If you want to perform a completely clean rebuild:

```bash
make clean
make
```

Then run:

```bash
./internet-speed
```

---

# Author

**Arindam Sen**

GitHub:

https://github.com/arindamsen95

Repository:

https://github.com/arindamsen95/Internet-Speed-Monitor
