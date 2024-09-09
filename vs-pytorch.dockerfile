FROM ubuntu:22.04

# prepare environment
RUN apt update -y && apt upgrade -y
RUN apt install -y \
    libgl1-mesa-glx \
    curl \
    wget \
    make \
    libssl-dev \
    libffi-dev \
    libopenblas-dev \
    git

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py310_24.7.1-0-Linux-x86_64.sh
RUN bash Miniconda3-py310_24.7.1-0-Linux-x86_64.sh -b -p /opt/conda && rm -rf Miniconda3-latest-Linux-x86_64.sh

# Add the conda binary folder to the path
ENV PATH /opt/conda/bin:$PATH
ENV CONDARC_PATH /opt/conda/.condarc
ENV CONDARC $CONDARC_PATH
ENV PYTHONUNBUFFERED 1

RUN conda install --solver=classic conda-forge::conda-libmamba-solver conda-forge::libmamba conda-forge::libmambapy conda-forge::libarchive

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
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# install AI packages
RUN pip install vsrealesrgan
RUN python -m vsrealesrgan

# clear cache
RUN apt clean
RUN pip cache purge
RUN conda clean -all -y
