# Docker image for Bark
- 14.29 GB (compressed)
- Models are already downloaded

## Ports

- 7860: Bark WebUI
- 8888: Jupyterlab
- 22: SSH

## Usage

```bash
docker run -d \
  --gpus all \
  -p 22:22 \
  -p 7860:7860 \
  -p 8888:8888 \
  quickpod/bark:latest
```

## Build

```bash
docker buildx bake
docker buildx bake --push
```