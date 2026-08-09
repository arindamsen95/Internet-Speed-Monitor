#include "SpeedFormatter.h"

#include <iomanip>
#include <sstream>


std::string formatSpeed(double mbPerSecond)
{
    std::ostringstream output;


    if(mbPerSecond >= 1.0)
    {
        output
        << std::fixed
        << std::setprecision(2)
        << mbPerSecond
        << " MB/s";
    }


    else if(mbPerSecond >= 1.0 / 1024.0)
    {
        double kb =
            mbPerSecond * 1024.0;


        output
        << std::fixed
        << std::setprecision(2)
        << kb
        << " KB/s";
    }


    else
    {
        double bytes =
            mbPerSecond * 1024.0 * 1024.0;


        output
        << std::fixed
        << std::setprecision(0)
        << bytes
        << " B/s";
    }


    return output.str();
}
