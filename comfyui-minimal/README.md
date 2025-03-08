# ComfyUI Minimal Docker
- 3.55 GB (compressed)
- Comes with manager installed
- No other models/custom nodes

## Ports
- 8188: Comfyui + manager
- 8888: Jupyterlab
- 22: SSH

## Usage

```bash
docker run -d \
  --gpus all \
  -p 22:22 \
  -p 8188:8188 \
  -p 8888:8888 \
  quickpod/comfyui:minimal
```

## Build

```bash
docker buildx bake
docker buildx bake --push
```
