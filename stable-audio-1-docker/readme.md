# Stable Audio 1 Docker
- 8.18 GB (compressed)
- Models included

## Ports
- 7860: Stable Audio 1 Gradio
- 8888: Jupyterlab
- 22: SSH

## Usage

```bash
docker run -d \
  --gpus all \
  -p 22:22 \
  -p 7860:7860 \
  -p 8888:8888 \
  quickpod/stable-audio-1:latest
```