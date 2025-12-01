#!/bin/bash
set -e

# Define variables
LOG_FILE="/var/log/setup_script.log"
CUDA_VERSION="13-0"
CUDA_DEB_VERSION="13.0.2-580.95.05-1"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log_message "Starting setup script"

# Setup bash aliases
echo "alias update='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo snap refresh'" > "$HOME/.bash_aliases"
echo "alias docker-compose='docker compose'" >> "$HOME/.bash_aliases"

# Git configuration
git config --global submodule.recurse true
git config --global credential.helper store
git config --global user.email "admin@agixt.com"
git config --global user.name "admin"

# Install base dependencies
sudo apt-get update
sudo apt-get install -y curl wget apt-transport-https ca-certificates software-properties-common gnupg lsb-release linux-headers-$(uname -r)

# Install Python 3.10 and pip
if ! command -v python3.10 &> /dev/null; then
    log_message "Python 3.10 not found. Attempting to install..."
    if command -v apt-get &> /dev/null; then
        sudo DEBIAN_FRONTEND=noninteractive apt-get update
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common
        sudo add-apt-repository -y ppa:deadsnakes/ppa
        sudo DEBIAN_FRONTEND=noninteractive apt-get update
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3.10 python3.10-venv python3.10-dev python3-pip
    elif command -v yum &> /dev/null; then
        sudo yum install -y centos-release-scl
        sudo yum install -y rh-python310
        source /opt/rh/rh-python310/enable
    else
        log_message "Unable to install Python 3.10. Please install it manually."
        exit 1
    fi
else
    log_message "Python 3.10 is already installed."
fi

# Ensure pip is installed for Python 3.10
if ! python3.10 -m pip --version &> /dev/null; then
    log_message "pip for Python 3.10 not found. Attempting to install..."
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python3.10 get-pip.py --user
    rm get-pip.py
fi
python3.10 -m pip install --upgrade pip setuptools wheel

log_message "Python 3.10 and pip installation and configuration completed."

# Docker installation
log_message "Starting Docker installation"
if ! command -v docker &> /dev/null; then
    log_message "Docker not found. Attempting to install..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --batch --yes -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker $USER
else
    log_message "Docker is already installed."
fi

# Check for NVIDIA GPU
if lspci | grep -i nvidia &> /dev/null; then
    log_message "NVIDIA GPU detected. Proceeding with NVIDIA driver and CUDA installation."

    # Check current driver version
    CURRENT_DRIVER=""
    if command -v nvidia-smi &> /dev/null; then
        CURRENT_DRIVER=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null | head -1 || echo "")
    fi

    # Need driver 570+ for RTX 50 series support with open kernel modules
    DRIVER_OK=false
    if [[ -n "$CURRENT_DRIVER" ]]; then
        DRIVER_MAJOR=$(echo "$CURRENT_DRIVER" | cut -d. -f1)
        if [[ "$DRIVER_MAJOR" -ge 570 ]]; then
            DRIVER_OK=true
            log_message "NVIDIA driver $CURRENT_DRIVER already installed and sufficient."
        else
            log_message "NVIDIA driver $CURRENT_DRIVER is too old. Need 570+ for RTX 50 series support."
        fi
    fi

    if [[ "$DRIVER_OK" == false ]]; then
        log_message "Installing NVIDIA drivers and CUDA (with open kernel modules for RTX 50 series support)..."
        
        # Remove old NVIDIA packages to avoid conflicts
        log_message "Removing old NVIDIA packages..."
        sudo apt-get purge -y nvidia-driver-* libnvidia-compute-* libnvidia-gl-* 2>/dev/null || true
        sudo apt-get autoremove -y

        # Install CUDA repo (includes 580-open driver)
        log_message "Setting up CUDA repository..."
        wget -q https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin
        sudo mv cuda-ubuntu2404.pin /etc/apt/preferences.d/cuda-repository-pin-600
        
        wget -q "https://developer.download.nvidia.com/compute/cuda/${CUDA_DEB_VERSION%%-*}/local_installers/cuda-repo-ubuntu2404-${CUDA_VERSION}-local_${CUDA_DEB_VERSION}_amd64.deb"
        sudo dpkg -i "cuda-repo-ubuntu2404-${CUDA_VERSION}-local_${CUDA_DEB_VERSION}_amd64.deb"
        sudo cp /var/cuda-repo-ubuntu2404-${CUDA_VERSION}-local/cuda-*-keyring.gpg /usr/share/keyrings/
        rm -f "cuda-repo-ubuntu2404-${CUDA_VERSION}-local_${CUDA_DEB_VERSION}_amd64.deb"
        
        sudo apt-get update
        
        # Install CUDA toolkit + driver (580-open comes bundled)
        # This supports RTX 30, 40, and 50 series
        log_message "Installing CUDA ${CUDA_VERSION} and drivers..."
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y cuda-${CUDA_VERSION}
    else
        # Driver is OK, just check if CUDA toolkit is installed
        if ! command -v nvcc &> /dev/null; then
            log_message "CUDA toolkit not found. Installing..."
            wget -q https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin
            sudo mv cuda-ubuntu2404.pin /etc/apt/preferences.d/cuda-repository-pin-600
            
            wget -q "https://developer.download.nvidia.com/compute/cuda/${CUDA_DEB_VERSION%%-*}/local_installers/cuda-repo-ubuntu2404-${CUDA_VERSION}-local_${CUDA_DEB_VERSION}_amd64.deb"
            sudo dpkg -i "cuda-repo-ubuntu2404-${CUDA_VERSION}-local_${CUDA_DEB_VERSION}_amd64.deb"
            sudo cp /var/cuda-repo-ubuntu2404-${CUDA_VERSION}-local/cuda-*-keyring.gpg /usr/share/keyrings/
            rm -f "cuda-repo-ubuntu2404-${CUDA_VERSION}-local_${CUDA_DEB_VERSION}_amd64.deb"
            
            sudo apt-get update
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y cuda-toolkit-${CUDA_VERSION}
        else
            log_message "CUDA is already installed."
        fi
    fi

    # Add CUDA to PATH if not already there
    if ! grep -q "cuda" "$HOME/.bashrc" 2>/dev/null; then
        log_message "Adding CUDA to PATH..."
        echo '' >> "$HOME/.bashrc"
        echo '# CUDA' >> "$HOME/.bashrc"
        echo 'export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}' >> "$HOME/.bashrc"
        echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}' >> "$HOME/.bashrc"
    fi

    # NVIDIA Container Toolkit installation
    log_message "Starting NVIDIA Container Toolkit installation"
    
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor --batch --yes -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null

    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nvidia-container-toolkit

    log_message "Configuring Docker daemon for NVIDIA runtime"
    sudo nvidia-ctk runtime configure --runtime=docker

    log_message "Restarting Docker daemon"
    sudo systemctl restart docker
else
    log_message "No NVIDIA GPU detected. Skipping NVIDIA driver and CUDA installation."
fi

# Verification
log_message "============================================"
log_message "Verifying installations"
log_message "============================================"

echo ""
echo "Docker:"
docker --version
docker compose --version

echo ""
echo "Python:"
python3.10 --version

if lspci | grep -i nvidia &> /dev/null; then
    echo ""
    echo "NVIDIA Driver:"
    nvidia-smi || echo "nvidia-smi not available yet (reboot required)"
    
    echo ""
    echo "CUDA:"
    /usr/local/cuda/bin/nvcc --version 2>/dev/null || echo "nvcc not in PATH yet (reboot or source ~/.bashrc)"
fi

log_message "============================================"
log_message "Setup complete!"
log_message "============================================"
log_message ""
log_message "IMPORTANT: Reboot the system to complete the installation:"
log_message "  sudo reboot"
log_message ""
log_message "After reboot, verify GPU access in Docker:"
log_message "  docker run --rm --gpus all nvidia/cuda:12.8.0-base-ubuntu24.04 nvidia-smi"
