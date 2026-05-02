#!/bin/bash
set -e

# ---------------------------------------------------------------------------- #
#                          Function Definitions                                 #
# ---------------------------------------------------------------------------- #

setup_ssh() {
    if [[ $PUBLIC_KEY ]]; then
        echo "Setting up SSH with provided public key"
        mkdir -p /root/.ssh
        chmod 700 /root/.ssh
        echo "$PUBLIC_KEY" >> /root/.ssh/authorized_keys
        chmod 600 /root/.ssh/authorized_keys
        service ssh start
        echo "SSH service started"
    fi
}

start_display() {
    echo "Starting virtual display (Xvfb)..."
    Xvfb :0 -screen 0 1920x1080x24 -nolisten tcp &
    sleep 2
    export DISPLAY=:0
}

start_vnc() {
    echo "Starting VNC server..."
    x11vnc -display :0 -forever -nopw -shared -rfbport 5900 -noxdamage &
    sleep 1

    echo "Starting noVNC (web access on port 6080)..."
    websockify --web /usr/share/novnc 6080 localhost:5900 &
}

start_emulator() {
    echo "Starting Android emulator: ${EMULATOR_NAME}"

    local emu_args=(
        -avd "${EMULATOR_NAME}"
        -no-audio
        -no-sim
        -skin 480x960
        -gpu swiftshader_indirect
        -no-boot-anim
        -no-snapshot
        -memory 2048
    )

    # Use -no-window only if no display
    if [[ -z "$DISPLAY" ]]; then
        emu_args+=(-no-window)
    fi

    # Enable KVM if available
    if [[ -e /dev/kvm ]]; then
        echo "KVM acceleration available"
    else
        echo "WARNING: KVM not available. Emulator will be slow."
        emu_args+=(-no-accel)
    fi

    $ANDROID_HOME/emulator/emulator "${emu_args[@]}" &
    EMULATOR_PID=$!

    echo "Waiting for emulator to boot..."
    adb wait-for-device

    # Wait for boot completion
    local boot_complete=""
    local timeout=300
    local elapsed=0
    while [[ "$boot_complete" != "1" && $elapsed -lt $timeout ]]; do
        boot_complete=$(adb shell getprop sys.boot_completed 2>/dev/null || echo "")
        if [[ "$boot_complete" != "1" ]]; then
            elapsed=$((elapsed + 5))
            sleep 5
        fi
    done

    if [[ "$boot_complete" == "1" ]]; then
        echo "Emulator booted successfully!"
        # Disable animations for faster testing
        adb shell settings put global window_animation_scale 0
        adb shell settings put global transition_animation_scale 0
        adb shell settings put global animator_duration_scale 0
    else
        echo "WARNING: Emulator boot timed out after ${timeout}s"
    fi
}

setup_adb_network() {
    echo "Configuring ADB to accept network connections..."
    # Allow ADB connections from any host
    adb -s emulator-5554 tcpip 5555 2>/dev/null || true
    # Forward ADB server port
    socat TCP-LISTEN:5037,fork,reuseaddr TCP:127.0.0.1:5037 &
}

# ---------------------------------------------------------------------------- #
#                               Main Entry Point                                #
# ---------------------------------------------------------------------------- #

echo "============================================"
echo "  QuickPod Android Emulator Container"
echo "  API Level: ${API_LEVEL}"
echo "  Device: ${EMULATOR_DEVICE}"
echo "============================================"

# Ensure IPv6 loopback is available (emulator modem uses ::1)
if ! grep -q '::1' /etc/hosts 2>/dev/null; then
    echo '::1 localhost ip6-localhost ip6-loopback' >> /etc/hosts
fi

# Enable IPv6 loopback if possible
if [[ -w /proc/sys/net/ipv6/conf/lo/disable_ipv6 ]]; then
    echo 0 > /proc/sys/net/ipv6/conf/lo/disable_ipv6
fi

setup_ssh
start_display
start_vnc
start_emulator
setup_adb_network

echo ""
echo "============================================"
echo "  Android Emulator is ready!"
echo "  - ADB: adb connect <host>:5555"
echo "  - noVNC: http://<host>:6080"
echo "  - SSH: ssh root@<host>"
echo "============================================"

# Keep container running
exec supervisord -n -c /etc/supervisor/conf.d/emulator.conf
