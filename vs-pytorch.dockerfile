FROM ubuntu:22.04

# Set the working directory
WORKDIR /workspace

# Set environment variables to avoid user interaction during the installation process
ENV DEBIAN_FRONTEND=noninteractive

###
# prepare environment
###

RUN apt update && apt upgrade -y

# Install Python versions and pip
RUN apt install -y \
    python3.10 \
    python3.10-venv \
    python3.10-dev \
    python3-pip \
    python-is-python3

RUN apt install -y \
    libgl1-mesa-glx \
    curl \
    wget \
    make \
    cmake \
    libssl-dev \
    libffi-dev \
    libopenblas-dev \
    git

###
# Install compilers and build tools
###

# from https://github.com/styler00dollar/VSGAN-tensorrt-docker/blob/main/Dockerfile#L382
RUN apt install autoconf libtool nasm ninja-build yasm pkg-config -y

RUN apt --fix-broken install

RUN pip install meson ninja cython

# install g++13
RUN apt install build-essential manpages-dev software-properties-common -y
RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y
RUN apt update -y && apt install gcc-13 g++-13 -y
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 13
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 13

# install checkinstall
RUN apt install checkinstall -y

###
# Install VapourSynth
###

# zimg
# setting pkg version manually since otherwise 'Version' field value '-1': version number is empty
RUN git clone https://github.com/sekrit-twc/zimg --recursive && cd zimg && \
  ./autogen.sh && ./configure && make -j$(nproc) && make install
RUN cd zimg && checkinstall -y -pkgversion=0.0 && apt install /workspace/zimg/zimg_0.0-1_amd64.deb -y

### Install VapourSynth
ARG VAPOURSYNTH_VERSION=R70
RUN wget https://github.com/vapoursynth/vapoursynth/archive/refs/tags/${VAPOURSYNTH_VERSION}.tar.gz && \
  tar -zxvf ${VAPOURSYNTH_VERSION}.tar.gz && mv vapoursynth-${VAPOURSYNTH_VERSION} vapoursynth && cd vapoursynth && \
  ./autogen.sh && ./configure && make -j$(nproc) && make install && ldconfig

###
# Install FFmpeg with Encoders
###

# dav1d
RUN git clone https://code.videolan.org/videolan/dav1d/ && \
  cd dav1d && meson build --buildtype release -Ddefault_library=static && ninja -C build install

# Vulkan-Headers
RUN git clone https://github.com/KhronosGroup/Vulkan-Headers.git && cd Vulkan-Headers/ && cmake -S . -DBUILD_SHARED_LIBS=OFF -B build/ && cmake --install build

# nv-codec-headers
RUN git clone https://github.com/FFmpeg/nv-codec-headers && cd nv-codec-headers && make -j$(nproc) && make install

# FFmpeg
RUN git clone https://github.com/FFmpeg/FFmpeg --depth 1 && cd FFmpeg && \
  CFLAGS=-fPIC ./configure --enable-libdav1d --enable-cuda --enable-nonfree --disable-shared --enable-static --enable-gpl --enable-version3 --disable-doc --enable-pic --extra-ldflags="-static" --extra-cflags="-march=native" && \
  make -j$(nproc) && make install -j$(nproc)

# override ffmpeg and ffprobe with static builds, lol
COPY --from=mwader/static-ffmpeg:7.1 /ffmpeg /usr/local/bin/
COPY --from=mwader/static-ffmpeg:7.1 /ffprobe /usr/local/bin/

###
# Install VapourSynth C++ plugins
###

# jansson
RUN git clone https://github.com/akheron/jansson && cd jansson && autoreconf -fi && CFLAGS=-fPIC ./configure --disable-shared --enable-static && \
  make -j$(nproc) && make install

# bzip2
RUN git clone https://github.com/libarchive/bzip2 && cd bzip2 && \
  mkdir build && cd build && cmake .. -DBUILD_SHARED_LIBS=OFF && make -j$(nproc) && make install

# bestsource
RUN apt install libxxhash-dev -y
RUN git clone https://github.com/vapoursynth/bestsource.git --depth 1 --recurse-submodules --shallow-submodules --remote-submodules && cd bestsource && \
  CFLAGS=-fPIC meson setup -Denable_plugin=true build && CFLAGS=-fPIC ninja -C build && ninja -C build install

# ffms2
RUN apt install autoconf -y
RUN git clone https://github.com/FFMS/ffms2 && cd ffms2 && ./autogen.sh && CFLAGS=-fPIC CXXFLAGS=-fPIC LDFLAGS="-Wl,-Bsymbolic" ./configure --enable-shared && make -j$(nproc) && make install

# fmtconv
RUN git clone https://github.com/EleonoreMizo/fmtconv && cd fmtconv/build/unix/ && ./autogen.sh && ./configure && make -j$(nproc) && make install

###
# Install VapourSynth Python plugins
###

# install vapoursynth
RUN cd vapoursynth && python setup.py install

# install python packages with specific versions!!!
RUN pip install numpy==1.26.4
RUN pip install opencv-python-headless==4.10.0.82

# install other vs plugins
RUN pip install git+https://github.com/HomeOfVapourSynthEvolution/mvsfunc.git
RUN pip install vsutil==0.8.0
RUN pip install git+https://github.com/HomeOfVapourSynthEvolution/havsfunc.git

# install PyTorch
RUN pip install torch==2.1.2 torchvision==0.16.2 torchaudio==2.1.2 --index-url https://download.pytorch.org/whl/cu121

# install CuPy
RUN pip install cupy-cuda12x

# install TensoRaws's packages
RUN pip install mbfunc==0.0.2
RUN pip install ccrestoration==0.2.1
RUN pip install ccvfi==0.0.1

RUN ls /usr/local/lib
RUN ls /usr/local/include
