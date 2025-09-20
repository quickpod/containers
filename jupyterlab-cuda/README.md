# Python CUDA Docker Images

This repository contains Dockerfile and configuration for building Python CUDA images with different CUDA and cuDNN versions.

## Available Tags

- `4.3.1-py3.10.12-cuda12.6-cudnn9.5-ubuntu22.04` (Latest - 0.1.8)
- `4.3.1-py3.10.12-cuda12.4-cudnn9.1-ubuntu22.04`
- `4.3.1-py3.10.12-cuda11.8-cudnn8.9-ubuntu22.04`
- `4.3.1-py3.10.12-cuda12.9-cudnn9.10-ubuntu22.04`
- `4.3.1-py3.10.12-cuda13.0-cudnn9.13-ubuntu22.04`

## Building Images

This project uses Docker Bake for building images. The configuration is defined in `docker-bake.hcl`.

### Prerequisites

- Docker with BuildKit support
- Docker Bake

### Build Commands

Build all variants:
```bash
docker buildx bake
```

Build specific variant:
```bash
# For CUDA 12.6 with cuDNN (Latest - 0.1.8)
docker buildx bake cuda-12-6-cudnn

# For CUDA 12.4
docker buildx bake cuda-12-4

# For CUDA 11.8
docker buildx bake cuda-11-8

# For Cuda 12.9
docker buildx bake cuda-12-9

# For Cuda 13.0
docker buildx bake cuda-13-0
```

The images will be built with the name `quickpod/jupyterlab` and appropriate tags as listed above.
