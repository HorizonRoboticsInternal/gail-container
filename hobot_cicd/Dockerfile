# Copyright (c) 2019 Horizon Robotics. All Rights Reserved.
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

FROM ubuntu:22.04

RUN apt update

# Prepare the global python environment
RUN apt install -y python3
RUN ln -sf /usr/bin/python3 /usr/bin/python
RUN apt install -y pip
RUN apt install -y libboost-all-dev libglu1 ffmpeg

# for opencv
RUN apt-get install -y libglib2.0-0 libsm6 libxrender1 libxext6

# Install other tools
RUN apt install -y \
    curl \
    wget \
    git \
    libsm6  \
    libxext-dev \
    libxrender1 \
    unzip \
    cmake \
    libxml2 libxml2-dev libxslt1-dev \
    dirmngr gnupg2 lsb-release \
    xvfb kmod swig patchelf \
    libopenmpi-dev  libcups2-dev \
    libssl-dev  libosmesa6-dev \
    mesa-utils

RUN apt-get install -y liboctomap-dev libfcl-dev

# Clean up to make the resulting image smaller
RUN  rm -rf /var/lib/apt/lists/*

# For some reason, we need to manually delete the existing old setuptools version
RUN rm -rf /usr/lib/python3/dist-packages/setuptools*
RUN pip install setuptools==63.1.0

# Install pacakges from requirements.txt
COPY ./requirements.txt  /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt \
    --extra-index-url https://download.pytorch.org/whl/cpu

RUN pip install --upgrade protobuf==3.20.1

RUN apt install -y clang-format
