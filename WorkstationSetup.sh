#!/bin/bash
echo "alias update='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo snap refresh'" > "$HOME/.bash_aliases"
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
curl -sL https://deb.nodesource.com/setup_18.x | sudo bash -
sudo apt install -y nodejs
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb
wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb
rm libssl1.1_1.1.1f-1ubuntu2_amd64.deb
sudo apt update && sudo apt upgrade -y
sudo apt remove -y libreoffice*
sudo apt install -y python3
sudo apt install -y python3-pip
sudo apt install -y libpq-dev
sudo apt install -y docker-compose
sudo apt install -y snapd
sudo apt install -y evolution 
sudo apt install -y evolution-ews 
sudo apt install -y gnome-boxes 
sudo apt install -y apt-transport-https
sudo apt install -y code
sudo apt install -y piper
pip install --upgrade pip
sudo apt autoremove -y
sudo npm install --global yarn
sudo snap install powershell --classic
sudo snap install dotnet-sdk --classic --channel=7.0
sudo snap alias dotnet-sdk.dotnet dotnet
sudo snap install -y discord
sudo snap install onlyoffice-desktopeditors
sudo snap install --edge spotify
sudo snap install slack
sudo snap refresh
sudo pip install jupyter && pip install jupyter
sudo pip install matplotlib && pip install matplotlib
git config --global submodule.recurse true
git config --global user.email "josh@devxt.com"
git config --global user.name "Josh XT"
echo "Updates" > ~/.gitmessage
git config --global commit.template ~/.gitmessage
