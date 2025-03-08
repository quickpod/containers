# Docker image for Audiocraft
- 3.58 GB (compressed)
- No models

## Ports

- 7860: Audiocraft Plus
- 8888: Jupyterlab
- 22: SSH

## Usage

```bash
docker run -d \
  --gpus all \
  -p 22:22 \
  -p 7860:7860 \
  -p 8888:8888 \
  quickpod/audiocraft-plus:latest
```

## Build

```bash
docker buildx bake
docker buildx bake --push
```