#!/bin/bash
echo "alias update='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo snap refresh'" > "$HOME/.bash_aliases"
# Update APT
sudo apt-get update
sudo add-apt-repository ppa:dotnet/backports
sudo apt update && sudo apt upgrade -y && sudo snap refresh
sudo apt install -y wget
# OpenSSL
wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb
rm libssl1.1_1.1.1f-1ubuntu2_amd64.deb
sudo chmod +x UbuntuSetup.sh
sudo ./UbuntuSetup.sh
# Python
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1
sudo update-alternatives --set python3 /usr/bin/python3.10
python3.10 -m pip install --upgrade pip setuptools wheel
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
# Brave
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install -y brave-browser
# APT Packages
sudo apt install -y libpq-dev
sudo apt install -y evolution 
sudo apt install -y evolution-ews 
sudo apt install -y gnome-boxes 
sudo apt install -y apt-transport-https
sudo apt install -y piper
sudo apt install -y software-properties-common
sudo apt install -y ocl-icd-opencl-dev opencl-headers clinfo libclblast-dev libopenblas-dev cmake gcc g++
sudo apt install -y node-typescript make nodejs npm gnome-shell-extensions
sudo apt install -y dotnet-sdk-8.0 aspnetcore-runtime-8.0
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
# Additional updates
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo snap refresh
# Pop Shell
RELEASE_INFO = lsb_release -a
CODENAME = $(echo $RELEASE_INFO | grep "Codename" | awk '{print $2}')
git clone https://github.com/pop-os/shell -b "master_$CODENAME"
cd shell
make local-install -s
# A reboot or log out is required to complete the installation of Pop Shell, it can take a few minutes to appear in the GNOME Extensions app.