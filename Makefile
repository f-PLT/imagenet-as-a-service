## -- Basic variables
PROJECT_PATH := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
CONDA_TOOL := micromamba

## -- Docker variables
API_DOCKER_IMAGE := imagenet-service
API_DOCKER_CONTAINER_NAME := imagenet-service
API_DOCKER_FILE := ${PROJECT_PATH}/Dockerfile

#### Install ####

.PHONY: create-env
create-env:
	${CONDA_TOOL} env create -f environment.yml

.PHONY: install
install:
	poetry install

#### Docker ####

.PHONY: docker-build
docker-build: ## Build Docker container(s)
	docker build -f ${API_DOCKER_FILE} -t ${API_DOCKER_IMAGE} .

.PHONY: docker-run
docker-run:  ## Run docker container(s)
	docker run -it --name ${API_DOCKER_CONTAINER_NAME} --rm -p 8000:8000 ${API_DOCKER_IMAGE}

.PHONY: docker-run-dev
docker-run-dev:  ## Run docker container(s)
	docker run -it --name ${API_DOCKER_CONTAINER_NAME} -v `pwd`/imagenet_service:/home/worker/imagenet-service/imagenet_service:ro --rm -p 8000:8000 ${API_DOCKER_IMAGE}

.PHONY: docker-stop
docker-stop: ## Stop running docker container(s)
	docker stop ${API_DOCKER_CONTAINER_NAME} || true

.PHONY: docker-clean
docker-clean: docker-stop ## Destroy docker images
	docker rmi ${API_DOCKER_IMAGE}

#### Linting ####
.PHONY: check-lint
check-lint: ## Check code linting
	nox -s check

.PHONY: fix-lint
fix-lint: ## Fix code linting
	nox -s fix

#### Tests ####
.PHONY: test
test: ## Run tests
	nox -s test