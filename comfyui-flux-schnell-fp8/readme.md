# ComfyUI Flux Dev FP8 Docker
- 15.57 GB (compressed)
- ComfyUI manager installed
- Flux FP8 model installed

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
  quickpod/comfyui:flux-schnell-fp8
```