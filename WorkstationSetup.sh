#!/bin/bash
echo "alias update='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo snap refresh'" > "$HOME/.bash_aliases"
# Update APT
sudo apt-get update
sudo apt update && sudo apt upgrade -y && sudo snap refresh
# Microsoft Packages
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
# Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb
# OpenSSL
wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb
rm libssl1.1_1.1.1f-1ubuntu2_amd64.deb
# Remove LibreOffice
sudo apt remove -y libreoffice*
# Git
sudo apt install -y git
git config --global submodule.recurse true
git config --global credential.helper store
git config --global user.email "josh@devxt.com"
git config --global user.name "Josh XT"
echo "Updates" > ~/.gitmessage
git config --global commit.template ~/.gitmessage
# Python
sudo apt install -y python3
sudo apt install -y python3-pip
pip install --upgrade pip
sudo pip install jupyter && pip install jupyter
sudo pip install matplotlib && pip install matplotlib
# APT Packages
sudo apt install -y curl
sudo apt install -y libpq-dev
sudo apt install -y docker-compose
sudo apt install -y evolution 
sudo apt install -y evolution-ews 
sudo apt install -y gnome-boxes 
sudo apt install -y apt-transport-https
sudo apt install -y piper
sudo apt install -y software-properties-common
sudo apt install -y ocl-icd-opencl-dev opencl-headers clinfo libclblast-dev libopenblas-dev cmake gcc g++
# Snap
sudo apt install -y snapd
sudo snap install code --classic
sudo snap install dotnet-sdk --classic --channel=8.0
sudo snap alias dotnet-sdk.dotnet dotnet
sudo snap install powershell --classic
sudo snap install discord
sudo snap install onlyoffice-desktopeditors
sudo snap install --edge spotify
sudo snap install slack
# NodeJS
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
nvm install --lts
nvm use --lts
sudo npm install --global yarn
# Cuda things
sudo ubuntu-drivers install nvidia-driver-545
sudo apt install -y nvidia-utils-545
sudo apt install -y nvidia-cuda-toolkit
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
# Cleanup
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo snap refresh
