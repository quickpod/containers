variable "AUDIOCRAFT_VERSION" {
    default = "2.0.1"
}

variable "REGISTRY" {
    default = "quickpod"
}

# Target for building the latest version
target "latest" {
    context = "."
    dockerfile = "Dockerfile"
    platforms = ["linux/amd64"]
    args = {
        BASE_IMAGE = "python:3.10-slim"
        AUDIOCRAFT_VERSION = "${AUDIOCRAFT_VERSION}"
    }
    tags = [
        "${REGISTRY}/audiocraft-plus:latest",
        "${REGISTRY}/audiocraft-plus:${AUDIOCRAFT_VERSION}"
    ]
}

# Default target group that will be built when no specific target is specified
group "default" {
    targets = ["latest"]
} 