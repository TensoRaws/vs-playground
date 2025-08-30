FROM ubuntu:22.04

# Set environment variables to avoid user interaction during the installation process
ENV DEBIAN_FRONTEND=noninteractive

###
# prepare environment
###

RUN apt update && apt upgrade -y

## Install Python versions and pip
#RUN apt install -y \
#    python3.10 \
#    python3.10-venv \
#    python3.10-dev \
#    python3-pip \
#    python-is-python3
#
#RUN apt install -y \
#    libgl1-mesa-glx \
#    curl \
#    wget \
#    make \
#    cmake \
#    libssl-dev \
#    libffi-dev \
#    libopenblas-dev \
#    git
#
####
## Install compilers and build tools
####
#
## from https://github.com/styler00dollar/VSGAN-tensorrt-docker/blob/main/Dockerfile#L382
#RUN apt install autoconf libtool nasm ninja-build yasm pkg-config checkinstall -y && \
#    apt --fix-broken install && \
#    pip install meson ninja cython
#
## install g++13
#RUN apt install build-essential manpages-dev software-properties-common -y && \
#    add-apt-repository ppa:ubuntu-toolchain-r/test -y && \
#    apt update -y && \
#    apt install gcc-13 g++-13 -y && \
#    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 13 && \
#    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 13
#
####
## Set the working directory for VapourSynth and FFmpeg
####
#WORKDIR /workspace
#
####
## Install VapourSynth
####
#
## zimg
## setting pkg version manually since otherwise 'Version' field value '-1': version number is empty
#RUN git clone https://github.com/sekrit-twc/zimg --recursive && cd zimg && \
#  ./autogen.sh && ./configure && make -j$(nproc) && make install && \
#  checkinstall -y -pkgversion=0.0 && apt install ./zimg_0.0-1_amd64.deb -y
#
#### Install VapourSynth
#ARG VAPOURSYNTH_VERSION=R70
#RUN wget https://github.com/vapoursynth/vapoursynth/archive/refs/tags/${VAPOURSYNTH_VERSION}.tar.gz && \
#  tar -zxvf ${VAPOURSYNTH_VERSION}.tar.gz && mv vapoursynth-${VAPOURSYNTH_VERSION} vapoursynth && cd vapoursynth && \
#  ./autogen.sh && ./configure && make -j$(nproc) && make install && ldconfig
## install vapoursynth python package
#RUN cd vapoursynth && python setup.py install
#
####
## Install FFmpeg with Encoders
####
#
## --- prerequisites ---
#
#RUN apt install -y \
#    tcl \
#    libfreetype-dev \
#    libfribidi-dev \
#    libfontconfig-dev \
#    libharfbuzz-dev \
#    libunibreak-dev \
#    libsoxr-dev \
#    libxml2-dev
#
## Vulkan-Headers
#RUN git clone https://github.com/KhronosGroup/Vulkan-Headers.git --depth 1 && \
#  cd Vulkan-Headers/ && cmake -S . -B build/ && cmake --install build
#
## nv-codec-headers
#RUN git clone https://github.com/FFmpeg/nv-codec-headers --depth 1 && \
#  cd nv-codec-headers && make -j$(nproc) && make install
#
#RUN git clone https://github.com/gypified/libmp3lame --depth 1 && \
#  cd libmp3lame && ./configure --enable-nasm --enable-static --enable-shared && make -j$(nproc) install
#
#RUN git clone https://github.com/mstorsjo/fdk-aac --depth 1 && \
#  cd fdk-aac && ./autogen.sh && ./configure --enable-static --enable-shared && make -j$(nproc) install
#
#RUN git clone https://github.com/xiph/ogg --depth 1 && \
#  cd ogg && ./autogen.sh && ./configure --enable-static --enable-shared && make -j$(nproc) install
#
#RUN git clone https://github.com/xiph/vorbis --depth 1 && \
#  cd vorbis && ./autogen.sh && ./configure --enable-static --enable-shared && make -j$(nproc) install
#
#RUN git clone https://github.com/xiph/opus --depth 1 && \
#  cd opus && ./autogen.sh && ./configure --enable-static --enable-shared && make -j$(nproc) install
#
#RUN git clone https://github.com/xiph/theora --depth 1 && \
#  cd theora && ./autogen.sh && ./configure --disable-examples --enable-static --enable-shared && make -j$(nproc) install
#
#RUN git clone https://github.com/webmproject/libvpx --depth 1 && \
#  cd libvpx && ./configure --enable-vp9-highbitdepth --disable-unit-tests --disable-examples --enable-static --enable-shared && \
#  make -j$(nproc) install
#
#RUN git clone https://code.videolan.org/videolan/x264.git --depth 1 && \
#  cd x264 && ./configure --enable-pic --enable-static --enable-shared && make -j$(nproc) install
#
#ARG X265_VERSION=4.1
#ARG X265_URL="https://bitbucket.org/multicoreware/x265_git/downloads/x265_$X265_VERSION.tar.gz"
## multilib.sh will build 8,10,12bit libraries and link them together to 8bit's directory
#RUN wget -O x265_git.tar.bz2 "$X265_URL" && tar xf x265_git.tar.bz2 && cd x265_*/build/linux && \
#  MAKEFLAGS="-j$(nproc)" ./multilib.sh && \
#  make -C 8bit -j$(nproc) install
#
#RUN git clone https://github.com/webmproject/libwebp --depth 1 && \
#  cd libwebp && ./autogen.sh && ./configure --enable-static --enable-shared && make -j$(nproc) install
#
#RUN git clone https://github.com/xiph/speex --depth 1 && \
#  cd speex && ./autogen.sh && ./configure --enable-static --enable-shared && make -j$(nproc) install
#
#RUN git clone --depth 1 https://aomedia.googlesource.com/aom --depth 1 && \
#  cd aom && mkdir build_tmp && cd build_tmp && \
#  cmake \
#    -DENABLE_TESTS=OFF \
#    -DENABLE_NASM=ON \
#    -DCMAKE_INSTALL_LIBDIR=lib \
#    -DBUILD_SHARED_LIBS=ON \
#    .. && \
#    make -j$(nproc) install
#
#RUN git clone https://github.com/georgmartius/vid.stab --depth 1 && \
#  cd vid.stab && cmake -DBUILD_SHARED_LIBS=on . && make -j$(nproc) install
#
#RUN git clone https://github.com/ultravideo/kvazaar --depth 1 && \
#  cd kvazaar && ./autogen.sh && ./configure --enable-static --enable-shared && make -j$(nproc) install
#
## dependencies for libass and ffmpeg
## libfreetype-dev libfribidi-dev libfontconfig-dev libharfbuzz-dev libunibreak-dev
## libass
#RUN git clone https://github.com/libass/libass --depth 1 && \
#  cd libass && ./autogen.sh && ./configure --enable-static --enable-shared && make -j$(nproc) && make install
#
#RUN git clone https://github.com/uclouvain/openjpeg --depth 1 && \
#  cd openjpeg && cmake -G "Unix Makefiles" && make -j$(nproc) install
#
#RUN git clone https://code.videolan.org/videolan/dav1d --depth 1 && \
#  cd dav1d && meson build --buildtype release && ninja -C build install
#
## add extra CFLAGS that are not enabled by -O3
## http://websvn.xvid.org/cvs/viewvc.cgi/trunk/xvidcore/build/generic/configure.in?revision=2146&view=markup
#ARG XVID_VERSION=1.3.7
#ARG XVID_URL="https://downloads.xvid.com/downloads/xvidcore-$XVID_VERSION.tar.gz"
#ARG XVID_SHA256=abbdcbd39555691dd1c9b4d08f0a031376a3b211652c0d8b3b8aa9be1303ce2d
#RUN wget -O libxvid.tar.gz "$XVID_URL" && \
#    echo "$XVID_SHA256  libxvid.tar.gz" | sha256sum --status -c - && \
#    tar xf libxvid.tar.gz && \
#    cd xvidcore/build/generic && \
#    CFLAGS="-O2 -fno-strict-overflow -fstack-protector-all -fPIE -fstrength-reduce -ffast-math" ./configure && \
#    make -j$(nproc) && make install
#
## configure use tcl sh
#RUN git clone https://github.com/Haivision/srt --depth 1 && \
#  cd srt && ./configure --cmake-install-libdir=lib --cmake-install-includedir=include --cmake-install-bindir=bin && \
#  make -j$(nproc) && make install
#
#RUN git clone https://github.com/gianni-rosato/svt-av1-psy --depth 1 && \
#  cd svt-av1-psy/Build && \
#    cmake \
#    -G"Unix Makefiles" \
#    -DCMAKE_VERBOSE_MAKEFILE=ON \
#    -DCMAKE_INSTALL_LIBDIR=lib \
#    -DBUILD_SHARED_LIBS=OFF \
#    -DCMAKE_BUILD_TYPE=Release \
#    .. && \
#    make -j$(nproc) install
#
#RUN git clone https://github.com/pkuvcl/davs2 --depth 1 && \
#  cd davs2/build/linux && ./configure --disable-asm --enable-pic --enable-static --enable-shared && \
#  make -j$(nproc) install
#
#RUN git clone https://github.com/Netflix/vmaf --depth 1 && \
#  cd vmaf/libvmaf && meson build --buildtype release && ninja -C build install
#
#RUN git clone https://github.com/cisco/openh264 --depth 1 && \
#  cd openh264 && meson build --buildtype release && ninja -C build install
#
#RUN git clone https://github.com/mpeg5/xeve && \
#  cd xeve && mkdir build && cd build && cmake .. && make -j$(nproc) && make install
#
## dependencies for ffmpeg: libsoxr-dev libxml2-dev
#RUN git clone https://github.com/FFmpeg/FFmpeg --depth 1 && cd FFmpeg && \
#  CFLAGS="-O3 -static-libgcc -fno-strict-overflow -fstack-protector-all -fPIE" && \
#    ./configure \
#    --extra-cflags="-fopenmp -lcrypto -lz -ldl" \
#    --extra-cxxflags="-fopenmp -lcrypto -lz -ldl" \
#    --extra-ldflags="-fopenmp -lcrypto -lz -ldl" \
#    --toolchain=hardened \
#    --enable-static \
#    --enable-shared \
#    --disable-debug \
#    --enable-pic \
#    --enable-gpl \
#    --enable-gray \
#    --enable-nonfree \
#    --enable-openssl \
#    --enable-iconv \
#    --enable-libxml2 \
#    --enable-libmp3lame \
#    --enable-libfdk-aac \
#    --enable-libvorbis \
#    --enable-libopus \
#    --enable-libtheora \
#    --enable-libvpx \
#    --enable-libx264 \
#    --enable-libx265 \
#    --enable-libwebp \
#    --enable-libspeex \
#    --enable-libaom \
#    --enable-libvidstab \
#    --enable-libkvazaar \
#    --enable-libfreetype \
#    --enable-fontconfig \
#    --enable-libfribidi \
#    --enable-libass \
#    --enable-libsoxr \
#    --enable-libopenjpeg \
#    --enable-libdav1d \
#    #--enable-librav1e \ # I'm lazy to compile it
#    --enable-libsrt \
#    --enable-libsvtav1 \
#    --enable-libdavs2 \
#    --enable-libvmaf \
#    --enable-libxeve \
#    #--enable-cuda-nvcc \ # ERROR: failed checking for nvcc
#    --enable-vapoursynth \
#    #--enable-hardcoded-tables \
#    --enable-libopenh264 \
#    --enable-optimizations \
#    #--enable-cuda-llvm \ # ERROR: cuda_llvm requested but not found
#    --enable-nvdec \
#    --enable-nvenc \
#    --enable-cuvid \
#    --enable-cuda \
#    --enable-pthreads \
#    --enable-runtime-cpudetect \
#    --enable-lto && \
#    #--enable-vulkan && \ # currently can't get it working
#    make -j$(nproc) && make install
