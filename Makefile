CXX = g++
CC = gcc

# Added -I flags so g++ can find headers in src/ and dbus/
INCLUDES = -Isrc -Idbus

CXXFLAGS = -std=c++17 -Wall $(INCLUDES) $(shell pkg-config --cflags gio-2.0)
CFLAGS = -Wall $(INCLUDES) $(shell pkg-config --cflags gio-2.0)

LDLIBS = $(shell pkg-config --libs gio-2.0)

TARGET = internet-speed-daemon

# Object files placed inside src/ and dbus/
OBJECTS = src/main.o \
          src/NetworkMonitor.o \
          src/InterfaceDetector.o \
          src/NetworkManager.o \
          src/NetworkSpeedDBus.o \
          dbus/DBusService.o

# Installation paths used by Debian packager
PREFIX ?= /usr
BINDIR = $(DESTDIR)$(PREFIX)/bin
DBUSDIR = $(DESTDIR)$(PREFIX)/share/dbus-1/services
EXTDIR = $(DESTDIR)$(PREFIX)/share/gnome-shell/extensions/internet-speed@arindamsen95

all: $(TARGET)

# Link all objects together
$(TARGET): $(OBJECTS)
	$(CXX) $(OBJECTS) $(LDLIBS) -o $(TARGET)

# C++ compilation rule for files in src/
src/%.o: src/%.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

# C compilation rule for NetworkSpeedDBus.c in src/
src/NetworkSpeedDBus.o: src/NetworkSpeedDBus.c
	$(CC) $(CFLAGS) -c $< -o $@

# C++ compilation rule for files in dbus/
dbus/%.o: dbus/%.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Install rule required by Debian dpkg-buildpackage
install: $(TARGET)
	install -d $(BINDIR)
	install -m 755 $(TARGET) $(BINDIR)/
	install -d $(DBUSDIR)
	install -m 644 dbus/arindamsen95.NetworkSpeed.service $(DBUSDIR)/
	install -d $(EXTDIR)
	install -m 644 extension/extension.js $(EXTDIR)/
	install -m 644 extension/metadata.json $(EXTDIR)/

clean:
	rm -f src/*.o dbus/*.o $(TARGET)

.PHONY: all clean install
