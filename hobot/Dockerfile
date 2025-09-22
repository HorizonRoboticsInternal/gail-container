FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

# Environment setup
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=US/Pacific \
    NVIDIA_DRIVER_CAPABILITIES=compute,graphics,utility \
    LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/usr/lib/i386-linux-gnu:/usr/local/nvidia/lib:/usr/local/nvidia/lib64 \
    PYOPENGL_PLATFORM=egl \
    CUBLAS_WORKSPACE_CONFIG=:4096:8 \
    MS_ASSET_DIR=/data/.maniskill \
    PATH="/app/venv/bin:$PATH" \
    VIRTUAL_ENV="/app/venv"

# Combined system setup and package installation
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        # GPU libraries
        libxau6 libxau6:i386 libxdmcp6 libxdmcp6:i386 libxcb1 libxcb1:i386 \
        libxext6 libxext6:i386 libx11-6 libx11-6:i386 libglvnd0 libglvnd0:i386 \
        libgl1 libgl1:i386 libglx0 libglx0:i386 libegl1 libegl1:i386 \
        libgles2 libgles2:i386 pkg-config libglvnd-dev libglvnd-dev:i386 \
        libgl1-mesa-dev libgl1-mesa-dev:i386 libegl1-mesa-dev libegl1-mesa-dev:i386 \
        libgles2-mesa-dev libgles2-mesa-dev:i386 libx11-xcb-dev libxkbcommon-dev \
        libwayland-dev libxrandr-dev libvulkan1 \
        # Build tools and dependencies
        build-essential vim tree curl wget unzip git cmake \
        libxml2 libxml2-dev libxslt1-dev libfreetype6-dev \
        dirmngr gnupg2 lsb-release xvfb kmod swig patchelf ffmpeg rsync \
        libopenmpi-dev libcups2-dev libssl-dev \
        python3 python3-pip python3-dev python3-setuptools python3-venv \
        libboost-all-dev libosmesa6-dev libglib2.0-0 libxrender1 \
        libglew-dev xpra libglfw3-dev pybind11-dev libeigen3-dev \
        liboctomap-dev libfcl-dev libjpeg-dev gnupg ca-certificates \
        libsm6 libxext6 libxext-dev ninja-build && \
    # Install Google Chrome
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /usr/share/keyrings/google-chrome.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y google-chrome-stable && \
    # Make Python 3 the default
    ln -sf /usr/bin/python3 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip && \
    # Cleanup
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy GPU configuration files
COPY ./10_nvidia.json /usr/share/glvnd/egl_vendor.d/10_nvidia.json
COPY ./nvidia_icd.json /usr/share/vulkan/icd.d/nvidia_icd.json
COPY ./nvidia_layers.json /etc/vulkan/implicit_layer.d/nvidia_layers.json

# Create working directory and Python environment
WORKDIR /app

# Copy requirements first for better layer caching
COPY requirements.txt /app/

# Create venv and install all Python packages in one layer
RUN umask 0000 && \
    python3.10 -m venv /app/venv && \
    /app/venv/bin/pip install --upgrade pip wheel setuptools packaging && \
    /app/venv/bin/pip install torch==2.6.0 torchvision --index-url https://download.pytorch.org/whl/cu124 && \
    /app/venv/bin/pip install -r /app/requirements.txt && \
    /app/venv/bin/python -c "import torch; import sys; version = torch.__version__; assert '+cu124' in version, f'Expected PyTorch with CUDA 12.4 (+cu124 suffix), but got version {version}'; sys.exit(0)" && \
    # Kaolin is required for EmbodiedGen and should be installed after torch
    /app/venv/bin/pip install kaolin==0.18.0 -f https://nvidia-kaolin.s3.us-east-2.amazonaws.com/torch-2.6.0_cu124.html && \
    chmod -R 777 /app/venv && \
    # Cleanup pip cache and temporary files
    /app/venv/bin/pip cache purge && \
    find /app/venv -name "*.pyc" -delete && \
    find /app/venv -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
