.DEFAULT_GOAL := default

.PHONY: lint
lint:
	pre-commit install # pip install pre-commit
	pre-commit run --all-files

.PHONY: pt
pt:
	docker buildx build -f vs-pytorch.dockerfile -t lychee0/vs-pytorch .
	docker tag lychee0/vs-pytorch lychee0/vs-pytorch:dev
	docker tag lychee0/vs-pytorch lychee0/vs-pytorch:cuda

.PHONY: pt-release
pt-release:
	docker login
	docker push lychee0/vs-pytorch:dev
	docker push lychee0/vs-pytorch:cuda

.PHONY: pt-rocm
pt-rocm:
	docker buildx build -f vs-pytorch-rocm.dockerfile -t lychee0/vs-pytorch .
	docker tag lychee0/vs-pytorch lychee0/vs-pytorch:rocm

.PHONY: pt-rocm-release
pt-rocm-release:
	docker login
	docker push lychee0/vs-pytorch:rocm

.PHONY: pg
pg:
	docker buildx build -f vs-playground.dockerfile -t lychee0/vs-playground --build-arg BASE_CONTAINER_TAG=cuda .
	docker tag lychee0/vs-playground lychee0/vs-playground:dev
	docker tag lychee0/vs-playground lychee0/vs-playground:cuda

.PHONY: pg-release
pg-release:
	docker login
	docker push lychee0/vs-playground:dev
	docker push lychee0/vs-playground:cuda

.PHONY: pg-rocm
pg-rocm:
	docker buildx build -f vs-playground-rocm.dockerfile -t lychee0/vs-playground --build-arg BASE_CONTAINER_TAG=rocm .
	docker tag lychee0/vs-playground lychee0/vs-playground:rocm

.PHONY: pg-rocm-release
pg-rocm-release:
	docker login
	docker push lychee0/vs-playground:rocm

.PHONY: release
release: pt pt-release pg pg-release pt-rocm pt-rocm-release pg-rocm pg-rocm-release
