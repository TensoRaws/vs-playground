# vs-playground

[![CI-test](https://github.com/TensoRaws/vs-playground/actions/workflows/CI-test.yml/badge.svg)](https://github.com/TensoRaws/vs-playground/actions/workflows/CI-test.yml)
[![CI-build](https://github.com/TensoRaws/vs-playground/actions/workflows/CI-build.yml/badge.svg)](https://github.com/TensoRaws/vs-playground/actions/workflows/CI-build.yml)
[![Release](https://github.com/TensoRaws/vs-playground/actions/workflows/Release.yml/badge.svg)](https://github.com/TensoRaws/vs-playground/actions/workflows/Release.yml)

dev with docker and jupyter notebook!

### Preparations

- docker and docker-compose
- Nvidia GPU and GPU container runtime (optional)
- make (optional)

### Start

```bash
make dev
```

open `http://localhost:1145` in your browser, default password is `114514`

template ipynb file is in [./video](./video) folder, you should put video in here

- (optional) use code completion in jupyter notebook

load yuuno plugin in jupyter notebook, then you can preview any frame

#### _run the example code in order, encode your first video!_

![vsplayground001](https://raw.githubusercontent.com/TensoRaws/.github/refs/heads/main/vsplayground001.png)

### SSH

the playground image has sshd installed, you can ssh into the container to dev

- default port: 1022 (1022:22)
- user: root
- password: 123456

## Base Environment

- system: Ubuntu 22.04
- GCC/G++: 13
- python: 3.11
- FFmpeg: 8.0
- VapourSynth: R70
- x264: latest
- x265: 4.1
- svt-av1-psy: latest
- aom: latest
- libvpx: latest
- fdk-aac: latest
- libass: latest

### VapourSynth Python Plugin List

```bash
mbfunc
ccrestoration
ccvfi
vsutil
mvsfunc
havsfunc
JET's funcs
```

### VapourSynth C++ Plugin List

```bash
bestsource.so
libaddgrain.so
libakarin.so
libassrender.so
libbilateral.so
libbm3dcpu.so
libbm3dcuda.so
libbm3dcuda_rtc.so
libboxblur.so
libbwdif.so
libcas.so
libctmf.so
#libd2vsource.so
libdctfilter.so
libdescale.so
libdfttest2_cpu.so
libdfttest2_cuda.so
libdfttest2_nvrtc.so
libeedi2.so
libeedi3m.so
libffms2.so
libfillborders.so
libfluxsmooth.so
libfmtconv.so
libhqdn3d.so
libils.so
libmiscfilters.so
libmvtools.so
libneo-dfttest.so
libneo-f3kdb.so
libneo-fft3d.so
libnnedi3.so
libremapframes.so
libremovegrain.so
libretinex.so
libsangnom.so
libtcanny.so
libtedgemask.so
libttempsmooth.so
libvsnlm_cuda.so
libvsznedi3.so
```

### Build

build [image](./vs-pytorch.dockerfile) (default for FinalRip) and [playground image](./vs-playground.dockerfile)

```bash
make pt && make pg
```

### Reference

- [static-ffmpeg](https://github.com/wader/static-ffmpeg)
- [VSGAN-tensorrt-docker](https://github.com/styler00dollar/VSGAN-tensorrt-docker)
- [vs-ffmpeg-docker](https://github.com/TensoRaws/vs-ffmpeg-docker)
- [VapourSynth](https://www.vapoursynth.com/)
- [yuuno](https://github.com/Irrational-Encoding-Wizardry/yuuno)

### License

This project is licensed under the GPL-3.0 license - see the [LICENSE file](https://github.com/TensoRaws/vs-playground/blob/main/LICENSE) for details.
