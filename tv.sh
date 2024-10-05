#!/bin/bash

# Function to check if the script is run with sudo privileges
check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run this script with sudo privileges"
        exit 1
    fi
}

# Function to create the "kids" user if it doesn't exist
create_kids_user() {
    if id "kids" &>/dev/null; then
        echo "Existing 'kids' user found. Preparing for removal..."
        pkill -u kids
        sleep 2
        pkill -KILL -u kids
        echo "Deleting existing 'kids' user"
        userdel -r kids
    fi
    echo "Creating 'kids' user"
    adduser --disabled-password --gecos "" kids
}

# Function to configure auto-login for the "kids" user
configure_auto_login() {
    echo "Configuring auto-login for 'kids' user"
    if [ -f /etc/gdm3/custom.conf ]; then
        sed -i '/AutomaticLoginEnable/d' /etc/gdm3/custom.conf
        sed -i '/AutomaticLogin/d' /etc/gdm3/custom.conf
        sed -i '/\[daemon\]/a AutomaticLoginEnable=true\nAutomaticLogin=kids' /etc/gdm3/custom.conf
    else
        echo "[daemon]" > /etc/gdm3/custom.conf
        echo "AutomaticLoginEnable=true" >> /etc/gdm3/custom.conf
        echo "AutomaticLogin=kids" >> /etc/gdm3/custom.conf
    fi
}

# Function to set up Chromium
setup_chromium() {
    echo "Setting up Chromium"
    apt-get update
    apt-get install -y chromium-browser

    HOMEPAGE="http://devxt-nas01:31437"
    POLICIES_DIR="/etc/chromium-browser/policies/managed"
    mkdir -p "$POLICIES_DIR"

    cat > "$POLICIES_DIR/kids_policy.json" << EOF
{
    "HomepageLocation": "$HOMEPAGE",
    "HomepageIsNewTabPage": false,
    "NewTabPageLocation": "$HOMEPAGE",
    "RestoreOnStartup": 4,
    "RestoreOnStartupURLs": ["$HOMEPAGE"],
    "BookmarkBarEnabled": false,
    "IncognitoModeAvailability": 1,
    "BrowserSignin": 0,
    "SyncDisabled": true,
    "SearchSuggestEnabled": false
}
EOF

    AUTOSTART_DIR="/home/kids/.config/autostart"
    mkdir -p "$AUTOSTART_DIR"
    chown kids:kids "$AUTOSTART_DIR"

    cat > "$AUTOSTART_DIR/chromium-kiosk.desktop" << EOF
[Desktop Entry]
Type=Application
Exec=chromium-browser --kiosk --no-first-run --disable-pinch --overscroll-history-navigation=0 --disable-features=TranslateUI --no-default-browser-check $HOMEPAGE
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Chromium Kiosk
Name=Chromium Kiosk
Comment=Start Chromium in kiosk mode
EOF
    chown kids:kids "$AUTOSTART_DIR/chromium-kiosk.desktop"
}

# Function to modify hosts file for redirecting websites
modify_hosts_file() {
    echo "Modifying hosts file to redirect certain websites"
    WEBSITES=(
        "www.youtube.com"
        "youtube.com"
        "youtu.be"
        "www.facebook.com"
        "facebook.com"
        "www.tiktok.com"
        "tiktok.com"
    )
    
    cp /etc/hosts /etc/hosts.backup
    
    for site in "${WEBSITES[@]}"; do
        if ! grep -q "$site" /etc/hosts; then
            echo "127.0.0.1 $site" >> /etc/hosts
        fi
    done
}

# Function to disable Ubuntu initial setup
disable_initial_setup() {
    echo "Disabling Ubuntu initial setup"
    if [ -f /etc/xdg/autostart/gnome-initial-setup-first-login.desktop ]; then
        mv /etc/xdg/autostart/gnome-initial-setup-first-login.desktop /etc/xdg/autostart/gnome-initial-setup-first-login.desktop.disabled
    fi
    if [ -f /etc/xdg/autostart/gnome-welcome-tour.desktop ]; then
        mv /etc/xdg/autostart/gnome-welcome-tour.desktop /etc/xdg/autostart/gnome-welcome-tour.desktop.disabled
    fi
}

# Function to disable Windows key, sidebar, and other unwanted features
disable_features() {
    echo "Disabling Windows key, sidebar, and other features"

    # Disable Ubuntu dock system-wide
    gsettings set org.gnome.shell enabled-extensions "[]"
    gsettings set org.gnome.shell disabled-extensions "['ubuntu-dock@ubuntu.com']"

    # Disable overlay-key (Windows key) system-wide
    gsettings set org.gnome.mutter overlay-key ''

    # Disable hot corners system-wide
    gsettings set org.gnome.desktop.interface enable-hot-corners false

    # Create a script to apply these settings for the kids user on login
    SCRIPT_PATH="/home/kids/.config/disable_features.sh"
    cat > "$SCRIPT_PATH" << EOF
#!/bin/bash
gsettings set org.gnome.shell enabled-extensions "[]"
gsettings set org.gnome.shell disabled-extensions "['ubuntu-dock@ubuntu.com']"
gsettings set org.gnome.mutter overlay-key ''
gsettings set org.gnome.desktop.interface enable-hot-corners false
EOF

    chmod +x "$SCRIPT_PATH"
    chown kids:kids "$SCRIPT_PATH"

    # Add the script to autostart for the kids user
    AUTOSTART_DIR="/home/kids/.config/autostart"
    mkdir -p "$AUTOSTART_DIR"
    cat > "$AUTOSTART_DIR/disable_features.desktop" << EOF
[Desktop Entry]
Type=Application
Exec=/home/kids/.config/disable_features.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Disable Unwanted Features
Name=Disable Unwanted Features
Comment=Disables Windows key, sidebar, and other features for kids user
EOF
    chown -R kids:kids "$AUTOSTART_DIR"

    # Disable the GNOME shell completely for the kids user
    sudo -u kids dconf write /org/gnome/desktop/session/session-name "'ubuntu'"
}

# Main script execution
check_sudo
sudo apt update --fix-missing -y && sudo apt upgrade -y
create_kids_user
configure_auto_login
setup_chromium
modify_hosts_file
disable_initial_setup
disable_features

echo "Setup complete. Please reboot the system to apply changes."