ARG BASE_CONTAINER_TAG=latest

FROM lychee0/vs-ffmpeg-docker:${BASE_CONTAINER_TAG}

###
# Set the working directory for CUDA
###
WORKDIR /cuda

###
# set up CUDA environment (CUDA 12.4)
###

RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \
    apt update && \
    apt install -y cuda-nvcc-12-4 cuda-cudart-dev-12-4 cuda-nvrtc-dev-12-4 libcufft-dev-12-4

# set up environment variables
ENV PATH=/usr/local/cuda/bin:${PATH}
ENV CUDA_PATH=/usr/local/cuda
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

###
# Set the working directory for VapourSynth
###
WORKDIR /workspace

###
# Install VapourSynth C++ plugins
###

# --- prerequisites ---

RUN apt install -y \
    autoconf \
    llvm-15 \
    nasm \
    libboost-dev \
    libxxhash-dev \
    libfftw3-dev \
    libtbb-dev

# jansson
RUN git clone https://github.com/akheron/jansson --depth 1 && cd jansson && autoreconf -fi && CFLAGS=-fPIC ./configure && \
  make -j$(nproc) && make install

# bzip2
RUN git clone https://github.com/libarchive/bzip2 --depth 1 && cd bzip2 && \
  mkdir build && cd build && cmake .. && make -j$(nproc) && make install

# --- VapourSynth plugins ---
# bestsource
RUN git clone https://github.com/vapoursynth/bestsource.git --depth 1 --recurse-submodules --shallow-submodules --remote-submodules && cd bestsource && \
  CFLAGS=-fPIC meson setup -Denable_plugin=true build && CFLAGS=-fPIC ninja -C build && ninja -C build install

# vs-miscfilters
RUN git clone https://github.com/vapoursynth/vs-miscfilters-obsolete --depth 1 && cd vs-miscfilters-obsolete && \
    mkdir build && cd build && meson ../ && ninja && ninja install

# ffms2
RUN git clone https://github.com/FFMS/ffms2 --depth 1 && cd ffms2 && \
    ./autogen.sh && CFLAGS=-fPIC CXXFLAGS=-fPIC LDFLAGS="-Wl,-Bsymbolic" ./configure --enable-shared && make -j$(nproc) && make install
RUN ln -s /usr/local/lib/libffms2.so /usr/local/lib/vapoursynth/libffms2.so

# fmtconv
RUN git clone https://github.com/EleonoreMizo/fmtconv --depth 1 && cd fmtconv/build/unix/ && \
    ./autogen.sh && ./configure && make -j$(nproc) && make install
RUN ln -s /usr/local/lib/libfmtconv.so /usr/local/lib/vapoursynth/libfmtconv.so

# removegrain
RUN git clone https://github.com/vapoursynth/vs-removegrain --depth 1 && cd vs-removegrain && \
    mkdir build && cd build && meson ../ && ninja && ninja install

# HomeOfVapourSynthEvolution's plugins
# Retinex
RUN git clone https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Retinex --depth 1 && cd VapourSynth-Retinex && \
    mkdir build && cd build && meson ../ && ninja && ninja install

# TCanny
RUN git clone https://github.com/HomeOfVapourSynthEvolution/VapourSynth-TCanny --depth 1 && cd VapourSynth-TCanny && \
    mkdir build && cd build && meson ../ && ninja && ninja install

# CTMF
RUN git clone https://github.com/HomeOfVapourSynthEvolution/VapourSynth-CTMF --depth 1 && cd VapourSynth-CTMF && \
    mkdir build && cd build && meson ../ && ninja && ninja install

# CAS
RUN git clone https://github.com/HomeOfVapourSynthEvolution/VapourSynth-CAS --depth 1 && cd VapourSynth-CAS && \
    mkdir build && cd build && meson ../ && ninja && ninja install

# AddGrain
RUN git clone https://github.com/HomeOfVapourSynthEvolution/VapourSynth-AddGrain --depth 1 && cd VapourSynth-AddGrain && \
    mkdir build && cd build && meson ../ && ninja && ninja install

# Bilateral
RUN git clone https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Bilateral --depth 1 && cd VapourSynth-Bilateral && \
    ./configure && make -j$(nproc) && make install

# Bwdif
RUN git clone https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Bwdif --depth 1 && cd VapourSynth-Bwdif && \
    mkdir build && cd build && meson ../ && ninja && ninja install

# DCTFilter
RUN git clone https://github.com/HomeOfVapourSynthEvolution/VapourSynth-DCTFilter --depth 1 && cd VapourSynth-DCTFilter && \
    mkdir build && cd build && meson ../ && ninja && ninja install

# TTempSmooth
RUN git clone https://github.com/HomeOfVapourSynthEvolution/VapourSynth-TTempSmooth --depth 1 && cd VapourSynth-TTempSmooth && \
    mkdir build && cd build && meson ../ && ninja && ninja install

# EEDI2
RUN git clone https://github.com/HomeOfVapourSynthEvolution/VapourSynth-EEDI2 --depth 1 && cd VapourSynth-EEDI2 && \
    mkdir build && cd build && meson ../ && ninja && ninja install

# EEDI3
RUN git clone https://github.com/HomeOfVapourSynthEvolution/VapourSynth-EEDI3 --depth 1 && cd VapourSynth-EEDI3 && \
    mkdir build && cd build && meson -D opencl=false ../ && ninja && ninja install

# HomeOfAviSynthPlusEvolution's plugins
# neo_FFT3D
RUN git clone https://github.com/HomeOfAviSynthPlusEvolution/neo_FFT3D --depth 1 && cd neo_FFT3D && \
    cmake -S . -B build -G Ninja -LA && \
    cmake --build build --verbose
RUN cp neo_FFT3D/build/libneo-fft3d.so /usr/local/lib && \
    ln -s /usr/local/lib/libneo-fft3d.so /usr/local/lib/vapoursynth/libneo-fft3d.so

# neo_DFTTest
RUN git clone https://github.com/HomeOfAviSynthPlusEvolution/neo_DFTTest --depth 1 && cd neo_DFTTest && \
    cmake -S . -B build -G Ninja -LA && \
    cmake --build build --verbose
RUN cp neo_DFTTest/build/libneo-dfttest.so /usr/local/lib && \
    ln -s /usr/local/lib/libneo-dfttest.so /usr/local/lib/vapoursynth/libneo-dfttest.so

# neo_f3kdb
RUN git clone https://github.com/HomeOfAviSynthPlusEvolution/neo_f3kdb --depth 1 && cd neo_f3kdb && \
    cmake -S . -B build -G Ninja -LA && \
    cmake --build build --verbose
RUN cp neo_f3kdb/build/libneo-f3kdb.so /usr/local/lib && \
    ln -s /usr/local/lib/libneo-f3kdb.so /usr/local/lib/vapoursynth/libneo-f3kdb.so

# AmusementClub's plugins
# assrender
RUN git clone https://github.com/AmusementClub/assrender --depth 1 && cd assrender && \
    mkdir build && cd build && cmake .. && make -j$(nproc) && make install

# vs-boxblur
RUN git clone https://github.com/AmusementClub/vs-boxblur --depth 1 --recurse-submodules && cd vs-boxblur && \
    cmake -S . -B build -G Ninja \
    -D VS_INCLUDE_DIR="/usr/local/include/vapoursynth" \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_CXX_FLAGS_RELEASE="-Wall -ffast-math -march=x86-64-v3" && \
    cmake --build build --verbose && \
    cmake --install build --prefix /usr/local

# Irrational-Encoding-Wizardry's plugins
# descale
RUN git clone https://github.com/Irrational-Encoding-Wizardry/descale --depth 1 && cd descale && \
    mkdir build && cd build && meson ../ && ninja && ninja install

# RemapFrames
RUN git clone https://github.com/Irrational-Encoding-Wizardry/Vapoursynth-RemapFrames --depth 1 && cd Vapoursynth-RemapFrames && \
    mkdir build && cd build && meson ../ && ninja && ninja install
RUN ln -s /usr/local/lib/x86_64-linux-gnu/vapoursynth/libremapframes.so /usr/local/lib/vapoursynth/libremapframes.so

# AkarinVS's plugins
# libakarin, depends on llvm ver >= 10.0 && < 16
RUN git clone https://github.com/AkarinVS/vapoursynth-plugin --depth 1 && cd vapoursynth-plugin && \
    mkdir build && cd build && meson ../ && ninja && ninja install

# dubhater's plugins
# mvtools
RUN git clone https://github.com/dubhater/vapoursynth-mvtools --depth 1 && cd vapoursynth-mvtools && \
    mkdir build && cd build && meson ../ && ninja && ninja install
RUN ln -s /usr/local/lib/x86_64-linux-gnu/libmvtools.so /usr/local/lib/vapoursynth/libmvtools.so

# fillborders
RUN git clone https://github.com/dubhater/vapoursynth-fillborders --depth 1 && cd vapoursynth-fillborders && \
    mkdir build && cd build && meson ../ && ninja && ninja install
RUN ln -s /usr/local/lib/x86_64-linux-gnu/libfillborders.so /usr/local/lib/vapoursynth/libfillborders.so

# flux
RUN git clone https://github.com/dubhater/vapoursynth-fluxsmooth --depth 1 && cd vapoursynth-fluxsmooth && \
    ./autogen.sh && CFLAGS=-fPIC ./configure && make -j$(nproc) && make install
RUN ln -s /usr/local/lib/libfluxsmooth.so /usr/local/lib/vapoursynth/libfluxsmooth.so

# nnedi3
RUN git clone https://github.com/dubhater/vapoursynth-nnedi3 --depth 1 && cd vapoursynth-nnedi3 && \
    ./autogen.sh && CFLAGS=-fPIC CXXFLAGS=-fPIC ./configure && make -j$(nproc) && make install
RUN ln -s /usr/local/lib/libnnedi3.so /usr/local/lib/vapoursynth/libnnedi3.so

# tedgemask
RUN git clone https://github.com/dubhater/vapoursynth-tedgemask --depth 1 && cd vapoursynth-tedgemask && \
    mkdir build && cd build && meson ../ && ninja && ninja install
RUN ln -s /usr/local/lib/x86_64-linux-gnu/libtedgemask.so /usr/local/lib/vapoursynth/libtedgemask.so

# sangnom
RUN git clone https://github.com/dubhater/vapoursynth-sangnom --depth 1 && cd vapoursynth-sangnom && \
    mkdir build && cd build && meson ../ && ninja && ninja install
RUN ln -s /usr/local/lib/x86_64-linux-gnu/libsangnom.so /usr/local/lib/vapoursynth/libsangnom.so

# TensoRaw's plugins
# hqdn3d
RUN git clone https://github.com/TensoRaws/vapoursynth-hqdn3d --depth 1 && cd vapoursynth-hqdn3d && \
    ./autogen.sh && CXXFLAGS=-fPIC ./configure && make -j$(nproc) && make install
RUN ln -s /usr/local/lib/libhqdn3d.so /usr/local/lib/vapoursynth/libhqdn3d.so

# d2vsource
RUN git clone https://github.com/TensoRaws/d2vsource --depth 1 && cd d2vsource && \
    ./autogen.sh && CXXFLAGS=-fPIC ./configure && make -j$(nproc) && make install
RUN ln -s /usr/local/lib/libd2vsource.so /usr/local/lib/vapoursynth/libd2vsource.so

## znedi3
#RUN git clone https://github.com/TensoRaws/znedi3 --depth 1 --recurse-submodules && cd znedi3 && \
#    mkdir build && cd build && meson ../ && ninja && ninja install
#RUN ln -s /usr/local/lib/x86_64-linux-gnu/libvsznedi3.so /usr/local/lib/vapoursynth/libvsznedi3.so

###
# Install VapourSynth CUDA plugins
###

# AmusementClub's plugins
# dfttest2
RUN git clone https://github.com/AmusementClub/vs-dfttest2 --depth 1 --recurse-submodules && cd vs-dfttest2 && \
    cmake -S . -B build -G Ninja -LA \
    -D USE_NVRTC_STATIC=ON \
    -D VAPOURSYNTH_INCLUDE_DIRECTORY="/usr/local/include/vapoursynth" \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_CXX_FLAGS="-Wall -ffast-math -march=x86-64-v3" \
    -D CMAKE_CUDA_FLAGS="--threads 0 --use_fast_math --resource-usage -Wno-deprecated-gpu-targets" \
    -D CMAKE_CUDA_ARCHITECTURES="50;52-real;60;61-real;70;75-real;80;86-real;89-real;90-real" && \
    cmake --build build --verbose && \
    cmake --install build --verbose --prefix /usr/local

# WolframRhodium's plugins
# BM3DCUDA
RUN git clone https://github.com/WolframRhodium/VapourSynth-BM3DCUDA --depth 1 && cd VapourSynth-BM3DCUDA && \
    cmake -S . -B build -G Ninja -LA \
    -D USE_NVRTC_STATIC=ON \
    -D VAPOURSYNTH_INCLUDE_DIRECTORY="/usr/local/include/vapoursynth" \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_CXX_FLAGS="-Wall -ffast-math -march=x86-64-v3" \
    -D CMAKE_CUDA_FLAGS="--threads 0 --use_fast_math --resource-usage -Wno-deprecated-gpu-targets" \
    -D CMAKE_CUDA_ARCHITECTURES="50;52-real;60;61-real;70;75-real;80;86-real;89-real;90-real" && \
    cmake --build build --verbose && \
    cmake --install build --verbose --prefix /usr/local
RUN ln -s /usr/local/lib/libbm3dcuda.so /usr/local/lib/vapoursynth/libbm3dcuda.so && \
    ln -s /usr/local/lib/libbm3dcuda_rtc.so /usr/local/lib/vapoursynth/libbm3dcuda_rtc.so && \
    ln -s /usr/local/lib/libbm3dcpu.so /usr/local/lib/vapoursynth/libbm3dcpu.so

# ILS
RUN git clone https://github.com/WolframRhodium/VapourSynth-ILS --depth 1 && cd VapourSynth-ILS && \
    cmake -S . -B build -G Ninja \
    -D VAPOURSYNTH_INCLUDE_DIRECTORY="/usr/local/include/vapoursynth" \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_CXX_FLAGS="-Wall -ffast-math -march=x86-64-v3" \
    -D CMAKE_CUDA_FLAGS="--threads 0 --use_fast_math --resource-usage -Wno-deprecated-gpu-targets" \
    -D CMAKE_CUDA_ARCHITECTURES="50;52-real;60;61-real;70;75-real;80;86-real;89-real;90-real" && \
    cmake --build build --verbose
RUN cp VapourSynth-ILS/build/libils.so /usr/local/lib && \
    ln -s /usr/local/lib/libils.so /usr/local/lib/vapoursynth/libils.so

###
# Install VapourSynth Python plugins
###

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


# ------------------ new plugins ------------------

RUN cd /usr/local/lib/x86_64-linux-gnu && ls
RUN cd /usr/local/lib && ls
RUN cd /usr/local/lib/vapoursynth && ls && exit 1