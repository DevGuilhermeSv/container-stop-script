#!/bin/bash

ADMIN_CONTAINER_NAME=$1
REPO_SLUG=$2
PORT=$3
PORT_CONTAINER=$4

if docker run -d -p $PORT_HOST:$PORT_CONTAINER --name $ADMIN_CONTAINER_NAME $REPO_SLUG:latest
then echo "Deploy success!"
else echo "Deploy failed, returnig to last version"
    docker rename '${ADMIN_CONTAINER_NAME}_older' '${ADMIN_CONTAINER_NAME}'
    docker start $ADMIN_CONTAINER_NAME
    exit 1
fi
