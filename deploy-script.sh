#!/bin/bash

CONTAINER_NAME=$1
REPO_SLUG=$2
PORT_HOST=$3
PORT_CONTAINER=$4
DOCKER_ARGUMENTS=$5

# Verifica se os parâmetros foram passados corretamente
if [ -z "$CONTAINER_NAME" ] || [ -z "$REPO_SLUG" ] || [ -z "$PORT_HOST" ] || [ -z "$PORT_CONTAINER" ]; then
    echo "Uso: $0 <container_name> <repo_slug> <port_host> <port_container> [docker_arguments]"
    exit 1
fi

# Verifica se o container ${CONTAINER_NAME}_backup existe
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}_backup$"; then
    echo "Parando e renomeando ${CONTAINER_NAME}_backup para ${CONTAINER_NAME}_older..."
    docker stop "${CONTAINER_NAME}_backup" 2>/dev/null
    docker rename "${CONTAINER_NAME}_backup" "${CONTAINER_NAME}_older"
fi

# Verifica se o container $CONTAINER_NAME existe
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Parando e renomeando ${CONTAINER_NAME} para ${CONTAINER_NAME}_backup..."
    docker stop "${CONTAINER_NAME}"
    docker rename "${CONTAINER_NAME}" "${CONTAINER_NAME}_backup"
fi

# Tenta iniciar o novo container
if docker run -d -p "$PORT_HOST":"$PORT_CONTAINER" ${DOCKER_ARGUMENTS:-} --name "$CONTAINER_NAME" "$REPO_SLUG:latest"; then
    echo "✅ Deploy success!"

    # Remove o backup antigo, se existir
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}_older$"; then
        echo "Removendo container de backup mais antigo (${CONTAINER_NAME}_older)..."
        docker rm "${CONTAINER_NAME}_older"
    fi
else
    echo "❌ Deploy failed, reverting to last version..."

    # Restaura o backup, se existir
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}_backup$"; then
        docker rename "${CONTAINER_NAME}_backup" "$CONTAINER_NAME"
        docker start "$CONTAINER_NAME"

        # Renomeia o container _older para _backup, se necessário
        if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}_older$"; then
            docker rename "${CONTAINER_NAME}_older" "${CONTAINER_NAME}_backup"
        fi
    fi

    exit 1
fi
