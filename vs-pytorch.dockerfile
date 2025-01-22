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

# -O3 makes sure we compile with optimization. setting CFLAGS/CXXFLAGS seems to override
# default automake cflags.
# -static-libgcc is needed to make gcc not include gcc_s as "as-needed" shared library which
# cmake will include as a implicit library.
# other options to get hardened build (same as ffmpeg hardened)
ARG CFLAGS="-O3 -static-libgcc -fno-strict-overflow -fstack-protector-all -fPIE"
ARG CXXFLAGS="-O3 -static-libgcc -fno-strict-overflow -fstack-protector-all -fPIE"
ARG LDFLAGS="-Wl,-z,relro,-z,now"

# Vulkan-Headers
RUN git clone https://github.com/KhronosGroup/Vulkan-Headers.git --depth 1 && \
  cd Vulkan-Headers/ && cmake -S . -B build/ && cmake --install build

# nv-codec-headers
RUN git clone https://github.com/FFmpeg/nv-codec-headers --depth 1 && \
  cd nv-codec-headers && make -j$(nproc) && make install

RUN git clone https://github.com/gypified/libmp3lame --depth 1 && \
  cd libmp3lame && ./configure --enable-nasm --enable-static && make -j$(nproc) install

RUN git clone https://github.com/mstorsjo/fdk-aac --depth 1 && \
  cd fdk-aac && ./autogen.sh && ./configure --enable-static && make -j$(nproc) install

RUN git clone https://github.com/xiph/ogg --depth 1 && \
  cd ogg && ./autogen.sh && ./configure --enable-static && make -j$(nproc) install

RUN git clone https://github.com/xiph/vorbis --depth 1 && \
  cd vorbis && ./autogen.sh && ./configure --enable-static && make -j$(nproc) install

RUN git clone https://github.com/xiph/opus --depth 1 && \
  cd opus && ./autogen.sh && ./configure --enable-static && make -j$(nproc) install

RUN git clone https://github.com/xiph/theora --depth 1 && \
  cd theora && ./autogen.sh && ./configure --disable-examples --enable-static && make -j$(nproc) install

RUN git clone https://github.com/webmproject/libvpx --depth 1 && \
  cd libvpx && ./configure --enable-vp9-highbitdepth --disable-unit-tests --disable-examples --enable-static && \
  make -j$(nproc) install

RUN git clone https://code.videolan.org/videolan/x264.git --depth 1 && \
  cd x264 && ./configure --enable-pic --enable-static && make -j$(nproc) install

ARG X265_VERSION=4.1
ARG X265_URL="https://bitbucket.org/multicoreware/x265_git/downloads/x265_$X265_VERSION.tar.gz"
# CMAKEFLAGS issue
# https://bitbucket.org/multicoreware/x265_git/issues/620/support-passing-cmake-flags-to-multilibsh
RUN \
  wget -O x265_git.tar.bz2 "$X265_URL" && \
  tar xf x265_git.tar.bz2 && cd x265_*/build/linux && \
  cmake ../../source -G "Unix Makefiles" \
    -DHIGH_BIT_DEPTH=ON \
    -DEXPORT_C_API=ON \
    -DENABLE_SHARED=ON \
    -DENABLE_CLI=ON \
    -DENABLE_NASM=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DENABLE_AGGRESSIVE_CHECKS=ON && \
  make -j$(nproc) install

RUN git clone https://github.com/webmproject/libwebp --depth 1 && \
  cd libwebp && ./autogen.sh && ./configure --enable-static && make -j$(nproc) install

RUN git clone https://github.com/xiph/speex --depth 1 && \
  cd speex && ./autogen.sh && ./configure --enable-static && make -j$(nproc) install

RUN git clone --depth 1 https://aomedia.googlesource.com/aom --depth 1 && \
  cd aom && \
  mkdir build_tmp && cd build_tmp && cmake -DENABLE_TESTS=0 -DENABLE_NASM=on -DCMAKE_INSTALL_LIBDIR=lib .. && make -j$(nproc) install

RUN git clone https://github.com/georgmartius/vid.stab --depth 1 && \
  cd vid.stab && cmake . && make -j$(nproc) install

RUN git clone https://github.com/ultravideo/kvazaar --depth 1 && \
  cd kvazaar && ./autogen.sh && ./configure --enable-static && make -j$(nproc) install

# dependencies for libass and ffmpeg
RUN apt install libfreetype-dev libfribidi-dev libfontconfig-dev -y
# dependencies for libass
RUN apt install libharfbuzz-dev libunibreak-dev -y
# libass
RUN git clone https://github.com/libass/libass --depth 1 && \
  cd libass && ./autogen.sh && ./configure --enable-static && make -j$(nproc) && make install

RUN git clone https://github.com/uclouvain/openjpeg --depth 1 && \
  cd openjpeg && cmake -G "Unix Makefiles" && make -j$(nproc) install

RUN git clone https://code.videolan.org/videolan/dav1d --depth 1 && \
  cd dav1d && meson build --buildtype release -Ddefault_library=static && ninja -C build install

# add extra CFLAGS that are not enabled by -O3
# http://websvn.xvid.org/cvs/viewvc.cgi/trunk/xvidcore/build/generic/configure.in?revision=2146&view=markup
ARG XVID_VERSION=1.3.7
ARG XVID_URL="https://downloads.xvid.com/downloads/xvidcore-$XVID_VERSION.tar.gz"
ARG XVID_SHA256=abbdcbd39555691dd1c9b4d08f0a031376a3b211652c0d8b3b8aa9be1303ce2d
RUN wget -O libxvid.tar.gz "$XVID_URL" && \
  echo "$XVID_SHA256  libxvid.tar.gz" | sha256sum --status -c - && \
  tar xf libxvid.tar.gz && \
  cd xvidcore/build/generic && \
  CFLAGS="$CFLAGS -fstrength-reduce -ffast-math" \
    ./configure && make -j$(nproc) && make install

# configure use tcl sh
RUN apt install tcl -y
RUN git clone https://github.com/Haivision/srt --depth 1 && \
  cd srt && ./configure --cmake-install-libdir=lib --cmake-install-includedir=include --cmake-install-bindir=bin && \
  make -j$(nproc) && make install

RUN git clone https://github.com/gianni-rosato/svt-av1-psy --depth 1 && \
  cd svt-av1-psy/Build && \
    cmake \
    -G"Unix Makefiles" \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    .. && \
    make -j$(nproc) install

RUN git clone https://github.com/pkuvcl/davs2 --depth 1 && \
  cd davs2/build/linux && ./configure --disable-asm --enable-pic && \
  make -j$(nproc) install

RUN git clone https://github.com/Netflix/vmaf --depth 1 && \
  cd vmaf/libvmaf && meson build --buildtype release && ninja -vC build install

RUN git clone https://github.com/cisco/openh264 --depth 1 && \
  cd openh264 && meson build --buildtype release && ninja -C build install

RUN git clone https://github.com/mpeg5/xeve && \
  cd xeve && mkdir build && cd build && cmake .. && make -j$(nproc) && make install

# dependencies for ffmpeg
RUN apt install libsoxr-dev libxml2-dev -y
RUN git clone https://github.com/FFmpeg/FFmpeg --depth 1
RUN cd FFmpeg && \
  CFLAGS="${CFLAGS}" && \
    ./configure \
    --extra-cflags="-fopenmp -lcrypto -lz -ldl" \
    --extra-cxxflags="-fopenmp -lcrypto -lz -ldl" \
    --extra-ldflags="-fopenmp -lcrypto -lz -ldl" \
    --toolchain=hardened \
    --enable-static \
    --enable-shared \
    --disable-debug \
    --enable-pic \
    --enable-gpl \
    --enable-gray \
    --enable-nonfree \
    --enable-openssl \
    --enable-iconv \
    --enable-libxml2 \
    --enable-libmp3lame \
    --enable-libfdk-aac \
    --enable-libvorbis \
    --enable-libopus \
    --enable-libtheora \
    --enable-libvpx \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libwebp \
    --enable-libspeex \
    --enable-libaom \
    --enable-libvidstab \
    --enable-libkvazaar \
    --enable-libfreetype \
    --enable-fontconfig \
    --enable-libfribidi \
    --enable-libass \
    --enable-libsoxr \
    --enable-libopenjpeg \
    --enable-libdav1d \
    #--enable-librav1e \ # I'm lazy to compile it
    --enable-libsrt \
    --enable-libsvtav1 \
    --enable-libdavs2 \
    --enable-libvmaf \
    --enable-libxeve \
    #--enable-cuda-nvcc \ # ERROR: failed checking for nvcc
    --enable-vapoursynth \
    #--enable-hardcoded-tables \
    --enable-libopenh264 \
    --enable-optimizations \
    #--enable-cuda-llvm \ # ERROR: cuda_llvm requested but not found
    --enable-nvdec \
    --enable-nvenc \
    --enable-cuvid \
    --enable-cuda \
    --enable-pthreads \
    --enable-runtime-cpudetect \
    --enable-lto && \
    #--enable-vulkan && \ # currently can't get it working
    make -j$(nproc) && make install

###
# Install VapourSynth C++ plugins
###

# jansson
RUN git clone https://github.com/akheron/jansson && cd jansson && autoreconf -fi && CFLAGS=-fPIC ./configure && \
  make -j$(nproc) && make install

# bzip2
RUN git clone https://github.com/libarchive/bzip2 && cd bzip2 && \
  mkdir build && cd build && cmake .. && make -j$(nproc) && make install

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
RUN pkg-config --list-all
