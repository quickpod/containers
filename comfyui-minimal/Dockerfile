ARG BASE_IMAGE
FROM ${BASE_IMAGE:?}

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=all

RUN apt update -y && apt install git wget ffmpeg -y

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

COPY --chmod=755 scripts/* ./
RUN ./setup-ssh.sh

CMD ["/workspace/ComfyUI/start.sh"]