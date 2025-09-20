variable "REGISTRY" {
  default = "quickpod/jupyterlab:"
}

// Common target configuration
target "common" {
  context = "."
  dockerfile = "Dockerfile"
}

// CUDA 12.6
target "cuda-12-6" {
  inherits = ["common"]
  tags = [
    "${REGISTRY}4.3.1-py3.10.12-cuda12.6-cudnn9.5-ubuntu22.04",
    "${REGISTRY}0.1.8"
  ]
  args = {
    CUDA_VERSION = "12.6.2"
    CUDNN_VERSION = ""
    UBUNTU_VERSION = "22.04"
  }
}

// CUDA 12.4
target "cuda-12-4" {
  inherits = ["common"]
  tags = [
    "${REGISTRY}4.3.1-py3.10.12-cuda12.4-cudnn9.1-ubuntu22.04"
  ]
  args = {
    CUDA_VERSION = "12.4.1"
    CUDNN_VERSION = "9.1"
    UBUNTU_VERSION = "22.04"
  }
}

// CUDA 11.8
target "cuda-11-8" {
  inherits = ["common"]
  tags = [
    "${REGISTRY}4.3.1-py3.10.12-cuda11.8-cudnn8.9-ubuntu22.04"
  ]
  args = {
    CUDA_VERSION = "11.8.0"
    CUDNN_VERSION = "8.9"
    UBUNTU_VERSION = "22.04"
  }
}


// CUDA 12.9
target "cuda-12-9" {
  inherits = ["common"]
  tags = [
    "${REGISTRY}4.3.1-py3.10.12-cuda12.9-cudnn9.10-ubuntu22.04"
  ]
  args = {
    CUDA_VERSION = "12.9.1"
    CUDNN_VERSION = ""
    UBUNTU_VERSION = "22.04"
  }
}

// CUDA 13.0
target "cuda-13-0" {
  inherits = ["common"]
  tags = [
    "${REGISTRY}4.3.1-py3.10.12-cuda13.0-cudnn9.13-ubuntu22.04"
  ]
  args = {
    CUDA_VERSION = "13.0.1"
    CUDNN_VERSION = ""
    UBUNTU_VERSION = "22.04"
  }
}


// Default group that builds all versions
group "default" {
  targets = ["cuda-12-6", "cuda-12-4", "cuda-11-8", "cuda-12-9", "cuda-13-0"]
} 