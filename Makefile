CXX = g++

CXXFLAGS = -std=c++17 -Wall

TARGET = internet-speed

OBJECTS = main.o \
          NetworkMonitor.o \
          InterfaceDetector.o \
          NetworkManager.o \
          SpeedFormatter.o


$(TARGET): $(OBJECTS)
	$(CXX) $(OBJECTS) -o $(TARGET)


main.o: main.cpp NetworkManager.h
	$(CXX) $(CXXFLAGS) -c main.cpp


NetworkMonitor.o: NetworkMonitor.cpp NetworkMonitor.h NetworkSpeed.h
	$(CXX) $(CXXFLAGS) -c NetworkMonitor.cpp


InterfaceDetector.o: InterfaceDetector.cpp InterfaceDetector.h
	$(CXX) $(CXXFLAGS) -c InterfaceDetector.cpp


NetworkManager.o: NetworkManager.cpp NetworkManager.h \
                  NetworkMonitor.h InterfaceDetector.h
	$(CXX) $(CXXFLAGS) -c NetworkManager.cpp


SpeedFormatter.o: SpeedFormatter.cpp SpeedFormatter.h
	$(CXX) $(CXXFLAGS) -c SpeedFormatter.cpp

.PHONY: clean

clean:
	rm -f *.o $(TARGET)
