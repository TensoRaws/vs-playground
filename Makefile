.DEFAULT_GOAL := default

.PHONY: lint
lint:
	pre-commit install
	pre-commit run --all-files

.PHONY: pt
pt:
	docker buildx build -f vs-pytorch.dockerfile \
		-t lychee0/vs-pytorch \
		-t lychee0/vs-pytorch:dev \
		-t lychee0/vs-pytorch:cuda-dev \
		-t lychee0/vs-pytorch:cuda .

.PHONY: pg
pg:
	docker buildx build -f vs-playground.dockerfile --build-arg BASE_CONTAINER_TAG=cuda \
		-t lychee0/vs-playground \
		-t lychee0/vs-playground:dev \
		-t lychee0/vs-playground:cuda-dev \
		-t lychee0/vs-playground:cuda .

.PHONY: dev
dev:
	docker compose -f docker-compose.yml down
	docker compose -f docker-compose.yml up -d
