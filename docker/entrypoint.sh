#!/bin/bash
# =============================================================
# Universal ROS environment wrapper
# Used as both:
#   1. Docker ENTRYPOINT  (auto-sources env on container start)
#   2. CLI helper via symlink "rosenv" in PATH
#      Usage: docker exec container rosenv ros2 topic list
# =============================================================
set -eo pipefail

# Source ROS2 environment (temporarily disable -u for ROS scripts)
set +u
[ -f /opt/ros/humble/setup.bash ]        && source /opt/ros/humble/setup.bash
[ -f /workspace/install/setup.bash ]     && source /workspace/install/setup.bash
set -u

# Ensure XDG_RUNTIME_DIR exists (needed by GUI apps like Gazebo/RViz)
if [ -n "${XDG_RUNTIME_DIR:-}" ]; then
    mkdir -p "$XDG_RUNTIME_DIR" 2>/dev/null || true
    chmod 700 "$XDG_RUNTIME_DIR" 2>/dev/null || true
fi

# If called with arguments, execute them; otherwise start a shell
if [ $# -gt 0 ]; then
    exec "$@"
else
    exec /bin/bash
fi
