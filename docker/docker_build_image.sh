#!/bin/bash
set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the project root (one level up from this script)
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

DOCKERFILE_PATH="$PROJECT_ROOT/Dockerfile"

IMAGE_NAME="zsibot/matrix-dev:latest"

echo "[INFO] Building Docker image: $IMAGE_NAME"
echo "[INFO] Project root: $PROJECT_ROOT"
echo "[INFO] Dockerfile location: $DOCKERFILE_PATH"

if [ ! -f "$DOCKERFILE_PATH" ]; then
  echo "[ERROR] Dockerfile not found: $DOCKERFILE_PATH"
  exit 1
fi

# Build the image
# -t: Tag the image
# -f: Specify the Dockerfile path
# .: Use the project root as the build context
docker build \
  -t "$IMAGE_NAME" \
  -f "$DOCKERFILE_PATH" \
  "$PROJECT_ROOT"

echo "[INFO] Successfully built image: $IMAGE_NAME"
echo "[INFO] To run the container: ./scripts/docker/docker_run_gpu.sh"
