ARG BASE_IMAGE
FROM ${BASE_IMAGE:?}

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=all

RUN apt update -y && apt install git wget aria2 ffmpeg -y

ARG COMFYUI_VERSION
WORKDIR /workspace/ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI .

RUN git checkout v${COMFYUI_VERSION}

# comfyui requirements
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m venv ./venv && \
    . ./venv/bin/activate && \
    pip install -r requirements.txt && \
    pip install jupyterlab

# comfyui manager
RUN --mount=type=cache,target=/root/.cache/pip \
    . ./venv/bin/activate && \
    git -C ./custom_nodes clone https://github.com/ltdrdata/ComfyUI-Manager.git && \
    cd custom_nodes/ComfyUI-Manager && pip install -r requirements.txt

# models
RUN ls
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M "https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/flux1-schnell.safetensors" -d "models/unet" -o "flux1-schnell.safetensors"
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors" -d "models/text_encoders" -o "t5xxl_fp16.safetensors"
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors" -d "models/text_encoders" -o "clip_l.safetensors"
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M "https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/ae.safetensors" -d "models/vae" -o "ae.safetensors"

COPY --chmod=755 scripts/* ./

# set default workflow
RUN mkdir -p ./user/default/workflows
COPY workflows/* ./user/default/workflows
RUN echo '{"Comfy.TutorialCompleted": true}' > ./user/default/comfy.settings.json
RUN python setup-default-workflow.py --workflow-path "./user/default/workflows/flux-schnell-fp16-workflow.json" --workflow-name "flux-schnell-fp16-workflow.json" --workflow-index 1 --html-path "./venv/lib/python3.10/site-packages/comfyui_frontend_package/static/index.html"

RUN ./setup-ssh.sh

CMD ["/workspace/ComfyUI/start.sh"]