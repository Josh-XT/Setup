#!/bin/bash
echo "alias update='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo snap refresh'" > "$HOME/.bash_aliases"
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
nvm install --lts
nvm use --lts
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb
wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb
rm libssl1.1_1.1.1f-1ubuntu2_amd64.deb
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/12.0.0/local_installers/cuda-repo-ubuntu2204-12-0-local_12.0.0-525.60.13-1_amd64.deb
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
  sudo tee /etc/apt/sources.list.d/signal-xenial.list
sudo dpkg -i cuda-repo-ubuntu2204-12-0-local_12.0.0-525.60.13-1_amd64.deb
sudo cp /var/cuda-repo-ubuntu2204-12-0-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda
sudo apt update && sudo apt upgrade -y && sudo snap refresh
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
sudo apt install -y signal-desktop
sudo apt install software-properties-common
pip install --upgrade pip
sudo npm install --global yarn
sudo snap install powershell --classic
sudo snap install dotnet-sdk --classic --channel=7.0
sudo snap alias dotnet-sdk.dotnet dotnet
sudo snap install -y discord
sudo snap install onlyoffice-desktopeditors
sudo snap install --edge spotify
sudo snap install slack
sudo pip install jupyter && pip install jupyter
sudo pip install matplotlib && pip install matplotlib
git config --global submodule.recurse true
git config --global user.email "josh@devxt.com"
git config --global user.name "Josh XT"
echo "Updates" > ~/.gitmessage
git config --global commit.template ~/.gitmessage
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo snap refresh