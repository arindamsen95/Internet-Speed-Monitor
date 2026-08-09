CXX = g++
CC = gcc

CXXFLAGS = -std=c++17 -Wall $(shell pkg-config --cflags gio-2.0)
CFLAGS = -Wall $(shell pkg-config --cflags gio-2.0)

LDLIBS = $(shell pkg-config --libs gio-2.0)

TARGET = internet-speed

OBJECTS = main.o \
          NetworkMonitor.o \
          InterfaceDetector.o \
          NetworkManager.o \
          DBusService.o \
          NetworkSpeedDBus.o


$(TARGET): $(OBJECTS)
	$(CXX) $(OBJECTS) $(LDLIBS) -o $(TARGET)


main.o: main.cpp NetworkManager.h DBusService.h
	$(CXX) $(CXXFLAGS) -c main.cpp


NetworkMonitor.o: NetworkMonitor.cpp NetworkMonitor.h NetworkSpeed.h
	$(CXX) $(CXXFLAGS) -c NetworkMonitor.cpp


InterfaceDetector.o: InterfaceDetector.cpp InterfaceDetector.h
	$(CXX) $(CXXFLAGS) -c InterfaceDetector.cpp


NetworkManager.o: NetworkManager.cpp NetworkManager.h \
                  NetworkMonitor.h InterfaceDetector.h
	$(CXX) $(CXXFLAGS) -c NetworkManager.cpp


DBusService.o: DBusService.cpp DBusService.h \
               NetworkManager.h NetworkSpeedDBus.h
	$(CXX) $(CXXFLAGS) -c DBusService.cpp


NetworkSpeedDBus.o: NetworkSpeedDBus.c NetworkSpeedDBus.h
	$(CC) $(CFLAGS) -c NetworkSpeedDBus.c


.PHONY: clean

clean:
	rm -f *.o $(TARGET)
