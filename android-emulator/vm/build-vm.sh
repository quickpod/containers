#!/bin/bash
set -e

# Build a QEMU qcow2 VM image with Android emulator pre-installed.
# Requires: libguestfs-tools, wget, qemu-utils
#
# Usage: ./build-vm.sh [output-file]
#
# The resulting image can be booted with KVM for hardware-accelerated
# Android emulation without Docker privilege restrictions.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT="${1:-$SCRIPT_DIR/android-emulator.qcow2}"
DISK_SIZE="30G"
UBUNTU_VERSION="22.04"
UBUNTU_IMAGE_URL="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
UBUNTU_IMAGE="$SCRIPT_DIR/jammy-server-cloudimg-amd64.img"

API_LEVEL=34
BUILD_TOOLS_VERSION="34.0.0"
CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"

echo "============================================"
echo "  Building Android Emulator QEMU VM Image"
echo "  Ubuntu: ${UBUNTU_VERSION}"
echo "  Android API: ${API_LEVEL}"
echo "  Output: ${OUTPUT}"
echo "============================================"

# Check dependencies
for cmd in virt-customize qemu-img wget; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "ERROR: '$cmd' is required. Install with:"
        echo "  apt-get install libguestfs-tools qemu-utils wget"
        exit 1
    fi
done

# Download Ubuntu cloud image if not present
if [[ ! -f "$UBUNTU_IMAGE" ]]; then
    echo "Downloading Ubuntu ${UBUNTU_VERSION} cloud image..."
    wget -q --show-progress -O "$UBUNTU_IMAGE" "$UBUNTU_IMAGE_URL"
fi

# Create output image from base
echo "Creating VM disk image (${DISK_SIZE})..."
cp "$UBUNTU_IMAGE" "$OUTPUT"
qemu-img resize "$OUTPUT" "$DISK_SIZE"

# Expand the filesystem inside the image to use full disk
echo "Expanding guest filesystem..."
virt-customize -a "$OUTPUT" \
    --run-command 'apt-get update -y && apt-get install -y cloud-guest-utils' \
    --run-command 'growpart /dev/sda 1 || true' \
    --run-command 'resize2fs /dev/sda1 || xfs_growfs / || true' \
    --run-command 'apt-get clean && rm -rf /var/lib/apt/lists/*'

# Customize the image
echo "Installing packages and configuring image..."
virt-customize -a "$OUTPUT" \
    --run-command 'apt-get update -y' \
    --run-command 'DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-17-jdk-headless wget unzip curl git xvfb x11vnc novnc websockify libx11-6 libxcb1 libxext6 libxrender1 libxi6 libgl1-mesa-glx libgl1-mesa-dri libegl1 libpulse0 libglu1-mesa supervisor socat net-tools openssh-server qemu-kvm' \
    --run-command 'apt-get clean && rm -rf /var/lib/apt/lists/*' \
    --run-command 'mkdir -p /opt/android-sdk/cmdline-tools' \
    --run-command "wget -q '${CMDLINE_TOOLS_URL}' -O /tmp/cmdline-tools.zip && unzip -q /tmp/cmdline-tools.zip -d /tmp && mv /tmp/cmdline-tools /opt/android-sdk/cmdline-tools/latest && rm /tmp/cmdline-tools.zip" \
    --run-command 'yes | /opt/android-sdk/cmdline-tools/latest/bin/sdkmanager --licenses > /dev/null 2>&1' \
    --run-command "/opt/android-sdk/cmdline-tools/latest/bin/sdkmanager platform-tools 'platforms;android-${API_LEVEL}' 'build-tools;${BUILD_TOOLS_VERSION}' emulator 'system-images;android-${API_LEVEL};google_apis;x86_64'" \
    --run-command "echo 'no' | /opt/android-sdk/cmdline-tools/latest/bin/avdmanager create avd --name quickpod_device --package 'system-images;android-${API_LEVEL};google_apis;x86_64' --device pixel_6 --force" \
    --run-command 'mkdir -p /root/.android' \
    --run-command 'echo "hw.ramSize=4096" >> /root/.android/avd/quickpod_device.avd/config.ini' \
    --run-command 'echo "hw.gpu.enabled=yes" >> /root/.android/avd/quickpod_device.avd/config.ini' \
    --run-command 'echo "hw.gpu.mode=swiftshader_indirect" >> /root/.android/avd/quickpod_device.avd/config.ini' \
    --run-command 'echo "disk.dataPartition.size=4096M" >> /root/.android/avd/quickpod_device.avd/config.ini' \
    --run-command 'echo "hw.keyboard=yes" >> /root/.android/avd/quickpod_device.avd/config.ini' \
    --run-command 'echo "hw.mainKeys=no" >> /root/.android/avd/quickpod_device.avd/config.ini' \
    --run-command 'ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html' \
    --copy-in "$SCRIPT_DIR/vm-start.sh:/opt/" \
    --copy-in "$SCRIPT_DIR/android-emulator.service:/etc/systemd/system/" \
    --run-command 'chmod +x /opt/vm-start.sh' \
    --run-command 'systemctl enable android-emulator.service' \
    --run-command 'systemctl enable ssh' \
    --append-line '/etc/environment:ANDROID_HOME=/opt/android-sdk' \
    --append-line '/etc/environment:ANDROID_SDK_ROOT=/opt/android-sdk' \
    --append-line '/etc/environment:PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/android-sdk/emulator:/opt/android-sdk/platform-tools:/opt/android-sdk/cmdline-tools/latest/bin'

# Set up cloud-init for first boot (password, SSH keys)
virt-customize -a "$OUTPUT" \
    --run-command 'echo "root:quickpod" | chpasswd' \
    --run-command 'sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/" /etc/ssh/sshd_config' \
    --run-command 'sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config'

echo ""
echo "============================================"
echo "  VM image built successfully!"
echo "  Output: ${OUTPUT}"
echo "  Size: $(du -h "$OUTPUT" | cut -f1)"
echo ""
echo "  Boot with:"
echo "    ./launch-vm.sh ${OUTPUT}"
echo "============================================"
