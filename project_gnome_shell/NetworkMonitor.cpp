#include "NetworkMonitor.h"
#include <string>
#include <fstream>


long long NetworkMonitor::readBytes(
        std::string interfaceName,
        std::string type)
{

    std::string filename =
        "/sys/class/net/" +
        interfaceName +
        "/statistics/" +
        type;


    std::ifstream file(filename);


    long long bytes = 0;

    file >> bytes;


    return bytes;
}



NetworkMonitor::NetworkMonitor(std::string name)
:
interfaceName(name),
oldRx(0),
oldTx(0),
speed{0.0, 0.0}
{

    oldRx = readBytes(interfaceName,"rx_bytes");
    oldTx = readBytes(interfaceName,"tx_bytes");

}



void NetworkMonitor::update()
{

    long long newRx =
        readBytes(interfaceName,"rx_bytes");


    long long newTx =
        readBytes(interfaceName,"tx_bytes");


    speed.downloadSpeed =
        (newRx - oldRx)/(1024.0 * 1024.0);


    speed.uploadSpeed =
        (newTx - oldTx)/(1024.0 * 1024.0);


    oldRx = newRx;
    oldTx = newTx;

}



NetworkSpeed NetworkMonitor::getSpeed() const
{
    return speed;
}

std::string NetworkMonitor::getName() const
{
    return interfaceName;
}
