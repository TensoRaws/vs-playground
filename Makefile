.DEFAULT_GOAL := default

version := v0.0.1

.PHONY: lint ## pip install pre-commit
lint:
	pre-commit install
	pre-commit run --all-files

.PHONY: pt
pt:
	docker buildx build -f vs-pytorch.dockerfile -t lychee0/vs-pytorch .
	docker tag lychee0/vs-pytorch lychee0/vs-pytorch:latest
	docker tag lychee0/vs-pytorch lychee0/vs-pytorch:dev
	docker tag lychee0/vs-pytorch lychee0/vs-pytorch:cuda-dev
	docker tag lychee0/vs-pytorch lychee0/vs-pytorch:cuda-${version}
	docker tag lychee0/vs-pytorch lychee0/vs-pytorch:cuda

.PHONY: pt-release-dev
pt-release-dev:
	docker login
	docker push lychee0/vs-pytorch:dev
	docker push lychee0/vs-pytorch:cuda-dev

.PHONY: pt-release
pt-release:
	docker login
	docker push lychee0/vs-pytorch:latest
	docker push lychee0/vs-pytorch:cuda
	docker push lychee0/vs-pytorch:cuda-${version}

.PHONY: pt-rocm
pt-rocm:
	docker buildx build -f vs-pytorch-rocm.dockerfile -t lychee0/vs-pytorch .
	docker tag lychee0/vs-pytorch lychee0/vs-pytorch:rocm-dev
	docker tag lychee0/vs-pytorch lychee0/vs-pytorch:rocm-${version}
	docker tag lychee0/vs-pytorch lychee0/vs-pytorch:rocm

.PHONY: pt-rocm-release-dev
pt-rocm-release-dev:
	docker login
	docker push lychee0/vs-pytorch:rocm-dev

.PHONY: pt-rocm-release
pt-rocm-release:
	docker login
	docker push lychee0/vs-pytorch:rocm
	docker push lychee0/vs-pytorch:rocm-${version}

.PHONY: pg
pg:
	docker buildx build -f vs-playground.dockerfile -t lychee0/vs-playground --build-arg BASE_CONTAINER_TAG=cuda .
	docker tag lychee0/vs-playground lychee0/vs-playground:latest
	docker tag lychee0/vs-playground lychee0/vs-playground:dev
	docker tag lychee0/vs-playground lychee0/vs-playground:cuda-dev
	docker tag lychee0/vs-playground lychee0/vs-playground:cuda-${version}
	docker tag lychee0/vs-playground lychee0/vs-playground:cuda

.PHONY: pg-release-dev
pg-release-dev:
	docker login
	docker push lychee0/vs-playground:dev
	docker push lychee0/vs-playground:cuda-dev

.PHONY: pg-release
pg-release:
	docker login
	docker push lychee0/vs-playground:latest
	docker push lychee0/vs-playground:cuda
	docker push lychee0/vs-playground:cuda-${version}

.PHONY: pg-rocm
pg-rocm:
	docker buildx build -f vs-playground.dockerfile -t lychee0/vs-playground --build-arg BASE_CONTAINER_TAG=rocm .
	docker tag lychee0/vs-playground lychee0/vs-playground:rocm-dev
	docker tag lychee0/vs-playground lychee0/vs-playground:rocm-${version}
	docker tag lychee0/vs-playground lychee0/vs-playground:rocm

.PHONY: pg-rocm-release-dev
pg-rocm-release-dev:
	docker login
	docker push lychee0/vs-playground:rocm-dev

.PHONY: pg-rocm-release
pg-rocm-release:
	docker login
	docker push lychee0/vs-playground:rocm
	docker push lychee0/vs-playground:rocm-${version}

.PHONY: release-dev
release-dev: pt pt-release-dev pg pg-release-dev

.PHONY: release
release: pt pt-release pg pg-release

.PHONY: release-rocm-dev
release-rocm-dev: pt-rocm pt-rocm-release-dev pg-rocm pg-rocm-release-dev

.PHONY: release-rocm
release-rocm: pt-rocm pt-rocm-release pg-rocm pg-rocm-release

.PHONY: dev
dev:
	docker compose -f docker-compose.yml down
	docker compose -f docker-compose.yml up -d

.PHONY: dev-rocm
dev-rocm:
	docker compose -f docker-compose-rocm.yml down
	docker compose -f docker-compose-rocm.yml up -d
