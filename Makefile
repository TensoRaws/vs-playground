.DEFAULT_GOAL := default

.PHONY: lint
lint:
	pre-commit install
	pre-commit run --all-files

.PHONY: ff
ff:
	docker buildx build -f vs-ffmpeg-base.dockerfile -t lychee0/vs-ffmpeg-base .
	docker tag lychee0/vs-ffmpeg-base lychee0/vs-ffmpeg-base:latest
	docker tag lychee0/vs-ffmpeg-base lychee0/vs-ffmpeg-base:dev

.PHONY: pt
pt:
	docker buildx build -f vs-pytorch.dockerfile -t lychee0/vs-pytorch --build-arg BASE_CONTAINER_TAG=latest .
	docker tag lychee0/vs-pytorch lychee0/vs-pytorch:latest
	docker tag lychee0/vs-pytorch lychee0/vs-pytorch:dev
	docker tag lychee0/vs-pytorch lychee0/vs-pytorch:cuda-dev
	docker tag lychee0/vs-pytorch lychee0/vs-pytorch:cuda

.PHONY: pg
pg:
	docker buildx build -f vs-playground.dockerfile -t lychee0/vs-playground --build-arg BASE_CONTAINER_TAG=cuda .
	docker tag lychee0/vs-playground lychee0/vs-playground:latest
	docker tag lychee0/vs-playground lychee0/vs-playground:dev
	docker tag lychee0/vs-playground lychee0/vs-playground:cuda-dev
	docker tag lychee0/vs-playground lychee0/vs-playground:cuda

.PHONY: dev
dev:
	docker compose -f docker-compose.yml down
	docker compose -f docker-compose.yml up -d
