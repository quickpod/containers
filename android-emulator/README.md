# Android Emulator

A headless Android emulator Docker image for mobile app testing on QuickPod GPU instances.

## Features

- Android 14 (API 34) with Google APIs
- Headless emulator with software rendering (swiftshader)
- KVM hardware acceleration when available
- noVNC web-based screen access on port 6080
- ADB accessible over network on port 5555
- SSH access for remote development

## Ports

| Port | Service |
|------|---------|
| 22   | SSH |
| 5554 | Emulator console |
| 5555 | ADB over network |
| 6080 | noVNC (browser-based emulator view) |

## Usage

### Run with Docker

```bash
docker run -d \
  --privileged \
  --device /dev/kvm \
  -p 5555:5555 \
  -p 6080:6080 \
  -p 22:22 \
  -e PUBLIC_KEY="ssh-rsa AAAA..." \
  quickpod/android-emulator:latest
```

> **Note:** `--device /dev/kvm` requires KVM support on the host. Without it, the emulator runs in software-only mode (much slower).

### Connect via ADB

```bash
adb connect <host-ip>:5555
adb devices
```

### View Emulator Screen

Open `http://<host-ip>:6080` in a browser for noVNC access.

### Use with Expo

```bash
# Connect ADB to the container
adb connect <container-ip>:5555

# Start Expo with the connected device
npx expo start --android --tunnel
```

## Build

```bash
# Build Android 34 image
docker buildx bake android-34

# Build Android 35 image
docker buildx bake android-35
```

## Requirements

- Host must support KVM for acceptable performance (x86_64 with virtualization extensions)
- Minimum 4GB RAM allocated to the container
- ~15GB disk space for the image

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PUBLIC_KEY` | - | SSH public key for root access |
| `EMULATOR_NAME` | `quickpod_device` | AVD name |
| `API_LEVEL` | `34` | Android API level |
| `EMULATOR_DEVICE` | `pixel_6` | Emulated hardware profile |
