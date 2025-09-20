# 12.4.1 4.3.1-py3.10.12-cuda12.4-cudnn9.1-ubuntu22.04
# 12.6.2 4.3.1-py3.10.12-cuda12.6-cudnn9.5-ubuntu22.04
# 11.8.0 4.3.1-py3.10.12-cuda11.8-cudnn8.9-ubuntu22.04
ARG CUDA_VERSION="12.6.2"
ARG CUDNN_VERSION=""
ARG UBUNTU_VERSION="22.04"
ARG DOCKER_FROM=nvidia/cuda:${CUDA_VERSION}${CUDNN_VERSION:+-cudnn$CUDNN_VERSION}-devel-ubuntu${UBUNTU_VERSION}

# Base NVidia CUDA Ubuntu image
FROM $DOCKER_FROM AS base

# Set non-interactive frontend for apt-get
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York
ENV DISPLAY=:0
ENV PIP_ROOT_USER_ACTION=ignore

# Add environment variables to .bashrc
RUN echo "export DEBIAN_FRONTEND=noninteractive" >> /root/.bashrc && \
    echo "export TZ=America/New_York" >> /root/.bashrc && \
    echo "export DISPLAY=:0" >> /root/.bashrc && \
    echo "export PIP_ROOT_USER_ACTION=ignore" >> /root/.bashrc

# Install Python, openssh, and FFmpeg development libraries
RUN apt-get update -y && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt-get install -y python3 python3-pip python3-venv && \
    apt-get install -y --no-install-recommends openssh-server openssh-client git git-lfs wget vim dos2unix curl zip unzip rsync p7zip-full && \
    apt-get install -y software-properties-common && \
    apt-get install -y \
        apt-utils \
        python3-tk \
        psmisc \
        build-essential \
        gcc \
        g++ \
        gdb \
        cmake \
        ffmpeg \
        libx264-dev \
        libx265-dev \
        libnuma-dev \
        libvpx-dev \
        libfdk-aac-dev \
        libmp3lame-dev \
        libopus-dev \
        libass-dev \
        libfreetype6-dev \
        libfontconfig1-dev \
        google-perftools \
        libgoogle-perftools-dev \
        xdg-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a dummy x-www-browser to suppress xdg-open warnings
RUN ln -s /usr/bin/true /usr/bin/x-www-browser

# Add tcmalloc as default memory allocator
ENV LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libtcmalloc.so.4"

# Create symbolic links for python3 and pip3
RUN ln -s /usr/bin/python3 /usr/local/bin/python
    
ENV PATH="/usr/local/cuda/bin:${PATH}"

# Create symbolic link for nvcc
RUN echo "PATH=/usr/local/cuda/bin:${PATH}" >> /etc/environment && \
    ln -s /usr/local/cuda/bin/nvcc /usr/bin/nvcc

# Copy and convert start-ssh-only.sh
COPY --chmod=755 start-ssh-only.sh /start.sh
RUN dos2unix /start.sh

# Set up workspace and run initialization script
WORKDIR /workspace
# Set root password and grant sudo rights
RUN echo "root:root" | chpasswd && \
    echo "ALL ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Add Jupyter Notebook with root privileges
RUN pip3 install jupyterlab
    
EXPOSE 8888

# Ensure we run everything as root
USER root

CMD [ "/start.sh" ]

