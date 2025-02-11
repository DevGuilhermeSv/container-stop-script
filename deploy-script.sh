#!/bin/bash

CONTAINER_NAME=$1
REPO_SLUG=$2
PORT_HOST=$3
PORT_CONTAINER=$4
DOCKER_ARGUMENTS=$5

# Verifica se o container ${CONTAINER_NAME}_backup existe
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}_backup$"; then
  echo "Parando o container ${CONTAINER_NAME}_backup..."
  docker stop "${CONTAINER_NAME}_backup" || true
  docker rename "${CONTAINER_NAME}_backup" "${CONTAINER_NAME}_older"
else
  echo "O container ${CONTAINER_NAME}_backup não existe."
fi

# Verifica se o container $CONTAINER_NAME existe
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Parando o container ${CONTAINER_NAME}..."
  docker stop "${CONTAINER_NAME}"

  echo "Renomeando o container ${CONTAINER_NAME} para ${CONTAINER_NAME}_backup..."
  docker rename "${CONTAINER_NAME}" "${CONTAINER_NAME}_backup"
else
  echo "O container ${CONTAINER_NAME} não existe."
fi

# Tenta iniciar o novo container
if docker run -d -p "$PORT_HOST":"$PORT_CONTAINER" $DOCKER_ARGUMENTS --name "$CONTAINER_NAME" "$REPO_SLUG:latest"; then
    echo "Deploy success!"
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}_older$"; then
        docker rm "${CONTAINER_NAME}_older"
else
    echo "Deploy failed, returning to last version"
    # Restaura o backup, se existir
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}_backup$"; then
        docker rename "${CONTAINER_NAME}_backup" "$CONTAINER_NAME"
        docker start "$CONTAINER_NAME"
        
        # Renomeia o container Older, se existir
        if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}_older$"; then
            docker rename "${CONTAINER_NAME}_older" "${CONTAINER_NAME}_backup"
        fi
    fi
    exit 1
fi
