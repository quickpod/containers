# Android Emulator Docker Image
# Provides a headless Android emulator accessible via ADB and noVNC for visual access
ARG UBUNTU_VERSION="22.04"
FROM ubuntu:${UBUNTU_VERSION} AS base

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin

# Android SDK configuration
ARG API_LEVEL=34
ARG BUILD_TOOLS_VERSION=34.0.0
ARG EMULATOR_DEVICE="pixel_6"
ARG EMULATOR_NAME="quickpod_device"

ENV API_LEVEL=${API_LEVEL}
ENV BUILD_TOOLS_VERSION=${BUILD_TOOLS_VERSION}
ENV EMULATOR_DEVICE=${EMULATOR_DEVICE}
ENV EMULATOR_NAME=${EMULATOR_NAME}

# Force emulator to use IPv4 (avoids ::1 modem connection failures in containers)
ENV ANDROID_EMULATOR_WAIT_TIME_BEFORE_KILL=2
ENV ANDROID_AVD_HOME=/root/.android/avd

# Install system dependencies
RUN apt-get update -y && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt-get install -y --no-install-recommends \
        openssh-server openssh-client openssl \
        git wget curl zip unzip \
        openjdk-17-jdk-headless \
        # Display/VNC dependencies
        xvfb x11vnc novnc websockify \
        libx11-6 libxcb1 libxext6 libxrender1 libxi6 \
        libgl1-mesa-glx libgl1-mesa-dri libegl1 \
        libpulse0 libglu1-mesa \
        # Misc utilities
        supervisor socat net-tools \
        qemu-kvm libvirt-daemon-system cpu-checker && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Android command-line tools
RUN mkdir -p $ANDROID_HOME/cmdline-tools && \
    cd /tmp && \
    wget -q "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip" -O cmdline-tools.zip && \
    unzip -q cmdline-tools.zip && \
    mv cmdline-tools $ANDROID_HOME/cmdline-tools/latest && \
    rm cmdline-tools.zip

# Accept licenses and install SDK components
RUN yes | sdkmanager --licenses > /dev/null 2>&1 && \
    sdkmanager \
        "platform-tools" \
        "platforms;android-${API_LEVEL}" \
        "build-tools;${BUILD_TOOLS_VERSION}" \
        "emulator" \
        "system-images;android-${API_LEVEL};google_apis;x86_64"

# Create AVD
RUN echo "no" | avdmanager create avd \
        --name "${EMULATOR_NAME}" \
        --package "system-images;android-${API_LEVEL};google_apis;x86_64" \
        --device "${EMULATOR_DEVICE}" \
        --force && \
    # Configure AVD for better headless performance
    mkdir -p /root/.android && \
    echo "hw.ramSize=2048" >> /root/.android/avd/${EMULATOR_NAME}.avd/config.ini && \
    echo "hw.gpu.enabled=yes" >> /root/.android/avd/${EMULATOR_NAME}.avd/config.ini && \
    echo "hw.gpu.mode=swiftshader_indirect" >> /root/.android/avd/${EMULATOR_NAME}.avd/config.ini && \
    echo "disk.dataPartition.size=4096M" >> /root/.android/avd/${EMULATOR_NAME}.avd/config.ini && \
    echo "hw.keyboard=yes" >> /root/.android/avd/${EMULATOR_NAME}.avd/config.ini && \
    echo "hw.gsmModem=no" >> /root/.android/avd/${EMULATOR_NAME}.avd/config.ini && \
    echo "hw.mainKeys=no" >> /root/.android/avd/${EMULATOR_NAME}.avd/config.ini

# Set up noVNC for browser-based access
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# SSH configuration
RUN mkdir -p /var/run/sshd && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

# Note: IPv6 loopback (::1) is added at runtime in start.sh
# because Docker overwrites /etc/hosts at container start

# Expose ports:
#   5554/5555 - emulator console/adb
#   5037      - adb server
#   6080      - noVNC web access
#   22        - SSH
EXPOSE 5554 5555 5037 6080 22

COPY start.sh /start.sh
RUN chmod +x /start.sh

COPY supervisord.conf /etc/supervisor/conf.d/emulator.conf

CMD ["/start.sh"]
