#!/bin/bash
set -e

# MATRiX Docker run script with GPU support
# This script launches the matrix-dev container with proper GPU, X11, and network setup

IMAGE_NAME="zsibot/matrix-dev:latest"
CONTAINER_NAME="MATRiX"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Check and remove existing container
echo "[INFO] Checking if container '$CONTAINER_NAME' already exists..."
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "[INFO] Container exists. Stopping and removing old container..."
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm "$CONTAINER_NAME" 2>/dev/null || true
fi

# Allow X11 connections
echo "[INFO] Allowing X11 connections from local containers..."
xhost +local:root || echo "[WARN] xhost command failed - X11 forwarding may not work"

# Get host input group GID
INPUT_GID=$(getent group input | cut -d: -f3)

echo "[INFO] Starting container '$CONTAINER_NAME' with GPU support..."

docker run -itd \
  --name "$CONTAINER_NAME" \
  --network host \
  --ipc=host \
  --privileged \
  --gpus all \
  \
  `# === GPU / OpenGL / Vulkan ===` \
  --device=/dev/dri \
  --env="NVIDIA_VISIBLE_DEVICES=all" \
  --env="NVIDIA_DRIVER_CAPABILITIES=all" \
  --env="VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json" \
  --volume="/usr/share/vulkan:/usr/share/vulkan:ro" \
  --volume="/usr/share/glvnd:/usr/share/glvnd:ro" \
  \
  `# === X11 Display ===` \
  --env="DISPLAY=$DISPLAY" \
  --env="QT_X11_NO_MITSHM=1" \
  --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
  \
  `# === Input devices ===` \
  --volume="/dev/bus/usb:/dev/bus/usb" \
  --volume="/etc/udev:/etc/udev" \
  --volume="/dev/input:/dev/input" \
  --group-add video \
  --group-add "$INPUT_GID" \
  \
  `# === Project volumes ===` \
  --volume="$PROJECT_ROOT:/workspace" \
  --volume="/media/$USER:/media" \
  --volume="/etc/localtime:/etc/localtime:ro" \
  \
  `# === Container config ===` \
  --env="CONTAINER_NAME=$CONTAINER_NAME" \
  --workdir=/workspace \
  \
  "$IMAGE_NAME" \
  "$@"

echo "[INFO] Configuring container permissions..."
# Fix input permissions and ensure matrix_user is in correct groups
# Wait for container to be fully up
sleep 2
docker exec -u 0 "$CONTAINER_NAME" bash -c "
    INPUT_GID=$(getent group input | cut -d: -f3)
    
    # 1. Ensure input group exists with host GID
    if [ ! -z \"\$INPUT_GID\" ]; then
        if getent group input > /dev/null 2>&1; then
            groupmod -g \$INPUT_GID input 2>/dev/null || true
        else
            groupadd -g \$INPUT_GID input 2>/dev/null || true
        fi
    fi

    # 2. Add matrix_user to critical groups
    usermod -aG video,input,sudo matrix_user 2>/dev/null || true

    # 3. Force permissions (the ultimate fix)
    chmod -R 666 /dev/input/* 2>/dev/null || true
    chmod -R 666 /dev/input/by-id/* 2>/dev/null || true
    chmod -R 666 /dev/input/by-path/* 2>/dev/null || true
    
    echo 'Permissions set for matrix_user.'
"

echo "[INFO] Container '$CONTAINER_NAME' is ready."
echo "To enter the container: docker/docker_join.sh"
