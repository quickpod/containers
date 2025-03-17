ARG BASE_IMAGE

FROM $BASE_IMAGE

WORKDIR /workspace/stable-audio-1

RUN apt-get update && apt-get install git wget libsndfile1 ffmpeg aria2 -y

# Install dependencies
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m venv ./venv && \
    . ./venv/bin/activate && \
    pip install torch torchvision gradio==3.50.2 jupyterlab stable-audio-tools==0.0.16

# Model
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M "https://huggingface.co/audo/stable-audio-open-1.0/resolve/main/model.safetensors" -d "./" -o "model.safetensors"
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M "https://huggingface.co/audo/stable-audio-open-1.0/resolve/main/model_config.json" -d "./" -o "model_config.json"

# T5
RUN . ./venv/bin/activate && \
    huggingface-cli download google-t5/t5-base config.json model.safetensors spiece.model tokenizer.json && \
    mv /root/.cache/huggingface/hub/models--google-t5--t5-base /root/.cache/huggingface/hub/models--t5-base

COPY --chmod=755 scripts/* ./
RUN ./setup-ssh.sh

CMD ["/workspace/stable-audio-1/start.sh"]
