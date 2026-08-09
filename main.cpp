#include <fstream>
#include <memory>
#include <iostream>
#include <iomanip>
#include <chrono>
#include <thread>
#include <string>

#include <glib.h>

#include "NetworkManager.h"
#include "DBusService.h"


using namespace std;


// ============================================================
// Timer callback
// ============================================================

static gboolean
updateCallback(gpointer data)
{
    NetworkManager* manager =
        static_cast<NetworkManager*>(data);


    manager->updateInterfaces();

    manager->update();


    // Keep the timer running

    return G_SOURCE_CONTINUE;
}


// ============================================================
// Main
// ============================================================

int main()
{
    NetworkManager manager;


    // --------------------------------------------------------
    // Start D-Bus service
    // --------------------------------------------------------

    DBusService service(manager);


    if(!service.start())
    {
        cerr
            << "Failed to start D-Bus service"
            << endl;

        return 1;
    }


    // --------------------------------------------------------
    // Do an initial update
    // --------------------------------------------------------

    manager.updateInterfaces();

    manager.update();


    // --------------------------------------------------------
    // Create GLib main loop
    // --------------------------------------------------------

    GMainLoop* loop =
        g_main_loop_new(
            nullptr,
            FALSE
        );


    // --------------------------------------------------------
    // Update network speed every second
    // --------------------------------------------------------

    g_timeout_add_seconds(
        1,
        updateCallback,
        &manager
    );

    // --------------------------------------------------------
    // Run event loop
    // --------------------------------------------------------

    g_main_loop_run(loop);


    // --------------------------------------------------------
    // Cleanup
    // --------------------------------------------------------

    service.stop();

    g_main_loop_unref(loop);


    return 0;
}
