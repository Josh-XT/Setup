#!/bin/bash

# Set error handling
set -e

# Define variables
LOG_FILE="/var/log/nvidia_installation.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log_message "NVIDIA CUDA 12.3 and Container Toolkit installation script started"

# NVIDIA drivers and CUDA installation
log_message "Starting NVIDIA drivers and CUDA 12.3 installation"
if ! command -v nvidia-smi &> /dev/null; then
    log_message "NVIDIA drivers not found. Attempting to install..."
    sudo apt-get update
    sudo apt-get install -y linux-headers-$(uname -r)
    sudo apt-get install -y nvidia-driver-535 nvidia-utils-535
else
    log_message "NVIDIA drivers are already installed."
fi

if ! command -v nvcc &> /dev/null; then
    log_message "CUDA not found. Attempting to install CUDA 12.3..."
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
    sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600
    wget https://developer.download.nvidia.com/compute/cuda/12.3.0/local_installers/cuda-repo-ubuntu2204-12-3-local_12.3.0-545.23.06-1_amd64.deb
    sudo dpkg -i cuda-repo-ubuntu2204-12-3-local_12.3.0-545.23.06-1_amd64.deb
    sudo cp /var/cuda-repo-ubuntu2204-12-3-local/cuda-*-keyring.gpg /usr/share/keyrings/
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
sudo docker run --rm --gpus all nvidia/cuda:12.3.0-base-ubuntu22.04 nvidia-smi

log_message "Installation completed successfully"
log_message "Cleanup completed"
