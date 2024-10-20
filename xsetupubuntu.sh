#!/bin/bash

# Setze Fehlerbehandlung
set -e

# Definiere Variablen
LOG_FILE="/var/log/nvidia_installation.log"

# Funktion zum Protokollieren von Nachrichten
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Backup der bestehenden .bashrc und .bash_aliases
log_message "Erstelle Backups von bestehenden Konfigurationsdateien."
cp ~/.bashrc ~/.bashrc.backup
cp ~/.bash_aliases ~/.bash_aliases.backup 2>/dev/null || touch ~/.bash_aliases

# Füge Alias für Update hinzu
log_message "Füge Alias für update hinzu."
echo "alias update='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo snap refresh'" >> ~/.bash_aliases

# Lade Aliases in die aktuelle Shell
source ~/.bash_aliases

# Git Konfiguration
log_message "Konfiguriere Git."
git config --global submodule.recurse true
git config --global credential.helper store
git config --global user.email "vesiassr@gmail.com"
git config --global user.name "Vesias"
echo "Updates" > ~/.gitmessage
git config --global commit.template ~/.gitmessage

# Installiere Python 3.10 und pip
log_message "Überprüfe und installiere Python 3.10 und pip."
if ! command -v python3.10 &> /dev/null; then
    log_message "Python 3.10 nicht gefunden. Versuche zu installieren..."
    sudo DEBIAN_FRONTEND=noninteractive apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common curl
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    sudo DEBIAN_FRONTEND=noninteractive apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3.10 python3.10-venv python3.10-dev
else
    log_message "Python 3.10 ist bereits installiert."
fi

# Sicherstellen, dass pip für Python 3.10 installiert ist
if ! python3.10 -m pip --version &> /dev/null; then
    log_message "pip für Python 3.10 nicht gefunden. Versuche zu installieren..."
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python3.10 get-pip.py --user
    rm get-pip.py
else
    log_message "pip für Python 3.10 ist bereits installiert."
fi

# Erstelle Aliase für python und pip
log_message "Erstelle Aliase für python und pip."
echo "alias python=python3.10" >> ~/.bash_aliases
echo "alias pip='python3.10 -m pip'" >> ~/.bash_aliases

# Lade Aliases in die aktuelle Shell
source ~/.bash_aliases

log_message "Python 3.10 und pip Installation abgeschlossen."

# Installiere Chromium statt Google Chrome
log_message "Installiere Chromium anstelle von Google Chrome."
if ! command -v chromium-browser &> /dev/null; then
    sudo apt-get install -y chromium-browser
else
    log_message "Chromium ist bereits installiert."
fi

# Installiere Microsoft Packages
log_message "Installiere Microsoft-Pakete."
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

# Installiere OpenSSL (falls benötigt)
log_message "Installiere OpenSSL."
sudo apt-get install -y libssl1.1 || log_message "libssl1.1 ist bereits installiert oder nicht verfügbar."

# Entferne LibreOffice
log_message "Entferne LibreOffice."
sudo apt-get remove -y libreoffice*

# Installiere APT-Pakete
log_message "Installiere benötigte APT-Pakete."
sudo apt-get install -y \
    curl \
    libpq-dev \
    docker-compose \
    evolution \
    evolution-ews \
    gnome-boxes \
    apt-transport-https \
    piper \
    software-properties-common \
    ocl-icd-opencl-dev \
    opencl-headers \
    clinfo \
    libclblast-dev \
    libopenblas-dev \
    cmake \
    gcc \
    g++ \
    libfuse2 \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libgtk-3-0 \
    libgbm1 \
    libasound2 \
    libclblast1 \
    libgl1 \
    fonts-noto \
    libtinfo6 \
    linux-tools-$(uname -r) \
    iotop \
    htop \
    neofetch \
    bpytop \
    clang \
    cargo \
    libc6-i386 \
    libc6-x32 \
    libu2f-udev \
    samba-common-bin \
    exfat-fuse \
    default-jdk \
    unzip \
    tar \
    bzip2 \
    ntfs-3g \
    p7zip \
    flatpak \
    gdebi \
    gnome-tweaks \
    gnome-shell-extension-manager \
    vlc \
    ubuntu-restricted-extras

# Installiere Snap-Pakete
log_message "Installiere Snap-Pakete."
sudo snap install code --classic
sudo snap install dotnet-sdk --classic --channel=8.0
sudo snap alias dotnet-sdk.dotnet dotnet
sudo snap install powershell --classic
sudo snap install discord
sudo snap install onlyoffice-desktopeditors
sudo snap install --edge spotify
sudo snap install slack
sudo snap install go --classic

# Installiere NodeJS und yarn
log_message "Installiere NodeJS und yarn."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # Lädt nvm
nvm install --lts
nvm use --lts
sudo npm install --global yarn

# Installiere Docker (falls nicht bereits installiert)
log_message "Installiere Docker."
if ! command -v docker &> /dev/null; then
    log_message "Docker nicht gefunden. Versuche zu installieren..."
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

    # Füge Docker GPG Schlüssel hinzu
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Füge Docker Repository hinzu
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Aktualisiere die Paketliste und installiere Docker
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
else
    log_message "Docker ist bereits installiert."
fi

# Füge den aktuellen Benutzer zur Docker-Gruppe hinzu
log_message "Füge Benutzer zur Docker-Gruppe hinzu."
sudo usermod -aG docker $USER

# Installiere NVIDIA Container Toolkit
log_message "Starte NVIDIA Container Toolkit-Installation."

# Füge NVIDIA Container Toolkit Repository hinzu
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null

# Aktualisiere die Paketliste und installiere NVIDIA Container Toolkit
log_message "Aktualisiere die Paketliste."
sudo apt-get update

log_message "Installiere NVIDIA Container Toolkit."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nvidia-container-toolkit

# Konfiguriere Docker Daemon für NVIDIA Runtime
log_message "Konfiguriere Docker Daemon für NVIDIA Runtime."
sudo nvidia-ctk runtime configure --runtime=docker

# Starte Docker neu
log_message "Starte Docker Daemon neu."
sudo systemctl restart docker

# Installiere und konfiguriere Cockpit
log_message "Installiere und starte Cockpit."
sudo apt-get install -y cockpit cockpit-machines
sudo systemctl start cockpit

# Installiere Anaconda
log_message "Installiere Anaconda."
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm -rf ~/miniconda3/miniconda.sh
~/miniconda3/bin/conda init bash
~/miniconda3/bin/conda init zsh

# Installiere CMake und pkg-config (bereits installiert, aber nochmal sicherheitshalber)
log_message "Installiere CMake und pkg-config."
sudo apt-get install -y cmake pkg-config

# Installiere weitere wichtige Tools
log_message "Installiere weitere wichtige Tools."
sudo apt-get install -y gpg-agent wget exfat-fuse p7zip

# Installiere Flatpak-Pakete
log_message "Installiere Flatpak-Pakete."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.spotify.Client
flatpak install -y flathub com.transmissionbt.Transmission
flatpak install -y flathub com.obsproject.Studio

# Installiere LM Studio und NVIDIA AI Workbench
log_message "Installiere LM Studio und NVIDIA AI Workbench."
wget https://releases.lmstudio.ai/linux/0.2.19/beta/LM_Studio-0.2.19.AppImage
chmod +x LM_Studio-0.2.19.AppImage
# Optional: Starte LM Studio
# ./LM_Studio-0.2.19.AppImage &

wget https://workbench.download.nvidia.com/stable/workbench-desktop/0.57.3/NVIDIA-AI-Workbench-x86_64.AppImage
chmod +x NVIDIA-AI-Workbench-x86_64.AppImage
sudo mv NVIDIA-AI-Workbench-x86_64.AppImage /usr/local/bin/
sudo ./NVIDIA-AI-Workbench-x86_64.AppImage --no-sandbox &

# Installiere xpipe
log_message "Installiere xpipe."
bash <(curl -sL https://github.com/xpipe-io/xpipe/raw/master/get-xpipe.sh)

# Installiere Go-Protokolle
log_message "Installiere Go-Protokolle."
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
export PATH="$PATH:$(go env GOPATH)/bin"

# Clone und Build von grpc-go Beispielen
git clone -b v1.65.0 --depth 1 https://github.com/grpc/grpc-go
cd grpc-go/examples/helloworld
make
cd ../..

# Clone und Build von LocalAI
git clone https://github.com/mudler/LocalAI.git
cd LocalAI
make build
cd ..

# Installiere und konfiguriere UFW
log_message "Installiere und konfiguriere UFW."
sudo apt-get install -y ufw
sudo systemctl enable ufw
sudo systemctl start ufw
sudo ufw deny 22/tcp

# Füge Intel OneAPI und NVIDIA HPC SDK Repositorys hinzu
log_message "Füge Intel OneAPI und NVIDIA HPC SDK Repositorys hinzu."
wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | gpg --dearmor | sudo tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list

curl https://developer.download.nvidia.com/hpc-sdk/ubuntu/DEB-GPG-KEY-NVIDIA-HPC-SDK | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-hpcsdk-archive-keyring.gpg
echo 'deb [signed-by=/usr/share/keyrings/nvidia-hpcsdk-archive-keyring.gpg] https://developer.download.nvidia.com/hpc-sdk/ubuntu/amd64 /' | sudo tee /etc/apt/sources.list.d/nvhpc.list

# Aktualisiere die Paketliste und installiere NVIDIA HPC SDK
log_message "Aktualisiere die Paketliste und installiere NVIDIA HPC SDK."
sudo apt-get update
sudo apt-get install -y nvhpc-24-5 intel-basekit intel-hpckit

# Installiere Ollama
log_message "Installiere Ollama."
curl -fsSL https://ollama.com/install.sh | sh

# Konfiguriere CPU-Frequenz auf Performance
log_message "Konfiguriere CPU-Frequenz auf Performance."
echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
sudo cpupower frequency-set -r -g performance

# Installiere weitere Python-Pakete
log_message "Installiere weitere Python-Pakete."
pip install --upgrade pip
sudo pip install jupyter matplotlib uv

# Installiere weitere npm-Pakete
log_message "Installiere weitere npm-Pakete."
sudo npm install -y --global yarn @primer/react-brand react-terminal-terminal-ui

# Installiere Astral UV
log_message "Installiere Astral UV."
curl -LsSf https://astral.sh/uv/install.sh | sh
pip install uv

# Installiere Protobuf für Go
log_message "Installiere Protobuf für Go."
sudo go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28
sudo go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2

# Installiere und konfiguriere NVIDIA AI Workbench erneut (falls nicht bereits geschehen)
log_message "Stelle sicher, dass NVIDIA AI Workbench installiert und konfiguriert ist."
wget https://workbench.download.nvidia.com/stable/workbench-desktop/0.57.3/NVIDIA-AI-Workbench-x86_64.AppImage
chmod +x NVIDIA-AI-Workbench-x86_64.AppImage
sudo mv NVIDIA-AI-Workbench-x86_64.AppImage /usr/local/bin/
sudo ./NVIDIA-AI-Workbench-x86_64.AppImage --no-sandbox &

# Installiere Docker erneut (falls nicht bereits geschehen)
log_message "Stelle sicher, dass Docker korrekt installiert ist."
if ! command -v docker &> /dev/null; then
    log_message "Docker nicht gefunden. Versuche zu installieren..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    newgrp docker
    docker run hello-world
else
    log_message "Docker ist bereits installiert."
fi

# Installiere NVIDIA Container Toolkit erneut (für Sicherheit)
log_message "Stelle sicher, dass NVIDIA Container Toolkit korrekt installiert ist."
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# Setze ulimit
log_message "Setze ulimit."
echo "ulimit -n 4096" >> ~/.bashrc
ulimit -n 4096

# Finaler Cleanup
log_message "Führe finalen Cleanup durch."
sudo apt-get autoremove -y
sudo apt-get autoclean -y
sudo rm -rf /var/lib/apt/lists/*
sudo rm -rf ~/.cache/yarn/*

# Aktualisiere initramfs und Grub
log_message "Aktualisiere initramfs und Grub."
sudo update-initramfs -u
sudo update-grub

# Reboot Empfehlung
log_message "Installation abgeschlossen. Bitte starte das System neu, um alle Änderungen zu übernehmen."
echo "Bitte starte das System neu, um alle Änderungen zu übernehmen."
