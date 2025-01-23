ARG BASE_CONTAINER_TAG=latest

FROM lychee0/vs-ffmpeg-docker:${BASE_CONTAINER_TAG}

###
# Set the working directory for VapourSynth
###
WORKDIR /workspace

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
RUN git clone https://github.com/FFMS/ffms2 && cd ffms2 && \
    ./autogen.sh && CFLAGS=-fPIC CXXFLAGS=-fPIC LDFLAGS="-Wl,-Bsymbolic" ./configure --enable-shared && make -j$(nproc) && make install
RUN ln -s /usr/local/lib/libffms2.so /usr/local/lib/vapoursynth/libffms2.so

# fmtconv
RUN git clone https://github.com/EleonoreMizo/fmtconv && cd fmtconv/build/unix/ && \
    ./autogen.sh && ./configure && make -j$(nproc) && make install
RUN ln -s /usr/local/lib/libfmtconv.so /usr/local/lib/vapoursynth/libfmtconv.so

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

RUN ls /usr/local/lib
RUN ls /usr/local/include
RUN pkg-config --list-all
