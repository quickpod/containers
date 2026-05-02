# Android Emulator QEMU VM

A QEMU virtual machine image with a pre-installed Android emulator. Unlike the Docker container approach, the VM has direct KVM access without needing `--privileged` or `--device` flags.

## Why VM instead of Docker?

- **No privilege restrictions** — KVM is available directly inside the VM
- **Fast boot** — With nested KVM, the Android emulator boots in ~30 seconds
- **No container runtime dependency** — Just QEMU on the host

## Build

### Requirements

```bash
apt-get install libguestfs-tools qemu-utils wget qemu-system-x86
```

### Build the image

```bash
chmod +x build-vm.sh
./build-vm.sh
# Output: android-emulator.qcow2 (~15GB)
```

## Launch

```bash
chmod +x launch-vm.sh
./launch-vm.sh android-emulator.qcow2
```

### Options

```bash
./launch-vm.sh android-emulator.qcow2 \
  --memory 6144 \
  --cpus 4 \
  --ssh-port 2222 \
  --adb-port 5555 \
  --vnc-port 6080 \
  --daemonize
```

## Access

| Service | Default Port | Command |
|---------|-------------|---------|
| SSH | 2222 | `ssh -p 2222 root@localhost` (password: `quickpod`) |
| ADB | 5555 | `adb connect localhost:5555` |
| noVNC | 6080 | Browser: `http://localhost:6080` |

## Use with Expo

```bash
# Connect ADB to the VM's emulator
adb connect localhost:5555

# Start Expo dev server
cd your-app/
npx expo start --android --tunnel
```

## Architecture

```
Host (bare metal / cloud VM)
└── QEMU VM (KVM-accelerated)
    ├── Xvfb (virtual display :0)
    ├── x11vnc → noVNC (port 6080)
    ├── Android Emulator (KVM-accelerated inside VM)
    │   └── Android 14 (API 34, Pixel 6)
    └── ADB server (port 5555)
```

The key advantage: the QEMU VM runs with `-enable-kvm` on the host, and the Android emulator inside the VM also gets KVM access — giving you hardware-accelerated Android emulation without any Docker privilege issues.

## QuickPod Deployment

To distribute as a QuickPod template:

1. Build the image: `./build-vm.sh`
2. Upload `android-emulator.qcow2` to storage
3. Configure the template to boot the qcow2 with QEMU + KVM
4. Expose ports 5555 (ADB) and 6080 (noVNC)

## File Structure

```
vm/
├── build-vm.sh                 # Builds the qcow2 image
├── launch-vm.sh                # Launches the VM with QEMU
├── vm-start.sh                 # Runs inside VM at boot
├── android-emulator.service    # systemd unit for auto-start
└── README.md
```
