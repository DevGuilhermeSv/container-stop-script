#!/bin/bash

ADMIN_CONTAINER_NAME=$1
REPO_SLUG=$2
PORT=$3

if docker run -d -p $PORT:3000 --name $ADMIN_CONTAINER_NAME $REPO_SLUG:latest
then echo "Deploy success!"
else echo "Deploy failed, returnig to last version"
    docker rename '${ADMIN_CONTAINER_NAME}_older' '${ADMIN_CONTAINER_NAME}'
    docker start $ADMIN_CONTAINER_NAME
    exit 1
fi