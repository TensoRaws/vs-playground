GO ?= go

.DEFAULT_GOAL := default

TAGS ?=

.PHONY: lint
lint:
	pre-commit install # pip install pre-commit
	pre-commit run --all-files

.PHONY: pt
pt:
	docker buildx build -f vs-pytorch.dockerfile -t lychee0/vs-pytorch .

.PHONY: pt-dev
pt-dev:
	docker buildx build -f vs-pytorch.dockerfile -t lychee0/vs-pytorch .
	docker tag lychee0/vs-pytorch lychee0/vs-pytorch:dev
	docker login
	docker push lychee0/vs-pytorch:dev

.PHONY: pg
vs:
	docker buildx build -f vs-playground.dockerfile -t lychee0/vs-playground .

.PHONY: pg-dev
pg-dev:
	docker buildx build -f vs-playground.dockerfile -t lychee0/vs-playground .
	docker tag lychee0/vs-playground lychee0/vs-playground:dev
	docker login
	docker push lychee0/vs-playground:dev
