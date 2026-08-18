CXX = g++
CC = gcc

CXXFLAGS = -std=c++17 -Wall $(shell pkg-config --cflags gio-2.0)
CFLAGS = -Wall $(shell pkg-config --cflags gio-2.0)
LDLIBS = $(shell pkg-config --libs gio-2.0)

TARGET = internet-speed


PREFIX = /usr
BINDIR = $(PREFIX)/bin
DBUS_SERVICES_DIR = $(PREFIX)/share/dbus-1/services

EXTENSION_UUID = internet-speed@arindamsen95
EXTENSION_DIR = $(HOME)/.local/share/gnome-shell/extensions/$(EXTENSION_UUID)



OBJECTS = \
    src/main.o \
    src/NetworkMonitor.o \
    src/InterfaceDetector.o \
    src/NetworkManager.o \
    src/DBusService.o \
    src/NetworkSpeedDBus.o
    
# ============================================================
# Generate D-Bus source files
# ============================================================

src/NetworkSpeedDBus.c src/NetworkSpeedDBus.h: src/NetworkSpeed.xml
	gdbus-codegen \
		--generate-c-code=src/NetworkSpeedDBus \
		--c-namespace=Arindamsen95 \
		src/NetworkSpeed.xml
		
# ============================================================
# Build
# ============================================================

$(TARGET): $(OBJECTS)
	$(CXX) $(OBJECTS) $(LDLIBS) -o $(TARGET)


src/main.o: src/main.cpp \
            src/NetworkManager.h \
            src/DBusService.h
	$(CXX) $(CXXFLAGS) -c $< -o $@


src/NetworkMonitor.o: src/NetworkMonitor.cpp \
                      src/NetworkMonitor.h \
                      src/NetworkSpeed.h
	$(CXX) $(CXXFLAGS) -c $< -o $@


src/InterfaceDetector.o: src/InterfaceDetector.cpp \
                         src/InterfaceDetector.h
	$(CXX) $(CXXFLAGS) -c $< -o $@


src/NetworkManager.o: src/NetworkManager.cpp \
                      src/NetworkManager.h \
                      src/NetworkMonitor.h \
                      src/InterfaceDetector.h \
                      src/NetworkSpeed.h
	$(CXX) $(CXXFLAGS) -c $< -o $@


src/DBusService.o: src/DBusService.cpp \
                   src/DBusService.h \
                   src/NetworkManager.h \
                   src/NetworkSpeedDBus.h
	$(CXX) $(CXXFLAGS) -c $< -o $@


src/NetworkSpeedDBus.o: src/NetworkSpeedDBus.c \
                        src/NetworkSpeedDBus.h
	$(CC) $(CFLAGS) -c $< -o $@


# ============================================================
# Clean
# ============================================================

.PHONY: clean

clean:
	rm -f $(OBJECTS) $(TARGET)
	
# ============================================================
# Install system components
# ============================================================
	
.PHONY: clean install uninstall

install: $(TARGET)
	install -Dm755 $(TARGET) $(DESTDIR)$(BINDIR)/$(TARGET)
	install -Dm644 dbus/arindamsen95.NetworkSpeed.service \
		$(DESTDIR)$(DBUS_SERVICES_DIR)/arindamsen95.NetworkSpeed.service

	mkdir -p $(EXTENSION_DIR)
	install -Dm644 extension/extension.js \
		$(EXTENSION_DIR)/extension.js
	install -Dm644 extension/metadata.json \
		$(EXTENSION_DIR)/metadata.json

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/$(TARGET)
	rm -f $(DESTDIR)$(DBUS_SERVICES_DIR)/arindamsen95.NetworkSpeed.service
	rm -rf $(EXTENSION_DIR)
