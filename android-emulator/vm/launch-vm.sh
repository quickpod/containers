#!/bin/bash
set -e

# Launch the Android Emulator QEMU VM with KVM acceleration.
#
# Usage: ./launch-vm.sh [image-file] [options]
#
# Options:
#   --memory SIZE    RAM in MB (default: 6144)
#   --cpus NUM       Number of CPUs (default: 4)
#   --vnc-port PORT  Host port for noVNC (default: 6080)
#   --adb-port PORT  Host port for ADB (default: 5555)
#   --ssh-port PORT  Host port for SSH (default: 2222)
#   --daemonize      Run in background

IMAGE="${1:-$(dirname "$0")/android-emulator.qcow2}"
MEMORY=6144
CPUS=4
VNC_PORT=6080
ADB_PORT=5555
SSH_PORT=2222
DAEMONIZE=""

shift 2>/dev/null || true
while [[ $# -gt 0 ]]; do
    case "$1" in
        --memory) MEMORY="$2"; shift 2 ;;
        --cpus) CPUS="$2"; shift 2 ;;
        --vnc-port) VNC_PORT="$2"; shift 2 ;;
        --adb-port) ADB_PORT="$2"; shift 2 ;;
        --ssh-port) SSH_PORT="$2"; shift 2 ;;
        --daemonize) DAEMONIZE="-daemonize"; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [[ ! -f "$IMAGE" ]]; then
    echo "ERROR: Image not found: $IMAGE"
    echo "Run ./build-vm.sh first to create the image."
    exit 1
fi

echo "============================================"
echo "  Launching Android Emulator VM"
echo "  Image: $IMAGE"
echo "  Memory: ${MEMORY}MB, CPUs: $CPUS"
echo "  Ports:"
echo "    SSH:   localhost:${SSH_PORT}"
echo "    ADB:   localhost:${ADB_PORT}"
echo "    noVNC: localhost:${VNC_PORT}"
echo "============================================"

QEMU_ARGS=(
    -m "${MEMORY}"
    -smp "$CPUS"
    -drive "file=${IMAGE},format=qcow2,if=virtio"
    -netdev "user,id=net0,hostfwd=tcp::${SSH_PORT}-:22,hostfwd=tcp::${ADB_PORT}-:5555,hostfwd=tcp::${VNC_PORT}-:6080"
    -device "virtio-net-pci,netdev=net0"
    -nographic
    -serial mon:stdio
)

# Enable KVM if available on host
if [[ -e /dev/kvm ]]; then
    echo "KVM acceleration: enabled"
    QEMU_ARGS+=(-enable-kvm -cpu host)
else
    echo "WARNING: KVM not available, VM will be slow"
    QEMU_ARGS+=(-cpu qemu64)
fi

if [[ -n "$DAEMONIZE" ]]; then
    QEMU_ARGS+=(-daemonize)
    echo "Running in background..."
fi

exec qemu-system-x86_64 "${QEMU_ARGS[@]}"
