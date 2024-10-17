#!/bin/bash
echo "alias update='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo snap refresh'" > "$HOME/.bash_aliases"
# Update APT
sudo apt-get update
sudo apt update && sudo apt upgrade -y && sudo snap refresh
sudo apt install -y wget
# OpenSSL
wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb
rm libssl1.1_1.1.1f-1ubuntu2_amd64.deb
sudo chmod +x UbuntuSetup.sh
sudo ./UbuntuSetup.sh
# Docker
sudo usermod -aG docker $USER
sudo systemctl restart docker
# Git
git config --global submodule.recurse true
git config --global credential.helper store
git config --global user.email "josh@devxt.com"
git config --global user.name "Josh XT"
echo "Updates" > ~/.gitmessage
git config --global commit.template ~/.gitmessage
# APT Packages
sudo apt install -y libpq-dev
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
sudo snap install --edge spotify
# NodeJS
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
nvm install --lts
nvm use --lts
# Cleanup
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo snap refresh