#!/bin/bash

set -e

BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")";pwd)
IMAGE_NAME="draw_table"
IMAGE_TAG="centos"
CONTAINER_NAME="draw_table_centos_container"
PROJECT_PATH=$(basename ${BASE_DIR})

# build docker image
if docker images | awk '{print $1":"$2}' | grep -q "${IMAGE_NAME}:${IMAGE_TAG}"; then
    echo "Docker image ${IMAGE_NAME}:${IMAGE_TAG} already exists."
else
    echo "Docker image ${IMAGE_NAME}:${IMAGE_TAG} does not exist. Building..."
    docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" .
fi

# run docker container
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && cd .. && pwd )"

if docker ps -a | grep -q "${CONTAINER_NAME}"; then
    echo "Docker container ${CONTAINER_NAME} already exists."
    if docker ps | grep -q "${CONTAINER_NAME}"; then
        echo "Docker container ${CONTAINER_NAME} is already running. Entering the container..."
        docker exec -it ${CONTAINER_NAME} /bin/bash
    else
        echo "Docker container ${CONTAINER_NAME} exists but is not running. Starting the container..."
        docker start "${CONTAINER_NAME}" > /dev/null
        docker exec -it "${CONTAINER_NAME}" /bin/bash
    fi
else
    echo "Docker container ${CONTAINER_NAME} does not exist. Creating the container..."
    docker run --name "${CONTAINER_NAME}" -v "${ROOT_DIR}/${PROJECT_PATH}:/${PROJECT_PATH}" -w /${PROJECT_PATH} -v ~/.ssh:/root/.ssh -v ~/.gitconfig:/root/.gitconfig -it "${IMAGE_NAME}:${IMAGE_TAG}"
fi
