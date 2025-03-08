# Fooocus Docker
- 9.96 GB (compressed)

## Models
- [juggernautXL_v8Rundiffusion](https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_offset_example-lora_1.0.safetensors)	
- [fooocus_expansion](https://huggingface.co/lllyasviel/misc/resolve/main/fooocus_expansion.bin)	

## Ports
- 7860: Fooocus
- 8888: Jupyterlab
- 22: SSH

## Usage

```bash
docker run -d \
  --gpus all \
  -p 22:22 \
  -p 7860:7860 \
  -p 8888:8888 \
  yuvraj108c/fooocus:latest
```

## Build

```bash
docker buildx bake
docker buildx bake --push
```
