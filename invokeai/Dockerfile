ARG BASE_IMAGE
ARG INVOKEAI_VERSION

FROM ${BASE_IMAGE:?} AS source

ARG INVOKEAI_VERSION

WORKDIR /workspace/invokeai

RUN apt update -y && apt install git -y

RUN git clone https://github.com/invoke-ai/InvokeAI .
RUN git checkout v${INVOKEAI_VERSION}

FROM node:22-slim AS web-builder

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN corepack use pnpm@10.x && corepack enable

WORKDIR /build

COPY --from=source /workspace/invokeai/invokeai/frontend/web/ ./

RUN --mount=type=cache,target=/pnpm/store \
    pnpm install --frozen-lockfile && \
    pnpm build

FROM ${BASE_IMAGE:?}

WORKDIR /workspace/invokeai

RUN apt update -y && apt install git wget curl libgl1 libglib2.0-0 gcc build-essential -y

COPY --from=source /workspace/invokeai/ ./
COPY --from=web-builder /build/dist ./invokeai/frontend/web/dist

# Install dependencies
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m venv ./venv && \
    . ./venv/bin/activate && \
    pip install . jupyterlab
    
COPY invokeai.yaml .

COPY --chmod=+x scripts/* ./

RUN bash ./setup-ssh.sh

CMD ["/workspace/invokeai/start.sh"]