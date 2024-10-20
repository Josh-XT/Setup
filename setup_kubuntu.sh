#!/bin/bash

# Setze Fehlerbehandlung, aber fahre bei Fehlern fort
set +e

# Definiere Variablen
LOG_FILE="/var/log/kubuntu_setup.log"
ERROR_LOG="$(dirname "$0")/error.txt"

# Funktion zum Protokollieren von Nachrichten
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Funktion zum Protokollieren von Fehlern
log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: $1" | tee -a "$LOG_FILE" "$ERROR_LOG"
}

# Backup der bestehenden .bashrc und .bash_aliases
log_message "Erstelle Backups von bestehenden Konfigurationsdateien."
cp ~/.bashrc ~/.bashrc.backup || log_error "Backup von .bashrc fehlgeschlagen."
cp ~/.bash_aliases ~/.bash_aliases.backup 2>/dev/null || touch ~/.bash_aliases

# Installiere NALA, falls nicht bereits installiert
log_message "Überprüfe und installiere NALA."
if ! command -v nala &> /dev/null; then
    log_message "NALA nicht gefunden. Versuche zu installieren..."
    sudo apt update || log_error "apt update fehlgeschlagen."
    sudo apt install -y curl gnupg lsb-release || log_error "Installation von curl, gnupg, lsb-release fehlgeschlagen."
    curl -s https://deb.volian.org/volian.key | sudo gpg --dearmor -o /usr/share/keyrings/volian-archive-keyring.gpg || log_error "Hinzufügen des Volian GPG-Schlüssels fehlgeschlagen."
    echo "deb [signed-by=/usr/share/keyrings/volian-archive-keyring.gpg] https://deb.volian.org/volian/ releases main" | sudo tee /etc/apt/sources.list.d/nala.list || log_error "Hinzufügen des NALA Repositories fehlgeschlagen."
    sudo apt update || log_error "apt update nach Hinzufügen von NALA Repository fehlgeschlagen."
    sudo apt install -y nala || log_error "Installation von NALA fehlgeschlagen."
else
    log_message "NALA ist bereits installiert."
fi

# Füge Alias für update hinzu
log_message "Füge Alias für update hinzu."
echo "alias update='sudo nala update && sudo nala upgrade -y && sudo nala autoremove -y && sudo snap refresh'" >> ~/.bash_aliases || log_error "Hinzufügen des update Alias fehlgeschlagen."

# Lade Aliases in die aktuelle Shell
source ~/.bash_aliases || log_error "Laden der Aliases fehlgeschlagen."

# Entferne unnötige Social Media und Entertainment Pakete
log_message "Entferne unnötige Social Media und Entertainment Pakete."
sudo nala remove -y spotify discord slack || log_error "Entfernen von Spotify, Discord oder Slack fehlgeschlagen."

# Installiere Git und GitHub CLI
log_message "Installiere Git und GitHub CLI."
sudo nala install -y git gh || log_error "Installation von Git oder GitHub CLI fehlgeschlagen."

# Git Konfiguration
log_message "Konfiguriere Git."
git config --global submodule.recurse true || log_error "Git config submodule.recurse fehlgeschlagen."
git config --global credential.helper store || log_error "Git config credential.helper fehlgeschlagen."
git config --global user.email "vesiassr@gmail.com" || log_error "Git config user.email fehlgeschlagen."
git config --global user.name "Vesias" || log_error "Git config user.name fehlgeschlagen."
echo "Updates" > ~/.gitmessage
git config --global commit.template ~/.gitmessage || log_error "Git config commit.template fehlgeschlagen."

# Installiere Python 3.10 und pip
log_message "Überprüfe und installiere Python 3.10 und pip."
if ! command -v python3.10 &> /dev/null; then
    log_message "Python 3.10 nicht gefunden. Versuche zu installieren..."
    sudo nala install -y software-properties-common curl || log_error "Installation von software-properties-common oder curl fehlgeschlagen."
    sudo add-apt-repository -y ppa:deadsnakes/ppa || log_error "Hinzufügen des deadsnakes PPA fehlgeschlagen."
    sudo nala update || log_error "apt update fehlgeschlagen."
    sudo nala install -y python3.10 python3.10-venv python3.10-dev || log_error "Installation von Python 3.10 fehlgeschlagen."
else
    log_message "Python 3.10 ist bereits installiert."
fi

# Sicherstellen, dass pip für Python 3.10 installiert ist
if ! python3.10 -m pip --version &> /dev/null; then
    log_message "pip für Python 3.10 nicht gefunden. Versuche zu installieren..."
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py || log_error "Download von get-pip.py fehlgeschlagen."
    python3.10 get-pip.py --user || log_error "Installation von pip fehlgeschlagen."
    rm get-pip.py
fi

# Erstelle Aliase für python und pip
log_message "Erstelle Aliase für python und pip."
echo "alias python=python3.10" >> ~/.bash_aliases || log_error "Hinzufügen des python Alias fehlgeschlagen."
echo "alias pip='python3.10 -m pip'" >> ~/.bash_aliases || log_error "Hinzufügen des pip Alias fehlgeschlagen."

# Lade Aliases in die aktuelle Shell
source ~/.bash_aliases || log_error "Laden der Aliases fehlgeschlagen."

log_message "Python 3.10 und pip Installation abgeschlossen."

# Installiere nvm und setze Node.js Version 20 als Standard
log_message "Installiere nvm und setze Node.js Version 20 als Standard."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash || log_error "Installation von nvm fehlgeschlagen."
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || log_error "Laden von nvm fehlgeschlagen."
nvm install 20 || log_error "Installation von Node.js Version 20 fehlgeschlagen."
nvm alias default 20 || log_error "Setzen von Node.js Version 20 als Standard fehlgeschlagen."
nvm use default || log_error "Wechsel zu Node.js Version 20 fehlgeschlagen."

# Installiere npm über nvm (sollte bereits mit Node.js installiert sein)
log_message "Stelle sicher, dass npm installiert ist."
if ! command -v npm &> /dev/null; then
    log_error "npm ist nicht installiert."
else
    log_message "npm ist bereits installiert."
fi

# Installiere Docker im Rootless Modus
log_message "Installiere Docker im Rootless Modus."
curl -fsSL https://get.docker.com/rootless | sh || log_error "Installation von Docker rootless fehlgeschlagen."
export PATH=/usr/bin:$PATH
dockerd-rootless-setuptool.sh install || log_error "Docker rootless Setup fehlgeschlagen."
export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock

# Installiere NVIDIA Treiber
log_message "Installiere NVIDIA Treiber."
if ! command -v nvidia-smi &> /dev/null; then
    log_message "NVIDIA Treiber nicht gefunden. Versuche zu installieren..."
    sudo nala install -y linux-headers-$(uname -r) || log_error "Installation der Linux-Header fehlgeschlagen."
    sudo nala install -y nvidia-driver-560 nvidia-utils-560 || log_error "Installation der NVIDIA Treiber fehlgeschlagen."
else
    log_message "NVIDIA Treiber sind bereits installiert."
fi

# Installiere CUDA
log_message "Installiere CUDA."
if ! command -v nvcc &> /dev/null; then
    log_message "CUDA nicht gefunden. Versuche zu installieren..."
    CUDA_DEB="cuda-repo-ubuntu2404-12-6-local_12.6.1-560.35.03-1_amd64.deb"
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/$CUDA_DEB || log_error "Download des CUDA Repos fehlgeschlagen."
    sudo nala install -y ./$CUDA_DEB || log_error "Installation des CUDA Repos fehlgeschlagen."
    sudo cp /var/cuda-repo-ubuntu2404-12-6-local/cuda-*-keyring.gpg /usr/share/keyrings/ || log_error "Kopieren des CUDA Keyrings fehlgeschlagen."
    sudo nala update || log_error "apt update fehlgeschlagen."
    sudo nala install -y cuda-toolkit-12-6 || log_error "Installation des CUDA Toolkits fehlgeschlagen."
    sudo nala install -y cuda || log_error "Installation von CUDA fehlgeschlagen."
    sudo rm -f ./$CUDA_DEB || log_error "Entfernen des CUDA Repos fehlgeschlagen."
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

# Installiere Anaconda
log_message "Installiere Anaconda."
mkdir -p ~/miniconda3 || log_error "Erstellen des Verzeichnisses für Anaconda fehlgeschlagen."
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh || log_error "Download von Anaconda fehlgeschlagen."
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3 || log_error "Installation von Anaconda fehlgeschlagen."
rm ~/miniconda3/miniconda.sh
~/miniconda3/bin/conda init bash || log_error "Conda init bash fehlgeschlagen."
~/miniconda3/bin/conda init zsh || log_error "Conda init zsh fehlgeschlagen."

# Installiere CMake und pkg-config
log_message "Installiere CMake und pkg-config."
sudo nala install -y cmake pkg-config || log_error "Installation von CMake und pkg-config fehlgeschlagen."

# Installiere weitere wichtige Tools
log_message "Installiere weitere wichtige Tools."
sudo nala install -y gpg-agent wget exfat-fuse p7zip || log_error "Installation weiterer Tools fehlgeschlagen."

# Installiere Flatpak-Pakete
log_message "Installiere Flatpak-Pakete."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || log_error "Hinzufügen des Flatpak Flathub Repositories fehlgeschlagen."
flatpak install -y flathub com.spotify.Client || log_error "Installation von Spotify via Flatpak fehlgeschlagen."
flatpak install -y flathub com.transmissionbt.Transmission || log_error "Installation von Transmission via Flatpak fehlgeschlagen."
flatpak install -y flathub com.obsproject.Studio || log_error "Installation von OBS Studio via Flatpak fehlgeschlagen."

# Installiere LM Studio und NVIDIA AI Workbench
log_message "Installiere LM Studio und NVIDIA AI Workbench."
LM_STUDIO="LM_Studio-0.2.19.AppImage"
wget https://releases.lmstudio.ai/linux/0.2.19/beta/$LM_STUDIO || log_error "Download von LM Studio fehlgeschlagen."
chmod +x $LM_STUDIO || log_error "Setzen der Ausführungsrechte für LM Studio fehlgeschlagen."
# Optional: Starte LM Studio
# ./$LM_STUDIO &

AI_WORKBENCH="NVIDIA-AI-Workbench-x86_64.AppImage"
wget https://workbench.download.nvidia.com/stable/workbench-desktop/0.57.3/$AI_WORKBENCH || log_error "Download von NVIDIA AI Workbench fehlgeschlagen."
chmod +x $AI_WORKBENCH || log_error "Setzen der Ausführungsrechte für NVIDIA AI Workbench fehlgeschlagen."
sudo mv $AI_WORKBENCH /usr/local/bin/ || log_error "Verschieben von NVIDIA AI Workbench fehlgeschlagen."
sudo ./$AI_WORKBENCH --no-sandbox &

# Installiere xpipe
log_message "Installiere xpipe."
bash <(curl -sL https://github.com/xpipe-io/xpipe/raw/master/get-xpipe.sh) || log_error "Installation von xpipe fehlgeschlagen."

# Installiere Go-Protokolle
log_message "Installiere Go-Protokolle."
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest || log_error "Installation von protoc-gen-go-grpc fehlgeschlagen."
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest || log_error "Installation von protoc-gen-go fehlgeschlagen."
export PATH="$PATH:$(go env GOPATH)/bin"

# Clone und Build von grpc-go Beispielen
log_message "Clone und build grpc-go Beispiele."
git clone -b v1.65.0 --depth 1 https://github.com/grpc/grpc-go || log_error "Clone von grpc-go fehlgeschlagen."
cd grpc-go/examples/helloworld || log_error "Wechsel in das grpc-go Beispielverzeichnis fehlgeschlagen."
make || log_error "Build des grpc-go Beispiels fehlgeschlagen."
cd ../../.. || log_error "Wechsel ins Hauptverzeichnis fehlgeschlagen."

# Clone und Build von LocalAI
log_message "Clone und build LocalAI."
git clone https://github.com/mudler/LocalAI.git || log_error "Clone von LocalAI fehlgeschlagen."
cd LocalAI || log_error "Wechsel in das LocalAI Verzeichnis fehlgeschlagen."
make build || log_error "Build von LocalAI fehlgeschlagen."
cd .. || log_error "Wechsel ins Hauptverzeichnis fehlgeschlagen."

# Installiere und konfiguriere UFW
log_message "Installiere und konfiguriere UFW."
sudo nala install -y ufw || log_error "Installation von UFW fehlgeschlagen."
sudo systemctl enable ufw || log_error "Aktivieren von UFW fehlgeschlagen."
sudo systemctl start ufw || log_error "Starten von UFW fehlgeschlagen."
# Erlaube Standardports
sudo ufw allow 5000 || log_error "Erlauben von Port 5000 fehlgeschlagen."
sudo ufw allow 3000 || log_error "Erlauben von Port 3000 fehlgeschlagen."
sudo ufw allow 8080 || log_error "Erlauben von Port 8080 fehlgeschlagen."
sudo ufw allow 8000 || log_error "Erlauben von Port 8000 fehlgeschlagen."
# Blockiere Port 22
sudo ufw deny 22/tcp || log_error "Blockieren von Port 22 fehlgeschlagen."

# Füge Intel OneAPI und NVIDIA HPC SDK Repositorys hinzu
log_message "Füge Intel OneAPI und NVIDIA HPC SDK Repositorys hinzu."
wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | gpg --dearmor | sudo tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null || log_error "Hinzufügen des Intel OneAPI GPG Keys fehlgeschlagen."
echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list || log_error "Hinzufügen des Intel OneAPI Repositories fehlgeschlagen."

curl https://developer.download.nvidia.com/hpc-sdk/ubuntu/DEB-GPG-KEY-NVIDIA-HPC-SDK | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-hpcsdk-archive-keyring.gpg || log_error "Hinzufügen des NVIDIA HPC SDK GPG Keys fehlgeschlagen."
echo 'deb [signed-by=/usr/share/keyrings/nvidia-hpcsdk-archive-keyring.gpg] https://developer.download.nvidia.com/hpc-sdk/ubuntu/amd64 /' | sudo tee /etc/apt/sources.list.d/nvhpc.list || log_error "Hinzufügen des NVIDIA HPC SDK Repositories fehlgeschlagen."

# Aktualisiere die Paketliste und installiere NVIDIA HPC SDK
log_message "Aktualisiere die Paketliste und installiere NVIDIA HPC SDK."
sudo nala update || log_error "apt update fehlgeschlagen."
sudo nala install -y nvhpc-24-5 intel-basekit intel-hpckit || log_error "Installation des NVIDIA HPC SDK fehlgeschlagen."

# Installiere Ollama
log_message "Installiere Ollama."
curl -fsSL https://ollama.com/install.sh | sh || log_error "Installation von Ollama fehlgeschlagen."

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
echo "ulimit -n 4096" >> ~/.bashrc || log_error "Hinzufügen von ulimit zu .bashrc fehlgeschlagen."
ulimit -n 4096 || log_error "Setzen von ulimit fehlgeschlagen."

# Clean-up heruntergeladene .deb Dateien
log_message "Bereinige heruntergeladene .deb Dateien."
sudo find /var/cache/apt/archives/ -type f -name "*.deb" -exec rm -f {} \; || log_error "Entfernen der .deb Dateien fehlgeschlagen."

# Konfiguriere Docker für Rootless Nutzung über SSH
log_message "Konfiguriere Docker für Rootless Nutzung über SSH."
# Docker Rootless Setup
dockerd-rootless-setuptool.sh install || log_error "Docker Rootless Setup fehlgeschlagen."
export PATH=/usr/bin:$PATH
export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock

# Starte Docker Rootless Daemon
log_message "Starte Docker Rootless Daemon."
systemctl --user start docker || log_error "Starten des Docker Rootless Daemon fehlgeschlagen."
systemctl --user enable docker || log_error "Aktivieren des Docker Rootless Daemon fehlgeschlagen."

# Stelle sicher, dass LAN aktiviert ist
log_message "Stelle sicher, dass LAN aktiviert ist."
nmcli networking on || log_error "Aktivieren von Netzwerk fehlgeschlagen."

# Finaler Cleanup
log_message "Führe finalen Cleanup durch."
sudo nala autoremove -y || log_error "apt-get autoremove fehlgeschlagen."
sudo nala autoclean -y || log_error "apt-get autoclean fehlgeschlagen."
sudo rm -rf /var/lib/apt/lists/* || log_error "Entfernen der apt Listen fehlgeschlagen."
sudo rm -rf ~/.cache/yarn/* || log_error "Entfernen des Yarn Caches fehlgeschlagen."

# Aktualisiere initramfs und Grub
log_message "Aktualisiere initramfs und Grub."
sudo update-initramfs -u || log_error "Update von initramfs fehlgeschlagen."
sudo update-grub || log_error "Update von Grub fehlgeschlagen."

# Best Practices für CLI Konfiguration ohne Vim
log_message "Konfiguriere CLI Best Practices."
# Installiere zsh und oh-my-zsh
sudo nala install -y zsh || log_error "Installation von zsh fehlgeschlagen."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || log_error "Installation von oh-my-zsh fehlgeschlagen."
chsh -s $(which zsh) || log_error "Ändern der Standard-Shell zu zsh fehlgeschlagen."

# Installiere nnn als alternativen Dateimanager
sudo nala install -y nnn || log_error "Installation von nnn fehlgeschlagen."

# Setze nnn als Standard Dateimanager (optional)
echo "alias fm='nnn'" >> ~/.bash_aliases || log_error "Hinzufügen des fm Alias fehlgeschlagen."
source ~/.bash_aliases || log_error "Laden der Aliases fehlgeschlagen."

# Reboot Empfehlung
log_message "Installation abgeschlossen. Bitte starte das System neu, um alle Änderungen zu übernehmen."
echo "Bitte starte das System neu, um alle Änderungen zu übernehmen."
