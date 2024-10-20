#!/bin/bash

# Setze Fehlerbehandlung, aber fahre bei Fehlern fort
set +e

# Definiere Variablen
LOG_FILE="/var/log/kubuntu_setup.log"

# Funktion zum Protokollieren von Nachrichten
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Backup der bestehenden .bashrc und .bash_aliases
log_message "Erstelle Backups von bestehenden Konfigurationsdateien."
cp ~/.bashrc ~/.bashrc.backup
cp ~/.bash_aliases ~/.bash_aliases.backup 2>/dev/null || touch ~/.bash_aliases

# Füge Alias für update hinzu
log_message "Füge Alias für update hinzu."
echo "alias update='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo snap refresh'" >> ~/.bash_aliases

# Lade Aliases in die aktuelle Shell
source ~/.bash_aliases

# Git Konfiguration
log_message "Konfiguriere Git."
git config --global submodule.recurse true || log_message "Git config submodule.recurse fehlgeschlagen."
git config --global credential.helper store || log_message "Git config credential.helper fehlgeschlagen."
git config --global user.email "vesiassr@gmail.com" || log_message "Git config user.email fehlgeschlagen."
git config --global user.name "Vesias" || log_message "Git config user.name fehlgeschlagen."
echo "Updates" > ~/.gitmessage
git config --global commit.template ~/.gitmessage || log_message "Git config commit.template fehlgeschlagen."

# Installiere Python 3.10 und pip
log_message "Überprüfe und installiere Python 3.10 und pip."
if ! command -v python3.10 &> /dev/null; then
    log_message "Python 3.10 nicht gefunden. Versuche zu installieren..."
    sudo DEBIAN_FRONTEND=noninteractive apt-get update || log_message "apt-get update fehlgeschlagen."
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common curl || log_message "Installation von software-properties-common fehlgeschlagen."
    sudo add-apt-repository -y ppa:deadsnakes/ppa || log_message "Hinzufügen des deadsnakes PPA fehlgeschlagen."
    sudo DEBIAN_FRONTEND=noninteractive apt-get update || log_message "apt-get update fehlgeschlagen."
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3.10 python3.10-venv python3.10-dev || log_message "Installation von Python 3.10 fehlgeschlagen."
fi

# Sicherstellen, dass pip für Python 3.10 installiert ist
if ! python3.10 -m pip --version &> /dev/null; then
    log_message "pip für Python 3.10 nicht gefunden. Versuche zu installieren..."
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py || log_message "Download von get-pip.py fehlgeschlagen."
    python3.10 get-pip.py --user || log_message "Installation von pip fehlgeschlagen."
    rm get-pip.py
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
    sudo apt-get install -y chromium-browser || log_message "Installation von Chromium fehlgeschlagen."
else
    log_message "Chromium ist bereits installiert."
fi

# Installiere Microsoft Packages
log_message "Installiere Microsoft-Pakete."
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb || log_message "Download der Microsoft-Pakete fehlgeschlagen."
sudo dpkg -i packages-microsoft-prod.deb || log_message "Installation der Microsoft-Pakete fehlgeschlagen."
rm packages-microsoft-prod.deb

# Installiere OpenSSL (falls benötigt)
log_message "Installiere OpenSSL."
sudo apt-get install -y libssl1.1 || log_message "Installation von libssl1.1 fehlgeschlagen oder bereits installiert."

# Entferne LibreOffice
log_message "Entferne LibreOffice."
sudo apt-get remove -y libreoffice* || log_message "Entfernen von LibreOffice fehlgeschlagen."

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
    ubuntu-restricted-extras || log_message "Installation der APT-Pakete fehlgeschlagen."

# Installiere Snap-Pakete
log_message "Installiere Snap-Pakete."
sudo snap install code --classic || log_message "Installation von VS Code fehlgeschlagen."
sudo snap install dotnet-sdk --classic --channel=8.0 || log_message "Installation von dotnet-sdk fehlgeschlagen."
sudo snap alias dotnet-sdk.dotnet dotnet || log_message "Setzen des Snap Alias für dotnet fehlgeschlagen."
sudo snap install powershell --classic || log_message "Installation von PowerShell fehlgeschlagen."
sudo snap install discord || log_message "Installation von Discord fehlgeschlagen."
sudo snap install onlyoffice-desktopeditors || log_message "Installation von OnlyOffice fehlgeschlagen."
sudo snap install --edge spotify || log_message "Installation von Spotify fehlgeschlagen."
sudo snap install slack || log_message "Installation von Slack fehlgeschlagen."
sudo snap install go --classic || log_message "Installation von Go fehlgeschlagen."

# Installiere NodeJS und yarn
log_message "Installiere NodeJS und yarn."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash || log_message "Installation von nvm fehlgeschlagen."
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # Lädt nvm
nvm install --lts || log_message "Installation von NodeJS fehlgeschlagen."
nvm use --lts || log_message "Wechsel zu NodeJS LTS fehlgeschlagen."
sudo npm install --global yarn || log_message "Installation von yarn fehlgeschlagen."

# Installiere Docker (rootless mode)
log_message "Installiere Docker im Rootless Modus."
curl -fsSL https://get.docker.com/rootless | sh || log_message "Installation von Docker rootless fehlgeschlagen."
export PATH=/usr/bin:$PATH
dockerd-rootless-setuptool.sh install || log_message "Docker rootless Setup fehlgeschlagen."

# Installiere NVIDIA Treiber
log_message "Installiere NVIDIA Treiber."
if ! command -v nvidia-smi &> /dev/null; then
    log_message "NVIDIA Treiber nicht gefunden. Versuche zu installieren..."
    sudo apt-get update || log_message "apt-get update fehlgeschlagen."
    sudo apt-get install -y linux-headers-$(uname -r) || log_message "Installation der Linux-Header fehlgeschlagen."
    sudo apt-get install -y nvidia-driver-560 nvidia-utils-560 || log_message "Installation der NVIDIA Treiber fehlgeschlagen."
else
    log_message "NVIDIA Treiber sind bereits installiert."
fi

# Installiere CUDA
log_message "Installiere CUDA."
if ! command -v nvcc &> /dev/null; then
    log_message "CUDA nicht gefunden. Versuche zu installieren..."
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin || log_message "Download von CUDA pin fehlgeschlagen."
    sudo mv cuda-ubuntu2404.pin /etc/apt/preferences.d/cuda-repository-pin-600 || log_message "Verschieben des CUDA pin fehlgeschlagen."
    wget https://developer.download.nvidia.com/compute/cuda/12.6.1/local_installers/cuda-repo-ubuntu2404-12-6-local_12.6.1-560.35.03-1_amd64.deb || log_message "Download des CUDA Repos fehlgeschlagen."
    sudo dpkg -i cuda-repo-ubuntu2404-12-6-local_12.6.1-560.35.03-1_amd64.deb || log_message "Installation des CUDA Repos fehlgeschlagen."
    sudo cp /var/cuda-repo-ubuntu2404-12-6-local/cuda-*-keyring.gpg /usr/share/keyrings/ || log_message "Kopieren des CUDA Keyrings fehlgeschlagen."
    sudo apt-get update || log_message "apt-get update fehlgeschlagen."
    sudo apt-get install -y cuda-toolkit-12-6 || log_message "Installation des CUDA Toolkits fehlgeschlagen."
    sudo apt-get install -y cuda || log_message "Installation von CUDA fehlgeschlagen."
    # Entferne CUDA repo .deb
    sudo rm cuda-repo-ubuntu2404-12-6-local_12.6.1-560.35.03-1_amd64.deb || log_message "Entfernen des CUDA Repos fehlgeschlagen."
else
    log_message "CUDA ist bereits installiert."
fi

# Installiere NVIDIA Container Toolkit
log_message "Installiere NVIDIA Container Toolkit."
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg || log_message "Download des NVIDIA Container Toolkit GPG Keys fehlgeschlagen."
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null || log_message "Hinzufügen des NVIDIA Container Toolkit Repositories fehlgeschlagen."
sudo apt-get update || log_message "apt-get update fehlgeschlagen."
sudo apt-get install -y nvidia-container-toolkit || log_message "Installation des NVIDIA Container Toolkits fehlgeschlagen."
sudo nvidia-ctk runtime configure --runtime=docker || log_message "Konfiguration des NVIDIA Runtimes fehlgeschlagen."
sudo systemctl restart docker || log_message "Neustarten von Docker fehlgeschlagen."

# Installiere und konfiguriere Cockpit
log_message "Installiere und starte Cockpit."
sudo apt-get install -y cockpit cockpit-machines || log_message "Installation von Cockpit fehlgeschlagen."
sudo systemctl start cockpit || log_message "Starten von Cockpit fehlgeschlagen."

# Installiere Anaconda
log_message "Installiere Anaconda."
mkdir -p ~/miniconda3 || log_message "Erstellen des Verzeichnisses für Anaconda fehlgeschlagen."
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh || log_message "Download von Anaconda fehlgeschlagen."
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3 || log_message "Installation von Anaconda fehlgeschlagen."
rm ~/miniconda3/miniconda.sh
~/miniconda3/bin/conda init bash || log_message "Conda init bash fehlgeschlagen."
~/miniconda3/bin/conda init zsh || log_message "Conda init zsh fehlgeschlagen."

# Installiere CMake und pkg-config (bereits installiert, aber nochmal sicherheitshalber)
log_message "Installiere CMake und pkg-config."
sudo apt-get install -y cmake pkg-config || log_message "Installation von CMake und pkg-config fehlgeschlagen."

# Installiere weitere wichtige Tools
log_message "Installiere weitere wichtige Tools."
sudo apt-get install -y gpg-agent wget exfat-fuse p7zip || log_message "Installation weiterer Tools fehlgeschlagen."

# Installiere Flatpak-Pakete
log_message "Installiere Flatpak-Pakete."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || log_message "Hinzufügen des Flatpak Flathub Repositories fehlgeschlagen."
flatpak install -y flathub com.spotify.Client || log_message "Installation von Spotify via Flatpak fehlgeschlagen."
flatpak install -y flathub com.transmissionbt.Transmission || log_message "Installation von Transmission via Flatpak fehlgeschlagen."
flatpak install -y flathub com.obsproject.Studio || log_message "Installation von OBS Studio via Flatpak fehlgeschlagen."

# Installiere LM Studio und NVIDIA AI Workbench
log_message "Installiere LM Studio und NVIDIA AI Workbench."
wget https://releases.lmstudio.ai/linux/0.2.19/beta/LM_Studio-0.2.19.AppImage || log_message "Download von LM Studio fehlgeschlagen."
chmod +x LM_Studio-0.2.19.AppImage || log_message "Setzen der Ausführungsrechte für LM Studio fehlgeschlagen."
# Optional: Starte LM Studio
# ./LM_Studio-0.2.19.AppImage &

wget https://workbench.download.nvidia.com/stable/workbench-desktop/0.57.3/NVIDIA-AI-Workbench-x86_64.AppImage || log_message "Download von NVIDIA AI Workbench fehlgeschlagen."
chmod +x NVIDIA-AI-Workbench-x86_64.AppImage || log_message "Setzen der Ausführungsrechte für NVIDIA AI Workbench fehlgeschlagen."
sudo mv NVIDIA-AI-Workbench-x86_64.AppImage /usr/local/bin/ || log_message "Verschieben von NVIDIA AI Workbench fehlgeschlagen."
sudo ./NVIDIA-AI-Workbench-x86_64.AppImage --no-sandbox &

# Installiere xpipe
log_message "Installiere xpipe."
bash <(curl -sL https://github.com/xpipe-io/xpipe/raw/master/get-xpipe.sh) || log_message "Installation von xpipe fehlgeschlagen."

# Installiere Go-Protokolle
log_message "Installiere Go-Protokolle."
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest || log_message "Installation von protoc-gen-go-grpc fehlgeschlagen."
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest || log_message "Installation von protoc-gen-go fehlgeschlagen."
export PATH="$PATH:$(go env GOPATH)/bin"

# Clone und Build von grpc-go Beispielen
log_message "Clone und build grpc-go Beispiele."
git clone -b v1.65.0 --depth 1 https://github.com/grpc/grpc-go || log_message "Clone von grpc-go fehlgeschlagen."
cd grpc-go/examples/helloworld || log_message "Wechsel in das grpc-go Beispielverzeichnis fehlgeschlagen."
make || log_message "Build des grpc-go Beispiels fehlgeschlagen."
cd ../../..

# Clone und Build von LocalAI
log_message "Clone und build LocalAI."
git clone https://github.com/mudler/LocalAI.git || log_message "Clone von LocalAI fehlgeschlagen."
cd LocalAI || log_message "Wechsel in das LocalAI Verzeichnis fehlgeschlagen."
make build || log_message "Build von LocalAI fehlgeschlagen."
cd ..

# Installiere und konfiguriere UFW
log_message "Installiere und konfiguriere UFW."
sudo apt-get install -y ufw || log_message "Installation von UFW fehlgeschlagen."
sudo systemctl enable ufw || log_message "Aktivieren von UFW fehlgeschlagen."
sudo systemctl start ufw || log_message "Starten von UFW fehlgeschlagen."
# Erlaube Standardports
sudo ufw allow 5000 || log_message "Erlauben von Port 5000 fehlgeschlagen."
sudo ufw allow 3000 || log_message "Erlauben von Port 3000 fehlgeschlagen."
sudo ufw allow 8080 || log_message "Erlauben von Port 8080 fehlgeschlagen."
sudo ufw allow 8000 || log_message "Erlauben von Port 8000 fehlgeschlagen."
# Blockiere Port 22
sudo ufw deny 22/tcp || log_message "Blockieren von Port 22 fehlgeschlagen."

# Füge Intel OneAPI und NVIDIA HPC SDK Repositorys hinzu
log_message "Füge Intel OneAPI und NVIDIA HPC SDK Repositorys hinzu."
wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | gpg --dearmor | sudo tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null || log_message "Hinzufügen des Intel OneAPI GPG Keys fehlgeschlagen."
echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list || log_message "Hinzufügen des Intel OneAPI Repositories fehlgeschlagen."

curl https://developer.download.nvidia.com/hpc-sdk/ubuntu/DEB-GPG-KEY-NVIDIA-HPC-SDK | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-hpcsdk-archive-keyring.gpg || log_message "Hinzufügen des NVIDIA HPC SDK GPG Keys fehlgeschlagen."
echo 'deb [signed-by=/usr/share/keyrings/nvidia-hpcsdk-archive-keyring.gpg] https://developer.download.nvidia.com/hpc-sdk/ubuntu/amd64 /' | sudo tee /etc/apt/sources.list.d/nvhpc.list || log_message "Hinzufügen des NVIDIA HPC SDK Repositories fehlgeschlagen."

# Aktualisiere die Paketliste und installiere NVIDIA HPC SDK
log_message "Aktualisiere die Paketliste und installiere NVIDIA HPC SDK."
sudo apt-get update || log_message "apt-get update fehlgeschlagen."
sudo apt-get install -y nvhpc-24-5 intel-basekit intel-hpckit || log_message "Installation des NVIDIA HPC SDK fehlgeschlagen."

# Installiere Ollama
log_message "Installiere Ollama."
curl -fsSL https://ollama.com/install.sh | sh || log_message "Installation von Ollama fehlgeschlagen."

# Deaktiviere Bildschirmsperre und Energiesparmodus
log_message "Deaktiviere Bildschirmsperre und Energiesparmodus."
# Für KDE Plasma (Kubuntu)
kwriteconfig5 --file kdeglobals --group KDE --key ScreenSaverEnabled false || log_message "Deaktivieren der Bildschirmsperre fehlgeschlagen."
kwriteconfig5 --file kdeglobals --group KDE --key EnergySavingEnabled false || log_message "Deaktivieren des Energiesparmodus fehlgeschlagen."
qdbus org.freedesktop.ScreenSaver /ScreenSaver org.freedesktop.ScreenSaver.Lock false || log_message "Bildschirmsperre über qdbus deaktivieren fehlgeschlagen."

# Aktiviere CPU Turbo und setze pstate für NVIDIA GPUs
log_message "Aktiviere CPU Turbo und setze pstate für NVIDIA GPUs."
# CPU Turbo (abhängig von BIOS, kann nicht vollständig über Skript gesteuert werden)
# Versuche, CPU-Frequenz auf Performance zu setzen
sudo apt-get install -y cpupower || log_message "Installation von cpupower fehlgeschlagen."
sudo cpupower frequency-set -r -g performance || log_message "Setzen der CPU-Frequenz auf Performance fehlgeschlagen."

# Setze pstate für NVIDIA GPUs (Beispiel: Aktivieren des Performance Modus)
nvidia-smi -pm ENABLED || log_message "Setzen des Persistenzmodus für NVIDIA GPUs fehlgeschlagen."
nvidia-smi --auto-boost-default=ENABLED || log_message "Aktivieren von Auto Boost für NVIDIA GPUs fehlgeschlagen."

# Setze ulimit
log_message "Setze ulimit."
echo "ulimit -n 4096" >> ~/.bashrc
ulimit -n 4096

# Clean-up heruntergeladene .deb Dateien
log_message "Bereinige heruntergeladene .deb Dateien."
find /tmp -type f -name "*.deb" -exec rm -f {} \; || log_message "Entfernen der .deb Dateien fehlgeschlagen."

# Konfiguriere Docker für Rootless Nutzung über SSH
log_message "Konfiguriere Docker für Rootless Nutzung über SSH."
# Docker Rootless Setup
dockerd-rootless-setuptool.sh install || log_message "Docker Rootless Setup fehlgeschlagen."
export PATH=/usr/bin:$PATH
export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock

# Starte Docker Rootless Daemon
log_message "Starte Docker Rootless Daemon."
systemctl --user start docker || log_message "Starten des Docker Rootless Daemon fehlgeschlagen."
systemctl --user enable docker || log_message "Aktivieren des Docker Rootless Daemon fehlgeschlagen."

# Stelle sicher, dass LAN aktiviert ist
log_message "Stelle sicher, dass LAN aktiviert ist."
nmcli networking on || log_message "Aktivieren von Netzwerkfehlgeschlagen."

# Finaler Cleanup
log_message "Führe finalen Cleanup durch."
sudo apt-get autoremove -y || log_message "apt-get autoremove fehlgeschlagen."
sudo apt-get autoclean -y || log_message "apt-get autoclean fehlgeschlagen."
sudo rm -rf /var/lib/apt/lists/* || log_message "Entfernen der apt Listen fehlgeschlagen."
sudo rm -rf ~/.cache/yarn/* || log_message "Entfernen des Yarn Caches fehlgeschlagen."

# Aktualisiere initramfs und Grub
log_message "Aktualisiere initramfs und Grub."
sudo update-initramfs -u || log_message "Update von initramfs fehlgeschlagen."
sudo update-grub || log_message "Update von Grub fehlgeschlagen."

# Reboot Empfehlung
log_message "Installation abgeschlossen. Bitte starte das System neu, um alle Änderungen zu übernehmen."
echo "Bitte starte das System neu, um alle Änderungen zu übernehmen."
