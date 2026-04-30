ARG BASE_IMAGE
FROM ${BASE_IMAGE:?}

ENV TORCH_INDEX_URL=https://download.pytorch.org/whl/cu121

WORKDIR /workspace/audiocraft

RUN apt update -y && apt install git wget ffmpeg -y

ARG AUDIOCRAFT_VERSION
RUN git clone https://github.com/GrandaddyShmax/audiocraft_plus . && \
    git checkout tags/${AUDIOCRAFT_VERSION}

RUN python -m venv venv

RUN --mount=type=cache,target=/root/.cache/pip \
    . ./venv/bin/activate && \
    pip install --index-url "$TORCH_INDEX_URL" \
        torch==2.3.0 \
        torchvision==0.18.0 \
        torchaudio==2.3.0 && \
    pip install xformers==0.0.26.post1 jupyterlab

RUN --mount=type=cache,target=/root/.cache/pip \
    . ./venv/bin/activate && \
    pip install -r requirements.txt

COPY --chmod=755 scripts/* ./

RUN ./setup-ssh.sh

CMD ["/workspace/audiocraft/start.sh"]