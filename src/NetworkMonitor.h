#ifndef NETWORKMONITOR_H
#define NETWORKMONITOR_H

#include <string>
#include "NetworkSpeed.h"

class NetworkMonitor
{

private:

    std::string interfaceName;

    long long oldRx;
    long long oldTx;

    NetworkSpeed speed;


    long long readBytes(std::string interfaceName,
                        std::string type);


public:

    NetworkMonitor(std::string name);

    void update();
    
    NetworkSpeed getSpeed() const;
    
    std::string getName() const;

};

#endif
