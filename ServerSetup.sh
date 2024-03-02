#!/bin/bash
echo "alias update='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo snap refresh'" >> ~/.bashrc
sudo timedatectl set-timezone America/New_York
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
sudo apt remove docker docker-engine docker.io containerd runc -y
sudo add-apt-repository ppa:deadsnakes/ppa 
sudo apt update
sudo apt install python3.10 python3-pip -y
sudo apt install ca-certificates curl gnupg lsb-release -y
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose -y
sudo service docker start
