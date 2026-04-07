#!/bin/bash

CONTAINER_NAME="MATRiX"

if [ $(docker ps -aq -f name=$CONTAINER_NAME | wc -l) -eq 0 ]; then
    echo "Container $CONTAINER_NAME does not exist. Please check the container name or create the container."
    exit 1
fi

CONTAINER_STATUS=$(docker inspect -f '{{.State.Running}}' $CONTAINER_NAME)

if [ "$CONTAINER_STATUS" == "true" ]; then
    echo "Container $CONTAINER_NAME is already running. Attaching to the container..."
else
    echo "Container $CONTAINER_NAME is not running. Restarting container..."
    docker start $CONTAINER_NAME
fi

echo "Attaching to container $CONTAINER_NAME as matrix_user..."

# Determine DISPLAY: use host value if set, otherwise auto-detect from X11 socket
if [ -z "$DISPLAY" ]; then
    # SSH session: detect from /tmp/.X11-unix
    X_SOCKET=$(ls /tmp/.X11-unix/ 2>/dev/null | head -1)
    if [ -n "$X_SOCKET" ]; then
        DISPLAY=":${X_SOCKET#X}"
        echo "[INFO] SSH session detected, using DISPLAY=$DISPLAY"
    else
        echo "[WARN] No X11 display found. GUI apps may not work."
    fi
fi

docker exec -it -u matrix_user -e DISPLAY=$DISPLAY $CONTAINER_NAME /bin/bash
