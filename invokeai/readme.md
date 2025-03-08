# Invoke AI Docker
- 3.98 GB
- No models included

## Ports
- 9090: InvokeAI
- 8888: Jupyterlab
- 22: SSH

## Usage

```bash
docker run -d \
  --gpus all \
  -p 22:22 \
  -p 9090:9090 \
  -p 8888:8888 \
  yuvraj108c/invokeai:latest
```

## Build

```bash
docker buildx bake
```
