#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo " Running D-Bus Integration Tests"
echo "=========================================="

# 1. Verify executable exists
if [ ! -f "./internet-speed" ]; then
    echo "Error: 'internet-speed' binary not found. Run 'make' first."
    exit 1
fi

# 2. Run daemon under isolated D-Bus session
dbus-run-session -- bash -c '
    echo "Starting internet-speed daemon in background..."
    ./internet-speed &
    DAEMON_PID=$!

    # Give service time to register on D-Bus
    sleep 2

    echo "Querying D-Bus interface..."
    # Replace with your actual D-Bus destination and object path
    if gdbus call --session \
        --dest arindamsen95.NetworkSpeed \
        --object-path /arindamsen95/NetworkSpeed \
        --method arindamsen95.NetworkSpeed.GetDownloadSpeed > /dev/null; then
        echo "D-Bus test PASSED!"
        kill $DAEMON_PID
        exit 0
    else
        echo "D-Bus test FAILED!"
        kill -9 $DAEMON_PID 2>/dev/null || true
        exit 1
    fi
'
