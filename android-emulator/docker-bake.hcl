variable "REGISTRY" {
  default = "quickpod/android-emulator:"
}

target "common" {
  context = "."
  dockerfile = "Dockerfile"
}

// Android 34 (Android 14 "UpsideDownCake")
target "android-34" {
  inherits = ["common"]
  tags = [
    "${REGISTRY}android-34-x86_64",
    "${REGISTRY}latest"
  ]
  args = {
    UBUNTU_VERSION = "22.04"
    API_LEVEL = "34"
    BUILD_TOOLS_VERSION = "34.0.0"
    EMULATOR_DEVICE = "pixel_6"
    EMULATOR_NAME = "quickpod_device"
  }
}

// Android 35 (Android 15)
target "android-35" {
  inherits = ["common"]
  tags = [
    "${REGISTRY}android-35-x86_64"
  ]
  args = {
    UBUNTU_VERSION = "22.04"
    API_LEVEL = "35"
    BUILD_TOOLS_VERSION = "35.0.0"
    EMULATOR_DEVICE = "pixel_6"
    EMULATOR_NAME = "quickpod_device"
  }
}
