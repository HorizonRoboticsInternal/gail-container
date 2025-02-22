# Copyright (c) 2023 Horizon Robotics. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# For lower nvidia driver <470
#ARG CUDA_BASE=nvidia/cuda:11.1.1-cudnn8-devel-ubuntu20.04
# For higher nvidia driver >=470
ARG CUDA_BASE=nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

######################## Build Vulkan #################################
# as vulkan-khronos
FROM ubuntu:22.04

ENV TZ=US/Pacific
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    git \
    libegl1-mesa-dev \
    libwayland-dev \
    libx11-xcb-dev \
    libxkbcommon-dev \
    libxrandr-dev \
    python3 \
    python3-distutils \
    curl wget && \
    rm -rf /var/lib/apt/lists/*

#ARG VULKAN_VERSION=sdk-1.1.121.0

# Download and compile vulkan components
#RUN ln -s /usr/bin/python3 /usr/bin/python && \
#    git clone https://github.com/KhronosGroup/Vulkan-ValidationLayers.git /opt/vulkan && \
#    cd /opt/vulkan && git checkout "${VULKAN_VERSION}" && \
#    mkdir build && cd build && ../scripts/update_deps.py && \
#    cmake -C helper.cmake -DCMAKE_BUILD_TYPE=Release .. && \
#    cmake --build . && make install && ldconfig && \
#    mkdir -p /usr/local/lib && cp -a Vulkan-Loader/build/install/lib/* /usr/local/lib && \
#    mkdir -p /usr/local/include/vulkan && cp -r Vulkan-Headers/build/install/include/vulkan/* /usr/local/include/vulkan && \
#    mkdir -p /usr/local/share/vulkan/registry && \
#    cp -r Vulkan-Headers/build/install/share/vulkan/registry/* /usr/local/share/vulkan/registry && \
#    rm -rf /opt/vulkan

FROM ${CUDA_BASE}

ENV TZ=US/Pacific
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV NVIDIA_DRIVER_CAPABILITIES compute,graphics,utility
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf \
    && echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf
ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/usr/lib/i386-linux-gnu:/usr/local/nvidia/lib:/usr/local/nvidia/lib64:/usr/local/nvidia/lib:/usr/local/nvidia/lib64

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
    libxrandr-dev \
    libegl1-mesa-dev

#COPY --from=vulkan-khronos /usr/local/bin /usr/local/bin
#COPY --from=vulkan-khronos /usr/local/lib /usr/local/lib
#COPY --from=vulkan-khronos /usr/local/include/vulkan /usr/local/include/vulkan
#COPY --from=vulkan-khronos /usr/local/share/vulkan /usr/local/share/vulkan
#COPY ./nvidia_icd.json /etc/vulkan/icd.d/nvidia_icd.json
COPY ./10_nvidia.json /usr/share/glvnd/egl_vendor.d/10_nvidia.json

######################## Hobot dependencies #####################
RUN apt update

RUN apt update && apt install -y --no-install-recommends \
    build-essential \
    vim tree curl wget unzip git cmake \
    libxml2 libxml2-dev libxslt1-dev libfreetype6-dev \
    dirmngr gnupg2 lsb-release \
    xvfb kmod swig patchelf ffmpeg rsync \
    libopenmpi-dev libcups2-dev libssl-dev \
    python3 python3-pip python3-dev python3-setuptools \
    libboost-all-dev

RUN python3 -m pip install --upgrade pip
RUN ln -sf /usr/bin/python3 /usr/bin/python \
    && ln -sf /usr/bin/python3.10 /usr/bin/python3

# for opencv
RUN apt-get install -y libglib2.0-0 libsm6 libxrender1 libxext6 libxext-dev

RUN pip install torch==2.1.1 torchvision==0.16.1 --extra-index-url https://download.pytorch.org/whl/cu118

# need the following for python-fcl in requiremeents.txt
RUN apt-get install -y liboctomap-dev libfcl-dev

# Install Rust and Cargo. Needed for building transformers from source
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

RUN pip install Cython==0.29.33

# Install pacakges from requirements.txt
COPY ./requirements.txt  /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

# Recent VLMs need up-to-date transformers repo, which in turn, needs
# at least python3.10.
RUN cd /opt/ && git clone https://github.com/huggingface/transformers.git \
    && cd transformers && pip install -e .
# make sure all other users can access this repo
RUN chmod -R a+rx /opt/transformers

# Test cnest
RUN pip --version
RUN python -c "import cnest"

RUN pip install --upgrade protobuf==3.20.1

# Enable EGL
ENV PYOPENGL_PLATFORM=egl
RUN python -c "from OpenGL.raw.EGL._types import *"
# Enable determinism for pytorch
ENV CUBLAS_WORKSPACE_CONFIG=:4096:8

# Clean up to make the resulting image smaller
RUN  rm -rf /var/lib/apt/lists/*
