#!/bin/bash

#-------------------------------------------------------------------------------
# ALIASES & GIT CONFIGURATION
#-------------------------------------------------------------------------------
# Set error handling first to catch any issues early
set -e

# Update package list and install prerequisites
sudo apt-get update
sudo apt-get install -y curl git python3-pip

# Configure Git
git config --global submodule.recurse true
git config --global credential.helper store
git config --global user.email "admin@agixt.com"
git config --global user.name "admin"

# Upgrade pip and install common Python packages
pip install --upgrade tzlocal python-dotenv --break-system-packages

# Create aliases in .bash_aliases
echo "alias update='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y'" > "$HOME/.bash_aliases"
echo "alias docker-compose='docker compose'" >> "$HOME/.bash_aliases"
echo "alias python='python3'" >> "$HOME/.bash_aliases"
echo "alias pip='pip3'" >> "$HOME/.bash_aliases"

#-------------------------------------------------------------------------------
# LOGGING SETUP
#-------------------------------------------------------------------------------
LOG_FILE="/var/log/setup_script_debian.log"

# Function to log messages
log_message() {
    # Use sudo to write to the log file, as it's in /var/log
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | sudo tee -a "$LOG_FILE"
}

#-------------------------------------------------------------------------------
# DOCKER INSTALLATION
#-------------------------------------------------------------------------------
log_message "Starting Docker installation"
if ! command -v docker &> /dev/null; then
    log_message "Docker not found. Attempting to install..."
    # Add Docker's official GPG key
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Set up the repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker Engine
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    log_message "Docker installed successfully."
else
    log_message "Docker is already installed."
fi

#-------------------------------------------------------------------------------
# DOCKER PERMISSIONS & SERVICE SETUP
#-------------------------------------------------------------------------------
log_message "Configuring Docker permissions and service"

# Add current user to docker group
log_message "Adding user $USER to docker group"
sudo usermod -aG docker "$USER"

# Enable and start Docker service
log_message "Enabling and starting Docker service"
sudo systemctl enable docker
sudo systemctl start docker

log_message "Docker permissions configured. You may need to log out and back in for group changes to take effect."

#-------------------------------------------------------------------------------
# VERIFICATION
#-------------------------------------------------------------------------------
log_message "Verifying installations."
docker --version
docker compose version
python3 --version

log_message "Setup complete. Please log out and back in (or reboot) for Docker group permissions to take effect, and source your .bash_aliases file to use new aliases."