#include "InterfaceDetector.h"

#include <filesystem>
#include <fstream>


std::vector<std::string>
InterfaceDetector::getActiveInterfaces()
{

    std::vector<std::string> interfaces;


    std::string path = "/sys/class/net";


    for(auto &entry :
        std::filesystem::directory_iterator(path))
    {

        std::string interfaceName =
            entry.path().filename().string();



        if(interfaceName == "lo")
            continue;



        std::string stateFile =
            path + "/" +
            interfaceName +
            "/operstate";



        std::ifstream file(stateFile);


        std::string state;

        file >> state;



        if(state == "up")
        {
            interfaces.push_back(interfaceName);
        }

    }


    return interfaces;

}
