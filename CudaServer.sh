#!/bin/bash
log_message "alias update='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo snap refresh'" >> ~/.bashrc
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
log_message "alias python=python3.10" >> ~/.bashrc
log_message "alias pip='python3.10 -m pip'" >> ~/.bashrc

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
    log_message "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
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

# Function to get the LVM physical volume
get_lvm_pv() {
    vg_name=$(lvs --noheadings -o vg_name /dev/mapper/ubuntu--vg-ubuntu--lv | tr -d ' ')
    pv_device=$(pvs --noheadings -o pv_name | grep $(vgs --noheadings -o pv_name $vg_name | tr -d ' ') | tr -d ' ')
    log_message $pv_device
}

# Function to get total disk size
get_disk_size() {
    disk_device=$(log_message $1 | sed 's/p[0-9]*$//')
    size_kb=$(lsblk -ndo SIZE -b $disk_device | awk '{print int($1/1024)}')
    log_message $size_kb
}

# Function to get sizes of all partitions
get_partition_sizes() {
    disk_device=$(log_message $1 | sed 's/p[0-9]*$//')
    lsblk -nlo SIZE,NAME,TYPE -b $disk_device | awk '{print int($1/1024), $2, $3}'
}

# Function to extend the logical volume and filesystem
extend_lv_and_fs() {
    # Get the root logical volume
    root_lv="/dev/mapper/ubuntu--vg-ubuntu--lv"

    # Get the current size of the LV in KB
    current_size=$(lvs --noheadings --units k -o lv_size $root_lv | tr -d ' K' | cut -d'.' -f1)

    # Get the total disk size and sizes of all partitions
    lvm_pv=$1
    total_disk_size=$(get_disk_size $lvm_pv)
    log_message "Total disk size: $((total_disk_size / 1024 / 1024))GB"

    log_message "Partition sizes:"
    get_partition_sizes $lvm_pv

    # Get the size of the LVM partition
    lvm_partition_size=$(lsblk -nlo SIZE,NAME -b | grep "${lvm_pv##*/}" | awk '{print int($1/1024)}')
    log_message "LVM partition size: $((lvm_partition_size / 1024 / 1024))GB"

    # Calculate the size to extend in KB, leaving a 4MB buffer for LVM metadata
    extend_size=$((lvm_partition_size - current_size - 4096))  # 4MB = 4096KB

    log_message "Current LV size: $((current_size / 1024 / 1024))GB"
    log_message "Available space for extension: $((extend_size / 1024 / 1024))GB"

    if [ $extend_size -le 0 ]; then
        log_message "No significant space available for extension. Exiting."
        exit 0
    fi

    log_message "Extending the logical volume by $((extend_size / 1024))MB..."
    lvextend -L +${extend_size}K $root_lv

    log_message "Resizing the filesystem..."
    resize2fs $root_lv
}
# Main execution
log_message "Starting LVM expansion process..."

# Get the LVM PV
lvm_pv=$(get_lvm_pv)
log_message "LVM Physical Volume: $lvm_pv"

# Print current LV size
log_message "Current LV size:"
lvs --units g /dev/mapper/ubuntu--vg-ubuntu--lv

# Extend LV and filesystem
extend_lv_and_fs $lvm_pv

# Print new LV size
log_message "New LV size:"
lvs --units g /dev/mapper/ubuntu--vg-ubuntu--lv

log_message "LVM expansion process completed."
df -h
lsblk

# Verification
log_message "Verifying installations"
nvidia-smi
nvcc --version
docker --version
docker-compose --version
python3.10 --version
log_message "Installation completed successfully"
log_message "Reboot the system to complete the installation."
