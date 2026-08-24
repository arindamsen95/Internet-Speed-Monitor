#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo " Running D-Bus Integration Tests"
echo "=========================================="

# ------------------------------------------------------------
# 1. Verify executable exists
# ------------------------------------------------------------

if [ ! -f "./internet-speed" ]; then
    echo "ERROR: 'internet-speed' binary not found."
    echo "Run 'make' first."
    exit 1
fi

echo "Executable: OK"

# ------------------------------------------------------------
# 2. Run daemon inside an isolated D-Bus session
# ------------------------------------------------------------

dbus-run-session -- bash -c '
    set -e

    echo "Starting internet-speed daemon..."

    ./internet-speed &
    DAEMON_PID=$!

    # Always clean up the daemon when this test exits
    cleanup()
    {
        if kill -0 "$DAEMON_PID" 2>/dev/null; then
            kill "$DAEMON_PID" 2>/dev/null || true
            wait "$DAEMON_PID" 2>/dev/null || true
        fi
    }

    trap cleanup EXIT

    # Give the daemon time to start and register its D-Bus name
    sleep 2

    # --------------------------------------------------------
    # Test GetDownload
    # --------------------------------------------------------

    echo
    echo "Testing GetDownload..."

    DOWNLOAD=$(gdbus call \
        --session \
        --dest arindamsen95.NetworkSpeed \
        --object-path /arindamsen95/NetworkSpeed \
        --method arindamsen95.NetworkSpeed.GetDownload)

    echo "GetDownload returned: $DOWNLOAD"

    if [[ "$DOWNLOAD" =~ ^\([0-9.eE+-]+,\)$ ]]; then
        echo "GetDownload: PASSED"
    else
        echo "GetDownload: FAILED"
        exit 1
    fi

    # --------------------------------------------------------
    # Test GetUpload
    # --------------------------------------------------------

    echo
    echo "Testing GetUpload..."

    UPLOAD=$(gdbus call \
        --session \
        --dest arindamsen95.NetworkSpeed \
        --object-path /arindamsen95/NetworkSpeed \
        --method arindamsen95.NetworkSpeed.GetUpload)

    echo "GetUpload returned: $UPLOAD"

    if [[ "$UPLOAD" =~ ^\([0-9.eE+-]+,\)$ ]]; then
        echo "GetUpload: PASSED"
    else
        echo "GetUpload: FAILED"
        exit 1
    fi

    echo
    echo "=========================================="
    echo " D-Bus Integration Tests PASSED"
    echo "=========================================="
'
