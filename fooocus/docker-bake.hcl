variable "FOOOCUS_VERSION" {
    default = "2.5.5"
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
        FOOOCUS_VERSION = "${FOOOCUS_VERSION}"
    }
    tags = [
        "${REGISTRY}/fooocus:latest",
        "${REGISTRY}/fooocus:${FOOOCUS_VERSION}"
    ]
}

# Default target group that will be built when no specific target is specified
group "default" {
    targets = ["latest"]
} 