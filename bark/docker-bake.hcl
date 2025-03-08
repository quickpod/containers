variable "REGISTRY" {
    default = "quickpod"
}

# Target for building the latest version
target "latest" {
    context = "."
    dockerfile = "Dockerfile"
    platforms = ["linux/amd64"]
    args = {
        BASE_IMAGE = "python:3.8-slim"
    }
    tags = [
        "${REGISTRY}/bark:latest"
    ]
}

# Default target group that will be built when no specific target is specified
group "default" {
    targets = ["latest"]
} 