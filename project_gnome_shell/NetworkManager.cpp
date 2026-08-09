#include <string>
#include <vector>
#include <memory>
#include "NetworkManager.h"


bool NetworkManager::hasMonitor(
    const std::string& name)
{
    for(const auto& monitor : monitors)
    {
        if(monitor->getName() == name)
        {
            return true;
        }
    }

    return false;
}


bool NetworkManager::interfaceIsActive(
    const std::vector<std::string>& interfaces,
    const std::string& name)
{
    for(const auto& interfaceName : interfaces)
    {
        if(interfaceName == name)
        {
            return true;
        }
    }

    return false;
}


void NetworkManager::updateInterfaces()
{
    std::vector<std::string> interfaces =
        detector.getActiveInterfaces();


    // Add new interfaces

    for(const auto& name : interfaces)
    {
        if(!hasMonitor(name))
        {
            monitors.push_back(
                std::make_unique<NetworkMonitor>(name)
            );
        }
    }


    // Remove interfaces

    for(auto it = monitors.begin();
        it != monitors.end();)
    {
        if(!interfaceIsActive(
            interfaces,
            (*it)->getName()))
        {
            it = monitors.erase(it);
        }
        else
        {
            ++it;
        }
    }
}


void NetworkManager::update()
{
    for(auto& monitor : monitors)
    {
        monitor->update();
    }
}


const std::vector<
    std::unique_ptr<NetworkMonitor>
>&
NetworkManager::getMonitors() const
{
    return monitors;
}

NetworkSpeed NetworkManager::getTotalSpeed() const
{
    NetworkSpeed total{0.0, 0.0};


    for(const auto& monitor : monitors)
    {
        NetworkSpeed speed =
            monitor->getSpeed();


        total.downloadSpeed +=
            speed.downloadSpeed;


        total.uploadSpeed +=
            speed.uploadSpeed;
    }


    return total;
}
