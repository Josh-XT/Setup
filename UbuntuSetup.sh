#!/bin/bash
set -e

# =====================================================
# Variables
# =====================================================
LOG_FILE="/var/log/setup_script.log"
CUDA_VERSION="13-0"
CUDA_DEB_VERSION="13.0.2-580.95.05-1"
COMPOSE_VERSION="v2.30.3"

# Detect real user
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
VENV_DIR="$REAL_HOME/.venvs/default"
COMPOSE_PLUGIN_DIR="/usr/local/lib/docker/cli-plugins"

# =====================================================
# Logging
# =====================================================
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log_message "Starting setup script as user: $REAL_USER"

# =====================================================
# Bash aliases
# =====================================================
log_message "Configuring bash aliases"

cat > "$REAL_HOME/.bash_aliases" <<EOF
alias update='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo snap refresh'
alias docker-compose='docker compose'
EOF

chown "$REAL_USER:$REAL_USER" "$REAL_HOME/.bash_aliases"

# =====================================================
# Git configuration
# =====================================================
log_message "Configuring git"

sudo -u "$REAL_USER" git config --global submodule.recurse true
sudo -u "$REAL_USER" git config --global credential.helper store
sudo -u "$REAL_USER" git config --global user.email "admin@agixt.com"
sudo -u "$REAL_USER" git config --global user.name "admin"

# =====================================================
# Base dependencies
# =====================================================
log_message "Installing base dependencies"

sudo apt-get update
sudo apt-get install -y \
    curl wget apt-transport-https ca-certificates \
    software-properties-common gnupg lsb-release \
    linux-headers-$(uname -r) \
    python3 python3-venv python3-full

# =====================================================
# Python virtual environment (PEP 668 safe)
# =====================================================
log_message "Setting up Python virtual environment"

mkdir -p "$REAL_HOME/.venvs"
chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/.venvs"

if [ ! -d "$VENV_DIR" ]; then
    sudo -u "$REAL_USER" python3 -m venv "$VENV_DIR"
fi

source "$VENV_DIR/bin/activate"
pip install --upgrade pip setuptools wheel

# Auto-activate venv for interactive shells
if ! grep -q "auto-activate default venv" "$REAL_HOME/.bashrc"; then
    cat >> "$REAL_HOME/.bashrc" <<EOF

# auto-activate default venv
if [ -d "$VENV_DIR" ]; then
    source "$VENV_DIR/bin/activate"
fi
EOF
    chown "$REAL_USER:$REAL_USER" "$REAL_HOME/.bashrc"
fi

log_message "Python venv ready at $VENV_DIR"

# =====================================================
# Docker Engine
# =====================================================
log_message "Installing Docker Engine"

if ! command -v docker &>/dev/null; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
        sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin
    sudo usermod -aG docker "$REAL_USER"
fi

# =====================================================
# Docker Compose v2 (official plugin)
# =====================================================
log_message "Installing Docker Compose v2 plugin"

sudo mkdir -p "$COMPOSE_PLUGIN_DIR"

if ! docker compose version &>/dev/null; then
    sudo curl -SL \
        "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-x86_64" \
        -o "$COMPOSE_PLUGIN_DIR/docker-compose"
    sudo chmod +x "$COMPOSE_PLUGIN_DIR/docker-compose"
fi

# =====================================================
# NVIDIA / CUDA
# =====================================================
if lspci | grep -i nvidia &>/dev/null; then
    log_message "NVIDIA GPU detected"

    CURRENT_DRIVER=""
    if command -v nvidia-smi &>/dev/null; then
        CURRENT_DRIVER=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader | head -1 || true)
    fi

    DRIVER_OK=false
    if [[ -n "$CURRENT_DRIVER" ]]; then
        DRIVER_MAJOR=${CURRENT_DRIVER%%.*}
        [[ "$DRIVER_MAJOR" -ge 570 ]] && DRIVER_OK=true
    fi

    if [[ "$DRIVER_OK" == false ]]; then
        log_message "Installing NVIDIA driver and CUDA"

        sudo apt-get purge -y nvidia-driver-* libnvidia-* || true
        sudo apt-get autoremove -y

        wget -q https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin
        sudo mv cuda-ubuntu2404.pin /etc/apt/preferences.d/cuda-repository-pin-600

        wget -q "https://developer.download.nvidia.com/compute/cuda/${CUDA_DEB_VERSION%%-*}/local_installers/cuda-repo-ubuntu2404-${CUDA_VERSION}-local_${CUDA_DEB_VERSION}_amd64.deb"
        sudo dpkg -i cuda-repo-ubuntu2404-${CUDA_VERSION}-local_${CUDA_DEB_VERSION}_amd64.deb
        sudo cp /var/cuda-repo-ubuntu2404-${CUDA_VERSION}-local/*.gpg /usr/share/keyrings/

        sudo apt-get update
        sudo apt-get install -y cuda-${CUDA_VERSION}
    fi

    # CUDA env vars
    if ! grep -q "/usr/local/cuda" "$REAL_HOME/.bashrc"; then
        cat >> "$REAL_HOME/.bashrc" <<EOF

# CUDA
export PATH=/usr/local/cuda/bin:\$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:\$LD_LIBRARY_PATH
EOF
        chown "$REAL_USER:$REAL_USER" "$REAL_HOME/.bashrc"
    fi

    # NVIDIA Container Toolkit
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
        sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit.gpg

    curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit.gpg] https://#' | \
        sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

    sudo apt-get update
    sudo apt-get install -y nvidia-container-toolkit
    sudo nvidia-ctk runtime configure --runtime=docker
    sudo systemctl restart docker
fi

# =====================================================
# Verification
# =====================================================
log_message "Verification"

echo ""
echo "Docker:"
docker --version

echo ""
echo "Docker Compose:"
docker compose version

echo ""
echo "Python (venv):"
"$VENV_DIR/bin/python" --version
"$VENV_DIR/bin/pip" --version

if lspci | grep -i nvidia &>/dev/null; then
    echo ""
    echo "NVIDIA:"
    nvidia-smi || echo "nvidia-smi requires reboot"
fi

# =====================================================
# Done
# =====================================================
log_message "Setup complete"
log_message "REBOOT REQUIRED: sudo reboot"
