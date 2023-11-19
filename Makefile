PROJET_PATH := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
API_DOCKER_NAME := imagenet-service
API_DOCKER_FILE := ${PROJET_PATH}/docker/api.dockerfile

docker-build:
	docker build -f ${API_DOCKER_FILE} -t ${API_DOCKER_NAME} .

docker-run:
	docker run -it --rm -p 8000:8000 ${API_DOCKER_NAME}

docker-clean:
	docker rmi ${API_DOCKER_NAME}