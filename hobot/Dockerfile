FROM ubuntu:24.04
# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

ENV TZ=US/Pacific
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV NVIDIA_DRIVER_CAPABILITIES compute,graphics,utility
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf \
    && echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf
ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/usr/lib/i386-linux-gnu:/usr/local/nvidia/lib:/usr/local/nvidia/lib64:/usr/local/nvidia/lib:/usr/local/nvidia/lib64

# Install GPU libraries and dependencies
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y --no-install-recommends \
    libxau6 libxau6:i386 \
    libxdmcp6 libxdmcp6:i386 \
    libxcb1 libxcb1:i386 \
    libxext6 libxext6:i386 \
    libx11-6 libx11-6:i386 \
    libglvnd0 libglvnd0:i386 \
    libgl1 libgl1:i386 \
    libglx0 libglx0:i386 \
    libegl1 libegl1:i386 \
    libgles2 libgles2:i386 \
    pkg-config \
    libglvnd-dev libglvnd-dev:i386 \
    libgl1-mesa-dev libgl1-mesa-dev:i386 \
    libegl1-mesa-dev libegl1-mesa-dev:i386 \
    libgles2-mesa-dev libgles2-mesa-dev:i386 \
    libx11-xcb-dev \
    libxkbcommon-dev \
    libwayland-dev \
    libxrandr-dev

COPY ./10_nvidia.json /usr/share/glvnd/egl_vendor.d/10_nvidia.json

# Install build tools and Python dependencies
RUN apt update && apt install -y --no-install-recommends \
    build-essential \
    vim tree curl wget unzip git cmake \
    libxml2 libxml2-dev libxslt1-dev libfreetype6-dev \
    dirmngr gnupg2 lsb-release \
    xvfb kmod swig patchelf ffmpeg rsync \
    libopenmpi-dev libcups2-dev libssl-dev \
    python3 python3-pip python3-dev python3-setuptools python3-venv \
    libboost-all-dev \
    libosmesa6-dev \
    libglib2.0-0 \
    libxrender1 \
    libglew-dev \
    xpra \
    libglfw3-dev \
    pybind11-dev \
    libeigen3-dev \
    liboctomap-dev \
    libfcl-dev \
    libjpeg-dev \
    gnupg \
    ca-certificates \
    libsm6 libxext6 libxext-dev ninja-build

# Install Google Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /usr/share/keyrings/google-chrome.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable

# Make Python 3 the default
RUN ln -sf /usr/bin/python3 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip

# Create a working directory for the mounted volume
WORKDIR /app
RUN python3.12 -m venv /app/venv

# Need to run umask 0000 so relax permissions for venv so that Hobot can pip install kincpp and ManiSkill

RUN umask 0000 && /app/venv/bin/pip install --upgrade pip

# Install torch 2.6 + cuda 11.8
RUN umask 0000 && /app/venv/bin/pip install torch==2.6.0 torchvision --index-url https://download.pytorch.org/whl/cu118

# Install all pip dependencies
COPY requirements.txt /app/
RUN umask 0000 && /app/venv/bin/pip install wheel
RUN umask 0000 && /app/venv/bin/pip install -r /app/requirements.txt

# Check for PyTorch with CUDA 11.8
RUN /app/venv/bin/python -c "import torch; import sys; version = torch.__version__; assert '+cu118' in version, f'Expected PyTorch with CUDA 11.8 (+cu118 suffix), but got version {version}'; sys.exit(0)"

ENV PYOPENGL_PLATFORM=egl
ENV CUBLAS_WORKSPACE_CONFIG=:4096:8

# Clean up to make the resulting image smaller
RUN rm -rf /var/lib/apt/lists/*

# Setup the venv
ENV PATH="/app/venv/bin:$PATH"
ENV VIRTUAL_ENV="/app/venv"

# Point to ManiSkill asset directory
ENV MS_ASSET_DIR="/data"
