variable "INVOKEAI_VERSION" {
    default = "6.9.0"
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
        INVOKEAI_VERSION = "${INVOKEAI_VERSION}"
    }
    tags = [
        "${REGISTRY}/invokeai:latest",
        "${REGISTRY}/invokeai:${INVOKEAI_VERSION}"
    ]
}

# Default target group that will be built when no specific target is specified
group "default" {
    targets = ["latest"]
} 