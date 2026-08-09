#ifndef DBUSSERVICE_H
#define DBUSSERVICE_H

#include <gio/gio.h>

#include "NetworkManager.h"
#include "NetworkSpeedDBus.h"


class DBusService
{
private:

    NetworkManager& manager;

    GDBusConnection* connection;

    guint ownerId;

    guint registrationId;


public:

    DBusService(NetworkManager& manager);

    bool start();

    void stop();


    NetworkManager& getManager()
    {
        return manager;
    }
};


#endif
