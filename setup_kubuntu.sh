#!/bin/bash

# Setze Fehlerbehandlung, aber fahre bei Fehlern fort
set +e

# Definiere Variablen
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/kubuntu_setup.log"
ERROR_FILE="$SCRIPT_DIR/error.txt"

# Leere vorherige Logs
> "$LOG_FILE"
> "$ERROR_FILE"

# Funktion zum Protokollieren von Nachrichten
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Funktion zum Protokollieren von Fehlern
log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: $1" | tee -a "$ERROR_FILE" >&2
}

# Installiere Nala, falls nicht vorhanden
log_message "Überprüfe und installiere Nala."
if ! command -v nala &> /dev/null; then
    log_message "Nala nicht gefunden. Installiere Nala..."
    sudo apt update || log_error "apt update fehlgeschlagen."
    sudo apt install -y nala || log_error "Installation von Nala fehlgeschlagen."
else
    log_message "Nala ist bereits installiert."
fi

# Aktualisiere Nala und führe Systemaktualisierung durch
log_message "Führe Systemaktualisierung mit Nala durch."
sudo nala update && sudo nala upgrade -y && sudo nala autoremove -y && sudo snap refresh || log_error "Systemaktualisierung fehlgeschlagen."

# Backup der bestehenden .bashrc und .bash_aliases
log_message "Erstelle Backups von bestehenden Konfigurationsdateien."
cp ~/.bashrc ~/.bashrc.backup || log_error "Backup von .bashrc fehlgeschlagen."
cp ~/.bash_aliases ~/.bash_aliases.backup 2>/dev/null || touch ~/.bash_aliases

# Füge Alias für Update hinzu
log_message "Füge Alias für update hinzu."
echo "alias update='sudo nala update && sudo nala upgrade -y && sudo nala autoremove -y && sudo snap refresh'" >> ~/.bash_aliases || log_error "Hinzufügen des Alias fehlgeschlagen."

# Lade Aliases in die aktuelle Shell
source ~/.bash_aliases

# Git Konfiguration
log_message "Konfiguriere Git."
git config --global submodule.recurse true || log_error "Git config submodule.recurse fehlgeschlagen."
git config --global credential.helper store || log_error "Git config credential.helper fehlgeschlagen."
git config --global user.email "vesiassr@gmail.com" || log_error "Git config user.email fehlgeschlagen."
git config --global user.name "Vesias" || log_error "Git config user.name fehlgeschlagen."
echo "Updates" > ~/.gitmessage || log_error "Erstellen der gitmessage fehlgeschlagen."
git config --global commit.template ~/.gitmessage || log_error "Git config commit.template fehlgeschlagen."

# Installiere essentielle Pakete mit Nala
log_message "Installiere essentielle Pakete mit Nala."
sudo nala install -y \
    cmus \
    sl \
    curl \
    wget \
    gdebi \
    git \
    python3 \
    python3-pip \
    jupyter \
    matplotlib \
    cmus \
    sl \
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
    gdebi || log_error "Installation der essentiellen Pakete fehlgeschlagen."

# Installiere Docker Rootless
log_message "Installiere Docker im Rootless Modus."
curl -fsSL https://get.docker.com/rootless | sh || log_error "Installation von Docker Rootless fehlgeschlagen."
export PATH=/usr/bin:$PATH
dockerd-rootless-setuptool.sh install || log_error "Docker Rootless Setup fehlgeschlagen."

# Installiere und konfiguriere Docker mit Nala
log_message "Installiere Docker mit Nala."
if ! command -v docker &> /dev/null; then
    sudo nala install -y docker-ce docker-ce-cli containerd.io || log_error "Installation von Docker fehlgeschlagen."
else
    log_message "Docker ist bereits installiert."
fi

# Füge den aktuellen Benutzer zur Docker-Gruppe hinzu
log_message "Füge Benutzer zur Docker-Gruppe hinzu."
sudo usermod -aG docker "$USER" || log_error "Hinzufügen zur Docker-Gruppe fehlgeschlagen."

# Installiere NVIDIA Treiber
log_message "Installiere NVIDIA Treiber."
if ! command -v nvidia-smi &> /dev/null; then
    sudo nala install -y linux-headers-$(uname -r) || log_error "Installation der Linux-Header fehlgeschlagen."
    sudo nala install -y nvidia-driver-560 nvidia-utils-560 || log_error "Installation der NVIDIA Treiber fehlgeschlagen."
else
    log_message "NVIDIA Treiber sind bereits installiert."
fi

# Installiere CUDA
log_message "Installiere CUDA."
if ! command -v nvcc &> /dev/null; then
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin || log_error "Download von CUDA pin fehlgeschlagen."
    sudo mv cuda-ubuntu2404.pin /etc/apt/preferences.d/cuda-repository-pin-600 || log_error "Verschieben des CUDA pin fehlgeschlagen."
    wget https://developer.download.nvidia.com/compute/cuda/12.6.1/local_installers/cuda-repo-ubuntu2404-12-6-local_12.6.1-560.35.03-1_amd64.deb || log_error "Download des CUDA Repos fehlgeschlagen."
    sudo dpkg -i cuda-repo-ubuntu2404-12-6-local_12.6.1-560.35.03-1_amd64.deb || log_error "Installation des CUDA Repos fehlgeschlagen."
    sudo cp /var/cuda-repo-ubuntu2404-12-6-local/cuda-*-keyring.gpg /usr/share/keyrings/ || log_error "Kopieren des CUDA Keyrings fehlgeschlagen."
    sudo nala update || log_error "apt update fehlgeschlagen."
    sudo nala install -y cuda-toolkit-12-6 || log_error "Installation des CUDA Toolkits fehlgeschlagen."
    sudo nala install -y cuda || log_error "Installation von CUDA fehlgeschlagen."
    sudo rm cuda-repo-ubuntu2404-12-6-local_12.6.1-560.35.03-1_amd64.deb || log_error "Entfernen des CUDA Repos fehlgeschlagen."
else
    log_message "CUDA ist bereits installiert."
fi

# Installiere NVIDIA Container Toolkit
log_message "Installiere NVIDIA Container Toolkit."
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg || log_error "Download des NVIDIA Container Toolkit GPG Keys fehlgeschlagen."
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null || log_error "Hinzufügen des NVIDIA Container Toolkit Repositories fehlgeschlagen."
sudo nala update || log_error "apt update fehlgeschlagen."
sudo nala install -y nvidia-container-toolkit || log_error "Installation des NVIDIA Container Toolkits fehlgeschlagen."
sudo nvidia-ctk runtime configure --runtime=docker || log_error "Konfiguration des NVIDIA Runtimes fehlgeschlagen."
sudo systemctl restart docker || log_error "Neustarten von Docker fehlgeschlagen."

# Installiere und konfiguriere Cockpit
log_message "Installiere und starte Cockpit."
sudo nala install -y cockpit cockpit-machines || log_error "Installation von Cockpit fehlgeschlagen."
sudo systemctl start cockpit || log_error "Starten von Cockpit fehlgeschlagen."

# Installiere Flatpak-Pakete
log_message "Installiere Flatpak-Pakete."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || log_error "Hinzufügen des Flatpak Flathub Repositories fehlgeschlagen."
flatpak install -y flathub com.spotify.Client || log_error "Installation von Spotify via Flatpak fehlgeschlagen."
flatpak install -y flathub com.transmissionbt.Transmission || log_error "Installation von Transmission via Flatpak fehlgeschlagen."
flatpak install -y flathub com.obsproject.Studio || log_error "Installation von OBS Studio via Flatpak fehlgeschlagen."

# Installiere Chromium anstelle von Google Chrome
log_message "Installiere Chromium anstelle von Google Chrome."
if ! command -v chromium-browser &> /dev/null; then
    sudo nala install -y chromium-browser || log_error "Installation von Chromium fehlgeschlagen."
else
    log_message "Chromium ist bereits installiert."
fi

# Installiere Gdebi mit Nala
log_message "Installiere Gdebi mit Nala."
sudo nala install -y gdebi || log_error "Installation von Gdebi fehlgeschlagen."

# Installiere und konfiguriere Docker rootless over SSH
log_message "Konfiguriere Docker für Rootless Nutzung über SSH."
dockerd-rootless-setuptool.sh install || log_error "Docker Rootless Setup fehlgeschlagen."
export PATH=/usr/bin:$PATH
export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock
systemctl --user start docker || log_error "Starten des Docker Rootless Daemon fehlgeschlagen."
systemctl --user enable docker || log_error "Aktivieren des Docker Rootless Daemon fehlgeschlagen."

# Deaktiviere Bildschirmsperre und Energiesparmodus
log_message "Deaktiviere Bildschirmsperre und Energiesparmodus."
# Für KDE Plasma (Kubuntu)
kwriteconfig5 --file kdeglobals --group KDE --key ScreenSaverEnabled false || log_error "Deaktivieren der Bildschirmsperre fehlgeschlagen."
kwriteconfig5 --file kdeglobals --group KDE --key EnergySavingEnabled false || log_error "Deaktivieren des Energiesparmodus fehlgeschlagen."
qdbus org.freedesktop.ScreenSaver /ScreenSaver org.freedesktop.ScreenSaver.Lock false || log_error "Bildschirmsperre über qdbus deaktivieren fehlgeschlagen."

# Aktiviere CPU Turbo und setze pstate für NVIDIA GPUs
log_message "Aktiviere CPU Turbo und setze pstate für NVIDIA GPUs."
# CPU Turbo (abhängig von BIOS, kann nicht vollständig über Skript gesteuert werden)
# Versuche, CPU-Frequenz auf Performance zu setzen
sudo nala install -y cpupower || log_error "Installation von cpupower fehlgeschlagen."
sudo cpupower frequency-set -r -g performance || log_error "Setzen der CPU-Frequenz auf Performance fehlgeschlagen."

# Setze pstate für NVIDIA GPUs (Beispiel: Aktivieren des Performance Modus)
nvidia-smi -pm ENABLED || log_error "Setzen des Persistenzmodus für NVIDIA GPUs fehlgeschlagen."
nvidia-smi --auto-boost-default=ENABLED || log_error "Aktivieren von Auto Boost für NVIDIA GPUs fehlgeschlagen."

# Setze ulimit
log_message "Setze ulimit."
echo "ulimit -n 4096" >> ~/.bashrc || log_error "Setzen von ulimit in .bashrc fehlgeschlagen."
ulimit -n 4096 || log_error "Setzen von ulimit in aktueller Sitzung fehlgeschlagen."

# Erlaube spezifische Ports und blockiere andere
log_message "Konfiguriere UFW-Firewall."
sudo nala install -y ufw || log_error "Installation von UFW fehlgeschlagen."
sudo systemctl enable ufw || log_error "Aktivieren von UFW fehlgeschlagen."
sudo systemctl start ufw || log_error "Starten von UFW fehlgeschlagen."
# Erlaube Ports 5000, 3000, 8080, 8000
sudo ufw allow 5000 || log_error "Erlauben von Port 5000 fehlgeschlagen."
sudo ufw allow 3000 || log_error "Erlauben von Port 3000 fehlgeschlagen."
sudo ufw allow 8080 || log_error "Erlauben von Port 8080 fehlgeschlagen."
sudo ufw allow 8000 || log_error "Erlauben von Port 8000 fehlgeschlagen."
# Blockiere Standardports wie 22 (falls gewünscht)
sudo ufw deny 22/tcp || log_error "Blockieren von Port 22 fehlgeschlagen."
sudo ufw enable || log_error "Aktivieren von UFW fehlgeschlagen."

# Stelle sicher, dass LAN aktiviert ist
log_message "Stelle sicher, dass LAN aktiviert ist."
nmcli networking on || log_error "Aktivieren von Netzwerk fehlgeschlagen."

# Installiere und konfiguriere Anaconda
log_message "Installiere Anaconda."
mkdir -p ~/miniconda3 || log_error "Erstellen des Verzeichnisses für Anaconda fehlgeschlagen."
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh || log_error "Download von Anaconda fehlgeschlagen."
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3 || log_error "Installation von Anaconda fehlgeschlagen."
rm ~/miniconda3/miniconda.sh || log_error "Entfernen des Anaconda Installationsskripts fehlgeschlagen."
~/miniconda3/bin/conda init bash || log_error "Conda init bash fehlgeschlagen."
~/miniconda3/bin/conda init zsh || log_error "Conda init zsh fehlgeschlagen."

# Installiere weitere Python-Pakete
log_message "Installiere weitere Python-Pakete."
pip install --upgrade pip || log_error "Upgrade von pip fehlgeschlagen."
sudo pip install jupyter matplotlib uv || log_error "Installation von Python-Paketen fehlgeschlagen."

# Installiere weitere npm-Pakete
log_message "Installiere weitere npm-Pakete."
sudo npm install -y --global yarn @primer/react-brand react-terminal-terminal-ui || log_error "Installation von npm-Paketen fehlgeschlagen."

# Installiere Astral UV
log_message "Installiere Astral UV."
curl -LsSf https://astral.sh/uv/install.sh | sh || log_error "Installation von Astral UV fehlgeschlagen."
pip install uv || log_error "Installation von uv via pip fehlgeschlagen."

# Installiere Protobuf für Go
log_message "Installiere Protobuf für Go."
sudo go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28 || log_error "Installation von protoc-gen-go fehlgeschlagen."
sudo go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2 || log_error "Installation von protoc-gen-go-grpc fehlgeschlagen."
export PATH="$PATH:$(go env GOPATH)/bin"

# Clone und Build von grpc-go Beispielen
log_message "Clone und build grpc-go Beispiele."
git clone -b v1.65.0 --depth 1 https://github.com/grpc/grpc-go || log_error "Clone von grpc-go fehlgeschlagen."
cd grpc-go/examples/helloworld || log_error "Wechsel in das grpc-go Beispielverzeichnis fehlgeschlagen."
make || log_error "Build des grpc-go Beispiels fehlgeschlagen."
cd ../../..

# Clone und Build von LocalAI
log_message "Clone und build LocalAI."
git clone https://github.com/mudler/LocalAI.git || log_error "Clone von LocalAI fehlgeschlagen."
cd LocalAI || log_error "Wechsel in das LocalAI Verzeichnis fehlgeschlagen."
make build || log_error "Build von LocalAI fehlgeschlagen."
cd ..

# Installiere und konfiguriere UFW erneut für zusätzliche Sicherheit
log_message "Installiere und konfiguriere UFW erneut."
sudo nala install -y ufw || log_error "Installation von UFW fehlgeschlagen."
sudo systemctl enable ufw || log_error "Aktivieren von UFW fehlgeschlagen."
sudo systemctl start ufw || log_error "Starten von UFW fehlgeschlagen."
# Erlaube Ports 5000, 3000, 8080, 8000
sudo ufw allow 5000 || log_error "Erlauben von Port 5000 fehlgeschlagen."
sudo ufw allow 3000 || log_error "Erlauben von Port 3000 fehlgeschlagen."
sudo ufw allow 8080 || log_error "Erlauben von Port 8080 fehlgeschlagen."
sudo ufw allow 8000 || log_error "Erlauben von Port 8000 fehlgeschlagen."
# Blockiere Port 22, falls nicht benötigt
sudo ufw deny 22/tcp || log_error "Blockieren von Port 22 fehlgeschlagen."
sudo ufw enable || log_error "Aktivieren von UFW fehlgeschlagen."

# Installiere LM Studio und NVIDIA AI Workbench
log_message "Installiere LM Studio und NVIDIA AI Workbench."
wget https://releases.lmstudio.ai/linux/0.2.19/beta/LM_Studio-0.2.19.AppImage || log_error "Download von LM Studio fehlgeschlagen."
chmod +x LM_Studio-0.2.19.AppImage || log_error "Setzen der Ausführungsrechte für LM Studio fehlgeschlagen."
# Optional: Starte LM Studio
# ./LM_Studio-0.2.19.AppImage &

wget https://workbench.download.nvidia.com/stable/workbench-desktop/0.57.3/NVIDIA-AI-Workbench-x86_64.AppImage || log_error "Download von NVIDIA AI Workbench fehlgeschlagen."
chmod +x NVIDIA-AI-Workbench-x86_64.AppImage || log_error "Setzen der Ausführungsrechte für NVIDIA AI Workbench fehlgeschlagen."
sudo mv NVIDIA-AI-Workbench-x86_64.AppImage /usr/local/bin/ || log_error "Verschieben von NVIDIA AI Workbench fehlgeschlagen."
sudo ./NVIDIA-AI-Workbench-x86_64.AppImage --no-sandbox &

# Installiere xpipe
log_message "Installiere xpipe."
bash <(curl -sL https://github.com/xpipe-io/xpipe/raw/master/get-xpipe.sh) || log_error "Installation von xpipe fehlgeschlagen."

# Installiere und konfiguriere UFW Firewall
log_message "Konfiguriere UFW-Firewall."
sudo nala install -y ufw || log_error "Installation von UFW fehlgeschlagen."
sudo ufw allow 5000 || log_error "Erlauben von Port 5000 fehlgeschlagen."
sudo ufw allow 3000 || log_error "Erlauben von Port 3000 fehlgeschlagen."
sudo ufw allow 8080 || log_error "Erlauben von Port 8080 fehlgeschlagen."
sudo ufw allow 8000 || log_error "Erlauben von Port 8000 fehlgeschlagen."
sudo ufw deny 22/tcp || log_error "Blockieren von Port 22 fehlgeschlagen."
sudo ufw enable || log_error "Aktivieren von UFW fehlgeschlagen."

# Clean-up heruntergeladene .deb Dateien
log_message "Bereinige heruntergeladene .deb Dateien."
find /tmp -type f -name "*.deb" -exec sudo rm -f {} \; || log_error "Entfernen der .deb Dateien fehlgeschlagen."

# Aktualisiere initramfs und Grub
log_message "Aktualisiere initramfs und Grub."
sudo update-initramfs -u || log_error "Update von initramfs fehlgeschlagen."
sudo update-grub || log_error "Update von Grub fehlgeschlagen."

# Setze CPU-Frequenz auf Performance
log_message "Setze CPU-Frequenz auf Performance."
sudo cpupower frequency-set -r -g performance || log_error "Setzen der CPU-Frequenz auf Performance fehlgeschlagen."

# Setze Persistenzmodus und Auto Boost für NVIDIA GPUs
log_message "Setze Persistenzmodus und Auto Boost für NVIDIA GPUs."
nvidia-smi -pm ENABLED || log_error "Setzen des Persistenzmodus für NVIDIA GPUs fehlgeschlagen."
nvidia-smi --auto-boost-default=ENABLED || log_error "Aktivieren von Auto Boost für NVIDIA GPUs fehlgeschlagen."

# Re-Setze ulimit in der aktuellen Shell
log_message "Setze ulimit in der aktuellen Shell."
ulimit -n 4096 || log_error "Setzen von ulimit in aktueller Sitzung fehlgeschlagen."

# Finaler Cleanup
log_message "Führe finalen Cleanup durch."
sudo nala autoremove -y || log_error "apt-get autoremove fehlgeschlagen."
sudo nala autoclean -y || log_error "apt-get autoclean fehlgeschlagen."
sudo rm -rf /var/lib/apt/lists/* || log_error "Entfernen der apt Listen fehlgeschlagen."
sudo rm -rf ~/.cache/yarn/* || log_error "Entfernen des Yarn Caches fehlgeschlagen."

# Empfehlung zum Neustart
log_message "Installation abgeschlossen. Bitte starte das System neu, um alle Änderungen zu übernehmen."
echo "Bitte starte das System neu, um alle Änderungen zu übernehmen."

