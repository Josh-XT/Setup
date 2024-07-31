#!/bin/bash
echo "alias update='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo snap refresh'" >> ~/.bashrc
git config --global submodule.recurse true
git config --global credential.helper store
git config --global user.email "admin@agixt.com"
git config --global user.name "admin"
# Set error handling
set -e

# Define variables
LOG_FILE="/var/log/nvidia_installation.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Install Python 3.10 and pip
if ! command -v python3.10 &> /dev/null; then
    log_message "Python 3.10 not found. Attempting to install..."
    if command -v apt-get &> /dev/null; then
        sudo DEBIAN_FRONTEND=noninteractive apt-get update
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common
        sudo add-apt-repository -y ppa:deadsnakes/ppa
        sudo DEBIAN_FRONTEND=noninteractive apt-get update
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3.10 python3.10-venv python3.10-dev
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

# Create aliases
alias python=python3.10
alias pip="python3.10 -m pip"

# Add aliases to .bashrc for persistence
echo "alias python=python3.10" >> ~/.bashrc
echo "alias pip='python3.10 -m pip'" >> ~/.bashrc

log_message "Python 3.10 and pip installation and configuration completed."

log_message "NVIDIA CUDA and Container Toolkit installation script started"

# NVIDIA drivers and CUDA installation
log_message "Starting NVIDIA drivers and CUDA installation"
if ! command -v nvidia-smi &> /dev/null; then
    log_message "NVIDIA drivers not found. Attempting to install..."
    sudo apt-get update
    sudo apt-get install -y linux-headers-$(uname -r)
    sudo apt-get install -y nvidia-driver-535 nvidia-utils-535
else
    log_message "NVIDIA drivers are already installed."
fi

if ! command -v nvcc &> /dev/null; then
    log_message "CUDA not found. Attempting to install CUDA..."
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin
    sudo mv cuda-ubuntu2404.pin /etc/apt/preferences.d/cuda-repository-pin-600
    wget https://developer.download.nvidia.com/compute/cuda/12.5.1/local_installers/cuda-repo-ubuntu2404-12-5-local_12.5.1-555.42.06-1_amd64.deb
    sudo dpkg -i cuda-repo-ubuntu2404-12-5-local_12.5.1-555.42.06-1_amd64.deb
    sudo cp /var/cuda-repo-ubuntu2404-12-5-local/cuda-*-keyring.gpg /usr/share/keyrings/
    sudo apt-get update
    sudo apt-get -y install cuda
else
    log_message "CUDA is already installed."
fi

# Docker installation
log_message "Starting Docker installation"
if ! command -v docker &> /dev/null; then
    log_message "Docker not found. Attempting to install..."
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
else
    log_message "Docker is already installed."
fi

# NVIDIA Container Toolkit installation
log_message "Starting NVIDIA Container Toolkit installation"
log_message "Setting up NVIDIA Container Toolkit repository"

# NVIDIA's official instructions for adding the Container Toolkit repository
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor --batch --yes -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null

log_message "Updating package list"
sudo apt-get update

log_message "Installing NVIDIA Container Toolkit"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nvidia-container-toolkit

log_message "Configuring Docker daemon"
sudo nvidia-ctk runtime configure --runtime=docker

log_message "Restarting Docker daemon"
sudo systemctl restart docker

# Verification
log_message "Verifying installations"
nvidia-smi
nvcc --version
docker --version
docker-compose --version
python3.10 --version
log_message "Installation completed successfully"
log_message "Reboot the system to complete the installation."
