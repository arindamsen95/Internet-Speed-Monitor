#include <iostream>
#include <iomanip>
#include <string>
#include <vector>
#include <chrono>
#include <thread>
#include <memory>
#include "NetworkManager.h"
#include "SpeedFormatter.h"

using namespace std;


int main()
{
    NetworkManager manager;


    while(true)
    {
        this_thread::sleep_for(
            chrono::seconds(1)
        );


        manager.updateInterfaces();

        manager.update();



        cout << "\033[2J\033[1;1H";


        cout << string(30, '=') << endl;
        cout << "   Internet Speed Monitor\n";
        cout << string(30, '=') << endl;



        const auto& monitors =
            manager.getMonitors();


        for(const auto& monitor : monitors)
        {
        
            NetworkSpeed speed =
                    monitor->getSpeed();
                    
            cout << "\nInterface: "
                 << monitor->getName()
                 << "\n";

            cout << setw(12)
                 << "Download:"
                 << setw(8)
                 << formatSpeed(speed.downloadSpeed)
                 << "\n";

            cout << setw(12)
                 << "Upload:"
                 << setw(8)
                 << formatSpeed(speed.uploadSpeed)
                 << "\n";
        }
    }


    return 0;
}
