GO ?= go

.DEFAULT_GOAL := default

TAGS ?=

.PHONY: lint
lint:
	pre-commit install # pip install pre-commit
	pre-commit run --all-files

.PHONY: pt
pt:
	docker buildx build -f Dockerfile-vs-pytorch -t lychee0/vs-pytorch .

.PHONY: pt-dev
pt-dev:
	docker buildx build -f Dockerfile-vs-pytorch -t lychee0/vs-pytorch .
	docker tag lychee0/vs-pytorch lychee0/vs-pytorch:dev
	docker login
	docker push lychee0/vs-pytorch:dev

.PHONY: vs
vs:
	docker buildx build -f Dockerfile-vs-playground -t lychee0/vs-playground .

.PHONY: vs-dev
vs-dev:
	docker buildx build -f Dockerfile-vs-playground -t lychee0/vs-playground .
	docker tag lychee0/vs-playground lychee0/vs-playground:dev
	docker login
	docker push lychee0/vs-playground:dev