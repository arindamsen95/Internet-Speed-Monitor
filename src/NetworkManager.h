#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <vector>
#include <string>
#include <memory>
#include "NetworkMonitor.h"
#include "InterfaceDetector.h"
#include "NetworkSpeed.h"

class NetworkManager
{

private:

    InterfaceDetector detector;

    std::vector<std::unique_ptr<NetworkMonitor>> monitors;

    bool hasMonitor(
        const std::string& name);

    bool interfaceIsActive(
        const std::vector<std::string>& interfaces,
        const std::string& name);


public:

    void updateInterfaces();

    void update();

    const std::vector<
        std::unique_ptr<NetworkMonitor>>& getMonitors() const;
        
    NetworkSpeed getTotalSpeed() const;

};

#endif
