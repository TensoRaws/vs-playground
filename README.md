# vs-playground

dev with docker and jupyter notebook!

### Preparations

- docker and docker-compose
- Nvidia GPU / AMD GPU with ROCm support (7000 series on WSL2)
- make (optional)

### Dev

```bash
make dev
```

`make dev-rocm` for AMD GPU

open `http://localhost:8888` in your browser, default password is `114514`

template ipynb file is in [./video](./video) folder, you should put video in here

- (optional) use code completion in jupyter notebook

load yuuno plugin in jupyter notebook, then you can preview any frame

#### _run the example code in order, encode your first video!_

### Build

build [base image](./vs-pytorch.dockerfile) (default for FinalRip) and [playground image](./vs-playground.dockerfile)

```bash
make pt && make pg
```

`make pt-rocm && make pg-rocm` for AMD GPU

### Reference

- [VapourSynth](https://www.vapoursynth.com/)
- [yuuno](https://github.com/Irrational-Encoding-Wizardry/yuuno)

### License

This project is licensed under the GPL-3.0 license - see the [LICENSE file](https://github.com/TensoRaws/vs-playground/blob/main/LICENSE) for details.
