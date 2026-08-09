CXX = g++
CC = gcc

CXXFLAGS = -std=c++17 -Wall $(shell pkg-config --cflags gio-2.0)
CFLAGS = -Wall $(shell pkg-config --cflags gio-2.0)
LDLIBS = $(shell pkg-config --libs gio-2.0)

TARGET = internet-speed

OBJECTS = \
    src/main.o \
    src/NetworkMonitor.o \
    src/InterfaceDetector.o \
    src/NetworkManager.o \
    src/DBusService.o \
    src/NetworkSpeedDBus.o


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


.PHONY: clean

clean:
	rm -f $(OBJECTS) $(TARGET)
