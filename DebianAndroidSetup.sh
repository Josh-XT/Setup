#!/bin/bash

#-------------------------------------------------------------------------------
# ALIASES & GIT CONFIGURATION
#-------------------------------------------------------------------------------
git config --global submodule.recurse true
git config --global credential.helper store
git config --global user.email "admin@agixt.com"
git config --global user.name "admin"
sudo apt install curl python3-pip -y
python3 -m pip install --upgrade pip
python3 -m pip install --upgrade setuptools wheel tzlocal python-dotenv
echo "alias update='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo snap refresh'" > "$HOME/.bash_aliases"
echo "alias docker-compose='docker compose'" >> "$HOME/.bash_aliases"
echo "alias python='python3'" >> "$HOME/.bash_aliases"
echo "alias pip='pip3'" >> "$HOME/.bash_aliases"

# Set error handling
set -e

#-------------------------------------------------------------------------------
# LOGGING SETUP
#-------------------------------------------------------------------------------
LOG_FILE="/var/log/setup_script_debian.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | sudo tee -a "$LOG_FILE"
}

#-------------------------------------------------------------------------------
# DOCKER INSTALLATION
#-------------------------------------------------------------------------------
log_message "Starting Docker installation"
if ! command -v docker &> /dev/null; then
    log_message "Docker not found. Attempting to install..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
    log_message "Docker is already installed."
fi

docker --version
docker compose version
log_message "Reboot the system to complete the installation."