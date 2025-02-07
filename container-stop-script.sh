#!/bin/bash

# Defina o nome do container
CONTAINER_NAME=$1

# Verifica se o container ${CONTAINER_NAME}_older existe
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}_older$"; then
  echo "Parando o container ${CONTAINER_NAME}_older..."
  docker stop "${CONTAINER_NAME}_older" 
else
  echo "O container ${CONTAINER_NAME}_older não existe."
fi

# Verifica se o container $CONTAINER_NAME existe
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Parando o container ${CONTAINER_NAME}..."
  docker stop "${CONTAINER_NAME}"

  echo "Renomeando o container ${CONTAINER_NAME} para ${CONTAINER_NAME}_older..."
  docker rename "${CONTAINER_NAME}" "${CONTAINER_NAME}_older"
else
  echo "O container ${CONTAINER_NAME} não existe."
fi
