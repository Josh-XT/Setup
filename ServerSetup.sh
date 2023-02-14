#!/bin/bash
# I use this script to handle initial package installs for Ubuntu 22.04 LTS servers
alias update='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo snap refresh'
sudo timedatectl set-timezone America/New_York
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
sudo apt remove docker docker-engine docker.io containerd runc -y
sudo apt update
sudo apt install ca-certificates curl gnupg lsb-release -y
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
sudo service docker start
curl -sL https://deb.nodesource.com/setup_18.x | sudo bash -
sudo apt install -y nodejs
sudo npm install --global yarn
sudo npm install -g npm@9.2.0
sudo snap install powershell --classic
sudo apt install -y apt-transport-https dotnet-sdk-6.0 aspnetcore-runtime-6.0
sudo apt install -y python3 python3-pip
pip install --upgrade pip
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
sudo snap refresh