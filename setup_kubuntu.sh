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

# Füge Alias für update hinzu
log_message "Füge Alias für update hinzu."
echo "alias update='sudo nala update && sudo nala upgrade -y && sudo nala autoremove -y && sudo snap refresh'" >> ~/.bash_aliases

# Lade Aliases in die aktuelle Shell
source ~/.bash_aliases

# Installiere Nala
log_message "Installiere Nala."
sudo apt install -y nala || log_error "Installation von Nala fehlgeschlagen."

# Ersetze apt durch nala für zukünftige Befehle
alias apt='nala'

# Entferne unnötige Pakete
log_message "Entferne unnötige Social Media und Entertainment Pakete."
sudo nala remove -y spotify discord slack || log_error "Entfernen von Spotify, Discord oder Slack fehlgeschlagen."

# Installiere grundlegende Pakete mit Nala
log_message "Installiere grundlegende Pakete mit Nala."
sudo nala install -y cmus sl curl wget htop neofetch bpytop clang cargo libc6-i386 libc6-x32 libu2f-udev samba-common-bin exfat-fuse default-jdk \
    unrar linux-headers-$(uname -r) linux-headers-generic git gstreamer1.0-vaapi unzip ntfs-3g p7zip gdebi || log_error "Installation grundlegender Pakete fehlgeschlagen."

# Installiere Python 3.10 und pip
log_message "Überprüfe und installiere Python 3.10 und pip."
if ! command -v python3.10 &> /dev/null; then
    log_message "Python 3.10 nicht gefunden. Versuche zu installieren..."
    sudo nala install -y software-properties-common curl || log_error "Installation von software-properties-common fehlgeschlagen."
    sudo add-apt-repository -y ppa:deadsnakes/ppa || log_error "Hinzufügen des deadsnakes PPA fehlgeschlagen."
    sudo nala update || log_error "apt update fehlgeschlagen."
    sudo nala install -y python3.10 python3.10-venv python3.10-dev || log_error "Installation von Python 3.10 fehlgeschlagen."
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
echo "alias python=python3.10" >> ~/.bash_aliases
echo "alias pip='python3.10 -m pip'" >> ~/.bash_aliases

# Lade Aliases in die aktuelle Shell
source ~/.bash_aliases

log_message "Python 3.10 und pip Installation abgeschlossen."

# Installiere npm über Nala
log_message "Installiere npm über Nala."
sudo nala install -y npm || log_error "Installation von npm fehlgeschlagen."

# Installiere NVM (Node Version Manager) via Best Practice
log_message "Installiere NVM."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash || log_error "Installation von NVM fehlgeschlagen."

# Lade NVM in die aktuelle Shell
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Installiere NodeJS Version 20 und setze als Standard
log_message "Installiere NodeJS Version 20 und setze als Standard."
nvm install 20 || log_error "Installation von NodeJS 20 fehlgeschlagen."
nvm alias default 20 || log_error "Setzen von NodeJS 20 als Standard fehlgeschlagen."
nvm use default

# Installiere yarn
log_message "Installiere yarn."
sudo npm install --global yarn || log_error "Installation von yarn fehlgeschlagen."

# Installiere GitHub CLI
log_message "Installiere GitHub CLI."
type -p curl >/dev/null || sudo nala install -y curl || log_error "Installation von curl fehlgeschlagen."
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    || log_error "Download des GitHub CLI GPG Keys fehlgeschlagen."
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    || log_error "Hinzufügen des GitHub CLI Repositories fehlgeschlagen."
sudo nala update || log_error "apt update fehlgeschlagen."
sudo nala install -y gh || log_error "Installation von GitHub CLI fehlgeschlagen."

# GitHub Initialisierung
log_message "Initialisiere GitHub Konfiguration."
gh auth login || log_error "GitHub Authentifizierung fehlgeschlagen."

# Installiere Docker im Rootless Modus
log_message "Installiere Docker im Rootless Modus."
curl -fsSL https://get.docker.com/rootless | sh || log_error "Installation von Docker rootless fehlgeschlagen."
export PATH=/usr/bin:$PATH
dockerd-rootless-setuptool.sh install || log_error "Docker rootless Setup fehlgeschlagen."

# Installiere NVIDIA Treiber
log_message "Installiere NVIDIA Treiber."
if ! command -v nvidia-smi &> /dev/null; then
    log_message "NVIDIA Treiber nicht gefunden. Versuche zu installieren..."
    sudo nala install -y linux-headers-$(uname -r) || log_error "Installation der Linux-Header fehlgeschlagen."
    sudo nala install -y nvidia-driver-560 nvidia-utils-560 || log_error "Installation der NVIDIA Treiber fehlgeschlagen."
fi

# Installiere CUDA
log_message "Installiere CUDA."
if ! command -v nvcc &> /dev/null; then
    log_message "CUDA nicht gefunden. Versuche zu installieren..."
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin -O cuda-ubuntu2404.pin || log_error "Download von CUDA pin fehlgeschlagen."
    sudo mv cuda-ubuntu2404.pin /etc/apt/preferences.d/cuda-repository-pin-600 || log_error "Verschieben des CUDA pin fehlgeschlagen."
    wget https://developer.download.nvidia.com/compute/cuda/12.6.1/local_installers/cuda-repo-ubuntu2404-12-6-local_12.6.1-560.35.03-1_amd64.deb || log_error "Download des CUDA Repos fehlgeschlagen."
    sudo dpkg -i cuda-repo-ubuntu2404-12-6-local_12.6.1-560.35.03-1_amd64.deb || log_error "Installation des CUDA Repos fehlgeschlagen."
    sudo cp /var/cuda-repo-ubuntu2404-12-6-local/cuda-*-keyring.gpg /usr/share/keyrings/ || log_error "Kopieren des CUDA Keyrings fehlgeschlagen."
    sudo nala update || log_error "apt update fehlgeschlagen."
    sudo nala install -y cuda-toolkit-12-6 || log_error "Installation des CUDA Toolkits fehlgeschlagen."
    sudo nala install -y cuda || log_error "Installation von CUDA fehlgeschlagen."
    sudo rm cuda-repo-ubuntu2404-12-6-local_12.6.1-560.35.03-1_amd64.deb || log_error "Entfernen des CUDA Repos fehlgeschlagen."
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

# Installiere und starte Cockpit
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

# Installiere CMake und pkg-config (bereits installiert, aber nochmal sicherheitshalber)
log_message "Installiere CMake und pkg-config."
sudo nala install -y cmake pkg-config || log_error "Installation von CMake und pkg-config fehlgeschlagen."

# Installiere weitere wichtige Tools
log_message "Installiere weitere wichtige Tools."
sudo nala install -y gpg-agent wget exfat-fuse p7zip || log_error "Installation weiterer Tools fehlgeschlagen."

# Installiere Flatpak-Pakete
log_message "Installiere Flatpak-Pakete."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || log_error "Hinzufügen des Flatpak Flathub Repositories fehlgeschlagen."
flatpak install -y flathub com.transmissionbt.Transmission || log_error "Installation von Transmission via Flatpak fehlgeschlagen."
flatpak install -y flathub com.obsproject.Studio || log_error "Installation von OBS Studio via Flatpak fehlgeschlagen."

# Installiere Cursor IDE AppImage
log_message "Installiere Cursor IDE."
wget https://github.com/Cursor-IDE/cursor/releases/download/v1.0.0/cursor-1.0.0-x86_64.AppImage -O CursorIDE.AppImage || log_error "Download von Cursor IDE fehlgeschlagen."
chmod +x CursorIDE.AppImage || log_error "Setzen der Ausführungsrechte für Cursor IDE fehlgeschlagen."
sudo mv CursorIDE.AppImage /usr/local/bin/ || log_error "Verschieben von Cursor IDE fehlgeschlagen."

# Installiere Replit CLI
log_message "Installiere Replit CLI."
curl -fsSL https://raw.githubusercontent.com/replit/replit/main/install.sh | bash || log_error "Installation von Replit CLI fehlgeschlagen."

# Installiere Docker spezifische Best Practices
log_message "Installiere Docker Best Practices."
sudo nala install -y docker-compose || log_error "Installation von docker-compose fehlgeschlagen."

# Konfiguriere xrandr mit cvt und füge zu .profile hinzu
log_message "Konfiguriere xrandr mit cvt."
MODELINE=$(cvt 1680 1050 60 | grep "Modeline" | cut -d '"' -f2)
if [ -n "$MODELINE" ]; then
    xrandr --newmode $MODELINE || log_error "Erstellen eines neuen Modus mit xrandr fehlgeschlagen."
    xrandr --addmode VGA-1 1680x1050_60.00 || log_error "Hinzufügen des neuen Modus zu VGA-1 fehlgeschlagen."
    echo "xrandr --newmode \"$MODELINE\"" >> ~/.profile
    echo "xrandr --addmode VGA-1 1680x1050_60.00" >> ~/.profile
else
    log_error "Erstellen des Modelines mit cvt fehlgeschlagen."
fi

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
echo "ulimit -n 4096" >> ~/.bashrc
ulimit -n 4096 || log_error "Setzen von ulimit fehlgeschlagen."

# Clean-up heruntergeladene .deb Dateien
log_message "Bereinige heruntergeladene .deb Dateien."
sudo nala clean || log_error "Bereinigung der APT-Cache fehlgeschlagen."
find /tmp -type f -name "*.deb" -exec sudo rm -f {} \; || log_error "Entfernen der .deb Dateien fehlgeschlagen."

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

# Reboot Empfehlung
log_message "Installation abgeschlossen. Bitte starte das System neu, um alle Änderungen zu übernehmen."
echo "Bitte starte das System neu, um alle Änderungen zu übernehmen."
