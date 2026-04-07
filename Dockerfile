FROM osrf/ros:humble-desktop

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Create workspace and copy repository
WORKDIR /workspace

# ============================================================
# Layer 1: System base packages + locale
# ============================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
        # --- locale & crypto ---
        locales ca-certificates gnupg2 lsb-release \
        # --- build essentials ---
        build-essential cmake g++ gcc \
        pkg-config \
        # --- networking & utils ---
        curl wget git vim net-tools iputils-ping sudo jq unzip xz-utils procps \
        python3-pip \
        # --- messaging libs ---
        libzmq3-dev \
        python3-zmq \
        # --- X11 / display ---
        xvfb x11-utils mesa-utils wmctrl \
        # --- OpenGL / Mesa runtime ---
        libgl1-mesa-glx libglu1-mesa \
        libxrandr2 libxinerama1 libxcursor1 libxi6 \
        # --- Vulkan runtime ---
        libvulkan1 vulkan-tools mesa-vulkan-drivers \
        # --- misc ---
        software-properties-common xdg-user-dirs \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# Configure bashrc for root (Proxy + PS1 + ROS)
RUN echo "export http_proxy=http://127.0.0.1:7897" >> /root/.bashrc && \
    echo "export https_proxy=http://127.0.0.1:7897" >> /root/.bashrc && \
    echo 'export PS1="\[\033[01;31m\]\u@$CONTAINER_NAME:\w# \[\033[00m\]"' >> /root/.bashrc && \
    echo 'if [ -f /opt/ros/humble/setup.bash ]; then source /opt/ros/humble/setup.bash; fi' >> /root/.bashrc

# ============================================================
# Layer 2: Upgrade libstdc++ for GLIBCXX_3.4.32
# ============================================================
RUN add-apt-repository universe && \
    add-apt-repository ppa:ubuntu-toolchain-r/test -y && \
    apt-get update && \
    apt-get install --only-upgrade libstdc++6 -y && \
    rm -rf /var/lib/apt/lists/*

# ============================================================
# Layer 3: Install colcon (ros-humble-desktop already in base image)
# ============================================================
RUN apt-get update && \
    apt-get install -y python3-colcon-common-extensions && \
    rm -rf /var/lib/apt/lists/*

# ============================================================
# Layer 4: Create non-root user for development: matrix_user
# ============================================================
RUN useradd -m -s /bin/bash matrix_user && \
    echo "matrix_user:matrix" | chpasswd && \
    echo "matrix_user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/matrix_user && \
    chmod 0440 /etc/sudoers.d/matrix_user && \
    chown -R matrix_user:matrix_user /workspace

# Create startup script for permission fix (will be executed on login)
RUN echo '#!/bin/bash' > /etc/profile.d/fix-input-permissions.sh && \
    echo 'sudo chmod 666 /dev/input/* 2>/dev/null || true' >> /etc/profile.d/fix-input-permissions.sh && \
    echo 'sudo chmod 666 /dev/input/by-id/* 2>/dev/null || true' >> /etc/profile.d/fix-input-permissions.sh && \
    echo 'sudo chmod 666 /dev/input/by-path/* 2>/dev/null || true' >> /etc/profile.d/fix-input-permissions.sh && \
    chmod +x /etc/profile.d/fix-input-permissions.sh

# Switch to the new user
USER matrix_user
ENV HOME=/home/matrix_user
WORKDIR /workspace

# Source ROS setup & Configure bashrc for matrix_user (Proxy + PS1)
RUN echo "export http_proxy=http://127.0.0.1:7897" >> /home/matrix_user/.bashrc && \
    echo "export https_proxy=http://127.0.0.1:7897" >> /home/matrix_user/.bashrc && \
    echo 'export PS1="\[\033[01;32m\]\u@$CONTAINER_NAME:\w$ \[\033[00m\]"' >> /home/matrix_user/.bashrc && \
    echo "source /opt/ros/humble/setup.bash" >> /home/matrix_user/.bashrc && \
    echo "if [ -f /workspace/install/setup.bash ]; then source /workspace/install/setup.bash; fi" >> /home/matrix_user/.bashrc

# Entrypoint to source environment and forward X/ROS usage
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN sudo chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]
