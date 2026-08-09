#include "DBusService.h"

#include <iostream>


// ============================================================
// GObject implementation of arindamsen95.NetworkSpeed
// ============================================================

typedef struct
{
    GObject parent_instance;

    DBusService* service;

} NetworkSpeedObject;


typedef struct
{
    GObjectClass parent_class;

} NetworkSpeedObjectClass;


// Forward declaration

static void
network_speed_object_iface_init(
    Arindamsen95NetworkSpeedIface* iface);


// Create GObject type

G_DEFINE_TYPE_WITH_CODE(
    NetworkSpeedObject,
    network_speed_object,
    G_TYPE_OBJECT,

    G_IMPLEMENT_INTERFACE(
        TYPE_ARINDAMSEN95_NETWORK_SPEED,
        network_speed_object_iface_init
    )
)


// ============================================================
// Convert GObject to NetworkSpeedObject
// ============================================================

#define NETWORK_SPEED_OBJECT(obj) \
    ((NetworkSpeedObject*) \
     g_type_check_instance_cast( \
         (GTypeInstance*)(obj), \
         network_speed_object_get_type()))


// ============================================================
// GObject initialization
// ============================================================

static void
network_speed_object_init(
    NetworkSpeedObject* object)
{
    object->service = nullptr;
}


static void
network_speed_object_class_init(
    NetworkSpeedObjectClass* klass)
{
}


// ============================================================
// D-Bus method: GetDownload
// ============================================================

static gboolean
handle_get_download(
    Arindamsen95NetworkSpeed* object,
    GDBusMethodInvocation* invocation)
{
    NetworkSpeedObject* speedObject =
        NETWORK_SPEED_OBJECT(object);


    DBusService* service =
        speedObject->service;


    NetworkSpeed speed =
        service->getManager().getTotalSpeed();


    arindamsen95_network_speed_complete_get_download(
        object,
        invocation,
        speed.downloadSpeed
    );


    return TRUE;
}


// ============================================================
// D-Bus method: GetUpload
// ============================================================

static gboolean
handle_get_upload(
    Arindamsen95NetworkSpeed* object,
    GDBusMethodInvocation* invocation)
{
    NetworkSpeedObject* speedObject =
        NETWORK_SPEED_OBJECT(object);


    DBusService* service =
        speedObject->service;


    NetworkSpeed speed =
        service->getManager().getTotalSpeed();


    arindamsen95_network_speed_complete_get_upload(
        object,
        invocation,
        speed.uploadSpeed
    );


    return TRUE;
}


// ============================================================
// Connect generated D-Bus interface to handlers
// ============================================================

static void
network_speed_object_iface_init(
    Arindamsen95NetworkSpeedIface* iface)
{
    iface->handle_get_download =
        handle_get_download;


    iface->handle_get_upload =
        handle_get_upload;
}


// ============================================================
// D-Bus method dispatcher
// ============================================================

static void
method_call(
    GDBusConnection* connection,
    const gchar* sender,
    const gchar* objectPath,
    const gchar* interfaceName,
    const gchar* methodName,
    GVariant* parameters,
    GDBusMethodInvocation* invocation,
    gpointer userData)
{

//std::cout
//        << "D-Bus method called: "
//        << methodName
//        << std::endl;



    NetworkSpeedObject* object =
        static_cast<NetworkSpeedObject*>(userData);


    if(g_strcmp0(methodName, "GetDownload") == 0)
    {
        handle_get_download(
            ARINDAMSEN95_NETWORK_SPEED(object),
            invocation
        );

        return;
    }


    if(g_strcmp0(methodName, "GetUpload") == 0)
    {
        handle_get_upload(
            ARINDAMSEN95_NETWORK_SPEED(object),
            invocation
        );

        return;
    }


    g_dbus_method_invocation_return_error(
        invocation,
        G_IO_ERROR,
        G_IO_ERROR_NOT_SUPPORTED,
        "Unknown method: %s",
        methodName
    );
}


// ============================================================
// D-Bus interface VTable
// ============================================================

static const GDBusInterfaceVTable interfaceVTable =
{
    method_call,
    nullptr,
    nullptr
};


// ============================================================
// DBusService constructor
// ============================================================

DBusService::DBusService(
    NetworkManager& manager)
:
manager(manager),
connection(nullptr),
ownerId(0),
registrationId(0)
{
}


// ============================================================
// Start D-Bus service
// ============================================================

bool DBusService::start()
{
    GError* error = nullptr;


    // --------------------------------------------------------
    // Connect to the session D-Bus
    // --------------------------------------------------------

    connection =
        g_bus_get_sync(
            G_BUS_TYPE_SESSION,
            nullptr,
            &error
        );


    if(error != nullptr)
    {
        std::cerr
            << "D-Bus connection error: "
            << error->message
            << std::endl;


        g_error_free(error);

        return false;
    }


    std::cout
        << "Connected to D-Bus"
        << std::endl;


    // --------------------------------------------------------
    // Claim D-Bus bus name
    // --------------------------------------------------------

    ownerId =
        g_bus_own_name_on_connection(
            connection,

            "arindamsen95.NetworkSpeed",

            G_BUS_NAME_OWNER_FLAGS_NONE,

            nullptr,
            nullptr,
            nullptr,
            nullptr
        );


    // --------------------------------------------------------
    // Create our GObject
    // --------------------------------------------------------

    NetworkSpeedObject* object =
        static_cast<NetworkSpeedObject*>(
            g_object_new(
                network_speed_object_get_type(),
                nullptr
            )
        );


    object->service = this;


    // --------------------------------------------------------
    // Register object on D-Bus
    // --------------------------------------------------------

    registrationId =
        g_dbus_connection_register_object(
            connection,

            "/arindamsen95/NetworkSpeed",

            arindamsen95_network_speed_interface_info(),

            &interfaceVTable,

            object,

            nullptr,

            &error
        );


    if(registrationId == 0)
    {
        std::cerr
            << "Failed to register D-Bus object: "
            << error->message
            << std::endl;


        g_error_free(error);

        g_object_unref(object);

        return false;
    }


    std::cout
        << "D-Bus object registered"
        << std::endl;


    return true;
}


// ============================================================
// Stop D-Bus service
// ============================================================

void DBusService::stop()
{
    // --------------------------------------------------------
    // Unregister object
    // --------------------------------------------------------

    if(connection != nullptr &&
       registrationId != 0)
    {
        g_dbus_connection_unregister_object(
            connection,
            registrationId
        );


        registrationId = 0;
    }


    // --------------------------------------------------------
    // Release bus name
    // --------------------------------------------------------

    if(ownerId != 0)
    {
        g_bus_unown_name(ownerId);

        ownerId = 0;
    }


    // --------------------------------------------------------
    // Disconnect from D-Bus
    // --------------------------------------------------------

    if(connection != nullptr)
    {
        g_object_unref(connection);

        connection = nullptr;
    }
}
