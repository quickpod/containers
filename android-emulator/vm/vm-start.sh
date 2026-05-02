#!/bin/bash
set -e

# Android Emulator VM startup script
# Runs inside the QEMU VM at boot via systemd

export ANDROID_HOME=/opt/android-sdk
export ANDROID_SDK_ROOT=/opt/android-sdk
export PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin
export DISPLAY=:0

EMULATOR_NAME="quickpod_device"

echo "[android-emulator] Starting virtual display..."
Xvfb :0 -screen 0 1920x1080x24 -nolisten tcp &
sleep 2

echo "[android-emulator] Starting VNC server..."
x11vnc -display :0 -forever -nopw -shared -rfbport 5900 -noxdamage &
sleep 1

echo "[android-emulator] Starting noVNC on port 6080..."
websockify --web /usr/share/novnc 6080 localhost:5900 &

echo "[android-emulator] Starting Android emulator..."
EMU_ARGS=(
    -avd "$EMULATOR_NAME"
    -no-audio
    -no-sim
    -skin 480x960
    -gpu swiftshader_indirect
    -no-boot-anim
    -no-snapshot
    -memory 4096
    -no-metrics
)

# KVM is available directly in the VM (no container restrictions)
if [[ -e /dev/kvm ]]; then
    echo "[android-emulator] KVM acceleration enabled"
else
    echo "[android-emulator] WARNING: No KVM, using software emulation (slow)"
    EMU_ARGS+=(-no-accel)
fi

$ANDROID_HOME/emulator/emulator "${EMU_ARGS[@]}" &
EMULATOR_PID=$!

echo "[android-emulator] Waiting for emulator to boot (PID: $EMULATOR_PID)..."
adb wait-for-device

# Wait for boot completion
boot_complete=""
timeout=120
elapsed=0
while [[ "$boot_complete" != "1" && $elapsed -lt $timeout ]]; do
    boot_complete=$(adb shell getprop sys.boot_completed 2>/dev/null || echo "")
    if [[ "$boot_complete" != "1" ]]; then
        elapsed=$((elapsed + 3))
        sleep 3
    fi
done

if [[ "$boot_complete" == "1" ]]; then
    echo "[android-emulator] Boot complete!"
    # Disable animations
    adb shell settings put global window_animation_scale 0
    adb shell settings put global transition_animation_scale 0
    adb shell settings put global animator_duration_scale 0
    # Enable ADB over network
    adb tcpip 5555
else
    echo "[android-emulator] WARNING: Boot timed out after ${timeout}s"
fi

echo "[android-emulator] Ready. ADB: port 5555, noVNC: port 6080"

# Keep running
wait $EMULATOR_PID
