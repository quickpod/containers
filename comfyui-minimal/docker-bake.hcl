variable "COMFYUI_VERSION" {
    default = "0.3.22"
}

variable "REGISTRY" {
    default = "quickpod"
}

# Target for building the minimal version
target "minimal" {
    context = "."
    dockerfile = "Dockerfile"
    platforms = ["linux/amd64"]
    args = {
        BASE_IMAGE = "python:3.10-slim"
        COMFYUI_VERSION = "${COMFYUI_VERSION}"
    }
    tags = [
        "${REGISTRY}/comfyui:minimal",
        "${REGISTRY}/comfyui:minimal-${COMFYUI_VERSION}"
    ]
}

# Default target group that will be built when no specific target is specified
group "default" {
    targets = ["minimal"]
} 