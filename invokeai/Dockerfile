ARG BASE_IMAGE
FROM ${BASE_IMAGE:?}

WORKDIR /workspace/invokeai

RUN apt update -y && apt install git wget curl libgl1 libglib2.0-0 -y

ARG INVOKEAI_VERSION
RUN git clone https://github.com/invoke-ai/InvokeAI .
RUN git checkout v${INVOKEAI_VERSION}

# Install dependencies
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m venv ./venv && \
    . ./venv/bin/activate && \
    pip install InvokeAI jupyterlab
    
COPY invokeai.yaml .

COPY --chmod=755 scripts/* ./

RUN ./setup-ssh.sh

CMD ["/workspace/invokeai/start.sh"]