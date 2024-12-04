FROM ubuntu:22.04

# Set the working directory
WORKDIR /amd

# Set environment variables to avoid user interaction during the installation process
ENV DEBIAN_FRONTEND=noninteractive

# prepare environment
RUN apt update && apt upgrade -y

# Install Python versions and pip
RUN apt install -y \
    python3.10 \
    python3.10-venv \
    python3.10-dev \
    python3-pip

RUN apt install -y \
    libgl1-mesa-glx \
    curl \
    wget \
    make \
    libssl-dev \
    libffi-dev \
    libopenblas-dev \
    git

# Install necessary dependencies
RUN apt install -y \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && add-apt-repository universe \
    && apt update

RUN wget http://security.ubuntu.com/ubuntu/pool/universe/n/ncurses/libtinfo5_6.2-0ubuntu2.1_amd64.deb
RUN apt install -y ./libtinfo5_6.2-0ubuntu2.1_amd64.deb && rm -f ./libtinfo5_6.2-0ubuntu2.1_amd64.deb

RUN wget https://mirrors.edge.kernel.org/ubuntu/pool/main/s/suitesparse/libsuitesparseconfig5_5.10.1+dfsg-4build1_amd64.deb
RUN apt install -y ./libsuitesparseconfig5_5.10.1+dfsg-4build1_amd64.deb && rm -f ./libsuitesparseconfig5_5.10.1+dfsg-4build1_amd64.deb

RUN wget https://mirrors.edge.kernel.org/ubuntu/pool/universe/s/suitesparse/libccolamd2_5.10.1+dfsg-4build1_amd64.deb
RUN apt install -y ./libccolamd2_5.10.1+dfsg-4build1_amd64.deb && rm -f ./libccolamd2_5.10.1+dfsg-4build1_amd64.deb

RUN wget https://mirrors.edge.kernel.org/ubuntu/pool/main/s/suitesparse/libcamd2_5.7.1+dfsg-2_amd64.deb
RUN apt install -y ./libcamd2_5.7.1+dfsg-2_amd64.deb && rm -f ./libcamd2_5.7.1+dfsg-2_amd64.deb

RUN wget https://mirrors.edge.kernel.org/ubuntu/pool/main/s/suitesparse/libcolamd2_5.7.1+dfsg-2_amd64.deb
RUN apt install -y ./libcolamd2_5.7.1+dfsg-2_amd64.deb && rm -f ./libcolamd2_5.7.1+dfsg-2_amd64.deb

RUN wget https://mirrors.edge.kernel.org/ubuntu/pool/main/s/suitesparse/libamd2_5.7.1+dfsg-2_amd64.deb
RUN apt install -y ./libamd2_5.7.1+dfsg-2_amd64.deb && rm -f ./libamd2_5.7.1+dfsg-2_amd64.deb

RUN wget https://mirrors.edge.kernel.org/ubuntu/pool/main/s/suitesparse/libcholmod3_5.7.1+dfsg-2_amd64.deb
RUN apt install -y ./libcholmod3_5.7.1+dfsg-2_amd64.deb && rm -f ./libcholmod3_5.7.1+dfsg-2_amd64.deb

RUN wget http://security.ubuntu.com/ubuntu/pool/universe/n/ncurses/libncurses5_6.2-0ubuntu2.1_amd64.deb
RUN apt install -y ./libncurses5_6.2-0ubuntu2.1_amd64.deb && rm -f ./libncurses5_6.2-0ubuntu2.1_amd64.deb

RUN wget https://mirrors.edge.kernel.org/ubuntu/pool/main/m/mime-support/mime-support_3.66_all.deb
RUN apt install -y ./mime-support_3.66_all.deb && rm -f ./mime-support_3.66_all.deb

RUN wget https://mirrors.edge.kernel.org/ubuntu/pool/universe/libf/libffi7/libffi7_3.3-5ubuntu1_amd64.deb
RUN apt install -y ./libffi7_3.3-5ubuntu1_amd64.deb && rm -f ./libffi7_3.3-5ubuntu1_amd64.deb

RUN wget https://mirrors.edge.kernel.org/ubuntu/pool/main/m/mpdecimal/libmpdec2_2.4.2-3_amd64.deb
RUN apt install -y ./libmpdec2_2.4.2-3_amd64.deb && rm -f ./libmpdec2_2.4.2-3_amd64.deb

# Download the AMD GPU installer package
RUN wget https://repo.radeon.com/amdgpu-install/6.1.3/ubuntu/jammy/amdgpu-install_6.1.60103-1_all.deb

RUN apt install -y ./amdgpu-install_6.1.60103-1_all.deb && rm -f ./amdgpu-install_6.1.60103-1_all.deb

RUN amdgpu-install -y --usecase=wsl,rocm --no-dkms

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py310_24.7.1-0-Linux-x86_64.sh
RUN bash Miniconda3-py310_24.7.1-0-Linux-x86_64.sh -b -p /opt/conda && rm -rf Miniconda3-latest-Linux-x86_64.sh

# Add the conda binary folder to the path
ENV PATH /opt/conda/bin:$PATH
ENV CONDARC_PATH /opt/conda/.condarc
ENV CONDARC $CONDARC_PATH
ENV PYTHONUNBUFFERED 1

RUN conda install conda-forge::conda-libmamba-solver conda-forge::libmamba conda-forge::libmambapy conda-forge::libarchive --force -y

# install vapoursynth
RUN conda install conda-forge::vapoursynth=69 -y

# install vapoursynth C++ plugins
RUN conda install tongyuantongyu::vapoursynth-bestsource=5 -y
RUN conda install tongyuantongyu::vapoursynth-fmtconv=30 -y

# install vapoursynth python plugins
RUN conda install tongyuantongyu::vapoursynth-mvsfunc=10.10 -y
RUN conda install tongyuantongyu::vapoursynth-vsutil=0.8.0 -y
RUN pip install git+https://github.com/HomeOfVapourSynthEvolution/havsfunc.git

# install python packages
RUN conda install conda-forge::numpy=1.26.4 -y
RUN conda install fastai::opencv-python-headless=4.10.0.82 -y

# install PyTorch
RUN wget https://repo.radeon.com/rocm/manylinux/rocm-rel-6.1.3/torch-2.1.2%2Brocm6.1.3-cp310-cp310-linux_x86_64.whl
RUN wget https://repo.radeon.com/rocm/manylinux/rocm-rel-6.1.3/torchvision-0.16.1%2Brocm6.1.3-cp310-cp310-linux_x86_64.whl
RUN wget https://repo.radeon.com/rocm/manylinux/rocm-rel-6.1.3/pytorch_triton_rocm-2.1.0%2Brocm6.1.3.4d510c3a44-cp310-cp310-linux_x86_64.whl
RUN pip install numpy==1.26.4 torch-2.1.2+rocm6.1.3-cp310-cp310-linux_x86_64.whl torchvision-0.16.1+rocm6.1.3-cp310-cp310-linux_x86_64.whl pytorch_triton_rocm-2.1.0+rocm6.1.3.4d510c3a44-cp310-cp310-linux_x86_64.whl
RUN rm -f torch-2.1.2+rocm6.1.3-cp310-cp310-linux_x86_64.whl torchvision-0.16.1+rocm6.1.3-cp310-cp310-linux_x86_64.whl pytorch_triton_rocm-2.1.0+rocm6.1.3.4d510c3a44-cp310-cp310-linux_x86_64.whl

#RUN pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm6.1

# Locate the torch library directory, HACK
RUN location=$(pip show torch | grep Location | awk -F ": " '{print $2}') && \
    cd ${location}/torch/lib/ && \
    rm -f libhsa-runtime64.so* && \
    cp /opt/rocm/lib/libhsa-runtime64.so.1.2 libhsa-runtime64.so

## install AI packages
RUN pip install ccrestoration==0.1.2

# clear cache
RUN apt clean
RUN pip cache purge
RUN conda clean -all -y
